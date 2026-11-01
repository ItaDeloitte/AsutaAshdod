#Requires -Version 5.1
<#
.SYNOPSIS
    Exclude custom field(s) from the AssutaMerkazim deployment source, with
    reason-dependent behavior.

.DESCRIPTION
    Shared helper used directly by the `exclude-fields` skill and called by the
    `org-git-sync-objects` and `exclude-future-deployment` skills.

    DELETION REQUIRES A REASON, and the reason decides which trees are touched:

      Deprecated | OnlyLocal   -> delete from BOTH test\ and force-app\
      FutureDeployment         -> delete from test\ ONLY, keep the source in
                                  force-app\, and add a commented .forceignore
                                  entry so the field stays out of the manifest and
                                  out of the test\ retrieve. Also records the field
                                  in docs\sync\excluded-pending-future-deployment.md
                                  for restoration.

    For each "Object.Field" it handles:
      - objects/<Obj>/fields/<Field>.field-meta.xml
      - objectTranslations/<Obj>-*/<Field>.fieldTranslation-meta.xml  (EVERY language)
    and, ONLY for Deprecated/OnlyLocal (a full removal), also removes safe inline
    references from compactLayouts, fieldSets and inline objectTranslation blocks.
    For FutureDeployment the field stays in force-app untouched, so its references
    are left in place (they are reported for review).

    Any other reference (validation rules, record types, formulas, web links,
    quick actions, layouts, cross-object "<Obj>.<Field>") is reported for MANUAL
    REVIEW and never auto-edited.

    Every field is appended to docs\sync\field-exclusions-log.md.

.PARAMETER Fields
    One or more "Object.Field__c" identifiers. Entries may also be comma-joined.

.PARAMETER Reason
    FutureDeployment | Deprecated | OnlyLocal  (required).

.PARAMETER Note
    Optional detail. For FutureDeployment it is the blocker (what it waits on) and
    appears in the .forceignore comment and the restoration tracker.

.PARAMETER RestoreAfter
    FutureDeployment only: short "restore after X" note for the tracker. Defaults
    to -Note.

.PARAMETER DryRun
    Report what would change; make no edits and write no log.

.EXAMPLE
    .\scripts\Exclude-Fields.ps1 -Fields "Case.Old_Status__c" -Reason Deprecated

.EXAMPLE
    .\scripts\Exclude-Fields.ps1 -Fields "SurveyTaker__c.Site__c" `
        -Reason FutureDeployment -Note "Site__c not yet in production" `
        -RestoreAfter "Site__c deployed to prod"
#>
param(
    [Parameter(Mandatory = $true)]
    [string[]]$Fields,

    [Parameter(Mandatory = $true)]
    [ValidateSet('FutureDeployment', 'Deprecated', 'OnlyLocal')]
    [string]$Reason,

    [string]$Note = '',

    [string]$RestoreAfter = '',

    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ============================================================
# CONSTANTS
# ============================================================
$script:ProjectRoot = Split-Path $PSScriptRoot -Parent
$script:Trees = [ordered]@{
    'force-app' = Join-Path $script:ProjectRoot 'force-app\main\default'
    'test'      = Join-Path $script:ProjectRoot 'test\main\default'
}
$script:LogPath     = Join-Path $script:ProjectRoot 'docs\sync\field-exclusions-log.md'
$script:ForceIgnore = Join-Path $script:ProjectRoot '.forceignore'
$script:TrackFile   = Join-Path $script:ProjectRoot 'docs\sync\excluded-pending-future-deployment.md'
$script:NowUtc      = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd HH:mmZ')
$script:Today       = (Get-Date).ToString('yyyy-MM-dd')

# Reason-dependent behavior
$script:FullDelete = ($Reason -ne 'FutureDeployment')   # delete force-app too + strip inline refs
$script:Deferral   = ($Reason -eq 'FutureDeployment')   # test-only delete + .forceignore + tracker

# ============================================================
# HELPERS
# ============================================================
function Write-Head([string]$m) { Write-Host "`n== $m ==" -ForegroundColor Cyan }
function Write-Line([string]$m) { Write-Host "  $m" }
function Write-Note([string]$m) { Write-Host "  $m" -ForegroundColor DarkGray }
function Write-Flag([string]$m) { Write-Host "  REVIEW: $m" -ForegroundColor Yellow }

function Read-FileInfo([string]$path) {
    $bytes  = [System.IO.File]::ReadAllBytes($path)
    $hasBom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
    $text   = [System.Text.Encoding]::UTF8.GetString($bytes)
    if ($text.Length -gt 0 -and $text[0] -eq [char]0xFEFF) { $text = $text.Substring(1) }
    $nl = if ($text -match "`r`n") { "`r`n" } else { "`n" }
    return [pscustomobject]@{ Text = $text; HasBom = $hasBom; Newline = $nl }
}

function Write-FilePreserving([string]$path, [string]$text, [bool]$hasBom, [string]$nl) {
    $norm = $text -replace "`r`n", "`n"
    if ($nl -eq "`r`n") { $norm = $norm -replace "`n", "`r`n" }
    $enc = New-Object System.Text.UTF8Encoding($hasBom)
    [System.IO.File]::WriteAllText($path, $norm, $enc)
}

function Remove-SingleLineElement([string]$path, [string]$field) {
    $info    = Read-FileInfo $path
    $lines   = ($info.Text -replace "`r`n", "`n") -split "`n"
    $pattern = "^\s*<fields>$([regex]::Escape($field))</fields>\s*$"
    $kept    = @($lines | Where-Object { $_ -notmatch $pattern })
    $removed = $lines.Count - $kept.Count
    if ($removed -gt 0 -and -not $DryRun) {
        Write-FilePreserving $path (($kept -join "`n")) $info.HasBom $info.Newline
    }
    return $removed
}

function Remove-XmlBlocks([string]$path, [string]$tag, [string]$field) {
    $info  = Read-FileInfo $path
    $lines = ($info.Text -replace "`r`n", "`n") -split "`n"
    $out   = New-Object System.Collections.Generic.List[string]
    $needle1 = "<field>$([regex]::Escape($field))</field>"
    $needle2 = "<name>$([regex]::Escape($field))</name>"
    $i = 0; $removed = 0
    while ($i -lt $lines.Count) {
        $line = $lines[$i]
        if ($line -match "^\s*<$tag>\s*$") {
            $block = New-Object System.Collections.Generic.List[string]
            $block.Add($line)
            $j = $i + 1
            while ($j -lt $lines.Count -and $lines[$j] -notmatch "^\s*</$tag>\s*$") {
                $block.Add($lines[$j]); $j++
            }
            if ($j -lt $lines.Count) { $block.Add($lines[$j]) }
            $blockText = ($block -join "`n")
            if ($blockText -match [regex]::Escape($needle1) -or $blockText -match [regex]::Escape($needle2)) {
                $removed++
            } else {
                foreach ($b in $block) { $out.Add($b) }
            }
            $i = $j + 1
        } else {
            $out.Add($line); $i++
        }
    }
    if ($removed -gt 0 -and -not $DryRun) {
        Write-FilePreserving $path (($out.ToArray() -join "`n")) $info.HasBom $info.Newline
    }
    return $removed
}

function Invoke-GitGrep([string[]]$grepArgs) {
    Push-Location $script:ProjectRoot
    $savedEap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $out = & git grep -nI @grepArgs 2>$null
        return @($out)
    } catch {
        return @()
    } finally {
        $ErrorActionPreference = $savedEap
        Pop-Location
    }
}

function Invoke-RefScan([string]$obj, [string]$field) {
    # Remaining references in force-app for MANUAL REVIEW. The field's own file is excluded.
    $selfRel = "force-app/main/default/objects/$obj/fields/$field.field-meta.xml"
    $review  = New-Object System.Collections.Generic.List[string]
    foreach ($g in (Invoke-GitGrep @('-F', '-w', '-e', $field, '--', "force-app/main/default/objects/$obj"))) {
        $m = [regex]::Match($g, '^(.*?):(\d+):')
        if ($m.Success) {
            $rel = $m.Groups[1].Value.Replace('\', '/')
            if ($rel -ne $selfRel) { $null = $review.Add("${rel}:$($m.Groups[2].Value)") }
        }
    }
    foreach ($g in (Invoke-GitGrep @('-F', '-w', '-e', "$obj.$field", '--',
            'force-app/main/default/objects', 'force-app/main/default/quickActions'))) {
        $m = [regex]::Match($g, '^(.*?):(\d+):')
        if ($m.Success) {
            $rel = $m.Groups[1].Value.Replace('\', '/')
            if ($rel -ne $selfRel) { $null = $review.Add("${rel}:$($m.Groups[2].Value)") }
        }
    }
    return @($review | Sort-Object -Unique)
}

function Add-ForceIgnorePatterns([string[]]$patterns, [string]$comment) {
    # Idempotent, BOM-safe append to the bottom of .forceignore. Returns patterns added.
    if (-not (Test-Path $script:ForceIgnore)) { throw ".forceignore not found at project root." }
    $info = Read-FileInfo $script:ForceIgnore
    $existing = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($ln in (($info.Text -replace "`r`n", "`n") -split "`n")) {
        $t = $ln.Trim()
        if ($t -ne '' -and -not $t.StartsWith('#')) { $null = $existing.Add($t) }
    }
    $toAdd = @($patterns | Where-Object { -not $existing.Contains($_.Trim()) })
    if ($toAdd.Count -eq 0) { return @() }
    $block = New-Object System.Collections.Generic.List[string]
    $block.Add('')
    $block.Add("# $comment")
    foreach ($p in $toAdd) { $block.Add($p) }
    if (-not $DryRun) {
        $newText = $info.Text
        if (-not $newText.EndsWith("`n")) { $newText += "`n" }
        $newText += (($block -join "`n") + "`n")
        Write-FilePreserving $script:ForceIgnore $newText $info.HasBom $info.Newline
    }
    return $toAdd
}

function Add-TrackerRow([string]$component, [string]$type, [string]$filePath, [string]$reason, [string]$restoreAfter) {
    $docsSync = Split-Path $script:TrackFile -Parent
    if (-not $DryRun -and -not (Test-Path $docsSync)) { New-Item -ItemType Directory -Path $docsSync -Force | Out-Null }
    if (-not (Test-Path $script:TrackFile)) {
        $header = @(
            '# Excluded — Pending Future Deployment',
            '',
            'Components kept in `force-app` but excluded from this wave via `.forceignore`',
            '(and removed from the test/ staging tree) because they depend on something not',
            'yet in production. Restore each after the blocking deployment by removing its',
            '`.forceignore` lines, then re-running the sync.',
            '',
            '| Date (UTC) | Component | Type | Excluded file | Blocked by / Reason | Restore after |',
            '|---|---|---|---|---|---|'
        ) -join "`n"
        if (-not $DryRun) {
            $enc = New-Object System.Text.UTF8Encoding($false)
            [System.IO.File]::WriteAllText($script:TrackFile, $header + "`n", $enc)
        }
    }
    $row = "| $script:NowUtc | $component | $type | $filePath | $reason | $restoreAfter |"
    if (-not $DryRun) {
        $existing = [System.IO.File]::ReadAllText($script:TrackFile)
        if (-not $existing.EndsWith("`n")) { $existing += "`n" }
        $existing += ($row + "`n")
        $enc = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($script:TrackFile, $existing, $enc)
    }
    Write-Line "tracker -> docs/sync/excluded-pending-future-deployment.md"
    Write-Note $row
}

# ============================================================
# MAIN
# ============================================================
$dryLabel = if ($DryRun) { '  [DRY RUN]' } else { '' }
$behavior = if ($script:FullDelete) { 'delete from test + force-app' } else { 'delete from test only; keep + .forceignore in force-app' }
Write-Host "Exclude-Fields.ps1  (Reason: $Reason -> $behavior)$dryLabel" -ForegroundColor White
Write-Host "Project root: $script:ProjectRoot"

# Normalise field list (allow comma-joined entries)
$targets = New-Object System.Collections.Generic.List[string]
foreach ($raw in $Fields) {
    foreach ($part in ($raw -split ',')) {
        $t = $part.Trim()
        if ($t -ne '') { $targets.Add($t) }
    }
}
if ($targets.Count -eq 0) { Write-Host "No fields supplied." -ForegroundColor Red; exit 1 }

# Trees we physically delete from
$treesToDelete = if ($script:FullDelete) { @('force-app', 'test') } else { @('test') }

$logRows = New-Object System.Collections.Generic.List[string]

foreach ($target in $targets) {
    $dotIdx = $target.IndexOf('.')
    if ($dotIdx -le 0 -or $dotIdx -ge ($target.Length - 1)) {
        Write-Host "SKIP '$target' -- expected Object.Field format." -ForegroundColor Red
        continue
    }
    $obj   = $target.Substring(0, $dotIdx)
    $field = $target.Substring($dotIdx + 1)

    Write-Head "$obj.$field"

    $deletedFiles = New-Object System.Collections.Generic.List[string]
    $treesTouched = New-Object System.Collections.Generic.List[string]
    $refsRemoved  = 0
    $ignoredAdded = 0

    foreach ($treeName in $treesToDelete) {
        $treeBase = $script:Trees[$treeName]
        if (-not (Test-Path $treeBase)) { continue }
        $touched = $false

        # (1) field-meta.xml
        $fieldPath = Join-Path $treeBase "objects\$obj\fields\$field.field-meta.xml"
        if (Test-Path $fieldPath) {
            if (-not $DryRun) { Remove-Item $fieldPath -Force }
            $rel = $fieldPath.Substring($script:ProjectRoot.Length).TrimStart('\').Replace('\', '/')
            $deletedFiles.Add($rel); $touched = $true
            Write-Line "[$treeName] deleted field  $rel"
        }

        # (2) field translations -- EVERY language
        $transBase = Join-Path $treeBase 'objectTranslations'
        if (Test-Path $transBase) {
            foreach ($langDir in @(Get-ChildItem -Path $transBase -Directory -Filter "$obj-*" -ErrorAction SilentlyContinue)) {
                $tp = Join-Path $langDir.FullName "$field.fieldTranslation-meta.xml"
                if (Test-Path $tp) {
                    if (-not $DryRun) { Remove-Item $tp -Force }
                    $rel = $tp.Substring($script:ProjectRoot.Length).TrimStart('\').Replace('\', '/')
                    $deletedFiles.Add($rel); $touched = $true
                    Write-Line "[$treeName] deleted translation  $rel"
                }
                # inline <fields><name>Field</name>...</fields> -- only on a full removal
                if ($script:FullDelete) {
                    $mainT = Join-Path $langDir.FullName "$($langDir.Name).objectTranslation-meta.xml"
                    if (Test-Path $mainT) {
                        $r = Remove-XmlBlocks $mainT 'fields' $field
                        if ($r -gt 0) { $refsRemoved += $r; $touched = $true; Write-Line "[$treeName] removed $r inline translation block(s) from $($langDir.Name)" }
                    }
                }
            }
        }

        # (3) inline references -- only on a full removal (field is leaving force-app too)
        if ($script:FullDelete) {
            $clDir = Join-Path $treeBase "objects\$obj\compactLayouts"
            if (Test-Path $clDir) {
                foreach ($cl in @(Get-ChildItem -Path $clDir -File -Filter '*.compactLayout-meta.xml' -ErrorAction SilentlyContinue)) {
                    $r = Remove-SingleLineElement $cl.FullName $field
                    if ($r -gt 0) { $refsRemoved += $r; $touched = $true; Write-Line "[$treeName] removed $r compactLayout ref(s) from $($cl.Name)" }
                }
            }
            $fsDir = Join-Path $treeBase "objects\$obj\fieldSets"
            if (Test-Path $fsDir) {
                foreach ($fs in @(Get-ChildItem -Path $fsDir -File -Filter '*.fieldSet-meta.xml' -ErrorAction SilentlyContinue)) {
                    $r = (Remove-XmlBlocks $fs.FullName 'displayedFields' $field) +
                         (Remove-XmlBlocks $fs.FullName 'availableFields' $field)
                    if ($r -gt 0) { $refsRemoved += $r; $touched = $true; Write-Line "[$treeName] removed $r fieldSet ref(s) from $($fs.Name)" }
                }
            }
        }

        if ($touched) { $treesTouched.Add($treeName) }
    }

    # (4) FutureDeployment: keep the source in force-app -> .forceignore + tracker
    if ($script:Deferral) {
        $blocker     = if ($Note -ne '') { $Note } else { '(dependency unspecified)' }
        $restoreNote = if ($RestoreAfter -ne '') { $RestoreAfter } else { $blocker }
        $ignorePaths = @(
            "force-app/main/default/objects/$obj/fields/$field.field-meta.xml",
            "**/objectTranslations/$obj-*/$field.fieldTranslation-meta.xml"
        )
        $added = @(Add-ForceIgnorePatterns -patterns $ignorePaths `
            -comment "$script:Today future-deployment exclusion: $obj.$field (CustomField) -- blocked by $blocker. Source kept in force-app; restore after: $restoreNote (remove the line(s) below).")
        $ignoredAdded = $added.Count
        if ($added.Count -gt 0) {
            Write-Line ".forceignore += $($added.Count) pattern(s) (field kept in force-app)"
            foreach ($p in $added) { Write-Note $p }
        } else {
            Write-Note ".forceignore already covers this field (no new pattern)."
        }
        Add-TrackerRow $target 'CustomField' `
            "force-app/main/default/objects/$obj/fields/$field.field-meta.xml" $blocker $restoreNote
    }

    if ($deletedFiles.Count -eq 0 -and $refsRemoved -eq 0 -and $ignoredAdded -eq 0) {
        Write-Note "Nothing to do for $obj.$field (already excluded, or check the Object.Field spelling)."
    }

    # (5) MANUAL-REVIEW reference scan -- force-app
    $review = @(Invoke-RefScan $obj $field)
    if ($review.Count -gt 0) {
        $msg = if ($script:Deferral) {
            "$($review.Count) force-app reference(s) to the now-ignored $obj.$field -- may fail to deploy until restored:"
        } else {
            "$($review.Count) remaining reference(s) to $obj.$field -- review before deploying:"
        }
        Write-Flag $msg
        foreach ($h in ($review | Select-Object -First 40)) { Write-Host "    $h" -ForegroundColor Yellow }
        if ($review.Count -gt 40) { Write-Host "    ... and $($review.Count - 40) more" -ForegroundColor Yellow }
    }

    $primaryPath = "force-app/main/default/objects/$obj/fields/$field.field-meta.xml"
    $treesCell = if ($script:Deferral) { 'test (kept+ignored in force-app)' } else { (($treesTouched | Select-Object -Unique) -join '+') }
    $noteCell  = $Note
    $logRows.Add(("| {0} | {1}.{2} | CustomField | {3} | {4} | {5} | {6} | {7} | {8} |" -f `
        $script:NowUtc, $obj, $field, $Reason, $noteCell, $treesCell,
        $deletedFiles.Count, $refsRemoved, $review.Count))
}

# ============================================================
# LOG
# ============================================================
if (-not $DryRun -and $logRows.Count -gt 0) {
    $docsSync = Split-Path $script:LogPath -Parent
    if (-not (Test-Path $docsSync)) { New-Item -ItemType Directory -Path $docsSync -Force | Out-Null }
    if (-not (Test-Path $script:LogPath)) {
        $header = @(
            '# Field Exclusions Log',
            '',
            'Every field removed from source by `scripts/Exclude-Fields.ps1`. Appended automatically.',
            'Deprecated / OnlyLocal delete from test + force-app. FutureDeployment deletes from test',
            'only, keeps the source in force-app, and adds a `.forceignore` entry.',
            '',
            '| Date (UTC) | Object.Field | Type | Reason | Note | Trees | Files removed | Inline refs removed | Manual-review refs |',
            '|---|---|---|---|---|---|---|---|---|'
        ) -join "`n"
        $enc = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($script:LogPath, $header + "`n", $enc)
    }
    $existing = [System.IO.File]::ReadAllText($script:LogPath)
    if (-not $existing.EndsWith("`n")) { $existing += "`n" }
    $existing += (($logRows -join "`n") + "`n")
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($script:LogPath, $existing, $enc)
    Write-Head 'Logged'
    Write-Line "Appended $($logRows.Count) row(s) to docs/sync/field-exclusions-log.md"
}

Write-Host "`nDone." -ForegroundColor Green
if ($DryRun) { Write-Host "(dry run -- no files changed, no log written)" -ForegroundColor DarkGray }

# Explicit success: a non-zero $LASTEXITCODE from `git grep` (1 == no matches) must
# not bleed into this script's exit code. Real errors throw (EAP=Stop) above.
exit 0

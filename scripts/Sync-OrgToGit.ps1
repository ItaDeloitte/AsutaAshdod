#Requires -Version 5.1
<#
.SYNOPSIS
    Org-to-Git Object Metadata Sync + Production Manifest (SPEC-001).

.DESCRIPTION
    Synchronises the 49 in-scope objects from the astDev sandbox into force-app,
    then generates manifest/package-objects-prod.xml for production deployment.

    ADR-001 deprecated exclusion: components whose label or API name contains
    _deprecated (case-insensitive) are detected, stripped from staging, and never
    copied into force-app or included in the production manifest.

    Phase Retrieve (Steps 0-4):
        Retrieves metadata, strips excluded folders, detects and strips _deprecated
        components (Steps 2b/2c), compares staging vs force-app, writes deletion log,
        deprecated-excluded log, and sync report. Ends at the HUMAN GATE.

    Phase Sync (Steps 6-8):
        Reads the deletion log, applies deletions and copies, generates the
        production manifest (with _deprecated guard), and validates it locally
        including a payload guard (Step 8b). No org deploy occurs.

.PARAMETER Phase
    'Retrieve'  -- Run Steps 0-4. Safe/read-only for force-app.
    'Sync'      -- Run Steps 6-8. Modifies force-app. Requires Phase Retrieve to
                 have completed first (staging must exist).

.EXAMPLE
    .\scripts\Sync-OrgToGit.ps1 -Phase Retrieve
    # Review docs/sync/ output, then:
    .\scripts\Sync-OrgToGit.ps1 -Phase Sync
#>
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Retrieve', 'Sync')]
    [string]$Phase
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# C3 FIX: Suppress SF CLI auto-update stderr noise that causes PS 5.1 to throw
# when EAP=Stop and stderr is redirected. Belt-and-suspenders: set both env vars.
$env:SF_AUTOUPDATE_DISABLE  = 'true'
$env:SF_DISABLE_AUTOUPDATE  = 'true'

# ============================================================
# CONSTANTS
# ============================================================
$script:ProjectRoot  = Split-Path $PSScriptRoot -Parent
$script:TargetOrg    = 'astDev'
$script:ApiVersion   = '64.0'
$script:SyncDir       = Join-Path $script:ProjectRoot '.sync'
# A3: sfdx-project.json defines "test" as the default package dir.
# sf project retrieve start (without --output-dir) deposits files at test\main\default\...
$script:StageRoot     = Join-Path $script:ProjectRoot 'test'
$script:StagingBase   = Join-Path $script:StageRoot 'main\default'
$script:ForceAppBase = Join-Path $script:ProjectRoot 'force-app\main\default'
$script:DocsSync     = Join-Path $script:ProjectRoot 'docs\sync'
$script:Today        = (Get-Date).ToString('yyyyMMdd')
$script:RunTimestamp = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
$script:OrgUsername  = ''
$script:GitHash      = ''

# C4 FIX: Single global ignore set, loaded once, fail-closed.
$script:GlobalIgnoreSet = $null

# H7 FIX: Folders stripped from staging (Step 2), excluded from copy/manifest (Step 6a/7),
# and actively purged from force-app during Phase Sync (Step 6c) so they never ship to prod.
$script:ExcludedChildFolders = @('listViews', 'businessProcesses', 'sharingReasons')

$script:AllObjects = @(
    # Custom objects
    'Language_new__c', 'Country__c', 'City__c', 'settlement__c', 'VDN__c',
    'Service_Line__c', 'SmsTemplate__c', 'Guidelines__c', 'Sequence__c',
    'Scheduler_parameters__c', 'Assuta_Employee__c', 'FTDocGen__c',
    'RecommendationsTypeAfterExam__c', 'Payer_Factor__c', 'Arrangements__c',
    'Domain__c', 'Medical_Procedure__c', 'SMSReminder__c', 'Related_document__c',
    'Guidance_Scenario__c', 'Sub_Expertise__c', 'Expertise__c', 'Calendar__c',
    'Calendar1__c', 'Calendar_Ashdod__c', 'calendar_medp__c', 'SpinCal__c',
    'File__c', 'Survey_Assuta__c', 'Disabilities__c', 'Appointment__c',
    'Agreement__c', 'SMS__c', 'WhatsApp__c', 'Reminder__c',
    'cases_and_appoitments__c', 'Recommendations_after_exam__c',
    'Event_Inquiry__c', 'SurveyTaker__c', 'Agent_survey__c',
    # Platform events
    'RisStatus__e', 'Pop_Record__e',
    # Standard objects
    'Account', 'Contact', 'Case', 'ContentVersion', 'MessagingSession', 'EmailMessage',
    # Additional objects
    'Site__c', 'Doctor_arrangement__c', 'Clinic__c', 'Department__c',
    'Doctor_in_Clinic__c', 'Referral_from_doctor_website__c', 'Implants_mp_apt__c',
    'Implants_to_med_prod__c', 'Case_Recommended_Doctor__c', 'ConsentFormTaken__c',
    'SMS_Parent_Session__c', 'waiting_list__c', 'SurveyQuestionResponse__c', 'Survey__c',
    # Added 2026-10-19
    'ConsentFormToSite__c', 'ConsentForm__c', 'Nursery__c', 'Survey_Question__c'
)

$script:PlatformEvents = @('RisStatus__e', 'Pop_Record__e')

# Fast membership lookup
$script:ObjectSet = @{}
foreach ($o in $script:AllObjects) { $script:ObjectSet[$o] = $true }

# Subfolder -> MDAPI child type (within objects/<Obj>/)
# Note: businessProcesses and sharingReasons are intentionally absent (H7).
$script:FolderTypeMap = [ordered]@{
    'fields'          = 'CustomField'
    'validationRules' = 'ValidationRule'
    'recordTypes'     = 'RecordType'
    'compactLayouts'  = 'CompactLayout'
    'fieldSets'       = 'FieldSet'
    'webLinks'        = 'WebLink'
    'indexes'         = 'Index'
}

# ============================================================
# DEPRECATED EXCLUSION  (ADR-001 / SPEC-001 Amendment A1)
# ============================================================
. (Join-Path $PSScriptRoot 'lib\SyncDeprecated.ps1')

$script:DeprecatedMarker  = Join-Path $script:SyncDir 'deprecated-stripped.marker'
$script:DeprecatedEntries = [System.Collections.Generic.List[hashtable]]::new()   # components + dependents
$script:SuspectEntries    = [System.Collections.Generic.List[hashtable]]::new()
$script:DeprecatedByPath  = @{}      # RelativePath -> entry  (Removal='File' only)
$script:SyncLogDate       = ''       # date token from the deletion log in use (Phase Sync)

# File suffixes for component name extraction (longest first for correct matching)
$script:KnownSuffixes = @(
    '.objectTranslation-meta.xml',
    '.validationRule-meta.xml',
    '.compactLayout-meta.xml',
    '.quickAction-meta.xml',
    '.recordType-meta.xml',
    '.fieldSet-meta.xml',
    '.object-meta.xml',
    '.field-meta.xml',
    '.webLink-meta.xml',
    '.index-meta.xml'
)

# ============================================================
# HELPER FUNCTIONS
# ============================================================

function Write-Step([int]$num, [string]$msg) {
    Write-Host ("`n" + '=' * 60) -ForegroundColor DarkGray
    Write-Host "[Step $num] $msg" -ForegroundColor Cyan
    Write-Host ('=' * 60) -ForegroundColor DarkGray
}

function Write-Info([string]$msg) {
    Write-Host "  $msg"
}

function Write-Warn([string]$msg) {
    Write-Host "  WARNING: $msg" -ForegroundColor Yellow
}

function Write-Fatal([string]$msg) {
    Write-Host "`nFATAL: $msg" -ForegroundColor Red
    exit 1
}

function Get-RelPath([string]$absPath) {
    $trimmed = $absPath.Substring($script:ProjectRoot.Length).TrimStart('\').TrimStart('/')
    return $trimmed.Replace('\', '/')
}

function Get-ApiName([string]$filename) {
    foreach ($sfx in $script:KnownSuffixes) {
        if ($filename.EndsWith($sfx, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $filename.Substring(0, $filename.Length - $sfx.Length)
        }
    }
    return $filename
}

function Get-NormalizedContent([string]$filePath) {
    $raw = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)
    $raw = $raw -replace "`r`n", "`n" -replace "`r", "`n"
    $lines = $raw -split "`n"
    $lines = $lines | ForEach-Object { $_.TrimEnd() }
    return ($lines -join "`n").TrimEnd()
}

function Write-Utf8Lf([string]$filePath, [string]$content) {
    $encoding = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($filePath, $content.Replace("`r`n", "`n"), $encoding)
}

function Invoke-NativeCommand {
    <#
    .SYNOPSIS
        C3 FIX: Calls a native executable with EAP temporarily set to Continue.
        In PS 5.1 with EAP=Stop, stderr from native commands wrapped in 2>&1 or
        2>$null throws a terminating NativeCommandError. This wrapper avoids that
        by lowering EAP for the duration of the native call only.
        Caller MUST check $LASTEXITCODE after each call.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Executable,
        [string[]]$ArgList = @()
    )
    $savedEap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = & $Executable @ArgList
        return $output
    } finally {
        $ErrorActionPreference = $savedEap
    }
}

function Initialize-IgnoreSet {
    <#
    .SYNOPSIS
        C4 FIX: Loads all .forceignore matches in a single CLI call.
        Fails closed: on any error, aborts the script rather than returning an
        empty set that would unprotect ignored files from deletion.
    #>
    Push-Location $script:ProjectRoot
    try {
        Write-Info "Loading .forceignore data via 'sf project list ignored'..."
        $jsonLines = Invoke-NativeCommand 'sf' @('project', 'list', 'ignored',
            '--source-dir', 'force-app/main/default', '--json')
        if ($LASTEXITCODE -ne 0) {
            Write-Fatal ("'sf project list ignored' failed (exit $LASTEXITCODE). " +
                "Cannot determine .forceignore protections. Aborting to protect ignored files.")
        }
        $rawJson = ($jsonLines -join '')
        $parsed  = $null
        try {
            $parsed = $rawJson | ConvertFrom-Json
        } catch {
            Write-Fatal "Could not parse 'sf project list ignored' JSON: $_. Aborting."
        }

        $ignoreSet = [System.Collections.Generic.HashSet[string]]::new(
            [System.StringComparer]::OrdinalIgnoreCase)
        $items = @()
        if ($null -ne $parsed -and $null -ne $parsed.result) {
            if ($parsed.result.PSObject.Properties['ignoredFiles']) {
                $items = @($parsed.result.ignoredFiles)
            } elseif ($parsed.result -is [array] -or $parsed.result -is [System.Object[]]) {
                $items = @($parsed.result)
            }
        }
        foreach ($item in $items) {
            $normalized = ("$item").Replace('\', '/')
            $null = $ignoreSet.Add($normalized)
        }
        $script:GlobalIgnoreSet = $ignoreSet
        Write-Info "Loaded $($ignoreSet.Count) ignored file path(s) from .forceignore."
    } finally {
        Pop-Location
    }
}

function Test-FileIsIgnored([string]$relPath) {
    <#
    .SYNOPSIS
        C4 FIX: Uses $script:GlobalIgnoreSet (initialized once, fail-closed).
        If the set is $null (not initialized), treats file as ignored (keep it)  -- safe default.
    #>
    if ($null -eq $script:GlobalIgnoreSet) {
        Write-Warn "GlobalIgnoreSet is null  -- treating '$relPath' as ignored (safe: keep it)."
        return $true
    }
    $fwd = $relPath.Replace('\', '/')
    if ($script:GlobalIgnoreSet.Contains($fwd)) { return $true }
    foreach ($item in $script:GlobalIgnoreSet) {
        if ($item.EndsWith("/$fwd", [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }
    return $false
}

function Get-AllFilesExcludingFolders([string]$rootDir) {
    <#
    .SYNOPSIS
        H7 FIX: Excludes listViews, businessProcesses, and sharingReasons from
        file enumeration. Formerly Get-AllFilesExcludingListViews.
    #>
    if (-not (Test-Path $rootDir)) { return @() }
    @(Get-ChildItem -Path $rootDir -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object {
            $relativeParts = $_.FullName.Substring($rootDir.Length).Replace('/', '\').Split('\')
            $excluded = $false
            foreach ($excFolder in $script:ExcludedChildFolders) {
                if ($relativeParts -contains $excFolder) { $excluded = $true; break }
            }
            -not $excluded
        })
}

function Build-RuntimeManifestXml {
    <#
    .SYNOPSIS
        C2 FIX: Builds a package.xml string from a hashtable of mdType -> string[].
    #>
    param(
        [hashtable]$TypeMembers,
        [string]$Comment = ''
    )
    $sb = [System.Text.StringBuilder]::new()
    $null = $sb.AppendLine('<?xml version="1.0" encoding="UTF-8"?>')
    if ($Comment) {
        $null = $sb.AppendLine("<!-- $Comment -->")
    }
    $null = $sb.AppendLine('<Package xmlns="http://soap.sforce.com/2006/04/metadata">')
    foreach ($mdType in ($TypeMembers.Keys | Sort-Object)) {
        $memberList = @($TypeMembers[$mdType])
        if ($memberList.Count -eq 0) { continue }
        $null = $sb.AppendLine('    <types>')
        foreach ($m in ($memberList | Sort-Object)) {
            $null = $sb.AppendLine("        <members>$m</members>")
        }
        $null = $sb.AppendLine("        <name>$mdType</name>")
        $null = $sb.AppendLine('    </types>')
    }
    $null = $sb.AppendLine("    <version>$script:ApiVersion</version>")
    $null = $sb.AppendLine('</Package>')
    return $sb.ToString()
}

function Invoke-OrgListMetadata([string]$MetadataType) {
    <#
    .SYNOPSIS
        C2 FIX: Runtime query of org metadata members via sf org list metadata.
        Returns array of fullName strings. Fails-closed on error.
    #>
    Push-Location $script:ProjectRoot
    try {
        Write-Info "Querying org for $MetadataType metadata members..."
        $jsonLines = Invoke-NativeCommand 'sf' @('org', 'list', 'metadata',
            '--metadata-type', $MetadataType,
            '--target-org', $script:TargetOrg,
            '--json')
        if ($LASTEXITCODE -ne 0) {
            Write-Fatal ("'sf org list metadata --metadata-type $MetadataType' failed " +
                "(exit $LASTEXITCODE). Aborting.")
        }
        $rawJson = ($jsonLines -join '')
        $parsed  = $null
        try {
            $parsed = $rawJson | ConvertFrom-Json
        } catch {
            Write-Fatal "Could not parse 'sf org list metadata' JSON for $($MetadataType): $_"
        }
        $members = @()
        if ($null -ne $parsed -and $null -ne $parsed.result) {
            $items = if ($parsed.result -is [array] -or $parsed.result -is [System.Object[]]) {
                @($parsed.result)
            } else {
                @($parsed.result)
            }
            $members = @($items | Where-Object { $null -ne $_ -and $_.PSObject.Properties['fullName'] } |
                ForEach-Object { $_.fullName })
        }
        return $members
    } finally {
        Pop-Location
    }
}

function Invoke-ValidateRetrieveResult([string]$jsonPath, [string]$passLabel) {
    <#
    .SYNOPSIS
        H5 FIX: Full validation of retrieve result JSON.
        Checks: file exists, JSON parses, status==0, success!=false,
        no problem messages, no Failed file entries.
    #>
    if (-not (Test-Path $jsonPath)) {
        Write-Fatal "$passLabel result file not found: $jsonPath"
    }
    $rawJson = $null
    try {
        $rawJson = Get-Content $jsonPath -Raw -Encoding UTF8
    } catch {
        Write-Fatal "$($passLabel): Could not read result file '$jsonPath': $_"
    }
    $parsed = $null
    try {
        $parsed = $rawJson | ConvertFrom-Json
    } catch {
        Write-Fatal "$($passLabel): Failed to parse retrieve result JSON: $_"
    }
    if ([int]$parsed.status -ne 0) {
        Write-Fatal "$passLabel returned status $($parsed.status). See $jsonPath."
    }
    if ($null -ne $parsed.result -and
        $parsed.result.PSObject.Properties['success'] -and
        $parsed.result.success -eq $false) {
        Write-Fatal "$passLabel reported success=false. See $jsonPath."
    }
    # Check problem messages
    $problems = @()
    if ($null -ne $parsed.result -and $parsed.result.PSObject.Properties['messages']) {
        $problems = @($parsed.result.messages | Where-Object {
            $_.PSObject.Properties['problem'] -and
            $null -ne $_.problem -and
            "$($_.problem)" -ne ''
        })
    }
    if ($problems.Count -gt 0) {
        foreach ($prob in $problems) {
            Write-Warn "Problem: $($prob.problem)"
        }
        Write-Fatal "$passLabel completed with $($problems.Count) problem(s). Aborting."
    }
    # Check for failed file entries
    if ($null -ne $parsed.result -and $parsed.result.PSObject.Properties['files']) {
        $failedFiles = @($parsed.result.files | Where-Object {
            $_.PSObject.Properties['state'] -and $_.state -eq 'Failed'
        })
        if ($failedFiles.Count -gt 0) {
            Write-Fatal "$passLabel had $($failedFiles.Count) failed component(s). See $jsonPath."
        }
    }
    Write-Info "$passLabel validation passed."
}

# ============================================================
# PHASE: RETRIEVE  -- Steps 0 through 4
# ============================================================

function Invoke-Preflight {
    Write-Step 0 'Pre-flight checks'

    # C4: Initialize ignore set first  -- fail-closed if CLI not available
    Initialize-IgnoreSet

    Push-Location $script:ProjectRoot
    try {
        # C3 FIX: No 2>&1  -- use Invoke-NativeCommand; check $LASTEXITCODE
        Write-Info "Checking org authentication for '$script:TargetOrg'..."
        $orgLines = Invoke-NativeCommand 'sf' @('org', 'display',
            '--target-org', $script:TargetOrg, '--json')
        if ($LASTEXITCODE -ne 0) {
            Write-Fatal ("Org '$script:TargetOrg' not authenticated. " +
                "Run: sf org login web --alias $script:TargetOrg")
        }
        $orgJson = ($orgLines -join '') | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($null -ne $orgJson -and $null -ne $orgJson.result) {
            $script:OrgUsername = $orgJson.result.username
        }
        Write-Info "Org username: $script:OrgUsername"

        # C3 FIX: No 2>$null on git
        $gitLogLines = Invoke-NativeCommand 'git' @('log', '--oneline', '-1', '--format=%h')
        $script:GitHash = if ($gitLogLines) { ($gitLogLines | Select-Object -First 1).Trim() } else { 'unknown' }
        Write-Info "Git base commit: $script:GitHash"

        # L1 FIX: wrap in @() so .Count is always valid on PS 5.1
        # Retrieve phase: warn only (H4 hard-abort is in Phase Sync)
        $dirtyLines = @(Invoke-NativeCommand 'git' @('status', '--porcelain') |
            Where-Object { $_.Trim() -ne '' })
        if ($dirtyLines.Count -gt 0) {
            Write-Warn "Working tree has $($dirtyLines.Count) uncommitted change(s). See spec risk R3."
            Write-Warn "Consider committing or stashing before the sync (spec recommends a clean tree)."
        } else {
            Write-Info "Working tree is clean."
        }
    } finally {
        Pop-Location
    }

    foreach ($dir in @($script:StageRoot, $script:DocsSync)) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Info "Created directory: $(Get-RelPath $dir)"
        }
    }

    Write-Info 'Pre-flight OK.'
}

function Invoke-Retrieve {
    Write-Step 1 'Retrieve metadata from org'

    # H1 FIX: Clear staging before retrieve to avoid stale files from prior runs.
    # L5 FIX: Safety guard  -- StageRoot must be the test staging directory.
    $expectedStageRoot = Join-Path $script:ProjectRoot 'test'
    if ($script:StageRoot -ne $expectedStageRoot) {
        Write-Fatal "SAFETY: StageRoot '$script:StageRoot' is not the expected test staging directory. Aborting."
    }
    # ADR-001: Remove stale deprecated-stripped marker before fresh retrieve
    if (Test-Path $script:DeprecatedMarker) { Remove-Item $script:DeprecatedMarker -Force }

    if (Test-Path $script:StageRoot) {
        $existingCount = @(Get-ChildItem -Path $script:StageRoot -ErrorAction SilentlyContinue).Count
        if ($existingCount -gt 0) {
            Remove-Item -Path "$($script:StageRoot)\*" -Recurse -Force
            Write-Info "Cleared staging directory (test/)  -- $existingCount item(s) removed."
        }
    } else {
        New-Item -ItemType Directory -Path $script:StageRoot -Force | Out-Null
    }

    Push-Location $script:ProjectRoot
    try {
        # C2 FIX: Pre-query org for QuickAction and CustomObjectTranslation members.
        # This gives us explicit member lists for runtime manifests, avoiding the
        # wildcard forms (Obj.*, Obj-*) that the Metadata API rejects.

        $allQaMembers = @(Invoke-OrgListMetadata 'QuickAction')
        $qaMembers = @($allQaMembers | Where-Object {
            $dotIdx = $_.IndexOf('.')
            $dotIdx -gt 0 -and $script:ObjectSet.ContainsKey($_.Substring(0, $dotIdx))
        })
        Write-Info "Found $($qaMembers.Count) object-specific QuickAction member(s)."

        $allTransMembers = @(Invoke-OrgListMetadata 'CustomObjectTranslation')
        $transMembers = @($allTransMembers | Where-Object {
            $dashIdx = $_.IndexOf('-')
            $dashIdx -gt 0 -and $script:ObjectSet.ContainsKey($_.Substring(0, $dashIdx))
        })
        Write-Info "Found $($transMembers.Count) CustomObjectTranslation member(s) for the 49 objects."

        # --- Pass 1: CustomObject + CustomObjectTranslation in a single retrieve (H6 FIX) ---
        # Merging translations into Pass 1 ensures field translations are complete
        # (the API returns child translations alongside the object in the same pass).
        $pass1Members = @{ 'CustomObject' = [string[]]$script:AllObjects }
        if ($transMembers.Count -gt 0) {
            $pass1Members['CustomObjectTranslation'] = [string[]]$transMembers
        }
        $pass1Xml  = Build-RuntimeManifestXml -TypeMembers $pass1Members `
            -Comment 'Runtime  -- Pass 1: CustomObject + CustomObjectTranslation'
        $pass1Path = Join-Path $script:SyncDir 'retrieve-pass1-runtime.xml'
        Write-Utf8Lf -filePath $pass1Path -content $pass1Xml

        Write-Info ("Running Pass 1  -- CustomObject ($($script:AllObjects.Count) objects) + " +
            "CustomObjectTranslation ($($transMembers.Count) translations)...")
        $p1ResultAbs = Join-Path $script:ProjectRoot '.sync\retrieve-result-objects.json'

        $p1Lines = Invoke-NativeCommand 'sf' @('project', 'retrieve', 'start',
            '--manifest', '.sync\retrieve-pass1-runtime.xml',
            '--target-org', $script:TargetOrg,
            '--api-version', $script:ApiVersion,
            '--json')
        $p1Raw = $p1Lines -join ''
        Write-Utf8Lf -filePath $p1ResultAbs -content $p1Raw
        if ($LASTEXITCODE -ne 0) {
            Write-Fatal "Pass 1 exited with code $LASTEXITCODE. See .sync/retrieve-result-objects.json."
        }
        Invoke-ValidateRetrieveResult -jsonPath $p1ResultAbs -passLabel 'Pass 1'
        Write-Info 'Pass 1 retrieve complete (source format deposited in test\main\default\).'

        # H2 FIX: Completeness check  -- every object must have at least one file in staging.
        $objStagingDir = Join-Path $script:StagingBase 'objects'
        foreach ($obj in $script:AllObjects) {
            $objDir   = Join-Path $objStagingDir $obj
            $objFiles = @(Get-ChildItem -Path $objDir -Recurse -File -ErrorAction SilentlyContinue)
            if (-not (Test-Path $objDir) -or $objFiles.Count -eq 0) {
                Write-Fatal ("ABORT: Object '$obj' has no files in staging after Pass 1 retrieve. " +
                    "Possible partial retrieve. Verify connectivity and re-run.")
            }
        }
        Write-Info "Pass 1 completeness check passed  -- all $($script:AllObjects.Count) object directories populated."

        # --- Pass 2: QuickAction (runtime manifest, C2 FIX) ---
        if ($qaMembers.Count -gt 0) {
            $pass2Members = @{ 'QuickAction' = [string[]]$qaMembers }
            $pass2Xml  = Build-RuntimeManifestXml -TypeMembers $pass2Members `
                -Comment 'Runtime  -- Pass 2: QuickAction (object-specific only)'
            $pass2Path = Join-Path $script:SyncDir 'retrieve-quickactions-runtime.xml'
            Write-Utf8Lf -filePath $pass2Path -content $pass2Xml

            Write-Info "Running Pass 2  -- QuickAction ($($qaMembers.Count) member(s))..."
            $p2ResultAbs = Join-Path $script:ProjectRoot '.sync\retrieve-result-quickactions.json'

            $p2Lines = Invoke-NativeCommand 'sf' @('project', 'retrieve', 'start',
                '--manifest', '.sync\retrieve-quickactions-runtime.xml',
                '--target-org', $script:TargetOrg,
                '--api-version', $script:ApiVersion,
                '--json')
            $p2Raw = $p2Lines -join ''
            Write-Utf8Lf -filePath $p2ResultAbs -content $p2Raw
            if ($LASTEXITCODE -ne 0) {
                Write-Fatal "Pass 2 exited with code $LASTEXITCODE. See .sync/retrieve-result-quickactions.json."
            }
            Invoke-ValidateRetrieveResult -jsonPath $p2ResultAbs -passLabel 'Pass 2'
            Write-Info 'Pass 2 retrieve complete (source format deposited in test\main\default\).'

            # H2: QuickAction completeness warning (not abort  -- QAs may be legitimately absent)
            $qaStagingDir = Join-Path $script:StagingBase 'quickActions'
            $retrievedQaCount = @(Get-ChildItem -Path $qaStagingDir -File `
                -Filter '*.quickAction-meta.xml' -ErrorAction SilentlyContinue).Count
            if ($retrievedQaCount -eq 0) {
                Write-Warn ("Pass 2: $($qaMembers.Count) QuickAction member(s) in manifest " +
                    "but 0 files retrieved. QuickActions may be legitimately absent in this org.")
            }
        } else {
            Write-Info "Pass 2 skipped  -- no object-specific QuickActions found in org."
        }

    } finally {
        Pop-Location
    }

    Write-Info "All retrieve passes complete."
}

function Remove-ExcludedFolders {
    # H7 FIX: Strips listViews, businessProcesses, and sharingReasons from staging.
    Write-Step 2 "Strip excluded folders from staging ($($script:ExcludedChildFolders -join ', '))"

    # L5 FIX: Safety guard
    $expectedStageRoot = Join-Path $script:ProjectRoot 'test'
    if ($script:StageRoot -ne $expectedStageRoot) {
        Write-Fatal "SAFETY: StageRoot is not the expected test staging directory. Refusing to strip folders."
    }

    $totalRemoved = 0
    foreach ($folderName in $script:ExcludedChildFolders) {
        $dirs = @(Get-ChildItem -Path $script:StageRoot -Recurse -Directory `
            -Filter $folderName -ErrorAction SilentlyContinue)
        foreach ($dir in $dirs) {
            Remove-Item -Path $dir.FullName -Recurse -Force
            Write-Info "Removed: $(Get-RelPath $dir.FullName)"
            $totalRemoved++
        }
    }
    Write-Info "Total excluded folders removed: $totalRemoved."
}

function Write-RetrieveLog {
    $logPath = Join-Path $script:DocsSync "retrieve-log-$($script:Today).txt"
    $sb = [System.Text.StringBuilder]::new()
    $null = $sb.AppendLine('# Retrieval Log -- Org-to-Git Sync')
    $null = $sb.AppendLine("# Source org: $script:TargetOrg ($script:OrgUsername)")
    $null = $sb.AppendLine("# Retrieved at: $script:RunTimestamp")
    $null = $sb.AppendLine("# Git base commit: $script:GitHash")
    $null = $sb.AppendLine('# Passes: CustomObject+CustomObjectTranslation (P1), QuickAction (P2)')
    $null = $sb.AppendLine('#')
    $null = $sb.AppendLine('# Status: OK | SKIPPED | MISSING | DEPRECATED')
    $null = $sb.AppendLine("# Object`tPass`tMetadataType`tComponentName`tStatus`tNotes")

    $hasMissing = $false

    # P1: objects
    $objStagingDir = Join-Path $script:StagingBase 'objects'
    foreach ($obj in $script:AllObjects) {
        $objDir = Join-Path $objStagingDir $obj
        if (-not (Test-Path $objDir)) {
            $null = $sb.AppendLine("$obj`tP1`tCustomObject`t$obj`tMISSING`tDirectory absent in staging")
            $hasMissing = $true
            continue
        }
        $files = @(Get-ChildItem -Path $objDir -Recurse -File -ErrorAction SilentlyContinue)
        if ($files.Count -eq 0) {
            $null = $sb.AppendLine("$obj`tP1`tCustomObject`t$obj`tWARNING`tNo files retrieved")
            continue
        }
        foreach ($f in $files) {
            $parentFolder = Split-Path (Split-Path $f.FullName -Parent) -Leaf
            if ($parentFolder -eq $obj) { $parentFolder = '' }
            $mdType = if ($script:FolderTypeMap.Contains($parentFolder)) {
                $script:FolderTypeMap[$parentFolder]
            } else {
                'CustomObject'
            }
            $compName   = Get-ApiName $f.Name
            $fileRelInObj = $f.FullName.Substring($objDir.Length).TrimStart('\').TrimStart('/').Replace('\', '/')
            $projRelPath  = "force-app/main/default/objects/$obj/$fileRelInObj"
            $isIgnored    = Test-FileIsIgnored $projRelPath
            $status = 'OK'
            $notes  = ''
            if ($isIgnored) {
                $status = 'SKIPPED'; $notes = 'Matched by .forceignore'
            } elseif ($script:DeprecatedByPath.ContainsKey($projRelPath)) {
                $deprE = $script:DeprecatedByPath[$projRelPath]
                $status = 'DEPRECATED'; $notes = "$($deprE.MatchedOn): $($deprE.MatchedValue)"
            }
            $null = $sb.AppendLine("$obj`tP1`t$mdType`t$compName`t$status`t$notes")
        }
    }

    # P2: quickActions
    $qaStagingDir = Join-Path $script:StagingBase 'quickActions'
    if (Test-Path $qaStagingDir) {
        $qaFiles = @(Get-ChildItem -Path $qaStagingDir -File `
            -Filter '*.quickAction-meta.xml' -ErrorAction SilentlyContinue)
        foreach ($f in $qaFiles) {
            $dotIdx = $f.Name.IndexOf('.')
            if ($dotIdx -le 0) { continue }
            $objName = $f.Name.Substring(0, $dotIdx)
            if (-not $script:ObjectSet.ContainsKey($objName)) { continue }
            $compName    = Get-ApiName $f.Name
            $projRelPath = "force-app/main/default/quickActions/$($f.Name)"
            $isIgnored   = Test-FileIsIgnored $projRelPath
            $status = 'OK'
            $notes  = ''
            if ($isIgnored) {
                $status = 'SKIPPED'; $notes = 'Matched by .forceignore'
            } elseif ($script:DeprecatedByPath.ContainsKey($projRelPath)) {
                $deprE = $script:DeprecatedByPath[$projRelPath]
                $status = 'DEPRECATED'; $notes = "$($deprE.MatchedOn): $($deprE.MatchedValue)"
            }
            $null = $sb.AppendLine("$objName`tP2`tQuickAction`t$compName`t$status`t$notes")
        }
    }

    # P1 (translations): objectTranslations
    $transStagingDir = Join-Path $script:StagingBase 'objectTranslations'
    if (Test-Path $transStagingDir) {
        $transFolders = @(Get-ChildItem -Path $transStagingDir -Directory -ErrorAction SilentlyContinue)
        foreach ($folder in $transFolders) {
            $folderName = $folder.Name
            $dashIdx = $folderName.IndexOf('-')
            if ($dashIdx -le 0) { continue }
            $objName = $folderName.Substring(0, $dashIdx)
            if (-not $script:ObjectSet.ContainsKey($objName)) { continue }
            $null = $sb.AppendLine("$objName`tP1`tCustomObjectTranslation`t$folderName`tOK`t")
        }
    }

    Write-Utf8Lf -filePath $logPath -content $sb.ToString()
    Write-Info "Retrieve log: docs/sync/retrieve-log-$($script:Today).txt"

    if ($hasMissing) {
        Write-Fatal 'One or more objects have MISSING status in the retrieve log. Aborting before comparison.'
    }
}

function Invoke-DetectDeprecated {
    # ADR-001 Step 2b: Detect _deprecated components in staging
    Write-Step 2 '(2b) Detect _deprecated components in staging'
    $r = $null
    try {
        $r = Find-DeprecatedInStaging -StagingBase $script:StagingBase `
            -Objects $script:AllObjects -FolderTypeMap $script:FolderTypeMap
    } catch {
        Write-Fatal $_.Exception.Message
    }
    foreach ($e in $r.Deprecated) {
        $script:DeprecatedEntries.Add($e)
        if ($e.Removal -eq 'File') { $script:DeprecatedByPath[$e.RelativePath] = $e }
    }
    foreach ($e in $r.Suspect) { $script:SuspectEntries.Add($e) }
    Write-Info "Deprecated components: $($r.Deprecated.Count)   Suspect markers: $($r.Suspect.Count)"
}

function Invoke-StripDeprecated {
    # ADR-001 Step 2c: Strip _deprecated components from staging
    Write-Step 2 '(2c) Strip _deprecated components from staging'
    $deps = $null
    try {
        $inputList = [System.Collections.Generic.List[hashtable]]::new()
        foreach ($e in $script:DeprecatedEntries) { $inputList.Add($e) }
        $deps = @(Remove-DeprecatedFromStaging -StagingBase $script:StagingBase -Deprecated $inputList)
    } catch {
        Write-Fatal $_.Exception.Message
    }
    foreach ($d in $deps) {
        $script:DeprecatedEntries.Add($d)
        if ($d.Removal -eq 'File') { $script:DeprecatedByPath[$d.RelativePath] = $d }
    }
    $depsCount = if ($null -ne $deps) { $deps.Count } else { 0 }

    # Remove whole-deprecated objects from the runtime scope so comparison and manifest skip them.
    $removedObjSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($e in $script:DeprecatedEntries) {
        if ($e.Removal -eq 'Object') { $null = $removedObjSet.Add($e.Object) }
    }
    if ($removedObjSet.Count -gt 0) {
        $script:AllObjects = @($script:AllObjects | Where-Object { -not $removedObjSet.Contains($_) })
        foreach ($o in $removedObjSet) { $script:ObjectSet.Remove($o) }
        Write-Info "Removed $($removedObjSet.Count) deprecated object(s) from active scope: $($removedObjSet -join ', ')"
    }

    Write-Utf8Lf -filePath $script:DeprecatedMarker `
        -content ("stripped_at=$script:RunTimestamp`nrun_date=$script:Today`ncomponents=$($script:DeprecatedEntries.Count)`ndependents=$depsCount`n")
    Write-Info "Stripped. Dependent translation entries removed: $depsCount"
    Write-Info "Marker written: .sync/deprecated-stripped.marker"
}

function Invoke-PayloadGuard {
    # ADR-001 Step 8b: Payload guard -- no _deprecated in .sync/mdapi-check
    Write-Step 8 '(8b) Payload guard -- no _deprecated in .sync/mdapi-check'
    $deprLog = Join-Path $script:DocsSync "deprecated-excluded-$($script:SyncLogDate).txt"
    if (-not (Test-Path $deprLog)) {
        Write-Fatal "Deprecated log $deprLog not found (must match deletion log date). Re-run -Phase Retrieve."
    }
    $names = $null
    $viol  = $null
    try {
        $names = Read-DeprecatedLog $deprLog
        $viol  = @(Test-MdapiPayloadForDeprecated `
            -MdapiDir (Join-Path $script:SyncDir 'mdapi-check') -DeprecatedNames $names)
    } catch {
        Write-Fatal $_.Exception.Message
    }
    if ($viol.Count -gt 0) {
        foreach ($v in $viol) { Write-Host "  PAYLOAD VIOLATION: $v" -ForegroundColor Red }
        Write-Fatal "Converted payload contains _deprecated components. (ADR-001 L4)"
    }
    Write-Info 'Payload guard PASSED -- no _deprecated components in converted payload.'
}

function Invoke-Compare {
    Write-Step 3 'Compare staging vs force-app'

    $results = @{
        OnlyLocal           = [System.Collections.Generic.List[hashtable]]::new()
        OnlyLocalIgnored    = [System.Collections.Generic.List[hashtable]]::new()
        OnlyOrg             = [System.Collections.Generic.List[hashtable]]::new()
        Modified            = [System.Collections.Generic.List[hashtable]]::new()
        Identical           = [System.Collections.Generic.List[hashtable]]::new()
        FormulaPending      = [System.Collections.Generic.List[hashtable]]::new()
        OnlyOrgDeprecated   = [System.Collections.Generic.List[hashtable]]::new()
        DeprecatedDelete    = [System.Collections.Generic.List[hashtable]]::new()
        DeprecatedRefs      = [System.Collections.Generic.List[hashtable]]::new()
        Suspect             = [System.Collections.Generic.List[hashtable]]::new()
    }

    # ----- Objects -----
    $objStagingDir = Join-Path $script:StagingBase 'objects'
    $objLocalDir   = Join-Path $script:ForceAppBase 'objects'

    foreach ($obj in $script:AllObjects) {
        $stagingObjDir = Join-Path $objStagingDir $obj
        $localObjDir   = Join-Path $objLocalDir $obj

        # H7 FIX: Exclude listViews, businessProcesses, sharingReasons from both sides
        $stagingFiles = @{}
        foreach ($f in @(Get-AllFilesExcludingFolders $stagingObjDir)) {
            $rel = $f.FullName.Substring($stagingObjDir.Length).TrimStart('\').TrimStart('/').Replace('\', '/')
            $stagingFiles[$rel] = $f.FullName
        }

        $localFiles = @{}
        foreach ($f in @(Get-AllFilesExcludingFolders $localObjDir)) {
            $rel = $f.FullName.Substring($localObjDir.Length).TrimStart('\').TrimStart('/').Replace('\', '/')
            $localFiles[$rel] = $f.FullName
        }

        $allRelPaths = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        foreach ($k in $stagingFiles.Keys) { $null = $allRelPaths.Add($k) }
        foreach ($k in $localFiles.Keys)   { $null = $allRelPaths.Add($k) }

        $ignoreRelDir = "force-app/main/default/objects/$obj"

        foreach ($relPath in $allRelPaths) {
            $parts     = $relPath -split '/'
            $subFolder = if ($parts.Count -gt 1) { $parts[0] } else { '' }
            $fileName  = $parts[-1]
            $mdType    = if ($script:FolderTypeMap.Contains($subFolder)) {
                $script:FolderTypeMap[$subFolder]
            } else {
                'CustomObject'
            }
            $compName    = Get-ApiName $fileName
            $projRelPath = "$ignoreRelDir/$relPath"

            $entry = @{
                Object        = $obj
                MetadataType  = $mdType
                ComponentName = $compName
                RelativePath  = $projRelPath
                LocalPath     = if ($localFiles.ContainsKey($relPath)) { $localFiles[$relPath] } else { '' }
                StagingPath   = if ($stagingFiles.ContainsKey($relPath)) { $stagingFiles[$relPath] } else { '' }
            }

            $inStaging = $stagingFiles.ContainsKey($relPath)
            $inLocal   = $localFiles.ContainsKey($relPath)

            if ($inStaging -and -not $inLocal) {
                $results.OnlyOrg.Add($entry)
            } elseif ($inLocal -and -not $inStaging) {
                # C4 FIX: Test-FileIsIgnored uses GlobalIgnoreSet (fail-closed)
                if (Test-FileIsIgnored $projRelPath) {
                    $results.OnlyLocalIgnored.Add($entry)
                } elseif ($script:DeprecatedByPath.ContainsKey($projRelPath)) {
                    $results.DeprecatedDelete.Add($entry)
                } else {
                    $results.OnlyLocal.Add($entry)
                }
            } elseif ($inStaging -and $inLocal) {
                $stagingContent = Get-NormalizedContent $entry.StagingPath
                $localContent   = Get-NormalizedContent $entry.LocalPath
                if ($stagingContent -ne $localContent) {
                    $results.Modified.Add($entry)
                } else {
                    $results.Identical.Add($entry)
                }
            }
        }
    }

    # ----- QuickActions -----
    $qaStagingDir = Join-Path $script:StagingBase 'quickActions'
    $qaLocalDir   = Join-Path $script:ForceAppBase 'quickActions'

    $qaStagingFiles = @{}
    if (Test-Path $qaStagingDir) {
        @(Get-ChildItem -Path $qaStagingDir -File -Filter '*.quickAction-meta.xml' -ErrorAction SilentlyContinue) |
            ForEach-Object {
                $dotIdx = $_.Name.IndexOf('.')
                if ($dotIdx -gt 0 -and $script:ObjectSet.ContainsKey($_.Name.Substring(0, $dotIdx))) {
                    $qaStagingFiles[$_.Name] = $_.FullName
                }
            }
    }
    $qaLocalFiles = @{}
    if (Test-Path $qaLocalDir) {
        @(Get-ChildItem -Path $qaLocalDir -File -Filter '*.quickAction-meta.xml' -ErrorAction SilentlyContinue) |
            ForEach-Object {
                $dotIdx = $_.Name.IndexOf('.')
                if ($dotIdx -gt 0 -and $script:ObjectSet.ContainsKey($_.Name.Substring(0, $dotIdx))) {
                    $qaLocalFiles[$_.Name] = $_.FullName
                }
            }
    }

    $allQaNames = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($k in $qaStagingFiles.Keys) { $null = $allQaNames.Add($k) }
    foreach ($k in $qaLocalFiles.Keys)   { $null = $allQaNames.Add($k) }

    foreach ($qaName in $allQaNames) {
        $dotIdx  = $qaName.IndexOf('.')
        $objName = if ($dotIdx -gt 0) { $qaName.Substring(0, $dotIdx) } else { '' }
        $compName    = Get-ApiName $qaName
        $projRelPath = "force-app/main/default/quickActions/$qaName"

        $entry = @{
            Object        = $objName
            MetadataType  = 'QuickAction'
            ComponentName = $compName
            RelativePath  = $projRelPath
            LocalPath     = if ($qaLocalFiles.ContainsKey($qaName)) { $qaLocalFiles[$qaName] } else { '' }
            StagingPath   = if ($qaStagingFiles.ContainsKey($qaName)) { $qaStagingFiles[$qaName] } else { '' }
        }

        $inStaging = $qaStagingFiles.ContainsKey($qaName)
        $inLocal   = $qaLocalFiles.ContainsKey($qaName)

        if ($inStaging -and -not $inLocal) {
            $results.OnlyOrg.Add($entry)
        } elseif ($inLocal -and -not $inStaging) {
            if (Test-FileIsIgnored $projRelPath) {
                $results.OnlyLocalIgnored.Add($entry)
            } elseif ($script:DeprecatedByPath.ContainsKey($projRelPath)) {
                $results.DeprecatedDelete.Add($entry)
            } else {
                $results.OnlyLocal.Add($entry)
            }
        } elseif ($inStaging -and $inLocal) {
            $stagingContent = Get-NormalizedContent $entry.StagingPath
            $localContent   = Get-NormalizedContent $entry.LocalPath
            if ($stagingContent -ne $localContent) {
                $results.Modified.Add($entry)
            } else {
                $results.Identical.Add($entry)
            }
        }
    }

    # ----- ObjectTranslations -----
    $transStagingDir = Join-Path $script:StagingBase 'objectTranslations'
    $transLocalDir   = Join-Path $script:ForceAppBase 'objectTranslations'

    $transStagingFolders = @{}
    if (Test-Path $transStagingDir) {
        @(Get-ChildItem -Path $transStagingDir -Directory -ErrorAction SilentlyContinue) |
            ForEach-Object {
                $dashIdx = $_.Name.IndexOf('-')
                if ($dashIdx -gt 0) {
                    $objName = $_.Name.Substring(0, $dashIdx)
                    if ($script:ObjectSet.ContainsKey($objName)) {
                        $transStagingFolders[$_.Name] = $_.FullName
                    }
                }
            }
    }
    $transLocalFolders = @{}
    if (Test-Path $transLocalDir) {
        @(Get-ChildItem -Path $transLocalDir -Directory -ErrorAction SilentlyContinue) |
            ForEach-Object {
                $dashIdx = $_.Name.IndexOf('-')
                if ($dashIdx -gt 0) {
                    $objName = $_.Name.Substring(0, $dashIdx)
                    if ($script:ObjectSet.ContainsKey($objName)) {
                        $transLocalFolders[$_.Name] = $_.FullName
                    }
                }
            }
    }

    $allTransFolders = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($k in $transStagingFolders.Keys) { $null = $allTransFolders.Add($k) }
    foreach ($k in $transLocalFolders.Keys)   { $null = $allTransFolders.Add($k) }

    foreach ($folderName in $allTransFolders) {
        $dashIdx  = $folderName.IndexOf('-')
        $objName  = if ($dashIdx -gt 0) { $folderName.Substring(0, $dashIdx) } else { $folderName }
        $projRelDir = "force-app/main/default/objectTranslations/$folderName"

        $stagingFolderPath = if ($transStagingFolders.ContainsKey($folderName)) { $transStagingFolders[$folderName] } else { '' }
        $localFolderPath   = if ($transLocalFolders.ContainsKey($folderName)) { $transLocalFolders[$folderName] } else { '' }

        $stgFiles = @{}
        if ($stagingFolderPath -ne '' -and (Test-Path $stagingFolderPath)) {
            @(Get-ChildItem -Path $stagingFolderPath -Recurse -File -ErrorAction SilentlyContinue) |
                ForEach-Object {
                    $rel = $_.FullName.Substring($stagingFolderPath.Length).TrimStart('\').TrimStart('/').Replace('\', '/')
                    $stgFiles[$rel] = $_.FullName
                }
        }
        $locFiles = @{}
        if ($localFolderPath -ne '' -and (Test-Path $localFolderPath)) {
            @(Get-ChildItem -Path $localFolderPath -Recurse -File -ErrorAction SilentlyContinue) |
                ForEach-Object {
                    $rel = $_.FullName.Substring($localFolderPath.Length).TrimStart('\').TrimStart('/').Replace('\', '/')
                    $locFiles[$rel] = $_.FullName
                }
        }

        $allFileRels = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        foreach ($k in $stgFiles.Keys) { $null = $allFileRels.Add($k) }
        foreach ($k in $locFiles.Keys) { $null = $allFileRels.Add($k) }

        foreach ($fileRel in $allFileRels) {
            $fileName    = Split-Path $fileRel -Leaf
            $compName    = Get-ApiName $fileName
            $projRelPath = "$projRelDir/$fileRel"

            $entry = @{
                Object        = $objName
                MetadataType  = 'CustomObjectTranslation'
                ComponentName = $folderName
                RelativePath  = $projRelPath
                LocalPath     = if ($locFiles.ContainsKey($fileRel)) { $locFiles[$fileRel] } else { '' }
                StagingPath   = if ($stgFiles.ContainsKey($fileRel)) { $stgFiles[$fileRel] } else { '' }
            }

            $inStaging = $stgFiles.ContainsKey($fileRel)
            $inLocal   = $locFiles.ContainsKey($fileRel)

            if ($inStaging -and -not $inLocal) {
                $results.OnlyOrg.Add($entry)
            } elseif ($inLocal -and -not $inStaging) {
                if (Test-FileIsIgnored $projRelPath) {
                    $results.OnlyLocalIgnored.Add($entry)
                } elseif ($script:DeprecatedByPath.ContainsKey($projRelPath)) {
                    $results.DeprecatedDelete.Add($entry)
                } else {
                    $results.OnlyLocal.Add($entry)
                }
            } elseif ($inStaging -and $inLocal) {
                $stagingContent = Get-NormalizedContent $entry.StagingPath
                $localContent   = Get-NormalizedContent $entry.LocalPath
                if ($stagingContent -ne $localContent) {
                    $results.Modified.Add($entry)
                } else {
                    $results.Identical.Add($entry)
                }
            }
        }
    }

    # H3 FIX: Scan ALL staged XML files for FORMULA_PENDING  -- not just ONLY_ORG and MODIFIED.
    # The most common case is IDENTICAL (same placeholder in both staging and git), which was
    # previously missed and would produce a false "_None detected_" in the report.
    Write-Info "Scanning all staged XML files for FORMULA_PENDING placeholders..."
    $allStagedXml = @(Get-ChildItem -Path $script:StagingBase -Recurse -Filter '*.xml' -ErrorAction SilentlyContinue)
    $fpSeen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($xmlFile in $allStagedXml) {
        $rawContent = Get-Content $xmlFile.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
        if ($rawContent -match 'FORMULA_PENDING') {
            $relFromBase = $xmlFile.FullName.Substring($script:StagingBase.Length).TrimStart('\').TrimStart('/').Replace('\', '/')
            $projRelPath = "force-app/main/default/$relFromBase"
            if (-not $fpSeen.Contains($projRelPath)) {
                $null = $fpSeen.Add($projRelPath)
                $pathParts = $relFromBase -split '[/\\]'
                $fpObj = if ($pathParts.Count -ge 2 -and $pathParts[0] -eq 'objects') { $pathParts[1] } else { '' }
                $results.FormulaPending.Add(@{
                    Object        = $fpObj
                    MetadataType  = ''
                    ComponentName = (Get-ApiName $xmlFile.Name)
                    RelativePath  = $projRelPath
                    LocalPath     = ''
                    StagingPath   = $xmlFile.FullName
                })
            }
        }
    }

    # ADR-001: Set LocalAction on every DeprecatedEntries item; classify OnlyOrgDeprecated
    foreach ($de in $script:DeprecatedEntries) {
        if ($de.Removal -eq 'Inline') {
            $de['LocalAction'] = 'MODIFY'
        } else {
            $localAbsPath = Join-Path $script:ProjectRoot ($de.RelativePath.Replace('/', '\'))
            if (Test-Path $localAbsPath) {
                if (Test-FileIsIgnored $de.RelativePath) {
                    $de['LocalAction'] = 'KEPT_IGNORED'
                } else {
                    $de['LocalAction'] = 'DELETE'
                }
            } else {
                $de['LocalAction'] = 'NONE'
                $results.OnlyOrgDeprecated.Add($de)
            }
        }
    }

    # ADR-001: Find references to deprecated components in staging (production blockers)
    try {
        $depRefList = [System.Collections.Generic.List[hashtable]]::new()
        foreach ($de in $script:DeprecatedEntries) { $depRefList.Add($de) }
        $refItems = @(Find-DeprecatedReferences -StagingBase $script:StagingBase -Deprecated $depRefList)
        foreach ($ri in $refItems) { $results.DeprecatedRefs.Add($ri) }
    } catch {
        Write-Fatal $_.Exception.Message
    }

    # ADR-001: Carry suspect entries into results
    foreach ($se in $script:SuspectEntries) { $results.Suspect.Add($se) }

    Write-Info "ONLY_ORG:         $($results.OnlyOrg.Count)  (will be added to force-app)"
    Write-Info "MODIFIED:         $($results.Modified.Count)  (will be overwritten with org version)"
    Write-Info "ONLY_LOCAL:       $($results.OnlyLocal.Count)  (will be deleted from force-app)"
    Write-Info "ONLY_LOCAL_IGN:   $($results.OnlyLocalIgnored.Count)  (protected by .forceignore, kept)"
    Write-Info "IDENTICAL:        $($results.Identical.Count)  (no action)"
    Write-Info "FORMULA_PENDING:  $($results.FormulaPending.Count)  (production blockers  -- all staged files scanned)"
    Write-Info "ONLY_ORG_DEPR:    $($results.OnlyOrgDeprecated.Count)  (deprecated in org, no local copy)"
    Write-Info "DEPR_DELETE:      $($results.DeprecatedDelete.Count)  (deprecated + local copy exists  -- will be deleted)"
    Write-Info "DEPR_REFS:        $($results.DeprecatedRefs.Count)  (production blockers  -- references to deprecated)"
    Write-Info "SUSPECT:          $($results.Suspect.Count)  (suspect markers  -- review)"

    return $results
}

function Write-Reports([hashtable]$results) {
    Write-Step 4 'Write deletion log and sync report'

    $deletionLogPath = Join-Path $script:DocsSync "deleted-files-$($script:Today).txt"
    $reportPath      = Join-Path $script:DocsSync "sync-report-$($script:Today).md"

    # ----- Deletion Log (ADR-001: adds DeprecatedDelete rows + Reason column) -----
    $onlyLocal   = @($results.OnlyLocal | Sort-Object { "$($_.Object)|$($_.MetadataType)|$($_.ComponentName)" })
    $deprDelete  = @($results.DeprecatedDelete | Sort-Object { "$($_.Object)|$($_.MetadataType)|$($_.ComponentName)" })
    $ignoredCount = $results.OnlyLocalIgnored.Count
    $totalDelete  = $onlyLocal.Count + $deprDelete.Count

    $delSb = [System.Text.StringBuilder]::new()
    $null = $delSb.AppendLine('# Org-to-Git Sync -- Deletion List')
    $null = $delSb.AppendLine("# Source org: $script:TargetOrg ($script:OrgUsername)")
    $null = $delSb.AppendLine("# Retrieved at: $script:RunTimestamp")
    $null = $delSb.AppendLine("# Git base commit: $script:GitHash")
    $null = $delSb.AppendLine("# Total files to delete: $totalDelete")
    $null = $delSb.AppendLine("# Protected by .forceignore (not deleted): $ignoredCount -- see sync-report")
    $null = $delSb.AppendLine("# Of which deprecated in org: $($deprDelete.Count) -- see deprecated-excluded-$($script:Today).txt")
    $null = $delSb.AppendLine('#')
    $null = $delSb.AppendLine("# Object`tMetadataType`tComponentName`tRelativePath`tReason")

    $allDeleteRows = @(
        @(
            @($onlyLocal  | ForEach-Object { [pscustomobject]@{ E=$_; Reason='ONLY_LOCAL' } }) +
            @($deprDelete | ForEach-Object { [pscustomobject]@{ E=$_; Reason='DEPRECATED_IN_ORG' } })
        ) | Sort-Object { "$($_.E.Object)|$($_.E.MetadataType)|$($_.E.ComponentName)" }
    )

    if ($allDeleteRows.Count -eq 0) {
        $null = $delSb.AppendLine('# No files to delete')
    } else {
        foreach ($row in $allDeleteRows) {
            $e = $row.E
            $null = $delSb.AppendLine("$($e.Object)`t$($e.MetadataType)`t$($e.ComponentName)`t$($e.RelativePath)`t$($row.Reason)")
        }
    }

    Write-Utf8Lf -filePath $deletionLogPath -content $delSb.ToString()
    Write-Info "Deletion log: docs/sync/deleted-files-$($script:Today).txt ($totalDelete files, $($deprDelete.Count) deprecated)"

    # ----- Deprecated-Excluded Log (ADR-001 BR-9) -----
    $deprLogPath = Join-Path $script:DocsSync "deprecated-excluded-$($script:Today).txt"
    $deprAll     = @($script:DeprecatedEntries | Sort-Object { "$($_.Object)|$($_.MetadataType)|$($_.ComponentName)" })
    $compCount   = @($deprAll | Where-Object { $_.MatchedOn -ne 'dependent' }).Count
    $depCount    = @($deprAll | Where-Object { $_.MatchedOn -eq 'dependent' }).Count

    $deprSb = [System.Text.StringBuilder]::new()
    $null = $deprSb.AppendLine('# Org-to-Git Sync -- Deprecated Components Excluded (ADR-001)')
    $null = $deprSb.AppendLine("# Source org: $script:TargetOrg ($script:OrgUsername)")
    $null = $deprSb.AppendLine("# Retrieved at: $script:RunTimestamp")
    $null = $deprSb.AppendLine("# Git base commit: $script:GitHash")
    $null = $deprSb.AppendLine('# Rule: case-insensitive "_deprecated" in top-level label element or API name')
    $null = $deprSb.AppendLine("# Deprecated components: $compCount   Dependent translation entries: $depCount")
    $null = $deprSb.AppendLine('#')
    $null = $deprSb.AppendLine("# Object`tMetadataType`tComponentName`tMatchedOn`tMatchedValue`tLocalAction`tRelativePath")
    if ($compCount + $depCount -eq 0) {
        $null = $deprSb.AppendLine('# No deprecated components detected')
    } else {
        foreach ($de in $deprAll) {
            $mv = ($de.MatchedValue -replace "`t",' ' -replace "`n",' ')
            $null = $deprSb.AppendLine("$($de.Object)`t$($de.MetadataType)`t$($de.ComponentName)`t$($de.MatchedOn)`t$mv`t$($de.LocalAction)`t$($de.RelativePath)")
        }
    }
    Write-Utf8Lf -filePath $deprLogPath -content $deprSb.ToString()
    Write-Info "Deprecated log: docs/sync/deprecated-excluded-$($script:Today).txt ($compCount components, $depCount dependents)"

    # ----- Sync Report -----
    $objSummary = @{}
    foreach ($obj in $script:AllObjects) {
        $objSummary[$obj] = @{ OnlyLocal=0; OnlyLocalIgnored=0; OnlyOrg=0; Modified=0; Identical=0 }
    }
    foreach ($e in $results.OnlyLocal)        { if ($objSummary.ContainsKey($e.Object)) { $objSummary[$e.Object].OnlyLocal++ } }
    foreach ($e in $results.OnlyLocalIgnored) { if ($objSummary.ContainsKey($e.Object)) { $objSummary[$e.Object].OnlyLocalIgnored++ } }
    foreach ($e in $results.OnlyOrg)          { if ($objSummary.ContainsKey($e.Object)) { $objSummary[$e.Object].OnlyOrg++ } }
    foreach ($e in $results.Modified)         { if ($objSummary.ContainsKey($e.Object)) { $objSummary[$e.Object].Modified++ } }
    foreach ($e in $results.Identical)        { if ($objSummary.ContainsKey($e.Object)) { $objSummary[$e.Object].Identical++ } }

    $rptSb = [System.Text.StringBuilder]::new()
    $null = $rptSb.AppendLine('# Org-to-Git Sync Report')
    $null = $rptSb.AppendLine('')
    $null = $rptSb.AppendLine("**Date:** $script:Today  ")
    $null = $rptSb.AppendLine("**Source org:** $script:TargetOrg ($script:OrgUsername)  ")
    $null = $rptSb.AppendLine("**Retrieved at:** $script:RunTimestamp  ")
    $null = $rptSb.AppendLine("**Git base commit:** $script:GitHash  ")
    $null = $rptSb.AppendLine('')
    $null = $rptSb.AppendLine('## Summary by Object')
    $null = $rptSb.AppendLine('')
    $null = $rptSb.AppendLine('| Object | ONLY_LOCAL (delete) | ONLY_LOCAL_IGNORED (keep) | ONLY_ORG (add) | MODIFIED (overwrite) | IDENTICAL | ONLY_ORG_DEPRECATED | DEPRECATED_DELETE |')
    $null = $rptSb.AppendLine('|--------|--------------------:|-------------------------:|---------------:|--------------------:|----------:|--------------------:|------------------:|')
    foreach ($obj in $script:AllObjects) {
        $s = $objSummary[$obj]
        $ood = @($results.OnlyOrgDeprecated | Where-Object { $_.Object -eq $obj }).Count
        $dd  = @($results.DeprecatedDelete  | Where-Object { $_.Object -eq $obj }).Count
        $null = $rptSb.AppendLine("| $obj | $($s.OnlyLocal) | $($s.OnlyLocalIgnored) | $($s.OnlyOrg) | $($s.Modified) | $($s.Identical) | $ood | $dd |")
    }
    $totOL  = $results.OnlyLocal.Count
    $totOLI = $results.OnlyLocalIgnored.Count
    $totOO  = $results.OnlyOrg.Count
    $totMOD = $results.Modified.Count
    $totIDN = $results.Identical.Count
    $totOOD = $results.OnlyOrgDeprecated.Count
    $totDD  = $results.DeprecatedDelete.Count
    $null = $rptSb.AppendLine("| **TOTAL** | **$totOL** | **$totOLI** | **$totOO** | **$totMOD** | **$totIDN** | **$totOOD** | **$totDD** |")

    $null = $rptSb.AppendLine('')
    $null = $rptSb.AppendLine('## Files to Add from Org (ONLY_ORG)')
    $null = $rptSb.AppendLine('')
    if ($results.OnlyOrg.Count -eq 0) {
        $null = $rptSb.AppendLine('_None._')
    } else {
        foreach ($e in ($results.OnlyOrg | Sort-Object { "$($_.Object)|$($_.ComponentName)" })) {
            $null = $rptSb.AppendLine("- ``$($e.RelativePath)``  ($($e.MetadataType): $($e.Object).$($e.ComponentName))")
        }
    }

    $null = $rptSb.AppendLine('')
    $null = $rptSb.AppendLine('## Files to Overwrite with Org Version (MODIFIED)')
    $null = $rptSb.AppendLine('')
    if ($results.Modified.Count -eq 0) {
        $null = $rptSb.AppendLine('_None._')
    } else {
        foreach ($e in ($results.Modified | Sort-Object { "$($_.Object)|$($_.ComponentName)" })) {
            $null = $rptSb.AppendLine("- ``$($e.RelativePath)``  ($($e.MetadataType): $($e.Object).$($e.ComponentName))")
        }
    }

    $null = $rptSb.AppendLine('')
    $null = $rptSb.AppendLine('## Files Protected by .forceignore (ONLY_LOCAL_IGNORED  -- kept)')
    $null = $rptSb.AppendLine('')
    if ($results.OnlyLocalIgnored.Count -eq 0) {
        $null = $rptSb.AppendLine('_None._')
    } else {
        foreach ($e in ($results.OnlyLocalIgnored | Sort-Object { "$($_.Object)|$($_.ComponentName)" })) {
            $null = $rptSb.AppendLine("- ``$($e.RelativePath)``  ($($e.MetadataType): $($e.Object).$($e.ComponentName))")
        }
    }

    # H3 FIX: FORMULA_PENDING section now covers ALL staged files (IDENTICAL + ONLY_ORG + MODIFIED)
    $null = $rptSb.AppendLine('')
    $null = $rptSb.AppendLine('## PRODUCTION BLOCKERS  -- FORMULA_PENDING fields')
    $null = $rptSb.AppendLine('')
    $null = $rptSb.AppendLine('> These staged files contain `FORMULA_PENDING` placeholders and are production blockers.')
    $null = $rptSb.AppendLine('> Restore the original formula from the `<description>` field before deploying to production.')
    $null = $rptSb.AppendLine('> **Coverage: ALL staged files were scanned** (IDENTICAL + ONLY_ORG + MODIFIED).')
    $null = $rptSb.AppendLine('')
    if ($results.FormulaPending.Count -eq 0) {
        $null = $rptSb.AppendLine('_None detected._')
    } else {
        foreach ($e in ($results.FormulaPending | Sort-Object { $_.RelativePath })) {
            $null = $rptSb.AppendLine("- ``$($e.RelativePath)``")
        }
    }

    # ADR-001 sections
    $null = $rptSb.AppendLine('')
    $null = $rptSb.AppendLine('## Deprecated Components Excluded (ADR-001)')
    $null = $rptSb.AppendLine('')
    if ($script:DeprecatedEntries.Count -eq 0) {
        $null = $rptSb.AppendLine('_None._')
    } else {
        foreach ($de in ($script:DeprecatedEntries | Sort-Object { "$($_.Object)|$($_.ComponentName)" })) {
            $mv = ($de.MatchedValue -replace "`t",' ' -replace "`n",' ')
            $null = $rptSb.AppendLine("- ``$($de.RelativePath)`` ($($de.MetadataType): $($de.Object).$($de.ComponentName))  -- MatchedOn: $($de.MatchedOn): $mv  -- LocalAction: $($de.LocalAction)")
        }
    }

    $null = $rptSb.AppendLine('')
    $null = $rptSb.AppendLine('## PRODUCTION BLOCKERS  -- References to Deprecated Components')
    $null = $rptSb.AppendLine('')
    if ($results.DeprecatedRefs.Count -eq 0) {
        $null = $rptSb.AppendLine('_None._')
    } else {
        foreach ($r in $results.DeprecatedRefs) {
            $null = $rptSb.AppendLine("- ``$($r.File)``:$($r.Line) → $($r.Token)")
        }
    }

    $null = $rptSb.AppendLine('')
    $null = $rptSb.AppendLine('## Suspect Deprecated Markers  -- Review (not excluded)')
    $null = $rptSb.AppendLine('')
    if ($results.Suspect.Count -eq 0) {
        $null = $rptSb.AppendLine('_None._')
    } else {
        foreach ($se in ($results.Suspect | Sort-Object { "$($_.Object)|$($_.ComponentName)" })) {
            $null = $rptSb.AppendLine("- ``$($se.RelativePath)`` ($($se.MetadataType): $($se.Object).$($se.ComponentName))  -- MatchedOn: $($se.MatchedOn): $($se.MatchedValue)")
        }
    }

    Write-Utf8Lf -filePath $reportPath -content $rptSb.ToString()
    Write-Info "Sync report: docs/sync/sync-report-$($script:Today).md"
}

# ============================================================
# PHASE: SYNC  -- Steps 6 through 8
# ============================================================

function Get-LatestDeletionLog {
    $logs = @(Get-ChildItem -Path $script:DocsSync -Filter 'deleted-files-*.txt' `
        -ErrorAction SilentlyContinue | Sort-Object Name -Descending)
    if ($logs.Count -eq 0) {
        Write-Fatal "No deletion log found in docs/sync/. Run Phase Retrieve first."
    }
    $latest = $logs[0]
    # M1 FIX: Print log name and modification time so user can confirm it's the right log.
    $logDate = $latest.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')
    Write-Info "Using deletion log: docs/sync/$($latest.Name)  (last modified: $logDate)"
    Write-Info "Confirm this is the log you reviewed before Phase Sync runs any deletions."
    return $latest.FullName
}

function Read-DeletionLog([string]$logPath) {
    $paths = [System.Collections.Generic.List[string]]::new()
    foreach ($line in (Get-Content -Path $logPath -Encoding UTF8)) {
        if ($line.StartsWith('#') -or [string]::IsNullOrWhiteSpace($line)) { continue }
        $cols = $line -split "`t"
        if ($cols.Count -ge 4) {
            $relPath = $cols[3].Trim()
            if ($relPath -ne '') { $paths.Add($relPath) }
        }
    }
    return $paths
}

function Invoke-ApplySync {
    Write-Step 6 'Apply sync: copy from staging, delete ONLY_LOCAL files'

    # Verify staging exists
    if (-not (Test-Path $script:StagingBase)) {
        Write-Fatal ("Staging directory not found: $script:StagingBase`n" +
            "Run Phase Retrieve first.")
    }

    # ADR-001 BR-14: abort if deprecated strip marker is missing
    if (-not (Test-Path $script:DeprecatedMarker)) {
        Write-Fatal ("Staging was not stripped of _deprecated components (.sync/deprecated-stripped.marker missing). " +
                     "Re-run -Phase Retrieve. (ADR-001)")
    }

    # ADR-001 M-2/M-4: verify marker is complete and matches the deletion log from the same run.
    # Guards:
    #   (a) run_date and stripped_at must be present  -- missing fields mean a corrupt/partial marker.
    #   (b) deprecated-excluded-<run_date>.txt must exist (log from that date).
    #   (c) After reading the deletion log, its date must match the marker date (same-day two-run protection).
    #   (d) The deprecated-excluded log's "Retrieved at:" timestamp must match stripped_at (exact-run match).
    $markerContent = Get-Content $script:DeprecatedMarker -Raw -ErrorAction SilentlyContinue
    $markerDate    = ''
    $markerTs      = ''
    if ($markerContent -match '(?m)^run_date=(\d{8})')                              { $markerDate = $Matches[1] }
    if ($markerContent -match '(?m)^stripped_at=([^\r\n]+)')                         { $markerTs   = $Matches[1].Trim() }
    if ($markerDate -eq '' -or $markerTs -eq '') {
        Write-Fatal ("Deprecated strip marker is incomplete (missing run_date or stripped_at). " +
                     "Re-run -Phase Retrieve. (ADR-001 M-4)")
    }
    $expectedDeprLog = Join-Path $script:DocsSync "deprecated-excluded-$markerDate.txt"
    if (-not (Test-Path $expectedDeprLog)) {
        Write-Fatal ("Marker run_date=$markerDate but deprecated-excluded-$markerDate.txt not found. " +
                     "Re-run -Phase Retrieve to regenerate a complete set. (ADR-001 M-2)")
    }
    $script:SyncLogDate = $markerDate

    # H4 FIX: Hard-abort if in-scope paths have uncommitted changes.
    # Step 6 overwrites and deletes files  -- uncommitted changes in these paths cannot be recovered.
    Write-Info "Checking working tree for uncommitted changes in in-scope paths..."
    $dirtyInScope = @(Invoke-NativeCommand 'git' @('status', '--porcelain', '--',
        'force-app/main/default/objects',
        'force-app/main/default/quickActions',
        'force-app/main/default/objectTranslations') |
        Where-Object { $_.Trim() -ne '' })
    if ($dirtyInScope.Count -gt 0) {
        Write-Host "`nERROR: Working tree is dirty for in-scope paths ($($dirtyInScope.Count) file(s))." -ForegroundColor Red
        Write-Host "  Commit or stash your changes before running Phase Sync." -ForegroundColor Red
        Write-Host "  Files that would be overwritten cannot be recovered from git in their current state." -ForegroundColor Red
        Write-Host "  Aborting." -ForegroundColor Red
        exit 1
    }
    Write-Info "Working tree is clean for in-scope paths."

    # Read deletion log (M1: name + date printed inside Get-LatestDeletionLog)
    $logPath      = Get-LatestDeletionLog
    $deletionDate = ([System.IO.Path]::GetFileNameWithoutExtension($logPath)) -replace '^deleted-files-',''
    # ADR-001 M-4(c): deletion log date must match marker date
    if ($deletionDate -ne $markerDate) {
        Write-Fatal ("Deletion log date '$deletionDate' does not match marker run_date '$markerDate'. " +
                     "Re-run -Phase Retrieve to produce a consistent set of logs. (ADR-001 M-4)")
    }
    # ADR-001 M-4(d): deprecated-excluded log Retrieved-at timestamp must match marker stripped_at
    $deprLogContent = Get-Content $expectedDeprLog -Raw -ErrorAction SilentlyContinue
    $deprLogTs = ''
    if ($deprLogContent -match '(?m)^# Retrieved at:\s*([^\r\n]+)') { $deprLogTs = $Matches[1].Trim() }
    if ($deprLogTs -ne '' -and $deprLogTs -ne $markerTs) {
        Write-Fatal ("Deprecated-excluded log timestamp '$deprLogTs' does not match marker stripped_at '$markerTs'. " +
                     "Re-run -Phase Retrieve to produce a matching set of logs. (ADR-001 M-4)")
    }
    # ADR-001: record date token for Invoke-PayloadGuard (Step 8b)
    $script:SyncLogDate = $deletionDate
    $toDelete = Read-DeletionLog $logPath
    Write-Info "Files to delete: $($toDelete.Count)"

    # Allowed staging roots to copy from (L3 FIX)
    $allowedRoots = @('objects', 'quickActions', 'objectTranslations')

    # Allowed delete path prefixes (safety guard in Step 6b)
    $allowedDeletePrefixes = @(
        'force-app/main/default/objects/',
        'force-app/main/default/quickActions/',
        'force-app/main/default/objectTranslations/'
    )

    # --- Step 6a: Copy staging files to force-app ---
    $copied         = 0
    $skippedExclude = 0
    $skippedUnknown = 0

    $stagingFiles = @(Get-ChildItem -Path $script:StagingBase -Recurse -File -ErrorAction SilentlyContinue)
    foreach ($stagingFile in $stagingFiles) {
        $relToBase = $stagingFile.FullName.Substring($script:StagingBase.Length).TrimStart('\').TrimStart('/')
        $relParts  = $relToBase -split '[/\\]'

        # L3 FIX: Only copy from known roots
        if ($relParts.Count -eq 0 -or -not ($allowedRoots -contains $relParts[0])) {
            $skippedUnknown++
            continue
        }

        # Safety guard: never copy excluded folders
        $skipFolder = $false
        foreach ($excFolder in $script:ExcludedChildFolders) {
            if ($relParts -contains $excFolder) { $skipFolder = $true; break }
        }
        if ($skipFolder) { $skippedExclude++; continue }

        # Filter to in-scope objects
        if ($relParts[0] -eq 'objects' -and $relParts.Count -ge 2) {
            if (-not $script:ObjectSet.ContainsKey($relParts[1])) { continue }
        }
        if ($relParts[0] -eq 'quickActions' -and $relParts.Count -ge 2) {
            $dotIdx = $relParts[1].IndexOf('.')
            if ($dotIdx -gt 0 -and -not $script:ObjectSet.ContainsKey($relParts[1].Substring(0, $dotIdx))) { continue }
        }
        if ($relParts[0] -eq 'objectTranslations' -and $relParts.Count -ge 2) {
            $dashIdx = $relParts[1].IndexOf('-')
            if ($dashIdx -gt 0 -and -not $script:ObjectSet.ContainsKey($relParts[1].Substring(0, $dashIdx))) { continue }
        }

        $destPath = Join-Path $script:ForceAppBase $relToBase
        $destDir  = Split-Path $destPath -Parent
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        Copy-Item -Path $stagingFile.FullName -Destination $destPath -Force
        $copied++
    }

    Write-Info "Copied/overwritten $copied file(s) from staging to force-app."
    if ($skippedExclude -gt 0) {
        Write-Info "Skipped $skippedExclude excluded-folder file(s) (listViews/businessProcesses/sharingReasons)."
    }
    if ($skippedUnknown -gt 0) {
        Write-Info "Skipped $skippedUnknown file(s) outside known staging roots."
    }

    # --- Step 6b: Delete ONLY_LOCAL files ---
    $deleted = 0
    foreach ($relPath in $toDelete) {
        # Safety: path must begin with an allowed prefix
        $allowedPrefix = $false
        foreach ($pfx in $allowedDeletePrefixes) {
            if ($relPath.StartsWith($pfx, [System.StringComparison]::OrdinalIgnoreCase)) {
                $allowedPrefix = $true; break
            }
        }
        if (-not $allowedPrefix) {
            Write-Warn "SKIPPING deletion of path outside allowed scope: $relPath"
            continue
        }
        $absPath = Join-Path $script:ProjectRoot ($relPath.Replace('/', '\'))
        if (Test-Path $absPath) {
            Remove-Item -Path $absPath -Force
            $deleted++
        } else {
            Write-Warn "File to delete not found (already removed?): $relPath"
        }
    }

    Write-Info "Deleted $deleted file(s) from force-app."

    # --- Step 6c: Purge excluded folders from force-app ---
    # listViews, businessProcesses, sharingReasons must be EMPTY in force-app
    # for all 49 in-scope objects  -- deploying a CustomObject deploys every file
    # in the object folder, so leaving these folders populated would ship them
    # to production. Strip them here unconditionally after the ONLY_LOCAL pass.
    Write-Info "Purging excluded child folders ($($script:ExcludedChildFolders -join ', ')) from force-app..."
    $objLocalDir  = Join-Path $script:ForceAppBase 'objects'
    $purgedFolders = 0
    $purgedFiles   = 0
    foreach ($obj in $script:AllObjects) {
        $objDir = Join-Path $objLocalDir $obj
        if (-not (Test-Path $objDir)) { continue }
        foreach ($excFolder in $script:ExcludedChildFolders) {
            $targetDir = Join-Path $objDir $excFolder
            if (Test-Path $targetDir) {
                $filesInDir = @(Get-ChildItem -Path $targetDir -File -Recurse -ErrorAction SilentlyContinue)
                if ($filesInDir.Count -gt 0) {
                    Remove-Item -Path $targetDir -Recurse -Force
                    Write-Info "  Removed $($filesInDir.Count) file(s) from $obj\$excFolder"
                    $purgedFiles  += $filesInDir.Count
                    $purgedFolders++
                }
            }
        }
    }
    if ($purgedFolders -gt 0) {
        Write-Info "Purged $purgedFiles file(s) across $purgedFolders excluded folder(s)."
    } else {
        Write-Info "No excluded-folder files found in force-app (already clean)."
    }

    Write-Info "Sync complete: $copied copied/overwritten, $deleted deleted, $purgedFiles excluded-folder files purged."
}

function New-ProdManifest {
    Write-Step 7 'Generate manifest/package-objects-prod.xml'

    $manifestPath = Join-Path $script:ProjectRoot 'manifest\package-objects-prod.xml'
    if (Test-Path (Join-Path $script:ProjectRoot 'manifest\package.xml')) {
        Write-Info "Existing manifest/package.xml is untouched."
    }

    $typeMembers = [ordered]@{
        'CompactLayout'            = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        'CustomField'              = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        'CustomObject'             = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        'CustomObjectTranslation'  = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        'FieldSet'                 = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        'Index'                    = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        'QuickAction'              = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        'RecordType'               = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        'ValidationRule'           = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        'WebLink'                  = [System.Collections.Generic.SortedSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    }

    Write-Info "Building production manifest from force-app contents..."

    # ADR-001 BR-15: collect deprecated violations; abort before writing manifest
    $violations = [System.Collections.Generic.List[string]]::new()

    # ----- Objects -----
    # H7: $script:FolderTypeMap does not include businessProcesses/sharingReasons,
    # so those subfolders are naturally excluded from the manifest.
    $objLocalDir = Join-Path $script:ForceAppBase 'objects'
    foreach ($obj in $script:AllObjects) {
        $objDir = Join-Path $objLocalDir $obj
        if (-not (Test-Path $objDir)) { continue }

        $objMetaFile = Join-Path $objDir "$obj.object-meta.xml"
        if (Test-Path $objMetaFile) {
            $projRel = "force-app/main/default/objects/$obj/$obj.object-meta.xml"
            if (-not (Test-FileIsIgnored $projRel)) {
                # ADR-001 BR-15: check for _deprecated on CustomObject
                $deprCheck = $null
                try { $deprCheck = Get-DeprecatedMatch -FilePath $objMetaFile -MetadataType 'CustomObject' -ApiName $obj }
                catch { Write-Fatal $_.Exception.Message }
                if ($deprCheck.IsDeprecated) {
                    $violations.Add("$projRel ($($deprCheck.MatchedOn): $($deprCheck.MatchedValue))")
                } else {
                    $null = $typeMembers['CustomObject'].Add($obj)
                }
            }
        }

        foreach ($subFolder in $script:FolderTypeMap.Keys) {
            $mdType = $script:FolderTypeMap[$subFolder]
            $subDir = Join-Path $objDir $subFolder
            if (-not (Test-Path $subDir)) { continue }

            $childFiles = @(Get-ChildItem -Path $subDir -File -ErrorAction SilentlyContinue)
            foreach ($f in $childFiles) {
                $projRel = "force-app/main/default/objects/$obj/$subFolder/$($f.Name)"
                if (Test-FileIsIgnored $projRel) { continue }
                $compName = Get-ApiName $f.Name
                # ADR-001 BR-15: check child component
                $deprCheck = $null
                try { $deprCheck = Get-DeprecatedMatch -FilePath $f.FullName -MetadataType $mdType -ApiName $compName }
                catch { Write-Fatal $_.Exception.Message }
                if ($deprCheck.IsDeprecated) {
                    $violations.Add("$projRel ($($deprCheck.MatchedOn): $($deprCheck.MatchedValue))")
                } else {
                    $null = $typeMembers[$mdType].Add("$obj.$compName")
                }
            }
        }
    }

    # ----- QuickActions -----
    $qaLocalDir = Join-Path $script:ForceAppBase 'quickActions'
    if (Test-Path $qaLocalDir) {
        @(Get-ChildItem -Path $qaLocalDir -File -Filter '*.quickAction-meta.xml' -ErrorAction SilentlyContinue) |
            ForEach-Object {
                $dotIdx = $_.Name.IndexOf('.')
                if ($dotIdx -le 0) { return }
                $objName = $_.Name.Substring(0, $dotIdx)
                if (-not $script:ObjectSet.ContainsKey($objName)) { return }
                $projRel = "force-app/main/default/quickActions/$($_.Name)"
                if (Test-FileIsIgnored $projRel) { return }
                $compName = Get-ApiName $_.Name
                # ADR-001 BR-15: check QuickAction
                $deprCheck = $null
                try { $deprCheck = Get-DeprecatedMatch -FilePath $_.FullName -MetadataType 'QuickAction' -ApiName $compName }
                catch { Write-Fatal $_.Exception.Message }
                if ($deprCheck.IsDeprecated) {
                    $violations.Add("$projRel ($($deprCheck.MatchedOn): $($deprCheck.MatchedValue))")
                } else {
                    $null = $typeMembers['QuickAction'].Add($compName)
                }
            }
    }

    # ----- ObjectTranslations -----
    $transLocalDir = Join-Path $script:ForceAppBase 'objectTranslations'
    if (Test-Path $transLocalDir) {
        @(Get-ChildItem -Path $transLocalDir -Directory -ErrorAction SilentlyContinue) |
            ForEach-Object {
                $folderName = $_.Name
                $dashIdx    = $folderName.IndexOf('-')
                if ($dashIdx -le 0) { return }
                $objName = $folderName.Substring(0, $dashIdx)
                if (-not $script:ObjectSet.ContainsKey($objName)) { return }
                $mainFile = Join-Path $_.FullName "$folderName.objectTranslation-meta.xml"
                $projRel  = "force-app/main/default/objectTranslations/$folderName/$folderName.objectTranslation-meta.xml"
                if (Test-Path $mainFile) {
                    if (-not (Test-FileIsIgnored $projRel)) {
                        $null = $typeMembers['CustomObjectTranslation'].Add($folderName)
                    }
                } else {
                    $anyFile = @(Get-ChildItem -Path $_.FullName -File -ErrorAction SilentlyContinue) |
                        Select-Object -First 1
                    if ($null -ne $anyFile) {
                        $projRelAny = "force-app/main/default/objectTranslations/$folderName/$($anyFile.Name)"
                        if (-not (Test-FileIsIgnored $projRelAny)) {
                            $null = $typeMembers['CustomObjectTranslation'].Add($folderName)
                        }
                    }
                }
            }
    }

    # ADR-001 BR-15: abort if any deprecated component found in force-app
    if ($violations.Count -gt 0) {
        if (Test-Path $manifestPath) { Remove-Item $manifestPath -Force }
        foreach ($v in $violations) { Write-Host "  DEPRECATED IN FORCE-APP: $v" -ForegroundColor Red }
        Write-Fatal "$($violations.Count) _deprecated component(s) found in force-app. Manifest not written. (ADR-001 L3)"
    }

    # ----- Build XML -----
    $xmlSb = [System.Text.StringBuilder]::new()
    $null = $xmlSb.AppendLine('<?xml version="1.0" encoding="UTF-8"?>')
    $null = $xmlSb.AppendLine('<!--')
    $null = $xmlSb.AppendLine('  Production manifest for the 49 in-scope objects.')
    $null = $xmlSb.AppendLine("  Generated by Sync-OrgToGit.ps1 on $script:RunTimestamp")
    $null = $xmlSb.AppendLine("  Source: $script:TargetOrg | Git: $script:GitHash")
    $null = $xmlSb.AppendLine('  DO NOT ADD wildcards. DO NOT add ListView, Layout, or FlexiPage members.')
    $null = $xmlSb.AppendLine('-->')
    $null = $xmlSb.AppendLine('<Package xmlns="http://soap.sforce.com/2006/04/metadata">')

    foreach ($mdType in $typeMembers.Keys) {
        $memberSet = $typeMembers[$mdType]
        if ($memberSet.Count -eq 0) { continue }
        $null = $xmlSb.AppendLine('    <types>')
        foreach ($member in $memberSet) {
            $null = $xmlSb.AppendLine("        <members>$member</members>")
        }
        $null = $xmlSb.AppendLine("        <name>$mdType</name>")
        $null = $xmlSb.AppendLine('    </types>')
    }

    $null = $xmlSb.AppendLine("    <version>$script:ApiVersion</version>")
    $null = $xmlSb.AppendLine('</Package>')

    $manifestDir = Split-Path $manifestPath -Parent
    if (-not (Test-Path $manifestDir)) {
        New-Item -ItemType Directory -Path $manifestDir -Force | Out-Null
    }
    Write-Utf8Lf -filePath $manifestPath -content $xmlSb.ToString()

    $totalMembers = 0
    foreach ($mdType in $typeMembers.Keys) { $totalMembers += $typeMembers[$mdType].Count }
    Write-Info "manifest/package-objects-prod.xml written with $totalMembers member(s)."
}

function Test-Manifest {
    Write-Step 8 'Validate manifest locally (sf project convert source)'

    $manifestPath  = Join-Path $script:ProjectRoot 'manifest\package-objects-prod.xml'
    $mdapiCheckDir = Join-Path $script:SyncDir 'mdapi-check'

    if (-not (Test-Path $manifestPath)) {
        Write-Fatal "manifest/package-objects-prod.xml not found. Run Step 7 first."
    }

    # M5: Clean mdapi-check dir before converting to get a fresh count
    if (Test-Path $mdapiCheckDir) {
        Remove-Item -Path $mdapiCheckDir -Recurse -Force
    }

    Push-Location $script:ProjectRoot
    try {
        # C3 FIX: No 2>&1
        $jsonLines = Invoke-NativeCommand 'sf' @('project', 'convert', 'source',
            '--manifest', 'manifest\package-objects-prod.xml',
            '--output-dir', '.sync\mdapi-check',
            '--json')
        $rawJson = $jsonLines -join ''

        if ($LASTEXITCODE -eq 0) {
            Write-Info "Manifest validation PASSED. All members resolved successfully."
            try {
                $parsed = $rawJson | ConvertFrom-Json
                if ($null -ne $parsed.result -and
                    $parsed.result.PSObject.Properties['numComponents']) {
                    Write-Info "Components converted: $($parsed.result.numComponents)"
                }
            } catch { }
            # ADR-001 Step 8b: payload guard
            Invoke-PayloadGuard
        } else {
            Write-Warn "Manifest validation FAILED (exit code $LASTEXITCODE)."
            try {
                $parsed = $rawJson | ConvertFrom-Json
                if ($null -ne $parsed.message) {
                    Write-Host "  $($parsed.message)" -ForegroundColor Red
                }
                if ($null -ne $parsed.result -and
                    $parsed.result.PSObject.Properties['unresolvedComponents']) {
                    foreach ($uc in $parsed.result.unresolvedComponents) {
                        Write-Host "  UNRESOLVED: $uc" -ForegroundColor Red
                    }
                }
            } catch {
                Write-Host $rawJson -ForegroundColor Red
            }
            Write-Fatal "Fix the manifest errors above before proceeding to production deployment."
        }
    } finally {
        Pop-Location
    }
}

# ============================================================
# MAIN ENTRY POINT
# ============================================================

Write-Host "`nSync-OrgToGit.ps1  -- Phase: $Phase" -ForegroundColor White
Write-Host "Project root: $script:ProjectRoot"

if ($Phase -eq 'Retrieve') {
    Invoke-Preflight
    Invoke-Retrieve
    Remove-ExcludedFolders
    Invoke-DetectDeprecated
    Write-RetrieveLog
    Invoke-StripDeprecated
    $compareResults = Invoke-Compare
    Write-Reports $compareResults

    Write-Host "`n" -NoNewline
    Write-Host ('=' * 60) -ForegroundColor Magenta
    Write-Host '=== HUMAN GATE ===' -ForegroundColor Magenta
    Write-Host ('=' * 60) -ForegroundColor Magenta
    Write-Host ''
    Write-Host "Review the following files before proceeding:"
    Write-Host "  docs\sync\deleted-files-$($script:Today).txt"
    Write-Host "  docs\sync\sync-report-$($script:Today).md"
    Write-Host "  docs\sync\retrieve-log-$($script:Today).txt"
    Write-Host "  docs\sync\deprecated-excluded-$($script:Today).txt"
    Write-Host ''
    Write-Host "Pay special attention to:"
    Write-Host "  - ONLY_LOCAL files (will be deleted from force-app)"
    Write-Host "  - FORMULA_PENDING section (production blockers  -- ALL staged files scanned)"
    Write-Host "  - Deprecated exclusions and deprecated-reference blockers (ADR-001)"
    Write-Host ''
    Write-Host "To approve and proceed with the sync, run:" -ForegroundColor Yellow
    Write-Host "  .\scripts\Sync-OrgToGit.ps1 -Phase Sync" -ForegroundColor Yellow
    Write-Host ''

} elseif ($Phase -eq 'Sync') {

    # Verify staging exists
    if (-not (Test-Path $script:StagingBase)) {
        Write-Fatal ("Staging directory not found at '$script:StagingBase'.`n" +
            "Phase Retrieve must be run before Phase Sync.")
    }

    # C4: Initialize ignore set for Sync phase (not called via Invoke-Preflight in Sync)
    Initialize-IgnoreSet

    # Populate runtime metadata from git (C3: no 2>$null)
    $gitLines = Invoke-NativeCommand 'git' @('log', '--oneline', '-1', '--format=%h')
    $script:GitHash     = if ($gitLines) { ($gitLines | Select-Object -First 1).Trim() } else { 'unknown' }
    $script:OrgUsername = $script:TargetOrg  # approximate; full lookup not re-run in Sync

    Invoke-ApplySync
    New-ProdManifest
    Test-Manifest

    Write-Host ''
    Write-Host ('=' * 60) -ForegroundColor Green
    Write-Host 'Phase Sync complete.' -ForegroundColor Green
    Write-Host ('=' * 60) -ForegroundColor Green
    Write-Host ''
    Write-Host "Outputs:"
    Write-Host "  manifest\package-objects-prod.xml   -- production manifest"
    Write-Host "  .sync\mdapi-check\                  -- MDAPI validation output (git-ignored)"
    Write-Host ''
    Write-Host "Next steps:"
    Write-Host "  1. Review manifest\package-objects-prod.xml for correctness."
    Write-Host "  2. Resolve any FORMULA_PENDING fields flagged in the sync report."
    # M4 FIX: PowerShell 5.1 compatible  -- no && operator, separate statements
    Write-Host "  3. Commit the sync changes (PowerShell):"
    Write-Host "       git add force-app\main\default\objects force-app\main\default\quickActions force-app\main\default\objectTranslations docs\sync manifest\package-objects-prod.xml"
    Write-Host "       git commit -m 'chore: org-to-git sync $(Get-Date -Format yyyy-MM-dd)'"
    Write-Host "  4. Validate against production before deploying (no deploy executed):"
    Write-Host "       sf project deploy validate --manifest manifest\package-objects-prod.xml --target-org <prod-alias>"
    Write-Host ''
}

#Requires -Version 5.1
<#
.SYNOPSIS
    Compares local force-app objects with what the org currently has.

.DESCRIPTION
    1. Copies force-app  →  force-app-copy  (full snapshot of current local state)
    2. Empties force-app-copy/main/default/objects
    3. Retrieves all objects fresh from the org into force-app-copy
    4. Diffs force-app-copy objects against force-app objects and writes a report

    The script is read-only with respect to force-app — it never touches the real tree.

.PARAMETER TargetOrg
    SF CLI alias or username for the org to retrieve from. Default: astDev

.PARAMETER SkipRetrieve
    If set, skips steps 1-3 and just re-runs the diff against an existing force-app-copy.

.EXAMPLE
    .\scripts\Compare-OrgObjects.ps1
    .\scripts\Compare-OrgObjects.ps1 -TargetOrg myOtherSandbox
    .\scripts\Compare-OrgObjects.ps1 -SkipRetrieve   # re-diff without re-fetching
#>
param(
    [string]$TargetOrg   = 'astDev',
    [switch]$SkipRetrieve
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$env:SF_AUTOUPDATE_DISABLE = 'true'
$env:SF_DISABLE_AUTOUPDATE = 'true'

# ── paths ──────────────────────────────────────────────────────────────────────
$ProjectRoot   = Split-Path $PSScriptRoot -Parent
$ForceApp      = Join-Path $ProjectRoot 'force-app'
$ForceAppCopy  = Join-Path $ProjectRoot 'force-app-copy'
$ObjLocal      = Join-Path $ForceApp     'main\default\objects'
$ObjCopy       = Join-Path $ForceAppCopy 'main\default\objects'
$ReportDir     = Join-Path $ProjectRoot  'docs\compare'
$ReportFile    = Join-Path $ReportDir    "compare-objects-$(Get-Date -Format 'yyyyMMdd-HHmm').md"

New-Item -ItemType Directory -Force -Path $ReportDir | Out-Null

# ── helpers ────────────────────────────────────────────────────────────────────
function Write-Step([string]$msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Write-OK  ([string]$msg) { Write-Host "    OK  $msg" -ForegroundColor Green }
function Write-Warn([string]$msg) { Write-Host "    !! $msg"  -ForegroundColor Yellow }

# ── step 1-3: copy + retrieve ──────────────────────────────────────────────────
if (-not $SkipRetrieve) {

    # 1. Copy force-app → force-app-copy
    Write-Step "Step 1 — Copying force-app → force-app-copy"
    if (Test-Path $ForceAppCopy) {
        Write-Warn "force-app-copy already exists — removing it first"
        Remove-Item -Recurse -Force $ForceAppCopy
    }
    Copy-Item -Recurse -Path $ForceApp -Destination $ForceAppCopy
    Write-OK "Copied"

    # 2. Empty the objects folder in force-app-copy
    Write-Step "Step 2 — Clearing force-app-copy objects folder"
    if (Test-Path $ObjCopy) {
        Remove-Item -Recurse -Force $ObjCopy
    }
    New-Item -ItemType Directory -Force -Path $ObjCopy | Out-Null
    Write-OK "Cleared $ObjCopy"

    # 3. Retrieve all objects from the org into force-app-copy
    Write-Step "Step 3 — Retrieving objects from org ($TargetOrg)"
    Write-Host "    Running: sf project retrieve start --metadata CustomObject --output-dir force-app-copy/main/default --target-org $TargetOrg"

    $retrieveArgs = @(
        'project', 'retrieve', 'start',
        '--metadata', 'CustomObject',
        '--output-dir', (Join-Path $ForceAppCopy 'main\default'),
        '--target-org', $TargetOrg,
        '--api-version', '64.0'
    )

    & sf @retrieveArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Warn "Retrieve exited with code $LASTEXITCODE — diff may be incomplete"
    } else {
        Write-OK "Retrieve complete"
    }
}

# ── step 4: diff ───────────────────────────────────────────────────────────────
Write-Step "Step 4 — Diffing objects"

if (-not (Test-Path $ObjLocal)) { throw "force-app objects folder not found: $ObjLocal" }
if (-not (Test-Path $ObjCopy))  { throw "force-app-copy objects folder not found: $ObjCopy — run without -SkipRetrieve first" }

# Collect relative paths under each root (object subfolders + all xml files inside)
function Get-RelativePaths([string]$root) {
    Get-ChildItem -Recurse -File -Path $root |
        ForEach-Object { $_.FullName.Substring($root.Length).TrimStart('\', '/') }
}

$localFiles = Get-RelativePaths $ObjLocal  | Sort-Object
$copyFiles  = Get-RelativePaths $ObjCopy   | Sort-Object

$localSet = [System.Collections.Generic.HashSet[string]]($localFiles)
$copySet  = [System.Collections.Generic.HashSet[string]]($copyFiles)

$onlyInLocal = $localFiles | Where-Object { -not $copySet.Contains($_) }
$onlyInCopy  = $copyFiles  | Where-Object { -not $localSet.Contains($_) }
$inBoth      = $localFiles | Where-Object { $copySet.Contains($_) }

# Find modified files (same path, different content)
$modified = $inBoth | Where-Object {
    $localHash = (Get-FileHash (Join-Path $ObjLocal $_) -Algorithm MD5).Hash
    $copyHash  = (Get-FileHash (Join-Path $ObjCopy  $_) -Algorithm MD5).Hash
    $localHash -ne $copyHash
}

# ── report ─────────────────────────────────────────────────────────────────────
$totalDiff = $onlyInLocal.Count + $onlyInCopy.Count + @($modified).Count

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor White
Write-Host "  DIFF SUMMARY" -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor White
Write-Host "  Only in force-app (local only) : $($onlyInLocal.Count)" -ForegroundColor Yellow
Write-Host "  Only in force-app-copy (org)   : $($onlyInCopy.Count)"  -ForegroundColor Green
Write-Host "  Modified (same path, diff hash): $(@($modified).Count)"  -ForegroundColor Magenta
Write-Host "  Total differences              : $totalDiff"              -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor White

# Build markdown report
$sb = [System.Text.StringBuilder]::new()
$null = $sb.AppendLine("# Object Compare Report")
$null = $sb.AppendLine("")
$null = $sb.AppendLine("| | |")
$null = $sb.AppendLine("|---|---|")
$null = $sb.AppendLine("| **Date** | $(Get-Date -Format 'yyyy-MM-dd HH:mm') |")
$null = $sb.AppendLine("| **Org** | $TargetOrg |")
$null = $sb.AppendLine("| **Local (force-app)** | $ObjLocal |")
$null = $sb.AppendLine("| **Org snapshot (force-app-copy)** | $ObjCopy |")
$null = $sb.AppendLine("")
$null = $sb.AppendLine("## Summary")
$null = $sb.AppendLine("")
$null = $sb.AppendLine("| Category | Count |")
$null = $sb.AppendLine("|---|---|")
$null = $sb.AppendLine("| Only in local force-app | $($onlyInLocal.Count) |")
$null = $sb.AppendLine("| Only in org (force-app-copy) | $($onlyInCopy.Count) |")
$null = $sb.AppendLine("| Modified | $(@($modified).Count) |")
$null = $sb.AppendLine("| **Total differences** | **$totalDiff** |")
$null = $sb.AppendLine("")

if ($onlyInLocal.Count -gt 0) {
    $null = $sb.AppendLine("## Files only in local force-app (not in org)")
    $null = $sb.AppendLine("> These exist locally but the org returned nothing for them.")
    $null = $sb.AppendLine("")
    foreach ($f in ($onlyInLocal | Sort-Object)) {
        $null = $sb.AppendLine("- ``$f``")
    }
    $null = $sb.AppendLine("")
}

if ($onlyInCopy.Count -gt 0) {
    $null = $sb.AppendLine("## Files only in org (force-app-copy)")
    $null = $sb.AppendLine("> These came from the org but are not present in the local source tree.")
    $null = $sb.AppendLine("")
    foreach ($f in ($onlyInCopy | Sort-Object)) {
        $null = $sb.AppendLine("- ``$f``")
    }
    $null = $sb.AppendLine("")
}

if (@($modified).Count -gt 0) {
    $null = $sb.AppendLine("## Modified files (content differs)")
    $null = $sb.AppendLine("> Same path in both trees but different content.")
    $null = $sb.AppendLine("")
    foreach ($f in ($modified | Sort-Object)) {
        $null = $sb.AppendLine("- ``$f``")
    }
    $null = $sb.AppendLine("")
}

if ($totalDiff -eq 0) {
    $null = $sb.AppendLine("## Result")
    $null = $sb.AppendLine("")
    $null = $sb.AppendLine("> **No differences found.** Local objects match the org exactly.")
    $null = $sb.AppendLine("")
}

Set-Content -Path $ReportFile -Value $sb.ToString() -Encoding UTF8

Write-Host ""
Write-OK "Report written to: $ReportFile"
Write-Host ""

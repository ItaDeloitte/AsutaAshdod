#Requires -Version 5.1
<#
.SYNOPSIS
    Keep only Hebrew (iw) and English (en) object translations in the test/ staging tree.

.DESCRIPTION
    Project rule: only Hebrew (`iw`) and US English (`en_US`) CustomObjectTranslation
    folders belong in the `test\main\default\objectTranslations\` staging area. Every
    other language is dropped so it is never mirrored into force-app by Phase Sync.

    This runs AFTER `Sync-OrgToGit.ps1 -Phase Retrieve` (which lands every retrieved
    language in test/) and BEFORE the human reviews / runs Phase Sync. It only ever
    touches `test\main\default\objectTranslations\` -- never force-app, never .forceignore.

    A translation folder is named "<Object>-<locale>" (object API names contain no '-',
    so the locale is everything after the FIRST '-'). Folders whose locale is NOT in
    -KeepLangs are removed. Managed-package locales such as "HealthCloudGA__iw" are
    treated as a different locale and removed (they are .forceignored anyway).

.PARAMETER KeepLangs
    Locales to keep. Default: iw, en_US (case-insensitive).

.PARAMETER DryRun
    Report what would be removed; delete nothing.

.EXAMPLE
    .\scripts\Limit-TestTranslations.ps1
    .\scripts\Limit-TestTranslations.ps1 -DryRun
#>
param(
    [string[]]$KeepLangs = @('iw', 'en_US'),
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path $PSScriptRoot -Parent
$transDir    = Join-Path $projectRoot 'test\main\default\objectTranslations'

# Safety guard: refuse to run anywhere but the test staging translations folder.
$expected = Join-Path $projectRoot 'test\main\default\objectTranslations'
if ($transDir -ne $expected) { Write-Host "SAFETY: unexpected path. Aborting." -ForegroundColor Red; exit 1 }

$dryLabel = if ($DryRun) { '  [DRY RUN]' } else { '' }
Write-Host "Limit-TestTranslations.ps1  (keep: $($KeepLangs -join ', '))$dryLabel" -ForegroundColor White

if (-not (Test-Path $transDir)) {
    Write-Host "No test/ objectTranslations folder found -- nothing to do." -ForegroundColor DarkGray
    exit 0
}

$keepSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($l in $KeepLangs) { $null = $keepSet.Add($l) }

$kept = 0; $removed = 0
foreach ($dir in @(Get-ChildItem -Path $transDir -Directory -ErrorAction SilentlyContinue)) {
    $dash = $dir.Name.IndexOf('-')
    $lang = if ($dash -gt 0 -and $dash -lt ($dir.Name.Length - 1)) { $dir.Name.Substring($dash + 1) } else { '' }
    if ($lang -ne '' -and $keepSet.Contains($lang)) {
        $kept++
    } else {
        Write-Host "  remove  $($dir.Name)  (locale: $lang)" -ForegroundColor Yellow
        if (-not $DryRun) { Remove-Item -Path $dir.FullName -Recurse -Force }
        $removed++
    }
}

Write-Host "`nKept $kept translation folder(s); removed $removed." -ForegroundColor Green
if ($DryRun) { Write-Host "(dry run -- nothing deleted)" -ForegroundColor DarkGray }
exit 0

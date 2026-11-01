#Requires -Version 5.1
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ProjectRoot   = Split-Path $PSScriptRoot -Parent
$TestBase      = Join-Path $ProjectRoot 'test\main\default'
$ForceAppBase  = Join-Path $ProjectRoot 'force-app\main\default'
$LogDate       = Get-Date -Format 'yyyy-MM-dd'
$LogFile       = Join-Path $ProjectRoot "docs\sync\sync-test-to-forceapp-$LogDate.log"

$AllowedSubs = @('compactLayouts', 'fields', 'recordTypes', 'validationRules', 'webLinks')

# Deprecated files relative to force-app/main/default/objects/
# (minus the leading "objects\" prefix -- we build the path via $ForceObjectsDir)
$DeprecatedRel = @(
    'Account\fields\Bank_Name__c.field-meta.xml',
    'Account\fields\Bank_Number__c.field-meta.xml',
    'Account\fields\payer_factor_ID__c.field-meta.xml',
    'Account\validationRules\CameleonIDCheck_number_format.validationRule-meta.xml',
    'Case\validationRules\Mandatory_Fields_For_Schedule_Corona.validationRule-meta.xml',
    'Case\validationRules\Must_fill_text_field.validationRule-meta.xml',
    'Case\validationRules\if_doc_is_known_then_link_him_to_case.validationRule-meta.xml',
    'Implants_to_med_prod__c\fields\formula_for_imp_de_kit__c.field-meta.xml',
    'Implants_to_med_prod__c\fields\formula_imp_name__c.field-meta.xml',
    'Task\validationRules\fill_surgeon_doctor_of_patient.validationRule-meta.xml'
)

$Copied  = 0
$Deleted = 0
$Skipped = 0

function Write-Log([string]$msg) {
    $line = "[$(Get-Date -Format 'HH:mm:ss')] $msg"
    Write-Host $line
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
}

$null = New-Item -ItemType Directory -Force -Path (Split-Path $LogFile)
Write-Log "=== Sync-TestToForceApp START ==="

# -------------------------------------------------------
# PHASE A -- Objects
# -------------------------------------------------------
Write-Log "--- Phase A: objects ---"

$TestObjectsDir  = Join-Path $TestBase 'objects'
$ForceObjectsDir = Join-Path $ForceAppBase 'objects'

if (Test-Path $TestObjectsDir) {
    $objDirs = Get-ChildItem -Path $TestObjectsDir -Directory
    foreach ($objDir in $objDirs) {
        $objName    = $objDir.Name
        $testObjDir = $objDir.FullName
        $faObjDir   = Join-Path $ForceObjectsDir $objName

        # Root object XML
        $rootXml = Join-Path $testObjDir "$objName.object-meta.xml"
        if (Test-Path $rootXml) {
            $null = New-Item -ItemType Directory -Force -Path $faObjDir
            Copy-Item -Path $rootXml -Destination (Join-Path $faObjDir "$objName.object-meta.xml") -Force
            Write-Log "COPY  objects/$objName/$objName.object-meta.xml"
            $Copied++
        }

        # Allowed subfolders
        foreach ($sub in $AllowedSubs) {
            $testSubDir = Join-Path $testObjDir $sub
            if (-not (Test-Path $testSubDir)) { continue }

            $faSubDir = Join-Path $faObjDir $sub
            $null = New-Item -ItemType Directory -Force -Path $faSubDir

            $subFiles = Get-ChildItem -Path $testSubDir -File
            foreach ($f in $subFiles) {
                Copy-Item -Path $f.FullName -Destination (Join-Path $faSubDir $f.Name) -Force
                Write-Log "COPY  objects/$objName/$sub/$($f.Name)"
                $Copied++
            }
        }
    }
} else {
    Write-Log "WARN: test/objects not found -- skipping Phase A"
}

# -------------------------------------------------------
# PHASE B -- Object Translations
# -------------------------------------------------------
Write-Log "--- Phase B: objectTranslations ---"

$TestTransDir  = Join-Path $TestBase 'objectTranslations'
$ForceTransDir = Join-Path $ForceAppBase 'objectTranslations'

if (Test-Path $TestTransDir) {
    $localeDirs = Get-ChildItem -Path $TestTransDir -Directory
    foreach ($localeDir in $localeDirs) {
        $folderName   = $localeDir.Name
        $faLocaleDir  = Join-Path $ForceTransDir $folderName
        $null = New-Item -ItemType Directory -Force -Path $faLocaleDir

        $transFiles = Get-ChildItem -Path $localeDir.FullName -File
        foreach ($f in $transFiles) {
            Copy-Item -Path $f.FullName -Destination (Join-Path $faLocaleDir $f.Name) -Force
            Write-Log "COPY  objectTranslations/$folderName/$($f.Name)"
            $Copied++
        }
    }
} else {
    Write-Log "WARN: test/objectTranslations not found -- skipping Phase B"
}

# -------------------------------------------------------
# PHASE C -- Delete deprecated files
# -------------------------------------------------------
Write-Log "--- Phase C: delete deprecated ---"

foreach ($rel in $DeprecatedRel) {
    $fullPath = Join-Path $ForceObjectsDir $rel
    if (Test-Path $fullPath) {
        Remove-Item -Path $fullPath -Force
        Write-Log "DELETE objects/$($rel -replace '\\','/')"
        $Deleted++
    } else {
        Write-Log "SKIP   objects/$($rel -replace '\\','/') (already absent)"
        $Skipped++
    }
}

Write-Log "=== DONE: $Copied copied, $Deleted deleted, $Skipped already-absent ==="

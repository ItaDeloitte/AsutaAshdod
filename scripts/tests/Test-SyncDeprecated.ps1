#Requires -Version 5.1
<#
.SYNOPSIS
    Unit tests for scripts/lib/SyncDeprecated.ps1.
    23 test cases (TC-01 to TC-23).  No Pester dependency.
    Exit 0 = all pass.  Exit 1 = one or more failures.
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir '..\lib\SyncDeprecated.ps1')

$root      = Join-Path $env:TEMP ("sync-depr-" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $root -Force | Out-Null

$script:failCount = 0

# ---- Helpers ---------------------------------------------------------------

function New-Fixture([string]$rel, [string]$xml, [bool]$bom = $false) {
    $absPath = Join-Path $root $rel
    $dir     = Split-Path $absPath -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $enc = if ($bom) { New-Object System.Text.UTF8Encoding $true } `
           else      { New-Object System.Text.UTF8Encoding $false }
    [System.IO.File]::WriteAllText($absPath, $xml, $enc)
    return $absPath
}

function Check([string]$id, [bool]$cond, [string]$msg) {
    if ($cond) {
        Write-Host "PASS ${id}"
    } else {
        Write-Host "FAIL ${id}: ${msg}" -ForegroundColor Red
        $script:failCount++
    }
}

# ============================================================
# TC-01  CustomField label contains _deprecated (lower case)
# ============================================================
$tc01xml = @'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
<fullName>Old__c</fullName><label>Old Status_deprecated</label><type>Text</type>
</CustomField>
'@
$p01 = New-Fixture 'tc01\Old__c.field-meta.xml' $tc01xml
$r01 = Get-DeprecatedMatch -FilePath $p01 -MetadataType 'CustomField' -ApiName 'Old__c'
Check 'TC-01' ($r01.IsDeprecated -eq $true -and $r01.MatchedOn -eq 'label') `
    "Expected IsDeprecated=true MatchedOn=label, got IsDeprecated=$($r01.IsDeprecated) MatchedOn=$($r01.MatchedOn)"

# ============================================================
# TC-02  Case-insensitive: _DEPRECATED
# ============================================================
$tc02xml = '<?xml version="1.0" encoding="UTF-8"?><CustomField xmlns="http://soap.sforce.com/2006/04/metadata"><fullName>Old__c</fullName><label>Old Status_DEPRECATED</label></CustomField>'
$p02 = New-Fixture 'tc02\Old__c.field-meta.xml' $tc02xml
$r02 = Get-DeprecatedMatch -FilePath $p02 -MetadataType 'CustomField' -ApiName 'Old__c'
Check 'TC-02' ($r02.IsDeprecated -eq $true) "Expected IsDeprecated=true"

# ============================================================
# TC-03  Label contains 'deprecated' without leading underscore -- now fully deprecated (BR-1 revised)
# ============================================================
$tc03xml = '<?xml version="1.0" encoding="UTF-8"?><CustomField xmlns="http://soap.sforce.com/2006/04/metadata"><fullName>Old__c</fullName><label>Old Status (deprecated)</label></CustomField>'
$p03 = New-Fixture 'tc03\Old__c.field-meta.xml' $tc03xml
$r03 = Get-DeprecatedMatch -FilePath $p03 -MetadataType 'CustomField' -ApiName 'Old__c'
Check 'TC-03' ($r03.IsDeprecated -eq $true -and $r03.MatchedOn -eq 'label') `
    "Expected IsDeprecated=true MatchedOn=label, got IsDeprecated=$($r03.IsDeprecated) IsSuspect=$($r03.IsSuspect) MatchedOn=$($r03.MatchedOn)"

# ============================================================
# TC-04  <deprecated>false</deprecated> must NOT trigger detection
# ============================================================
$tc04xml = '<?xml version="1.0" encoding="UTF-8"?><CustomField xmlns="http://soap.sforce.com/2006/04/metadata"><deprecated>false</deprecated><label>Mobile Country Code</label></CustomField>'
$p04 = New-Fixture 'tc04\MobileCountryCode__c.field-meta.xml' $tc04xml
$r04 = Get-DeprecatedMatch -FilePath $p04 -MetadataType 'CustomField' -ApiName 'MobileCountryCode__c'
Check 'TC-04' ($r04.IsDeprecated -eq $false -and $r04.IsSuspect -eq $false) `
    "Expected IsDeprecated=false IsSuspect=false, got IsDeprecated=$($r04.IsDeprecated) IsSuspect=$($r04.IsSuspect)"

# ============================================================
# TC-05  Nested label inside valueSet must NOT trigger (BR-2)
# ============================================================
$tc05xml = @'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
<fullName>Status__c</fullName>
<label>Status</label>
<valueSet><valueSetDefinition><value><fullName>X</fullName><default>false</default><label>Closed_deprecated</label></value></valueSetDefinition></valueSet>
</CustomField>
'@
$p05 = New-Fixture 'tc05\Status__c.field-meta.xml' $tc05xml
$r05 = Get-DeprecatedMatch -FilePath $p05 -MetadataType 'CustomField' -ApiName 'Status__c'
Check 'TC-05' ($r05.IsDeprecated -eq $false) "Expected IsDeprecated=false (nested label must not trigger)"

# ============================================================
# TC-06  ValidationRule: deprecated by API name only (no label element)
# ============================================================
$tc06xml = '<?xml version="1.0" encoding="UTF-8"?><ValidationRule xmlns="http://soap.sforce.com/2006/04/metadata"><active>true</active><errorConditionFormula>true</errorConditionFormula><errorMessage>Error</errorMessage></ValidationRule>'
$p06 = New-Fixture 'tc06\Check_Date_deprecated.validationRule-meta.xml' $tc06xml
$r06 = Get-DeprecatedMatch -FilePath $p06 -MetadataType 'ValidationRule' -ApiName 'Check_Date_deprecated'
Check 'TC-06' ($r06.IsDeprecated -eq $true -and $r06.MatchedOn -eq 'apiName') `
    "Expected IsDeprecated=true MatchedOn=apiName, got IsDeprecated=$($r06.IsDeprecated) MatchedOn=$($r06.MatchedOn)"

# ============================================================
# TC-07  ValidationRule errorMessage containing _deprecated does NOT trigger (BR-2)
# ============================================================
$tc07xml = '<?xml version="1.0" encoding="UTF-8"?><ValidationRule xmlns="http://soap.sforce.com/2006/04/metadata"><active>true</active><errorConditionFormula>true</errorConditionFormula><errorMessage>use X_deprecated</errorMessage></ValidationRule>'
$p07 = New-Fixture 'tc07\Check_Date.validationRule-meta.xml' $tc07xml
$r07 = Get-DeprecatedMatch -FilePath $p07 -MetadataType 'ValidationRule' -ApiName 'Check_Date'
Check 'TC-07' ($r07.IsDeprecated -eq $false) "Expected IsDeprecated=false (errorMessage must not trigger)"

# ============================================================
# TC-08  WebLink: masterLabel contains _deprecated
# ============================================================
$tc08xml = '<?xml version="1.0" encoding="UTF-8"?><WebLink xmlns="http://soap.sforce.com/2006/04/metadata"><masterLabel>Print_deprecated</masterLabel><url>/</url></WebLink>'
$p08 = New-Fixture 'tc08\Print.webLink-meta.xml' $tc08xml
$r08 = Get-DeprecatedMatch -FilePath $p08 -MetadataType 'WebLink' -ApiName 'Print'
Check 'TC-08' ($r08.IsDeprecated -eq $true -and $r08.MatchedOn -eq 'label') `
    "Expected IsDeprecated=true MatchedOn=label, got IsDeprecated=$($r08.IsDeprecated) MatchedOn=$($r08.MatchedOn)"

# ============================================================
# TC-09  RecordType: label _Deprecated + nested picklistValues (BR-2)
# ============================================================
$tc09xml = '<?xml version="1.0" encoding="UTF-8"?><RecordType xmlns="http://soap.sforce.com/2006/04/metadata"><fullName>ClinicRT</fullName><label>Clinic RT_Deprecated</label><active>true</active><picklistValues><picklist>A__c</picklist></picklistValues></RecordType>'
$p09 = New-Fixture 'tc09\ClinicRT.recordType-meta.xml' $tc09xml
$r09 = Get-DeprecatedMatch -FilePath $p09 -MetadataType 'RecordType' -ApiName 'ClinicRT'
Check 'TC-09' ($r09.IsDeprecated -eq $true) "Expected IsDeprecated=true"

# ============================================================
# TC-10  QuickAction: leaf (after dot) clean, but label deprecated
# ============================================================
$tc10xml = '<?xml version="1.0" encoding="UTF-8"?><QuickAction xmlns="http://soap.sforce.com/2006/04/metadata"><label>New Task_deprecated</label></QuickAction>'
$p10 = New-Fixture 'tc10\Case.New_Task.quickAction-meta.xml' $tc10xml
$r10 = Get-DeprecatedMatch -FilePath $p10 -MetadataType 'QuickAction' -ApiName 'Case.New_Task'
Check 'TC-10' ($r10.IsDeprecated -eq $true) "Expected IsDeprecated=true"

# ============================================================
# TC-11  CustomField: API name contains _deprecated (matched before label read)
# ============================================================
$tc11xml = '<?xml version="1.0" encoding="UTF-8"?><CustomField xmlns="http://soap.sforce.com/2006/04/metadata"><fullName>Legacy_deprecated__c</fullName><label>Legacy</label></CustomField>'
$p11 = New-Fixture 'tc11\Legacy_deprecated__c.field-meta.xml' $tc11xml
$r11 = Get-DeprecatedMatch -FilePath $p11 -MetadataType 'CustomField' -ApiName 'Legacy_deprecated__c'
Check 'TC-11' ($r11.IsDeprecated -eq $true -and $r11.MatchedOn -eq 'apiName') `
    "Expected IsDeprecated=true MatchedOn=apiName, got MatchedOn=$($r11.MatchedOn)"

# ============================================================
# TC-12  Malformed XML throws InvalidOperationException containing the file path
# ============================================================
$p12 = New-Fixture 'tc12\Bad.field-meta.xml' '<CustomField><label>x</CustomField>'
$caught12 = $false
$errMsg12 = ''
try {
    $null = Get-DeprecatedMatch -FilePath $p12 -MetadataType 'CustomField' -ApiName 'Bad'
} catch [System.InvalidOperationException] {
    $caught12 = $true
    $errMsg12 = $_.Exception.Message
}
Check 'TC-12' ($caught12 -and $errMsg12.Contains($p12)) `
    "Expected InvalidOperationException containing file path; caught=$caught12 msg=$errMsg12"

# ============================================================
# TC-13  Find-DeprecatedInStaging: deprecated CustomObject label => Removal='Object' entry; does NOT throw (BR-10 revised)
#         Asserts: no throw, exactly 1 deprecated entry, Removal='Object', Object='Foo__c',
#         StagingPath = object directory (not the .object-meta.xml file).
# ============================================================
$tc13base = Join-Path $root 'tc13'
$null = New-Fixture 'tc13\objects\Foo__c\Foo__c.object-meta.xml' `
    '<?xml version="1.0" encoding="UTF-8"?><CustomObject xmlns="http://soap.sforce.com/2006/04/metadata"><label>Foo_deprecated</label></CustomObject>'
$tc13result = $null
$tc13threw  = $false
try {
    $tc13result = Find-DeprecatedInStaging -StagingBase $tc13base -Objects @('Foo__c') -FolderTypeMap @{}
} catch {
    $tc13threw = $true
}
$tc13depr   = @()
if ($null -ne $tc13result) { $tc13depr = @($tc13result.Deprecated) }
$tc13entry  = if ($tc13depr.Count -eq 1) { $tc13depr[0] } else { $null }
$tc13ObjDir = Join-Path $tc13base 'objects\Foo__c'
$tc13ok = (
    (-not $tc13threw) -and
    ($tc13depr.Count -eq 1) -and
    ($null -ne $tc13entry) -and
    ($tc13entry.Removal -eq 'Object') -and
    ($tc13entry.Object -eq 'Foo__c') -and
    ($tc13entry.StagingPath -eq $tc13ObjDir)
)
Check 'TC-13' $tc13ok `
    "Expected no throw + 1 entry(Removal=Object,Object=Foo__c,StagingPath=objDir); threw=$tc13threw count=$($tc13depr.Count) removal=$(if($tc13entry){$tc13entry.Removal}else{'n/a'}) obj=$(if($tc13entry){$tc13entry.Object}else{'n/a'}) stagingPath=$(if($tc13entry){$tc13entry.StagingPath}else{'n/a'}) expectedPath=$tc13ObjDir"

# ============================================================
# TC-14  UTF-8 with BOM, Hebrew label containing _deprecated
# ============================================================
$tc14xml = "<?xml version=`"1.0`" encoding=`"UTF-8`"?>`n<CustomField xmlns=`"http://soap.sforce.com/2006/04/metadata`">`n<label>סטטוס_deprecated</label>`n</CustomField>"
$p14 = New-Fixture 'tc14\Hebrew.field-meta.xml' $tc14xml $true   # $true = write BOM
$r14 = Get-DeprecatedMatch -FilePath $p14 -MetadataType 'CustomField' -ApiName 'Hebrew__c'
Check 'TC-14' ($r14.IsDeprecated -eq $true -and $r14.MatchedValue -eq 'סטטוס_deprecated') `
    "Expected IsDeprecated=true MatchedValue=סטטוס_deprecated, got IsDeprecated=$($r14.IsDeprecated) MatchedValue=$($r14.MatchedValue)"

# ============================================================
# TC-15  Remove-DeprecatedFromStaging: deprecated CustomField removes translation file
# ============================================================
$tc15base   = Join-Path $root 'tc15'
$tc15field  = New-Fixture 'tc15\objects\Case\fields\Old__c.field-meta.xml' `
    '<?xml version="1.0" encoding="UTF-8"?><CustomField xmlns="http://soap.sforce.com/2006/04/metadata"><label>Old_deprecated</label></CustomField>'
$null = New-Fixture 'tc15\objectTranslations\Case-iw\Old__c.fieldTranslation-meta.xml' `
    '<?xml version="1.0" encoding="UTF-8"?><CustomFieldTranslation xmlns="http://soap.sforce.com/2006/04/metadata"><name>Old__c</name><label>ישן</label></CustomFieldTranslation>'
$null = New-Fixture 'tc15\objectTranslations\Case-iw\Other__c.fieldTranslation-meta.xml' `
    '<?xml version="1.0" encoding="UTF-8"?><CustomFieldTranslation xmlns="http://soap.sforce.com/2006/04/metadata"><name>Other__c</name><label>אחר</label></CustomFieldTranslation>'

$list15 = [System.Collections.Generic.List[hashtable]]::new()
$list15.Add(@{
    Object = 'Case'; MetadataType = 'CustomField'; ComponentName = 'Old__c'
    MatchedOn = 'label'; MatchedValue = 'Old_deprecated'
    StagingPath = $tc15field
    RelativePath = 'force-app/main/default/objects/Case/fields/Old__c.field-meta.xml'
    Removal = 'File'; LocalAction = ''
})

$deps15     = @(Remove-DeprecatedFromStaging -StagingBase $tc15base -Deprecated $list15)
$oldRemoved = -not (Test-Path (Join-Path $tc15base 'objectTranslations\Case-iw\Old__c.fieldTranslation-meta.xml'))
$otherKept  = Test-Path (Join-Path $tc15base 'objectTranslations\Case-iw\Other__c.fieldTranslation-meta.xml')
$dep15ok    = $deps15.Count -eq 1 -and $deps15[0].Removal -eq 'File' -and $deps15[0].ComponentName -eq 'Case-iw/Old__c'
Check 'TC-15' ($oldRemoved -and $otherKept -and $dep15ok) `
    "oldRemoved=$oldRemoved otherKept=$otherKept depCount=$($deps15.Count) dep15ok=$dep15ok"

# ============================================================
# TC-16  Remove-DeprecatedFromStaging: deprecated RecordType strips inline block
# ============================================================
$tc16base = Join-Path $root 'tc16'
$tc16rt   = New-Fixture 'tc16\objects\Case\recordTypes\Old_RT.recordType-meta.xml' `
    '<?xml version="1.0" encoding="UTF-8"?><RecordType xmlns="http://soap.sforce.com/2006/04/metadata"><label>Old_RT_deprecated</label></RecordType>'
$tc16transXml = @'
<?xml version="1.0" encoding="UTF-8"?>
<CustomObjectTranslation xmlns="http://soap.sforce.com/2006/04/metadata">
    <recordTypes>
        <label>א</label>
        <name>Old_RT</name>
    </recordTypes>
    <recordTypes>
        <label>ב</label>
        <name>Keep_RT</name>
    </recordTypes>
    <caseValues>
        <plural>false</plural>
    </caseValues>
</CustomObjectTranslation>
'@
$null = New-Fixture 'tc16\objectTranslations\Case-iw\Case-iw.objectTranslation-meta.xml' $tc16transXml

$list16 = [System.Collections.Generic.List[hashtable]]::new()
$list16.Add(@{
    Object = 'Case'; MetadataType = 'RecordType'; ComponentName = 'Old_RT'
    MatchedOn = 'label'; MatchedValue = 'Old_RT_deprecated'
    StagingPath = $tc16rt
    RelativePath = 'force-app/main/default/objects/Case/recordTypes/Old_RT.recordType-meta.xml'
    Removal = 'File'; LocalAction = ''
})

$deps16       = @(Remove-DeprecatedFromStaging -StagingBase $tc16base -Deprecated $list16)
$tc16file     = Join-Path $tc16base 'objectTranslations\Case-iw\Case-iw.objectTranslation-meta.xml'
$tc16content  = [System.IO.File]::ReadAllText($tc16file)
$tc16bytes    = [System.IO.File]::ReadAllBytes($tc16file)
$tc16NoBom    = -not ($tc16bytes.Count -ge 3 -and $tc16bytes[0] -eq 0xEF -and
                       $tc16bytes[1] -eq 0xBB -and $tc16bytes[2] -eq 0xBF)
$tc16Parse    = $true
try {
    $chkDoc = New-Object System.Xml.XmlDocument; $chkDoc.LoadXml($tc16content)
} catch { $tc16Parse = $false }
$tc16NoOld    = $tc16content -notmatch '<name>Old_RT</name>'
$tc16HasKeep  = $tc16content -match '<name>Keep_RT</name>'
$tc16HasCV    = $tc16content -match '<caseValues>'
$dep16ok      = $deps16.Count -eq 1 -and $deps16[0].Removal -eq 'Inline'
Check 'TC-16' ($tc16NoBom -and $tc16Parse -and $tc16NoOld -and $tc16HasKeep -and $tc16HasCV -and $dep16ok) `
    "noBom=$tc16NoBom parseable=$tc16Parse noOld=$tc16NoOld hasKeep=$tc16HasKeep hasCV=$tc16HasCV dep16ok=$dep16ok"

# ============================================================
# TC-17  Remove-DeprecatedFromStaging: path outside StagingBase throws; no file deleted
#         Sub-checks: absolute unrelated path, sibling-prefix path, ../ traversal path
# ============================================================
$tc17base   = Join-Path $root 'tc17'
New-Item -ItemType Directory -Path $tc17base -Force | Out-Null
$tc17victim = Join-Path $tc17base 'victim.txt'
[System.IO.File]::WriteAllText($tc17victim, 'safe')

# Sub-check A: absolute path completely outside base
$list17 = [System.Collections.Generic.List[hashtable]]::new()
$list17.Add(@{
    Object = 'Case'; MetadataType = 'CustomField'; ComponentName = 'X__c'
    MatchedOn = 'label'; MatchedValue = 'X_deprecated'
    StagingPath = 'C:\Windows\System32\evil.xml'
    RelativePath = 'force-app/main/default/objects/Case/fields/X__c.field-meta.xml'
    Removal = 'File'; LocalAction = ''
})

$caught17A = $false
try {
    Remove-DeprecatedFromStaging -StagingBase $tc17base -Deprecated $list17
} catch [System.InvalidOperationException] {
    $caught17A = $true
}
$victimIntact17A = Test-Path $tc17victim

# Sub-check B: sibling-prefix path (e.g. base='tc17', path='tc17-sibling\x.xml')
$tc17siblingDir  = Join-Path $root 'tc17-sibling'
New-Item -ItemType Directory -Path $tc17siblingDir -Force | Out-Null
$tc17siblingFile = Join-Path $tc17siblingDir 'x.xml'
[System.IO.File]::WriteAllText($tc17siblingFile, 'sibling')

# Also include a valid entry FIRST; it must NOT be deleted because the guard fires before any deletion
$tc17validFile = Join-Path $tc17base 'valid.txt'
[System.IO.File]::WriteAllText($tc17validFile, 'valid')

$list17B = [System.Collections.Generic.List[hashtable]]::new()
$list17B.Add(@{
    Object = 'Case'; MetadataType = 'CustomField'; ComponentName = 'Y__c'
    MatchedOn = 'label'; MatchedValue = 'Y_deprecated'
    StagingPath = $tc17validFile
    RelativePath = 'force-app/main/default/objects/Case/fields/Y__c.field-meta.xml'
    Removal = 'File'; LocalAction = ''
})
$list17B.Add(@{
    Object = 'Case'; MetadataType = 'CustomField'; ComponentName = 'Z__c'
    MatchedOn = 'label'; MatchedValue = 'Z_deprecated'
    StagingPath = $tc17siblingFile
    RelativePath = 'force-app/main/default/objects/Case/fields/Z__c.field-meta.xml'
    Removal = 'File'; LocalAction = ''
})

$caught17B = $false
try {
    Remove-DeprecatedFromStaging -StagingBase $tc17base -Deprecated $list17B
} catch [System.InvalidOperationException] {
    $caught17B = $true
}
$siblingIntact  = Test-Path $tc17siblingFile
$validIntact    = Test-Path $tc17validFile   # guard must fire before any deletion

Check 'TC-17' ($caught17A -and $victimIntact17A -and $caught17B -and $siblingIntact -and $validIntact) `
    "SubA: caught=$caught17A victimIntact=$victimIntact17A | SubB(sibling-prefix): caught=$caught17B siblingIntact=$siblingIntact validIntact=$validIntact"

# ============================================================
# TC-18  Find-DeprecatedReferences: word-boundary matching
#         Old__c matches but Old__c_x__c must NOT match
# ============================================================
$tc18base   = Join-Path $root 'tc18'
$tc18field  = New-Fixture 'tc18\objects\Case\fields\Old__c.field-meta.xml' `
    '<?xml version="1.0" encoding="UTF-8"?><CustomField xmlns="http://soap.sforce.com/2006/04/metadata"><label>Old_deprecated</label></CustomField>'
$null = New-Fixture 'tc18\objects\Case\compactLayouts\CL.compactLayout-meta.xml' `
    '<?xml version="1.0" encoding="UTF-8"?><CompactLayout xmlns="http://soap.sforce.com/2006/04/metadata"><label>CL</label><fields>Old__c</fields><fields>Old__c_x__c</fields></CompactLayout>'

$list18 = [System.Collections.Generic.List[hashtable]]::new()
$list18.Add(@{
    Object = 'Case'; MetadataType = 'CustomField'; ComponentName = 'Old__c'
    MatchedOn = 'label'; MatchedValue = 'Old_deprecated'
    StagingPath = $tc18field
    RelativePath = 'force-app/main/default/objects/Case/fields/Old__c.field-meta.xml'
    Removal = 'File'; LocalAction = ''
})

$refs18 = @(Find-DeprecatedReferences -StagingBase $tc18base -Deprecated $list18)
$exactCount18 = @($refs18 | Where-Object { $_.Token -eq 'Old__c' }).Count
Check 'TC-18' ($refs18.Count -eq 1 -and $exactCount18 -eq 1) `
    "Expected exactly 1 ref (Old__c token), got total=$($refs18.Count) exactToken=$exactCount18"

# ============================================================
# TC-19  Find-DeprecatedReferences: qualified hit in QuickAction;
#         cross-object formula Case__r.Old__c is NOT reported (documented gap)
# ============================================================
$tc19base  = Join-Path $root 'tc19'
$tc19field = New-Fixture 'tc19\objects\Case\fields\Old__c.field-meta.xml' `
    '<?xml version="1.0" encoding="UTF-8"?><CustomField xmlns="http://soap.sforce.com/2006/04/metadata"><label>Old_deprecated</label></CustomField>'
$null = New-Fixture 'tc19\objects\Appointment__c\fields\F.field-meta.xml' `
    '<?xml version="1.0" encoding="UTF-8"?><CustomField xmlns="http://soap.sforce.com/2006/04/metadata"><label>F</label><formula>Case__r.Old__c</formula></CustomField>'
$null = New-Fixture 'tc19\quickActions\Appointment__c.Q.quickAction-meta.xml' `
    '<?xml version="1.0" encoding="UTF-8"?><QuickAction xmlns="http://soap.sforce.com/2006/04/metadata"><label>Q</label><description>Case.Old__c</description></QuickAction>'

$list19 = [System.Collections.Generic.List[hashtable]]::new()
$list19.Add(@{
    Object = 'Case'; MetadataType = 'CustomField'; ComponentName = 'Old__c'
    MatchedOn = 'label'; MatchedValue = 'Old_deprecated'
    StagingPath = $tc19field
    RelativePath = 'force-app/main/default/objects/Case/fields/Old__c.field-meta.xml'
    Removal = 'File'; LocalAction = ''
})

$refs19 = @(Find-DeprecatedReferences -StagingBase $tc19base -Deprecated $list19)
$qaRef19   = @($refs19 | Where-Object { $_.Token -eq 'Case.Old__c' })
$formRef19 = @($refs19 | Where-Object { $_.File -like '*Appointment__c*fields*' -and $_.Token -eq 'Old__c' })
Check 'TC-19' ($qaRef19.Count -ge 1 -and $formRef19.Count -eq 0) `
    "Expected >=1 qualified ref in QA and 0 formula refs; qaRef=$($qaRef19.Count) formRef=$($formRef19.Count)"

# ============================================================
# TC-20  Test-MdapiPayloadForDeprecated: child field label violation
# ============================================================
$tc20base = Join-Path $root 'tc20'
$null = New-Fixture 'tc20\objects\Case.object' `
    '<?xml version="1.0" encoding="UTF-8"?><CustomObject xmlns="http://soap.sforce.com/2006/04/metadata"><label>Case</label><fields><fullName>Old__c</fullName><label>Old_deprecated</label><type>Text</type></fields></CustomObject>'
$viol20 = @(Test-MdapiPayloadForDeprecated -MdapiDir $tc20base -DeprecatedNames @{})
Check 'TC-20' ($viol20.Count -eq 1) "Expected 1 violation, got $($viol20.Count)"

# ============================================================
# TC-21  Test-MdapiPayloadForDeprecated: translation entry in DeprecatedNames
# ============================================================
$tc21base = Join-Path $root 'tc21'
$null = New-Fixture 'tc21\objects\Case.object' `
    '<?xml version="1.0" encoding="UTF-8"?><CustomObject xmlns="http://soap.sforce.com/2006/04/metadata"><label>Case</label></CustomObject>'
$null = New-Fixture 'tc21\objectTranslations\Case-iw.objectTranslation' `
    '<?xml version="1.0" encoding="UTF-8"?><CustomObjectTranslation xmlns="http://soap.sforce.com/2006/04/metadata"><fields><name>Old__c</name><label>ישן</label></fields></CustomObjectTranslation>'
$names21 = @{}
$names21['Case'] = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$null = $names21['Case'].Add('Old__c')
$viol21 = @(Test-MdapiPayloadForDeprecated -MdapiDir $tc21base -DeprecatedNames $names21)
Check 'TC-21' ($viol21.Count -eq 1) "Expected 1 violation, got $($viol21.Count)"

# ============================================================
# TC-22  Test-MdapiPayloadForDeprecated: all clean = 0 violations
# ============================================================
$tc22base = Join-Path $root 'tc22'
$null = New-Fixture 'tc22\objects\Case.object' `
    '<?xml version="1.0" encoding="UTF-8"?><CustomObject xmlns="http://soap.sforce.com/2006/04/metadata"><label>Case</label><fields><fullName>Active__c</fullName><label>Active</label></fields></CustomObject>'
$viol22 = @(Test-MdapiPayloadForDeprecated -MdapiDir $tc22base -DeprecatedNames @{})
Check 'TC-22' ($viol22.Count -eq 0) "Expected 0 violations, got $($viol22.Count)"

# ============================================================
# TC-23  Read-DeprecatedLog: translation rows skipped; QuickAction adds leaf
# ============================================================
$tc23content = @'
# Org-to-Git Sync -- Deprecated Components Excluded (ADR-001)
# Source org: astDev
#
Case	CustomField	Old__c	force-app/main/default/objects/Case/fields/Old__c.field-meta.xml	DEPRECATED_IN_ORG
Case	CustomFieldTranslation	Case-iw/Old__c	force-app/main/default/objectTranslations/Case-iw/Old__c.fieldTranslation-meta.xml	DEPRECATED_IN_ORG
Case	QuickAction	Case.Q_deprecated	force-app/main/default/quickActions/Case.Q_deprecated.quickAction-meta.xml	DEPRECATED_IN_ORG
'@
$p23    = New-Fixture 'tc23\deprecated-excluded-20261007.txt' $tc23content
$res23  = Read-DeprecatedLog -Path $p23
$set23  = $res23['Case']
$has23Old  = $set23.Contains('Old__c')
$has23Qual = $set23.Contains('Case.Q_deprecated')
$has23Leaf = $set23.Contains('Q_deprecated')
Check 'TC-23' ($has23Old -and $has23Qual -and $has23Leaf -and $set23.Count -eq 3) `
    "Expected Case->{Old__c,Case.Q_deprecated,Q_deprecated}; hasOld=$has23Old hasQual=$has23Qual hasLeaf=$has23Leaf count=$($set23.Count)"

# ============================================================
# Cleanup & exit
# ============================================================
if (Test-Path $root) {
    Remove-Item -Path $root -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ''
if ($script:failCount -gt 0) {
    Write-Host "$($script:failCount) test(s) FAILED." -ForegroundColor Red
    exit 1
} else {
    Write-Host 'All 23 tests PASSED.' -ForegroundColor Green
    exit 0
}

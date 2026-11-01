# Deploy-ProdFields.ps1
# Deploys specific fields/objects to production using --source-dir (avoids TypeInferenceError from HealthCloudGA objectTranslations)
# Usage: .\scripts\Deploy-ProdFields.ps1

$org = "asutaProd"
$base = "force-app/main/default"

$paths = @(
    # User fields
    "$base/objects/User/fields/Ashdod_employee__c.field-meta.xml"
    "$base/objects/User/fields/TimeZoneOffset__c.field-meta.xml"
    "$base/objects/User/fields/Site_ivf__c.field-meta.xml"
    "$base/objects/User/fields/Full_Name_Helper__c.field-meta.xml"

    # Form Titan Domain (full object)
    "$base/objects/Form_Titan_Domain__c"

    # MessagingEndUser fields
    "$base/objects/MessagingEndUser/fields/Phone_Number__c.field-meta.xml"

    # Activity fields
    "$base/objects/Activity/fields/Call_Type__c.field-meta.xml"
    "$base/objects/Activity/fields/related_account__c.field-meta.xml"
)

$sourceDirArgs = ($paths | ForEach-Object { "--source-dir `"$_`"" }) -join " "

$cmd = "sf project deploy start $sourceDirArgs --target-org $org --test-level NoTestRun"
Write-Host $cmd
Invoke-Expression $cmd

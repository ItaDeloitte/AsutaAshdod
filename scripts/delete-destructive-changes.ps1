<#
.SYNOPSIS
    Reads destructiveChanges.xml and deletes the listed metadata files from the local git repo.
.DESCRIPTION
    Parses each <types> block, maps the Salesforce metadata type to its local file path,
    and runs git rm on every matched file/directory.
    Skips members that are XML comments (already stripped by the XML parser).
#>

param(
    [string]$XmlPath  = "$PSScriptRoot\..\manifest\destructiveChanges.xml",
    [string]$ForceApp = "$PSScriptRoot\..\force-app\main\default",
    [switch]$DryRun
)

# Metadata type -> (subfolder, file extensions)
$typeMap = @{
    ApexClass                = @{ folder = "classes";           exts = @(".cls", ".cls-meta.xml") }
    ApexTrigger              = @{ folder = "triggers";          exts = @(".trigger", ".trigger-meta.xml") }
    LightningComponentBundle = @{ folder = "lwc";               exts = @() }
    AuraDefinitionBundle     = @{ folder = "aura";              exts = @() }
    Flow                     = @{ folder = "flows";             exts = @(".flow-meta.xml") }
    FlowDefinition           = @{ folder = "flowDefinitions";   exts = @(".flowDefinition-meta.xml") }
    CustomObject             = @{ folder = "objects";           exts = @() }
    Layout                   = @{ folder = "layouts";           exts = @(".layout-meta.xml") }
    PermissionSet            = @{ folder = "permissionsets";    exts = @(".permissionset-meta.xml") }
    CustomMetadata           = @{ folder = "customMetadata";    exts = @(".md-meta.xml") }
    StaticResource           = @{ folder = "staticresources";   exts = @(".resource", ".resource-meta.xml") }
    CustomLabel              = @{ folder = "labels";            exts = @(".labels-meta.xml") }
    Report                   = @{ folder = "reports";           exts = @(".report-meta.xml") }
    Dashboard                = @{ folder = "dashboards";        exts = @(".dashboard-meta.xml") }
    EmailTemplate            = @{ folder = "email";             exts = @(".email", ".email-meta.xml") }
    QuickAction              = @{ folder = "quickActions";      exts = @(".quickAction-meta.xml") }
    FlexiPage                = @{ folder = "flexipages";        exts = @(".flexipage-meta.xml") }
    CustomTab                = @{ folder = "tabs";              exts = @(".tab-meta.xml") }
    ApexComponent            = @{ folder = "components";        exts = @(".component", ".component-meta.xml") }
    ApexPage                 = @{ folder = "pages";             exts = @(".page", ".page-meta.xml") }
    SharingRules             = @{ folder = "sharingRules";      exts = @(".sharingRules-meta.xml") }
    AssignmentRules          = @{ folder = "assignmentRules";   exts = @(".assignmentRules-meta.xml") }
    Workflow                 = @{ folder = "workflows";         exts = @(".workflow-meta.xml") }
    ApprovalProcess          = @{ folder = "approvalProcesses"; exts = @(".approvalProcess-meta.xml") }
    PathAssistant            = @{ folder = "pathAssistants";    exts = @(".pathAssistant-meta.xml") }
}

# Parse XML
[xml]$pkg = Get-Content $XmlPath -Encoding UTF8

$toDelete = @()

foreach ($typeNode in $pkg.Package.types) {
    $typeName = $typeNode.name
    $members  = @($typeNode.members)

    if (-not $typeMap.ContainsKey($typeName)) {
        Write-Warning "Unknown metadata type '$typeName' - skipped. Add it to the typeMap if needed."
        continue
    }

    $mapping = $typeMap[$typeName]
    $baseDir = Join-Path $ForceApp $mapping.folder

    foreach ($member in $members) {
        if ([string]::IsNullOrWhiteSpace($member)) { continue }

        if ($mapping.exts.Count -eq 0) {
            # Whole directory (LWC, Aura, CustomObject)
            $dir = Join-Path $baseDir $member
            if (Test-Path $dir) {
                $toDelete += $dir
            } else {
                Write-Warning "Directory not found: $dir"
            }
        } else {
            foreach ($ext in $mapping.exts) {
                $file = Join-Path $baseDir "$member$ext"
                if (Test-Path $file) {
                    $toDelete += $file
                } else {
                    Write-Warning "File not found: $file"
                }
            }
        }
    }
}

# Report & Execute
if ($toDelete.Count -eq 0) {
    Write-Host "Nothing to delete." -ForegroundColor Yellow
    exit 0
}

Write-Host "`nFiles/directories to remove from git:" -ForegroundColor Cyan
$toDelete | ForEach-Object { Write-Host "  $_" }

if ($DryRun) {
    Write-Host "`n[DryRun] No changes made." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
foreach ($path in $toDelete) {
    Write-Host "git rm -r --force `"$path`"" -ForegroundColor DarkGray
    git rm -r --force $path
}

Write-Host "`nDone. Review with 'git status' before committing." -ForegroundColor Green

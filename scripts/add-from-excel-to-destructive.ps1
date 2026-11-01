param(
    [Parameter(Mandatory)]
    [string]$ExcelPath,
    [string]$XmlPath    = "$PSScriptRoot\..\manifest\destructiveChanges.xml",
    [string]$ColumnName = "Class Name",
    [string]$SheetName  = "",
    [switch]$DryRun
)

Write-Host "Opening Excel: $ExcelPath"
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

try {
    $wb = $excel.Workbooks.Open($ExcelPath)
    if ($SheetName) {
        $ws = $wb.Sheets.Item($SheetName)
    } else {
        $ws = $wb.Sheets.Item(1)
    }

    $headerRow = 1
    $lastCol   = $ws.UsedRange.Columns.Count
    $colIndex  = $null

    for ($c = 1; $c -le $lastCol; $c++) {
        if ($ws.Cells.Item($headerRow, $c).Text -eq $ColumnName) {
            $colIndex = $c
            break
        }
    }

    if (-not $colIndex) {
        Write-Error "Column '$ColumnName' not found in sheet '$($ws.Name)'."
        exit 1
    }

    Write-Host "Found column at index $colIndex in sheet '$($ws.Name)'"

    $lastRow  = $ws.UsedRange.Rows.Count
    $newNames = @()

    for ($r = $headerRow + 1; $r -le $lastRow; $r++) {
        $val = $ws.Cells.Item($r, $colIndex).Text.Trim()
        if ($val -ne "") {
            $newNames += $val
        }
    }

    $wb.Close($false)
} finally {
    $excel.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
}

if ($newNames.Count -eq 0) {
    Write-Host "No class names found." -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($newNames.Count) class name(s):"
$newNames | ForEach-Object { Write-Host "  $_" }

[xml]$pkg = Get-Content $XmlPath -Encoding UTF8

$apexTypeNode = $null
foreach ($t in $pkg.Package.types) {
    if ($t.name -eq "ApexClass") {
        $apexTypeNode = $t
        break
    }
}

$nsUri = "http://soap.sforce.com/2006/04/metadata"

if (-not $apexTypeNode) {
    Write-Host "No ApexClass types block found - creating one."
    $apexTypeNode = $pkg.CreateElement("types", $nsUri)
    $nameEl = $pkg.CreateElement("name", $nsUri)
    $nameEl.InnerText = "ApexClass"
    $apexTypeNode.AppendChild($nameEl) | Out-Null
    $pkg.Package.InsertBefore($apexTypeNode, $pkg.Package.version) | Out-Null
}

$existing = @{}
foreach ($m in @($apexTypeNode.members)) {
    if ($m) { $existing[$m] = $true }
}

$added = 0
foreach ($name in $newNames) {
    if ($existing.ContainsKey($name)) {
        Write-Host "  [skip] '$name' already present" -ForegroundColor DarkGray
        continue
    }
    $memberEl = $pkg.CreateElement("members", $nsUri)
    $memberEl.InnerText = $name
    $nameNode = $apexTypeNode.SelectSingleNode("*[local-name()='name']")
    $apexTypeNode.InsertBefore($memberEl, $nameNode) | Out-Null
    $added++
    Write-Host "  [added] $name" -ForegroundColor Green
}

if ($DryRun) {
    Write-Host "[DryRun] $added member(s) would be added. XML not saved." -ForegroundColor Yellow
    exit 0
}

if ($added -eq 0) {
    Write-Host "Nothing new to add." -ForegroundColor Yellow
    exit 0
}

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.IndentChars = "    "
$settings.Encoding = New-Object System.Text.UTF8Encoding($false)

$writer = [System.Xml.XmlWriter]::Create($XmlPath, $settings)
$pkg.Save($writer)
$writer.Close()

Write-Host "Saved $XmlPath with $added new member(s)." -ForegroundColor Green
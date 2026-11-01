#Requires -Version 5.1
<#
.SYNOPSIS
    Pure-function library for _deprecated component detection, stripping, and
    reference scanning.  ADR-001 / SPEC-001 Amendment A1.

    Rules: no exit calls, no $script: reads except the constants defined here.
    On error, functions throw [System.InvalidOperationException].
#>

Set-StrictMode -Version Latest

# ============================================================
# CONSTANTS  (Section 3.2)
# ============================================================

$script:DeprecatedRegex = New-Object System.Text.RegularExpressions.Regex(
    '_deprecated',
    ([System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor
     [System.Text.RegularExpressions.RegexOptions]::CultureInvariant))

$script:SuspectRegex = New-Object System.Text.RegularExpressions.Regex(
    'deprecated',
    ([System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor
     [System.Text.RegularExpressions.RegexOptions]::CultureInvariant))

# MDAPI type -> top-level label element ('' = no label; API-name check only)
$script:DeprecatedLabelElement = @{
    'CustomObject'   = 'label'
    'CustomField'    = 'label'
    'RecordType'     = 'label'
    'CompactLayout'  = 'label'
    'FieldSet'       = 'label'
    'Index'          = 'label'
    'WebLink'        = 'masterLabel'
    'QuickAction'    = 'label'
    'ValidationRule' = ''
}

# MDAPI type -> inline element name inside <Obj>-<lang>.objectTranslation-meta.xml
$script:TranslationInlineElement = @{
    'RecordType'     = 'recordTypes'
    'ValidationRule' = 'validationRules'
    'WebLink'        = 'webLinks'
    'FieldSet'       = 'fieldSets'
    'QuickAction'    = 'quickActions'
}

# ============================================================
# FUNCTIONS  (Section 3.3)
# ============================================================

function Read-SyncXml([string]$Path, [bool]$PreserveWhitespace = $false) {
    $doc = New-Object System.Xml.XmlDocument
    $doc.PreserveWhitespace = $PreserveWhitespace
    $doc.XmlResolver = $null
    try {
        $doc.Load($Path)
    } catch {
        throw (New-Object System.InvalidOperationException(
            "XML parse failed: $Path -- $($_.Exception.Message)"))
    }
    return ,$doc
}

function Get-TopLevelText([System.Xml.XmlDocument]$Doc, [string]$LocalName) {
    foreach ($node in $Doc.DocumentElement.ChildNodes) {
        if ($node.NodeType -eq [System.Xml.XmlNodeType]::Element -and
            $node.LocalName -eq $LocalName) {
            return $node.InnerText.Trim()
        }
    }
    return $null
}

function ConvertTo-SyncApiName([string]$FileName) {
    if ($FileName -match '^(?<n>.+)\.[A-Za-z]+-meta\.xml$') {
        return $Matches['n']
    } else {
        return $FileName
    }
}

function Get-DeprecatedMatch([string]$FilePath, [string]$MetadataType, [string]$ApiName) {
    if (-not $script:DeprecatedLabelElement.ContainsKey($MetadataType)) {
        throw [System.InvalidOperationException]::new(
            "Unsupported MetadataType '$MetadataType' in Get-DeprecatedMatch.")
    }

    # Compute leaf (for QuickAction, part after first '.')
    $leaf = $ApiName
    if ($MetadataType -eq 'QuickAction' -and $ApiName.Contains('.')) {
        $leaf = $ApiName.Substring($ApiName.IndexOf('.') + 1)
    }

    # Check API name first
    if ($script:DeprecatedRegex.IsMatch($leaf)) {
        return [pscustomobject]@{
            IsDeprecated = $true
            IsSuspect    = $false
            MatchedOn    = 'apiName'
            MatchedValue = $ApiName
        }
    }

    # Load XML (throws on parse failure per BR-11)
    $doc = Read-SyncXml -Path $FilePath

    $el = $script:DeprecatedLabelElement[$MetadataType]
    $isSuspect   = $false
    $suspectOn   = ''
    $suspectVal  = ''

    if ($el -ne '') {
        $labelText = Get-TopLevelText -Doc $doc -LocalName $el
        # Label check uses SuspectRegex (matches 'deprecated' anywhere, case-insensitive).
        # "BIRAD Deprecated", "Surgery Deprecated" etc. are fully deprecated, not just suspect.
        # Description-based matches remain suspect-only (see below).
        if ($null -ne $labelText -and $script:SuspectRegex.IsMatch($labelText)) {
            return [pscustomobject]@{
                IsDeprecated = $true
                IsSuspect    = $false
                MatchedOn    = 'label'
                MatchedValue = $labelText
            }
        }
    }

    if (-not $isSuspect) {
        $descText = Get-TopLevelText -Doc $doc -LocalName 'description'
        if ($null -ne $descText -and $script:DeprecatedRegex.IsMatch($descText)) {
            $isSuspect  = $true
            $suspectOn  = 'description'
            $suspectVal = if ($descText.Length -gt 120) { $descText.Substring(0, 120) } else { $descText }
        }
    }

    if (-not $isSuspect -and $script:SuspectRegex.IsMatch($leaf)) {
        $isSuspect  = $true
        $suspectOn  = 'apiName'
        $suspectVal = $ApiName
    }

    return [pscustomobject]@{
        IsDeprecated = $false
        IsSuspect    = $isSuspect
        MatchedOn    = $suspectOn
        MatchedValue = $suspectVal
    }
}

function Find-DeprecatedInStaging(
    [string]$StagingBase,
    [string[]]$Objects,
    [System.Collections.IDictionary]$FolderTypeMap) {

    $deprecated = [System.Collections.Generic.List[hashtable]]::new()
    $suspect    = [System.Collections.Generic.List[hashtable]]::new()

    foreach ($O in $Objects) {

        # 1. Object-meta.xml  -- if the object itself is deprecated, strip the whole dir and skip children.
        $objMetaPath = Join-Path $StagingBase "objects\$O\$O.object-meta.xml"
        if (Test-Path $objMetaPath) {
            $objMatch = Get-DeprecatedMatch -FilePath $objMetaPath -MetadataType 'CustomObject' -ApiName $O
            if ($objMatch.IsDeprecated) {
                $deprecated.Add(@{
                    Object        = $O
                    MetadataType  = 'CustomObject'
                    ComponentName = $O
                    MatchedOn     = $objMatch.MatchedOn
                    MatchedValue  = $objMatch.MatchedValue
                    StagingPath   = (Join-Path $StagingBase "objects\$O")
                    RelativePath  = "force-app/main/default/objects/$O"
                    Removal       = 'Object'
                    LocalAction   = ''
                })
                continue
            }
        }

        # 2. Each subfolder defined in FolderTypeMap
        foreach ($folder in $FolderTypeMap.Keys) {
            $mdType = $FolderTypeMap[$folder]
            $subDir = Join-Path $StagingBase "objects\$O\$folder"
            if (-not (Test-Path $subDir)) { continue }

            $files = @(Get-ChildItem -Path $subDir -File -Filter '*-meta.xml' -ErrorAction SilentlyContinue)
            foreach ($f in $files) {
                $apiName    = ConvertTo-SyncApiName $f.Name
                $matchResult = Get-DeprecatedMatch -FilePath $f.FullName -MetadataType $mdType -ApiName $apiName
                $relProj    = "force-app/main/default/objects/$O/$folder/$($f.Name)"

                if ($matchResult.IsDeprecated) {
                    $deprecated.Add(@{
                        Object        = $O
                        MetadataType  = $mdType
                        ComponentName = $apiName
                        MatchedOn     = $matchResult.MatchedOn
                        MatchedValue  = $matchResult.MatchedValue
                        StagingPath   = $f.FullName
                        RelativePath  = $relProj
                        Removal       = 'File'
                        LocalAction   = ''
                    })
                } elseif ($matchResult.IsSuspect) {
                    $suspect.Add(@{
                        Object        = $O
                        MetadataType  = $mdType
                        ComponentName = $apiName
                        MatchedOn     = $matchResult.MatchedOn
                        MatchedValue  = $matchResult.MatchedValue
                        StagingPath   = $f.FullName
                        RelativePath  = $relProj
                        Removal       = 'File'
                        LocalAction   = ''
                    })
                }
            }
        }

        # 3. QuickActions for this object
        $qaDir = Join-Path $StagingBase 'quickActions'
        if (Test-Path $qaDir) {
            $qaFiles = @(Get-ChildItem -Path $qaDir -File `
                -Filter "$O.*.quickAction-meta.xml" -ErrorAction SilentlyContinue)
            foreach ($f in $qaFiles) {
                $apiName     = ConvertTo-SyncApiName $f.Name
                $matchResult = Get-DeprecatedMatch -FilePath $f.FullName -MetadataType 'QuickAction' -ApiName $apiName
                $relProj     = "force-app/main/default/quickActions/$($f.Name)"

                if ($matchResult.IsDeprecated) {
                    $deprecated.Add(@{
                        Object        = $O
                        MetadataType  = 'QuickAction'
                        ComponentName = $apiName
                        MatchedOn     = $matchResult.MatchedOn
                        MatchedValue  = $matchResult.MatchedValue
                        StagingPath   = $f.FullName
                        RelativePath  = $relProj
                        Removal       = 'File'
                        LocalAction   = ''
                    })
                } elseif ($matchResult.IsSuspect) {
                    $suspect.Add(@{
                        Object        = $O
                        MetadataType  = 'QuickAction'
                        ComponentName = $apiName
                        MatchedOn     = $matchResult.MatchedOn
                        MatchedValue  = $matchResult.MatchedValue
                        StagingPath   = $f.FullName
                        RelativePath  = $relProj
                        Removal       = 'File'
                        LocalAction   = ''
                    })
                }
            }
        }
    }

    return [pscustomobject]@{ Deprecated = $deprecated; Suspect = $suspect }
}

function Remove-DeprecatedFromStaging(
    [string]$StagingBase,
    [System.Collections.Generic.List[hashtable]]$Deprecated) {

    $dependents = [System.Collections.Generic.List[hashtable]]::new()

    # Safety guard: all paths must be inside StagingBase before any deletion.
    # Normalize both sides to prevent sibling-prefix and ../ traversal bypasses.
    $normalBase = [System.IO.Path]::GetFullPath($StagingBase).TrimEnd('\') + '\'
    foreach ($D in $Deprecated) {
        $normalPath = [System.IO.Path]::GetFullPath($D.StagingPath)
        if (-not $normalPath.StartsWith($normalBase, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw [System.InvalidOperationException]::new(
                "Safety guard: path '$($D.StagingPath)' is outside staging base '$StagingBase'")
        }
    }

    foreach ($D in $Deprecated) {
        # Whole-object deprecation: remove the entire object directory, no translation dependents.
        if ($D.Removal -eq 'Object') {
            if (Test-Path $D.StagingPath) {
                Remove-Item $D.StagingPath -Recurse -Force
            }
            continue
        }

        # Remove the component file
        if (Test-Path $D.StagingPath) {
            Remove-Item $D.StagingPath -Force
        }

        # Collect translation language dirs for this object
        $transDirs = @()
        $transBaseDir = Join-Path $StagingBase 'objectTranslations'
        if (Test-Path $transBaseDir) {
            $transDirs = @(Get-ChildItem $transBaseDir -Directory `
                -Filter "$($D.Object)-*" -ErrorAction SilentlyContinue)
        }

        if ($D.MetadataType -eq 'CustomField') {
            # BR-5: Remove matching .fieldTranslation-meta.xml files
            foreach ($dir in $transDirs) {
                $transFile = Join-Path $dir.FullName "$($D.ComponentName).fieldTranslation-meta.xml"
                if (-not (Test-Path $transFile)) { continue }
                $transDoc  = Read-SyncXml -Path $transFile
                $nameText  = Get-TopLevelText -Doc $transDoc -LocalName 'name'
                if ($null -ne $nameText -and
                    [string]::Compare($nameText, $D.ComponentName, [System.StringComparison]::OrdinalIgnoreCase) -eq 0) {
                    Remove-Item $transFile -Force
                    $relProj = "force-app/main/default/objectTranslations/$($dir.Name)/$($D.ComponentName).fieldTranslation-meta.xml"
                    $dependents.Add(@{
                        Object        = $D.Object
                        MetadataType  = 'CustomFieldTranslation'
                        ComponentName = "$($dir.Name)/$($D.ComponentName)"
                        MatchedOn     = 'dependent'
                        MatchedValue  = "$($D.Object).$($D.ComponentName)"
                        StagingPath   = $transFile
                        RelativePath  = $relProj
                        Removal       = 'File'
                        LocalAction   = ''
                    })
                }
            }

        } elseif ($script:TranslationInlineElement.ContainsKey($D.MetadataType)) {
            # BR-6: Strip inline blocks from objectTranslation files
            $elemName = $script:TranslationInlineElement[$D.MetadataType]
            $leaf = $D.ComponentName
            if ($D.MetadataType -eq 'QuickAction' -and $D.ComponentName.Contains('.')) {
                $leaf = $D.ComponentName.Substring($D.ComponentName.IndexOf('.') + 1)
            }
            $candidates = @($leaf, "$($D.Object).$leaf")

            foreach ($dir in $transDirs) {
                $transFile = Join-Path $dir.FullName "$($dir.Name).objectTranslation-meta.xml"
                if (-not (Test-Path $transFile)) { continue }

                $doc     = Read-SyncXml -Path $transFile -PreserveWhitespace $true
                $removed = 0

                # Snapshot child list to safely remove during iteration
                $childList = @($doc.DocumentElement.ChildNodes)
                foreach ($child in $childList) {
                    if ($child.NodeType -ne [System.Xml.XmlNodeType]::Element) { continue }
                    if ($child.LocalName -ne $elemName) { continue }

                    # Get the <name> grandchild text
                    $nameText = $null
                    foreach ($gc in $child.ChildNodes) {
                        if ($gc.NodeType -eq [System.Xml.XmlNodeType]::Element -and
                            $gc.LocalName -eq 'name') {
                            $nameText = $gc.InnerText.Trim()
                            break
                        }
                    }

                    $matched = $false
                    foreach ($c in $candidates) {
                        if ([string]::Compare($nameText, $c, [System.StringComparison]::OrdinalIgnoreCase) -eq 0) {
                            $matched = $true; break
                        }
                    }
                    if (-not $matched) { continue }

                    # Remove preceding whitespace text node
                    $prev = $child.PreviousSibling
                    if ($null -ne $prev -and
                        ($prev.NodeType -eq [System.Xml.XmlNodeType]::Whitespace -or
                         $prev.NodeType -eq [System.Xml.XmlNodeType]::SignificantWhitespace)) {
                        $null = $doc.DocumentElement.RemoveChild($prev)
                    }
                    $null = $doc.DocumentElement.RemoveChild($child)
                    $removed++

                    $relProj = "force-app/main/default/objectTranslations/$($dir.Name)/$($dir.Name).objectTranslation-meta.xml"
                    $dependents.Add(@{
                        Object        = $D.Object
                        MetadataType  = 'CustomObjectTranslationEntry'
                        ComponentName = "$($dir.Name):$elemName/$leaf"
                        MatchedOn     = 'dependent'
                        MatchedValue  = "$($D.Object).$leaf"
                        StagingPath   = $transFile
                        RelativePath  = $relProj
                        Removal       = 'Inline'
                        LocalAction   = ''
                    })
                }

                if ($removed -gt 0) {
                    $content = $doc.OuterXml.Replace("`r`n", "`n") + "`n"
                    $enc = New-Object System.Text.UTF8Encoding $false
                    [System.IO.File]::WriteAllText($transFile, $content, $enc)
                }
            }
        }
        # CompactLayout, Index: no translation handling needed
    }

    return $dependents
}

function Find-DeprecatedReferences(
    [string]$StagingBase,
    [System.Collections.Generic.List[hashtable]]$Deprecated) {

    $refs       = [System.Collections.Generic.List[hashtable]]::new()
    $dedupeKeys = [System.Collections.Generic.HashSet[string]]::new()
    $fileCache  = @{}

    # Only File-removal entries that are not translation types
    $candidates = @($Deprecated | Where-Object {
        $_.Removal -eq 'File' -and
        $_.MetadataType -notlike '*Translation*'
    })
    if ($candidates.Count -eq 0) { return $refs }

    foreach ($D in $candidates) {
        $O    = $D.Object
        $leaf = $D.ComponentName
        if ($D.MetadataType -eq 'QuickAction' -and $D.ComponentName.Contains('.')) {
            $leaf = $D.ComponentName.Substring($D.ComponentName.IndexOf('.') + 1)
        }

        $leafEsc = [System.Text.RegularExpressions.Regex]::Escape($leaf)
        $leafPattern = "(?<![A-Za-z0-9_])$leafEsc(?![A-Za-z0-9_])"
        $leafRegex   = New-Object System.Text.RegularExpressions.Regex(
            $leafPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

        $qualEsc     = [System.Text.RegularExpressions.Regex]::Escape($O)
        $qualPattern = "(?<![A-Za-z0-9_])$qualEsc\.$leafEsc(?![A-Za-z0-9_])"
        $qualRegex   = New-Object System.Text.RegularExpressions.Regex(
            $qualPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

        # --- Same-object scan ---
        $sameObjFiles = [System.Collections.Generic.List[string]]::new()

        $objDir = Join-Path $StagingBase "objects\$O"
        if (Test-Path $objDir) {
            @(Get-ChildItem $objDir -Recurse -File -ErrorAction SilentlyContinue) |
                ForEach-Object { $sameObjFiles.Add($_.FullName) }
        }
        $qaDir = Join-Path $StagingBase 'quickActions'
        if (Test-Path $qaDir) {
            @(Get-ChildItem $qaDir -File -Filter "$O.*" -ErrorAction SilentlyContinue) |
                ForEach-Object { $sameObjFiles.Add($_.FullName) }
        }
        $transBaseDir = Join-Path $StagingBase 'objectTranslations'
        if (Test-Path $transBaseDir) {
            @(Get-ChildItem $transBaseDir -Directory -Filter "$O-*" -ErrorAction SilentlyContinue) |
                ForEach-Object {
                    $tDir = $_
                    @(Get-ChildItem $tDir.FullName -Recurse -File -ErrorAction SilentlyContinue) |
                        ForEach-Object { $sameObjFiles.Add($_.FullName) }
                }
        }

        foreach ($fp in $sameObjFiles) {
            if ($fp -eq $D.StagingPath) { continue }
            if (-not $fileCache.ContainsKey($fp)) {
                try {
                    $fileCache[$fp] = @([System.IO.File]::ReadAllLines($fp, [System.Text.Encoding]::UTF8))
                } catch {
                    $fileCache[$fp] = @()
                }
            }
            $lines = $fileCache[$fp]
            for ($i = 0; $i -lt $lines.Count; $i++) {
                if ($leafRegex.IsMatch($lines[$i])) {
                    $projRel = 'force-app/main/default/' +
                        $fp.Substring($StagingBase.Length).TrimStart('\').TrimStart('/').Replace('\', '/')
                    $key = "$fp`t$($i + 1)`t$leaf"
                    if ($dedupeKeys.Add($key)) {
                        $refs.Add(@{ File = $projRel; Line = ($i + 1); Token = $leaf; Object = $O })
                    }
                }
            }
        }

        # --- Qualified scan: every staged file ---
        $allFiles = @(Get-ChildItem $StagingBase -Recurse -File -ErrorAction SilentlyContinue)
        foreach ($f in $allFiles) {
            $fp = $f.FullName
            if ($fp -eq $D.StagingPath) { continue }
            if (-not $fileCache.ContainsKey($fp)) {
                try {
                    $fileCache[$fp] = @([System.IO.File]::ReadAllLines($fp, [System.Text.Encoding]::UTF8))
                } catch {
                    $fileCache[$fp] = @()
                }
            }
            $lines = $fileCache[$fp]
            for ($i = 0; $i -lt $lines.Count; $i++) {
                if ($qualRegex.IsMatch($lines[$i])) {
                    $projRel = 'force-app/main/default/' +
                        $fp.Substring($StagingBase.Length).TrimStart('\').TrimStart('/').Replace('\', '/')
                    $token = "$O.$leaf"
                    $key   = "$fp`t$($i + 1)`t$token"
                    if ($dedupeKeys.Add($key)) {
                        $refs.Add(@{ File = $projRel; Line = ($i + 1); Token = $token; Object = $O })
                    }
                }
            }
        }
    }

    return $refs
}

function Read-DeprecatedLog([string]$Path) {
    $result = @{}
    foreach ($line in @(Get-Content -Path $Path -Encoding UTF8)) {
        if ($line.StartsWith('#') -or [string]::IsNullOrWhiteSpace($line)) { continue }
        $cols = $line -split "`t"
        if ($cols.Count -lt 3) { continue }
        $objName  = $cols[0].Trim()
        $mdType   = $cols[1].Trim()
        $compName = $cols[2].Trim()

        # Skip translation types (BR in Read-DeprecatedLog)
        if ($mdType.EndsWith('Translation') -or $mdType.EndsWith('TranslationEntry')) { continue }

        if (-not $result.ContainsKey($objName)) {
            $result[$objName] = [System.Collections.Generic.HashSet[string]]::new(
                [System.StringComparer]::OrdinalIgnoreCase)
        }
        $null = $result[$objName].Add($compName)

        # For QuickAction, also add the leaf segment after the first '.'
        if ($mdType -eq 'QuickAction' -and $compName.Contains('.')) {
            $leafPart = $compName.Substring($compName.IndexOf('.') + 1)
            $null = $result[$objName].Add($leafPart)
        }
    }
    return $result
}

function Test-MdapiPayloadForDeprecated([string]$MdapiDir, [hashtable]$DeprecatedNames) {
    $violations   = [System.Collections.Generic.List[string]]::new()
    $childTypeSet = @('fields', 'recordTypes', 'validationRules', 'compactLayouts',
                      'fieldSets', 'webLinks', 'indexes', 'listViews')

    # --- Objects ---
    $objDir = Join-Path $MdapiDir 'objects'
    if (Test-Path $objDir) {
        $objFiles = @(Get-ChildItem $objDir -File -Filter '*.object' -ErrorAction SilentlyContinue)
        foreach ($objFile in $objFiles) {
            $O   = [System.IO.Path]::GetFileNameWithoutExtension($objFile.Name)
            $doc = Read-SyncXml -Path $objFile.FullName

            # Root label
            $rootLabel = Get-TopLevelText -Doc $doc -LocalName 'label'
            if ($null -ne $rootLabel -and $script:DeprecatedRegex.IsMatch($rootLabel)) {
                $violations.Add("$($objFile.Name): root label '$rootLabel'")
            }

            # Child element checks
            foreach ($child in @($doc.DocumentElement.ChildNodes)) {
                if ($child.NodeType -ne [System.Xml.XmlNodeType]::Element) { continue }
                if (-not ($childTypeSet -contains $child.LocalName)) { continue }

                $fullName  = $null
                $labelName = if ($child.LocalName -eq 'webLinks') { 'masterLabel' } else { 'label' }
                $labelVal  = $null

                foreach ($gc in $child.ChildNodes) {
                    if ($gc.NodeType -ne [System.Xml.XmlNodeType]::Element) { continue }
                    if ($gc.LocalName -eq 'fullName' -and $null -eq $fullName) {
                        $fullName = $gc.InnerText.Trim()
                    }
                    if ($gc.LocalName -eq $labelName -and $null -eq $labelVal) {
                        $labelVal = $gc.InnerText.Trim()
                    }
                }

                if ($null -ne $labelVal -and $script:DeprecatedRegex.IsMatch($labelVal)) {
                    $violations.Add("$($objFile.Name): $($child.LocalName)/$fullName label '$labelVal'")
                } elseif ($null -ne $fullName -and $script:DeprecatedRegex.IsMatch($fullName)) {
                    $violations.Add("$($objFile.Name): $($child.LocalName)/$fullName")
                } elseif ($null -ne $fullName -and
                          $DeprecatedNames.ContainsKey($O) -and
                          $DeprecatedNames[$O].Contains($fullName)) {
                    $violations.Add("$($objFile.Name): $($child.LocalName)/$fullName (in deprecated log)")
                }
            }
        }
    }

    # --- QuickActions ---
    $qaDir = Join-Path $MdapiDir 'quickActions'
    if (Test-Path $qaDir) {
        $qaFiles = @(Get-ChildItem $qaDir -File -Filter '*.quickAction' -ErrorAction SilentlyContinue)
        foreach ($qaFile in $qaFiles) {
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($qaFile.Name)
            $dotIdx   = $baseName.IndexOf('.')
            $prefix   = if ($dotIdx -gt 0) { $baseName.Substring(0, $dotIdx) } else { '' }
            $segment  = if ($dotIdx -gt 0) { $baseName.Substring($dotIdx + 1) } else { $baseName }

            $doc      = Read-SyncXml -Path $qaFile.FullName
            $labelVal = Get-TopLevelText -Doc $doc -LocalName 'label'

            if ($script:DeprecatedRegex.IsMatch($segment)) {
                $violations.Add("$($qaFile.Name): API name segment '$segment'")
            } elseif ($null -ne $labelVal -and $script:DeprecatedRegex.IsMatch($labelVal)) {
                $violations.Add("$($qaFile.Name): label '$labelVal'")
            } elseif ($prefix -ne '' -and
                      $DeprecatedNames.ContainsKey($prefix) -and
                      $DeprecatedNames[$prefix].Contains($segment)) {
                $violations.Add("$($qaFile.Name): '$segment' (in deprecated log)")
            }
        }
    }

    # --- ObjectTranslations ---
    $transDir = Join-Path $MdapiDir 'objectTranslations'
    if (Test-Path $transDir) {
        $transFiles = @(Get-ChildItem $transDir -File -Filter '*.objectTranslation' -ErrorAction SilentlyContinue)
        foreach ($transFile in $transFiles) {
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($transFile.Name)
            $dashIdx  = $baseName.IndexOf('-')
            $O        = if ($dashIdx -gt 0) { $baseName.Substring(0, $dashIdx) } else { $baseName }

            if (-not $DeprecatedNames.ContainsKey($O)) { continue }

            $doc = Read-SyncXml -Path $transFile.FullName
            foreach ($child in @($doc.DocumentElement.ChildNodes)) {
                if ($child.NodeType -ne [System.Xml.XmlNodeType]::Element) { continue }
                $nameText = $null
                foreach ($gc in $child.ChildNodes) {
                    if ($gc.NodeType -eq [System.Xml.XmlNodeType]::Element -and
                        $gc.LocalName -eq 'name') {
                        $nameText = $gc.InnerText.Trim(); break
                    }
                }
                if ($null -ne $nameText -and $DeprecatedNames[$O].Contains($nameText)) {
                    $violations.Add("$($transFile.Name): $($child.LocalName) '$nameText' (in deprecated log)")
                }
            }
        }
    }

    return $violations
}

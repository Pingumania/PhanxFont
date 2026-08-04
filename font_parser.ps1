<#
.SYNOPSIS
Prints the SetFont block for Addon.lua from Blizzard's font XML.

.EXAMPLE
.\font_parser.ps1 -SourcePath ..\wow-ui-source > fonts.txt

.EXAMPLE
.\font_parser.ps1 -Diff
#>
[CmdletBinding()]
param(
    [string] $SourcePath = (Join-Path $PSScriptRoot ".." | Join-Path -ChildPath "wow-ui-source"),
    [string] $AddonPath = (Join-Path $PSScriptRoot "Addon.lua"),
    [int] $NameColumn = 42,
    [switch] $Diff
)

$ErrorActionPreference = "Stop"

$files = @(
    "Interface\AddOns\Blizzard_Fonts_Shared\Shared\Fonts.xml"
    "Interface\AddOns\Blizzard_Fonts_Shared\Shared\GameFonts.xml"
    "Interface\AddOns\Blizzard_Fonts_Shared\Mainline\Fonts.xml"
    "Interface\AddOns\Blizzard_Fonts_Shared\Mainline\GameFonts.xml"
    "Interface\AddOns\Blizzard_ObjectiveTracker\Blizzard_ObjectiveTrackerFonts.xml"
)

$outlines = @{
    "NORMAL" = "OUTLINE"
    "THICK"  = "THICKOUTLINE"
}

function Get-Value
{
    param($Node, [string] $Attribute)

    if (-not $Node) { return "nil" }

    $value = $Node.GetAttribute($Attribute)
    if ([string]::IsNullOrEmpty($value)) { return "nil" }

    return $value
}

$fonts = [ordered]@{}

foreach ($file in $files)
{
    $path = Join-Path $SourcePath $file
    if (-not (Test-Path -LiteralPath $path))
    {
        Write-Warning "Not found, skipping: $path"
        continue
    }

    $document = New-Object System.Xml.XmlDocument
    $document.Load((Resolve-Path -LiteralPath $path))

    $namespace = New-Object Xml.XmlNamespaceManager($document.NameTable)
    $namespace.AddNamespace("ns", "http://www.blizzard.com/wow/ui/")

    foreach ($family in $document.SelectNodes("//ns:FontFamily", $namespace))
    {
        $name = $family.GetAttribute("name")
        $font = $family.SelectSingleNode("./ns:Member[@alphabet='roman']/ns:Font", $namespace)
        if (-not $font)
        {
            Write-Warning "No roman member, skipping: $name"
            continue
        }

        $color = $font.SelectSingleNode("./ns:Color", $namespace)
        $shadow = $font.SelectSingleNode("./ns:Shadow", $namespace)
        $shadowColor = $font.SelectSingleNode("./ns:Shadow/ns:Color", $namespace)

        $shadowOffset = $font.SelectSingleNode("./ns:Shadow/ns:Offset/ns:AbsDimension", $namespace)
        if (-not $shadowOffset -and $shadow -and $shadow.HasAttribute("x"))
        {
            $shadowOffset = $shadow
        }

        $style = $outlines[$font.GetAttribute("outline")]
        if (-not $style) { $style = "" }

        $fonts[$name] = [pscustomobject]@{
            Height        = Get-Value $font "height"
            Style         = $style
            ColorR        = Get-Value $color "r"
            ColorG        = Get-Value $color "g"
            ColorB        = Get-Value $color "b"
            ShadowColorR  = Get-Value $shadowColor "r"
            ShadowColorG  = Get-Value $shadowColor "g"
            ShadowColorB  = Get-Value $shadowColor "b"
            ShadowOffsetX = Get-Value $shadowOffset "x"
            ShadowOffsetY = Get-Value $shadowOffset "y"
        }
    }
}

if ($fonts.Count -eq 0)
{
    throw "No font families found under $SourcePath"
}

$longestName = ($fonts.Keys | Measure-Object -Property Length -Maximum).Maximum
$column = [Math]::Max($NameColumn, $longestName + 1)

$lines = [ordered]@{}

foreach ($name in ($fonts.Keys | Sort-Object))
{
    $font = $fonts[$name]
    $padding = " " * ($column - $name.Length)

    $lines[$name] = "`tself:SetFont({0},{1}NORMAL, {2}, `"{3}`", {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11})" -f `
        $name, $padding, $font.Height, $font.Style,
        $font.ColorR, $font.ColorG, $font.ColorB,
        $font.ShadowColorR, $font.ShadowColorG, $font.ShadowColorB,
        $font.ShadowOffsetX, $font.ShadowOffsetY
}

if (-not $Diff)
{
    $lines.Values | Write-Output
    return
}

if (-not (Test-Path -LiteralPath $AddonPath))
{
    throw "Not found: $AddonPath"
}

$current = [ordered]@{}

foreach ($line in (Get-Content -LiteralPath $AddonPath))
{
    if ($line -match "^\s*self:SetFont\((\w+),")
    {
        $current[$Matches[1]] = $line.TrimEnd()
    }
}

$added = $lines.Keys | Where-Object { -not $current.Contains($_) }
$removed = $current.Keys | Where-Object { -not $lines.Contains($_) }
$changed = $lines.Keys | Where-Object { $current.Contains($_) -and $current[$_] -ne $lines[$_] }

Write-Output ("Added ({0}), in the XML but not in {1}:" -f @($added).Count, (Split-Path -Leaf $AddonPath))
foreach ($name in $added) { Write-Output $lines[$name] }

Write-Output ""
Write-Output ("Removed ({0}), no longer in the XML:" -f @($removed).Count)
foreach ($name in $removed) { Write-Output $current[$name] }

Write-Output ""
Write-Output ("Changed ({0}):" -f @($changed).Count)
foreach ($name in $changed)
{
    Write-Output ("  now: {0}" -f $current[$name].Trim())
    Write-Output ("  new: {0}" -f $lines[$name].Trim())
}

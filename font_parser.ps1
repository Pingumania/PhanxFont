<#
.SYNOPSIS
Writes FontObjects.lua from Blizzard's font XML on GitHub.

.EXAMPLE
.\font_parser.ps1

.EXAMPLE
.\font_parser.ps1 -Diff
#>
[CmdletBinding()]
param(
    [string] $Branch = "live",
    [string] $OutputPath = (Join-Path $PSScriptRoot "FontObjects.lua"),
    [switch] $Diff
)

$ErrorActionPreference = "Stop"

$baseUrl = "https://raw.githubusercontent.com/Gethe/wow-ui-source/$Branch/Interface/AddOns"

$files = @(
    "Blizzard_Fonts_Shared/Shared/Fonts.xml"
    "Blizzard_Fonts_Shared/Shared/FontStyles.xml"
    "Blizzard_Fonts_Shared/Shared/GameFonts.xml"
    "Blizzard_Fonts_Shared/Shared/GameFontStyles.xml"
    "Blizzard_Fonts_Shared/Mainline/Fonts.xml"
    "Blizzard_Fonts_Shared/Mainline/FontStyles.xml"
    "Blizzard_Fonts_Shared/Mainline/GameFonts.xml"
    "Blizzard_Fonts_Shared/Mainline/GameFontStyles.xml"
    "Blizzard_ObjectiveTracker/Blizzard_ObjectiveTrackerFonts.xml"
)

$objects = @{}
$fixedSize = @{}
$inherits = @{}

foreach ($file in $files)
{
    $url = "$baseUrl/$file"

    try
    {
        $content = (Invoke-WebRequest -Uri $url -UseBasicParsing).Content
    }
    catch
    {
        Write-Warning "Could not fetch, skipping: $url"
        continue
    }

    $document = New-Object System.Xml.XmlDocument
    $document.LoadXml($content)

    $namespace = New-Object Xml.XmlNamespaceManager($document.NameTable)
    $namespace.AddNamespace("ns", "http://www.blizzard.com/wow/ui/")

    foreach ($family in $document.SelectNodes("//ns:FontFamily[@name]", $namespace))
    {
        $name = $family.GetAttribute("name")
        $objects[$name] = $true

        $font = $family.SelectSingleNode("./ns:Member[@alphabet='roman']/ns:Font", $namespace)
        if ($font -and $font.GetAttribute("fixedSize") -eq "true")
        {
            $fixedSize[$name] = $true
        }
    }

    foreach ($font in $document.SelectNodes("//ns:Font[@name]", $namespace))
    {
        $name = $font.GetAttribute("name")

        if (-not $objects.ContainsKey($name))
        {
            $objects[$name] = $false
        }

        if ($font.GetAttribute("fixedSize") -eq "true")
        {
            $fixedSize[$name] = $true
        }

        $parent = $font.GetAttribute("inherits")
        if ($parent)
        {
            $inherits[$name] = $parent
        }
    }
}

if ($objects.Count -eq 0)
{
    throw "No font objects found. Is the branch name '$Branch' right?"
}

do
{
    $grew = $false

    foreach ($name in @($inherits.Keys))
    {
        if ($fixedSize.ContainsKey($inherits[$name]) -and -not $fixedSize.ContainsKey($name))
        {
            $fixedSize[$name] = $true
            $grew = $true
        }
    }
}
while ($grew)

$width = ($objects.Keys | Measure-Object -Property Length -Maximum).Maximum

if ($Diff)
{
    if (-not (Test-Path -LiteralPath $OutputPath))
    {
        throw "Not found: $OutputPath"
    }

    $current = @{}
    foreach ($line in (Get-Content -LiteralPath $OutputPath))
    {
        if ($line -match "^\s*(\w+)\s*=\s*(true|false),")
        {
            $current[$Matches[1]] = $Matches[2] -eq "true"
        }
    }

    $added = $objects.Keys | Where-Object { -not $current.ContainsKey($_) } | Sort-Object
    $removed = $current.Keys | Where-Object { -not $objects.ContainsKey($_) } | Sort-Object
    $changed = $objects.Keys | Where-Object { $current.ContainsKey($_) -and $current[$_] -ne $objects[$_] } | Sort-Object

    Write-Output ("-- Added ({0}), paste into Addon.Objects:" -f @($added).Count)
    foreach ($name in $added)
    {
        Write-Output ("`t{0} = {1}," -f $name.PadRight($width), $objects[$name].ToString().ToLower())
    }

    Write-Output ""
    Write-Output ("-- Removed ({0}), delete from Addon.Objects:" -f @($removed).Count)
    foreach ($name in $removed)
    {
        Write-Output ("`t{0} = {1}," -f $name.PadRight($width), $current[$name].ToString().ToLower())
    }

    Write-Output ""
    Write-Output ("-- Changed between family and derived ({0}), replace in Addon.Objects:" -f @($changed).Count)
    foreach ($name in $changed)
    {
        Write-Output ("`t{0} = {1}," -f $name.PadRight($width), $objects[$name].ToString().ToLower())
    }

    return
}

$lines = New-Object System.Collections.Generic.List[string]

$lines.Add("local _, Addon = ...")
$lines.Add("")
$lines.Add("--[[ PhanxFont.Objects")
$lines.Add("Every font object PhanxFont knows about, true when it is a font family that other objects were")
$lines.Add("built from. Regenerate with font_parser.ps1.")
$lines.Add("--]]")
$lines.Add("Addon.Objects = {")

foreach ($name in ($objects.Keys | Sort-Object))
{
    $lines.Add(("`t{0} = {1}," -f $name.PadRight($width), $objects[$name].ToString().ToLower()))
}

$lines.Add("}")
$lines.Add("")
$lines.Add("--[[ PhanxFont.FixedSize")
$lines.Add("Font objects the client sizes in screen pixels, so PhanxFont leaves their size alone.")
$lines.Add("--]]")
$lines.Add("Addon.FixedSize = {")

foreach ($name in ($fixedSize.Keys | Sort-Object))
{
    $lines.Add(("`t{0} = true," -f $name.PadRight($width)))
}

$lines.Add("}")

[System.IO.File]::WriteAllText($OutputPath, ($lines -join "`n") + "`n", (New-Object System.Text.UTF8Encoding($false)))

Write-Output ("{0}: {1} objects, {2} families, {3} fixed size" -f
    (Split-Path -Leaf $OutputPath),
    $objects.Count,
    @($objects.Keys | Where-Object { $objects[$_] }).Count,
    $fixedSize.Count)

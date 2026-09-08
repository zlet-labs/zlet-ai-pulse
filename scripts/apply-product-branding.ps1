[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$WorkDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ProductName = "Zlet AI Pulse"
$Utf8 = [System.Text.Encoding]::UTF8
$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)

$localeDir = Join-Path $WorkDir "rust\src\locale"
if (-not (Test-Path $localeDir)) {
    throw "Locale directory not found: $localeDir"
}

# Keep the legacy config path truthful until settings/config migration is done.
# Everything else in locale VALUES is product-facing copy and may be rebranded.
$allowedLegacyValueKeys = @("HooksConfigPathHint")

foreach ($localeFile in Get-ChildItem -Path $localeDir -Filter "*.ftl" -File) {
    # Windows PowerShell 5.1 can misread UTF-8 files without BOM via Get-Content.
    # Use .NET UTF-8 APIs explicitly so translated strings survive unchanged.
    $lines = [System.IO.File]::ReadAllLines($localeFile.FullName, $Utf8)
    $patched = foreach ($line in $lines) {
        $separator = $line.IndexOf("=")
        if ($separator -lt 1) {
            $line
            continue
        }

        $key = $line.Substring(0, $separator).Trim()
        if ($allowedLegacyValueKeys -contains $key) {
            $line
            continue
        }

        $prefix = $line.Substring(0, $separator + 1)
        $value = $line.Substring($separator + 1).Replace("CodexBar", $ProductName)
        $prefix + $value
    }

    [System.IO.File]::WriteAllLines($localeFile.FullName, $patched, $Utf8NoBom)
}

# The development helper is also visible to contributors. Rebrand only messages,
# not the current upstream binary filename/technical crate identifiers.
$devScriptPath = Join-Path $WorkDir "scripts\dev.ps1"
if (Test-Path $devScriptPath) {
    $devScript = [System.IO.File]::ReadAllText($devScriptPath, $Utf8)
    $devScript = $devScript.Replace("CodexBar Desktop", $ProductName)
    $devScript = $devScript.Replace("CodexBar Tauri desktop shell", "$ProductName Tauri desktop shell")
    [System.IO.File]::WriteAllText($devScriptPath, $devScript, $Utf8NoBom)
}

function Get-LocaleValue {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$Key
    )

    foreach ($line in ($Text -split "`r?`n")) {
        $separator = $line.IndexOf("=")
        if ($separator -lt 1) { continue }
        $lineKey = $line.Substring(0, $separator).Trim()
        if ($lineKey -eq $Key) {
            return $line.Substring($separator + 1).Trim()
        }
    }
    return $null
}

# Guard the exact keys visible in the first real Windows smoke test without
# embedding non-ASCII literals in this .ps1 (PowerShell 5.1 can misdecode them).
$ruLocalePath = Join-Path $localeDir "ru-RU.ftl"
$ruLocale = [System.IO.File]::ReadAllText($ruLocalePath, $Utf8)
$appNameValue = Get-LocaleValue -Text $ruLocale -Key "AppName"
$menuAboutValue = Get-LocaleValue -Text $ruLocale -Key "MenuAbout"
if ($appNameValue -ne $ProductName) {
    throw "Russian AppName was not rebranded: $appNameValue"
}
if ([string]::IsNullOrWhiteSpace($menuAboutValue) -or -not $menuAboutValue.Contains($ProductName) -or $menuAboutValue.Contains("CodexBar")) {
    throw "Russian MenuAbout was not rebranded: $menuAboutValue"
}

# No stale CodexBar branding may remain in locale values except the deliberately
# preserved legacy config-path hint above. Locale KEY names are not branding and
# must not be renamed because Rust LocaleKey depends on them.
$unexpected = @()
foreach ($localeFile in Get-ChildItem -Path $localeDir -Filter "*.ftl" -File) {
    foreach ($line in [System.IO.File]::ReadAllLines($localeFile.FullName, $Utf8)) {
        $separator = $line.IndexOf("=")
        if ($separator -lt 1) { continue }
        $key = $line.Substring(0, $separator).Trim()
        $value = $line.Substring($separator + 1)
        if (($allowedLegacyValueKeys -notcontains $key) -and $value.Contains("CodexBar")) {
            $unexpected += "$($localeFile.Name): $line"
        }
    }
}
if ($unexpected.Count -gt 0) {
    throw "Unexpected CodexBar branding remains in locale values:`n$($unexpected -join [Environment]::NewLine)"
}

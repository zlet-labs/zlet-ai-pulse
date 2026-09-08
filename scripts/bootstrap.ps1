[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ExpectedUpstreamCommit = "bdf0773f66c60810886037cfe5f160e0a9fa4fe7"
$ExpectedUpstreamVersion = "v0.55.0"
$UpstreamRepository = "https://github.com/nesszer/Win-CodexBar.git"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$VendorDir = Join-Path $RepoRoot "vendor\win-codexbar"
$WorkRoot = Join-Path $RepoRoot ".work"
$WorkDir = Join-Path $WorkRoot "zlet-ai-pulse"

function Invoke-Git {
    param([Parameter(Mandatory = $true)][string[]]$Arguments)

    & git @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed with exit code $LASTEXITCODE"
    }
}

function Write-Utf8Json {
    param(
        [Parameter(Mandatory = $true)]$Value,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $json = $Value | ConvertTo-Json -Depth 100
    [System.IO.File]::WriteAllText($Path, $json + [Environment]::NewLine, [System.Text.UTF8Encoding]::new($false))
}

Write-Host "== Zlet AI Pulse bootstrap ==" -ForegroundColor Cyan
Write-Host "Repository: $RepoRoot"
Write-Host "Upstream:   Win-CodexBar $ExpectedUpstreamVersion"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "Git is required but was not found in PATH."
}

Push-Location $RepoRoot
try {
    Write-Host "`n[1/5] Initializing pinned upstream submodule..." -ForegroundColor Cyan
    Invoke-Git -Arguments @("submodule", "update", "--init", "--recursive", "--", "vendor/win-codexbar")

    if (-not (Test-Path $VendorDir)) {
        throw "Upstream submodule directory was not created: $VendorDir"
    }

    $actualCommit = (& git -C $VendorDir rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to read upstream commit."
    }

    if ($actualCommit -ne $ExpectedUpstreamCommit) {
        throw "Unexpected upstream commit. Expected $ExpectedUpstreamCommit, got $actualCommit. Refusing to bootstrap from an unreviewed base."
    }

    $vendorStatus = (& git -C $VendorDir status --porcelain) -join "`n"
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to inspect upstream working tree."
    }
    if (-not [string]::IsNullOrWhiteSpace($vendorStatus)) {
        throw "vendor/win-codexbar contains local changes. Restore the pinned submodule before bootstrapping."
    }

    Write-Host "[2/5] Recreating generated development workspace..." -ForegroundColor Cyan
    if (Test-Path $WorkDir) {
        Remove-Item -Recurse -Force $WorkDir
    }
    New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null

    & robocopy $VendorDir $WorkDir /MIR /XD ".git" "target" "node_modules" /XF ".git" /NFL /NDL /NJH /NJS /NC /NS /NP | Out-Null
    $robocopyCode = $LASTEXITCODE
    if ($robocopyCode -ge 8) {
        throw "robocopy failed with exit code $robocopyCode"
    }
    # Robocopy uses 0..7 for successful outcomes. Normalize that value so a
    # successful copy does not leak as the PowerShell process exit code in CI.
    $global:LASTEXITCODE = 0

    Write-Host "[3/5] Applying Zlet product metadata..." -ForegroundColor Cyan

    $tauriConfigPath = Join-Path $WorkDir "apps\desktop-tauri\src-tauri\tauri.conf.json"
    if (-not (Test-Path $tauriConfigPath)) {
        throw "Tauri config not found at expected upstream path: $tauriConfigPath"
    }

    $tauriConfig = Get-Content -Raw -Path $tauriConfigPath | ConvertFrom-Json
    $tauriConfig.productName = "Zlet AI Pulse"
    $tauriConfig.identifier = "app.zlet.aipulse"
    foreach ($window in @($tauriConfig.app.windows)) {
        if ($window.label -eq "main") {
            $window.title = "Zlet AI Pulse"
        }
    }
    Write-Utf8Json -Value $tauriConfig -Path $tauriConfigPath

    $packageJsonPath = Join-Path $WorkDir "apps\desktop-tauri\package.json"
    if (Test-Path $packageJsonPath) {
        $packageJson = Get-Content -Raw -Path $packageJsonPath | ConvertFrom-Json
        $packageJson.name = "zlet-ai-pulse-desktop"
        Write-Utf8Json -Value $packageJson -Path $packageJsonPath
    }

    $indexHtmlPath = Join-Path $WorkDir "apps\desktop-tauri\index.html"
    if (Test-Path $indexHtmlPath) {
        $indexHtml = Get-Content -Raw -Path $indexHtmlPath
        $indexHtml = $indexHtml.Replace("<title>CodexBar Desktop</title>", "<title>Zlet AI Pulse</title>")
        [System.IO.File]::WriteAllText($indexHtmlPath, $indexHtml, [System.Text.UTF8Encoding]::new($false))
    }

    Write-Host "[4/5] Writing provenance marker..." -ForegroundColor Cyan
    $marker = [ordered]@{
        product = "Zlet AI Pulse"
        upstream_repository = $UpstreamRepository
        upstream_version = $ExpectedUpstreamVersion
        upstream_commit = $ExpectedUpstreamCommit
        generated_utc = (Get-Date).ToUniversalTime().ToString("o")
        generated_by = "scripts/bootstrap.ps1"
    }
    Write-Utf8Json -Value $marker -Path (Join-Path $WorkDir ".zlet-bootstrap.json")

    Write-Host "[5/5] Bootstrap complete." -ForegroundColor Green
    Write-Host ""
    Write-Host "Generated workspace:" -ForegroundColor Green
    Write-Host "  $WorkDir"
    Write-Host ""
    Write-Host "Next step on Windows:" -ForegroundColor Yellow
    Write-Host "  pnpm --dir `"$WorkDir\apps\desktop-tauri`" install --frozen-lockfile"
    Write-Host "  cd `"$WorkDir`""
    Write-Host "  .\scripts\dev.ps1"
    Write-Host ""
    Write-Host "Do not edit vendor/win-codexbar directly. Zlet changes belong in our overlay/first-party code."
}
finally {
    Pop-Location
}

# Publie l'installateur MYA sur GitHub Releases.
param(
    [string]$Tag,
    [string]$Notes = '',
    [switch]$SkipBuild,
    [switch]$Draft,
    [switch]$BumpBuild
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI (gh) requis : https://cli.github.com/"
}

$buildArgs = @{}
if ($SkipBuild) { $buildArgs.SkipBuild = $true }
if ($BumpBuild) { $buildArgs.BumpBuild = $true }
& "$PSScriptRoot\build-installer.ps1" @buildArgs
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$PubspecPath = Join-Path $ProjectRoot "pubspec.yaml"
$match = Select-String -Path $PubspecPath -Pattern '^version:\s*([\d.]+)\+(\d+)\s*$' | Select-Object -First 1
$versionName = $match.Matches[0].Groups[1].Value
$versionBuild = [int]$match.Matches[0].Groups[2].Value

if (-not $Tag) {
    if ($versionBuild -gt 1) {
        $Tag = "v$versionName-build$versionBuild"
    } else {
        $Tag = "v$versionName"
    }
}

$DistDir = Join-Path $ProjectRoot "dist"
$ExpectedName = if ($versionBuild -gt 1) {
    "MYA-Setup-$versionName-build$versionBuild.exe"
} else {
    "MYA-Setup-$versionName.exe"
}
$InstallerPath = Join-Path $DistDir $ExpectedName

if (-not (Test-Path $InstallerPath)) {
    throw "Installateur introuvable : $InstallerPath"
}

$releaseArgs = @('release', 'create', $Tag, $InstallerPath, '--title', "MYA $versionName")
if ($Notes) {
    $releaseArgs += @('--notes', $Notes)
} else {
    $releaseArgs += '--generate-notes'
}
if ($Draft) {
    $releaseArgs += '--draft'
}

Write-Host "==> Publication GitHub Release $Tag" -ForegroundColor Cyan
gh @releaseArgs
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "Release publiée : $Tag" -ForegroundColor Green
Write-Host "Les clients MYA détecteront automatiquement cette version." -ForegroundColor Cyan

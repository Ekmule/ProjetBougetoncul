# Publie MYA sur GitHub Releases (Windows et optionnellement Android).
param(
    [string]$Tag,
    [string]$Notes = '',
    [switch]$SkipBuild,
    [switch]$Draft,
    [switch]$BumpBuild,
    [switch]$IncludeAndroid
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw @"
GitHub CLI (gh) introuvable dans le PATH.
  Installer : winget install --id GitHub.cli -e
  Puis fermer et rouvrir le terminal, puis : gh auth login
  Doc : https://cli.github.com/
"@
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
if (-not (Test-Path $DistDir)) {
    New-Item -ItemType Directory -Path $DistDir | Out-Null
}

$ExpectedExe = if ($versionBuild -gt 1) {
    "MYA-Setup-$versionName-build$versionBuild.exe"
} else {
    "MYA-Setup-$versionName.exe"
}
$InstallerPath = Join-Path $DistDir $ExpectedExe

if (-not (Test-Path $InstallerPath)) {
    throw "Installateur introuvable : $InstallerPath"
}

$uploadPaths = @($InstallerPath)

if ($IncludeAndroid) {
    & "$PSScriptRoot\build-apk.ps1"
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    $apkSource = Join-Path $ProjectRoot "build\app\outputs\flutter-apk\app-release.apk"
    if (-not (Test-Path $apkSource)) {
        throw "APK introuvable : $apkSource"
    }

    $ExpectedApk = if ($versionBuild -gt 1) {
        "MYA-Android-$versionName-build$versionBuild.apk"
    } else {
        "MYA-Android-$versionName.apk"
    }
    $ApkPath = Join-Path $DistDir $ExpectedApk
    Copy-Item -Path $apkSource -Destination $ApkPath -Force
    $uploadPaths += $ApkPath
    Write-Host "APK Android : $ApkPath" -ForegroundColor Green
}

$releaseArgs = @('release', 'create', $Tag) + $uploadPaths + @('--title', "MYA $versionName")
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
Write-Host "Release publiee : $Tag" -ForegroundColor Green
Write-Host "Les clients MYA (Windows / Android) lisent releases/latest." -ForegroundColor Cyan
Write-Host "Un git push seul ne met pas a jour les utilisateurs - voir docs/releases.md" -ForegroundColor Yellow

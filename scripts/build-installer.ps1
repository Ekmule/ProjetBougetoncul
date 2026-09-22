# Build release + installateur Inno Setup pour MYA (Windows)
param(
    [switch]$SkipBuild,
    [switch]$BumpBuild,
    [string]$Version
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$PubspecPath = Join-Path $ProjectRoot "pubspec.yaml"

$Flutter = if ($env:FLUTTER_ROOT) { Join-Path $env:FLUTTER_ROOT "bin\flutter.bat" } else { "E:\flutter\bin\flutter.bat" }
$Iscc = @(
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles}\Inno Setup 6\ISCC.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

function Get-PubspecVersion {
    $match = Select-String -Path $PubspecPath -Pattern '^version:\s*([\d.]+)\+(\d+)\s*$' | Select-Object -First 1
    if (-not $match) {
        throw "Impossible de lire version: x.y.z+N dans $PubspecPath"
    }
    return @{
        Name  = $match.Matches[0].Groups[1].Value
        Build = [int]$match.Matches[0].Groups[2].Value
    }
}

function Set-PubspecVersion {
    param(
        [string]$Name,
        [int]$Build
    )
    $content = Get-Content $PubspecPath -Raw
    $updated = [regex]::Replace(
        $content,
        '(?m)^version:\s*[\d.]+\+\d+\s*$',
        "version: $Name+$Build"
    )
    if ($updated -eq $content) {
        throw "Échec de la mise à jour de la version dans pubspec.yaml"
    }
    Set-Content -Path $PubspecPath -Value $updated -NoNewline
}

Set-Location $ProjectRoot

$versionInfo = Get-PubspecVersion
if ($Version) {
    if ($Version -notmatch '^[\d.]+$') {
        throw "Format -Version invalide (attendu : 1.0.1)"
    }
    $versionInfo.Name = $Version
}

if ($BumpBuild) {
    $versionInfo.Build += 1
    Set-PubspecVersion -Name $versionInfo.Name -Build $versionInfo.Build
    Write-Host "==> Version pubspec : $($versionInfo.Name)+$($versionInfo.Build)" -ForegroundColor Cyan
}

if (-not $SkipBuild) {
    Write-Host "==> flutter build windows --release"
    & $Flutter build windows --release `
        --build-name $versionInfo.Name `
        --build-number $versionInfo.Build
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

$ReleaseDir = Join-Path $ProjectRoot "build\windows\x64\runner\Release"
if (-not (Test-Path (Join-Path $ReleaseDir "mya.exe"))) {
    Write-Error "mya.exe introuvable dans $ReleaseDir"
}

if (-not $Iscc) {
    Write-Host ""
    Write-Host "Inno Setup 6 non trouvé." -ForegroundColor Yellow
    Write-Host "1. Téléchargez : https://jrsoftware.org/isdl.php"
    Write-Host "2. Installez Inno Setup 6"
    Write-Host "3. Relancez : powershell -ExecutionPolicy Bypass -File .\scripts\build-installer.ps1 -SkipBuild"
    Write-Host ""
    Write-Host "Build release prêt dans : $ReleaseDir"
    exit 0
}

$IssPath = Join-Path $ProjectRoot "installer\mya.iss"
$IsccArgs = @(
    "/DMyAppVersion=$($versionInfo.Name)",
    "/DMyAppBuild=$($versionInfo.Build)",
    $IssPath
)

Write-Host "==> Compilation installateur ($($versionInfo.Name) build $($versionInfo.Build))"
& $Iscc @IsccArgs
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$DistDir = Join-Path $ProjectRoot "dist"
$ExpectedName = if ($versionInfo.Build -gt 1) {
    "MYA-Setup-$($versionInfo.Name)-build$($versionInfo.Build).exe"
} else {
    "MYA-Setup-$($versionInfo.Name).exe"
}
Write-Host ""
Write-Host "Installateur créé :" -ForegroundColor Green
Write-Host "  -> $(Join-Path $DistDir $ExpectedName)"
Write-Host ""
Write-Host "Mise à jour : installez par-dessus la version existante (même AppId)." -ForegroundColor Cyan
Write-Host "Données utilisateur conservées : %LOCALAPPDATA%\mya, %APPDATA%\com.mya" -ForegroundColor Cyan

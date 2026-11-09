# Build release + installateur Inno Setup pour MYA (Windows)
param(
    [ValidateSet("complete", "desktop")]
    [string]$Product = "complete",
    [switch]$SkipBuild,
    [switch]$BumpBuild,
    [string]$Version
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$VersionPath = Join-Path $ProjectRoot "config\versions\$Product.json"

$Flutter = if ($env:FLUTTER_ROOT) { Join-Path $env:FLUTTER_ROOT "bin\flutter.bat" } else { "E:\flutter\bin\flutter.bat" }
$Iscc = @(
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles}\Inno Setup 6\ISCC.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

function Get-ProductVersion {
    if (-not (Test-Path $VersionPath)) {
        throw "Version produit introuvable : $VersionPath"
    }
    $version = Get-Content $VersionPath -Raw | ConvertFrom-Json
    return @{
        Name  = [string]$version.name
        Build = [int]$version.build
    }
}

function Set-ProductVersion {
    param(
        [string]$Name,
        [int]$Build
    )
    @{ name = $Name; build = $Build } |
        ConvertTo-Json |
        Set-Content -Path $VersionPath -Encoding UTF8
}

Set-Location $ProjectRoot
. "$PSScriptRoot\local-product-build.ps1"

$versionInfo = Get-ProductVersion
if ($Version) {
    if ($Version -notmatch '^[\d.]+$') {
        throw "Format -Version invalide (attendu : 1.0.1)"
    }
    $versionInfo.Name = $Version
}

if ($BumpBuild) {
    $versionInfo.Build += 1
    Set-ProductVersion -Name $versionInfo.Name -Build $versionInfo.Build
    Write-Host "==> Version $Product : $($versionInfo.Name)+$($versionInfo.Build)" -ForegroundColor Cyan
}

if (-not $SkipBuild) {
    $DartDefineArgs = @()
    $EnvFile = Join-Path $ProjectRoot ".env.json"
    $DartDefineArgs += "--dart-define=MYA_PRODUCT=$Product"
    if ($Product -eq "complete" -and (Test-Path $EnvFile)) {
        Write-Host "==> Supabase : .env.json détecté" -ForegroundColor Yellow
        $DartDefineArgs += "--dart-define-from-file=$EnvFile"
    } elseif ($Product -eq "complete") {
        throw ".env.json absent : MYA Complete doit etre compile avec le cloud."
    } else {
        Write-Host "==> Produit local : cloud exclu" -ForegroundColor Green
    }

    Write-Host "==> flutter build windows --release"
    $Target = if ($Product -eq "desktop") { "lib/main_local.dart" } else { "lib/main.dart" }
    $FlutterArgs = @(
        "build", "windows", "--release",
        "--target", $Target,
        "--build-name", [string]$versionInfo.Name,
        "--build-number", [string]$versionInfo.Build
    ) + $DartDefineArgs
    if ($Product -eq "desktop") {
        $env:MYA_LOCAL_PRODUCT = "true"
        Invoke-LocalProductFlutter `
            -Flutter $Flutter `
            -Arguments $FlutterArgs `
            -ProjectRoot $ProjectRoot
    } else {
        Remove-Item Env:MYA_LOCAL_PRODUCT -ErrorAction SilentlyContinue
        & $Flutter @FlutterArgs
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
}

$ReleaseDir = Join-Path $ProjectRoot "build\windows\x64\runner\Release"
if (-not (Test-Path (Join-Path $ReleaseDir "mya.exe"))) {
    Write-Error "mya.exe introuvable dans $ReleaseDir"
}
$ProductMarker = Join-Path (Split-Path $ReleaseDir -Parent) ".mya-product"
if ($SkipBuild) {
    if (-not (Test-Path $ProductMarker) -or
        (Get-Content $ProductMarker -Raw).Trim() -ne $Product) {
        throw "-SkipBuild refuse : le build Windows courant n'est pas MYA $Product."
    }
} else {
    Set-Content $ProductMarker $Product -Encoding ASCII
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
$productDefines = if ($Product -eq "desktop") {
    @(
        "/DMyAppName=MYA Desktop",
        "/DMyAppId={{D50F7A1E-2A37-4AA8-A79D-62AC5D11B74E}",
        "/DMyAppGuid=D50F7A1E-2A37-4AA8-A79D-62AC5D11B74E",
        "/DMyOutputPrefix=MYA-Desktop-Setup-",
        "/DMyOptionsFolder=MYA Desktop",
        "/DMyCloudEnabled=False"
    )
} else {
    @(
        "/DMyAppName=MYA Complete",
        "/DMyAppId={{A8C22B55-049E-422F-B30F-863694DE08C8}",
        "/DMyAppGuid=A8C22B55-049E-422F-B30F-863694DE08C8",
        "/DMyOutputPrefix=MYA-Complete-Setup-",
        "/DMyOptionsFolder=MYA",
        "/DMyCloudEnabled=True"
    )
}
$IsccArgs = @(
    "/DMyAppVersion=$($versionInfo.Name)",
    "/DMyAppBuild=$($versionInfo.Build)",
    $productDefines
    $IssPath
)

Write-Host "==> Compilation installateur ($($versionInfo.Name) build $($versionInfo.Build))"
& $Iscc @IsccArgs
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$DistDir = Join-Path $ProjectRoot "dist"
$productName = if ($Product -eq "desktop") { "Desktop" } else { "Complete" }
$ExpectedName = if ($versionInfo.Build -gt 1) {
    "MYA-$productName-Setup-$($versionInfo.Name)-build$($versionInfo.Build).exe"
} else {
    "MYA-$productName-Setup-$($versionInfo.Name).exe"
}
Write-Host ""
Write-Host "Installateur créé :" -ForegroundColor Green
Write-Host "  -> $(Join-Path $DistDir $ExpectedName)"
Write-Host ""
Write-Host "Mise à jour : installez par-dessus la version existante (même AppId)." -ForegroundColor Cyan
Write-Host "Produit : MYA $productName (données séparées)." -ForegroundColor Cyan

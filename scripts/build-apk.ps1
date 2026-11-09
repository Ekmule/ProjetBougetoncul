# Build MYA APK release pour installation manuelle sur Android (D16).
#
# Prérequis :
#   - Flutter SDK (voir scripts/run-windows.ps1 pour le chemin sans accent)
#   - .env.json à la racine avec SUPABASE_URL et SUPABASE_ANON_KEY
#   - Android SDK (via Android Studio ou cmdline-tools)
#
# Usage :
#   .\scripts\build-apk.ps1
#   .\scripts\build-apk.ps1 -SplitPerAbi   # APK plus légers par architecture

param(
    [ValidateSet("complete", "mobile")]
    [string]$Product = "complete",
    [switch]$BumpBuild,
    [switch]$SplitPerAbi
)

$ErrorActionPreference = "Stop"

$flutterRoot = "E:\flutter"
$pubCache = "E:\pub-cache"
$jdkHome = "E:\jdk\jdk-17"
$sdkRoot = "E:\Android\Sdk"

if (-not (Test-Path "$flutterRoot\bin\flutter.bat")) {
    Write-Host "Flutter introuvable dans $flutterRoot" -ForegroundColor Red
    Write-Host "Copiez le SDK Flutter vers E:\flutter (voir docs/windows.md section 10)."
    exit 1
}

$env:FLUTTER_ROOT = $flutterRoot
$env:PUB_CACHE = $pubCache
$env:JAVA_HOME = $jdkHome
$env:ANDROID_HOME = $sdkRoot
$env:ANDROID_SDK_ROOT = $sdkRoot
$env:Path = "$flutterRoot\bin;$sdkRoot\platform-tools;" + $env:Path

Set-Location (Split-Path $PSScriptRoot -Parent)
. "$PSScriptRoot\local-product-build.ps1"

$versionFile = Join-Path (Get-Location) "config\versions\$Product.json"
if (-not (Test-Path $versionFile)) {
    throw "Version produit introuvable : $versionFile"
}
$versionInfo = Get-Content $versionFile -Raw | ConvertFrom-Json
if ($BumpBuild) {
    $versionInfo.build = [int]$versionInfo.build + 1
    @{ name = [string]$versionInfo.name; build = [int]$versionInfo.build } |
        ConvertTo-Json |
        Set-Content -Path $versionFile -Encoding UTF8
    Write-Host "Version $Product : $($versionInfo.name)+$($versionInfo.build)" -ForegroundColor Cyan
}

$envFile = Join-Path (Get-Location) ".env.json"
$dartDefineArgs = @("--dart-define=MYA_PRODUCT=$Product")
if ($Product -eq "complete" -and (Test-Path $envFile)) {
    Write-Host "Supabase : .env.json detecte" -ForegroundColor Yellow
    $dartDefineArgs += "--dart-define-from-file=$envFile"
} elseif ($Product -eq "complete") {
    throw ".env.json absent : MYA Complete doit etre compile avec le cloud."
} else {
    Write-Host "Produit local : aucun compte ni synchronisation cloud." -ForegroundColor Green
}

Write-Host "Flutter : $(& `"$flutterRoot\bin\flutter.bat`" --version | Select-Object -First 1)" -ForegroundColor Green

$buildArgs = @(
    "build", "apk", "--release",
    "--flavor", $Product,
    "--target", $(if ($Product -eq "mobile") { "lib/main_local.dart" } else { "lib/main.dart" }),
    "--build-name", [string]$versionInfo.name,
    "--build-number", [string]$versionInfo.build
)
if ($SplitPerAbi) {
    $buildArgs += "--split-per-abi"
}
$buildArgs += $dartDefineArgs

Write-Host "Build APK release..." -ForegroundColor Cyan
if ($Product -eq "mobile") {
    Invoke-LocalProductFlutter `
        -Flutter "$flutterRoot\bin\flutter.bat" `
        -Arguments $buildArgs `
        -ProjectRoot (Get-Location)
} else {
    & flutter @buildArgs
}

$outputDir = Join-Path (Get-Location) "build\app\outputs\flutter-apk"
$sourceApk = Join-Path $outputDir "app-$Product-release.apk"
$productName = if ($Product -eq "complete") { "Complete" } else { "Mobile" }
$distName = "MYA-$productName-Android-$($versionInfo.name)"
if ([int]$versionInfo.build -gt 1) {
    $distName += "-build$($versionInfo.build)"
}
$distName += ".apk"
$distDir = Join-Path (Get-Location) "dist"
New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (-not $SplitPerAbi) {
    if (-not (Test-Path $sourceApk)) {
        throw "APK introuvable : $sourceApk"
    }
    Copy-Item $sourceApk (Join-Path $distDir $distName) -Force
}
Write-Host ""
Write-Host "APK genere(s) dans :" -ForegroundColor Green
Get-ChildItem $outputDir -Filter "*.apk" | ForEach-Object {
    Write-Host "  $($_.FullName)" -ForegroundColor White
}
if (-not $SplitPerAbi) {
    Write-Host "  $(Join-Path $distDir $distName)" -ForegroundColor Green
}
Write-Host ""
Write-Host "Transferez l'APK sur le telephone et autorisez l'installation depuis sources inconnues." -ForegroundColor Cyan
Write-Host "Voir docs/android.md pour OAuth Google et le test de sync." -ForegroundColor Cyan

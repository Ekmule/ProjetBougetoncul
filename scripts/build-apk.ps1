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

$envFile = Join-Path (Get-Location) ".env.json"
$dartDefineArgs = @()
if (Test-Path $envFile) {
    Write-Host "Supabase : .env.json detecte" -ForegroundColor Yellow
    $dartDefineArgs += "--dart-define-from-file=$envFile"
} else {
    Write-Host "Attention : .env.json absent — l'APK fonctionnera en local-only." -ForegroundColor Yellow
}

Write-Host "Flutter : $(& `"$flutterRoot\bin\flutter.bat`" --version | Select-Object -First 1)" -ForegroundColor Green

$buildArgs = @("build", "apk", "--release")
if ($SplitPerAbi) {
    $buildArgs += "--split-per-abi"
}
$buildArgs += $dartDefineArgs

Write-Host "Build APK release..." -ForegroundColor Cyan
& flutter @buildArgs

$outputDir = Join-Path (Get-Location) "build\app\outputs\flutter-apk"
Write-Host ""
Write-Host "APK genere(s) dans :" -ForegroundColor Green
Get-ChildItem $outputDir -Filter "*.apk" | ForEach-Object {
    Write-Host "  $($_.FullName)" -ForegroundColor White
}
Write-Host ""
Write-Host "Transferez l'APK sur le telephone et autorisez l'installation depuis sources inconnues." -ForegroundColor Cyan
Write-Host "Voir docs/android.md pour OAuth Google et le test de sync." -ForegroundColor Cyan

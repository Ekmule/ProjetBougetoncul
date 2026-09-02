# Lance MYA sur Windows avec un SDK Flutter sans accent dans le chemin.
# Necessaire si le profil Windows contient des caracteres speciaux (ex: e accent aigu).
#
# Usage :
#   .\scripts\run-windows.ps1

$ErrorActionPreference = "Stop"

$flutterRoot = "E:\flutter"
$pubCache = "E:\pub-cache"

if (-not (Test-Path "$flutterRoot\bin\flutter.bat")) {
    Write-Host "Flutter introuvable dans $flutterRoot" -ForegroundColor Red
    Write-Host "Copiez le SDK Flutter vers E:\flutter (voir docs/windows.md section 10)."
    exit 1
}

$env:FLUTTER_ROOT = $flutterRoot
$env:PUB_CACHE = $pubCache
$env:Path = "$flutterRoot\bin;" + $env:Path

Set-Location (Split-Path $PSScriptRoot -Parent)

$envFile = Join-Path (Get-Location) ".env.json"
$dartDefineArgs = @()
if (Test-Path $envFile) {
    Write-Host "Supabase : .env.json detecte" -ForegroundColor Yellow
    $dartDefineArgs += "--dart-define-from-file=$envFile"
}

Write-Host "Flutter : $(& `"$flutterRoot\bin\flutter.bat`" --version | Select-Object -First 1)" -ForegroundColor Green
Write-Host "Lancement de MYA..." -ForegroundColor Cyan

& flutter run -d windows @dartDefineArgs @args

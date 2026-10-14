# Installe et configure le SDK Android pour builder l'APK MYA.
# Tout est place sur E:\ (meme logique que E:\flutter, sans accent).
#
# Usage :
#   .\scripts\setup-android-sdk.ps1
#   .\scripts\setup-android-sdk.ps1 -SkipAndroidStudio

param(
    [switch]$SkipAndroidStudio
)

$ErrorActionPreference = "Stop"

$flutterRoot = "E:\flutter"
$pubCache = "E:\pub-cache"
$jdkHome = "E:\jdk\jdk-17"
$sdkRoot = "E:\Android\Sdk"
$cmdlineToolsDir = Join-Path $sdkRoot "cmdline-tools\latest"
$sdkManager = Join-Path $cmdlineToolsDir "bin\sdkmanager.bat"

$env:FLUTTER_ROOT = $flutterRoot
$env:PUB_CACHE = $pubCache
$env:JAVA_HOME = $jdkHome
$env:ANDROID_HOME = $sdkRoot
$env:ANDROID_SDK_ROOT = $sdkRoot
$env:Path = "$flutterRoot\bin;$jdkHome\bin;" + $env:Path

function Ensure-AndroidSdkRoot {
    if (-not (Test-Path $sdkRoot)) {
        New-Item -ItemType Directory -Path $sdkRoot -Force | Out-Null
    }
}

function Install-PortableJdk {
    if (Test-Path (Join-Path $jdkHome "bin\java.exe")) {
        Write-Host "JDK portable deja present : $jdkHome" -ForegroundColor Green
        return
    }

    New-Item -ItemType Directory -Path (Split-Path $jdkHome -Parent) -Force | Out-Null
    $zipPath = Join-Path $env:TEMP "microsoft-jdk-17.zip"

    Write-Host "Telechargement du JDK 17 portable..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri "https://aka.ms/download-jdk/microsoft-jdk-17.0.20.1-windows-x64.zip" -OutFile $zipPath

    Write-Host "Extraction du JDK..." -ForegroundColor Cyan
    Expand-Archive -Path $zipPath -DestinationPath (Split-Path $jdkHome -Parent) -Force

    $extracted = Get-ChildItem (Split-Path $jdkHome -Parent) -Directory |
        Where-Object { Test-Path (Join-Path $_.FullName "bin\java.exe") } |
        Select-Object -First 1

    if (-not $extracted) {
        throw "JDK extrait mais java.exe introuvable."
    }

    if ($extracted.FullName -ne $jdkHome) {
        if (Test-Path $jdkHome) {
            Remove-Item $jdkHome -Recurse -Force
        }
        Rename-Item $extracted.FullName (Split-Path $jdkHome -Leaf)
    }

    Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
    & (Join-Path $jdkHome "bin\java.exe") -version
}

function Install-CommandLineTools {
    Ensure-AndroidSdkRoot

    if (Test-Path $sdkManager) {
        Write-Host "Command-line tools deja presents." -ForegroundColor Green
        return
    }

    $zipPath = Join-Path $env:TEMP "android-cmdline-tools.zip"
    $extractRoot = Join-Path $env:TEMP "android-cmdline-tools"

    if (Test-Path $extractRoot) {
        Remove-Item $extractRoot -Recurse -Force
    }

    Write-Host "Telechargement des Android command-line tools..." -ForegroundColor Cyan
    $url = "https://dl.google.com/android/repository/commandlinetools-win-13114758_latest.zip"
    Invoke-WebRequest -Uri $url -OutFile $zipPath

    Write-Host "Extraction..." -ForegroundColor Cyan
    Expand-Archive -Path $zipPath -DestinationPath $extractRoot -Force

    New-Item -ItemType Directory -Path (Split-Path $cmdlineToolsDir -Parent) -Force | Out-Null
    Move-Item -Path (Join-Path $extractRoot "cmdline-tools") -Destination $cmdlineToolsDir -Force

    Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
    Remove-Item $extractRoot -Recurse -Force -ErrorAction SilentlyContinue
}

function Install-SdkPackages {
    if (-not (Test-Path $sdkManager)) {
        throw "sdkmanager introuvable : $sdkManager"
    }

    Write-Host "Installation des composants SDK..." -ForegroundColor Cyan
    & $sdkManager --sdk_root=$sdkRoot `
        "platform-tools" `
        "platforms;android-35" `
        "platforms;android-36" `
        "build-tools;35.0.0" `
        "build-tools;36.0.0" `
        "cmdline-tools;latest"

    Write-Host "Acceptation des licences Android..." -ForegroundColor Cyan
    $yes = ("y`n" * 30)
    $yes | & $sdkManager --sdk_root=$sdkRoot --licenses | Out-Null
}

function Configure-UserEnv {
    & flutter config --android-sdk $sdkRoot | Out-Null

    [Environment]::SetEnvironmentVariable("JAVA_HOME", $jdkHome, "User")
    [Environment]::SetEnvironmentVariable("ANDROID_HOME", $sdkRoot, "User")
    [Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $sdkRoot, "User")

    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $pathsToAdd = @(
        (Join-Path $jdkHome "bin"),
        (Join-Path $sdkRoot "platform-tools"),
        (Join-Path $sdkRoot "cmdline-tools\latest\bin")
    )

    foreach ($entry in $pathsToAdd) {
        if ($userPath -notlike "*$entry*") {
            if ([string]::IsNullOrWhiteSpace($userPath)) {
                $userPath = $entry
            } else {
                $userPath = "$userPath;$entry"
            }
        }
    }

    [Environment]::SetEnvironmentVariable("Path", $userPath, "User")
    Write-Host "Variables utilisateur JAVA_HOME / ANDROID_HOME / Path mises a jour." -ForegroundColor Green
}

function Install-AndroidStudioOptional {
    if ($SkipAndroidStudio) { return }

    $studioPaths = @(
        "$env:ProgramFiles\Android\Android Studio\bin\studio64.exe",
        "${env:ProgramFiles(x86)}\Android\Android Studio\bin\studio64.exe"
    )
    foreach ($path in $studioPaths) {
        if (Test-Path $path) {
            Write-Host "Android Studio deja installe : $path" -ForegroundColor Green
            return
        }
    }

    Write-Host "Installation d'Android Studio via winget (optionnel)..." -ForegroundColor Cyan
    Write-Host "Une fenetre UAC peut apparaitre — acceptez si vous voulez l'IDE complet." -ForegroundColor Yellow
    winget install --id Google.AndroidStudio -e --accept-package-agreements --accept-source-agreements
}

Set-Location (Split-Path $PSScriptRoot -Parent)

Install-PortableJdk
Install-AndroidStudioOptional
Install-CommandLineTools
Install-SdkPackages
Configure-UserEnv

Write-Host ""
Write-Host "Verification Flutter..." -ForegroundColor Cyan
& flutter doctor -v

Write-Host ""
Write-Host "Prochaine etape :" -ForegroundColor Green
Write-Host "  1. Fermez et rouvrez le terminal (variables d'environnement)."
Write-Host "  2. Lancez : .\scripts\build-apk.ps1"
Write-Host ""
Write-Host "Android Studio est optionnel pour builder l'APK." -ForegroundColor Yellow

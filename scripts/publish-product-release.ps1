param(
    [ValidateSet("complete", "mobile", "desktop")]
    [string]$Product,
    [string]$Notes = "",
    [switch]$BumpBuild,
    [switch]$SkipBuild,
    [switch]$Draft
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI introuvable. Installez gh puis lancez : gh auth login"
}

$versionFile = Join-Path $ProjectRoot "config\versions\$Product.json"
if (-not (Test-Path $versionFile)) {
    throw "Version produit introuvable : $versionFile"
}

if (-not $SkipBuild) {
    if ($Product -eq "mobile") {
        & "$PSScriptRoot\build-apk.ps1" -Product mobile -BumpBuild:$BumpBuild
    } else {
        & "$PSScriptRoot\build-installer.ps1" -Product $Product -BumpBuild:$BumpBuild
        if ($Product -eq "complete") {
            & "$PSScriptRoot\build-apk.ps1" -Product complete
        }
    }
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
} elseif ($BumpBuild) {
    throw "-BumpBuild ne peut pas être utilisé avec -SkipBuild."
}

$version = Get-Content $versionFile -Raw | ConvertFrom-Json
$productName = (Get-Culture).TextInfo.ToTitleCase($Product)
$suffix = if ([int]$version.build -gt 1) { "-build$($version.build)" } else { "" }
$assets = @()

if ($Product -in @("complete", "desktop")) {
    $assets += Join-Path $ProjectRoot "dist\MYA-$productName-Setup-$($version.name)$suffix.exe"
}
if ($Product -in @("complete", "mobile")) {
    $assets += Join-Path $ProjectRoot "dist\MYA-$productName-Android-$($version.name)$suffix.apk"
}
if ($Product -eq "complete") {
    # Alias de transition pour les clients historiques qui lisent releases/latest.
    $legacySetup = Join-Path $ProjectRoot "dist\MYA-Setup-$($version.name)$suffix.exe"
    $legacyApk = Join-Path $ProjectRoot "dist\MYA-Android-$($version.name)$suffix.apk"
    Copy-Item $assets[0] $legacySetup -Force
    Copy-Item $assets[1] $legacyApk -Force
    $assets += @($legacySetup, $legacyApk)
}
foreach ($asset in $assets) {
    if (-not (Test-Path $asset)) { throw "Asset introuvable : $asset" }
}

$tag = "$Product-v$($version.name)$suffix"
$arguments = @("release", "create", $tag) + $assets +
    @("--title", "MYA $productName $($version.name)")
if ($Notes) { $arguments += @("--notes", $Notes) } else { $arguments += "--generate-notes" }
if ($Draft) { $arguments += "--draft" }

gh @arguments
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "Release $tag publiée pour MYA $productName." -ForegroundColor Green

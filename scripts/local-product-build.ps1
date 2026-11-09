function Invoke-LocalProductFlutter {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Flutter,
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,
        [Parameter(Mandatory = $true)]
        [string]$ProjectRoot
    )

    $pubspec = Join-Path $ProjectRoot "pubspec.yaml"
    $lock = Join-Path $ProjectRoot "pubspec.lock"
    $pubspecBackup = [IO.Path]::GetTempFileName()
    $lockBackup = [IO.Path]::GetTempFileName()
    Copy-Item $pubspec $pubspecBackup -Force
    $hadLock = Test-Path $lock
    if ($hadLock) { Copy-Item $lock $lockBackup -Force }

    $exitCode = 1
    try {
        $content = Get-Content $pubspec -Raw
        $localContent = [regex]::Replace(
            $content,
            '(?m)^\s{2}(app_links|flutter_web_auth_2|supabase_flutter):[^\r\n]*\r?\n',
            ''
        )
        Set-Content $pubspec $localContent -Encoding UTF8 -NoNewline
        & $Flutter clean
        if ($LASTEXITCODE -ne 0) { throw "flutter clean local a échoué." }
        & $Flutter pub get
        if ($LASTEXITCODE -ne 0) { throw "flutter pub get local a échoué." }

        & $Flutter @Arguments
        $exitCode = $LASTEXITCODE
    } finally {
        Copy-Item $pubspecBackup $pubspec -Force
        if ($hadLock) {
            Copy-Item $lockBackup $lock -Force
        } elseif (Test-Path $lock) {
            Remove-Item $lock -Force
        }
        Remove-Item $pubspecBackup, $lockBackup -Force -ErrorAction SilentlyContinue
        & $Flutter pub get | Out-Null
    }

    if ($exitCode -ne 0) {
        throw "Le build Flutter local a échoué (code $exitCode)."
    }
}

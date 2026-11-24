# ADDED: run Patrol test and pull the optimized screen recording afterward
# Usage: pwsh -File .\run_patrol_with_recording.ps1

$ErrorActionPreference = 'Stop'

$projectRoot   = Split-Path -Parent $MyInvocation.MyCommand.Path
$devicePath    = '/sdcard/patrol_test_recording.mp4'
$localOutput   = Join-Path $projectRoot 'patrol_recording.mp4'
$testFile      = 'patrol_test/app_test.dart'
$testName      = 'increments the tap counter and shows the updated value'

# ADDED: resolve adb (PATH first, then default SDK location)
$adb = (Get-Command adb -ErrorAction SilentlyContinue)?.Source
if (-not $adb) {
    $candidate = Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'
    if (Test-Path $candidate) { $adb = $candidate }
}
if (-not $adb) { throw 'adb not found. Install Android platform-tools or add adb to PATH.' }

# ADDED: make sure a device is attached
$devices = & $adb devices | Select-Object -Skip 1 | Where-Object { $_ -match '\S+\s+device$' }
if (-not $devices) { throw 'No Android device/emulator attached.' }
Write-Host "Device(s) attached:" -ForegroundColor Cyan
$devices | ForEach-Object { Write-Host "  $_" }

# ADDED: remove stale recording so we only pull the fresh one
& $adb shell rm -f $devicePath 2>$null | Out-Null

Push-Location $projectRoot
try {
    # ADDED: run the patrol test (recording is started/stopped inside the Dart test)
    Write-Host "Running Patrol test: $testName" -ForegroundColor Cyan
    & patrol test --target $testFile --name $testName
    $testExit = $LASTEXITCODE
} finally {
    Pop-Location
}

# ADDED: pull the recording (works even if the test failed)
if (Test-Path $localOutput) { Remove-Item $localOutput -Force }
Write-Host "Pulling recording from $devicePath" -ForegroundColor Cyan
& $adb pull $devicePath $localOutput

if (Test-Path $localOutput) {
    $sizeMb = [math]::Round((Get-Item $localOutput).Length / 1MB, 2)
    Write-Host "Saved recording -> $localOutput ($sizeMb MB)" -ForegroundColor Green
} else {
    Write-Warning "Recording not found on device. The test may have failed before startScreenRecording()."
}

exit $testExit
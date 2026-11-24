# ADDED: run Patrol test with native, optimized video recording
# Usage: pwsh -File .\run_patrol_with_recording.ps1

$ErrorActionPreference = 'Stop'

$projectRoot   = Split-Path -Parent $MyInvocation.MyCommand.Path
$testFile      = 'patrol_test/app_test.dart'
$videoDir      = Join-Path $projectRoot 'patrol_videos'   # ADDED: Patrol will write here
$localOutput   = Join-Path $projectRoot 'patrol_recording.mp4'

# ADDED: ensure clean output dir
if (Test-Path $videoDir) { Remove-Item $videoDir -Recurse -Force }
New-Item -ItemType Directory -Path $videoDir | Out-Null

Push-Location $projectRoot
try {
    Write-Host "Running Patrol test with video recording (720x1280 @ 4 Mbps)..." -ForegroundColor Cyan
    & patrol test `
        --target $testFile `
        --record-video `
        --video-size 720x1280 `
        --video-bit-rate 4000000 `
        --video-output-dir $videoDir
    $testExit = $LASTEXITCODE
} finally {
    Pop-Location
}

# ADDED: pick up whatever Patrol produced and normalize to a stable filename
$produced = Get-ChildItem -Path $videoDir -Filter *.mp4 -File -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($produced) {
    if (Test-Path $localOutput) { Remove-Item $localOutput -Force }
    Move-Item $produced.FullName $localOutput
    $sizeMb = [math]::Round((Get-Item $localOutput).Length / 1MB, 2)
    Write-Host "Saved recording -> $localOutput ($sizeMb MB)" -ForegroundColor Green
} else {
    Write-Warning "No recording produced. Check that the test actually ran (exit code $testExit)."
}

exit $testExit
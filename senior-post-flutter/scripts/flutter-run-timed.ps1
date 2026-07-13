# Lightweight timed flutter run — logs phase timings to repo debug-afbdfd.log
# Usage (from senior-post-flutter):
#   powershell -File .\scripts\flutter-run-timed.ps1
param(
  [string]$DeviceId = "127.0.0.1:7555"
)

$ErrorActionPreference = "Continue"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$flutterRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$logPath = Join-Path $repoRoot "debug-afbdfd.log"
$runId = "user-flutter-run-$(Get-Date -Format 'HHmmss')"
$wallStart = Get-Date
$script:phaseMarks = @{}

function Write-AgentLog {
  param([string]$HypothesisId, [string]$Location, [string]$Message, [hashtable]$Data = @{})
  # region agent log
  $payload = [ordered]@{
    sessionId    = "afbdfd"
    runId        = $runId
    hypothesisId = $HypothesisId
    location     = $Location
    message      = $Message
    data         = $Data
    timestamp    = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
  }
  ($payload | ConvertTo-Json -Compress -Depth 8) | Add-Content -Path $logPath -Encoding utf8
  # endregion
}

function Mark-Phase([string]$name, [string]$hypothesisId) {
  if ($script:phaseMarks.ContainsKey($name)) { return }
  $sec = [math]::Round(((Get-Date) - $wallStart).TotalSeconds, 1)
  $script:phaseMarks[$name] = $sec
  Write-Host "[timed +${sec}s] $name" -ForegroundColor Cyan
  Write-AgentLog $hypothesisId "flutter-run-timed:$name" "phase_reached" @{ elapsedSec = $sec; phase = $name }
}

Set-Location $flutterRoot
$apkPath = "build\app\outputs\flutter-apk\app-debug.apk"
Write-AgentLog "B" "flutter-run-timed:start" "user_flutter_run_started" @{
  deviceId  = $DeviceId
  cwd       = $flutterRoot
  apkExists = (Test-Path $apkPath)
  apkMB     = if (Test-Path $apkPath) { [math]::Round((Get-Item $apkPath).Length / 1MB, 2) } else { -1 }
}
Mark-Phase "process_start" "B"

# flutter run; parse milestones from combined output
& flutter run -d $DeviceId 2>&1 | ForEach-Object {
  $line = "$_"
  Write-Host $line
  if ($line -match "Running Gradle task") { Mark-Phase "gradle_started" "B" }
  if ($line -match "Running Gradle task 'assembleDebug'\.\.\.\s+([\d.]+)s") {
    Mark-Phase "gradle_finished" "B"
    Write-AgentLog "B" "flutter-run-timed:gradle_duration" "gradle_assemble_duration" @{ sec = $Matches[1]; line = $line.Trim() }
  }
  if ($line -match "Built build") { Mark-Phase "apk_built" "C" }
  if ($line -match "Installing") { Mark-Phase "install_started" "A" }
  if ($line -match "Syncing files to device|Flutter run key commands|A Dart VM Service on") {
    Mark-Phase "app_running" "A"
  }
}

$total = [math]::Round(((Get-Date) - $wallStart).TotalSeconds, 1)
Write-AgentLog "B" "flutter-run-timed:summary" "timing_summary" @{
  totalSec = $total
  phases   = @($script:phaseMarks.GetEnumerator() | ForEach-Object { @{ name = $_.Key; sec = $_.Value } })
}

Write-Host ""
Write-Host "=== TIMING SUMMARY (elapsed from start) ===" -ForegroundColor Green
$script:phaseMarks.GetEnumerator() | Sort-Object Value | ForEach-Object {
  Write-Host ("  {0,-20} +{1}s" -f $_.Key, $_.Value)
}
Write-Host "  total                ${total}s"
Write-Host "  log: $logPath"

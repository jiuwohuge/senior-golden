# Flutter Web local multi-account testing — Chrome by default.
# Usage (from senior-post-flutter):
#   powershell -File .\scripts\flutter-run-web.ps1
#   powershell -File .\scripts\flutter-run-web.ps1 -DeviceId edge
# Optional API override:
#   powershell -File .\scripts\flutter-run-web.ps1 -ApiBaseUrl "http://localhost:9011/backend"
param(
  [string]$DeviceId = "chrome",
  [string]$ApiBaseUrl = ""
)

$ErrorActionPreference = "Stop"
$flutterRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Set-Location $flutterRoot

$flutterArgs = @("run", "-d", $DeviceId)
if ($ApiBaseUrl -ne "") {
  $flutterArgs += "--dart-define=API_BASE_URL=$ApiBaseUrl"
}

Write-Host "Starting Flutter Web ($DeviceId)..." -ForegroundColor Cyan
Write-Host "Default API (when no dart-define): http://localhost/backend" -ForegroundColor DarkGray
Write-Host "Tip: open extra Chrome profiles / Incognito windows for multi-account." -ForegroundColor DarkGray
& flutter @flutterArgs

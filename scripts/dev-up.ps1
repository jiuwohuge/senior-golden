#Requires -Version 5.1
<#
.SYNOPSIS
  Package API JAR then rebuild/restart app services via root docker-compose.yml.

.DESCRIPTION
  Always runs `mvn clean package`, copies the server JAR into senior-post-api/dist,
  then rebuilds app images and recreates only senior-post-api / senior-post-manage.
  Middleware (postgresql / redis / nginx) is started if missing, never force-recreated.
  Prefer this over local spring-boot:run.
#>
param(
    [switch]$ApiOnly,
    [switch]$SkipManageBuild,
    [string]$ComposeFile = ""
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path (Join-Path $Root "docker-compose.yml"))) {
    throw "docker-compose.yml not found at repo root: $Root"
}

Set-Location $Root
$ApiDir = Join-Path $Root "senior-post-api"
$DistDir = Join-Path $ApiDir "dist"

Write-Host "==> mvn clean package (senior-post-api)" -ForegroundColor Cyan
Push-Location $ApiDir
try {
    mvn clean package "-Dmaven.test.skip=true"
    if ($LASTEXITCODE -ne 0) { throw "mvn clean package failed with exit $LASTEXITCODE" }
} finally {
    Pop-Location
}

$TargetJar = Get-ChildItem (Join-Path $ApiDir "server\target\senior-post-server-*.jar") |
    Where-Object { $_.Name -notlike "*-sources.jar" -and $_.Name -notlike "*-javadoc.jar" } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
if (-not $TargetJar) { throw "No senior-post-server-*.jar under server/target after package" }

New-Item -ItemType Directory -Force -Path $DistDir | Out-Null
$DestJar = Join-Path $DistDir $TargetJar.Name
Copy-Item $TargetJar.FullName $DestJar -Force
# Keep a stable wildcard-friendly name for Dockerfile ARG
Copy-Item $TargetJar.FullName (Join-Path $DistDir "senior-post-server-1.0-SNAPSHOT.jar") -Force
Write-Host "==> JAR -> dist/$($TargetJar.Name)" -ForegroundColor Cyan

$composeArgs = @("compose")
if ($ComposeFile) { $composeArgs += @("-f", $ComposeFile) }

# Middleware: ensure running, do not rebuild/recreate
$middleware = @("postgresql", "redis")
if (-not $ApiOnly) {
    $middleware += "nginx"
}

Write-Host "==> docker compose up -d --no-recreate ($($middleware -join ', '))" -ForegroundColor Cyan
& docker @($composeArgs + @("up", "-d", "--no-recreate") + $middleware)
if ($LASTEXITCODE -ne 0) { throw "docker compose up middleware failed" }

Write-Host "==> docker compose build senior-post-api" -ForegroundColor Cyan
& docker @($composeArgs + @("build", "senior-post-api"))
if ($LASTEXITCODE -ne 0) { throw "docker compose build senior-post-api failed" }

Write-Host "==> docker compose up -d --force-recreate --no-deps senior-post-api" -ForegroundColor Cyan
& docker @($composeArgs + @("up", "-d", "--force-recreate", "--no-deps", "senior-post-api"))
if ($LASTEXITCODE -ne 0) { throw "docker compose up senior-post-api failed" }

if (-not $ApiOnly) {
    if (-not $SkipManageBuild) {
        Write-Host "==> docker compose build senior-post-manage (optional image; runtime uses volume+vite)" -ForegroundColor Cyan
        & docker @($composeArgs + @("build", "senior-post-manage"))
    }
    Write-Host "==> docker compose up -d --force-recreate --no-deps senior-post-manage" -ForegroundColor Cyan
    & docker @($composeArgs + @("up", "-d", "--force-recreate", "--no-deps", "senior-post-manage"))
    if ($LASTEXITCODE -ne 0) { throw "docker compose up senior-post-manage failed" }
}

Write-Host ""
Write-Host "API:    http://localhost:9011/backend" -ForegroundColor Green
Write-Host "Manage: http://localhost:8080" -ForegroundColor Green
Write-Host "Done. (middleware left untouched: postgresql / redis / nginx)" -ForegroundColor Green

#Requires -Version 5.1
<#
.SYNOPSIS
  Mock full-chain E2E for billing + RTDN + recovery + FCM ban + optional manage (no real Google/Play).

.DESCRIPTION
  Ordered PASS/FAIL runner for plan §8 item 8 (模拟全链路验收).
  Default BASE_URL: http://127.0.0.1:9011/backend
  Optional: ADMIN_USER (default admin), ADMIN_PASSWORD (skip manage if unset)
  Exit 1 on any hard FAIL. SKIP steps do not fail the run.

.EXAMPLE
  pwsh -File docs/qa/scripts/e2e-mock-fullchain.ps1
  $env:BASE_URL="http://127.0.0.1:9011/backend"; .\docs\qa\scripts\e2e-mock-fullchain.ps1
#>
param(
    [string]$BaseUrl = $(if ($env:BASE_URL) { $env:BASE_URL } else { "http://127.0.0.1:9011/backend" }),
    [string]$AdminUser = $(if ($env:ADMIN_USER) { $env:ADMIN_USER } else { "admin" }),
    [string]$AdminPassword = $(if ($env:ADMIN_PASSWORD) { $env:ADMIN_PASSWORD } else { "" }),
    [string]$RepoRoot = ""
)

$ErrorActionPreference = "Continue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$script:FailCount = 0
$script:PassCount = 0
$script:SkipCount = 0
$script:Results = New-Object System.Collections.Generic.List[string]

function Write-Step([string]$name, [string]$status, [string]$detail = "") {
    $line = "[{0}] {1}" -f $status, $name
    if ($detail) { $line = "$line - $detail" }
    $script:Results.Add($line) | Out-Null
    $color = switch ($status) {
        "PASS" { "Green" }
        "FAIL" { "Red" }
        "SKIP" { "Yellow" }
        default { "Gray" }
    }
    Write-Host $line -ForegroundColor $color
    switch ($status) {
        "PASS" { $script:PassCount++ }
        "FAIL" { $script:FailCount++ }
        "SKIP" { $script:SkipCount++ }
    }
}

function ConvertTo-Text($content) {
    if ($null -eq $content) { return "" }
    if ($content -is [byte[]]) {
        return [System.Text.Encoding]::UTF8.GetString($content)
    }
    return [string]$content
}

function Invoke-Api {

    param(
        [string]$Method,
        [string]$Path,
        [hashtable]$Headers = @{},
        [object]$Body = $null,
        [int[]]$OkHttp = @(200)
    )
    $uri = ($BaseUrl.TrimEnd("/") + $Path)
    $hdrs = @{ "Content-Type" = "application/json" }
    foreach ($k in $Headers.Keys) { $hdrs[$k] = $Headers[$k] }
    $json = $null
    if ($null -ne $Body) {
        if ($Body -is [string]) { $json = $Body }
        else { $json = ($Body | ConvertTo-Json -Depth 8 -Compress) }
    }
    try {
        if ($null -ne $json) {
            $resp = Invoke-WebRequest -Uri $uri -Method $Method -Headers $hdrs -Body ([System.Text.Encoding]::UTF8.GetBytes($json)) -ContentType "application/json; charset=utf-8" -UseBasicParsing
        } else {
            $resp = Invoke-WebRequest -Uri $uri -Method $Method -Headers $hdrs -UseBasicParsing
        }
        $rawText = ConvertTo-Text $resp.Content
        $parsed = $null
        if ($rawText) {
            try { $parsed = $rawText | ConvertFrom-Json } catch { $parsed = $null }
        }
        return [pscustomobject]@{
            Ok       = ($OkHttp -contains [int]$resp.StatusCode)
            Status   = [int]$resp.StatusCode
            Code     = $(if ($parsed) { $parsed.code } else { $null })
            Success  = $(if ($parsed) { [bool]$parsed.success } else { $false })
            Message  = $(if ($parsed) { [string]$parsed.message } else { "" })
            Data     = $(if ($parsed) { $parsed.data } else { $null })
            Raw      = $rawText
            Exception = $null
        }
    } catch {
        $status = 0
        $raw = ""
        $parsed = $null
        try {
            $exResp = $_.Exception.Response
            if ($exResp) {
                $status = [int]$exResp.StatusCode
                $stream = $exResp.GetResponseStream()
                if ($stream) {
                    $reader = New-Object System.IO.StreamReader($stream)
                    $raw = $reader.ReadToEnd()
                    $reader.Close()
                }
                if ($raw) { try { $parsed = $raw | ConvertFrom-Json } catch {} }
            }
        } catch {}
        if (-not $raw -and $_.ErrorDetails -and $_.ErrorDetails.Message) {
            $raw = $_.ErrorDetails.Message
            try { $parsed = $raw | ConvertFrom-Json } catch {}
        }
        return [pscustomobject]@{
            Ok       = ($OkHttp -contains $status)
            Status   = $status
            Code     = $(if ($parsed) { $parsed.code } else { $null })
            Success  = $(if ($parsed) { [bool]$parsed.success } else { $false })
            Message  = $(if ($parsed) { [string]$parsed.message } else { $_.Exception.Message })
            Data     = $(if ($parsed) { $parsed.data } else { $null })
            Raw      = $raw
            Exception = $_.Exception.Message
        }
    }
}

function Assert-BizOk($resp, [string]$name, [string]$detailOk = "") {
    if ($resp.Ok -and $resp.Code -eq 200 -and $resp.Success) {
        Write-Step $name "PASS" $detailOk
        return $true
    }
    $d = "http=$($resp.Status) code=$($resp.Code) success=$($resp.Success) msg=$($resp.Message)"
    if ($resp.Exception) { $d += " ex=$($resp.Exception)" }
    Write-Step $name "FAIL" $d
    return $false
}

function Assert-Entitled($data, [bool]$expectEntitled, [string]$expectState, [string]$name) {
    if ($null -eq $data) {
        Write-Step $name "FAIL" "no subscription data"
        return $false
    }
    $ent = [bool]$data.entitled
    $st = [string]$data.state
    $ok = ($ent -eq $expectEntitled)
    if ($expectState) { $ok = $ok -and ($st -eq $expectState) }
    if ($ok) {
        Write-Step $name "PASS" "state=$st entitled=$ent"
        return $true
    }
    Write-Step $name "FAIL" "got state=$st entitled=$ent expect state=$expectState entitled=$expectEntitled"
    return $false
}

Write-Host "=== Mock full-chain E2E ===" -ForegroundColor Cyan
Write-Host "BASE_URL=$BaseUrl"
Write-Host ""

# Resolve repo root for local code smoke (optional)
if (-not $RepoRoot) {
    $here = $PSScriptRoot
    if ($here) {
        $candidate = Resolve-Path (Join-Path $here "..\..\..") -ErrorAction SilentlyContinue
        if ($candidate) { $RepoRoot = $candidate.Path }
    }
}

# ---------- 0. Health ----------
$health = Invoke-Api -Method GET -Path "/actuator/health"
if ($health.Ok -and $health.Raw -match '"status"\s*:\s*"UP"') {
    Write-Step "ENV health" "PASS" "UP"
} else {
    Write-Step "ENV health" "FAIL" "http=$($health.Status) body=$($health.Raw)"
    Write-Host "`nAPI not UP - abort." -ForegroundColor Red
    exit 1
}

# ---------- 1. Guest login ----------
$equipmentId = "qa-e2e-" + [guid]::NewGuid().ToString("N").Substring(0, 16)
$appHeaders = @{ "equipmentId" = $equipmentId }
$guestBody = @{
    deviceUuid = $equipmentId
    deviceType = "android"
    language   = "zh-CN"
}
$guest = Invoke-Api -Method POST -Path "/api/auth/guest" -Headers $appHeaders -Body $guestBody
$token = $null
$userId = $null
if ($guest.Ok -and $guest.Code -eq 200 -and $guest.Data -and $guest.Data.token) {
    $token = [string]$guest.Data.token
    $userId = $guest.Data.user.id
    $appHeaders["Token"] = $token
    Write-Step "AUTH guest" "PASS" "userId=$userId equipmentId=$equipmentId"
} else {
    Write-Step "AUTH guest" "FAIL" "code=$($guest.Code) msg=$($guest.Message)"
    Write-Host "`nCannot continue without guest token." -ForegroundColor Red
    exit 1
}

# Preflight: mock flags via first mock-sync (billing.mock-enabled)
$preflightToken = "mock:plus_yearly:PURCHASED:preflight" + [guid]::NewGuid().ToString("N")
# Use a dedicated token later for lifecycle; here only detect mockDisabled
$pre = Invoke-Api -Method POST -Path "/api/billing/mock-sync" -Headers $appHeaders -Body @{
    scenario      = "PENDING"
    productId     = "plus_yearly"
    purchaseToken = ("mock:plus_yearly:PENDING:pre" + [guid]::NewGuid().ToString("N"))
}
if ($pre.Code -eq 200 -and $pre.Success) {
    Write-Step "MOCK flags billing" "PASS" "billing.mock-enabled effective"
} elseif ($pre.Message -match "mock" -or $pre.Code -eq 4501) {
    Write-Step "MOCK flags billing" "FAIL" "mock disabled? code=$($pre.Code) msg=$($pre.Message)"
    Write-Host "Enable BILLING_MOCK_ENABLED / senior-post.billing.mock-enabled (non-prod)." -ForegroundColor Red
    exit 1
} else {
    Write-Step "MOCK flags billing" "FAIL" "code=$($pre.Code) msg=$($pre.Message)"
    exit 1
}

# ---------- 2. Purchase lifecycle via mock-sync (same token) ----------
$purchaseToken = "mock:plus_yearly:PURCHASED:" + [guid]::NewGuid().ToString("N")

function Invoke-MockSync([string]$scenario, [string]$token) {
    return Invoke-Api -Method POST -Path "/api/billing/mock-sync" -Headers $appHeaders -Body @{
        scenario      = $scenario
        productId     = "plus_yearly"
        purchaseToken = $token
    }
}
function Invoke-MockRtdn([string]$messageId, [string]$notificationType, [string]$token) {
    return Invoke-Api -Method POST -Path "/api/billing/mock-rtdn" -Headers $appHeaders -Body @{
        messageId          = $messageId
        purchaseToken      = $token
        notificationType   = $notificationType
        productId          = "plus_yearly"
    }
}
function Get-Sub {
    return Invoke-Api -Method GET -Path "/api/billing/subscription" -Headers $appHeaders
}

# Fresh token path: PENDING first (no prior PURCHASED on this token)
$pendingTok = "mock:plus_yearly:PENDING:" + [guid]::NewGuid().ToString("N")
$rPendingOnly = Invoke-Api -Method POST -Path "/api/billing/mock-sync" -Headers $appHeaders -Body @{
    scenario = "PENDING"; productId = "plus_yearly"; purchaseToken = $pendingTok
}
if (Assert-BizOk $rPendingOnly "mock-sync PENDING-only") {
    Assert-Entitled $rPendingOnly.Data $false "none" "entitlement PENDING-only" | Out-Null
}

# Lifecycle on stable purchaseToken
$rPurchased = Invoke-MockSync "PURCHASED" $purchaseToken
if (Assert-BizOk $rPurchased "mock-sync PURCHASED") {
    Assert-Entitled $rPurchased.Data $true "active" "entitlement PURCHASED" | Out-Null
}

$rPendingAfter = Invoke-MockSync "PENDING" $purchaseToken
if (Assert-BizOk $rPendingAfter "mock-sync PENDING after PURCHASED") {
    # hard-clear entitlement (5aef74d): entitled=false, typically expired/none
    $ent = [bool]$rPendingAfter.Data.entitled
    if (-not $ent) {
        Write-Step "entitlement PENDING clears VIP" "PASS" "state=$($rPendingAfter.Data.state) entitled=False"
    } else {
        Write-Step "entitlement PENDING clears VIP" "FAIL" "state=$($rPendingAfter.Data.state) entitled=True"
    }
}

# Restore purchased for subsequent RTDN / cancel paths
$rPurchased2 = Invoke-MockSync "PURCHASED" $purchaseToken
Assert-BizOk $rPurchased2 "mock-sync PURCHASED restore" "for RTDN chain" | Out-Null

$rRenew = Invoke-MockSync "RENEW" $purchaseToken
if (Assert-BizOk $rRenew "mock-sync RENEW") {
    Assert-Entitled $rRenew.Data $true "active" "entitlement RENEW" | Out-Null
}

$rCancel = Invoke-MockSync "CANCEL" $purchaseToken
if (Assert-BizOk $rCancel "mock-sync CANCEL") {
    Assert-Entitled $rCancel.Data $true "active" "entitlement CANCEL (period remains)" | Out-Null
}

$rExpire = Invoke-MockSync "EXPIRE" $purchaseToken
if (Assert-BizOk $rExpire "mock-sync EXPIRE") {
    Assert-Entitled $rExpire.Data $false "expired" "entitlement EXPIRE" | Out-Null
}

# New token for REFUND (after expire, re-purchase then refund)
$purchaseToken = "mock:plus_yearly:PURCHASED:" + [guid]::NewGuid().ToString("N")
$null = Invoke-MockSync "PURCHASED" $purchaseToken
$rRefund = Invoke-MockSync "REFUND" $purchaseToken
if (Assert-BizOk $rRefund "mock-sync REFUND") {
    Assert-Entitled $rRefund.Data $false "expired" "entitlement REFUND" | Out-Null
}

# ---------- 3. RTDN mock-rtdn same-token + idempotent messageId ----------
# Fresh guest so prior mock-sync tokens (still active CANCEL/RENEW) do not mask EXPIRE/REFUND entitlement.
$equipmentId = "qa-e2e-rtdn-" + [guid]::NewGuid().ToString("N").Substring(0, 12)
$appHeaders = @{ "equipmentId" = $equipmentId }
$guest2 = Invoke-Api -Method POST -Path "/api/auth/guest" -Headers $appHeaders -Body @{
    deviceUuid = $equipmentId
    deviceType = "android"
    language   = "zh-CN"
}
if (-not ($guest2.Ok -and $guest2.Code -eq 200 -and $guest2.Data.token)) {
    Write-Step "AUTH guest (RTDN isolation)" "FAIL" "code=$($guest2.Code) msg=$($guest2.Message)"
} else {
    $token = [string]$guest2.Data.token
    $userId = $guest2.Data.user.id
    $appHeaders["Token"] = $token
    Write-Step "AUTH guest (RTDN isolation)" "PASS" "userId=$userId"
}

$rtdnCases = @(
    @{ Name = "RTDN RENEW";  Type = "SUBSCRIPTION_RENEWED";  Entitled = $true;  State = "active" },
    @{ Name = "RTDN CANCEL"; Type = "SUBSCRIPTION_CANCELED"; Entitled = $true;  State = "active" },
    @{ Name = "RTDN EXPIRE"; Type = "SUBSCRIPTION_EXPIRED";  Entitled = $false; State = "expired" }
)
# One purchaseToken for RENEW → CANCEL → EXPIRE so earlier active rows cannot mask EXPIRE.
$purchaseToken = "mock:plus_yearly:PURCHASED:" + [guid]::NewGuid().ToString("N")
$seed0 = Invoke-MockSync "PURCHASED" $purchaseToken
Assert-BizOk $seed0 "seed RTDN chain PURCHASED" | Out-Null
foreach ($c in $rtdnCases) {
    $mid = "msg-" + ($c.Type.ToLower()) + "-" + [guid]::NewGuid().ToString("N")
    $rr = Invoke-MockRtdn $mid ([string]$c.Type) $purchaseToken
    if (Assert-BizOk $rr $c.Name) {
        $sub = Get-Sub
        $payload = $(if ($sub.Data) { $sub.Data } else { $rr.Data })
        Assert-Entitled $payload ([bool]$c.Entitled) ([string]$c.State) ("entitlement " + $c.Name) | Out-Null
    }
}

# REFUND via RTDN: new token after EXPIRE (prior chain already expired)
$purchaseToken = "mock:plus_yearly:PURCHASED:" + [guid]::NewGuid().ToString("N")
$seedRefund = Invoke-MockSync "PURCHASED" $purchaseToken
Assert-BizOk $seedRefund "seed RTDN REFUND PURCHASED" | Out-Null
$midRefund = "msg-refund-" + [guid]::NewGuid().ToString("N")
$rrRefund = Invoke-MockRtdn $midRefund "SUBSCRIPTION_REFUND" $purchaseToken
if (Assert-BizOk $rrRefund "RTDN REFUND") {
    $subR = Get-Sub
    Assert-Entitled $(if ($subR.Data) { $subR.Data } else { $rrRefund.Data }) $false "expired" "entitlement RTDN REFUND" | Out-Null
}

# Idempotent: same messageId x3 RENEWED
$purchaseToken = "mock:plus_yearly:PURCHASED:" + [guid]::NewGuid().ToString("N")
$null = Invoke-MockSync "PURCHASED" $purchaseToken
$midIdem = "msg-idem-" + [guid]::NewGuid().ToString("N")
$idemOk = $true
for ($i = 1; $i -le 3; $i++) {
    $ri = Invoke-MockRtdn $midIdem "SUBSCRIPTION_RENEWED" $purchaseToken
    if (-not ($ri.Ok -and $ri.Code -eq 200 -and $ri.Success)) {
        $idemOk = $false
        Write-Step ("RTDN idempotent #$i") "FAIL" "code=$($ri.Code) msg=$($ri.Message)"
    }
}
if ($idemOk) {
    Write-Step "RTDN idempotent messageId x3" "PASS" "messageId=$midIdem all success"
}

# ---------- 4. Exception recovery ----------
# PENDING → PURCHASED
$purchaseToken = "mock:plus_yearly:PENDING:" + [guid]::NewGuid().ToString("N")
$rP1 = Invoke-MockSync "PENDING" $purchaseToken
$rP2 = Invoke-MockSync "PURCHASED" $purchaseToken
if ((Assert-BizOk $rP1 "recovery PENDING") -and (Assert-BizOk $rP2 "recovery PENDING→PURCHASED")) {
    Assert-Entitled $rP2.Data $true "active" "entitlement PENDING→PURCHASED" | Out-Null
}

# webhook failed→retry: BillingEventRetryJob is placeholder no-op
Write-Step "webhook failed→retry job" "SKIP" "BillingEventRetryJob is no-op placeholder; re-call mock-rtdn on failed row is the local recovery path"

# force-sync (manage) - deferred to manage section

# Redis lock / single @Scheduled entrypoint smoke
$schedFile = $null
if ($RepoRoot) {
    $schedFile = Join-Path $RepoRoot "senior-post-api\biz\src\main\java\cn\nine\pros\post\biz\schedule\ScheduledTaskEntrypoints.java"
}
if ($schedFile -and (Test-Path $schedFile)) {
    $hits = @()
    Get-ChildItem (Join-Path $RepoRoot "senior-post-api\biz\src\main\java") -Recurse -Filter "*.java" -ErrorAction SilentlyContinue |
        ForEach-Object {
            $m = Select-String -Path $_.FullName -Pattern "@Scheduled" -SimpleMatch -ErrorAction SilentlyContinue
            if ($m) { $hits += $_.FullName }
        }
    $unique = $hits | Select-Object -Unique
    if ((@($unique).Count -eq 1) -and ("$($unique | Select-Object -First 1)" -like "*ScheduledTaskEntrypoints.java")) {
        Write-Step "@Scheduled single entrypoint" "PASS" "only ScheduledTaskEntrypoints.java"
    } else {
        Write-Step "@Scheduled single entrypoint" "FAIL" ("files=" + ($unique -join "; "))
    }
} else {
    Write-Step "@Scheduled single entrypoint" "SKIP" "repo sources not found next to script"
}

# Redis lock SET NX smoke (docker redis if available)
$redisOk = $false
try {
    $docker = Get-Command docker -ErrorAction SilentlyContinue
    if ($docker) {
        $probeKey = "schedule:lock:qaE2eProbe"
        $setOut = docker exec senior-golden-redis-1 redis-cli SET $probeKey "1" EX 10 NX 2>$null
        $getOut = docker exec senior-golden-redis-1 redis-cli GET $probeKey 2>$null
        $set2 = docker exec senior-golden-redis-1 redis-cli SET $probeKey "2" EX 10 NX 2>$null
        docker exec senior-golden-redis-1 redis-cli DEL $probeKey 2>$null | Out-Null
        if (("$setOut".Trim() -eq "OK") -and ("$getOut".Trim() -eq "1") -and ([string]::IsNullOrWhiteSpace("$set2") -or "$set2".Trim() -eq "")) {
            Write-Step "Redis job lock NX smoke" "PASS" "SET NX blocks second holder (DistributedJobLock key shape)"
            $redisOk = $true
        } else {
            Write-Step "Redis job lock NX smoke" "FAIL" "set=$setOut get=$getOut set2=$set2"
            $redisOk = $true
        }
    }
} catch {
    # fall through to skip
}
if (-not $redisOk) {
    Write-Step "Redis job lock NX smoke" "SKIP" "docker/redis not reachable from this shell"
}
Write-Step "multi-node job exclusivity" "SKIP" "only one API container locally; Redis NX documents the multi-instance guard"

# ---------- 5. FCM outbox letter pushes + payment ban ----------
$pushTok = Invoke-Api -Method POST -Path "/api/device/push-token" -Headers $appHeaders -Body @{
    platform = "android"
    token    = ("fcm-mock-" + [guid]::NewGuid().ToString("N"))
    enabled  = $true
}
# registerPushToken returns void → code 200 success empty data
if ($pushTok.Ok -and $pushTok.Code -eq 200) {
    Write-Step "push-token register" "PASS" ""
} else {
    Write-Step "push-token register" "FAIL" "code=$($pushTok.Code) msg=$($pushTok.Message)"
}

foreach ($ev in @("letter_matched_in_transit", "letter_arrived")) {
    $letterId = if ($ev -eq "letter_matched_in_transit") { 910001 } else { 910002 }
    $enq = Invoke-Api -Method POST -Path "/api/push/mock-enqueue" -Headers $appHeaders -Body @{
        eventType  = $ev
        letterId   = $letterId
        triggerJob = $true
    }
    if (Assert-BizOk $enq ("mock-enqueue " + $ev)) {
        $d = $enq.Data
        $delN = 0
        if ($d.deliveries) { $delN = @($d.deliveries).Count }
        $statusOk = $false
        if ($delN -gt 0) {
            $first = @($d.deliveries)[0]
            $statusOk = ($first.sendStatus -eq "mock_sent" -and $first.provider -eq "mock")
        }
        if ($statusOk -or ([int]$d.jobSent -ge 1)) {
            Write-Step ("delivery " + $ev) "PASS" "outboxId=$($d.outboxId) delN=$delN jobSent=$($d.jobSent)"
        } else {
            Write-Step ("delivery " + $ev) "FAIL" "outboxId=$($d.outboxId) delN=$delN jobSent=$($d.jobSent) raw deliveries missing mock_sent"
        }
    }
}

$banTypes = @("purchase_success", "refund", "subscription_renewed", "billing_event")
$banAll = $true
foreach ($bt in $banTypes) {
    $ban = Invoke-Api -Method POST -Path "/api/push/mock-enqueue" -Headers $appHeaders -Body @{
        eventType  = $bt
        letterId   = 1
        triggerJob = $false
    }
    # business reject: success=false, typically code 4501 (HTTP may still be 200)
    if ($ban.Success -eq $false -and $ban.Code -ne 200) {
        Write-Step ("payment ban " + $bt) "PASS" "code=$($ban.Code)"
    } elseif ($ban.Success -eq $false) {
        Write-Step ("payment ban " + $bt) "PASS" "code=$($ban.Code) msg=$($ban.Message)"
    } else {
        Write-Step ("payment ban " + $bt) "FAIL" "expected reject, got success code=$($ban.Code)"
        $banAll = $false
    }
}
if ($banAll) { } # already stepped

# ---------- 6. Manage readonly purchase + batch-status (optional) ----------
if ([string]::IsNullOrWhiteSpace($AdminPassword)) {
    Write-Step "manage purchases/paging" "SKIP" "set ADMIN_PASSWORD to exercise manage section"
    Write-Step "manage products/batch-status" "SKIP" "set ADMIN_PASSWORD to exercise manage section"
    Write-Step "manage purchases/force-sync" "SKIP" "set ADMIN_PASSWORD to exercise manage section"
} else {
    $adminLogin = Invoke-Api -Method POST -Path "/webapi/auth/login" -Body @{
        username = $AdminUser
        password = $AdminPassword
    }
    $adminToken = $null
    if ($adminLogin.Ok -and $adminLogin.Code -eq 200 -and $adminLogin.Data) {
        if ($adminLogin.Data.token) { $adminToken = [string]$adminLogin.Data.token }
        elseif ($adminLogin.Data.accessToken) { $adminToken = [string]$adminLogin.Data.accessToken }
        # Map login may nest differently
        if (-not $adminToken -and $adminLogin.Raw -match '"token"\s*:\s*"([^"]+)"') {
            $adminToken = $Matches[1]
        }
    }
    if (-not $adminToken) {
        Write-Step "manage admin login" "FAIL" "code=$($adminLogin.Code) msg=$($adminLogin.Message) - check ADMIN_PASSWORD"
    } else {
        Write-Step "manage admin login" "PASS" "user=$AdminUser"
        $adminHeaders = @{ "Token" = $adminToken }
        $pageBody = @{
            page = @{ page = 1; size = 10 }
            userId = $userId
        }
        $paging = Invoke-Api -Method POST -Path "/webapi/commerce/purchases/paging" -Headers $adminHeaders -Body $pageBody
        if (Assert-BizOk $paging "manage purchases/paging") {
            $total = $paging.Data.total
            $recs = @($paging.Data.records)
            Write-Step "manage purchases records" "PASS" "total=$total n=$($recs.Count) (token masked expected)"
            $purchaseId = $null
            if ($recs.Count -gt 0) { $purchaseId = $recs[0].id }
            if ($purchaseId) {
                $fs = Invoke-Api -Method POST -Path "/webapi/commerce/purchases/force-sync" -Headers $adminHeaders -Body @{
                    purchaseId = $purchaseId
                }
                if ($fs.Ok -and $fs.Code -eq 200 -and $fs.Success) {
                    Write-Step "manage force-sync" "PASS" "purchaseId=$purchaseId synced=$($fs.Data.synced)"
                } else {
                    Write-Step "manage force-sync" "FAIL" "code=$($fs.Code) msg=$($fs.Message)"
                }
            } else {
                Write-Step "manage force-sync" "SKIP" "no purchase rows for userId=$userId"
            }
        }
        $prodPage = Invoke-Api -Method POST -Path "/webapi/commerce/products/paging" -Headers $adminHeaders -Body @{
            page = @{ page = 1; size = 5 }
        }
        if (Assert-BizOk $prodPage "manage products/paging") {
            $prodRecs = @($prodPage.Data.records)
            if ($prodRecs.Count -gt 0) {
                $productId = $prodRecs[0].id
                $cur = [int]$prodRecs[0].status
                $target = if ($cur -eq 1) { 0 } else { 1 }
                $bs1 = Invoke-Api -Method POST -Path "/webapi/commerce/products/batch-status" -Headers $adminHeaders -Body @{
                    ids = @($productId); status = $target
                }
                $bs2 = Invoke-Api -Method POST -Path "/webapi/commerce/products/batch-status" -Headers $adminHeaders -Body @{
                    ids = @($productId); status = $cur
                }
                if (($bs1.Ok -and $bs1.Code -eq 200 -and $bs1.Success) -and ($bs2.Ok -and $bs2.Code -eq 200 -and $bs2.Success)) {
                    Write-Step "manage products/batch-status" "PASS" "prodId=$productId toggled $cur↔$target restored"
                } else {
                    Write-Step "manage products/batch-status" "FAIL" "off/on code=$($bs1.Code)/$($bs2.Code) msg=$($bs1.Message)/$($bs2.Message)"
                }
            } else {
                Write-Step "manage products/batch-status" "SKIP" "no products"
            }
        }
    }
}

# ---------- Real Play / sandbox skips ----------
Write-Step "real Google Play IAP" "SKIP" "not available in local mock harness"
Write-Step "real Play RTDN Pub/Sub" "SKIP" "use mock-rtdn only"
Write-Step "real FCM / Google login" "SKIP" "use MockFcmSender + guest auth"

Write-Host ""
Write-Host "=== Summary PASS=$PassCount FAIL=$FailCount SKIP=$SkipCount ===" -ForegroundColor Cyan
if ($FailCount -gt 0) {
    Write-Host "RESULT: FAIL" -ForegroundColor Red
    exit 1
}
Write-Host "RESULT: PASS" -ForegroundColor Green
exit 0







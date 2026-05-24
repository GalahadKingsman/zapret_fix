# Collects provider diagnostics for custom zapret strategy tuning.
# Run twice: once with zapret OFF, once with zapret ON (same strategy you normally use).
#
# Usage (Admin PowerShell):
#   cd "C:\path\to\zapret-discord-youtube\utils"
#   powershell -ExecutionPolicy Bypass -File ".\collect-provider-diagnostics.ps1" -ZapretState off
#   powershell -ExecutionPolicy Bypass -File ".\collect-provider-diagnostics.ps1" -ZapretState on

param(
    [ValidateSet("off", "on", "unknown")]
    [string]$ZapretState = "unknown"
)

$ErrorActionPreference = "Continue"
$rootDir = Split-Path $PSScriptRoot -Parent
$listsDir = Join-Path $rootDir "lists"
$utilsDir = Join-Path $rootDir "utils"
$outDir = Join-Path $utilsDir "diagnostics"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

$ts = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$outFile = Join-Path $outDir "provider-report_${ZapretState}_$ts.txt"

function Write-Section([string]$Title) {
    $line = ("=" * 60)
    Add-Content $outFile ""
    Add-Content $outFile $line
    Add-Content $outFile $Title
    Add-Content $outFile $line
}

function Try-Run([scriptblock]$Block, [string]$Label) {
    Add-Content $outFile ""
    Add-Content $outFile "--- $Label ---"
    try {
        $result = & $Block 2>&1 | Out-String
        if ([string]::IsNullOrWhiteSpace($result)) { Add-Content $outFile "(no output)" }
        else { Add-Content $outFile $result.TrimEnd() }
    } catch {
        Add-Content $outFile "ERROR: $($_.Exception.Message)"
    }
}

function Get-IpsetStatus {
    $listFile = Join-Path $listsDir "ipset-all.txt"
    if (-not (Test-Path $listFile)) { return "missing" }
    $lines = @(Get-Content $listFile | Where-Object { $_.Trim() -ne "" })
    if ($lines.Count -eq 0) { return "any" }
    if ($lines -match "203\.0\.113\.113/32") { return "none" }
    return "loaded ($($lines.Count) entries)"
}

function Get-GameFilterStatus {
    $flag = Join-Path $rootDir ".service\game_filter.enabled"
    if (-not (Test-Path $flag)) { return "disabled" }
    $mode = (Get-Content $flag -ErrorAction SilentlyContinue | Select-Object -First 1).Trim()
    if ($mode) { return "enabled ($mode)" }
    return "enabled"
}

function Get-ZapretVersion {
    $versionFile = Join-Path $rootDir ".service\version.txt"
    if (Test-Path $versionFile) { return (Get-Content $versionFile -Raw).Trim() }
    $serviceBat = Join-Path $rootDir "service.bat"
    if (Test-Path $serviceBat) {
        $m = Select-String -Path $serviceBat -Pattern 'LOCAL_VERSION=(.+)' | Select-Object -First 1
        if ($m) { return $m.Matches[0].Groups[1].Value.Trim('"') }
    }
    return "unknown"
}

function Test-HttpQuick([string]$Url, [int]$TimeoutSec = 10) {
    try {
        $r = Invoke-WebRequest -Uri $Url -Method Head -TimeoutSec $TimeoutSec -UseBasicParsing
        return "OK HTTP $($r.StatusCode)"
    } catch {
        $msg = $_.Exception.Message
        if ($_.Exception.Response) {
            $msg = "HTTP $([int]$_.Exception.Response.StatusCode) $msg"
        }
        return "FAIL $msg"
    }
}

# --- start report ---
"" | Out-File $outFile -Encoding UTF8
Write-Section "ZAPRET PROVIDER DIAGNOSTICS"
Add-Content $outFile "Generated: $(Get-Date -Format o)"
Add-Content $outFile "Zapret state for this run: $ZapretState"
Add-Content $outFile "Report file: $outFile"
Add-Content $outFile ""
Add-Content $outFile "Share BOTH reports (off + on) when asking for a custom strategy."

Write-Section "USER INPUT (fill manually if empty)"
Add-Content $outFile @"
Provider (e.g. Rostelecom, Dom.ru, MTS):
City / region:
Strategy .bat file used:
Browser (Chrome / Firefox / Yandex / other):
Does YouTube work WITHOUT zapret at all? (yes/no):
Does Discord work WITH zapret? (yes/no):
VPN tested for YouTube only? Result:
"@

Write-Section "ZAPRET INSTALL"
Add-Content $outFile "Version: $(Get-ZapretVersion)"
Add-Content $outFile "Install path: $rootDir"
Add-Content $outFile "IPSet filter: $(Get-IpsetStatus)"
Add-Content $outFile "Game filter: $(Get-GameFilterStatus)"
Add-Content $outFile "winws.exe running: $(
    if (Get-Process winws -ErrorAction SilentlyContinue) { 'yes' } else { 'no' }
)"

Try-Run {
    $reg = Get-ItemProperty "HKLM:\System\CurrentControlSet\Services\zapret" -ErrorAction SilentlyContinue
    if ($reg.'zapret-discord-youtube') { "Installed service strategy: $($reg.'zapret-discord-youtube')" }
    else { "No zapret service strategy in registry" }
} "Service strategy (registry)"

Write-Section "NETWORK / DNS"
Try-Run { ipconfig /all } "ipconfig /all"
Try-Run { Get-DnsClientServerAddress -AddressFamily IPv4 | Format-Table -AutoSize | Out-String } "DNS servers (IPv4)"
Try-Run { netsh interface tcp show global } "TCP global settings"

Write-Section "DNS RESOLUTION"
$hosts = @(
    "www.youtube.com",
    "youtube.com",
    "googlevideo.com",
    "redirector.googlevideo.com",
    "i.ytimg.com",
    "www.gstatic.com",
    "discord.com"
)
foreach ($h in $hosts) {
    Try-Run { nslookup $h 2>&1 } "nslookup $h"
}

Write-Section "CONNECTIVITY (HEAD requests, 10s timeout)"
$urls = @(
    "https://www.youtube.com",
    "https://www.google.com",
    "https://i.ytimg.com",
    "https://redirector.googlevideo.com",
    "https://www.gstatic.com",
    "https://discord.com",
    "https://www.cloudflare.com"
)
foreach ($u in $urls) {
    Add-Content $outFile "$u -> $(Test-HttpQuick $u)"
}

Write-Section "PING to resolved YouTube / Google CDN"
Try-Run {
    $ip = [System.Net.Dns]::GetHostAddresses("www.youtube.com") |
        Where-Object { $_.AddressFamily -eq 'InterNetwork' } |
        Select-Object -First 1
    if ($ip) {
        ping -n 4 $ip.IPAddressToString
    } else { "No IPv4 for www.youtube.com" }
} "ping www.youtube.com (IPv4)"

Try-Run {
    $ip = [System.Net.Dns]::GetHostAddresses("redirector.googlevideo.com") |
        Where-Object { $_.AddressFamily -eq 'InterNetwork' } |
        Select-Object -First 1
    if ($ip) {
        "googlevideo IP: $($ip.IPAddressToString)"
        ping -n 4 $ip.IPAddressToString
    } else { "No IPv4 for redirector.googlevideo.com" }
} "ping redirector.googlevideo.com"

Write-Section "TRACEROUTE (first 15 hops)"
Try-Run {
    $ip = [System.Net.Dns]::GetHostAddresses("www.youtube.com") |
        Where-Object { $_.AddressFamily -eq 'InterNetwork' } |
        Select-Object -First 1
    if ($ip) { tracert -d -h 15 $ip.IPAddressToString } else { "skip" }
} "tracert to YouTube IP"

Write-Section "LIST FILES (counts)"
foreach ($f in @("list-google.txt", "list-general.txt", "list-exclude.txt", "ipset-all.txt")) {
    $p = Join-Path $listsDir $f
    if (Test-Path $p) {
        $n = (Get-Content $p | Where-Object { $_.Trim() -ne "" }).Count
        Add-Content $outFile "$f : $n lines"
    } else {
        Add-Content $outFile "$f : missing"
    }
}

Write-Section "BLOCKCHECK REMINDER"
Add-Content $outFile @"
Manual step (required for custom strategy):
1. Stop zapret completely
2. Download: https://github.com/bol-van/zapret-win-bundle
3. Run blockcheck\blockcheck.cmd as Admin
4. Domain: youtube.com
5. Enable: HTTPS 1.2, HTTPS 1.3, HTTP3/QUIC
6. Copy the FULL blockcheck output into a file named:
   utils\diagnostics\blockcheck-youtube.txt
7. Repeat for domain: googlevideo.com (if blockcheck allows)

Also run service.bat -> Run Tests -> Standard tests with zapret ON,
save the file from utils\test results\ and attach it.
"@

Write-Host ""
Write-Host "Done. Report saved to:" -ForegroundColor Green
Write-Host $outFile
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Run this script again with other zapret state (-ZapretState off / on)"
Write-Host "2. Run blockcheck (see report BLOCKCHECK section)"
Write-Host "3. Send: both provider-report_*.txt + blockcheck-youtube.txt + test results"

@echo off
chcp 65001 > nul
:: Check Telegram DNS + TCP reachability (run with zapret OFF first, then ON)

cd /d "%~dp0"

echo.
echo  Telegram diagnostics
echo  ====================
echo.

powershell -NoProfile -Command ^
  "$hosts = Join-Path $env:SystemRoot 'System32\drivers\etc\hosts';" ^
  "Write-Host '--- hosts file ---';" ^
  "if (Select-String -Path $hosts -Pattern 'api.telegram.org' -Quiet) { Write-Host '[OK] Telegram entries in hosts' } else { Write-Host '[!] Run setup-telegram-hosts.bat as Admin' -ForegroundColor Yellow };" ^
  "Write-Host '';" ^
  "Write-Host '--- DNS api.telegram.org (system) ---';" ^
  "try { Resolve-DnsName api.telegram.org -Type A -ErrorAction Stop | Format-Table Name,IPAddress -AutoSize } catch { Write-Host $_.Exception.Message -ForegroundColor Red };" ^
  "Write-Host '--- DNS api.telegram.org (8.8.8.8) ---';" ^
  "try { Resolve-DnsName api.telegram.org -Type A -Server 8.8.8.8 -ErrorAction Stop | Format-Table Name,IPAddress -AutoSize } catch { Write-Host $_.Exception.Message -ForegroundColor Red };" ^
  "Write-Host '';" ^
  "Write-Host '--- TCP to Telegram DC (149.154.167.220) ---';" ^
  "foreach ($p in 443,5222) { $r = Test-NetConnection -ComputerName 149.154.167.220 -Port $p -WarningAction SilentlyContinue; Write-Host ('149.154.167.220:' + $p + ' -> TcpTestSucceeded=' + $r.TcpTestSucceeded) };" ^
  "Write-Host '';" ^
  "Write-Host '--- HTTPS web.telegram.org ---';" ^
  "try { $x = Invoke-WebRequest -Uri 'https://web.telegram.org' -TimeoutSec 10 -UseBasicParsing; Write-Host ('HTTP ' + $x.StatusCode) } catch { Write-Host $_.Exception.Message -ForegroundColor Red }"

echo.
echo If DNS fails: setup-dns-megafon.bat + setup-telegram-hosts.bat (Admin)
echo If TCP fails with zapret OFF: provider blocks Telegram IPs (need MTProto filter)
echo If TCP OK but Desktop stuck: restart Telegram after restarting zapret
echo.
pause

@echo off
chcp 65001 > nul
echo.
echo  YouTube DNS test (PATH not required)
echo  ===================================
echo.

powershell -NoProfile -Command ^
  "$ErrorActionPreference='Continue';" ^
  "Write-Host '1) System DNS (youtube.com):' -ForegroundColor Cyan;" ^
  "try { Resolve-DnsName youtube.com -Type A -ErrorAction Stop | Format-Table Name,IPAddress -AutoSize } catch { Write-Host ('FAIL: ' + $_.Exception.Message) -ForegroundColor Red };" ^
  "Write-Host '';" ^
  "Write-Host '2) Google DNS 8.8.8.8 (youtube.com):' -ForegroundColor Cyan;" ^
  "try { Resolve-DnsName youtube.com -Type A -Server 8.8.8.8 -ErrorAction Stop | Format-Table Name,IPAddress -AutoSize } catch { Write-Host ('FAIL: ' + $_.Exception.Message) -ForegroundColor Red };" ^
  "Write-Host '';" ^
  "Write-Host '3) hosts file contains youtube.com:' -ForegroundColor Cyan;" ^
  "if (Select-String -Path $env:SystemRoot'\System32\drivers\etc\hosts' -Pattern 'youtube.com' -Quiet) { Write-Host 'YES' -ForegroundColor Green } else { Write-Host 'NO - run setup-youtube-hosts.bat' -ForegroundColor Yellow }"

echo.
pause

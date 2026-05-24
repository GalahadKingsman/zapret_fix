@echo off
chcp 65001 > nul
:: Fix DNS poisoning on Megafon / NetByNet / WIFIRE (router returns NXDOMAIN for youtube.com)
:: Run as Administrator

cd /d "%~dp0"

echo.
echo  MEGAFON / NETBYNET - fix DNS for YouTube
echo  =======================================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Run as Administrator!
    pause
    exit /b 1
)

for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "(Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.HardwareInterface } | Select-Object -First 1).Name"`) do set "ADAPTER=%%i"

if not defined ADAPTER (
    echo Could not detect active network adapter. Set DNS manually to 8.8.8.8 and 1.1.1.1
    pause
    exit /b 1
)

echo Active adapter: %ADAPTER%
echo Setting DNS: 8.8.8.8, 1.1.1.1
echo.

netsh interface ipv4 set dns name="%ADAPTER%" static 8.8.8.8 validate=no
netsh interface ipv4 add dns name="%ADAPTER%" 1.1.1.1 index=2 validate=no

ipconfig /flushdns >nul

echo --- Test via router DNS (was broken before) ---
nslookup youtube.com
echo.
echo --- Test via Google DNS 8.8.8.8 (must resolve) ---
nslookup youtube.com 8.8.8.8
echo.

findstr /I /C:"youtube.com" "%SystemRoot%\System32\drivers\etc\hosts" >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [!] youtube.com not in hosts file yet.
    echo     Also run: setup-youtube-hosts.bat
) else (
    echo [OK] youtube.com found in hosts file
)

echo.
echo Done. If nslookup 8.8.8.8 shows addresses - start zapret and open YouTube.
echo In browser enable Secure DNS (DoH): https://dns.google/dns-query
echo.
pause

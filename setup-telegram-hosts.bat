@echo off
chcp 65001 > nul
:: Append Telegram hosts (Desktop + Web). Run as Administrator.

cd /d "%~dp0"

echo.
echo  Telegram - hosts fix
echo  ====================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Run as Administrator!
    pause
    exit /b 1
)

set "HOSTS=%SystemRoot%\System32\drivers\etc\hosts"
set "SOURCE=%~dp0.service\hosts-telegram.txt"

if not exist "%SOURCE%" (
    echo Missing: %SOURCE%
    pause
    exit /b 1
)

findstr /I /C:"api.telegram.org" "%HOSTS%" >nul 2>&1
if %errorlevel%==0 (
    echo hosts already contains Telegram entries.
    notepad "%HOSTS%"
    pause
    exit /b 0
)

echo Adding Telegram block from hosts-telegram.txt ...
echo.>> "%HOSTS%"
echo # zapret-discord-youtube Telegram DNS fix>> "%HOSTS%"
type "%SOURCE%" >> "%HOSTS%"

"%SystemRoot%\System32\ipconfig.exe" /flushdns >nul
echo Done.
echo.
powershell -NoProfile -Command "try { Resolve-DnsName api.telegram.org -Type A -Server 8.8.8.8 -ErrorAction Stop | Format-Table Name,IPAddress -AutoSize } catch { Write-Host $_.Exception.Message }"
echo.
pause

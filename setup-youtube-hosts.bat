@echo off
chcp 65001 > nul
:: Append YouTube hosts entries (backup DNS fix when router poisons youtube.com)

cd /d "%~dp0"

echo.
echo  Append YouTube entries to hosts file
echo  ====================================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Run as Administrator!
    pause
    exit /b 1
)

set "HOSTS=%SystemRoot%\System32\drivers\etc\hosts"
set "SOURCE=%~dp0.service\hosts-youtube.txt"

if not exist "%SOURCE%" (
    echo Missing: %SOURCE%
    pause
    exit /b 1
)

findstr /I /C:"youtube.com" "%HOSTS%" >nul 2>&1
if %errorlevel%==0 (
    echo hosts already contains youtube.com entries.
    echo Open hosts in notepad to edit manually if needed.
    notepad "%HOSTS%"
    pause
    exit /b 0
)

echo Adding YouTube block from hosts-youtube.txt ...
echo.>> "%HOSTS%"
echo # zapret-discord-youtube YouTube DNS fix>> "%HOSTS%"
type "%SOURCE%" >> "%HOSTS%"

"%SystemRoot%\System32\ipconfig.exe" /flushdns >nul
echo Done. hosts updated.
echo.
powershell -NoProfile -Command "try { Resolve-DnsName youtube.com -Type A -ErrorAction Stop | Select-Object Name,IPAddress } catch { Write-Host $_.Exception.Message }"
echo.
pause

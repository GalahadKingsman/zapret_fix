@echo off
chcp 65001 > nul
:: Minimal WinDivert test - if this fails, problem is driver/admin, not strategy

if /I not "%~1"=="admin" (
    powershell -NoProfile -Command "Start-Process 'cmd.exe' -ArgumentList '/c \"\"%~f0\" admin\"' -Verb RunAs"
    exit /b
)

cd /d "%~dp0\bin"
if not exist "winws.exe" (
    echo [ERROR] winws.exe not found
    pause
    exit /b 1
)

taskkill /F /IM winws.exe >nul 2>&1
timeout /t 1 /nobreak >nul

echo.
echo Minimal WinDivert test ...
echo.

start "" /min winws.exe --wf-tcp=443 --wf-udp=443 --filter-tcp=443 --dpi-desync=fake --dpi-desync-repeats=1
timeout /t 3 /nobreak >nul

tasklist /FI "IMAGENAME eq winws.exe" 2>nul | find /I "winws.exe" >nul
if errorlevel 1 (
    echo [FAIL] winws exited immediately - likely "Access is denied".
    echo.
    echo Try:
    echo   1. Reboot PC
    echo   2. fix-windivert-access.bat
    echo   3. Run this test again
    echo   4. service.bat - Run Diagnostics
) else (
    taskkill /F /IM winws.exe >nul 2>&1
    echo [OK] WinDivert works. Run general Megafon ALL.bat
)

echo.
pause

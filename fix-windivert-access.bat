@echo off
chcp 65001 > nul
:: Fix WinDivert "Access is denied" (exit code 5)

if /I not "%~1"=="admin" (
    powershell -NoProfile -Command "Start-Process 'cmd.exe' -ArgumentList '/c \"\"%~f0\" admin\"' -Verb RunAs"
    exit /b
)

echo.
echo  WinDivert fix (Access denied / code 5)
echo  ===================================
echo.

echo [1] Stopping winws.exe ...
taskkill /F /IM winws.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo [2] Stopping conflicting services ...
for %%s in (WinDivert GoodbyeDPI discordfix_zapret winws1 winws2) do (
    net stop "%%s" >nul 2>&1
    sc stop "%%s" >nul 2>&1
    sc delete "%%s" >nul 2>&1
)
timeout /t 1 /nobreak >nul

echo [3] WinDivert drivers on system:
driverquery | find /I "Divert"
echo.

echo [4] Checking WinDivert driver file ...
if exist "%~dp0bin\WinDivert64.sys" (
    echo [OK] WinDivert64.sys found
) else (
    echo [ERROR] bin\WinDivert64.sys missing - reinstall zapret from release
    pause
    exit /b 1
)

echo.
echo IMPORTANT: After deleting WinDivert service, Windows often needs a REBOOT
echo before winws can load the driver again.
echo.
echo Next steps:
echo   1. Reboot PC now
echo   2. After reboot: test-windivert-minimal.bat
echo   3. If test OK: general Megafon ALL.bat
echo.
echo If minimal test still fails after reboot:
echo   - service.bat - Run Diagnostics
echo   - Disable VPN / GoodbyeDPI / other bypass tools
echo   - Add zapret folder to antivirus exclusions
echo.
pause

@echo off
chcp 65001 > nul
:: Fix WinDivert "Access is denied" (exit code 5)

echo.
echo  WinDivert fix (Access denied / code 5)
echo  ===================================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Run this file as Administrator!
    echo Right-click - Run as administrator
    pause
    exit /b 1
)

echo [1] Stopping winws.exe ...
taskkill /F /IM winws.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo [2] Stopping WinDivert service if present ...
net stop WinDivert >nul 2>&1
sc stop WinDivert >nul 2>&1
timeout /t 1 /nobreak >nul

echo [3] Removing stuck WinDivert service ...
sc delete WinDivert >nul 2>&1

echo [4] Checking WinDivert driver file ...
if exist "%~dp0bin\WinDivert64.sys" (
    echo [OK] WinDivert64.sys found
) else (
    echo [ERROR] bin\WinDivert64.sys missing - reinstall zapret from release
    pause
    exit /b 1
)

echo.
echo Done. Now run ONLY ONE strategy as Administrator:
echo   - general Megafon ALL.bat
echo   - or general (MEGAFON OREL).bat
echo.
echo Do NOT run debug-megafon-all.bat for daily use.
echo.
pause

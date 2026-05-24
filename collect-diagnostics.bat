@echo off
chcp 65001 > nul
cd /d "%~dp0"

echo.
echo  ZAPRET - сбор диагностики для настройки под провайдера
echo  =====================================================
echo.
echo  Запустите ДВА раза:
echo    1) С ВЫКЛЮЧЕННЫМ zapret (winws.exe закрыт)
echo    2) С ВКЛЮЧЕННЫМ zapret (ваша обычная стратегия)
echo.

set /p state="Zapret сейчас включен? (off/on): "
if /i not "%state%"=="off" if /i not "%state%"=="on" (
    echo Invalid. Use off or on.
    pause
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0utils\collect-provider-diagnostics.ps1" -ZapretState %state%

echo.
pause

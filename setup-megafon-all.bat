@echo off
chcp 65001 > nul
:: Full Megafon setup: DNS + YouTube + Telegram + zapret (Discord/YouTube/TG)

cd /d "%~dp0"

echo.
echo  MEGAFON - Discord + YouTube + Telegram
echo  ====================================
echo  1. DNS 8.8.8.8 / 1.1.1.1
echo  2. hosts YouTube
echo  3. hosts Telegram
echo  4. zapret: general (MEGAFON ALL).bat
echo.

call "%~dp0setup-dns-megafon.bat"
call "%~dp0setup-youtube-hosts.bat"
call "%~dp0setup-telegram-hosts.bat"
call "%~dp0general (MEGAFON ALL).bat"

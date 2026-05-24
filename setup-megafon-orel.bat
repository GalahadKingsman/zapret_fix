@echo off
chcp 65001 > nul
:: One-click Megafon/NetByNet YouTube setup: DNS + hosts + zapret strategy

cd /d "%~dp0"

echo.
echo  MEGAFON OREL - полная настройка YouTube
echo  =====================================
echo  1. DNS 8.8.8.8 / 1.1.1.1
echo  2. hosts для youtube.com
echo  3. zapret: general (MEGAFON OREL).bat
echo.

call "%~dp0setup-dns-megafon.bat"
call "%~dp0setup-youtube-hosts.bat"
call "%~dp0general (MEGAFON OREL).bat"

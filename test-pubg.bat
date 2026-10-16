@echo off
chcp 65001 > nul
:: PUBG diagnostics: runs groups of rules from general (MEGAFON).bat one at a time
:: After each mode try to start a match and note the result

if /I not "%~1"=="admin" (
    powershell -NoProfile -Command "Start-Process 'cmd.exe' -ArgumentList '/c \"\"%~f0\" admin\"' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
call service.bat load_user_lists

set "BIN=%~dp0bin\"
set "LISTS=%~dp0lists\"
set "EXCL=--hostlist-exclude="%LISTS%list-exclude.txt" --hostlist-exclude="%LISTS%list-exclude-user.txt" --ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt""

:menu
echo.
echo  PUBG test - choose mode, then start a match
echo  ===========================================
echo  1. Interception only, no desync   (WinDivert vs anti-cheat)
echo  2. Discord only                   (lines 25-26)
echo  3. Google / YouTube only          (lines 23, 27)
echo  4. list-general only              (lines 24, 28: Discord, Cloudflare, cloudfront)
echo  0. Stop winws and exit
echo.
set "choice="
set /p "choice=Mode: "

taskkill /IM winws.exe /F >nul 2>&1
timeout /t 1 /nobreak >nul
cd /d "%BIN%"

if "%choice%"=="1" (
    start "zapret-test" /min "%BIN%winws.exe" --wf-tcp=80,443,2053,2083,2087,2096,8443 --wf-udp=443,19294-19344,50000-50100
) else if "%choice%"=="2" (
    start "zapret-test" /min "%BIN%winws.exe" --wf-tcp=2053,2083,2087,2096,8443 --wf-udp=19294-19344,50000-50100 ^
--filter-udp=19294-19344,50000-50100 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-fake-discord="%BIN%quic_initial_www_google_com.bin" --dpi-desync-fake-stun="%BIN%quic_initial_www_google_com.bin" --dpi-desync-repeats=6 --new ^
--filter-tcp=2053,2083,2087,2096,8443 --hostlist-domains=discord.media --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_www_google_com.bin" --dpi-desync-fake-tls="%BIN%tls_clienthello_www_google_com.bin"
) else if "%choice%"=="3" (
    start "zapret-test" /min "%BIN%winws.exe" --wf-tcp=443 --wf-udp=443 ^
--filter-udp=443 --hostlist="%LISTS%list-google.txt" %EXCL% --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^
--filter-tcp=443 --hostlist="%LISTS%list-google.txt" --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_www_google_com.bin" --dpi-desync-fake-tls="%BIN%tls_clienthello_www_google_com.bin"
) else if "%choice%"=="4" (
    start "zapret-test" /min "%BIN%winws.exe" --wf-tcp=80,443 --wf-udp=443 ^
--filter-udp=443 --hostlist="%LISTS%list-general.txt" --hostlist="%LISTS%list-general-user.txt" %EXCL% --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^
--filter-tcp=80,443 --hostlist="%LISTS%list-general.txt" --hostlist="%LISTS%list-general-user.txt" %EXCL% --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=664 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_max_ru.bin" --dpi-desync-fake-tls="%BIN%stun.bin" --dpi-desync-fake-tls="%BIN%tls_clienthello_max_ru.bin" --dpi-desync-fake-http="%BIN%tls_clienthello_max_ru.bin"
) else (
    echo winws stopped
    exit /b
)

cd /d "%~dp0"
timeout /t 2 /nobreak >nul
tasklist /FI "IMAGENAME eq winws.exe" 2>nul | find /I "winws.exe" >nul
if errorlevel 1 (
    echo [ERROR] winws.exe exited immediately
) else (
    echo [OK] mode %choice% running - start a PUBG match now
)
goto menu

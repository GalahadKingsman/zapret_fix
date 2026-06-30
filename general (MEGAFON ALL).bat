@echo off
chcp 65001 > nul
:: Megafon: Discord + YouTube + Telegram (short relative paths - required for long Cyrillic install dirs)

if /I not "%~1"=="admin" (
    powershell -NoProfile -Command "Start-Process 'cmd.exe' -ArgumentList '/c \"\"%~f0\" admin\"' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
call service.bat status_zapret
call service.bat check_updates
call service.bat load_game_filter
call service.bat load_user_lists
echo:

set "BIN=%~dp0bin\"
set "L=..\lists\"

if not exist "%BIN%winws.exe" (
    echo [ERROR] winws.exe not found in bin\
    pause
    exit /b 1
)
if not exist "%~dp0lists\list-telegram.txt" (
    echo [ERROR] Missing lists\list-telegram.txt
    pause
    exit /b 1
)
if not exist "%~dp0lists\ipset-telegram.txt" (
    echo [ERROR] Missing lists\ipset-telegram.txt
    pause
    exit /b 1
)

taskkill /F /IM winws.exe >nul 2>&1
timeout /t 1 /nobreak >nul

cd /d "%BIN%"

start "zapret-megafon-all" /min winws.exe --wf-tcp=80,443,5222,2053,2083,2087,2096,8443,%GameFilterTCP% --wf-udp=443,19294-19344,50000-50100,%GameFilterUDP% --filter-udp=443 --hostlist="%L%list-google.txt" --hostlist="%L%list-general-user.txt" --hostlist-exclude="%L%list-exclude.txt" --hostlist-exclude="%L%list-exclude-user.txt" --ipset-exclude="%L%ipset-exclude.txt" --ipset-exclude="%L%ipset-exclude-user.txt" --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="quic_initial_www_google_com.bin" --new --filter-udp=443 --hostlist="%L%list-general.txt" --hostlist="%L%list-general-user.txt" --hostlist-exclude="%L%list-exclude.txt" --hostlist-exclude="%L%list-exclude-user.txt" --ipset-exclude="%L%ipset-exclude.txt" --ipset-exclude="%L%ipset-exclude-user.txt" --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="quic_initial_www_google_com.bin" --new --filter-udp=19294-19344,50000-50100 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-fake-discord="quic_initial_www_google_com.bin" --dpi-desync-fake-stun="quic_initial_www_google_com.bin" --dpi-desync-repeats=6 --new --filter-tcp=443 --hostlist="%L%list-telegram.txt" --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="tls_clienthello_www_google_com.bin" --dpi-desync-fake-tls="tls_clienthello_www_google_com.bin" --new --filter-tcp=80,443,5222 --ipset="%L%ipset-telegram.txt" --dpi-desync=fake,multisplit --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n3 --dpi-desync-split-seqovl=664 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="tls_clienthello_max_ru.bin" --dpi-desync-fake-tls="stun.bin" --dpi-desync-fake-tls="tls_clienthello_max_ru.bin" --dpi-desync-fake-http="tls_clienthello_max_ru.bin" --new --filter-udp=443 --ipset="%L%ipset-telegram.txt" --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n3 --dpi-desync-fake-unknown-udp="quic_initial_dbankcloud_ru.bin" --new --filter-tcp=2053,2083,2087,2096,8443 --hostlist-domains=discord.media --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="tls_clienthello_www_google_com.bin" --dpi-desync-fake-tls="tls_clienthello_www_google_com.bin" --new --filter-tcp=443 --hostlist="%L%list-google.txt" --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="tls_clienthello_www_google_com.bin" --dpi-desync-fake-tls="tls_clienthello_www_google_com.bin" --new --filter-tcp=80,443 --hostlist="%L%list-general.txt" --hostlist="%L%list-general-user.txt" --hostlist-exclude="%L%list-exclude.txt" --hostlist-exclude="%L%list-exclude-user.txt" --ipset-exclude="%L%ipset-exclude.txt" --ipset-exclude="%L%ipset-exclude-user.txt" --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=664 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="tls_clienthello_max_ru.bin" --dpi-desync-fake-tls="stun.bin" --dpi-desync-fake-tls="tls_clienthello_max_ru.bin" --dpi-desync-fake-http="tls_clienthello_max_ru.bin" --new --filter-udp=443 --ipset="%L%ipset-all.txt" --hostlist-exclude="%L%list-exclude.txt" --hostlist-exclude="%L%list-exclude-user.txt" --ipset-exclude="%L%ipset-exclude.txt" --ipset-exclude="%L%ipset-exclude-user.txt" --ipset-exclude="%L%ipset-exclude-google.txt" --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="quic_initial_www_google_com.bin" --new --filter-tcp=80,443,8443 --ipset="%L%ipset-all.txt" --hostlist-exclude="%L%list-exclude.txt" --hostlist-exclude="%L%list-exclude-user.txt" --ipset-exclude="%L%ipset-exclude.txt" --ipset-exclude="%L%ipset-exclude-user.txt" --ipset-exclude="%L%ipset-exclude-google.txt" --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=664 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="tls_clienthello_max_ru.bin" --dpi-desync-fake-tls="stun.bin" --dpi-desync-fake-tls="tls_clienthello_max_ru.bin" --dpi-desync-fake-http="tls_clienthello_max_ru.bin" --new --filter-tcp=%GameFilterTCP% --ipset="%L%ipset-all.txt" --ipset-exclude="%L%ipset-exclude.txt" --ipset-exclude="%L%ipset-exclude-user.txt" --ipset-exclude="%L%ipset-exclude-google.txt" --dpi-desync=fake,multisplit --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n4 --dpi-desync-split-seqovl=664 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="tls_clienthello_max_ru.bin" --dpi-desync-fake-tls="stun.bin" --dpi-desync-fake-tls="tls_clienthello_max_ru.bin" --dpi-desync-fake-http="tls_clienthello_max_ru.bin" --new --filter-udp=%GameFilterUDP% --ipset="%L%ipset-all.txt" --ipset-exclude="%L%ipset-exclude.txt" --ipset-exclude="%L%ipset-exclude-user.txt" --ipset-exclude="%L%ipset-exclude-google.txt" --dpi-desync=fake --dpi-desync-repeats=10 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="quic_initial_dbankcloud_ru.bin" --dpi-desync-cutoff=n4

timeout /t 2 /nobreak >nul
tasklist /FI "IMAGENAME eq winws.exe" 2>nul | find /I "winws.exe" >nul
if errorlevel 1 (
    echo.
    echo [ERROR] winws.exe exited. Run debug-megafon-all.bat to see error text.
    pause
    exit /b 1
)

echo [OK] zapret-megafon-all started

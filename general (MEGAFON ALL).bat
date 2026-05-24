@echo off
chcp 65001 > nul
:: Megafon: Discord + YouTube + Telegram (short paths for long Cyrillic install dirs)

cd /d "%~dp0"
call service.bat status_zapret
call service.bat check_updates
call service.bat load_game_filter
call service.bat load_user_lists
echo:

set "ROOT=%~dp0"
set "BIN=%ROOT%bin\"
set "L=%ROOT%lists\"

if not exist "%BIN%winws.exe" (
    echo [ERROR] winws.exe not found in bin\
    pause
    exit /b 1
)
if not exist "%L%list-telegram.txt" (
    echo [ERROR] Missing lists\list-telegram.txt - copy new files from repo
    pause
    exit /b 1
)
if not exist "%L%ipset-telegram.txt" (
    echo [ERROR] Missing lists\ipset-telegram.txt - copy new files from repo
    pause
    exit /b 1
)

cd /d "%BIN%"

start "zapret-megafon-all" /min "%BIN%winws.exe" --wf-tcp=80,443,5222,2053,2083,2087,2096,8443,%GameFilterTCP% --wf-udp=443,19294-19344,50000-50100,%GameFilterUDP% ^
--filter-udp=443 --hostlist="..\lists\list-google.txt" --hostlist="..\lists\list-general-user.txt" --hostlist-exclude="..\lists\list-exclude.txt" --hostlist-exclude="..\lists\list-exclude-user.txt" --ipset-exclude="..\lists\ipset-exclude.txt" --ipset-exclude="..\lists\ipset-exclude-user.txt" --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="quic_initial_www_google_com.bin" --new ^
--filter-udp=443 --hostlist="..\lists\list-telegram.txt" --hostlist-exclude="..\lists\list-exclude.txt" --hostlist-exclude="..\lists\list-exclude-user.txt" --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="quic_initial_www_google_com.bin" --new ^
--filter-udp=443 --hostlist="..\lists\list-general.txt" --hostlist="..\lists\list-general-user.txt" --hostlist-exclude="..\lists\list-exclude.txt" --hostlist-exclude="..\lists\list-exclude-user.txt" --ipset-exclude="..\lists\ipset-exclude.txt" --ipset-exclude="..\lists\ipset-exclude-user.txt" --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="quic_initial_www_google_com.bin" --new ^
--filter-udp=19294-19344,50000-50100 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-fake-discord="quic_initial_www_google_com.bin" --dpi-desync-fake-stun="quic_initial_www_google_com.bin" --dpi-desync-repeats=6 --new ^
--filter-tcp=80,443,5222 --hostlist="..\lists\list-telegram.txt" --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="tls_clienthello_www_google_com.bin" --dpi-desync-fake-tls="tls_clienthello_www_google_com.bin" --new ^
--filter-tcp=80,443,5222 --ipset="..\lists\ipset-telegram.txt" --dpi-desync=fake,multisplit --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n3 --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="tls_clienthello_www_google_com.bin" --dpi-desync-fake-tls="tls_clienthello_www_google_com.bin" --new ^
--filter-udp=443 --ipset="..\lists\ipset-telegram.txt" --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="quic_initial_www_google_com.bin" --new ^
--filter-tcp=2053,2083,2087,2096,8443 --hostlist-domains=discord.media --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="tls_clienthello_www_google_com.bin" --dpi-desync-fake-tls="tls_clienthello_www_google_com.bin" --new ^
--filter-tcp=443 --hostlist="..\lists\list-google.txt" --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="tls_clienthello_www_google_com.bin" --dpi-desync-fake-tls="tls_clienthello_www_google_com.bin" --new ^
--filter-tcp=80,443 --hostlist="..\lists\list-general.txt" --hostlist="..\lists\list-general-user.txt" --hostlist-exclude="..\lists\list-exclude.txt" --hostlist-exclude="..\lists\list-exclude-user.txt" --ipset-exclude="..\lists\ipset-exclude.txt" --ipset-exclude="..\lists\ipset-exclude-user.txt" --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=664 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="tls_clienthello_max_ru.bin" --dpi-desync-fake-tls="stun.bin" --dpi-desync-fake-tls="tls_clienthello_max_ru.bin" --dpi-desync-fake-http="tls_clienthello_max_ru.bin" --new ^
--filter-udp=443 --ipset="..\lists\ipset-all.txt" --hostlist-exclude="..\lists\list-exclude.txt" --hostlist-exclude="..\lists\list-exclude-user.txt" --ipset-exclude="..\lists\ipset-exclude.txt" --ipset-exclude="..\lists\ipset-exclude-user.txt" --ipset-exclude="..\lists\ipset-exclude-google.txt" --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="quic_initial_www_google_com.bin" --new ^
--filter-tcp=80,443,8443 --ipset="..\lists\ipset-all.txt" --hostlist-exclude="..\lists\list-exclude.txt" --hostlist-exclude="..\lists\list-exclude-user.txt" --ipset-exclude="..\lists\ipset-exclude.txt" --ipset-exclude="..\lists\ipset-exclude-user.txt" --ipset-exclude="..\lists\ipset-exclude-google.txt" --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=664 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="tls_clienthello_max_ru.bin" --dpi-desync-fake-tls="stun.bin" --dpi-desync-fake-tls="tls_clienthello_max_ru.bin" --dpi-desync-fake-http="tls_clienthello_max_ru.bin" --new ^
--filter-tcp=%GameFilterTCP% --ipset="..\lists\ipset-all.txt" --ipset-exclude="..\lists\ipset-exclude.txt" --ipset-exclude="..\lists\ipset-exclude-user.txt" --ipset-exclude="..\lists\ipset-exclude-google.txt" --dpi-desync=fake,multisplit --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n4 --dpi-desync-split-seqovl=664 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="tls_clienthello_max_ru.bin" --dpi-desync-fake-tls="stun.bin" --dpi-desync-fake-tls="tls_clienthello_max_ru.bin" --dpi-desync-fake-http="tls_clienthello_max_ru.bin" --new ^
--filter-udp=%GameFilterUDP% --ipset="..\lists\ipset-all.txt" --ipset-exclude="..\lists\ipset-exclude.txt" --ipset-exclude="..\lists\ipset-exclude-user.txt" --ipset-exclude="..\lists\ipset-exclude-google.txt" --dpi-desync=fake --dpi-desync-repeats=10 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="quic_initial_dbankcloud_ru.bin" --dpi-desync-cutoff=n4

if errorlevel 1 (
    echo [ERROR] Failed to start winws.exe
    pause
    exit /b 1
)

timeout /t 2 /nobreak >nul
tasklist /FI "IMAGENAME eq winws.exe" 2>nul | find /I "winws.exe" >nul
if errorlevel 1 (
    echo [ERROR] winws.exe exited immediately. Run debug-megafon-all.bat to see error text.
    pause
    exit /b 1
)

echo [OK] zapret-megafon-all started

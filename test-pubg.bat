@echo off
chcp 65001 > nul
:: PUBG game traffic strategies: each mode runs ONLY game rules (ports 1024-65535, any IP)
:: Lobby is not affected; after each mode try to start a match and note the result

if /I not "%~1"=="admin" (
    powershell -NoProfile -Command "Start-Process 'cmd.exe' -ArgumentList '/c \"\"%~f0\" admin\"' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
call service.bat load_user_lists

set "BIN=%~dp0bin\"
set "LISTS=%~dp0lists\"
set "WF=--wf-tcp=1024-65535 --wf-udp=1024-65535"
set "EXCL=--ipset-exclude="%LISTS%ipset-exclude.txt" --ipset-exclude="%LISTS%ipset-exclude-user.txt""
set "TCP_BASE=--filter-tcp=1024-65535 %EXCL% --dpi-desync=fake,multisplit --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n4 --dpi-desync-split-seqovl=664 --dpi-desync-split-pos=1 --dpi-desync-fooling=ts --dpi-desync-repeats=8 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_max_ru.bin" --dpi-desync-fake-tls="%BIN%tls_clienthello_max_ru.bin""

:menu
echo.
echo  PUBG game strategies - choose mode, then start a match
echo  =====================================================
echo  1. Current MEGAFON game rules       (control, expected to fail)
echo  2. UDP fake google quic, repeats 6  + current TCP
echo  3. UDP fake stun, repeats 11        + current TCP
echo  4. UDP fake + ipfrag2               + current TCP
echo  5. UDP fake google quic only        (no TCP processing)
echo  6. UDP fake google quic + TCP fake,fakedsplit badseq
echo  7. UDP fake google quic + TCP multisplit without fakes
echo  0. Stop winws and exit
echo.
set "choice="
set /p "choice=Mode: "

taskkill /IM winws.exe /F >nul 2>&1
timeout /t 1 /nobreak >nul
cd /d "%BIN%"

set "UDP_QUIC=--filter-udp=1024-65535 %EXCL% --dpi-desync=fake --dpi-desync-any-protocol=1 --dpi-desync-repeats=6 --dpi-desync-cutoff=n2 --dpi-desync-fake-unknown-udp="%BIN%quic_initial_www_google_com.bin""

if "%choice%"=="1" (
    start "zapret-test" /min "%BIN%winws.exe" %WF% %TCP_BASE% --new ^
--filter-udp=1024-65535 %EXCL% --dpi-desync=fake --dpi-desync-repeats=10 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%BIN%quic_initial_dbankcloud_ru.bin" --dpi-desync-cutoff=n4
) else if "%choice%"=="2" (
    start "zapret-test" /min "%BIN%winws.exe" %WF% %TCP_BASE% --new %UDP_QUIC%
) else if "%choice%"=="3" (
    start "zapret-test" /min "%BIN%winws.exe" %WF% %TCP_BASE% --new ^
--filter-udp=1024-65535 %EXCL% --dpi-desync=fake --dpi-desync-any-protocol=1 --dpi-desync-repeats=11 --dpi-desync-cutoff=n3 --dpi-desync-fake-unknown-udp="%BIN%stun.bin"
) else if "%choice%"=="4" (
    start "zapret-test" /min "%BIN%winws.exe" %WF% %TCP_BASE% --new ^
--filter-udp=1024-65535 %EXCL% --dpi-desync=fake,ipfrag2 --dpi-desync-any-protocol=1 --dpi-desync-repeats=6 --dpi-desync-cutoff=n3 --dpi-desync-ipfrag-pos-udp=8 --dpi-desync-fake-unknown-udp="%BIN%quic_initial_www_google_com.bin"
) else if "%choice%"=="5" (
    start "zapret-test" /min "%BIN%winws.exe" --wf-udp=1024-65535 %UDP_QUIC%
) else if "%choice%"=="6" (
    start "zapret-test" /min "%BIN%winws.exe" %WF% ^
--filter-tcp=1024-65535 %EXCL% --dpi-desync=fake,fakedsplit --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n4 --dpi-desync-split-pos=1 --dpi-desync-fooling=badseq --dpi-desync-repeats=6 --dpi-desync-fake-tls="%BIN%tls_clienthello_www_google_com.bin" --new %UDP_QUIC%
) else if "%choice%"=="7" (
    start "zapret-test" /min "%BIN%winws.exe" %WF% ^
--filter-tcp=1024-65535 %EXCL% --dpi-desync=multisplit --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n4 --dpi-desync-split-seqovl=568 --dpi-desync-split-pos=1 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_www_google_com.bin" --new %UDP_QUIC%
) else (
    echo winws stopped
    exit /b
)

cd /d "%~dp0"
timeout /t 2 /nobreak >nul
tasklist /FI "IMAGENAME eq winws.exe" 2>nul | find /I "winws.exe" >nul
if errorlevel 1 (
    echo [ERROR] winws.exe exited immediately - this mode has an unsupported option, skip it
) else (
    echo [OK] mode %choice% running - start a PUBG match now
)
goto menu

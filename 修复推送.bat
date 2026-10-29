@echo off
setlocal
cd /d "%~dp0"

set "GIT="
where git >nul 2>nul && set "GIT=git"
if not defined GIT if exist "%ProgramFiles%\Git\cmd\git.exe" set "GIT=%ProgramFiles%\Git\cmd\git.exe"
if not defined GIT if exist "%ProgramFiles(x86)%\Git\cmd\git.exe" set "GIT=%ProgramFiles(x86)%\Git\cmd\git.exe"
if not defined GIT if exist "%LocalAppData%\Programs\Git\cmd\git.exe" set "GIT=%LocalAppData%\Programs\Git\cmd\git.exe"
if not defined GIT if exist "%USERPROFILE%\.workbuddy\binaries\PortableGit\versions\1.2.0\cmd\git.exe" set "GIT=%USERPROFILE%\.workbuddy\binaries\PortableGit\versions\1.2.0\cmd\git.exe"

if not defined GIT (
  echo [Git not found]
  pause
  exit /b 1
)

echo.
echo [1/2] Pointing git at Clash for Windows (127.0.0.1:7890) ...
"%GIT%" config --global http.proxy http://127.0.0.1:7890
"%GIT%" config --global https.proxy http://127.0.0.1:7890
"%GIT%" config --global http.version HTTP/1.1
"%GIT%" config --global http.postBuffer 524288000
echo    done. (Make sure Clash is running!)
echo.
echo [2/2] Pushing (retry up to 4 times) ...
set /a tries=0
:retry
set /a tries+=1
echo    attempt %tries% ...
"%GIT%" push > "%~dp0push-log.txt" 2>&1
if not errorlevel 1 goto success
if %tries% lss 4 (
  timeout /t 6 /nobreak >nul
  goto retry
)
echo.
echo ============================================
echo   PUSH FAILED after 4 attempts
echo ============================================
echo See push-log.txt
echo Check: Clash is running, port 7890 works,
echo and github.com opens in your browser.
echo ============================================
pause
exit /b 1

:success
echo.
echo ============================================
echo   Publish OK!  (pushed successfully)
echo ============================================
echo Log: %~dp0push-log.txt
echo.
pause

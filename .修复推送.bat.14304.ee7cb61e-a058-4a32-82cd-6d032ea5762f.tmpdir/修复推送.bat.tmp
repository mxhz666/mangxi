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
echo [1/2] Applying network-friendly git settings ...
"%GIT%" config --global http.version HTTP/1.1
"%GIT%" config --global http.postBuffer 524288000
echo    done.
echo.
echo [2/2] Pushing ... (log -> push-log.txt)
"%GIT%" push > "%~dp0push-log.txt" 2>&1
set "RC=%errorlevel%"
echo.
echo ============================================
echo   push exit code: %RC%   (0 = OK, other = failed)
echo ============================================
echo Log: %~dp0push-log.txt
echo Tell the AI you ran this, then it will read push-log.txt
echo.
pause

@echo off
setlocal
cd /d "%~dp0"

echo.
echo ============================================
echo    MANGXI Studio - Publish
echo ============================================
echo.

echo [1/2] Building works list ...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\build.ps1"
if errorlevel 1 (
  echo.
  echo Build failed. See messages above.
  pause
  exit /b 1
)

REM ---- find git ----
set "GIT="
where git >nul 2>nul && set "GIT=git"
if not defined GIT if exist "%ProgramFiles%\Git\cmd\git.exe" set "GIT=%ProgramFiles%\Git\cmd\git.exe"
if not defined GIT if exist "%ProgramFiles(x86)%\Git\cmd\git.exe" set "GIT=%ProgramFiles(x86)%\Git\cmd\git.exe"
if not defined GIT if exist "%LocalAppData%\Programs\Git\cmd\git.exe" set "GIT=%LocalAppData%\Programs\Git\cmd\git.exe"
if not defined GIT if exist "%USERPROFILE%\.workbuddy\binaries\PortableGit\versions\1.2.0\cmd\git.exe" set "GIT=%USERPROFILE%\.workbuddy\binaries\PortableGit\versions\1.2.0\cmd\git.exe"
if not defined GIT (
  echo.
  echo [Git not found] Please install Git: https://git-scm.com/download/win
  pause
  exit /b 1
)

echo.
echo [2/2] Publishing to GitHub ...
"%GIT%" remote get-url origin >nul 2>nul
if errorlevel 1 (
  echo.
  echo Not connected to GitHub yet. Run the CONNECT script first.
  echo You can still view locally with the PREVIEW script.
  pause
  exit /b 0
)

"%GIT%" add -A
"%GIT%" -c core.quotepath=false commit -m "update works"
"%GIT%" push
if errorlevel 1 (
  echo.
  echo Push failed (attempt 1). Retrying in 5 seconds ...
  timeout /t 5 /nobreak >nul
  "%GIT%" push
)
if errorlevel 1 (
  echo.
  echo ============================================
  echo   PUSH FAILED
  echo ============================================
  echo Please read the lines above (network / login / repo).
  echo If it says "unable to access" or "timed out", it is a network problem.
  echo Your works are saved locally anyway; just run this again later.
  echo ============================================
) else (
  echo.
  echo Publish OK! Wait 1-2 minutes, then open your website URL.
)
echo.
pause

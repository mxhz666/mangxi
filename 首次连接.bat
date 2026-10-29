@echo off
setlocal
cd /d "%~dp0"

echo.
echo ============================================
echo    MANGXI Studio - Connect to GitHub
echo    (run this only once)
echo ============================================
echo.

REM ---- find git ----
set "GIT="
where git >nul 2>nul && set "GIT=git"
if not defined GIT if exist "%ProgramFiles%\Git\cmd\git.exe" set "GIT=%ProgramFiles%\Git\cmd\git.exe"
if not defined GIT if exist "%ProgramFiles(x86)%\Git\cmd\git.exe" set "GIT=%ProgramFiles(x86)%\Git\cmd\git.exe"
if not defined GIT if exist "%LocalAppData%\Programs\Git\cmd\git.exe" set "GIT=%LocalAppData%\Programs\Git\cmd\git.exe"
if not defined GIT if exist "%USERPROFILE%\.workbuddy\binaries\PortableGit\versions\1.2.0\cmd\git.exe" set "GIT=%USERPROFILE%\.workbuddy\binaries\PortableGit\versions\1.2.0\cmd\git.exe"
if not defined GIT (
  echo [Git not found] Please install Git: https://git-scm.com/download/win
  echo Then double-click this file again.
  pause
  exit /b 1
)

REM ---- set commit identity + credential helper ----
REM commit needs user.name / user.email; push needs a credential helper.
"%GIT%" config --global user.name "MANGXI"
"%GIT%" config --global user.email "mxhz666@users.noreply.github.com"
"%GIT%" config --global credential.helper manager

echo Enter your info:
echo.
set /p GH_USER=  GitHub username: 
set /p GH_REPO=  Repository name: 

if "%GH_USER%"=="" ( echo Username is empty. & pause & exit /b 1 )
if "%GH_REPO%"=="" ( echo Repo name is empty. & pause & exit /b 1 )

echo.
echo Connecting to https://github.com/%GH_USER%/%GH_REPO%.git ...
echo If a browser opens, click Authorize / Login.
echo.

"%GIT%" init
"%GIT%" remote remove origin >nul 2>nul
"%GIT%" remote add origin https://github.com/%GH_USER%/%GH_REPO%.git
"%GIT%" add -A
"%GIT%" -c core.quotepath=false commit -m "init"
"%GIT%" branch -M main
"%GIT%" push -u origin main

if errorlevel 1 (
  echo.
  echo Push FAILED. See the messages above.
  echo Common causes: wrong repo name / not logged in / network issue.
) else (
  echo.
  echo Push OK! Next: open your repo, Settings - Pages - Source "main" - Save.
)
echo.
pause

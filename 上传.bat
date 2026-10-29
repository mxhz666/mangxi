@echo off
setlocal
cd /d "%~dp0"

if ""=="%~1" goto :publish

call :copyfile "%~1"
goto :publish

:copyfile
echo.
echo Dragged file: %~1
echo.
echo Choose the category:
echo   1 = apparel     (fashion)
echo   2 = brand       (brand TVC)
echo   3 = chinese     (new chinese)
echo   4 = american    (retro american)
echo   5 = ecommerce   (e-commerce)
echo.
set "CATNUM="
set /p CATNUM=Enter 1-5 (default 2): 
set "CAT=brand"
if "%CATNUM%"=="1" set "CAT=apparel"
if "%CATNUM%"=="3" set "CAT=chinese"
if "%CATNUM%"=="4" set "CAT=american"
if "%CATNUM%"=="5" set "CAT=ecommerce"
if not exist "assets\%CAT%" mkdir "assets\%CAT%"
copy /y "%~1" "assets\%CAT%\" >nul
if errorlevel 1 (
  echo [ERROR] Copy failed.
  pause
  exit /b 1
)
echo Copied into assets\%CAT%\
goto :eof

:publish
echo.
echo If you double-clicked (no file), everything already in assets will be published.
echo.
echo Building + publishing ...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\build.ps1"
if errorlevel 1 (
  echo Build failed. See messages above.
  pause
  exit /b 1
)

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

"%GIT%" remote get-url origin >nul 2>nul
if errorlevel 1 (
  echo.
  echo Not connected to GitHub yet. Run the CONNECT script first.
  pause
  exit /b 0
)

"%GIT%" add -A
"%GIT%" -c core.quotepath=false commit -m "upload works"
"%GIT%" push
if errorlevel 1 (
  echo.
  echo Push failed. See messages above.
) else (
  echo.
  echo Publish OK! Wait 1-2 minutes, then refresh your website.
)
echo.
pause

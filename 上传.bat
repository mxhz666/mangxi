@echo off
setlocal
cd /d "%~dp0"

set "VIDEO="
set "IMAGE="

if "%~1"=="" goto :interactive

:findargs
if "%~1"=="" goto :argsdone
if not defined VIDEO (
  for %%e in (mp4 mov webm m4v mkv avi) do if /i "%~x1"==".%%e" set "VIDEO=%~1"
)
if not defined IMAGE (
  for %%e in (jpg jpeg png webp) do if /i "%~x1"==".%%e" set "IMAGE=%~1"
)
shift
goto :findargs

:interactive
echo.
echo ============================================
echo   No file was dragged onto this .bat.
echo ============================================
echo TIP: drag the video file and drop it HERE
echo      into this black window (it fills in
echo      the path), or paste the full path,
echo      then press Enter.
echo ============================================
set /p VPATH=Video file path: 
if not defined VPATH goto :nofile
set "VPATH=%VPATH:"=%"
if "%VPATH%"=="" goto :nofile
set "VIDEO=%VPATH%"
goto :argsdone

:argsdone
if not defined VIDEO goto :nofile
if not exist "%VIDEO%" goto :nofile
goto :gotvideo

:nofile
echo.
echo No valid video found.
pause
exit /b 1

:gotvideo
echo.
echo Video: %VIDEO%
if defined IMAGE (echo Cover: %IMAGE%) else (echo Cover: automatic first frame)
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

for %%f in ("%VIDEO%") do set "VBASE=%%~nf"
copy /y "%VIDEO%" "assets\%CAT%\" >nul
if errorlevel 1 (
  echo [ERROR] Copy video failed.
  pause
  exit /b 1
)
echo Copied video into assets\%CAT%\

if defined IMAGE (
  for %%f in ("%IMAGE%") do set "IEXT=%%~xf"
  copy /y "%IMAGE%" "assets\%CAT%\%VBASE%%IEXT%" >nul
  echo Copied cover into assets\%CAT%\%VBASE%%IEXT%
)
goto :publish

:publish
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
  echo [Git not found] Please install Git: https://git-scm.com/download/win
  pause
  exit /b 1
)

"%GIT%" remote get-url origin >nul 2>nul
if errorlevel 1 (
  echo Not connected to GitHub yet. Run the CONNECT script first.
  pause
  exit /b 0
)

"%GIT%" add -A
"%GIT%" -c core.quotepath=false commit -m "upload works"
"%GIT%" push
if errorlevel 1 (
  echo Push failed. See messages above.
) else (
  echo Publish OK! Wait 1-2 minutes, then refresh your website.
)
echo.
pause

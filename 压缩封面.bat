@echo off
setlocal
cd /d "%~dp0"

set "FF="
if exist "C:\Program Files\Red Giant\Trapcode Suite\Tools\ffmpeg.exe" set "FF=C:\Program Files\Red Giant\Trapcode Suite\Tools\ffmpeg.exe"
if not defined FF (
  where ffmpeg >nul 2>nul && set "FF=ffmpeg"
)
if not defined FF (
  echo [ERROR] ffmpeg not found.
  echo Install ffmpeg first, or compress covers with another tool.
  pause
  exit /b 1
)

echo.
echo Compressing cover images to .jpg (max 1080px wide, ~150KB) ...
for %%d in (apparel jewelry tech beauty food ecommerce american brand chinese) do (
  if exist "assets\%%d\" (
    for %%f in ("assets\%%d\*.png") do (
      if exist "%%f" (
        echo   %%f
        "%FF%" -y -i "%%f" -vf "scale=1080:-2" -q:v 4 "%%~dpnf.jpg" -loglevel quiet
      )
    )
  )
)
echo.
echo Done. Compressed .jpg covers created next to the originals.
echo Now double-click publish.bat to rebuild + push.
echo.
pause

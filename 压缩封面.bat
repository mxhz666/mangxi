@echo off
setlocal
cd /d "%~dp0"
set "LOG=%~dp0compress-log.txt"
> "%LOG%" echo === compress log ===

set "FF="
if exist "C:\Program Files\Red Giant\Trapcode Suite\Tools\ffmpeg.exe" set "FF=C:\Program Files\Red Giant\Trapcode Suite\Tools\ffmpeg.exe"
if not defined FF (
  where ffmpeg >nul 2>nul && set "FF=ffmpeg"
)
if not defined FF (
  >> "%LOG%" echo ERROR ffmpeg not found
  echo [ERROR] ffmpeg not found. See compress-log.txt
  pause
  exit /b 1
)
>> "%LOG%" echo FFMPEG=%FF%
>> "%LOG%" echo.

for %%d in (apparel jewelry tech beauty food ecommerce american brand chinese) do (
  if exist "assets\%%d\" (
    for %%f in ("assets\%%d\*.png") do (
      if exist "%%f" (
        >> "%LOG%" echo INPUT=%%f
        "%FF%" -y -i "%%f" -vf "scale=1080:-2" -q:v 4 "%%~dpnf.jpg" -loglevel error >> "%LOG%" 2>&1
        if errorlevel 1 (
          >> "%LOG%" echo ERROR %%~dpnf.jpg
        ) else (
          >> "%LOG%" echo OK %%~dpnf.jpg
        )
      )
    )
  )
)
>> "%LOG%" echo DONE

echo.
echo Finished. Log saved to compress-log.txt
echo Run publish.bat afterwards.
echo.
pause

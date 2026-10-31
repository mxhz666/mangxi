@echo off
setlocal
cd /d "%~dp0"
set "LOG=%~dp0compress-video-log.txt"
set "TMP=%~dp0_tmp_vid"
> "%LOG%" echo === video compress log ===

set "FF="
if exist "C:\Program Files\Red Giant\Trapcode Suite\Tools\ffmpeg.exe" set "FF=C:\Program Files\Red Giant\Trapcode Suite\Tools\ffmpeg.exe"
if not defined FF (
  where ffmpeg >nul 2>nul && set "FF=ffmpeg"
)
if not defined FF (
  >> "%LOG%" echo ERROR ffmpeg not found
  echo [ERROR] ffmpeg not found. See compress-video-log.txt
  pause
  exit /b 1
)
>> "%LOG%" echo FFMPEG=%FF%
>> "%LOG%" echo.

for %%d in (apparel jewelry tech beauty food ecommerce american brand chinese) do (
  if exist "assets\%%d\" (
    for %%e in (mp4 mov webm m4v mkv) do (
      for %%f in ("assets\%%d\*.%%e") do (
        if exist "%%f" (
          >> "%LOG%" echo INPUT=%%f
          copy /y "%%f" "%TMP%.mp4" >nul
          "%FF%" -y -i "%TMP%.mp4" -vf "scale=-2:720" -c:v libx264 -crf 26 -preset medium -c:a aac -b:a 128k -movflags +faststart "%TMP%_c.mp4" -loglevel error >> "%LOG%" 2>&1
          if errorlevel 1 (
            >> "%LOG%" echo ERROR %%f
          ) else (
            copy /y "%TMP%_c.mp4" "%%f" >nul
            >> "%LOG%" echo OK %%f
          )
          del "%TMP%.mp4" "%TMP%_c.mp4" >nul 2>nul
        )
      )
    )
  )
)
>> "%LOG%" echo DONE

echo.
echo Finished. Log: compress-video-log.txt
echo Now double-click publish.bat
echo.
pause

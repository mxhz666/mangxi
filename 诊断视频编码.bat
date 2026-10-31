@echo off
setlocal
cd /d "%~dp0"
set "FF=C:\Program Files\Red Giant\Trapcode Suite\Tools\ffmpeg.exe"
if not exist "%FF%" set "FF=ffmpeg"
"%FF%" -version > "%~dp0ffmpeg-info.txt" 2>&1
"%FF%" -encoders > "%~dp0ffmpeg-encoders.txt" 2>&1
echo.
echo Done. See ffmpeg-info.txt / ffmpeg-encoders.txt
echo.
pause

@echo off
setlocal
cd /d "%~dp0"
echo.
echo Running network + push test ...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0net-test.ps1"
echo.
echo ============================================
echo   Test finished. Log: %~dp0net-log.txt
echo ============================================
echo.
pause

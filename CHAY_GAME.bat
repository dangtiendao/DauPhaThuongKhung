@echo off
setlocal EnableDelayedExpansion
set "PROJECT_DIR=%~dp0"
set "BIN_EXE="

if defined GODOT_EXE if exist "%GODOT_EXE%" set "BIN_EXE=%GODOT_EXE%"

if not defined BIN_EXE (
    for /f "delims=" %%I in ('where godot 2^>nul') do (
        if not defined BIN_EXE set "BIN_EXE=%%I"
    )
)

if not defined BIN_EXE if exist "%LOCALAPPDATA%\Microsoft\WinGet\Packages" (
    for /f "delims=" %%I in ('dir /b /s /a:-d "%LOCALAPPDATA%\Microsoft\WinGet\Packages\Godot*_win64.exe" 2^>nul') do (
        set "CAND=%%I"
        echo !CAND! | findstr /i "_console.exe" >nul
        if errorlevel 1 if not defined BIN_EXE set "BIN_EXE=%%I"
    )
)

if defined BIN_EXE (
    start "" "%BIN_EXE%" --path "%PROJECT_DIR%."
    exit /b 0
)

if exist "%PROJECT_DIR%builds\DauPhaThuongKhung.exe" (
    start "" "%PROJECT_DIR%builds\DauPhaThuongKhung.exe"
    exit /b 0
)

echo [LOI] Khong tim thay Godot 4 (bien moi truong GODOT_EXE / PATH / WinGet) va chua co builds\DauPhaThuongKhung.exe.
pause
exit /b 1

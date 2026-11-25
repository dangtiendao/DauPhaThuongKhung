@echo off
setlocal EnableDelayedExpansion
set "PROJECT_DIR=%~dp0.."
set "BIN_CONSOLE="

if defined GODOT_CONSOLE if exist "%GODOT_CONSOLE%" set "BIN_CONSOLE=%GODOT_CONSOLE%"
if not defined BIN_CONSOLE if defined GODOT_EXE if exist "%GODOT_EXE%" set "BIN_CONSOLE=%GODOT_EXE%"

if not defined BIN_CONSOLE if exist "%LOCALAPPDATA%\Microsoft\WinGet\Packages" (
    for /f "delims=" %%I in ('dir /b /s /a:-d "%LOCALAPPDATA%\Microsoft\WinGet\Packages\Godot*_win64_console.exe" 2^>nul') do (
        if not defined BIN_CONSOLE set "BIN_CONSOLE=%%I"
    )
)

if not defined BIN_CONSOLE (
    for /f "delims=" %%I in ('where godot 2^>nul') do (
        if not defined BIN_CONSOLE set "BIN_CONSOLE=%%I"
    )
)

if not defined BIN_CONSOLE (
    echo [LOI] Khong tim thay Godot 4 Console! Hay cai Godot 4 hoac dat bien moi truong GODOT_CONSOLE / GODOT_EXE.
    exit /b 1
)

"%BIN_CONSOLE%" --headless --path "%PROJECT_DIR%" res://tests/test_runner.tscn
exit /b %ERRORLEVEL%

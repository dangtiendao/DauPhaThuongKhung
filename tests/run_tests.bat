@echo off
setlocal
set "GODOT_CONSOLE=C:\Users\asus\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe"
if exist "%GODOT_CONSOLE%" (
    "%GODOT_CONSOLE%" --headless --path "%~dp0.." res://tests/test_runner.tscn
) else (
    godot --headless --path "%~dp0.." res://tests/test_runner.tscn
)
exit /b %ERRORLEVEL%

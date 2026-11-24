@echo off
set "GODOT_EXE=C:\Users\asus\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe"
if exist "%GODOT_EXE%" (
    start "" "%GODOT_EXE%" --editor --path "%~dp0."
) else (
    start "" godot --editor --path "%~dp0."
)

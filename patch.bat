@echo off
rem SPDX-License-Identifier: MIT
rem patch.bat - Windows launcher for patch.ps1 (double-click it, or drag your APK onto it).
rem -ExecutionPolicy Bypass lets this one script run without changing your system settings.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0patch.ps1" %*
rem Keep the window open so you can read the result.
pause

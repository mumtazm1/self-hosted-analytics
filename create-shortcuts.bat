@echo off
echo Creating Desktop Shortcuts...
echo.

set SCRIPT_DIR=%~dp0
set DESKTOP=%USERPROFILE%\Desktop

:: Create shortcut for start.bat
powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%DESKTOP%\Analytics Stack - Start.lnk'); $s.TargetPath = '%SCRIPT_DIR%start.bat'; $s.WorkingDirectory = '%SCRIPT_DIR%'; $s.IconLocation = 'shell32.dll,137'; $s.Save()"

:: Create shortcut for stop.bat
powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%DESKTOP%\Analytics Stack - Stop.lnk'); $s.TargetPath = '%SCRIPT_DIR%stop.bat'; $s.WorkingDirectory = '%SCRIPT_DIR%'; $s.IconLocation = 'shell32.dll,132'; $s.Save()"

:: Create shortcut for status.bat
powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%DESKTOP%\Analytics Stack - Status.lnk'); $s.TargetPath = '%SCRIPT_DIR%status.bat'; $s.WorkingDirectory = '%SCRIPT_DIR%'; $s.IconLocation = 'shell32.dll,210'; $s.Save()"

echo.
echo Desktop shortcuts created successfully!
echo.
echo Shortcuts created:
echo - Analytics Stack - Start
echo - Analytics Stack - Stop
echo - Analytics Stack - Status
echo.
pause
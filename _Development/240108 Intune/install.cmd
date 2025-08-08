@echo off

:Standard
if not exist "C:\ProgramData\AutoPilotConfig\MDE Check" md "C:\ProgramData\AutoPilotConfig\MDE Check"

:Signatures
xcopy "CheckMDE-RegistryAddRemove.ps1" "C:\ProgramData\AutoPilotConfig\MDE Check" /Y
xcopy "CheckMDE-RegistryRemove.ps1" "C:\ProgramData\AutoPilotConfig\MDE Check" /Y
xcopy "install.cmd" "C:\ProgramData\AutoPilotConfig\MDE Check" /Y
xcopy "MDE Check.xml" "C:\ProgramData\AutoPilotConfig\MDE Check" /Y 
xcopy "uninstall.cmd" "C:\ProgramData\AutoPilotConfig\MDE Check" /Y


:run
set "taskName=MDE Check"

REM Check if the task already exists
schtasks /query /TN "%taskName%" >nul 2>nul
if %errorlevel% equ 0 (
    echo Task "%taskName%" already exists.
) else (
    echo Registering task "%taskName%"...
    powershell -command "Register-ScheduledTask -Xml (Get-Content 'C:\ProgramData\AutoPilotConfig\MDE Check\MDE Check.xml' | Out-String) -TaskName 'MDE Check' -Force"
    echo Task "%taskName%" registered successfully.
)
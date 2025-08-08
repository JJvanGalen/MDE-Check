@echo off
set folder="C:\ProgramData\AutoPilotConfig\MDE Check"
set logfile="C:\ProgramData\AutoPilotConfig\MDE Check\MDE-Check.log"

:Standard
if not exist "C:\ProgramData\AutoPilotConfig\MDE Check" md "C:\ProgramData\AutoPilotConfig\MDE Check"

:Signatures
xcopy "CheckMDE-RegistryAddRemove.ps1" "C:\ProgramData\AutoPilotConfig\MDE Check" /Y >> %logfile%
xcopy "CheckMDE-RegistryRemove.ps1" "C:\ProgramData\AutoPilotConfig\MDE Check" /Y >> %logfile%
xcopy "install.cmd" "C:\ProgramData\AutoPilotConfig\MDE Check" /Y >> %logfile%
xcopy "MDE Check.xml" "C:\ProgramData\AutoPilotConfig\MDE Check" /Y >> %logfile%
xcopy "uninstall.cmd" "C:\ProgramData\AutoPilotConfig\MDE Check" /Y >> %logfile%


:run
set "taskName=MDE Check"

REM Check if the task already exists
schtasks /query /TN "%taskName%" >nul 2>nul >> %logfile%
if %errorlevel% equ 0 (
    echo Task "%taskName%" already exists - removing task. >> %logfile%
) else (
    echo Registering task "%taskName%"... >> %logfile%
    powershell -command "Register-ScheduledTask -Xml (Get-Content 'C:\ProgramData\AutoPilotConfig\MDE Check\MDE Check.xml' | Out-String) -TaskName 'MDE Check' -Force" >> %logfile%
    echo Task "%taskName%" registered successfully. >> %logfile%
	schtasks /query /TN "%taskName%" >nul 2>nul >> %logfile%
	if %errorlevel% neq 0 ( goto :run )
)
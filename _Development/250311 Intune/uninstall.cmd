@echo off
setlocal enabledelayedexpansion
set folder="C:\ProgramData\AutoPilotConfig\MDE Check"
set "exitcode=0"

:run
set "taskName=MDE Check"
schtasks /delete /TN "%taskName%" /F >nul
if errorlevel 1 (
    echo Fout bij verwijderen van scheduled task.
    set exitcode=1
)

powershell -ExecutionPolicy Bypass -File "C:\ProgramData\AutoPilotConfig\MDE Check\CheckMDE-RegistryRemove.ps1"
if errorlevel 1 (
    echo Fout bij uitvoeren van CheckMDE-RegistryRemove.ps1.
    set exitcode=1
)

del "%folder%\CheckMDE-RegistryAddRemove.ps1"
if exist "%folder%\CheckMDE-RegistryAddRemove.ps1" set exitcode=1
del "%folder%\install.cmd"
if exist "%folder%\install.cmd" set exitcode=1
del "%folder%\MDE Check.xml"
if exist "%folder%\MDE Check.xml" set exitcode=1
del "%folder%\uninstall.cmd"
if exist "%folder%\uninstall.cmd" set exitcode=1
rmdir /s /q %folder%
if exist %folder% set exitcode=1

exit /b !exitcode!

@echo off
set folderoud="C:\ProgramData\AutoPilotConfig\MDE Check"
set folder="C:\ProgramData\AutoPilotConfig\MDE_Check"

:run
set taskName="MDE Check"
schtasks /delete /TN "%taskName%" /F >nul

powershell -ExecutionPolicy Bypass -File "C:\ProgramData\AutoPilotConfig\MDE Check\CheckMDE-RegistryRemove.ps1"

del "%folder%\CheckMDE-RegistryAddRemove.ps1"
del "%folder%\install.cmd"
del "%folder%\MDE Check.xml"
del "%folder%\uninstall.cmd"
rmdir /s /q %folder%

del "%folderoud%\CheckMDE-RegistryAddRemove.ps1"
del "%folderoud%\install.cmd"
del "%folderoud%\MDE Check.xml"
del "%folderoud%\uninstall.cmd"
rmdir /s /q %folderoud%

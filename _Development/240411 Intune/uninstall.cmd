@echo off

:run
set "taskName=MDE Check"
schtasks /delete /TN "%taskName%" /F >nul

powershell -ExecutionPolicy Bypass -File "C:\ProgramData\AutoPilotConfig\MDE Check\CheckMDE-RegistryRemove.ps1"

del "C:\ProgramData\AutoPilotConfig\MDE Check\CheckMDE-RegistryAddRemove.ps1"
del "C:\ProgramData\AutoPilotConfig\MDE Check\CheckMDE-RegistryRemove.ps1"
del "C:\ProgramData\AutoPilotConfig\MDE Check\install.cmd"
del "C:\ProgramData\AutoPilotConfig\MDE Check\MDE Check.xml"
del "C:\ProgramData\AutoPilotConfig\MDE Check\uninstall.cmd"
rmdir /s /q "C:\ProgramData\AutoPilotConfig\MDE Check"

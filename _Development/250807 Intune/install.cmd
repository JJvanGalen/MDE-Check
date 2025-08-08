@echo on
set folder="C:\ProgramData\AutoPilotConfig\MDE_Check"
set folderoud="C:\ProgramData\AutoPilotConfig\MDE Check"
set logfile="%folder%\MDE-Check.log"

:Standard
if exist %logfile% del %logfile%
if not exist %folder% md %folder%
rmdir /s /q %folderoud%

:Signatures
xcopy /E *.* %folder% /Y


set taskName="MDE Check"
set maxTries="3"
set /a try=1

:registerTask
REM Check if the task al bestaat
schtasks /query /TN "%taskName%" >nul 2>nul >> %logfile%
if %errorlevel% equ 0 (
    echo Task "%taskName%" already exists - removing task. >> %logfile%
    schtasks /delete /TN "%taskName%" /F >nul 2>nul >> %logfile%
)
echo Registering task "%taskName%"... >> %logfile%
powershell -command "Register-ScheduledTask -Xml (Get-Content '%folder%\MDE Check.xml' | Out-String) -TaskName 'MDE Check' -Force" >> %logfile%
echo Task "%taskName%" registered (try %try%). >> %logfile%
schtasks /query /TN "%taskName%" >nul 2>nul >> %logfile%
if %errorlevel% neq 0 (
    set /a try+=1
    if %try% leq %maxTries% (
        echo Registratie mislukt, poging %try% van %maxTries%. >> %logfile%
        timeout /t 15 >nul
        goto :registerTask
    ) else (
        echo Registratie van taak "%taskName%" is na %maxTries% pogingen mislukt. >> %logfile%
        exit /b 1
    )
)
echo Registratie van taak "%taskName%" is geslaagd. >> %logfile%
exit /b 0
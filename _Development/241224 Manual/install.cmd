@echo on
set "folder=C:\ProgramData\MDE_Check"
set "logfile=%folder%\MDE-Check.log"

:Standard
if exist %logfile% del %logfile% :: Toegevoegd (14-12-2024)
if not exist %folder% md %folder%

:Signatures
xcopy /E *.* %folder% /Y


:run
set "taskName=MDE Check"

REM Check if the task already exists
schtasks /query /TN "%taskName%" >nul 2>nul >> %logfile%
if %errorlevel% equ 0 (
    echo Task "%taskName%" already exists - removing task. >> %logfile%
	schtasks /delete /TN "%taskName%" /F >nul 2>nul >> %logfile%
	echo Registering task "%taskName%"... >> %logfile%
    powershell -command "Register-ScheduledTask -Xml (Get-Content '%folder%\MDE Check.xml' | Out-String) -TaskName 'MDE Check' -Force" >> %logfile%
    echo Task "%taskName%" registered successfully. >> %logfile%
	schtasks /query /TN "%taskName%" >nul 2>nul >> %logfile%
	if %errorlevel% neq 0 ( goto :run )
) else (
    echo Registering task "%taskName%"... >> %logfile%
    powershell -command "Register-ScheduledTask -Xml (Get-Content '%folder%\MDE Check.xml' | Out-String) -TaskName 'MDE Check' -Force" >> %logfile%
    echo Task "%taskName%" registered successfully. >> %logfile%
	schtasks /query /TN "%taskName%" >nul 2>nul >> %logfile%
	if %errorlevel% neq 0 ( goto :run )
)
timeout /t 30 :: Seconden van 60 naar 30 teruggebracht (14-12-2024)
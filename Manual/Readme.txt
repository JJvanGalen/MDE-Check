Stappen voor handmatig toevoegen op bijvoorbeeld Stand-alone computers:

Kopieer het zip bestand naar C:\beheer\ en pak uit
Start een Command-Prompt met Administrator rechten
Start het script 'install.cmd'


Unzippen cmd: Expand-Archive -Force C:\path\to\archive.zip C:\where\to\extract\to


Scheduled Task starten

SCHTASKS /Run /TN "MDE Check"
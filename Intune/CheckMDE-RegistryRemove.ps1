$ErrorActionPreference = 'Stop'
$logDir = "C:\temp\MDECheck"
if (-not (Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory | Out-Null }
$logFile = Join-Path $logDir ("MDECheck-" + (Get-Date -Format 'yyyyMMdd') + ".log")
function Write-Log {
    param([string]$msg)
    $timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    Add-Content -Path $logFile -Value ("[$timestamp] $msg")
}

$registryPath    = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Reset_MDE"
$registryPathX86 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Reset_MDE"

try {
    if (Test-Path $registryPath) {
        Remove-Item -Path $registryPath -Force
        Write-Log "Registry HKLM Reset_MDE verwijderd."
    } else {
        Write-Log "Registry HKLM Reset_MDE niet gevonden."
    }
    if (Test-Path $registryPathX86) {
        Remove-Item -Path $registryPathX86 -Force
        Write-Log "Registry HKLM Wow6432Node Reset_MDE verwijderd."
    } else {
        Write-Log "Registry HKLM Wow6432Node Reset_MDE niet gevonden."
    }
    Write-Log "Registry remove script succesvol afgerond."
    exit 0
} catch {
    Write-Log "FOUT: Kan registry niet verwijderen: $_"
    exit 1
}
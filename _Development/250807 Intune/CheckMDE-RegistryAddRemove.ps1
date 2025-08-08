
# Script version
$version = "20250807"
$ErrorActionPreference = 'Stop'

# Logging setup
$logDir = "C:\temp\MDECheck"
if (-not (Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory | Out-Null }
$logFile = Join-Path $logDir ("MDECheck-" + (Get-Date -Format 'yyyyMMdd') + ".log")
function Write-Log {
    param([string]$msg)
    $timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    Add-Content -Path $logFile -Value ("[$timestamp] $msg")
}

# Cleanup logs ouder dan 30 dagen
Get-ChildItem -Path $logDir -Filter 'MDECheck-*.log' | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | Remove-Item -Force -ErrorAction SilentlyContinue

# Create the registry key if it does not exist
$registryPath    = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Reset_MDE"
$registryPathX86 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Reset_MDE"
if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath | Out-Null
}
if (-not (Test-Path $registryPathX86)) {
    New-Item -Path $registryPathX86 | Out-Null
}


# Variables
$displayNameValue = "Microsoft_MDE"
$publisherValue = "Reset_ICT-$version"
try {
    $computerStatus = Get-MpComputerStatus
    $displayVersion = $computerStatus.AMProductVersion
    $installDateToday = (Get-Date).ToString("yyyyMMdd")
    Write-Log "Defender status opgehaald."
} catch {
    Write-Log "FOUT: Kan Defender status niet ophalen: $_"
    exit 2
}


# Function to check and create registry property if it does not exist
function Set-RegistryValueIfNotExists {
    param (
        [string]$path,
        [string]$name,
        [string]$value,
        [string]$propertyType
    )
    if (-not (Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue)) {
        New-ItemProperty -Path $path -Name $name -Value $value -PropertyType $propertyType | Out-Null
    }
}

# Initialize unique code mapping
$uniqueCodes = @{
    "processMssense" = "001"
    "processMsmpeng" = "002"
    "processMpdefendercoreservice" = "003"
    "AMRunningMode" = "010"
    "AMServiceEnabled" = "011"
    "AntiSpywareEnabled" = "012"
    "BehaviorMonitorEnabled" = "013"
    "RealTimeProtectionEnabled" = "014"
    "IoavProtectionEnabled" = "015"
    "AntivirusEnabled" = "016"
    "IsTamperProtected" = "017"
    "OnAccessProtectionEnabled" = "018"
}
$issues = @()

try {
    # Perform checks
    $processMssense = (Get-Process -Name mssense -ErrorAction SilentlyContinue)
    if ($null -eq $processMssense) {
        $issues += $uniqueCodes["processMssense"]
    }
    $processMsmpeng = (Get-Process -Name msmpeng -ErrorAction SilentlyContinue)
    if ($null -eq $processMsmpeng) {
        $issues += $uniqueCodes["processMsmpeng"]
    }
    <#
    $processMpdefendercoreservice = (Get-Process -Name mpdefendercoreservice -ErrorAction SilentlyContinue)
    if ($null -eq $processMpdefendercoreservice) {
        $issues += $uniqueCodes["processMpdefendercoreservice"]
    }
    #>
    if ($computerStatus.AMRunningMode -ne 'Normal') {
        $issues += $uniqueCodes["AMRunningMode"]
    }
    if ($computerStatus.AMServiceEnabled -ne $true) {
        $issues += $uniqueCodes["AMServiceEnabled"]
    }
    if ($computerStatus.AntiSpywareEnabled -ne $true) {
        $issues += $uniqueCodes["AntiSpywareEnabled"]
    }
    if ($computerStatus.BehaviorMonitorEnabled -ne $true) {
        $issues += $uniqueCodes["BehaviorMonitorEnabled"]
    }
    if ($computerStatus.RealTimeProtectionEnabled -ne $true) {
        $issues += $uniqueCodes["RealTimeProtectionEnabled"]
    }
    if ($computerStatus.IoavProtectionEnabled -ne $true) {
        $issues += $uniqueCodes["IoavProtectionEnabled"]
    }
    if ($computerStatus.AntivirusEnabled -ne $true) {
        $issues += $uniqueCodes["AntivirusEnabled"]
    }
    if ($computerStatus.IsTamperProtected -ne $true) {
        $issues += $uniqueCodes["IsTamperProtected"]
    }
    if ($computerStatus.OnAccessProtectionEnabled -ne $true) {
        $issues += $uniqueCodes["OnAccessProtectionEnabled"]
    }
    if ($issues.Count -eq 0) {
        Write-Log "Alle checks uitgevoerd en zijn geslaagd."
    } else {
        Write-Log ("Checks uitgevoerd. Issues gevonden: " + ($issues -join ", "))
    }
} catch {
    Write-Log "FOUT: Fout tijdens checks: $_"
    exit 3
}


# Update $displayNameValue with status and unique codes
if ($issues.Count -gt 0) {
    $displayNameValue = "Microsoft_MDE_Status_NOT_OK (" + ($issues -join ",") + ")"
} else {
    $displayNameValue = "Microsoft_MDE_Status_OK"
}

try {
    # Output current state to registry
    Set-RegistryValueIfNotExists -path $registryPath -name "Publisher" -value $publisherValue -propertyType "String"
    Set-RegistryValueIfNotExists -path $registryPath -name "InstallDate" -value $installDateToday -propertyType "String"
    Set-RegistryValueIfNotExists -path $registryPathX86 -name "Publisher" -value $publisherValue -propertyType "String"
    Set-RegistryValueIfNotExists -path $registryPathX86 -name "InstallDate" -value $installDateToday -propertyType "String"

    # Alleen DisplayName/DisplayVersion bijwerken als status of versie wijzigt
    $currentDisplayName = (Get-ItemProperty -Path $registryPath -Name "DisplayName" -ErrorAction SilentlyContinue).DisplayName
    $currentDisplayVersion = (Get-ItemProperty -Path $registryPath -Name "DisplayVersion" -ErrorAction SilentlyContinue).DisplayVersion
    $currentDisplayNameX86 = (Get-ItemProperty -Path $registryPathX86 -Name "DisplayName" -ErrorAction SilentlyContinue).DisplayName
    $currentDisplayVersionX86 = (Get-ItemProperty -Path $registryPathX86 -Name "DisplayVersion" -ErrorAction SilentlyContinue).DisplayVersion

    if ($currentDisplayName -ne $displayNameValue -or $currentDisplayVersion -ne $displayVersion) {
        Set-ItemProperty -Path $registryPath -Name "DisplayName" -Value $displayNameValue
        Set-ItemProperty -Path $registryPath -Name "DisplayVersion" -Value $displayVersion
        Write-Log "Registry HKLM DisplayName/DisplayVersion bijgewerkt: $displayNameValue ($displayVersion)"
    } else {
        Write-Log "Registry HKLM DisplayName/DisplayVersion ongewijzigd."
    }
    if ($currentDisplayNameX86 -ne $displayNameValue -or $currentDisplayVersionX86 -ne $displayVersion) {
        Set-ItemProperty -Path $registryPathX86 -Name "DisplayName" -Value $displayNameValue
        Set-ItemProperty -Path $registryPathX86 -Name "DisplayVersion" -Value $displayVersion
        Write-Log "Registry HKLM Wow6432Node DisplayName/DisplayVersion bijgewerkt: $displayNameValue ($displayVersion)"
    } else {
        Write-Log "Registry HKLM Wow6432Node DisplayName/DisplayVersion ongewijzigd."
    }

    # Publisher/InstallDate alleen bij verschil
    $currentPublisher = (Get-ItemProperty -Path $registryPath -Name "Publisher" -ErrorAction SilentlyContinue).Publisher
    $currentInstallDate = (Get-ItemProperty -Path $registryPath -Name "InstallDate" -ErrorAction SilentlyContinue).InstallDate
    $currentPublisherX86 = (Get-ItemProperty -Path $registryPathX86 -Name "Publisher" -ErrorAction SilentlyContinue).Publisher
    $currentInstallDateX86 = (Get-ItemProperty -Path $registryPathX86 -Name "InstallDate" -ErrorAction SilentlyContinue).InstallDate
    if ($currentPublisher -ne $publisherValue) {
        Set-ItemProperty -Path $registryPath -Name "Publisher" -Value $publisherValue
        Write-Log "Registry HKLM Publisher bijgewerkt: $publisherValue"
    }
    if ($currentInstallDate -ne $installDateToday) {
        Set-ItemProperty -Path $registryPath -Name "InstallDate" -Value $installDateToday
        Write-Log "Registry HKLM InstallDate bijgewerkt: $installDateToday"
    }
    if ($currentPublisherX86 -ne $publisherValue) {
        Set-ItemProperty -Path $registryPathX86 -Name "Publisher" -Value $publisherValue
        Write-Log "Registry HKLM Wow6432Node Publisher bijgewerkt: $publisherValue"
    }
    if ($currentInstallDateX86 -ne $installDateToday) {
        Set-ItemProperty -Path $registryPathX86 -Name "InstallDate" -Value $installDateToday
        Write-Log "Registry HKLM Wow6432Node InstallDate bijgewerkt: $installDateToday"
    }
} catch {
    Write-Log "FOUT: Kan registry niet bijwerken: $_"
    exit 4
}

Write-Log "Script succesvol afgerond."
exit 0
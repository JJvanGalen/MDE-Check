# Script version
$version = "20241224"

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
$computerStatus = Get-MpComputerStatus
$displayVersion = $computerStatus.AMProductVersion
$installDateToday = (Get-Date).ToString("yyyyMMdd")


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

# Update $displayNameValue with status and unique codes
if ($issues.Count -gt 0) {
    $displayNameValue = "Microsoft_MDE_Status_NOT_OK (" + ($issues -join ",") + ")"
} else {
    $displayNameValue = "Microsoft_MDE_Status_OK"
}

# Output current state to registry
Set-RegistryValueIfNotExists -path $registryPath -name "Publisher" -value $publisherValue -propertyType "String"
Set-RegistryValueIfNotExists -path $registryPath -name "InstallDate" -value $installDateToday -propertyType "String"
Set-RegistryValueIfNotExists -path $registryPathX86 -name "Publisher" -value $publisherValue -propertyType "String"
Set-RegistryValueIfNotExists -path $registryPathX86 -name "InstallDate" -value $installDateToday -propertyType "String"

Set-ItemProperty -Path $registryPath -Name "DisplayName" -Value $displayNameValue
Set-ItemProperty -Path $registryPath -Name "DisplayVersion" -Value $displayVersion
Set-ItemProperty -Path $registryPathX86 -Name "DisplayName" -Value $displayNameValue
Set-ItemProperty -Path $registryPathX86 -Name "DisplayVersion" -Value $displayVersion

# Get install date from registry
$installDate = (Get-ItemProperty -Path $registryPath -Name "InstallDate").InstallDate

if ([int]$installDate -lt [int]$version) {
    Set-ItemProperty -Path $registryPath -Name "Publisher" -Value $publisherValue
    Set-ItemProperty -Path $registryPath -Name "InstallDate" -Value $installDateToday
    Set-ItemProperty -Path $registryPathX86 -Name "Publisher" -Value $publisherValue
    Set-ItemProperty -Path $registryPathX86 -Name "InstallDate" -Value $installDateToday
}

# Add output for logging
Write-Output "Registry updated with current status: $displayNameValue"
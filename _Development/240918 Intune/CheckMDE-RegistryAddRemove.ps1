# Get the computer status
$computerStatus = Get-MpComputerStatus

$registryPath = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Reset_MDE"
$registryPathX86 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Reset_MDE"
$displayNameValue = "Microsoft_MDE"
$publisherValue = "Reset_ICT"
$displayVersion = $computerStatus.AMProductVersion
$installDate = (Get-Date).ToString("yyyyMMdd")

# Create the registry key if it does not exist
if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath | Out-Null
}
if (-not (Test-Path $registryPathX86)) {
    New-Item -Path $registryPathX86 | Out-Null
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

# Set registry values only if they do not exist
Set-RegistryValueIfNotExists -path $registryPath -name "DisplayName" -value $displayNameValue -propertyType "String"
Set-RegistryValueIfNotExists -path $registryPath -name "Publisher" -value $publisherValue -propertyType "String"
Set-RegistryValueIfNotExists -path $registryPath -name "InstallDate" -value $installDate -propertyType "String"
Set-RegistryValueIfNotExists -path $registryPath -name "DisplayVersion" -value $displayVersion -propertyType "String"
Set-RegistryValueIfNotExists -path $registryPathX86 -name "DisplayName" -value $displayNameValue -propertyType "String"
Set-RegistryValueIfNotExists -path $registryPathX86 -name "Publisher" -value $publisherValue -propertyType "String"
Set-RegistryValueIfNotExists -path $registryPathX86 -name "InstallDate" -value $installDate -propertyType "String"
Set-RegistryValueIfNotExists -path $registryPathX86 -name "DisplayVersion" -value $displayVersion -propertyType "String"

# Check the required values
if (
    $computerStatus.AMRunningMode -eq 'Normal' -and
    $computerStatus.AMServiceEnabled -eq $true -and
    $computerStatus.AntiSpywareEnabled -eq $true -and
    $computerStatus.BehaviorMonitorEnabled -eq $true -and
    $computerStatus.RealTimeProtectionEnabled -eq $true -and
    $computerStatus.IoavProtectionEnabled -eq $true -and
    $computerStatus.AntivirusEnabled -eq $true -and
    $computerStatus.IsTamperProtected -eq $true -and
    $computerStatus.OnAccessProtectionEnabled -eq $true
    
) {
    # Check if mssense.exe is running
    $mssenseProcess = Get-Process -Name mssense -ErrorAction SilentlyContinue

    if ($null -ne $mssenseProcess) {
        # All values are as they should be, and mssense.exe is running
        Write-Output "Everything is OK. MDE is installed and running"
        New-ItemProperty -Path $registryPath -Name "DisplayName" -Value "Microsoft_MDE_Status_OK" -PropertyType String -Force | Out-Null
        New-ItemProperty -Path $registryPath -Name "DisplayVersion" -Value $displayVersion -PropertyType String -Force | Out-Null
        New-ItemProperty -Path $registryPathX86 -Name "DisplayName" -Value "Microsoft_MDE_Status_OK" -PropertyType String -Force | Out-Null
        New-ItemProperty -Path $registryPathX86 -Name "DisplayVersion" -Value $displayVersion -PropertyType String -Force | Out-Null
    } else {
        # mssense.exe is not running
        Write-Output "Not OK - mssense.exe is not running"
        New-ItemProperty -Path $registryPath -Name "DisplayName" -Value "Microsoft_MDE_Status_NOT_OK" -PropertyType String -Force | Out-Null
        New-ItemProperty -Path $registryPathX86 -Name "DisplayName" -Value "Microsoft_MDE_Status_NOT_OK" -PropertyType String -Force | Out-Null
    }
} else {
    # Not all values are as expected
    Write-Output "Not OK. Check the MpComputerStatus values"
    New-ItemProperty -Path $registryPath -Name "DisplayName" -Value "Microsoft_MDE_Status_NOT_OK" -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $registryPathX86 -Name "DisplayName" -Value "Microsoft_MDE_Status_NOT_OK" -PropertyType String -Force | Out-Null
}
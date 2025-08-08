# Get the computer status
$computerStatus = Get-MpComputerStatus

$registryPath = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Reset_MDE"
$displayNameValue = "Microsoft_MDE"
$publisherValue = "Reset_ICT"

# Check the required values
if (
    $computerStatus.AMRunningMode -eq 'Normal' -and
    $computerStatus.AMServiceEnabled -eq $true -and
    $computerStatus.AntiSpywareEnabled -eq $true -and
    $computerStatus.BehaviorMonitorEnabled -eq $true -and
    $computerStatus.RealTimeProtectionEnabled -eq $true -and
    $computerStatus.IoavProtectionEnabled -eq $true
) {
    # Check if mssense.exe is running
    $mssenseProcess = Get-Process -Name mssense -ErrorAction SilentlyContinue

    if ($null -ne $mssenseProcess) {
        # All values are as they should be, and mssense.exe is running
        Write-Output "Everything is OK. MDE is installed and running"

        # Check if the registry key already exists
        if (-not (Test-Path $registryPath)) {
            # Create the registry key if it does not exist
            New-Item -Path $registryPath -Force | Out-Null
            New-ItemProperty -Path $registryPath -Name "DisplayName" -Value $displayNameValue -PropertyType String -Force | Out-Null
            New-ItemProperty -Path $registryPath -Name "Publisher" -Value $publisherValue -PropertyType String -Force | Out-Null
        } <#elseif (Test-Path $registryPath) { # Testing code
        Remove-Item -Path $registryPath -Force | Out-Null
        } #>
    } else {
        # mssense.exe is not running
        Write-Output "Not OK - mssense.exe is not running"
        Remove-Item -Path $registryPath -Force | Out-Null
    }
} else {
    # Not all values are as expected
    Write-Output "Not OK. Check the MpComputerStatus values"
    Remove-Item -Path $registryPath -Force | Out-Null
}
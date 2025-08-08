$registryPath    = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Reset_MDE"
$registryPathX86 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Reset_MDE"

# Remove the registry key
Remove-Item -Path $registryPath -Force | Out-Null
Remove-Item -Path $registryPathX86 -Force | Out-Null
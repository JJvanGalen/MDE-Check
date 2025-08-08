$registryPath = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Reset_MDE"
$displayNameValue = "Microsoft_MDE"
$publisherValue = "Reset_ICT"

# Remove the registry key
Remove-Item -Path $registryPath -Force | Out-Null
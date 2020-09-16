#~ Version 3 ########################

# Verifying path to ps1 file exists
$TestFilePath = Join-Path $env:USERPROFILE "\Desktop\AD_Setup_Lite.ps1" 
#$TestFilePath = "C:\Users\Administrator\Desktop\AD_Setup_Lite.ps1"
if (Test-Path $TestFilePath) {
    Write-Host "Source exists." -ForegroundColor Green
}
else {
    Write-Output "This script made a read attempt at [$Time]. Source (C:\Users\Andersen\Desktop\src) cannot be found." | out-file C:\Users\Administrator\Desktop\KofaxScriptErrorLog.txt -Append
    Exit
}

#$schAction = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument '-NoProfile -WindowStyle Hidden -File "C:\Users\Administrator\Desktop\AD DS Setup.ps1"'
$PSPath = Join-Path $env:windir "system32\WindowsPowerShell\v1.0\powershell.exe"
$schAction = New-ScheduledTaskAction -Execute $PSPath -Argument '-NoProfile  -Executionpolicy bypass -WindowStyle Hidden -File "C:\Users\Administrator\Desktop\ADDS_Setup.ps1"'
$schTrigger = New-ScheduledTaskTrigger -AtLogOn
$schPrincipal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$schOption = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -WakeToRun
Register-ScheduledTask -Settings $schOption -Action $schAction -Trigger $schTrigger -TaskName "Configuration" -Description "Scheduled Task to run configuration Script At Startup" -Principal $schPrincipal 
Write-Output "Before reboot - basic" | Out-File  C:\Users\Administrator\Desktop\Log.txt -Append -ErrorAction Ignore
#Extra Code Here



Restart-Computer -Confirm
Write-Output "After reboot - basic" | Out-File  C:\Users\Administrator\Desktop\Log.txt -Append 

# Test waiting?
#Sleep 30
#Unregister-ScheduledTask -TaskName "Configuration" -Confirm:$false


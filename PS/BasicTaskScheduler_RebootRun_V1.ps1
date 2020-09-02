# Version 1 ########################
$schAction = New-ScheduledTaskAction -Execute "%WINDIR%\system32\WindowsPowerShell\v1.0\Powershell.exe" -Argument '-NoProfile -WindowStyle Hidden -File "C:\Scripts\<some config>.ps1"'
$schTrigger = New-ScheduledTaskTrigger -AtStartup 
$schPrincipal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -Action $schAction -Trigger $schTrigger -TaskName "Configuration" -Description "Scheduled Task to run configuration Script At Startup" -Principal $schPrincipal 

#Unregister-ScheduledTask -TaskName "Configuration" -Confirm:$false

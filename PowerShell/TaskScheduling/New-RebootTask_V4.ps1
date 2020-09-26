<# 
~ Automate setups or anything by scheduling tasks to run a .ps1 AFTER reboot

@ Version 4: implemented control flow 
! Remember to change the BASH CODE 


? Add interactivity? Or potentially employ csv integration


Steps from fresh install to Setup:

1. Change code for StandardSetup
2. Change code for New-RebootTask
3. Replace current file paths with .ps1 location of desired setup script (ie. C:\Users\Administrators\Desktop\Setup-AD.ps1)

#>

# Verifying path to ps1 file exists
$TestFilePath = Join-Path $env:USERPROFILE "\Desktop\AD_Setup_Lite.ps1" 

# Verification 
# REMEMBER TO CHANGE THE CODE FILE PATH FOR BASH CMDS
if (Test-Path $TestFilePath) {
    Write-Host "Source exists." -ForegroundColor Green

    $Time = Get-Date

    $PSPath = Join-Path $env:windir "system32\WindowsPowerShell\v1.0\powershell.exe"
    #@ REMEMBER TO CHANGE THIS #############################
    $schAction = New-ScheduledTaskAction -Execute $PSPath -Argument '-NoProfile  -Executionpolicy bypass -WindowStyle Hidden -File "C:\Users\Administrator\Desktop\Setup-AD.ps1"'
    $schTrigger = New-ScheduledTaskTrigger -AtLogOn
    $schPrincipal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    $schOption = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -WakeToRun
    Register-ScheduledTask -Settings $schOption -Action $schAction -Trigger $schTrigger -TaskName "Configuration" -Description "Scheduled Task to run configuration Script At Startup" -Principal $schPrincipal 
    Write-Output "[$Time] Before reboot" | out-file C:\Log.txt -Append
    #Extra Code Here ###################################################
    #@ Running setup script to automate 3 scripts in one - all 3 scripts must be in the same location
    #? Going through the below process MIGHT be causing the DC promotion errors ()
    #$RunScript = $PSScriptRoot + "\Standard Setup_v2"
    #&$RunScript
    Rename-Computer Terence -Restart -Confirm

    #@ Test waiting? ##########
    taskschd.msc
    Sleep 60
    Unregister-ScheduledTask -TaskName "Configuration" -Confirm:$false
    
    Write-Output "[$Time] After reboot" | out-file C:\Log.txt -Append
}
else {
    Write-Host "Source not found" -ForegroundColor Red
    $Time = Get-Date
    Write-Output "[$Time] Script cannot be found at $TestFilePath" | out-file C:\Log.txt -Append
    Exit
}





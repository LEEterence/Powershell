# AD DS Setup (WIP)
# REMEMBER TO CHANGE VALUES EACH TIME!!!!!!


## Standard setup - COMMENT out if already setup
#New-NetIPAddress -InterfaceIndex 4 -IPAddress 192.168.202.2 -PrefixLength 24 -DefaultGateway 192.168.61.2
#Set-DnsClientServerAddress -InterfaceIndex 4 -ServerAddresses ("192.168.202.2")
#Rename-Computer -NewName Test01 -Restart

# Remember to CHANGE DOMAINNAME and DomainNetbiosName
# DatabasePath is where AD database is stored (NTDS.dit), Domain mode and Forest mode is the functional level (the tpye of windows server 2012 r2, 2016, 2019,etc.)
Install-WindowsFeature –Name AD-Domain-Services -IncludeManagementTools
Import-Module ADDSDeployment
# AD DS installation
Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath "C:\Windows\NTDS" `
-DomainMode "WinThreshold" `
-DomainName "dmit2023.local" `
-DomainNetbiosName "DMIT2023" `
-ForestMode "WinThreshold" `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true
# Will be Prompted for DSRM recovery password, must set -NoRebootOnCompletion to $false
    # May require a COMPLEX password


# After Restart, then verify below - COMMENT OUT FIRST

#Get-Service adws,kdc,netlogon,dns
#Get-ADDomainController
#Get-ADDomain dmit2023.local

## LOCAL COMPUTER Running something else
workflow test-restart {
    param ([string]$Name)
    Write-Output "Before reboot" | Out-File  C:\Users\Administrator\Desktop\Log.txt -Append -ErrorAction Ignore
    Rename-Computer -NewName $name -Passthru
    Restart-Computer -Wait 
    Write-Output $Now2 "After reboot" | Out-File C:\Users\Administrator\Desktop\Log.txt -Append
}

$PSPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$Args = '-NonInteractive -WindowStyle Hidden -NoLogo -NoProfile -NoExit -Command "& {Import-Module PSWorkflow ; Get-Job | Resume-Job}"'
$Action = New-ScheduledTaskAction -Execute $PSPath -Argument $Args
$Option = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -WakeToRun
$Trigger = New-JobTrigger -AtStartUp -RandomDelay (New-TimeSpan -Minutes 5)
## Register-scheduled task will submit error if task already exists, use set-scheduledtask
#Register-ScheduledTask -TaskName ResumeJob -Action $Action -Trigger $Trigger -Settings $Option -RunLevel Highest 
Set-ScheduledTask -TaskName ResumeJob -Action $Action -Trigger $Trigger -Settings $Option

## Comment out to run manually or take out comment to run right away 
#test-restart -AsJob 

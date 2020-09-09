## REMOTE COMPUTER 
<#
workflow Rename-And-Reboot {
    param ([string]$Name)
    New-NetIPAddress -InterfaceIndex 4 -IPAddress 192.168.99.2 -PrefixLength 24 -DefaultGateway 192.168.99.2
    Set-DnsClientServerAddress -InterfaceIndex 4 -ServerAddresses ("192.168.99.1")
    Rename-Computer -NewName $Name -Force -Passthru
    Restart-Computer -Wait

    
    ## AD DS installation
    #inlinescript{
    #    Install-WindowsFeature –Name AD-Domain-Services -IncludeManagementTools
    #    Import-Module ADDSDeployment
    #    Install-ADDSForest `
    #    -CreateDnsDelegation:$false `
    #    -DatabasePath "C:\Windows\NTDS" `
    #    -DomainMode "WinThreshold" `
    #    -DomainName "dmit2023.local" `
    #    -DomainNetbiosName "DMIT2023" `
    #    -ForestMode "WinThreshold" `
    #    -InstallDns:$true `
    #    -LogPath "C:\Windows\NTDS" `
    #    -NoRebootOnCompletion:$false `
    #    -SysvolPath "C:\Windows\SYSVOL" `
    #    -Force:$true
    #}
    
}
#>


## LOCAL PC #### v2

workflow test-restart {
    param ([string]$Name)
    Write-Output "Before reboot" | Out-File  C:\Users\Administrator\Desktop\Log.txt -Append -ErrorAction Ignore
    ## Standard setup - COMMENT out if already setup
    New-NetIPAddress -InterfaceIndex 4 -IPAddress 192.168.202.2 -PrefixLength 24 -DefaultGateway 192.168.61.2
    Set-DnsClientServerAddress -InterfaceIndex 4 -ServerAddresses ("192.168.202.2")
    Rename-Computer -NewName $name -Passthru
    Restart-Computer -Wait 
    Write-Output $Now2 "After reboot" | Out-File C:\Users\Administrator\Desktop\Log.txt -Append
}

## NOTE: replace $PSPath with location of the powershell script to be ran afterwards
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


# Initial Code ######


<# workflow test-restart {
    Write-Output "Before reboot" | Out-File  C:/Log/t.txt -Append
    Restart-Computer -Wait
    Write-Output "$Now2 After reboot" | Out-File  C:/Log/t.txt -Append
}

$PSPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$Args = '-NonInteractive -WindowStyle Hidden -NoLogo -NoProfile -NoExit -Command "& {Import-Module PSWorkflow ; Get-Job | Resume-Job}"'
$Action = New-ScheduledTaskAction -Execute $PSPath -Argument $Args
$Option = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -WakeToRun
$Trigger = New-JobTrigger -AtStartUp -RandomDelay (New-TimeSpan -Minutes 5)
Register-ScheduledTask -TaskName ResumeJob -Action $Action -Trigger $Trigger -Settings $Option -RunLevel Highest


test-restart -AsJob #>


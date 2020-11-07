#
# Windows PowerShell script for AD DS Deployment
#

Import-Module ADDSDeployment
Install-ADDSDomainController `
    -NoGlobalCatalog:$false `
    -CreateDnsDelegation:$false `
    #-Credential (Get-Credential) `
    -CriticalReplicationOnly:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainName "sleepygeeks.com" `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$false `
    -ReplicationSourceDC "SG-DC01.sleepygeeks.com" `
    -SiteName "Edmonton" `
    -SysvolPath "C:\Windows\SYSVOL" `
    -WarningAction 'Ignore'
    -Force:$true


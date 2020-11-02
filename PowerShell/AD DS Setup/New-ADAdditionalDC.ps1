<# Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

Import-module ADDSDeployment

# Windows PowerShell script for AD DS Deployment
Install-ADDSDomainController `
    -NoGlobalCatalog:$false `
    -CreateDnsDelegation:$false `
    -CriticalReplicationOnly:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainName "sleepygeeks.com" `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$false `
    -SiteName "Edmonton" `
    -SysvolPath "C:\Windows\SYSVOL" `
    -SafeModeAdministratorPassword (ConvertTo-SecureString "Password1" -AsPlainText -Force)
    -Force:$true
 #>
# Verify
# Get-ADForest
# NetdOM /query FSMO

#
# Windows PowerShell script for AD DS Deployment
#

Import-Module ADDSDeployment
Install-ADDSDomainController `
    -NoGlobalCatalog:$false `
    -CreateDnsDelegation:$false `
    -Credential (Get-Credential) `
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


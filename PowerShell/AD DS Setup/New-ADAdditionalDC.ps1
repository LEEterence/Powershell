Install-WindowsFeature -Name AD-Domain-Services –IncludeManagementTools

Import-module ADDSDeployment

    # Windows PowerShell script for AD DS Deployment

    Install-ADDSDomainController -NoGlobalCatalog:$false -CreateDnsDelegation:$false -CriticalReplicationOnly:$false -DatabasePath “C:\Windows\NTDS” -DomainName “sleepygeeks.com” -InstallDns:$true -LogPath “C:\Windows\NTDS” -NoRebootOnCompletion:$false -SiteName “Edmonton” -SysvolPath “C:\Windows\SYSVOL” -Force:$true

# Verify
# Get-ADForest
# NetdOM /query FSMO
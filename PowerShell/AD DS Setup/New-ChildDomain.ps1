# Pretty much the same as join-domaintree


Import-Module ADDSDeployment
Install-ADDSDomain `
-NoGlobalCatalog:$false `
-CreateDnsDelegation:$false `
-Credential (Get-Credential) `
-DatabasePath "C:\Windows\NTDS" `
-DomainMode "Win2012R2" `
-DomainType "TreeDomain" `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NewDomainName "pennco.edu" `
-NewDomainNetbiosName "PENNCO" `
-ParentDomainName "PenncoDomain.edu" `
-NoRebootOnCompletion:$false `
-SiteName "Default-First-Site-Name" `
-SysvolPath "C:\Windows\SYSVOL" `
-SafeModeAdministratorPassword $DSRM `
-Force:$true
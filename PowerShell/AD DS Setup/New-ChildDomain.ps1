# Similar to join-domaintree but DomainType is different
$DomainName = Read-Host "Enter full domain name (ie. example.com)"        #Ex) terence.local
$DomainNetBios = Read-Host "Enter domain net bios value (ie. EXAMPLE)"     #Ex) TERENCE
$ParentDomain = Read-Host "Enter the parent domain"
$Site = Read-Host "Enter the Site"
$DSRM = ConvertTo-SecureString "Password1" -AsPlainText -Force

Import-Module ADDSDeployment
Install-ADDSDomain `
    -NoGlobalCatalog:$false `
    -CreateDnsDelegation:$false `
    -Credential (Get-Credential) `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode "WinThreshold" `
    -DomainType "ChildDomain" `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NewDomainName $DomainName `
    -NewDomainNetbiosName $DomainNetBios `
    -ParentDomainName $ParentDomain `
    -NoRebootOnCompletion:$false `
    -SiteName $Site `
    #-SiteName "Default-First-Site-Name" `
    -SysvolPath "C:\Windows\SYSVOL" `
    -SafeModeAdministratorPassword $DSRM `
    -Force:$true
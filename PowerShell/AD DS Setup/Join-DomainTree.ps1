#
# Windows PowerShell script for AD DS Deployment
#
$DomainName = Read-Host "Enter full domain name (ie. example.com)"        #Ex) terence.local
$DomainNetBios = Read-Host "Enter domain net bios value (ie. EXAMPLE)"     #Ex) TERENCE
$ForestRootDomain = Read-Host "Enter the forest root domain"
$DSRM = ConvertTo-SecureString "Password1" -AsPlainText -Force

Install-WindowsFeature –Name AD-Domain-Services -IncludeManagementTools

Import-Module ADDSDeployment
Install-ADDSDomain `
    -NoGlobalCatalog:$false `
    -CreateDnsDelegation:$false `
    -Credential (Get-Credential) `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode "WinThreshold" `
    -DomainType "TreeDomain" `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NewDomainName $DomainName `
    -NewDomainNetbiosName $DomainNetBios `
    -ParentDomainName $ForestRootDomain `
    -NoRebootOnCompletion:$false `
    -SiteName "Default-First-Site-Name" `
    -SysvolPath "C:\Windows\SYSVOL" `
    -SafeModeAdministratorPassword $DSRM `
    -Force:$true


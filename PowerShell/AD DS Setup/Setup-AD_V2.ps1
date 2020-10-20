<# 
~ AD DS Setup (WIP) 

#>
$DomainName = Read-Host "Enter full domain name (ie. example.com)"        #Ex) terence.local
$DomainNetBios = Read-Host "Enter domain net bios value (ie. EXAMPLE)"     #Ex) TERENCE
$DSRM = ConvertTo-SecureString "Password1" -AsPlainText -Force

Install-WindowsFeature –Name AD-Domain-Services -IncludeManagementTools

Import-Module ADDSDeployment
# AD DS installation
Install-ADDSForest `
    -CreateDnsDelegation:$false `
    -DomainMode "WinThreshold" `
    -DomainName $DomainName `
    -DomainNetbiosName $DomainNetBios `
    -ForestMode "WinThreshold" `
    -InstallDns:$true `
    -DatabasePath "C:\Windows\NTDS" `
    -LogPath "C:\Windows\NTDS" `
    -SysvolPath "C:\Windows\SYSVOL" `
    -NoRebootOnCompletion:$true `
    -SafeModeAdministratorPassword $DSRM `
    -Force:$true
Restart-Computer 


# After Restart, then verify below
Get-Service adws,kdc,netlogon,dns
Get-ADDomainController
Get-ADDomain $domainname

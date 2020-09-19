# AD DS Setup (WIP)
# REMEMBER TO CHANGE VALUES EACH TIME!!!!!! # Remember to CHANGE DOMAINNAME and DomainNetbiosName
$DomainName = ""        #Ex) terence.local
$DomainNetBios = ""     #Ex) TERENCE
$DSRM = ConvertTo-SecureString "Password1" -AsPlainText -Force
# DatabasePath is where AD database is stored (NTDS.dit), Domain mode and Forest mode is the functional level (the tpye of windows server 2012 r2, 2016, 2019,etc.)
Install-WindowsFeature –Name AD-Domain-Services -IncludeManagementTools
<# 
TODO attempt reboot run without import-module, compare with 1A pdf in mail server, test removing import-module below
TODO #issue may be the safemodeadminpassword is prompting but poewrshell doesn't appear - it looks like it worked when hardcoding password 
Solution may be to prompt user if hardcoding password is unacceptable ie. outside of test environment 
#>
Import-Module ADDSDeployment
# AD DS installation
Install-ADDSForest `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode "WinThreshold" `
    -DomainName $DomainName `
    -DomainNetbiosName $DomainNetBios `
    -ForestMode "WinThreshold" `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$false `
    -SysvolPath "C:\Windows\SYSVOL" `
    -SafeModeAdministratorPassword $DSRM `
    -Force:$true
# Will be Prompted for DSRM recovery password, must set -NoRebootOnCompletion to $false
# May require a COMPLEX password
Restart-Computer 


# After Restart, then verify below - COMMENT OUT FIRST
#Get-Service adws,kdc,netlogon,dns
#Get-ADDomainController
#Get-ADDomain $domainname

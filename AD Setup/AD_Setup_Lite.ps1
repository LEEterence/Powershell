<# 
TODO Will test this script to see if it works with reboot_run
#>

Install-WindowsFeature –Name AD-Domain-Services -IncludeManagementTools 
Import-Module ADDSdeployment 
Install-ADDSForest `
    –DomainName dmit2515.local `
    –SafeModeAdministratorPassword (ConvertTo-SecureString Password1 –AsPlainText –Force) `
    –DomainMode WinThreshold `
    –DomainNetbiosname ENRON  `
    –ForestMode WinThreshold `
    -InstallDNS `
    -Confirm:$False

Restart-Computer -Confirm

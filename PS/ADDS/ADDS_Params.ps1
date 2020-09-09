# create more variables
Install-WindowsFeature –Name AD-Domain-Services -IncludeManagementTools
Import-Module ADDSDeployment
$password = ConvertTo-SecureString "Password1" -Force

$Params = @{
    CreateDnsDelegation = $false
    DatabasePath = 'C:\Windows\NTDS'
    DomainMode = 'WinThreshold'
    DomainName = 'test.local'
    DomainNetbiosName = 'TEST'
    ForestMode = 'WinThreshold'
    InstallDns = $true
    LogPath = 'C:\Windows\NTDS'
    NoRebootOnCompletion = $true
    SafeModeAdministratorPassword = $Password
    SysvolPath = 'C:\Windows\SYSVOL'
    Force = $true
}
 
Install-ADDSForest @Params
Restart-Computer -Confirm
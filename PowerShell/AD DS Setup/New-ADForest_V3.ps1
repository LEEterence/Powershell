<# 
~ AD DS Setup (WIP) 

#>
function New-ADForest{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $DomainName,

        # Can aqlso use IgnoreCase if I'm specifying the NetBios name
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[A-Z]+$', Options = 'None')]
        [string]
        $DomainNetBios,

        # This parameter is only for setting up Hyper-V
        [Parameter(Mandatory = $false)]
        [string]
        $VMName,

        [Parameter(Mandatory = $false)]
        [string]
        $ForestMode = 'WinThreshold',

        [Parameter(Mandatory = $false)]
        [string]
        $DomainMode = 'WinThreshold',

        [Parameter(Mandatory = $true)]
        [SecureString]
        $SafeModeAdminPassword,

        # For remotely installing AD
        [Parameter(Mandatory = $false)]
        [SecureString]
        $Credential
    )
    #$DomainName = Read-Host "Enter full domain name (ie. example.com)"        #Ex) terence.local
    #$DomainNetBios = Read-Host "Enter domain net bios value (ie. EXAMPLE)"     #Ex) TERENCE
    #$DSRM = ConvertTo-SecureString "Password1" -AsPlainText -Force

    # Maybe implement 
    $DomainNetBios = $DomainNetBios.ToUpper()

    Install-WindowsFeature –Name AD-Domain-Services -IncludeManagementTools
    Import-Module ADDSDeployment
    # AD DS Forest installation
    Install-ADDSForest `
        -CreateDnsDelegation:$false `
        -DomainName $DomainName `
        -DomainNetbiosName $DomainNetBios `
        -DomainMode $DomainMode `
        -ForestMode $ForestMode `
        -InstallDns:$true `
        -DatabasePath "C:\Windows\NTDS" `
        -LogPath "C:\Windows\NTDS" `
        -SysvolPath "C:\Windows\SYSVOL" `
        -NoRebootOnCompletion:$true `
        -SafeModeAdministratorPassword $SafeModeAdminPassword `
        -warningaction 'Ignore' `
        -Force:$true
    Restart-Computer 

    # After Restart, MANUALLY run code below to verify setup
    Get-Service adws,kdc,netlogon,dns
    Get-ADDomainController
    Get-ADDomain $domainname
}






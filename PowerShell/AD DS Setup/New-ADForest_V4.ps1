<# 
~ AD DS Setup (WIP) 

#>
<#
 .Synopsis
  Displays a visual representation of a calendar.

 .Description
  Automates setup of AD with optional use of external credentials 

 .Example
   # Import in a secure XML file with safe mode password then directly inputting parameter
   $safeModePw = Import-CliXml -Path C:\PowerLab\SafeModeAdministratorPassword.xml
   New-ADForest -SafeModePassword $safeModePw -DomainName test.local -DomainNetBios TEST

 .Example
 # Prompt for a secure string to be input for the Safe Mode admin password
 New-ADForest -DomainName test.local -DomainNetBios TEST
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

        # This parameter is only for setting up Hyper-V (WIP)
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

        # For remotely installing AD (WIP)
        [Parameter(Mandatory = $false)]
        [SecureString]
        $Credential
    )
    # Maybe implement - ValidatePattern above prevents lowercase netbios anyways
    #$DomainNetBios = $DomainNetBios.ToUpper()

    Install-WindowsFeature –Name AD-Domain-Services -IncludeManagementTools
    Import-Module ADDSDeployment
    $ForestParameters =@{
        CreateDnsDelegation             = $false 
        DomainName                      = $DomainName 
        DomainNetbiosName               = $DomainNetBios 
        DomainMode                      = $DomainMode 
        ForestMode                      = $ForestMode 
        InstallDns                      = $true 
        DatabasePath                    = "C:\Windows\NTDS" 
        LogPath                         = "C:\Windows\NTDS" 
        SysvolPath                      = "C:\Windows\SYSVOL" 
        #NoRebootOnCompletion           = $true 
        SafeModeAdministratorPassword   = $SafeModeAdminPassword 
        WarningAction                   = 'Ignore' 
        Force                           = $true
    }

    # AD DS Forest installation
    $null = Install-ADDSForest @ForestParameters
    #Restart-Computer 

    # After Restart, MANUALLY run code below to verify setup
    Get-Service adws,kdc,netlogon,dns
    Get-ADDomainController
    Get-ADDomain 
}







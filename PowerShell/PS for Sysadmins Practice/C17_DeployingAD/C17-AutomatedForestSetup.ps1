<# 
~ Function to automate building Active Directory

@ Change Mandatory for false for all except for credential and safe mode password if using manually entering values intead of implementing read-host

Example execution at the bottom
#>

function New-ActiveDirectoryForest{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty]
        [string]
        $SafeModePassword,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty]
        [string]
        $Credential,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty]
        [string]
        $DomainName,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty]
        [string]
        $DomainMode,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty]
        [string]
        $ForestMode,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty]
        [string]
        $VMName
    )
    Invoke-Command -VMName $VMName -Credential $Credential -ScriptBlock {
        $ForestParameters =@{
            DomainName                    = $using:DomainName
            DomainMode                    = $using:DomainMode
            ForestMode                    = $using:ForestMode
            Confirm                       = $false
            SafeModeAdministratorPassword = (ConvertTo-SecureString -AsPlainText -String $using:SafeModePassword -Force)
            WarningAction                 = 'Ignore'
        }
        $null = Install-ADDSForest @ForestParameters
    }
}

<# 
@ Example Execution @

#>
#$safeModePw = Import-CliXml -Path C:\PowerLab\SafeModeAdministratorPassword.xml
#$cred = Import-CliXml -Path C:\PowerLab\VMCredential.xml
    # NOTE this contains admin password of local computer
#New-PowerLabActiveDirectoryForest -Credential $cred -SafeModePassword $safeModePw

<# 
@ Verification @
  Prompt myself for creds then export - 
  ! this should be a domain admin account b/c once the Forest has been installed the admin account of the forest is required to query it
#>
#Get-Credential | Export-CliXml -Path C:\PowerLab\DomainCredential.xml
function Test-PowerLabActiveDirectoryForest {
    param(
        [Parameter(Mandatory)]
        [pscredential]$Credential,

        [Parameter()]
        [string]$VMName = 'LABDC'
    )

    Invoke-Command -Credential $Credential -ScriptBlock {Get-AdUser -Filter * }
}
<# 
@ Example Execution 
#>
#$domaincred = Import-CliXml -Path C:\PowerLab\DomainCredential.xml
#New-PowerLabActiveDirectoryForest -Credential $domaincred 
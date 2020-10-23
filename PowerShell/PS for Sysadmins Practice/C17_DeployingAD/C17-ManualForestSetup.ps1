<# 
~ Performing a "manual setup" using Hyper-V
#>

$cred = ""

# Installing AD windows feature remotely 
Invoke-Command -VMName 'LabDC' -Credential $cred -ScriptBlock {Install-windowsfeature -Name -AD-Domain-Services}
# Creating TEST password and storing locally to disk
'Password1' | ConvertTo-SecureString -Force -AsPlainText | Export-Clixml -Path .\SafeModeAdministratorPassword.xml
$safemodepassword = Import-Clixml -Path ".\SafeModeAdministratorPassword.xml"

$forestparameters = @{
    DomainName                    = 'powerlab.local' 
    DomainMode                    = 'WinThreshold' 
    ForestMode                    = 'WinThreshold'
    Confirm                       = $false 
    SafeModeAdministratorPassword = $safeModePw 
    WarningAction                 = 'Ignore' 
}

Invoke-Command -VMName 'LabDC' -Credential $cred -scripblock {$null = Install-ADDSForest @using:forestparameters}
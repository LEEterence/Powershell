<#
CSV and input required methods coming
#>

# Creating AD user from powershell line
New-ADUser -Name "RDUser" -AccountPassword (ConvertTo-SecureString "Password1" -AsPlainText -Force) -PassThru -GivenName "RDUser" -SamAccountName "RDuser" -Enabled $true -UserPrincipalName "rduser@terence.local"

<#
CSV and input required methods coming

 - for CSV create a document with titles
#>

# FULL Creating AD user from powershell line
New-ADUser `
    -Name "Kevin Sapp" `
    -GivenName "Kevin" `
    -Surname "Sapp" `
    -SamAccountName "kesapp-test" `
    -AccountPassword (Read-Host -AsSecureString "Input User Password") `
    #@ Change this depending on test vs production
    -ChangePasswordAtLogon $False `
    -Company "Code Duet" `
    -Title "CEO" `
    -State "California" `
    -City "San Francisco" `
    -Description "Test Account Creation" `
    -EmployeeNumber "45" `
    -Department "Engineering" `
    -DisplayName "Kevin Sapp (Test)" `
    -Country "us" `
    -PostalCode "940001" `
    -Enabled $True

# TEST Creating AD user from powershell line
New-ADUser `
    -Name "Kevin Sapp" `
    -GivenName "Kevin" `
    -Surname "Sapp" `
    -SamAccountName "kesapp-test" `
    #@ Change this depending on if a single new user or multiple
    -AccountPassword (Read-Host -AsSecureString "Input User Password") `
    #@ Change this depending on test vs production
    -ChangePasswordAtLogon $False `
    -DisplayName "Kevin Sapp (Test)" `
    -Enabled $True

# Create user and set properties
New-ADUser -Name "ChewDavid" -OtherAttributes @{'title'="director";'mail'="chewdavid@fabrikam.com"}

# Import and export csv file

Export-Csv -filter * -properties * -Path C:\input.txt
Import-Csv -Path C:\input.txt

# Using existing csv and exporting to a separate csv
$ADusers = Import-Csv -Path C:\input.txt
$ADusers.foreach({$id = $id.empid 
    Get-ADUser -filter {employeeid -eq $id} -properties DisplayName,Userprincipalname,SAMaccountname | Select-Object DisplayName,Userprincipalname,SAMaccountname | Export-Csv -Path C:\output.csv
})

# Using templates to distribute the same 
$template_account = Get-ADUser -Identity kesapp-test -Properties State,Department,Country,City
# UPN is set to null to ensure templates UPN is unique - EVERY AD ACCOUNT MUST HAVE A UNIQUE UPN
$template_account.UserPrincipalName = $null

<# 
Source:
https://adamtheautomator.com/new-aduser/ 
#>
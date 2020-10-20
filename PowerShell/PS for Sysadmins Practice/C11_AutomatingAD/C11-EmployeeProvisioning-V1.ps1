<# 
~ Adjust parameter for new user
Goals:
    Dynamically create a username for user based on the first name and last name
    Create and assign the user a random password
    Force the user to change their password at logon
    Set the department attribute based on the department given
    Assign the user an internal employee number

#>

# @ NOTE: this is BELOW IS NOT A COMMENT - it checks modules to see if I have ActiveDirectory module installed & imported
#Requires -Module ActiveDirectory

$filelocation = ''

$csv = Import-Csv $filelocation

$username = $Parameters.firstname + '.' + $Parameters.Lastname
$password = -join ((40..90) + (97..122) | Get-Random -Count 10 | ForEach-Object{[char]$_})
$ID = -join((1..9 ) | Get-Random -Count 5)

$Parameters = @{
    FirstName = $_.GivenName
    LastName = $_.Surname
    Department = $_.Department
}

New-ADUser @Parameters -UserPrincipalName $username -AccountPassword (ConvertTo-SecureString $password -Force) -ChangePasswordAtLogon

# Random Password String
    # 65 - 90, 97 - 122 are ASCII numbers that correspond to letters 
    # Get-Random chooses random numbers based on the count value
    # Random numbers are piped into foreach-object which casts them to a character value
    # Surround entire oneline in paraentheses and put a join operator at the beginning so they are joined into a horizontal output
    # Source: https://devblogs.microsoft.com/scripting/generate-random-letters-with-powershell/
#-join((65..90) + (97..122) | Get-Random -Count 5 | ForEach-Object{[char]$_})

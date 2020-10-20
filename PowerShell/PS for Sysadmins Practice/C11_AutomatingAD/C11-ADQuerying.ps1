<# 
~ Querying for AD Objects
#>

# Basics ############################
Import-Module ActiveDirectory
# Good idea for finding commands
Get-Command -Module ActiveDirectory -Verb Get -Noun '*User*'
#Filtering 
Get-ADComputer -Filter 'Name -like "D*"'
# Alternative to filtering through 'Get-AD' options
Search-ADAccount -AccountInactive -Timespan 90.00:00:00 -UsersOnly
# When you know exact AD objects to query
Get-ADComputer -identity "DC01"

# Getting ALL PROPERTIES ############################
# Method 1: shows some extended properties but NOT ALL
Get-ADUser -Filter * | Select-Object -Property *
# @ Method 2: SHOWS ALL PROPERTIES - this will output a crapton of properties back - avoid filtering for all like below example
Get-ADUser -Filter * -properties *
Get-ADUser -Filter 'Name -like "Administrator"' -Properties *
    # NOTE: -properties parameter adds parameter to the output, must pipe into Select-Object to specify output
    Get-ADUser -Filter 'Name -like "Administrator"' -Properties * | Select-Object Name, PasswordLastSet
# @ Method 3: Shows ALL Properties in .NET user class (not necessary for simple administration)
$schema =[DirectoryServices.ActiveDirectory.ActiveDirectorySchema]::GetCurrentSchema()
$userClass = $schema.FindClass('user')
$userClass.GetAllProperties().Name




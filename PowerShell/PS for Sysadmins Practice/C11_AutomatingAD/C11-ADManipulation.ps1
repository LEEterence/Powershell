Import-Module ActiveDirectory
# Good idea for finding commands
Get-Command -Module ActiveDirectory -Verb Get -Noun '*User*'
#Filtering 
Get-ADComputer -Filter 'Name -like "D*"'
# Alternative to filtering through 'Get-AD' options
Search-ADAccount -AccountInactive -Timespan 90.00:00:00 -UsersOnly
# When you know exact AD objects to query
Get-ADComputer -identity "DC01"
<# 
~ Populating domain 
    1. Read excel sheet of users & groups
    2. Check if OU assigned to each user exists. If not - create it
    3. Check if the group assigned to each user exists. If not - create it
    4. Check if the user exists - if not create it.
    5. Check if the user is in the assigned group, if not - Add the user to assigned group
#>
Import-Module ImportExcel

$FileLocation = Join-Path $env:USERPROFILE '\desktop'
$ADUsers = Import-Excel -Path $FileLocation -worksheetname 'Users'
$ADGroups = Import-Excel -Path $FileLocation -WorksheetName 'Groups'


Get-ADOrganizationalUnit -Filter "Name -eq '<OU NAME>'"
New-ADOrganizationalUnit -Name '<OU NAME>'

Get-ADGroup -Filter "Name -eq '<GROUP NAME>'"
New-ADGroup -Name '<GROUP NAME>' -Path "OU=<OU NAME>,dc=sleepygeeks,dc=com" -GroupScope "<GroupScope>"

Get-ADUser -Filter "Name -eq '<username>'"
New-ADUser -Name $ADuser.username -Path "OU=$($adusers.ou),dc=sleepygeeks,dc=com"

$ADUsers.username -in  (Get-ADGroup -identity '<GROuP Name>').Name
Add-ADGroupMember -Identity 'Test' -Members 'Username'
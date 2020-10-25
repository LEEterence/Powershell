<# 
~ Populating domain 
    1. Read excel sheet of users & groups
    2. Check if OU assigned to each user exists. If not - create it
    3. Check if the group assigned to each user exists. If not - create it
    4. Check if the user exists - if not create it.
    5. Check if the user is in the assigned group, if not - Add the user to assigned group
#>
#Requires -Module ImportExcel
#Install-Module ImportExcel
Import-Module ImportExcel

$FileLocation = Join-Path $env:USERPROFILE '\desktop\ActiveDirectoryObjects.xlsx'
$ADUsers = Import-Excel -Path $FileLocation -Worksheetname 'Users'
$ADGroups = Import-Excel -Path $FileLocation -WorksheetName 'Groups'


foreach ($group in $ADGroups){
    if(-not(Get-ADOrganizationalUnit -Filter "Name -eq '$($group.OUName)'")){
        New-ADOrganizationalUnit -Name $group.OUName -ProtectedFromAccidentalDeletion $false 
    }
    if(-not(Get-ADGroup -Filter "Name -eq '$($group.GroupName)'")){
        New-ADGroup -Name $group.GroupName -Path "OU=$($group.OUName),dc=sleepygeeks,dc=com" -GroupScope $group.type 
    }
}

foreach ($user in $ADUsers){
    # In case an OU is missed from being created above
    if(-not(Get-ADOrganizationalUnit -Filter "Name -eq '$($user.OUName)'")){
        New-ADOrganizationalUnit -Name $user.OUName -ProtectedFromAccidentalDeletion $false 
    }
    if(-not(Get-ADUser -Filter "Name -eq '$user.Username'")){
        New-ADUser -Name $User.username -Path "OU=$($user.OUName),dc=sleepygeeks,dc=com" -GivenName $user.firstname -Surname $user.lastname 
    }
    if(-not($Users.username -in (Get-ADGroup -identity $user.Memberof).Name)){
        Add-ADGroupMember -Identity $user.Memberof -Members $user.username 
    }
}
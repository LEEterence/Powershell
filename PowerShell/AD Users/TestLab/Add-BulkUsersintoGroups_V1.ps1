<# 
~ TEST LAB USE: Adds csv imported users randomly allocated to a list of groups

    1. Import users from user csv
    2. Check if user exists, if not create user
    3. Then add users into existing groups and OUs in a random fashion by obtaining the number of users in my target pool of groups. Then find the number of users existing in each group, sort them, and return the group with the least number of users.
    4. Add user to group with least number of users until user list is exhausted

    Future Additions: Create list of groups and OUs ahead of time

    Source: https://www.reddit.com/r/PowerShell/comments/4k2vph/script_to_randomly_assign_a_security_group/
#>


# Import active directory module for running AD cmdlets
Import-Module activedirectory

#@ Adjust where lcation of csv file is
$Filelocation = ""  # Ex) C:\Users\Administrators\desktop\bulk_users.csv
#@ Added onto the UPN
$domainName= ""     # Ex)test.local
#Store the data from ADUsers.csv in the $ADUsers variable
$ADUsers = Import-csv $Filelocation

#Loop through each row containing user details in the CSV file 
foreach ($User in $ADUsers)
{
	#Read user data from each field in each row and assign the data to a variable as below
		
	$Username 	= $User.username
	$Password 	= "Password1"
	$Firstname 	= $User.firstname
	$Lastname 	= $User.lastname
    $domainName = 'lee.local'

    #Check to see if the user already exists in AD
	if (Get-ADUser -F {SamAccountName -eq $Username})
	{
		 #If user does exist, give a warning
		 Write-Warning "A user account with username $Username already exist in Active Directory."
	}
	else
	{
		# If User does not exist then proceed to create the new user account
		New-ADUser `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@$domainname" `
            -Name "$Firstname $Lastname" `
            -GivenName $Firstname `
            -Surname $Lastname `
            -Enabled $True `
            -DisplayName "$Lastname, $Firstname" `
            -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -ChangePasswordAtLogon $False `
            -Path "ou=test users,dc=lee,dc=local" 
        
        # arraylist containing an array 
        $count = [System.Collections.ArrayList]@()
        #$groups = "Group 1","Group 2","Group 3","Group 4","Group 5","Group 6","Group 7","Group 8","Group 9","Group 10"
        $groups = Import-Csv -Path C:\Users\tlee37\Desktop\group.csv

        # Random add to group, $count is an arraylist containing the number of members in each group in the csv
        foreach ($group in $groups) {
            $count.Add([pscustomobject]@{Group=$group;Members=(Get-ADGroup -identity $group.name -Properties Member).Member.Count}) | Out-Null
        } 
        # Once count of group members has completed - sort by the members which automatically goes least to greatest. Grab the first value (the lowest) and obtain only the 'Group' parameter. Then add the current user from $ADusers to the group
        $FewestGroupUsercount = $($count | Sort-Object Members | Select-Object -First 1).Group
        Add-ADGroupMember -Identity $FewestGroupUsercount.Name -Members $Username 
	}
}

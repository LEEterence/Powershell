<# 
~ Script to add users to groups

@ Author: Terence Lee

From a csv of OUs:
 1. Check if the OU has members, if not move to next OU in CSV
 2. For OUs with members, obtain a list of groups
 3. Iterate through each user (assuming user doesn't have a group yet)
 4. For each user, obtain a list of groups and sort by least to most - taking the group with least members
 5. Add the current selected user in the foreach loop into the group (with the fewest members) 
 6. Repeat 3-5

Changes: cleaned up code
#>

$Filelocation = "C:\ALL SJ SCRIPTS\SoftwareJuice Departments.csv"  # Ex) C:\Users\Administrators\desktop\bulk_users.csv
$OUs = Import-csv $Filelocation

foreach($ou in $OUs){
    $groups = Get-ADGroup -Filter * -SearchBase "ou=$($ou.Name),$($ou.Path)" -SearchScope OneLevel| Select-Object samaccountname
    $Users = Get-ADUser -Filter * -SearchBase "ou=$($ou.Name),$($ou.Path)" -SearchScope OneLevel | Select-Object samaccountname

    if ($null -eq $groups){
        Write-Host "$($ou.Name) has no groups, skipping..." -ForegroundColor Magenta
    }elseif(-not($null -eq $Users)){
        write-host "$($ou.Name) group has members" -ForegroundColor Green

        # Random add to group, $count is an arraylist containing the number of members in each group in the csv
        foreach ($user in $users){
            $count = [System.Collections.ArrayList]@()
            
            # Obtain user count for each group
            foreach ($group in $groups) {
                $count.Add([pscustomobject]@{Group=$group;Members=(Get-ADGroup -identity $group.samaccountname -Properties Member).Member.Count}) | Out-Null
            } 
            # Once count of group members has completed - sort by the members which automatically goes least to greatest. Grab the first value (the lowest) and obtain only the 'Group' parameter. Then add the current user from $ADusers to the group
            $FewestGroupUsercount = $($count | Sort-Object Members | Select-Object -First 1).Group
            $null = Add-ADGroupMember -Identity $FewestGroupUsercount.samaccountname -Members $user.samaccountname -WhatIf
            Write-Host "[$($user.samaccountname)] added to the group [$FewestGroupUsercount]" -ForegroundColor Green
        }
    }
}
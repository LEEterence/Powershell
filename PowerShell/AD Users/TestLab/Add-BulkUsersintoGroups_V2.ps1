<# 
From a csv of OUs:
 1. Check if the OU has members, if not move to next OU in CSV
 2. For OUs with members, obtain a list of groups
 3. Iterate through each user (assuming user doesn't have a group yet)
 4. For each user, obtain a list of groups and sort by least to most - taking the group with least members
 5. Add the current selected user in the foreach loop into the group (with the fewest members) 
 6. Repeat 3-5

Changes: added code to complete randomization that fixes when OUs have multiple groups
#>

$Filelocation = "C:\Users\Administrator\Desktop\SleepyGeeks Departments.csv"  # Ex) C:\Users\Administrators\desktop\bulk_users.csv
#@ Added onto the UPN
#$domainName= ""     # Ex)test.local
# Store the data from ADUsers.csv in the $ADUsers variable
$OUs = Import-csv $Filelocation

foreach($ou in $OUs){
    $Users = Get-ADUser -Filter * -SearchBase "ou=$($ou.Name),$($ou.Path)" -SearchScope OneLevel | Select-Object samaccountname
    #"$($ou.path)"
    if ($null -eq $Users){
        Write-Host "OU has no members, skipping..."
    }elseif(-not($null -eq $Users)){
        write-host "$($ou.Name) has members" 
        $groups = Get-ADGroup -Filter * -SearchBase "ou=$($ou.Name),$($ou.Path)" -SearchScope OneLevel| Select-Object name

        #Random group add 
        #$groups = "Group 1","Group 2","Group 3","Group 4","Group 5","Group 6","Group 7","Group 8","Group 9","Group 10"
        #$groups = Import-Csv -Path C:\Users\tlee37\Desktop\group.csv

        # Random add to group, $count is an arraylist containing the number of members in each group in the csv
        foreach ($user in $users){
            $count = [System.Collections.ArrayList]@()

            foreach ($group in $groups) {
                $count.Add([pscustomobject]@{Group=$group;Members=(Get-ADGroup -identity $group.name -Properties Member).Member.Count}) | Out-Null
            } 
            # Once count of group members has completed - sort by the members which automatically goes least to greatest. Grab the first value (the lowest) and obtain only the 'Group' parameter. Then add the current user from $ADusers to the group
            $FewestGroupUsercount = $($count | Sort-Object Members | Select-Object -First 1).Group
            $null = Add-ADGroupMember -Identity $FewestGroupUsercount.Name -Members $user.samaccountname 
            Write-Host "[$($user.samaccountname)] added to the group [$FewestGroupUsercount]" -ForegroundColor Green
        }

    }

    
}
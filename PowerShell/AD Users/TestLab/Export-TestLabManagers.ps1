$check = Read-Host "Have you changed the search path for the OUs? (Y/N)"

if($check.ToUpper() -eq "Y"){
    Get-ADUser -Filter * -SearchBase "ou=Managers,ou=department users,dc=sleepygeeks,dc=com" -Properties * | Export-Csv -Path C:\Managers.csv
    Get-ADGroup -Filter * -SearchBase "ou=Managers,ou=department users,dc=sleepygeeks,dc=com" -Properties * | Export-Csv -Path C:\Manager_Groups.csv
    #Get-ADGroup -Filter * -SearchBase "ou=Managers,ou=department users,dc=sleepygeeks,dc=com" | Get-ADGroupMember | select -Property * | Export-Csv C:\ManagersPerGroup
    $users = Import-Csv -Path C:\Managers.csv
    $logfile = "C:\ManagersPerGroup.csv"
    add-content $logfile "Username,Group"
    foreach($user in $users){
        #add-content $logfile $user.Name
        $groups = Get-ADPrincipalGroupMembership $user.SamAccountName 
        foreach($group in $groups){
          add-content $logfile "$($user.Name),$($group.name)"
        }
      }
}else {
    Write-Host "Change itsadfasdfa!"
}
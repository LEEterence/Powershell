<# 
~ Code will be integrated with Add-aduser scripts
#>

#Add-ADGroupMember -Name "Group Name" -Members "New/Existing User"

$FileLocation = "C:\Users\Administrator\Desktop\SleepyGroups.csv"

$GroupPath = Import-Csv $FileLocation

foreach($group in $GroupPath){
    try{
        $CheckGroup = Get-ADGroup -Filter "SamAccountName -eq '$($group.SamAccountName)'" #-SearchBase $ou.Path
        if (-not($null -eq $CheckGroup)){
            Write-Host "$($group.Name) already exists. Skipping." -ForegroundColor DarkMagenta
        }else{
            New-ADGroup `
                -SamAccountName $group.SamAccountName `
                -Name $group.Name `
                -Path $group.path `
                -GroupScope $group.GroupScope `
                -GroupCategory $group.GroupCategory `
                #-whatif
        }
    }
    catch{
        Write-Host "$($group.Name) at the path $($group.path) could not be found. Check csv for errors." -ForegroundColor Red
    }
}


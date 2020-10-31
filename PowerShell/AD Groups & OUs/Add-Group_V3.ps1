<# 
~ Script to add groups to domain

@ Author: Terence Lee
#>
$FileLocation = "C:\Users\Administrator\Desktop\SleepyGroups.csv"

$GroupPath = Import-Csv $FileLocation

foreach($group in $GroupPath){
    try{
        # Verify if group already exists
        $CheckGroup = Get-ADGroup -Filter "SamAccountName -eq '$($group.SamAccountName)'" #-SearchBase $ou.Path
        if (-not($null -eq $CheckGroup)){
            Write-Host "$($group.Name) already exists. Skipping." -ForegroundColor DarkMagenta
        }else{
            # Execute group add, based on CSV
            New-ADGroup `
                -Name $group.Name `
                -DisplayName $group.Displayname `
                -Path $group.path `
                -GroupScope $group.GroupScope `
                -GroupCategory $group.GroupCategory `
                -Whatif
            
                Write-Host "[$($group.Name)] created successfully in $($Group.path)." 
        }
    }
    catch{
        Write-Host "$($group.Name) at the path $($group.path) could not be found. Check csv for errors." -ForegroundColor Red
    }
}


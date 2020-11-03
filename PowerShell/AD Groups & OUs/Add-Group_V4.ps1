<# 
~ Script to add groups to domain

@ Author: Terence Lee
#>
$FileLocation = "C:\Users\Administrator\Desktop\SleepyGroups.csv"

function New-BulkGroups {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [String]
        $FileLocation
    )
    $GroupPath = Import-Csv $FileLocation
    if (-not($CheckExists -eq $true)){
        Write-Host "CSV at this location doesn't exist" -ForegroundColor Red
    }else {
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
                        #-Whatif
                    
                    Write-Host "[$($group.Name)] created successfully in $($Group.path)." -ForegroundColor Green
                }
            }
            catch{
                Write-Host "$($group.Name) at the path $($group.path) could not be found. Check csv for errors." -ForegroundColor Red
            }
        }
    }
}



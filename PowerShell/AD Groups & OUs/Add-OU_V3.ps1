<# 
~ Script to add multiple OUs

@ Author: Terence Lee
#>
# NOTE: add parent OUs at the top
$FileLocation = "C:\Users\Administrator\Desktop\SleepyGeeks Departments.csv"

$OUPath = Import-Csv $FileLocation
foreach($ou in $OUPath){
    try{
        $CheckOU = Get-ADOrganizationalUnit -Filter "Name -eq '$($ou.name)'" #-SearchBase $ou.Path
        if (-not($null -eq $CheckOU)){
            Write-Host "$($ou.Name) already exists. Skipping." -ForegroundColor DarkMagenta
        }else {
            New-ADOrganizationalUnit `
                -Name $ou.Name `
                -DisplayName $ou.Displayname `
                -Path $ou.path `
                -ProtectedFromAccidentalDeletion $false
            Write-Host "$($ou.Name) at the path $($ou.path) added successfully." -ForegroundColor Green
        }
    }
    catch{
        Write-Host "$($ou.Name) at the path $($ou.path) could not be found. Check csv for errors." -ForegroundColor Red
    }
}

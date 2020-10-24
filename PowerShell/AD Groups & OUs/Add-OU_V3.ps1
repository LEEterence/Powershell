<# 
~ Script to add multiple OUs

@ NOTE: remember to add parent OUs at the very top
#>

$FileLocation = ""

$OUPath = Import-Csv $FileLocation
foreach($ou in $OUPath){
    try{
        #$CheckOU = [adsi]::Exists("LDAP://$($_.Path)")
        $CheckOU = Get-ADOrganizationalUnit -Filter "Name -eq '$($ou.name)'" -SearchBase $ou.Path
        #if ($CheckOU -eq $true) {
        if (-not($null -eq $CheckOU)){
            Write-Host "$($ou.Name) already exists. Skipping." -ForegroundColor DarkMagenta
        }else {
            New-ADOrganizationalUnit `
                -Name $ou.Name `
                -DisplayName $ou.Displayname `
                -Path $ou.path `
            
            Write-Host "$($ou.Name) at the path $($ou.path) added successfully." -ForegroundColor Green
        }
    }
    catch{
        Write-Host "$($ou.Name) at the path $($ou.path) could not be found. Check csv for errors."
    }
}

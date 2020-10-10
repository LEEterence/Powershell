<# 
~ Script to add multiple OUs

@ NOTE: remember to add parent OUs at the very top
#>

$FileLocation = ""

$OUPath = Import-Csv $FileLocation

$OUPath.foreach({
    $CheckOU = [adsi]::Exists("LDAP://$($item.Path)")
    if ($CheckOU -eq $true) {
        Write-Host "$($item.Name) already exists. Skipping." -ForegroundColor DarkMagenta
    }else {
        New-ADOrganizationalUnit `
            -Name $item.Name `
            -DisplayName $item.Displayname `
            -Path $item.path `
            -Whatif
    }
})

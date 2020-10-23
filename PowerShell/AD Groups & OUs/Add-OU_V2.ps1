<# 
~ Script to add multiple OUs

@ NOTE: remember to add parent OUs at the very top
#>

$FileLocation = ""

$OUPath = Import-Csv $FileLocation

$OUPath.foreach({
    $CheckOU = [adsi]::Exists("LDAP://$($_.Path)")
    if ($CheckOU -eq $true) {
        Write-Host "$($_.Name) already exists. Skipping." -ForegroundColor DarkMagenta
    }else {
        New-ADOrganizationalUnit `
            -Name $_.Name `
            -DisplayName $_.Displayname `
            -Path $_.path `
            -Whatif
    }
})

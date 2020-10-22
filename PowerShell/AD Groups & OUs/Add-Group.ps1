<# 
~ Code will be integrated with Add-aduser scripts
#>

#Add-ADGroupMember -Name "Group Name" -Members "New/Existing User"

$FileLocation = ""

$OUPath = Import-Csv $FileLocation

$OUPath.foreach({
    $CheckGroup = [adsi]::Exists("LDAP://$($item.Path)")
    if ($CheckGroup -eq $true) {
        Write-Host "$($item.Name) already exists. Skipping." -ForegroundColor DarkMagenta
    }else {
        New-ADGroup `
            -Name $item.Name `
            -DisplayName $item.Displayname `
            -Path $item.path `
            -Whatif
    }
})
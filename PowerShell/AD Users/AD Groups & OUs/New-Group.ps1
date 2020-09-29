<# 
~ Code will be integrated with Add-aduser scripts
#>
Import-Module ActiveDirectory 

$FileLocation = "" # Ex) C:\
$ADGroups = Import-Csv $FileLocation

$ADGroups.foreach
({
    $Path          = $_.Path
    $DisplayName   = $_.DisplayName
    $Name          = $_.Name
    # $GroupScope     = $_.GroupScope
    # $GroupCategory  = $_.GroupCategory

    $GroupCheck = Get-ADGroup -filter * | -Name -eq $Name

    if ($GroupCheck -eq $True){
        try {

            Write-Warning "A group with the name of $Name already exist in Active Directory."
        }
        catch {
            New-ADGroup `
                -Name $Name `
                -GroupScope "Global" `
                -DisplayName $DisplayName `
                -GroupCategory "Security"
                -Path $Path `
            
            Write-Host "Group $Displayname created at $Path"

            # -GroupScope "Global/Domain Local/Universal" 
            # -GroupCategory "Security/Distribution" 
        }

    }else {
        
    }
})


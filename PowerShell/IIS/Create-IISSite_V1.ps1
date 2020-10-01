<# 
 ~ Creating and managing IIS sites through PS
#>


# @Verification
Get-Website | Format-Table -AutoSize
Get-WebBindings
Get-ItemProperty "IIS:\Sites\<SiteName>"

# Pre-reqs

Import-Module WebAdministration -Force
Import-Module IISAdministration -Force


Get-ChildItem -Path 'IIS:\Sites'

Get-Website -Name "<SiteName>" | Start-website

Get-Website -Name "<SiteName>" | stop-website
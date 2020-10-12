Get-ADGroup -Filter 'GroupCategory -eq "Distribution" -and Name -eq "IT"' | Get-ADGroupMember

# Source: https://adamtheautomator.com/powershell-get-ad-group-members/#Getting_AD_Groups
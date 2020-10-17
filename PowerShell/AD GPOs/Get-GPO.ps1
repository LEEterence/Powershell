# Basic one-liner
Get-GPO -All -Domain "<Domain_Name>"

Import-Module Gpo
Get-GPOReport -All -ReportType HTML -Path C:\GPOReport_1.html

# Empty array to hold all possible GPO links            
$gPLinks = @()            
            
# GPOs linked to the root of the domain            
# !!! Get-ADDomain does not return the gPLink attribute            
$gPLinks += Get-ADObject -Identity (Get-ADDomain).distinguishedName `
-Properties name, distinguishedName, gPLink, gPOptions            
            
# GPOs linked to OUs            
# !!! Get-GPO does not return the gPLink attribute            
$gPLinks += Get-ADOrganizationalUnit -Filter * -Properties name, `
distinguishedName, gPLink, gPOptions            
            
# GPOs linked to sites            
$gPLinks += Get-ADObject -LDAPFilter '(objectClass=site)' `
-SearchBase "CN=Sites,$((Get-ADRootDSE).configurationNamingContext)" `
-SearchScope OneLevel -Properties name, distinguishedName, gPLink, gPOptions


# Source
# https://docs.microsoft.com/en-ca/archive/blogs/ashleymcglone/dude-wheres-my-gpo-using-powershell-to-find-all-of-your-group-policy-links
# https://pastebin.com/50EmnSxH
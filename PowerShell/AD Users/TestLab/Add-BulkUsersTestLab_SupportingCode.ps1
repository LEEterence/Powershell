#$OUs = Get-ADOrganizationalUnit -Filter * -SearchBase "ou=edmonton users,ou=Department Users,dc=sleepygeeks,dc=com" -Properties Name  -SearchScope OneLevel| 
#        Select-Object -ExpandProperty DistinguishedName
#$OUMemberCount = [System.Collections.ArrayList]@()
#ForEach($OU in $OUs){
#    $OUMemberCount.Add(
#        [pscustomobject]@{
#        OU = $ou
#        Members = (Get-ADUser -Filter * -SearchBase "$ou").count 
#    }) | Out-Null
#}
#$FewestOUCount = $($OUMemberCount | Sort-Object Members | Select-Object -First 1).OU
#$FewestOUCount


# Grab parent OU using Split Method (lowest, most direct OU). Used for department WITH SPACES
$DN= "ou=edmonton users,ou=Department Users,dc=sleepygeeks,dc=com"
$dept = $dn.Split('OU=|,OU=')[1]

#Additional code for cases where department doesn't have spaces
$DN= "ou=edmonton users,ou=Department Users,dc=sleepygeeks,dc=com"
$dn.Split('OU=|,OU=')[1]
$dn.Split(',=')[1]



# Determining city and company
#If ($_.Statefull -eq 'Alberta'){
#    $City = 'Edmonton'
#    $Company = 'SleepyGeeks'
#}
#If ($_.Statefull -eq 'British Columbia'){
#    $Company = 'SleepyGeeks'
#    $City = 'Vancouver'
#}
#If ($_.Statefull -eq 'Ontario'){
#    $City = 'Toronto'
#    $Company = 'SleepyGeeks'
#}
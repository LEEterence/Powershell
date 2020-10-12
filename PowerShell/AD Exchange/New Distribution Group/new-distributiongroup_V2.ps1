# Method is only from exchange

# 1. Import department csv
# 2. Get-mailbox organizationalunit
# 3. Create Distribution group using new-distributiongroup with its name based on department names in csv
# 4. Add-distributiongroupmember

# 1
#$Filelocation = "C:\Lab 1\departments.csv"
$OU = Import-Csv -Path $Filelocation
$OU | foreach-object {New-DistributionGroup -name $_.Name} 
#$OU.foreach({Get-ADUser -filter * -Searchbase $_.path | select -Property Userprincipalname, Distinguishedname})
$employee = Import-Csv "C:\lab 1\employees.csv"
$employee.foreach({Add-distributiongroupmember -identity $_.department -member $_.userprincipalname -verbose})


# 4
#get-mailbox -OrganizationalUnit "ou=Ou,dc=Constoso,dc=local" -resultsize unlimited |
#ForEach-Object { Add-DistributionGroupMember -Identity "GroupName" -Member $_ }

#$OU | foreach-object {Get-mailbox -OrganizationalUnit $_.path} | Get-ADUser -
#$OU
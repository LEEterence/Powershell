<#  
~ Create Distribution Groups based on departments from a CSV then adding users from a user list to its corresponding DG
@ Method is only from exchange 

#>

# 1. Import department csv
# 2. Get-mailbox organizationalunit
# 3. Create Distribution group using new-distributiongroup with its name based on department names in csv
# 4. Add-distributiongroupmember

# 1
# Departments.csv contains list of all departments
$Filelocation = "C:\Lab 1\departments.csv"
$OU = Import-Csv -Path $Filelocation
#@ To change the Name of the Distribution Group to be different then csv - alter the below code to this: 
    # $OU | foreach-object {New-DistributionGroup -name "$($_.Name)DG"}  
$OU | foreach-object {New-DistributionGroup -name $_.Name} 
# Employee list contains all department and UPNs, etc.
$employee = Import-Csv "C:\lab 1\employees.csv"
#@ To change the Name of the Distribution Group to be different then csv - alter the below code to this: 
    # $employee.foreach({Add-distributiongroupmember -identity "$($_.department)DG" -member $_.userprincipalname -verbose})
$employee.foreach({Add-distributiongroupmember -identity $_.department -member $_.userprincipalname -verbose})


# 4
#get-mailbox -OrganizationalUnit "ou=Ou,dc=Constoso,dc=local" -resultsize unlimited |
#ForEach-Object { Add-DistributionGroupMember -Identity "GroupName" -Member $_ }

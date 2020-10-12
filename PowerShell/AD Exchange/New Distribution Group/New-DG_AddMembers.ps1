$DepartmentName = Read-Host "Enter Department Name"
New-distributionGroup -Name $DepartmentName 
$Filelocation = "C:\Lab 1\departments.csv"
$OU = Import-Csv -Path $Filelocation
$OU | foreach-object {Add-DistributionGroupMember -identity $DepartmentName -member $_.name} 

Get-DistributionGroupMember -Identity $DepartmentName
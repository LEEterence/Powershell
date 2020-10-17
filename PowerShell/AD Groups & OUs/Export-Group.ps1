
# Get all security groups and non domainlocal groups
Get-ADGroup -filter {Groupcategory -eq 'Security' -AND GroupScope -ne 'domainlocal'}


# Get all security groups and non domainlocal groups
Get-ADGroup -filter "Groupcategory -eq 'Security' -AND Member -like '*'" |
# iterating through each object
ForEach-Object { 
 Write-Host "Exporting $($_.name)" -ForegroundColor Cyan
 #$name = $_.name -replace " ","-"
 $name = $_.name
 # Exporting to csv file per group
 $ExportFilePath = Join-Path -path "C:\temp" -ChildPath "$name.csv"
 # Obtaining all members to be recorded into each group
 Get-ADGroupMember -Identity $_.distinguishedname -Recursive |  
 # Get-ADobject is ensures that parameters don't come up empty 
 Get-ADObject -Properties SamAccountname,Title,Department |
 Select-Object Name,SamAccountName,Title,Department,DistinguishedName,ObjectClass |
 Export-Csv -Path $ExportFilePath -NoTypeInformation
}
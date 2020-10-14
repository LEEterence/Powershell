Get-ADGroup -filter {Groupcategory -eq 'Security' -AND GroupScope -ne 'domainlocal'}



Get-ADGroup -filter "Groupcategory -eq 'Security' -AND GroupScope -ne 'DomainLocal' -AND Member -like '*'" |
ForEach-Object { 
 Write-Host "Exporting $($_.name)" -ForegroundColor Cyan
 $name = $_.name -replace " ","-"
 $file = Join-Path -path "C:\temp" -ChildPath "$name.csv"
 Get-ADGroupMember -Identity $_.distinguishedname -Recursive |  
 Get-ADObject -Properties SamAccountname,Title,Department |
 Select-Object Name,SamAccountName,Title,Department,DistinguishedName,ObjectClass |
 Export-Csv -Path $file -NoTypeInformation
}
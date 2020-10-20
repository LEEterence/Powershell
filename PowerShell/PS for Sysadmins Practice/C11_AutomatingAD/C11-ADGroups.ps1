<# 
~ Group creation, modification
#>

# Creating a group and modifying parameters
New-ADGroup -Name 'Test Users' -Description 'All test users in the company' -GroupScope DomainLocal
Get-ADGroup -Identity 'Test Users' | Set-ADGroup -Description 'More Test users!'

# Removing and adding users or computers to group
Get-ADGroup -Identity 'Test Users' | Add-ADGroupMember Members 'jjones'
Get-ADGroup -Identity 'Test Users' | Remove-ADGroupMember Members 'jjones'
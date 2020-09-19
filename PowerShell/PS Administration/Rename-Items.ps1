<# 
~ Script information focusing on renaming multiple items at once. 
? Future:
 Regex

.example 
ls .\TaskScheduling\ -Recurse | Rename-Item -NewName { $_.Name -replace 'BasicTaskScheduler_RebootRun', 'New-RebootTask' }

#>

# 1. Recurse through target location
Get-ChildItem C:\Example -Recurse

# 2. Employ rename-item command along with paramter spcifying new name of item
Get-ChildItem C:\Example -Recurse | Rename-Item -NewName

# 3. Filter based on 'current' and 'new' into array. Use current PSITEM to change filtered values to new value.
Get-ChildItem C:\Example -Recurse | Rename-Item -NewName { $_.Name -replace 'Current', 'new' }
<# 
~ monitoring tool that tracks statuses of SERVICES and their timestamps then exports to Excel
#>

# Import required community module
Import-Module ImportExcel
$FilePath = Join-Path $env:USERPROFILE "Desktop"

# Grab all related properties
Get-Service | Select-Object -Property Name,Status,@{Name= 'TimeStamp';Expression={Get-Date -Format 'yyyy-MM-dd hh:mm:ss'}} | Export-Excel -Path $FilePath -WorksheetName Services
# Change some services then add to same excel sheet - REMEMBER TO APPEND
Get-Service | Select-Object -Property Name,Status,@{Name= 'TimeStamp';Expression={Get-Date -Format 'yyyy-MM-dd hh:mm:ss'}} | Export-Excel -Path $FilePath -WorksheetName Services -Append
# Parse excel sheet then Export with a Pivot table to summarize the differences
Import-Excel -Path $FilePath\ServiceStates.xlsx -WorksheetName 'Services' | Export-Excel -Path $FilePath\ServiceStates.xlsx -Show -IncludePivotTable -PivotRows Name,TimeStamp -PivotData @{TimeStamp = 'count'} -PivotColumns Status -WorksheetName Services

Import-Excel -Path $FilePath\ServiceStates.xlsx -WorksheetName Sheet1PivotTable 
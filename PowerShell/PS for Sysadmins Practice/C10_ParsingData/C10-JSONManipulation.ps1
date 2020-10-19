# Reads json file
Get-Content .\Employees.json -raw
# Parse JSON
Get-Content .\Employees.json -raw | ConvertFrom-Json
# Access certain JSON node
(Get-Content .\Employees.json -raw | ConvertFrom-Json).Employees

# Creating JSON Strings by converting CSV to JSON (we are using CSV, but it can be anything that can be manipulated in PS)
Import-Csv -Path .\employee2.csv | ConvertTo-Json
Import-Csv -Path .\employee2.csv | ConvertTo-Json | Out-File .\employee2.json
    # @ NOTE: Append parameter WON'T WORK PROPERLY - will cause formatting errors 
# Compress JSON output (less readability, but view larger JSON files easier)
Import-Csv -Path .\employee2.csv | ConvertTo-Json -Compress 


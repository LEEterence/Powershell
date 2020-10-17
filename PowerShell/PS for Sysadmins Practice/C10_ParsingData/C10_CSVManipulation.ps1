# Basics
get-content .\employee2.csv -raw
$firstrow = Import-csv -path .\employee2.csv | Select-Object -First 1
# using 'Property' will leave a header
$firstrow | Select-Object -Property name
# Using expandproperty won't leave a header
$firstrow | Select-Object -expandProperty name

# Replace delimiters - set-content to replace the original file
(Import-Csv -Path .\employee2.csv).Replace(',',"`t") | Set-Content -Path .\employee2.csv

# changing headers, then export it or set to change original
import-csv -path .\employee2.csv -Header 'Employee_FirstName','Employee_LastName','Dept','Manager'
# Note using out-file will result in an unstructured file (export-csv much better in majority of cases)
import-csv -path .\employee2.csv -Header 'Employee_FirstName','Employee_LastName','Dept','Manager' | Export-Csv -path C:\Employee3.csv -NoTypeInformation

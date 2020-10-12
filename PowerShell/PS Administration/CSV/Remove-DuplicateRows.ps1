$inputCSVPath = 'C:\BLOG_2020\DEMO\UserDetails.csv'
#The Import-Csv cmdlet creates table-like custom objects from the items in CSV files
$inputCsv = Import-Csv $inputCSVPath | Sort-Object * -Unique
#The Export-CSV cmdlet creates a CSV file of the objects that you submit. 
#Each object is a row that includes a comma-separated list of the object's property values.
$inputCsv | Export-Csv "C:\\BLOG_2020\DEMO\UserDetails_Final.csv"  -NoTypeInformation
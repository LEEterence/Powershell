$csv = Import-csv .\Replication-FullReport.csv -Delimiter ","
$csv | Select-Object  -Property * -ExcludeProperty showrepl_columns,"transport type" | format-table -a
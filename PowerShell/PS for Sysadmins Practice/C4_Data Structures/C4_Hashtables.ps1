
#~ Hashtable PRactice #######################

$serverList = @{
    'server1' = 'DC01'
    'server2' = 'RDS'
    'server3' = 'WSUS01'
}

#$serverList.Keys 
#$serverList.Add('server4','WDS01')
#$serverList.Values
## GetEnumerator grabs the whole hashtable - keys and values
#$serverList.GetEnumerator()

foreach ($item in $serverList){
    # This outputs the Value based on the key of server1
    Write-host "$($item.'server1')"
}

$employeeList = @{
    'Name' = "Albert Meyers","Andrea Ring","Juan Hernandez","Sandra Brawner"
}

#Import-Csv "E:\_Git\Powershell\PowerShell\PS for Sysadmins Practice\C4_Foreach.csv" | 
#Where-Object foreach ($item in $employeeList) {
#    
#}
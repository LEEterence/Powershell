
#~ Hashtable PRactice #######################

$serverList = @{
    'server1' = 'DC01'
    'server2' = 'RDS'
    'server3' = 'WSUS01'
}
$serverList.Keys 
$serverList.Add('server4','WDS01')
$serverList.Values
# GetEnumerator grabs the whole hashtable - keys and values
$serverList.GetEnumerator()
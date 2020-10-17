$csv = Import-Csv -path .\IPAddresses.csv

#@  Base testing
#Test-Connection -computername $csv[0].IPAddress -Quiet -Count 1
#(Resolve-DnsName -Name $csv[0].IPAddress -ErrorAction Stop).Name

#@ Using foreach to iterate through each 
#$csv.foreach({
#    test-connection $_.IPAddress -Quiet -Count 1
#    (Resolve-DnsName $_.IPAddress -ErrorAction Stop).Namehost
#})

#@ Hashtable to add error handling and splatting
<# $IP_Table = @{}
$csv.ForEach({
    # Method 1
    #$IP_Table[$_.IPAddress] = $_.department
    #Method 2
    $IP_Table.Add($_.IPAddress,$_.department)
})
$IP_Table #>

#@ Better method to check if device is online, if hostname exists, and output error messages
$csv.ForEach({
    try {
        # NOTE - the KEYS ARE NEVER VARIABLES. SHOULD NEVER HAVE A DOLLAR SIGN IN FRONT OF THE LEFT SIDE KEYS
        $Parameters = @{
            IP = $_.IPAddress
            Dept = $_.department
            IsOnline = $false
            HostName = $null
            Error = $null
        }
        If(Test-Connection -ComputerName $_.IPAddress -Quiet -Count 1){
            #Write-Host "$($_.IPaddress) is online" -ForegroundColor Green
            $Parameters.IsOnline = $true
        }
        if($Name = (Resolve-DnsName -Name $_.IPaddress -ErrorAction Stop).NameHost){
            #Write-Host "$($_.Ipaddress) dns resolution is  $Name"
            $Parameters.hostname = $Name    
        }
    }
    catch {
        $Parameters.Error = $_.Exception.Message
    }
    finally{
        # This will list all the values in hash table pretty ugly
        #$Parameters.GetEnumerator()
        [PSCustomObject] $Parameters | Export-Csv -Append .\DeviceDiscovery.csv -NoTypeInformation
    }
})
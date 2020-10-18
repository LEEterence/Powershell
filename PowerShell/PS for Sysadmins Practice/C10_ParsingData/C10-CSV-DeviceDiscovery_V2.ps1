<#  
~ Code to iterate through list of IP Addresses to obtain several characteristics, then output to another csv
~ Use Hashtable to hold all parameters, including additional parameters:
  - Testing Connectivity
  - Obtaining Hostname
  - Output for errors
#>

$csv = import-csv -Path .\IPAddresses.csv

$csv.ForEach({
    # Hashtable with all parameters required
    $Output = @{
        IP_Address = $_.IPAddress
        Department = $_.Department
        # Computer connectivity variable will end up here
        IsOnline = $false
        # Obtain hostname from Resolve-DNSname cmdlet
        HostName = $null
        # All caught errors will be placed into error message
        Error = $null
    }
    try{
        # Test if device is online 
        if(Test-Connection -ComputerName $_.IPAddress -Count 1 -Quiet){
            $Output.IsOnline = $True
        }
        # Test if IP address's hostname can be resolved
        if($Name = (Resolve-DnsName -Name $_.IPAddress -ErrorAction Stop).namehost){
            $Output.HostName = $Name
        }
    }
    catch{
        # All errors are collected and outputed in the hash
        $Output.Error = $_.Exception.Message
    }
    finally{
        $FilePath = Join-path $env:USERPROFILE 'Desktop\DeviceDiscovery.csv'
        # Convert to PSCustomObject to convert into structured data
        [PScustomobject]$Output | Export-Csv -Path $FilePath -NoTypeInformation -Append
    }
})

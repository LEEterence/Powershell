$csv = Import-Csv -path .\IPAddresses.csv

#@  Base testing
#Test-Connection -computername $csv[0].IPAddress -Quiet -Count 1
#(Resolve-DnsName -Name $csv[0].IPAddress -ErrorAction Stop).Name

#@ Using foreach to iterate through each 
#$csv.foreach({
#    test-connection $_.IPAddress -Quiet -Count 1
#    (Resolve-DnsName $_.IPAddress -ErrorAction Stop).Namehost
#})


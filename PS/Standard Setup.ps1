## Starting from the beginning - for setting up a server specifically for DHCP
$IPAddress =  192.168.201.1           # ie. 192.168.0.10
$IPAlias = "Ethernet0"               # ie. "Ethernet0"
$Computername = "TEST01"        # ie. DC01

New-NetIPAddress -IPAddress $IPAddress -InterfaceAlias $IPAlias  -AddressFamily IPv4 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias $IPAlias -ServerAddresses $IPAddress
Rename-Computer -NewName $Computername -Restart -Confirm
## OPTIONAL - Join to Domain (Specify “-Computername” if adding multiple computers remotely
#Add-Computer -DomainName dmit2023.local -Restart -DomainCredential dmit2023.local\administrator -verbose
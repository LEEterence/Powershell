## Starting from the beginning - for setting up a server specifically for DHCP
New-NetIPAddress -IPAddress 192.168.50.1 -InterfaceAlias "Ethernet0"  -AddressFamily IPv4 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses 192.168.50.1
Rename-Computer -NewName DC01 -Restart
## OPTIONAL - Join to Domain (Specify “-Computername” if adding multiple computers remotely
#Add-Computer -DomainName dmit2023.local -Restart -DomainCredential dmit2023.local\administrator -verbose
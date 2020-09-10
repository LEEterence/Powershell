## Starting from the beginning - for setting up a server specifically for DHCP
$IPAddress = "192.168.202.151"           # ie. 192.168.0.10
$IPAlias = "Ethernet"               # ie. "Ethernet0"
$DNSServer = "192.168.202.150"
$DefaultGateway = ""
$Computername = "WSUS01"        # ie. DC01
$DomainName = "dmit2023.local"
$DomainCredential = "dmit2023.local\administrator"


Get-NetIPAddress -InterfaceAlias $IPAlias -AddressFamily IPv4 | Remove-NetIPAddress
New-NetIPAddress -IPAddress $IPAddress -InterfaceAlias $IPAlias  -AddressFamily IPv4 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias $IPAlias -ServerAddresses $DNSServer
Rename-Computer -NewName $Computername -Restart -Confirm
## OPTIONAL - Join to Domain (Specify -Computernameâ€ if adding multiple computers remotely
Add-Computer -DomainName $DomainName -Restart $DomainCredential dmit2023.local\administrator -verbose

# Rename Computer ###################
## Method 1 - performed locally, domain credential is the user with admin rights
#Rename-Computer -NewName "Server044" -DomainCredential Domain01\Admin01 -Restart
## Method 2 - can be performed remotely, changes existing computer to a new name, NOTE: no restart in this option
#Rename-Computer -ComputerName "Srv01" -NewName "Server001" -DomainCredential Domain01\Admin01 -Force
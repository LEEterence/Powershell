## DHCP SERVER SETUP ########## (WIP)

# Starting from the beginning - for setting up a server specifically for DHCP
#New-NetIPAddress -IPAddress 192.168.202.10 -InterfaceAlias "Ethernet0"  -AddressFamily IPv4 -PrefixLength 24
#Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses 192.168.202.2
#Rename-Computer -NewName TEST01 -Restart
# OPTIONAL - Join to Domain (Specify “-Computername” if adding multiple computers           # remotely
#Add-Computer -DomainName dmit2023.local -Restart -DomainCredential dmit2023.local\administrator -verbose



## DHCP Server Specific 
Install-WindowsFeature DHCP -IncludeManagementTools
## Add security groups into AD
netsh dhcp add securitygroups
Restart-Service dhcpserver
## Authorize DHCP server to AD (normally blocked to prevent Rogue DHCP server)
Add-DhcpServerInDC -DnsName test01.test.local -IPAddress 192.168.202.10
## Verify DHCP server is authorized
Get-DhcpServerInDC
## Prevent false positive post-DHCP install prompt
Set-ItemProperty –Path registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12 –Name ConfigurationState –Value 2

# Set-DhcpServerv4DnsSetting -ComputerName "DHCP1.corp.contoso.com" -DynamicUpdates "Always" -DeleteDnsRRonLeaseExpiry $True
# 
# $Credential = Get-Credential
# Set-DhcpServerDnsCredential -Credential $Credential -ComputerName "DHCP1.corp.contoso.com"
# rem User will be prompted now to supply credentials in form DOMAIN\user, password

## Configure scope  of Domain - Corpnet
## DHCP client range, State refers to if the scope is active (default is active)
Add-DhcpServerv4Scope -name "DHCP testing scope" -StartRange 192.168.202.100 -EndRange 192.168.202.200 -SubnetMask 255.255.255.0 -State Active
## DHCP client excluded range
Add-DhcpServerv4ExclusionRange -ScopeID 192.168.202.0 -StartRange 192.168.202.150 -EndRange 192.168.202.170
## Reserving IP, Client ID is mac address of the client (in this case it is made up - just like all details of the device)
Add-DhcpServerv4Reservation -ComputerName test01.test.local -ScopeId 192.168.202.0 -ClientId F0-DE-F1-7A-00-5E -IPAddress 192.168.202.200 -Description "Fourth Floor Printer" -Name printer.test.com
## Setting DHCP options for DNS server, domain of DNS(dnsdomain), and default gateway (router). ALL THREE
Set-DhcpServerv4OptionValue -ComputerName test01.test.local -DnsServer 192.168.202.2 -DnsDomain test.local -Router 192.168.201.1
Add-DhcpServerv4Class -Name "User Class for Lab Computers" -Type User -Data "LabComputers"
## Option to just set default gateway
#Set-DhcpServerv4OptionValue -OptionID 3 -Value 10.0.0.1 -ScopeID 10.0.0.0 -ComputerName DHCP1.corp.contoso.com
## Option to just set dns domain and dns server
#Set-DhcpServerv4OptionValue -DnsDomain corp.contoso.com -DnsServer 10.0.0.2

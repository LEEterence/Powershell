<# 
~ General Setup
    - New IP address, Gateway, DNS Server 
    - Optional Join Domain
#>


$IPAddress = "192.168.202.4"           # ie. 192.168.0.10
$IPAlias = "Ethernet0"               # ie. "Ethernet0"
$DNSServer = "192.168.202.2"
$DefaultGateway = "192.168.202.2"
$Computername = "Server2"        # ie. DC01
$DomainName = "dmit2515.local"
$DomainCredential = "dmit2515.local\administrator"

# Verification
Write-Host "Network Adapter = $IPAlias `nIP Address = $IPAddress `nDefault Gateway = $DefaultGateway `nDNS Server = $DNSServer `nComputer Name = $Computername`n"
Write-Host "Settings Correct? (Y/N)" -ForegroundColor Cyan
$flag = Read-Host 

if ($flag.ToUpper() -eq 'Y') {
    # Disable IPv6 on all network adapters 
    Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6
    # Removing network adapter and adding new
    Get-NetIPAddress -InterfaceAlias $IPAlias -AddressFamily IPv4 | Remove-NetIPAddress -ErrorAction Stop
    New-NetIPAddress -IPAddress $IPAddress -InterfaceAlias $IPAlias  -AddressFamily IPv4 -PrefixLength 24 -DefaultGateway $DefaultGateway -ErrorAction Stop
    # Default Gateway may be removed in some cases
    Set-DnsClientServerAddress -InterfaceAlias $IPAlias -ServerAddresses $DNSServer
    Rename-Computer -NewName $Computername -Restart -Confirm

    ###@ OPTIONAL - Join to Domain (Specify -Computername if adding multiple computers remotely
    ##Add-Computer -DomainName $DomainName -Restart -credential $DomainCredential -verbose
}
else {
    Write-Host "Exiting - recheck script" -ForegroundColor Red
    Exit
}


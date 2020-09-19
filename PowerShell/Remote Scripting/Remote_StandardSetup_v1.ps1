$DHCP_IPAddress = "192.168.50.13"
$NewName = "RDS01"
$IPAddress = "192.168.50.6"
$Defaultgateway = "192.168.50.2"
$interfaceAlias = "Ethernet0"
$dnsServerAddress = "192.168.50.4"

Invoke-Command -Credential -Credential (Get-Credential -Credential Administrator) -ComputerName $DHCP_IPAddress -ScriptBlock {
    Start-Job -ScriptBlock { 
        New-NetIPAddress -IPAddress $Args[0] -InterfaceAlias $Args[1] -PrefixLength 24 -AddressFamily IPv4 -defaultgateway $Args[1] -def
        Set-DnsClientServerAddress -InterfaceAlias $Args[2] -ServerAddresses $Args[3]
        Rename-Computer $Args[4] -Restart
    } -ArgumentList $IPaddress, $defaultgateway, $interfaceAlias, $dnsServerAddress, $NewName
}
<# 
~ General Setup
    - New IP address, Gateway, DNS Server 
    - Optional Join Domain
#>

$check = ""
$flag = ""

do {
    $IPAddress = Read-Host "Enter IP Address"           # ie. 192.168.0.10
    $IPAlias = Read-Host "Enter Interface Alias (ie. Ethernet0)"               # ie. "Ethernet0"
    $DNSServer = Read-Host "Enter the DNS Server: "
    $DefaultGateway = Read-Host "Enter the default gateway"
    $Computername = Read-Host "Enter the computer name"        # ie. DC01
    
    #$Flag = Read-Host "Are you joining this computer to a domain? (Y/N)"
    #if ($Flag.ToUpper() -eq 'Y'){
        #$DomainName = "dmit2515.local"
        #$DomainCredential = "dmit2515.local\administrator"
    #}else {
    #    
    #}
    
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
        Set-DnsClientServerAddress -InterfaceAlias $IPAlias -ServerAddresses $DNSServer
        Rename-Computer -NewName $Computername -Restart -Confirm
        # OPTIONAL - Join to Domain (Specify -Computername if adding multiple computers remotely
        #Add-Computer -DomainName $DomainName -Restart -credential $DomainCredential -verbose
    }
    elseif ($flag.ToUpper() -eq 'N'){
        $check = Read-Host "Re-enter code? (Y/N)"

        if (-not ($check.ToUpper() -eq 'Y')){
            Write-Host "Exiting - recheck entries" -ForegroundColor Red
            Exit
        }
    }
} until (-not ($check -eq 'Y'))
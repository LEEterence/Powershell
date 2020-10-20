<# 
~ General Standard Setup
    - New IP address, Gateway, DNS Server 
    - Optional Join Domain (WIP)
#>

function Set-BasicSetup {
    [cmdletbinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory = $true,)]
        [ValidateNotNullOrEmpty]
        [string] $IPAddress,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty]
        [string] $IPAlias,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty]
        [string] $DNSServer,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty]
        [string] $DefaultGateway,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty]
        [string] $Computername
    )
    begin {
        $check = ""
        $flag = ""

    do {
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
            # Removing network adapter and creating new IPv4 information
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
    }
}


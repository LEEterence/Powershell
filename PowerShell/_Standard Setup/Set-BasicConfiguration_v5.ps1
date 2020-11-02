<# 
~ General Standard Setup
    - New IP address, Gateway, DNS Server, Disable IPv6, Enable ICMP echo in, rename computer 
    - Optional Join Domain (WIP)
#>

function Set-BasicConfiguration {
    [cmdletbinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory = $true)]
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
        [string] $Computername,

        [Parameter(Mandatory = $False)]
        [ValidateSet('y,n,Y,N')]
        [string] $JoinDomain = 'N'
    )
    begin {
        do {
            #$Flag = Read-Host "Are you joining this computer to a domain? (Y/N)"
            #if ($Flag.ToUpper() -eq 'Y'){
                #$DomainName = "dmit2515.local"
                #$DomainCredential = "dmit2515.local\administrator"
            #}else {
            #    
            #}
        
            # Verification
            Write-Host "`nNetwork Adapter = $IPAlias `nIP Address = $IPAddress `nDefault Gateway = $DefaultGateway `nDNS Server = $DNSServer `nComputer Name = $Computername`n" -ForegroundColor Cyan
            $flag = Read-Host "Continue with settings or exit? (Y/N)"
        
            if ($flag.ToUpper() -eq 'Y') {
                # Disable IPv6 on all network adapters 
                Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6
                # Removing network adapter and creating new IPv4 information
                Get-NetIPAddress -InterfaceAlias $IPAlias -AddressFamily IPv4 | Remove-NetIPAddress -ErrorAction Stop
                New-NetIPAddress -IPAddress $IPAddress -InterfaceAlias $IPAlias  -AddressFamily IPv4 -PrefixLength 24 -DefaultGateway $DefaultGateway -ErrorAction Stop
                Set-DnsClientServerAddress -InterfaceAlias $IPAlias -ServerAddresses $DNSServer
                # Enable Ping
                Enable-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)"
                Rename-Computer -NewName $Computername -Restart
                # OPTIONAL - Join to Domain (Specify -Computername if adding multiple computers remotely
                #Add-Computer -DomainName $DomainName -Restart -credential $DomainCredential -verbose
                }
            elseif ($flag.ToUpper() -eq 'N'){
                Write-Host "Exiting..." -ForegroundColor Red
            }else{
                Write-Host "Select Y to continue with Settings, N to exit script"
            }
        } until (-not ($flag.ToUpper() -eq 'Y'))
    }
}


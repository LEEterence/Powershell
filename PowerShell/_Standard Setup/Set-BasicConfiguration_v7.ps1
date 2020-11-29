<# 
~ General Standard Setup
    - New IP address, Gateway, DNS Server, Disable IPv6, Enable ICMP echo in, rename computer 
    WIP:
    - Optional Join Domain (possibly using RunOnce or Task Scheduler)
    Changes:
    - Changed to create new firewall rule with less annoying display name
#>

function Set-BasicConfiguration {
    [cmdletbinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory = $true)]
        [string] $IPAddress,

        [Parameter(Mandatory = $true)]
        [string] $IPAlias,

        [Parameter(Mandatory = $true)]
        [string] $DNSServer,

        [Parameter(Mandatory = $true)]
        [string] $DefaultGateway,

        [Parameter(Mandatory = $true)]
        [string] $Computername,

        [Parameter(Mandatory = $False)]
        [ValidateSet('y,n,Y,N')]
        [string] $JoinDomain = 'N'
    )
    begin {
        # Verification Settings Prompt
        Write-Host "`nNetwork Adapter = $IPAlias `nIP Address = $IPAddress `nDefault Gateway = $DefaultGateway `nDNS Server = $DNSServer `nComputer Name = $Computername`n" -ForegroundColor Yellow
        $flag = Read-Host "Continue with settings or exit? (Y/N)"

        if ($flag.ToUpper() -eq 'Y') {
            # Disable IPv6 on all network adapters 
            Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6
            
            # Removing network adapter and creating new IPv4 information
            Get-NetIPAddress -InterfaceAlias $IPAlias -AddressFamily IPv4 | Remove-NetIPAddress -ErrorAction Stop
            New-NetIPAddress -IPAddress $IPAddress -InterfaceAlias $IPAlias  -AddressFamily IPv4 -PrefixLength 24 -DefaultGateway $DefaultGateway -ErrorAction Stop
            Set-DnsClientServerAddress -InterfaceAlias $IPAlias -ServerAddresses $DNSServer
            
            # Enable Ping
            Write-Host "Enabling Echo Request - ICMPv4-In..." -ForegroundColor Cyan
            Start-Sleep 1
            #Enable-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)"
            New-NetFirewallRule -DisplayName "Allow ICMPv4-In" -Protocol ICMPv4

            # Renaming Computer
            Write-Host "Renaming computer to $ComputerName..." -ForegroundColor Cyan
            Start-Sleep 1
            Rename-Computer -NewName $Computername -Restart

            # OPTIONAL - Join to Domain (Specify -Computername if adding multiple computers remotely
            #Add-Computer -DomainName $DomainName -Restart -credential $DomainCredential -verbose
            #if ($JoinDomain.ToUpper() -eq 'Y'){
                #$DomainName = Read-Host "Specify domain name"
                #$DomainCredential = "dmit2515.local\administrator"
            #}else {
            #    
            #}
        }
    }
}


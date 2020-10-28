<# 
~ General Standard Setup
    - New IP address, Gateway, DNS Server, Disable IPv6, Enable ICMP echo in, rename computer 
    WIP:
    - Optional Join Domain 
    Changes:
    - Validating parameter null or empty doesn't work well, removed in this version until alternative can be found
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
        do {
            # Verification Settings Prompt
            Write-Host "`nNetwork Adapter = $IPAlias `nIP Address = $IPAddress `nDefault Gateway = $DefaultGateway `nDNS Server = $DNSServer `nComputer Name = $Computername`n" 
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
                Enable-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)"
                
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
            elseif ($flag.ToUpper() -eq 'N'){
                Write-Host "Exiting..." -ForegroundColor Red
            }else{
                Write-Host "Select Y to continue with Settings, N to exit script"
            }
        } until (-not ($flag.ToUpper() -eq 'Y'))
    }
}


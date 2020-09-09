## Enabling Remote Access - Two Methods
## To remote to one or more computers, we make use of Wsman (WS-Management) which WinRM (Windows Remote Management) uses
## 1. PS-Session - FOR SIMPLEST ADMIN ACTIONS (this is also called interactive mode)
	# Must run in admin and user network profile CANNOT BE PUBLIC - must be either Domain or Private

    # REMOTE COMPUTER
    # Following command enables a remote computer to be accessed, SkipNetworkProfileCheck is used to skip over checking for public profile
    Enable-PSRemoting -SkipNetworkProfileCheck -Force
        # To change a public network profile to Private
        Set-NetConnectionProfile -NetworkCategory Private
        # OR - change registry key HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles
            # Set "Profile Name" to be "1"
        # Command recommended by Microsoft:
        Set-NetFirewallRule –Name "WINRM-HTTP-In-TCP-PUBLIC" –RemoteAddress Any

    # LOCAL COMPUTER
    # WinRM must be enabled
    get-service winrm
    # If error persists - check error message for "TRUSTED HOSTS". If so, must add the remote device IP to local computers trusted hosts
        # Method 1: CMD
        winrm set winrm/config/client @{TrustedHosts="192.168.50.11"}
            # Winrm stands for Windows Remote Management
            # Can also run WinRM in PS by surrounding trusted host in quotation
            winrm set winrm/config/client '@{TrustedHosts="192.168.50.11"}'
        # Method 2: PS
            # WSMan - add, change, clear, and delete WS-Management configuration data on local or remote computers.
        Set-Item WSMan:\localhost\Client\TrustedHosts -Value "192.168.50.11" -Force
        # Trust all devices in test environments, or when IP changes often
        Set-Item WSMan:\localhost\Client\TrustedHosts -Value * -Force
        # Verify
        Get-Item WSMan:\localhost\Client\TrustedHosts
        # Clear WSMan of trusted hosts 
        Set-Item WSMan:\localhost\Client\TrustedHosts -Value "" -Force
        # REMOTE IN!
        $Credentials = Get-Credential
        Enter-PSSession -ComputerName 10.0.2.33 -Credential $Credentials

## 2. Invoke-Command (running complex commands or running scripts remotely)
##  NOTE: to use multiple related commands at once, must use Enter-PSSession first then Invoke-command
Invoke-Command -ScriptBlock {Script-code} -ComputerName server1
# Invoke-command may require credentials
$creds = Get-Credential
Invoke-Command -Credentials $creds -ScriptBlock {Script-code} -ComputerName server1

## Changing ip address at remote computer
Invoke-Command -ComputerName WDS01 -ScriptBlock {
     Start-Job -ScriptBlock { Set-NetIPAddress -IPAddress 192.168.50.3 -InterfaceAlias "Ethernet0"  -PrefixLength 24 -AddressFamily IPv4 -defaultgateway 192.168.50.2 } 
    }


## Testing 
$ServerName 
$IPaddress = 192.168.50.4
$defaultgateway = 192.168.50.2
$interfacealias = "Ethernet0"

Invoke-Command -ComputerName WDS01 -ScriptBlock {
    Set-NetIPAddress -IPAddress $Args[0] -InterfaceAlias $Args[1] -PrefixLength 24 -AddressFamily IPv4 -defaultgateway $Args[1]
    Set-DnsClientServerAddress -InterfaceAlias $Args[2] -ServerAddresses $Args[1]
} -ArgumentList $IPaddress, $defaultgateway, $interfacealias
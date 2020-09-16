## Comment out multiple lines ################################
<#
ALT +SHIFT + A
Ctrl+K+C/Ctrl+K+U
#>

#~ Base Commands
Get-Command
Get-Help
help
Get-Member
Get-Variable

#~ Setting Strict Mode - generates error when bad coding practices are done (ie. executing an empty variable)
Set-StrictMode -Version Latest

#~ Getting Version of powershell
$PSVersionTable.PSVersion


#~ COMMAND SUMMARIES ############################################################################################

#Join-Path: join path and child path into a single path, useful in situations where they are delimited
Examples:
Join-Path -Path "path" -ChildPath "childpath"
path\childpath
Join-Path $env:windir "system32\WindowsPowerShell\v1.0\powershell.exe"
# Result: C:\system32\WindowsPowerShell\v1.0\powershell.exe

#@ disable IPv6 on all network adapters #####################################################
Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6

#~ Obtaining currently installed Windows Features - ON WINDOWS SERVER #####################################################
Get-WindowsFeature | Where-Object installed

#~ Grabbing current script LOCATION ##################################################
# Path to the script itself
$PSCommandPath
# Path to just the root
$PSScriptRoot

#~ Considerations for Setting up reboot_run using task scheduling ################################
c:\windows\system32\WindowsPowerShell\v1.0\powershell.exe

-NoProfile -Executionpolicy bypass -file "\\path\to\Generate-SQLDatabaseGrowth.ps1" -Parameter 'Value'
<#
    Notes about using cmd values during

    Verify that you are running PowerShell at the correct bitness - are you running PowerShell from syswow64 (32-bit) and trying to load a module under system32 (64-bit)? That won’t work. Fully spell out the path to the right PowerShell.exe.
    Don’t bother typing inside the ‘Add arguments’ text box. Use your favorite text editor and paste it in. Verify that you don’t have any odd trailing spaces or other remnants from pasting.
    -NoProfile: If you need to load code in your script, do it in your script. Allowing profiles adds complexity and opens you up to malicious code injection, and unintentional mistakes. What if a profile drops you in an unintended PSDrive that your script doesn’t account for? What if a profile sets variables that you naively assumed (never assume!) would be null? I can’t emphasize this enough, -NoProfile is required.
    Is your execution policy configured correctly? Sign your scripts, or add -ExecutionPolicy Bypass in the arguments to avoid this altogether.
    If you’re specifying -File, anything that comes after the file is seen as a parameter or parameter value for that script. Add your PowerShell.exe switches before -File. Run powershell.exe -? for more information.
    If you’re specifying -File, does the account running the task have access to that path?
    Are you making the assumption that you can use PowerShell syntax in the Add Arguments text box? That’s not the case, you need to provide syntax that cmd.exe can handle.

#>

#~ Fix Update-help errors ######################################################
Update-Help  -Force -ErrorAction 0 -ErrorVariable $Err
$err.exception  # assign the error variable to this..
# SourcE:https://superuser.com/questions/1286844/update-help-fails-to-update-two-modules

##~ Enabling Remote Access - Two Methods ############################################################################

## To remote to one or more computers, we make use of Wsman (WS-Management) which WinRM (Windows Remote Management) uses
##@ 1. PS-Session - FOR SIMPLEST ADMIN ACTIONS (this is also called interactive mode)
# Must run in admin and user network profile CANNOT BE PUBLIC - must be either Domain or Private

#@ REMOTE COMPUTER #########################
# Following command enables a remote computer to be accessed, SkipNetworkProfileCheck is used to skip over checking for public profile
Enable-PSRemoting -SkipNetworkProfileCheck -Force
# To change a public network profile to Private
Set-NetConnectionProfile -NetworkCategory Private
# OR - change registry key HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles
# Set "Profile Name" to be "1"
# Command recommended by Microsoft:
Set-NetFirewallRule –Name "WINRM-HTTP-In-TCP-PUBLIC" –RemoteAddress Any

#@ LOCAL COMPUTER #########################
# WinRM must be enabled
get-service winrm
# If error persists - check error message for "TRUSTED HOSTS". If so, must add the remote device IP to local computers trusted hosts

# Method 1: CMD
winrm set winrm/config/client @{TrustedHosts = "192.168.50.11" }
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

##@ 2. Invoke-Command (running complex commands or running scripts remotely)
##  NOTE: to use multiple related commands at once, must use Enter-PSSession first then Invoke-command
Invoke-Command -ScriptBlock { Script-code } -ComputerName server1
# Invoke-command may require credentials
$creds = Get-Credential
Invoke-Command -Credentials $creds -ScriptBlock { Script-code } -ComputerName server1
# Invoke-command basic script
Invoke-Command -ComputerName 192.168.50.13 -ScriptBlock { Get-ChildItem C:\ } -credential Administrator

###~ CHANGING IP ADDRESS REMOTELY ######################################################
# Grab remotes current IP address and ethernet info, remove it and use new-netipaddress. Don't bother with Set-netipaddress, this works better locally

##~ online and initialize disks ##############################################################
#(PASSTHRU returns the output so we can see in the gui)
Get-Disk | Where-Object PartitionStyle -eq 'RAW' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition  -Driveletter E -UseMaximumSize | Format-Volume -FileSystem NTFS -Confirm:$false
#use New-Partition -Assigndriveletter to assign the next available drive letter or #@-Driveletter to specify


#~ WSUS ########################################################################################
#https://www.stephenwagner.com/2019/05/15/guide-using-installing-wsus-windows-server-core-2019/
#https://www.stephenwagner.com/2019/05/14/wsus-iis-memory-issue-error-connection-error/
#https://www.stephenwagner.com/2019/05/14/manage-remotely-iis-on-windows-server-2019-server-core/
#Registry Key to Run 
$RegRunKey ="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\run"

#PowerShell PATH = C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe
$PowershellPath = (Join-Path $env:windir "system32\WindowsPowerShell\v1.0\powershell.exe")

#$MyInvocation is an automatic variable populated at script run time
$script = $myInvocation.MyCommand.Definition
$scriptPath = Split-Path -parent $script
#To load the path during runtime, and specify the PS Script to run after server reboot
$PowerShellScript = (Join-Path $scriptpath joinDomain.ps1)

$RegName="Resume-and-run"
$RegValue= "$PowershellPath $PowerShellScript"


function Change-Timezone {
#Change Time Zone - Singapore 
tzutil /s "Singapore Standard Time" #Set Timezone to UTC+8
Write-Host -ForegroundColor Green "Setting the TimeZone to UTC+8"
}

function Change-ComputerName ([string] $NewComputerName){
#Get-Computer Name 
#(Get-CIMInstance CIM_ComputerSystem).Name - Get ComputerName 
Rename-Computer -NewName $NewComputerName
Write-Host -ForegroundColor Green "Changed Computer Name to $NewComputerName" 
}

function Disable-Firewall {
#Disable Firewall 
Set-NetFirewallProfile -Name Domain, Private, Public -Enabled False
Get-NetFirewallProfile | Select Name, Enabled
Write-Host -ForegroundColor Green "Disabled Firewall..."
}

function Change-IP ($IP, $DNS, $SubnetMask, $DefaultGateway){
#Change IP Address 
$adapter = Get-NetAdapter
$adapter | Set-DnsClientServerAddress -ServerAddresses $DNS
$adapter | New-NetIPAddress -AddressFamily IPv4 `
                            -IPAddress $IP `
                            -PrefixLength $SubnetMask `
                            -DefaultGateway $DefaultGateway
                  
}

function Change-IPv4 {
#Change IPv4 as Default 
New-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\" -Name "DisabledComponents" -Value "0x20" -PropertyType DWord
}

function Enable-RemoteDesktop {
#Enable Remote Desktop Connection 
set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0
Write-Host -ForegroundColor Green "Enabled Remote Desktop...."
}


#To Add Registry Key 
function Set-RegistryKey {
New-ItemProperty -Path $RegRunKey -Name $RegName -Value $RegValue
}

#To remove the Registry Key 
function Remove-RegistryKey {
Remove-ItemProperty -Path $RegRunKey -Name $RegName 
}

#EXECUTION #################################################################################################
#To load the function defined #####################################
$script = $myInvocation.MyCommand.Definition
$scriptPath = Split-Path -parent $script

. (Join-Path $scriptpath functions.ps1)


#Startup Script For Windows 2012 R2  
#Variable
$NewComputerName="M-SQL1" 
$IP = "192.168.1.210"
$SubnetMask="24"
$DefaultGateway= "192.168.1.252" 
$DNS="192.168.1.200"


Change-Timezone
Change-ComputerName ($NewComputerName)
Disable-Firewall
Change-IP ($IP, $DNS, $SubnetMask, $DefaultGateway)
Change-IPv4
Enable-RemoteDesktop

Set-RegistryKey

Restart-Computer -Force

#To load the function defined  ########################
$script = $myInvocation.MyCommand.Definition
$scriptPath = Split-Path -parent $script

. (Join-Path $scriptpath functions.ps1)

$ADDomain = "MonsterBean"
$Admin="MonsterBean\administrator"
$Password = "PASSWORD" | ConvertTo-SecureString -AsPlainText -Force
$Credential=New-Object System.Management.Automation.PSCredential($Admin,$Password)
$ComputerName = (Get-CIMInstance CIM_ComputerSystem).Name

#Join AD Domain 
Add-Computer -DomainName $ADDomain -Credential $Credential
Write-Host -ForegroundColor Green "$ComputerName Joined to $ADDomain Successfully..."

#Remove the Registery in the RUN
Remove-RegistryKey

Restart-Computer -Force
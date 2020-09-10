#Registry Key to Run 
$RegRunKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\run"
#$RegRunKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\runonce"


#PowerShell PATH = C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe
$PowershellPath = (Join-Path $env:windir "system32\WindowsPowerShell\v1.0\powershell.exe")

#$MyInvocation is an automatic variable populated at script run time - THIS is the same as $PSCommandPath
$script = $myInvocation.MyCommand.Definition
# $scriptPath is the same as $PSScriptRoot
$scriptPath = Split-Path -parent $script
#To load the path during runtime, and specify the PS Script to run after server reboot
$PowerShellScript = (Join-Path $scriptpath joinDomain.ps1)

$RegName = "Resume-and-run"
$RegValue = "$PowershellPath $PowerShellScript"

#To Add Registry Key 
function Update-ComputerName ([string] $NewComputerName) {
    #Get-Computer Name 
    #(Get-CIMInstance CIM_ComputerSystem).Name - Get ComputerName 
    Rename-Computer -NewName $NewComputerName
    Write-Host -ForegroundColor Green "Changed Computer Name to $NewComputerName" 
}

function Set-RegistryKey {
    New-ItemProperty -Path $RegRunKey -Name $RegName -Value $RegValue
}

#To remove the Registry Key 
function Remove-RegistryKey {
    Remove-ItemProperty -Path $RegRunKey -Name $RegName 
}
Update-ComputerName ($NewComputerName)
<#
Update-Timezone
Disable-Firewall
Update-IP ($IP, $DNS, $SubnetMask, $DefaultGateway)
Update-IPv4
Enable-RemoteDesktop
#>
Set-RegistryKey

Restart-Computer -Force
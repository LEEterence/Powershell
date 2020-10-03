<# 
Finding FQDN of multiple computers remotely
#>

$server =  Invoke-Command -ScriptBlock {hostname}

#Above line will print just the short name of the server

$sysinfo = Get-WmiObject -Class Win32_ComputerSystem
$server = "{0}.{1}" -f $sysinfo.Name, $sysinfo.Domain

# Source: https://www.thetopsites.net/article/53234036.shtml
# Go to source for more info on why "$env:computername.$env:userdnsdomain" sucks
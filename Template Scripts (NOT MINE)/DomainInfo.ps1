New-Item -ItemType Directory -Path "C:\REPORT"
$DomainInfo = Get-ADDomain
$dnsroot = ($DomainInfo | select DNSRoot | foreach { $_.DNSRoot })
$domainSID = $DomainInfo.DomainSID
$domainDN = $DomainInfo.DistinguishedName
$domain = $DomainInfo.DNSRoot
Write-Output "Domain: $($domain)"
$NetBIOS = $DomainInfo.NetBIOSName
$domainfl = $DomainInfo.DomainMode
Write-Output "NetBIOS: $($NetBIOS)"

# Domain FSMO roles
$FSMOPDC = $DomainInfo.PDCEmulator
$FSMORID = $DomainInfo.RIDMaster
$FSMOINF = $DomainInfo.InfrastructureMaster

$DClist = $DomainInfo.ReplicaDirectoryServers
Write-Output "DC List: $($DClist)"
$RODCList = $DomainInfo.ReadOnlyReplicaDirectoryServers

$FGPPNo = "none"

# REM Get Domain Controllers
$DCListFiltered = Get-ADDomainController -Server $domain -Filter { operatingSystem -like "Windows Server 2016*" -or operatingSystem -like "Windows Server 2012*" } | Select * -ExpandProperty Name
$DCListFiltered | %{ $DCListFilteredIndex = $DCListFilteredIndex+1 }

if ( $DCListFilteredIndex -eq 1 )
{
	# Default Domain Password Policy
	$pwdGPO = Get-ADDefaultDomainPasswordPolicy -Server $NetBIOS
	if ( $domainfl -like "Windows2016Domain" -or $domainfl -like "Windows2008R2Domain" -or $domainfl -like "Windows2012Domain" -or $domainfl -like "Windows2012R2Domain" )
	{
		$FGPPNo = (Get-ADFineGrainedPasswordPolicy -Server $NetBIOS -Filter * | Measure-Object).Count
	}

	# Administrator account
	$builtinAdmin = Get-ADuser -Identity $domainSID-500 -Server $NetBIOS -Properties Name, LastLogonDate, PasswordLastSet, PasswordNeverExpires, whenCreated, Enabled
	# Number of Domain Admins
	$domainAdminsNo = (Get-ADGroup -Identity $domainSID-512 -Server $NetBIOS | Get-ADGroupMember -Recursive | Measure-Object).Count
}
else
{
	# Get information about Default Domain Password Policy from the first DC on the list
	$pwdGPO = Get-ADDefaultDomainPasswordPolicy -Server $NetBIOS
	# check DFL and get Fine-Grained Password Policies
	if ( $domainfl -like "Windows2016Domain" -or $domainfl -like "Windows2008R2Domain" -or $domainfl -like "Windows2012Domain" -or $domainfl -like "Windows2012R2Domain" )
	{
		$FGPPNo = (Get-ADFineGrainedPasswordPolicy -Server $NetBIOS -Filter * | Measure-Object).Count
	}
	# Get information about built-in domain Administrator account
	$builtinAdmin = Get-ADuser -Identity $domainSID-500 -Server $NetBIOS -Properties Name, LastLogonDate, PasswordLastSet, PasswordNeverExpires, whenCreated, Enabled
	$domainAdminsNo = (Get-ADGroup -Identity $domainSID-512 -Server $NetBIOS | Get-ADGroupMember -Recursive | Measure-Object).Count
}


$usrNo = 0
$usr_activeNo = 0
$usr_inactiveNo = 0
$usr_lockedNo = 0
$usr_pwdnoreqNo = 0
$usr_pwdnoexpNo = 0

$grpNo = 0
$grp_localNo = 0
$grp_universalNo = 0
$grp_globalNo = 0

$cmpNo = 0

$os2k = 0
$osxp = 0
$os7 = 0
$os8 = 0
$os81 = 0
$os10 = 0

$srv2k = 0
$srv2k3 = 0
$srv2k8 = 0
$srv2k8r2 = 0
$srv2k12 = 0
$srv2k12r2 = 0
$srv2k16 = 0

# Get information about Active Directory objects
$ouNo = (Get-ADOrganizationalUnit -Server $domain -Filter * | Measure-Object).Count

$cmpobjs = Get-ADComputer -Server $domain -Filter * -Properties operatingSystem
$cmpNo = $cmpobjs.Count

$cmpobjs | %{ if ($_.operatingSystem -like "Windows 2000 Professional*") { $os2k = $os2k + 1 } }
$cmpobjs | %{ if ($_.operatingSystem -like "Windows XP*") { $osxp = $osxp + 1 } }
$cmpobjs | %{ if ($_.operatingSystem -like "Windows 7*") { $os7 = $os7 + 1 } }
$cmpobjs | %{ if ($_.operatingSystem -like "Windows 8 *") { $os8 = $os8 + 1 } }
$cmpobjs | %{ if ($_.operatingSystem -like "Windows 8.1*") { $os81 = $os81 + 1 } }
$cmpobjs | %{ if ($_.operatingSystem -like "Windows 10*") { $os10 = $os10 + 1 } }

$cmpobjs | %{ if ($_.operatingSystem -like "Windows 2000 Server*") { $srv2k = $srv2k + 1 } }
$cmpobjs | %{ if ($_.operatingSystem -like "Windows Server 2003*") { $srv2k3 = $srv2k3 + 1 } }
$cmpobjs | %{ if ( ($_.operatingSystem -like "Windows Server 2008*") -and ($_.operatingSystem -notlike "Windows Server 2008 R2*") ) { $srv2k8 = $srv2k8 + 1 } }
$cmpobjs | %{ if ($_.operatingSystem -like "Windows Server 2008 R2*") { $srv2k8r2 = $srv2k8r2 + 1 } }
$cmpobjs | %{ if ( ($_.operatingSystem -like "Windows Server 2012 *") -and ($_.operatingSystem -notlike "Windows Server 2012 R2*") ) { $srv2k12 = $srv2k12 + 1 } }
$cmpobjs | %{ if ($_.operatingSystem -like "Windows Server 2012 R2*") { $srv2k12r2 = $srv2k12r2 + 1 } }
$cmpobjs | %{ if ($_.operatingSystem -like "Windows Server 2016*") { $srv2k16 = $srv2k16 + 1 } }

$grpobjs = Get-ADGroup -Server $domain -Filter * -Properties GroupScope
$grpNo = $grpobjs.Count
$grpobjs | %{ if ($_.GroupScope -eq "DomainLocal") { $grp_localNo = $grp_localNo + 1 } }
$grpobjs | %{ if ($_.GroupScope -eq "Universal") { $grp_universalNo = $grp_universalNo + 1 } }
$grpobjs | %{ if ($_.GroupScope -eq "Global") { $grp_globalNo = $grp_globalNo + 1 } }

$usrobjs = Get-ADUser -Server $domain -Filter * -Properties Enabled, LockedOut, PasswordNeverExpires, PasswordNotRequired
$usrNo = $usrobjs.Count
$usrobjs | %{ if ($_.Enabled -eq $True) { $usr_activeNo = $usr_activeNo + 1 } }
$usrobjs | %{ if ($_.Enabled -eq $False) { $usr_inactiveNo = $usr_inactiveNo + 1 } }
$usrobjs | %{ if ($_.LockedOut -eq $True) { $usr_lockedNo = $usr_lockedNo + 1 } }
$usrobjs | %{ if ($_.PasswordNotRequired -eq $True) { $usr_pwdnoreqNo = $usr_pwdnoreqNo + 1 } }
$usrobjs | %{ if ($_.PasswordNeverExpires -eq $True) { $usr_pwdnoexpNo = $usr_pwdnoexpNo + 1 } }



# Display details
Write-Output "DNS domain name" | Add-Content "C:\REPORT\$($domain).txt"
Write-Output $domain | Add-Content "C:\REPORT\$($domain).txt"

Write-Output "" | Add-Content "C:\REPORT\$($domain).txt"

Write-Output "NetBIOS domain name" | Add-Content "C:\REPORT\$($domain).txt"
Write-Output $NetBIOS | Add-Content "C:\REPORT\$($domain).txt"

Write-Output "" | Add-Content "C:\REPORT\$($domain).txt"



# Domain Functional Level
Write-Output "Domain Functional Level" | Add-Content "C:\REPORT\$($domain).txt"

switch ($domainfl)
{
	Windows2000Domain { Write-Output "Windows 2000 native" | Add-Content "C:\REPORT\$($domain).txt" }
	Windows2003Domain { Write-Output "Windows Server 2003" | Add-Content "C:\REPORT\$($domain).txt" }
	Windows2008Domain { Write-Output "Windows Server 2008" | Add-Content "C:\REPORT\$($domain).txt" }
	Windows2008R2Domain { Write-Output "Windows Server 2008 R2" | Add-Content "C:\REPORT\$($domain).txt" }
	Windows2012Domain { Write-Output "Windows Server 2012" | Add-Content "C:\REPORT\$($domain).txt" }
	Windows2012R2Domain { Write-Output "Windows Server 2012 R2" | Add-Content "C:\REPORT\$($domain).txt" }
	Windows2016Domain { Write-Output "Windows Server 2016" | Add-Content "C:\REPORT\$($domain).txt" }
	default { Write-Output "Unknown Domain Functional Level: $domainfl" | Add-Content "C:\REPORT\$($domain).txt" }

}
    

# Domain Controllers
Write-Output "List of Domain Controllers:" | Add-Content "C:\REPORT\$($domain).txt"
$DCList | Sort | %{ Write-Output $_ | Add-Content "C:\REPORT\$($domain).txt" }
Write-Output "" | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "List of Read-Only Domain Controllers" | Add-Content "C:\REPORT\$($domain).txt"
if ( $RODCList.Count -ne 0 )
{
	$RODCList | %{ Write-Output $_.TrimEnd($domain).toUpper() | Add-Content "C:\REPORT\$($domain).txt" }
}

else
{
	Write-Output "(none)" | Add-Content "C:\REPORT\$($domain).txt"
}

Write-Output "Global Catalog servers:" | Add-Content "C:\REPORT\$($domain).txt"

$ForestGC | Sort | %{ if ( $_ -match $DomainName -and ((( $_ -replace $DomainName ) -split "\.").Count -eq 2 ))
{ Write-Output ($_.TrimEnd($domain).toUpper()) | Add-Content "C:\REPORT\$($domain).txt" } }


# Organizational Units
Write-Output "Total number of Organizational Units : " | Add-Content "C:\REPORT\$($domain).txt"
Write-Output $ouNo | Add-Content "C:\REPORT\$($domain).txt"

Write-Output "" | Add-Content "C:\REPORT\$($domain).txt"

Write-Output "Total number of computers : $cmpNo" | Add-Content "C:\REPORT\$($domain).txt"

Write-Output "" | Add-Content "C:\REPORT\$($domain).txt"

Write-Output "  Client systems" | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "  Windows 2000   : $os2k" | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "  Windows XP     : $osxp" | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "  Windows 7      : $os7" | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "  Windows 8      : $os8" | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "  Windows 8.1    : $os81" | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "  Windows 10    : $os10" | Add-Content "C:\REPORT\$($domain).txt"

Write-Output "" | Add-Content "C:\REPORT\$($domain).txt"

Write-Output "  Server systems" | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "  Windows 2000 Server    : $srv2k" | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "  Windows Server 2003    : $srv2k3" | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "  Windows Server 2008    : $srv2k8" | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "  Windows Server 2008R2  : $srv2k8r2" | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "  Windows Server 2012    : $srv2k12" | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "  Windows Server 2012R2  : $srv2k12r2" | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "  Windows Server 2016  : $srv2k16" | Add-Content "C:\REPORT\$($domain).txt"

Write-Output "" | Add-Content "C:\REPORT\$($domain).txt"



# Total number of domain users
Write-Output "" | Add-Content "C:\REPORT\$($domain).txt"

Write-Output "Total number of users  : $usrNo" | Add-Content "C:\REPORT\$($domain).txt"
#Write-Output $usrNo | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "  Active      : $usr_activeNo" | Add-Content "C:\REPORT\$($domain).txt"
#Write-Output $usr_activeNo | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "  Inactive    : $usr_inactiveNo" | Add-Content "C:\REPORT\$($domain).txt"
#Write-Output $usr_inactiveNo | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "  Locked out  : $usr_lockedNo" | Add-Content "C:\REPORT\$($domain).txt"
#Write-Output $usr_lockedNo | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "  Password not required       : $usr_pwdnoreqNo" | Add-Content "C:\REPORT\$($domain).txt"
#Write-Output $usr_pwdnoreqNo | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "  Password never expires      : $usr_pwdnoexpNo" | Add-Content "C:\REPORT\$($domain).txt"
#Write-Output $usr_pwdnoexpNo | Add-Content "C:\REPORT\$($domain).txt"

Write-Output "" | Add-Content "C:\REPORT\$($domain).txt"



# Total number of domain groups
Write-Output "Total number of groups : $grpNo" | Add-Content "C:\REPORT\$($domain).txt"
#Write-Output $grpNo | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "  Global      : $grp_globalNo" | Add-Content "C:\REPORT\$($domain).txt"
#Write-Output $grp_globalNo | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "  Universal   : $grp_universalNo" | Add-Content "C:\REPORT\$($domain).txt"
#Write-Output $grp_universalNo | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "  Domain Local: $grp_localNo" | Add-Content "C:\REPORT\$($domain).txt"
#Write-Output $grp_localNo | Add-Content "C:\REPORT\$($domain).txt"

Write-Output "" | Add-Content "C:\REPORT\$($domain).txt"





# Total number of domain administrators
Write-Output ""

Write-Output "Total number of Domain Administrators: $domainAdminsNo"  | Add-Content "C:\REPORT\$($domain).txt"
Write-Output  "$((Get-ADGroup -Identity $domainSID-512 -Server $NetBIOS | Get-ADGroupMember -Recursive))"  | Add-Content "C:\REPORT\$($domain).txt"


# Details about built-in domain Administrator account
Write-Output "Built-in Domain Administrator account details: $($builtinAdmin.Name)" | Add-Content "C:\REPORT\$($domain).txt"
 if ( $builtinAdmin.Enabled ) { Write-Output "enabled" | Add-Content "C:\REPORT\$($domain).txt" }
else { Write-Output "disabled" | Add-Content "C:\REPORT\$($domain).txt" }
Write-Output "Password never expires: $($builtinAdmin.PasswordNeverExpires)" | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "Promoted to domain account: $($builtinAdmin.whenCreated)" | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "Last password change: $($builtinAdmin.PasswordLastSet)" | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "Last logon date: $($builtinAdmin.LastLogonDate)" | Add-Content "C:\REPORT\$($domain).txt"



# Check default domain policy existance
$gpoDD = Get-ADObject -Server $domain -LDAPFilter "(&(objectClass=groupPolicyContainer)(cn={31B2F340-016D-11D2-945F-00C04FB984F9}))"
$gpoDDC = Get-ADObject -Server $domain -LDAPFilter "(&(objectClass=groupPolicyContainer)(cn={6AC1786C-016F-11D2-945F-00C04fB984F9}))"

if ($gpoDD -ne $nul) { Write-Output "Default Domain policies check: exists" | Add-Content "C:\REPORT\$($domain).txt" }
else { Write-Output "Default Domain policies check: deos not exist" | Add-Content "C:\REPORT\$($domain).txt" }


# Default Domain Password Policy details
Write-Output "Default Domain Password Policy details:" | Add-Content "C:\REPORT\$($domain).txt"

Write-Output "Minimum password age: $($pwdGPO.MinPasswordAge.days) day(s)" | Add-Content "C:\REPORT\$($domain).txt"
#Write-Output $pwdGPO.MinPasswordAge.days "day(s)" | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "Maximum password age: $($pwdGPO.MaxPasswordAge.days) day(s)" | Add-Content "C:\REPORT\$($domain).txt"
#Write-Output $pwdGPO.MaxPasswordAge.days "day(s)" | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "Minimum password length: $($pwdGpo.MinPasswordLength) character(s)" | Add-Content "C:\REPORT\$($domain).txt"
#Write-Output $pwdGpo.MinPasswordLength "character(s)" | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "Password history count: $($pwdGPO.PasswordHistoryCount) unique password(s)" | Add-Content "C:\REPORT\$($domain).txt"
#Write-Output $pwdGPO.PasswordHistoryCount "unique password(s)" | Add-Content "C:\REPORT\$($domain).txt"

Write-Output "Password must meet complexity: " | Add-Content "C:\REPORT\$($domain).txt"

if ( $pwdGPO.ComplexityEnabled ) { Write-Output "yes" | Add-Content "C:\REPORT\$($domain).txt" }
else { Write-Output "no" | Add-Content "C:\REPORT\$($domain).txt" }
Write-Output "Account lockout treshold: " | Add-Content "C:\REPORT\$($domain).txt"
if ($pwdGPO.LockoutThreshold -eq 0 ) { Write-Output "Account never locks out" | Add-Content "C:\REPORT\$($domain).txt" }
else 
{
$pwdGPOdays = (($pwdGPO.LockoutObservationWindow.days) | Select -First 1)
$pwdGPOdays = ($pwdGPOdays -replace '\D+(\d+)','$1')
$pwdGPOhrs = (($pwdGPO.LockoutObservationWindow.hours) | Select -First 1)
$pwdGPOhrs = ($pwdGPOhrs -replace '\D+(\d+)','$1')
$pwdGPOmins = (($pwdGPO.LockoutObservationWindow.minutes) | Select -First 1)
$pwdGPOmins = ($pwdGPOmins -replace '\D+(\d+)','$1')
Write-Output $pwdGPO.LockoutThreshold "invalid logon attempts" | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "Account lockout duration days: $($pwdGPOdays)" | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "Account lockout duration hours: $($pwdGPOhrs)" | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "Account lockout duration minutes: $($pwdGPOmins)" | Add-Content "C:\REPORT\$($domain).txt"
}

# Display total number of Fine-Grained Password Policies
Write-Output "Fine-Grained Password Policies: $FGPPNo" | Add-Content "C:\REPORT\$($domain).txt"
Write-Output "$((Get-ADFineGrainedPasswordPolicy -Server $NetBIOS -Filter *))" | Add-Content "C:\REPORT\$($domain).txt"

$duser = (get-adgroupmember -Server $NetBIOS "Domain users" | where objectClass -eq user | Select-Object -last 1).samaccountname
Write-Output "Fine-Grained Password Policy for: $duser" | Add-Content "C:\REPORT\$($domain).txt"
Get-ADUserResultantPasswordPolicy -Server $NetBIOS -Identity "$($duser)" | Out-File -append -encoding ASCII -filepath "C:\REPORT\$($domain).txt"


$dadmin = (get-adgroupmember -Server $NetBIOS "Domain admins" | where objectClass -eq user | Select-Object -last 1).samaccountname
Write-Output "Fine-Grained Password Policy for: $dadmin" | Add-Content "C:\REPORT\$($domain).txt"
Get-ADUserResultantPasswordPolicy -Server $NetBIOS -Identity $dadmin | Out-File -append -encoding ASCII -filepath "C:\REPORT\$($domain).txt"
Get-GPOReport -All -Domain "$dnsroot" -ReportType HTML -Path "C:\REPORT\$($domain)-GPOReport.html" 
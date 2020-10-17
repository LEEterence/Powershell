# https://www.reddit.com/r/PowerShell/comments/5rhnc5/getting_list_of_gpos_applied_to_ou/

# Active Directory Group Policy Object Auditor
# Written:  20130711    Last Updated:  20130711
# Purpose:  Identify GPOs that are any combination of not linked, not applied, 
# not configured with policies, or should have the user or computer status disabled.

# =================================================
# ==========  CHOOSE CUSTOM SETTINGS  =============	
# =================================================
# Output file location
$OutputFilePath = "$env:userprofile\Desktop"

# Output file name
$OutputFileName = "GPOAudit.csv"
# =================================================
# ==========  End CUSTOM SETTINGS  ================	
# =================================================

# Combine the OutputFilePath and OutputFileName
$CSV = $OutputFilePath + "\" + $OutputFileName

# Import the required modules to perform Get-ADOrganizationalUnit & Get-GPO
Import-Module ActiveDirectory,GroupPolicy

# This group of commands provides us with a list of GPO IDs that are linked to an OU.
# Get a list of GPOs linked to OUs by querying the OUs' GPLink property.
[array]$LinkedGPOs = Get-ADOrganizationalUnit -LDAPFilter '(GPLink=*)' -Properties GPLink | Select-Object -ExpandProperty GPLink
# Two passes are made to clean up the list where you're left with just the GPO's ID pulled from the OUs' GPLink property.
[array]$CleanPass1 = $LinkedGPOs | ForEach{$_.Split("`\['\]")} | Where-Object {$_}
[array]$CleanPass2 = $CleanPass1 | ForEach{$_.Split('{}')[1]}
# CleanPass2 ends up with blank lines.  The ForEach below captures only lines that are not null.
# This results in a list in $LinkedGPOIDs that we can query.
ForEach ($GPOID in $CleanPass2) {If ($GPOID -ne $Null) {[array]$LinkedGPOIDs += $GPOID}}

# Get a list of GPOs by ID from Active Directory.  Sort by name so the host progress can be measured.
$GPOList = Get-GPO -All | Sort-Object DisplayName
Write-Output "Discovered $($GPOList.count) GPOs in Active Directory"
# Setup a hash table and an array that'll be sent to an out file
$OutputCollection = @{}
$OutputData = @()
ForEach ($GPO in $GPOList) {
	# A notice to the console that the script is still functioning
	Write-Host "Processing"$GPO.DisplayName"..." -foregroundcolor yellow
	# Check the list of linked GPO IDs from the OUs for the GPO's ID
	$GPOLinked = $Null
	$GPOLinked = Compare-Object $GPO.ID $LinkedGPOIDs | Where-Object {$_.SideIndicator -eq '<='}
	$NotLinked = $Null
	If ($GPOLinked) {$NotLinked = $True}

	# Create an XML report of the GPO that can be used to query for information.
	[XML]$Report = Get-GPOReport -GUID $GPO.ID -ReportType XML
	# Query the report to find out whether there are policies or not.  
	$UserStatus = $Null
	If ($Report.gpo.user.extensiondata) {$UserStatus = $True}
	$ComputerStatus = $Null
	If ($Report.gpo.computer.extensiondata) {$ComputerStatus = $True}
	# Set a variable for if policies exist at all to identify empty policies.
	$PoliciesExist = $Null
	If ($UserStatus -or $ComputerStatus) {$PoliciesExist = $True}
	$NoPolicies = $Null
	If (!$PoliciesExist) {$NoPolicies = $True}
	
	# Perform a status check to flag policies that need a configuration change.
	$GPOStatusError = $Null
	$GPOStatusNote = $Null
	If ($PoliciesExist) {
		Switch ($GPO.GPOStatus) {
			AllSettingsEnabled {
				If (!$UserStatus) {
					$GPOStatusError = $True;$GPOStatusNote = "No user policies.  Disable user configuration settings"
				}
				ElseIf (!$ComputerStatus) {
					$GPOStatusError = $True;$GPOStatusNote = "No computer policies.  Disable computer configuration settings"
				}
			}
			AllSettingsDisabled {$GPOStatus = "Policy Disabled"}
			UserSettingsDisabled {
				If (!$ComputerStatus) {
					$GPOStatusError = $True;$GPOStatusNote = "No computer policies.  Computer policies are disabled and/or do not exist.  Disable the policy."
				}
			}
			ComputerSettingsDisabled {
				If (!$UserStatus) {
					$GPOStatusError = $True;$GPOStatusNote = "No user policies.  User policies are disabled and/or do not exist.  Disable the policy."
				}	
			}
		}
	}
	
	# Query the GPO to see if the GPO is applied to any users or groups
	$SecInfo = $Null
	$SecInfo = $GPO.GetSecurityInfo() | Where {$_.Permission -eq "GPOApply"}
	$NotApplied = $Null
	If (!$SecInfo) {$NotApplied = $True}

	# Only write to the hash table if there is an event worth reviewing
	#If ($NotLinked -or $NotApplied -or $NoPolicies -or $GPOStatusError) {	
		$OutputCollection.DisplayName = $GPO.DisplayName
		$OutputCollection.Owner = $GPO.Owner
		$OutputCollection.Description = $GPO.Description
		$OutputCollection.CreationTime = $GPO.CreationTime
		$OutputCollection.ModificationTime = $GPO.ModificationTime
		$OutputCollection.ID = $GPO.ID
		$OutputCollection.NotLinked = $NotLinked
		$OutputCollection.NotApplied = $NotApplied
		$OutputCollection.NoPolicies = $NoPolicies
		$OutputCollection.GPOStatusError = $GPOStatusError
		$OutputCollection.GPOStatusNote = $GPOStatusNote
		$OutputData += New-Object PSObject -Property $OutputCollection
	#}
}

# Order your array, sort your array, and export your array to a CSV file
$OutputData | Select-Object DisplayName,Owner,Description,CreationTime,ModificationTime,ID,NotLinked,NotApplied,NoPolicies,GPOStatusError,GPOStatusNote | Sort-Object DisplayName | Export-CSV $CSV -NoTypeInformation

# Provide some stats to finish things off
Write-Host "An output file named $OutputFileName has been created in $OutputFilePath.  The script has completed." -foregroundcolor cyan
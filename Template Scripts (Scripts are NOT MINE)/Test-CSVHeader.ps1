<#
		.EXTERNALHELP ..\CSVValidator.psm1-help.xml
#>
function Test-CSVHeader
{
	[CmdletBinding(SupportsShouldProcess = $false)]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 0)]
		[ValidatePattern('.csv')]
		[ValidateNotNullOrEmpty()]
		[ValidateScript({ test-path $_ })]
		[Alias('File', 'FilePath', 'csv', 'csvfile')]
		[string]$Path,
		
		[Parameter(Mandatory = $true,
				   Position = 1)]
		[ValidateNotNullOrEmpty()]
		[string[]]$Headers,

		[switch]$DisallowHeadersWithoutRules
	)
	
	#begin
	$rules = @{ }
	foreach ($item in $Headers)
	{
		$rules.add($item, $item)
	}
	$csvData = Import-Csv $Path
	try
	{
		$CSVHeader = $csvData[0] | Get-Member | where-object{ $_.MemberType -eq 'NoteProperty' }
	}
	catch
	{
		throw "There was no data in the CSV file $($Path).  The script is unable to validate headers on this file."
	}
	$headersNotInRules = [System.Collections.ArrayList]@()
	$missingHeaders = [System.Collections.arraylist]@()
	$rulesResults = [pscustomobject]@{
		"HeadersInRules"  = $null
		"RulesAllPresent" = $null
		"CSVValid"	      = $null
		"MissingHeaders"  = [System.Collections.arraylist]@()
	}
	#process
	foreach ($item in $CSVHeader.name)
	{
		if ($Rules.$($item))
		{
			#nothing right now
		}
		else
		{
			$headersNotInRules.add($item) | Out-Null
		}
	}
	
	foreach ($item in $Rules.keys)
	{
		if ($CSVHeader.name -contains $item)
		{
			#nothign right now
		}
		else
		{
			$missingHeaders.add($item) | Out-Null
			$rulesResults.missingHeaders.add($item) | Out-Null
		}
	}
	
	if ((($headersNotInRules | measure-object).count -gt 0) -and $DisallowHeadersWithoutRules)
	{
		Write-Warning "The CSV file $($Path) has headers which are not defined in the rules and the DisallowHeadersWithoutRules switch is present.  This CSV file is not valid."
		$rulesResults.HeadersInRules = $false
	}
	elseif (($headersNotInRules | measure-object).count -gt 0)
	{
		Write-Verbose "The CSV file $($Path) has headers which are not defined in the rules.  The switch DisallowHeadersWithoutRules is not given, therfore processing will continue as normal. Testing all of the rules now."
		$rulesResults.HeadersInRules = $true
	}
	else
	{
		Write-Verbose "All the headers in CSV file $($Path) are found in the rules.  Testing all of the rules now."
		$rulesResults.headersInRules = $true
	}
	
	if (($missingHeaders | measure-object).count -gt 0)
	{
		Write-Warning "The CSV file $($Path) has defined headers in the ruleset which are not in the csv file"
		$rulesResults.rulesallpresent = $false
	}
	else
	{
		Write-Verbose "All of the headers defined in the rules are present in the CSV file"
		$rulesResults.rulesallpresent = $true
	}
	
	if ($rulesResults.rulesallpresent -eq $false -or $rulesResults.headersinrules -eq $false)
	{
		$rulesResults.csvValid = $false
	}
	else
	{
		$rulesResults.csvValid = $true
	}
	#end
	$rulesResults
}v
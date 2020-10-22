$syncFieldMap = @{
	fname = 'GivenName'
	lname = 'Surname'
	dept  = 'Department'
}

$fieldMatchIds = @{
	AD  = @('givenName', 'surName')
	CSV = @('fname', 'lname')
}

function Get-AcmeEmployeeFromCsv {
	[CmdletBinding()]
	param
	(
		[Parameter()]
        [string]$CsvFilePath = 'C:\Employees.csv',
        [Parameter(Mandatory)]
        [hashtable]$SyncFieldMap,
        [Parameter(Mandatory)]
        [hashtable]$FieldMatchIds
	)
	try {
		## "Map" the properties of the CSV to AD property names
		$properties = $syncFieldMap.GetEnumerator() | ForEach-Object {
			@{
				Name       = $_.Value
				Expression = [scriptblock]::Create("`$_.$($_.Key)")
			}
		}

		## Create a unique ID on the fly and make that a property
		$uniqueIdProperty = '"{0}{1}" -f '
		$uniqueIdProperty = $uniqueIdProperty += ($fieldMatchIds.CSV | ForEach-Object { '$_.{0}' -f $_ }) -join ','

		$properties += @{
			Name       = 'UniqueID'
			Expression = [scriptblock]::Create($uniqueIdProperty)
		}

		## Read the CSV and use Select-Object's calculated properties to do the "conversion"
		Import-Csv -Path $CsvFilePath | Select-Object -Property $properties

	} catch {
		Write-Error -Message $_.Exception.Message
	}
}
Get-AcmeEmployeeFromCsv -SyncFieldMap $syncFieldMap -FieldMatchIds $fieldMatchIds
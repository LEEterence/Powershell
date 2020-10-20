<# 
~ Sync AD data using external data source (CSV)
Goals:
1. Parse through CSV
2. Parse through AD
3. Find match btw CSV & AD
4. Modify or Create new 

#>
$FileLocation = Join-Path $env:USERPROFILE "\desktop\employee.csv"
#Get-Content $FileLocation -Raw

Function Get-ADEmployeeFromCSV {
    [CmdletBinding()]
    param(
        # Importing CSV - adjust location as required
        [Parameter(Mandatory = $false)]
        [string] $FileLocation,
        
        # Hashtable to change CSV headers to corresponding AD attributes
        [Parameter(Mandatory = $false)]
        [hashtable] $SyncFieldMap,

        # Hashtable to create a temp unique ID
        [Parameter(Mandatory = $true)]
        [hashtable] $fieldMatchIds
    )
    try{
        # Enumerate through input hash table and for each row create multiple calculated properties based on the value of the key
        # IE. in this scenario we have 'Given Name, Surname, and Department as the hashtable values. These will become new name of the properties
        # 
        $properties = $SyncFieldMap.GetEnumerator() | ForEach-Object {
            @{
                Name = $_.Value
                # Creates a scriptblock that can be stored in a variable, in this scenario we are storing how the calculated property's value is being generated.
                # IE. in this scenario the key of each row in the $syncfieldmap will be used to generate actual values from the CSV. Data rows will be empty until CSV values are fed in
                Expression = [scriptblock]::Create($_.Key)
            }
        }
        $uniqueIdProperty = '"{0}{1}" -f '
        $uniqueIdProperty = $uniqueIdProperty += 
        ($FieldMatchIds.CSV | ForEach-Object { '$_.{0}' -f $_ }) –join ','
        $properties += @{
            Name = 'UniqueID'
            Expression = [scriptblock]::Create($uniqueIdProperty)
        }
        Import-Csv -Path $FileLocation | Select-Object -Property $properties
    }
    catch{
        Write-Error -Message $_.Exception.Message
    }
    #$csv.foreach({})
    #Get-ADUser -Filter "GivenName -eq '$SyncParameters.givenname' -and Surname -eq '$SyncParameters.SurName'"
}
# Mapping CSV headers with corresponding AD parameters
$syncFieldMap = @{   
    fname = 'GivenName'
    lname = 'Surname'   
    dept = 'Department'
}

# Temporary Unique ID
$fieldMatchIds = @{
    AD = @('givenName','surName')
    CSV = @('fname','lname')
}


Get-ADEmployeeFromCSV -SyncFieldMap $syncFieldMap -fieldMatchIds $fieldMatchIds
## Creating my own script block (prevent having to re-enter code)
## Source: https://lazywinadmin.com/2017/03/ScriptBlockObject.html
#$NewScriptBlock = [scriptblock]::Create("Get-ChildItem Join-Path $env:USERPROFILE '\Desktop'")
#Invoke-Command -ScriptBlock $NewScriptBlock -ComputerName DC01
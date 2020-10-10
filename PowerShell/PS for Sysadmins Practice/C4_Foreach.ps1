<# 
~ Three Types of FOREACH
1. Foreach statement (same as C# foreach)
2. Foreach-object (input object piped into foreach)
3. Foreach method (This is the best and most recent version, processing speed is noticable in large data sets)

#>
$Time = Get-Date
$serverList = @('DC01','DC02','WSUS01','WDS01','RDS01')

# C# version of foreach
foreach ($x in $serverList){
    Write-Host "$x is active using foreach STATEMENT"
} 
# Processing each item in a collection of input objects iterating through current object in the PIPELINE
$serverList | ForEach-Object {
    Write-Host "$_ is active at $time using foreach-OBJECT"
}
# BEST METHOD - foreach method. More efficient for large data sets
# @NOTE the braces are OPPOSITE
$serverList.foreach({Write-Host "$_ is active at $time using foreach METHOD"})

# CSV manipulation ##################
# Some hashtables too

$employeeList = @{
    '1' = 'Kenneth Lay'
    '2' = 'Mike Swerzbin'
    '3'= 'Monika Causholli'
    '4'= 'Monique Sanchez'
    '5'= 'Paul Lucci'
    '6'= 'Peter Keavey'
    '7'= 'Phillip Allen'
}

$data = import-csv "E:\_Git\Powershell\PowerShell\PS for Sysadmins Practice\C4_Foreach.csv" | 
Where-Object {$_.givenname -like 'Dan'}
$data.Surname
$data.OfficePhone
# Testing with $employeelist hashtable
import-csv "E:\_Git\Powershell\PowerShell\PS for Sysadmins Practice\C4_Foreach.csv" | 
Where-Object {
        foreach($employee in $employeeList.GetEnumerator())
        {
            if ($employee.Values -eq $_.($employee.Name)) {
                Write-Host "$($emp.value) found."
            }
        }
    }
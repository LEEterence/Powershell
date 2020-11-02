
$namearray = Import-Csv .\Employees.csv | Get-Member | Where-Object {$_.membertype -eq 'NoteProperty'} | Select-Object -ExpandProperty  Name 
# Number 
$count = 0
$namearray.foreach(
    {
        if($_ -in ('Path','Name'))
        {
           # Write-host "$_ exists" 
           $count++
        } 
    }
)

# YOU CAN HAVE MORE THAN ONE VALUE PER KEY!!!!!!!!!!!!!!!!!!!!!
$remove_value_row = @{
    'Name' = "IT","Admins","Accounting"
}
$num = 0

Import-Csv "C:\Lab 1\departments_noLEGAL or EXEC.csv" |
    Where-Object {
        foreach ($remove in $remove_value_row.GetEnumerator()) {
            # $_.($remove.name) means this row of the CSV where the key 
            if ($remove.value -like $_.($remove.name)) {
                write-host "$remove.value"                
                write-host "$_.($remove.name)" -ForegroundColor Green
                return $false
                $num
            }
        }
        return $true
    } |
    Export-Csv 'C:\Users\tlee37\Desktop\output.csv' -NoTypeInformation -Encoding UTF8

Get-Content -Path 'C:\Users\tlee37\Desktop\output.csv' 
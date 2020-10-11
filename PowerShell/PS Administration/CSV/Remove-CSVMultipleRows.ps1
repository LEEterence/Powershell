$remove_value_row = @{
    "Name" = "IT"
}

Import-Csv "C:\Lab 1\departments_noLEGAL or EXEC.csv" |
    Where-Object {
        foreach ($remove in $remove_value_row.GetEnumerator()) {
            if ($remove.value -contains $_.($remove.name)) {
                return $false
            }
        }
        return $true
    } |
    Export-Csv 'C:\Users\tlee37\Desktop\output.csv' -NoTypeInformation -Encoding UTF8
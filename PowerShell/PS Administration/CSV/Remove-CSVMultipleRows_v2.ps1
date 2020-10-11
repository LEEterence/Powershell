$remove_value_row = @{
    "Name" = "IT"
}

Import-Csv "C:\Lab 1\departments_noLEGAL or EXEC.csv" |
    Where-Object {
        foreach ($remove in $remove_value_row.GetEnumerator()) {
            if ($remove.value -like $_.($remove.name)) {
                $exists = Get-mailbox -organizationalunit $_.($remove.name) 
                if ($exists -ne $null)
                {
                    Write-host "Removing row: OU=$($_.Name),$($_.path)"
                }
                return $false
            }
        }
        return $true
    } |
    Export-Csv 'C:\Users\tlee37\Desktop\output_V2.csv' -NoTypeInformation -Encoding UTF8
$OU = Import-csv "C:\Lab 1\departments_noLEGAL or EXEC.csv" | Measure-Object -Property count
#$OU.Name | ForEach { if (Get-mailbox $_.name -eq $null){Write-host "$_ has a mailbox"}else{Write-Host "$_ none"}}

# Counts the number of OUs that have existing mailboxes. Increments when mailbox is found 
$existCount=0

foreach($item in $OU){
    $x = $item.name
    $exists = Get-mailbox -organizationalunit $x 
    if ($exists -ne $null)
    {
        Write-host "$x has a mailbox" -ForegroundColor Red
        $existCount++
    }
    else
    {
        Write-Host "$x no mailbox"
    }
}

if ($existCount -gt 0)
{
    $flag = Read-Host "$existCount Mailboxes already have accounts, please remove them. Continue Anyways?" 
    if ($flag.toupper() -eq 'N'){
        'Bye'
        exit
    }
    else
    {
        # EXECUTION
        Write-Host "Continue"
    }
}
else
{
    # EXECUTION
}


# MUST be ran in EMS

$Filelocation = "C:\Lab 1\departments_noLEGAL or EXEC.csv"

Write-Verbose "Importing OU CSV..."
# SELECT ALL necessary properties
$OU = (Import-Csv $Filelocation -ErrorAction Stop | Select-Object -Property Name,DisplayName,Path)

Write-Host "Specify the database to Store User Mailboxes:" 
$Database = Read-Host 

#Testing additonal error handling
$ErrorCount = 0
$SuccessCount = 0
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
    $flag = Read-Host "$existCount Mailboxes already have accounts, please remove them. Continue Anyways? (Y/N)"
    if ($flag.toupper() -eq 'N'){
        'Bye'
        exit
    }
    else
    {
        # EXECUTION
        Write-Host "Continuing Enable"
        # Looping to enable mailboxes for each OU in CSV
        $OU.ForEach({
        $Name = $_.Name
        $DN = $_.Path
        $DisplayName = $_.'Display Name'
        try{
            Write-Host "`n[Enable Mailbox]`n Department: $Name`n Database: $Database" -ForegroundColor Cyan
            #Enable-Mailbox -OrganizationalUnit $Name -Database $Database -Whatif 
            Get-User -OrganizationalUnit $Name | Enable-mailbox -Database $Database -whatif
            $SuccessCount++
        }
        catch
        {
            Write-Host "Error enabling mailboxes for OU: $Name" -ForegroundColor Red
            $ErrorCount++
        }
        finally
        {
            Sleep 1
            $totalCount = $ErrorCount + $SuccessCount
            Write-Verbose "Total OU enable mailbox errors: $totalCount"

            $Percent = (($totalCount/$OU.Count)* 100)
            Write-Progress -Activity "Running Script..." -Status "Completion Progress: $Percent%" -PercentComplete $Percent -CurrentOperation "$($Name)"
        }
    })
    }
}
else
{
    # EXECUTION
    # Looping to enable mailboxes for each OU in CSV
$OU.ForEach({
    $Name = $_.Name
    $DN = $_.Path
    $DisplayName = $_.'Display Name'
    try{
        Write-Host "[Enable Mailbox]`n Department: $Name`n Database: $Database`n" -ForegroundColor Cyan
        #Enable-Mailbox -OrganizationalUnit $Name -Database $Database -Whatif 
        Get-User -OrganizationalUnit $Name | Enable-mailbox -Database $Database -whatif
        $SuccessCount++
    }
    catch
    {
        Write-Host "Error enabling mailboxes for OU: $Name" -ForegroundColor Red
        $ErrorCount++
    }
    finally
    {
        Sleep 1
        $totalCount = $ErrorCount + $SuccessCount
        Write-Verbose "Total OU enable mailbox errors: $totalCount"

        $Percent = (($totalCount/$OU.Count)* 100)
        Write-Progress -Activity "Running Script..." -Status "Completion Progress: $Percent%" -PercentComplete $Percent -CurrentOperation "$($Name)"
    }
})
}


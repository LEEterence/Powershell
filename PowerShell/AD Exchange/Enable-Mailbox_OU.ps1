$Filelocation = "C:\Lab 1\departments_noLEGAL or EXEC.csv"

Write-Verbose "Importing OU CSV..."
$OU = (Import-Csv $Filelocation -ErrorAction Stop | Select-Object -Property Name)

Write-Host "Specify the database to Store User Mailboxes:" -ForegroundColor Cyan
$Database = Read-Host 

#Testing additonal error handling
$ErrorCount = 0

# Looping to enable mailboxes for each OU in CSV
$OU.ForEach({
    $Name = $OU.Name
    $DN = $OU.Path
    try{
        Write-Verbose "[Enable Mailbox]`n Name: $DN `n DistinguishedName: $DN `n Database: $Database"
        Enable-Mailbox -OrganizationalUnity $Name -Database $Database -ErrorAction Stop -Whatif 

    }
    catch
    {
        Write-Host "Error enabling mailboxes for users in OU" -ForegroundColor Red
        $ErrorCount++
    }
    finally
    {
        Write-Verbose "Total OU enable mailbox errors: $ErrorCount"

        $Percent = (($ErrorCount/$OU.Count)* 100)
        Write-Progress -Activity "Running Script..." -Status "Completion Progress: $Percent%" -PercentComplete $Percent -CurrentOperation "$($Name)"
    }
})
<#	
.SYNOPSIS
    Imports user list from CSV file and then runs an Enable-Mailbox on-premises for each AD user

.PARAMETER InputFile
    Path for the Input CSV file

.PARAMETER SkipLine
    Optional parameter for value of line number to start from in CSV file.
    Does not include count for header row (if you want to skip first user, enter 1)

.PARAMETER StartTranscript
    Switch to start transcript and store in current directory as text file.

.PARAMETER Shared
    Switch to add '-Shared' parameter for Enable-Mailbox commandlet to create shared mailboxes on-prem
    (Need to first disable the user accounts in the AD)

.DESCRIPTION
    Takes an input CSV file with the column 'UserPrincipalName' and runs the Enable-Mailbox command 
    with below required columns (values as parameters to Enable-Mailbox command): 
        - UserPrincipalName        (For -Identity parameter)
        - Email                    (For -PrimarySMTPAddress parameter)
        - samAccountName           (For -Alias parameter)
         
.INPUTS
    InputFile - CSV File with "," delimited attributes. Must include a column with header 
        'UserPrincipalName'
        'Email'
        'samAccountName'

.OUTPUTS
    enable_MailboxCSV-Log - TXT file containing list of all items processed successfully
    enable_MailboxCSV-Error - TXT file contains list of any errors occured during script runtime
    enable_MailboxCSV-Transcript - TXT file contains PowerShell transcript (if StartTranscript is used)
  
.NOTES
    Version:        1.0
    Author:         Sidharth Zutshi
    Creation Date:  16/11/2017
    Change Date:    
    Purpose/Change: 

.EXAMPLE
    PS C:\> .\enable_MailboxCSV.ps1 -InputFile Users.csv
    
    Runs script for all users in the input CSV file. Runs an Enable-Mailbox command for each with 
    identity,primarysmtpaddress and alias parameters as per CSV file columns.

.EXAMPLE
    PS C:\> .\enable_MailboxCSV.ps1 -InputFile Users.csv -SkipLine 5

    Skips first 5 users and runs an Enable-Mailbox for all remaining users.

.EXAMPLE
    PS C:\> .\enable_MailboxCSV.ps1 -InputFile Users.csv -StartTranscript

    Runs script for all users in the input CSV file and outputs PS transcript file.


---------------------------------------------------------------------------------------#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
        [string]$InputFile,    
        [int]$SkipLine = 0,    
        [switch]$StartTranscript = $False,
        [switch]$Shared = $False

    )

$CurrentDate = (Get-Date -Format "dd-MM-yyyy_HH-mm")
$count = 0
$errcount = 0

#region----------------------------------------------[Parameter Declarations]---------------------------------------------------

$OutputLog = ".\enable_MailboxCSV-Log_$CurrentDate.txt"
$OutputErrorLog = ".\enable_MailboxCSV-Error_$CurrentDate.txt" 
$OutputTranscript = ".\enable_MailboxCSV-Transcript_$CurrentDate.txt"
$CurrentPreference = $Global:ErrorActionPreference
$Global:ErrorActionPreference = 'Stop'
#endregion


#region--------------------------------------------------[Execution Start]-------------------------------------------------------

if ($StartTranscript -eq $True)
{

    Start-Transcript -Path $OutputTranscript
}

#region: Add Header to Log Files and Output
Write-Output "`n`n
Starting script ***enable_MailboxCSV*** with parameters set as
------------------------------------------------------
InputFile = $InputFile
Shared Mailboxes = $Shared
StartTranscript = $StartTranscript
Skip Users = $SkipLine
Output Log File = $OutputLog
Output Error Log = $OutputErrorLog
Output Transcript = $OutputTranscript
------------------------------------------------------" 

$Current = (Get-Date -Format "dd-MM-yyyy HH:mm:ss")

$header = "
Script ***enable_MailboxCSV*** 
--------------------------------------------------
Started on:  $Current
Input File: $InputFile
Shared Mailboxes: $Shared
Skip Users: $SkipLine
"
Write-Verbose "Initializing Log Files and adding Headers..."
$header > $OutputLog
$header > $OutputErrorLog

#endregion

#Import CSV file into variable for processing
Write-Verbose "Importing CSV File for list of user UPNs..." 
$Items = (Import-CSV $InputFile -ErrorAction Stop | Select-Object `
                -Property UserPrincipalName,Email,samAccountName `
                -Skip $SkipLine) 

#region: Loop to process each mailbox
foreach($Item in $Items)
{

    $Error.Clear()

    try
    {       
        Write-Output "Running Enable-Mailbox for $($Item.UserPrincipalName)..."     
        
        #RUN ENABLE-MAILBOX FOR USER IN $ITEM
        $UPN = $Item.UserPrincipalName
        $SMTP = $Item.Email
        $SAM = $Item.samAccountName

        if($Shared -eq $True)
        {
            Write-Verbose "        [Enable-Mailbox] -Identity $UPN 
                                                    -PrimarySMTPAddress $SMTP 
                                                    -Alias $SAM 
                                                    -Shared" 
            Enable-Mailbox -Identity $UPN -PrimarySMTPAddress $SMTP -Alias $SAM -Shared -ErrorAction Stop
            
        }
        else
        {
            Write-Verbose "        [Enable-Mailbox] -Identity $UPN 
                                                    -PrimarySMTPAddress $SMTP 
                                                    -Alias $SAM" 
            Enable-Mailbox -Identity $UPN -PrimarySMTPAddress $SMTP -Alias $SAM -ErrorAction Stop
        }
                
        if($Error.Count -ne 0)
        {
            Write-Host "[ERROR]: Error in Enable-Mailbox for user! Please see Output Error Logs for details." `
                -ForegroundColor Red

            $string = "--------------------------------------------------
            User = $UPN
            Email = $SMTP
            Alias = $SAM
            Error Details:
            "

            $string >> $OutputErrorLog 
            $Error[0] >> $OutputErrorLog
            $errcount++
        }
        else
        {
            Write-Host "Mailbox enabled successfully." -ForegroundColor Green
            $string = "--------------------------------------------------
            Item Processed with details:
            User = $UPN
            Email = $SMTP
            Alias = $SAM"

            $string >> $OutputLog
            $count++
        }
        $Error.Clear()
    }

    catch
    {
        Write-Host "[ERRORCATCH]: Error in Enable-Mailbox for user! Please see Output Error Logs for details." `
            -ForegroundColor Red

        $string = "--------------------------------------------------
        User = $($Item.UserPrincipalName)
        Email = $($Item.PrimarySMTPAddress)
        Alias = $($Item.samAccountName)

        Error Details:
        "

        $string >> $OutputErrorLog 
        $Error[0] >> $OutputErrorLog
        $errcount++
    }

    finally
    {   
        $TotalCount = $count + $errcount
        Write-Verbose "Value of total count is $TotalCount from $($Items.count)"
        if($TotalCount -ne 1)
        {
            $Percent = (($TotalCount/$Items.count) * 100)
            Write-Verbose "Value of percent is $Percent"
            Write-Progress -Activity "Running Enable-Mailbox..." `
	            -Status "Progress: $Totalcount/$($Items.count)   $Percent% " `
	            -PercentComplete $Percent `
	            -CurrentOperation "$($Item.samAccountName)"
        }
    }
}
#endregion

$Global:ErrorActionPreference = $CurrentPreference

if ($StartTranscript -eq $True)
{
    Stop-Transcript
}


#endregion


#region------------------------------------------------[End Processing]-----------------------------------------------------------

#region: Add footer to Log files and Output
$CurrentEnd = (Get-Date -Format "dd-MM-yyyy HH:mm:ss")
						 
Write-Output "`n`n`n**************************End Script**************************`n`n" 
Write-Output "Script Ended on $CurrentEnd
Total Items Processed = $count
Total Errors = $errcount

"

$footerLog = "
--------------------------------------------------
--------------------------------------------------
********************END SCRIPT********************

Script Ended on: $CurrentEnd
Total Items Processed: $count
"

$footerError = "
--------------------------------------------------
--------------------------------------------------
********************END SCRIPT********************

Script Ended on: $CurrentEnd
Total Errors: $errcount
"
Write-Verbose "Adding Footer to Log Files..."
$footerLog >> $OutputLog
$footerError >> $OutputErrorLog
#endregion

#endregion


#--------------------------------------------------------------***End Script***----------------------------------------------------------

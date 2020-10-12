$mailbox = Get-mailbox | select -Property Name
$mailbox

$Filelocation = "C:\Lab 1\departments_noLEGAL or EXEC.csv"

Write-Verbose "Importing OU CSV..."
# SELECT ALL necessary properties
$OU = (Import-Csv $Filelocation -ErrorAction Stop | Select-Object -Property Name,DisplayName,Path)
$Names = $OU.Name

Foreach($item in $OU){
    foreach($name in $mailbox){
        if ($item -eq $name){
            Write-Debug
            Write-host 'exists' -ForegroundColor Green
        }
        else
        {
            'not exist'
        }
    }
}

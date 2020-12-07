<# 
~ Display Progress bar
Source: https://stackoverflow.com/questions/15739944/write-progress-bar-till-get-job-return-running-powershell
#>

# Some dummy jobs for illustration purposes
start-job -ScriptBlock { start-sleep -Seconds 5 }
start-job -ScriptBlock { start-sleep -Seconds 10 }
start-job -ScriptBlock { start-sleep -Seconds 15 }
start-job -ScriptBlock { start-sleep -Seconds 20 }
start-job -ScriptBlock { start-sleep -Seconds 25 }


# Get all the running jobs
$jobs = get-job | Where-Object { $_.State -eq "Running" }
$total = $jobs.count
$runningjobs = $jobs.count

# Loop while there are running jobs
while($runningjobs -gt 0) {
    # Update progress based on how many jobs are done yet.
    $Progress = [System.Math]::Round(($total-$runningjobs)/$total*100)
    $null = Write-Progress -Activity "Events" -Status "Progress:$Progress" -PercentComplete (($total-$runningjobs)/$total*100)

    # After updating the progress bar, get current job count
    $runningjobs = (get-job | Where-Object { $_.state -eq "running" }).Count
}
Get-Job


# function for this
function Display-Progress {
    #param (
    #    OptionalParameters
    #)
    $jobs = get-job | Where-Object { $_.State -eq "Running" }
    $total = $jobs.count
    $runningjobs = $jobs.count

    # Loop while there are running jobs
    while($runningjobs -gt 0) {
        # Update progress based on how many jobs are done yet.
        $Progress = [System.Math]::Round(($total-$runningjobs)/$total*100)
        Write-Progress -Activity "Events" -Status "Progress:$Progress%" -PercentComplete (($total-$runningjobs)/$total*100)

        # After updating the progress bar, get current job count
        $runningjobs = (get-job | Where-Object { $_.state -eq "running" }).Count
    }
    Write-Host "Get-Job"
}

# Some dummy jobs for illustration purposes
start-job -ScriptBlock { start-sleep -Seconds 5 }
start-job -ScriptBlock { start-sleep -Seconds 10 }
start-job -ScriptBlock { start-sleep -Seconds 15 }
#start-job -ScriptBlock { start-sleep -Seconds 20 }
#start-job -ScriptBlock { start-sleep -Seconds 25 }


function Show-Progress {
    #param (
    #    OptionalParameters
    #)
    $jobs = get-job | Where-Object { $_.State -eq "Running" }
    $total = $jobs.count
    $runningjobs = $jobs.count

    # Loop while there are running jobs
    while($runningjobs -gt 0) {
        # Update progress based on how many jobs are done yet.
        $Progress = [System.Math]::Round(($total-$runningjobs)/$total*100)
        Write-Progress -Activity "Events" -Status "Progress:$Progress" -PercentComplete (($total-$runningjobs)/$total*100)

        # After updating the progress bar, get current job count
        $runningjobs = (get-job | Where-Object { $_.state -eq "running" }).Count
    }
    Get-Job
}

$test = Show-Progress
$test  | Where-Object {$_.State -eq "Completed"} | Remove-Job
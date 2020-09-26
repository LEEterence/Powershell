#~ Switch to test file location on multiple servers

$servers = @('DC01', 'RDS01', 'Wsus01')
Write-Host $servers 

$currentServer = Read-Host "Choose a server"

switch ($currentServer) {
    $servers[0] {
        Write-Host "Verifying connection at $($servers[0])" -ForegroundColor Cyan
        # Use $Null To stop the normal 'True' or 'False' message that gets outputted by test-connection each time
        $null = test-connection $($servers[0]) -Quiet -count 1
        Get-Content "\\$($servers[0])\C$\users\administrator\desktop\app_configuration.txt"
        break
    }
    $servers[1] {
        try {
            # NOTE: -erroraction stop is required for the catch error message to appear, otherwise it will display ps error and continue on
            test-connection $($servers[1]) -ErrorAction Stop
            Get-Content "\\$($servers[1])\C$\users\administrator\desktop\app_configuration.txt"
        }
        catch {
            Write-Error "Server offline" 
        }
        break
    }
    $servers[2] {
        try {
            # NOTE: -erroraction stop is required for the catch error message to appear
            test-connection $($servers[2]) -ErrorAction Stop
            Get-Content "\\$($servers[1])\C$\users\administrator\desktop\app_configuration.txt"
        }
        catch {
            Write-Error "server offline"
        }
        break
    }
    default {
        Write-Host "Servers could not be found" -ForegroundColor Red
        break
    }
}
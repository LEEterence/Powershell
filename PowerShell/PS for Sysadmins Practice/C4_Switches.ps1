#~ Switch to test file location on multiple servers

$servers = @('DC01', 'RDS01', 'Wsus01')
Write-Host $servers 

$currentServer = Read-Host "Choose a server"

switch ($currentServer) {
    $servers[0] {
        test-connection $($servers[0]) -Quiet -count 1
        Get-Content "\\$($servers[0])\C$\users\administrator\desktop\app_configuration.txt"
        break
    }
    $servers[1] {
        try {
            test-connection $($servers[1])
            Get-Content "\\$($servers[1])\C$\users\administrator\desktop\app_configuration.txt"
        }
        catch {
            Write-Error "Server offline" 
        }
        break
    }
    $servers[2] {
        try {
            test-connection $($servers[2])
            Get-Content "\\$($servers[1])\C$\users\administrator\desktop\app_configuration.txt"
        }
        catch {
            Write-Error "server offline"
        }
        
        break
    }
    default {
        Write-Host "Servers could not be found" -ForegroundColor rEd
    }
}
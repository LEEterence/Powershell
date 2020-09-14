$servers = @('DC01', 'WDS01', 'Wsus01')
if (Test-Connection -computername $servers[0] -Quiet -count 1) {
    Write-Host "Server Online" -ForegroundColor Green
    Get-Content -path "\\$($servers[1])\C$\users\administrator.Terence\desktop\app_configuration.txt"
}
else {
    Write-Host "Server cannot be contacted" -ForegroundColor Red
}

<# Get-Content -path "\\$($servers[0])\C$\users\administrator\desktop\app_configuration.txt"

Get-Content -path "\\$($servers[2])\C$\users\administrator\desktop\app_configuration.txt" #>

$servercount = $servers.Count
$servercount

<# $servers | Get-Member #>

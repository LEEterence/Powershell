#~ Array Practice ################

$servers = @('DC01', 'RDS01', 'Wsus01')
if (Test-Connection -computername $servers[0] -Quiet -count 1) {
    Write-Host "Server Online" -ForegroundColor Green
    Get-Content -path "\\$($servers[0])\C$\Users\Administrator\desktop\app_configuration.txt"
    #Get-Content -path "\\$($servers[0])\$env:USERPROFILE\desktop\app_configuration.txt"

    <# get-content -Path "\\dc01\C$\Users\Administrator\Desktop\app_configuration.txt" #>

}
else {
    Write-Host "Server cannot be contacted" -ForegroundColor Red
}

<# Get-Content -path "\\$($servers[0])\C$\users\administrator\desktop\app_configuration.txt"

Get-Content -path "\\$($servers[2])\C$\users\administrator\desktop\app_configuration.txt" #>

$servercount = $servers.Count
$servercount

<# $servers | Get-Member #>

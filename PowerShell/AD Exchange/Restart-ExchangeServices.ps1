# Obtain all services
Get-Service *Exchange* | Where-Object {$_.DisplayName -NotLike "*Hyper-V*"} | Format-Table DisplayName, Name, Status 
# Restart all
Get-Service *Exchange* | Where-Object {$_.DisplayName -NotLike "*Hyper-V*"}  | Restart-Service -Force
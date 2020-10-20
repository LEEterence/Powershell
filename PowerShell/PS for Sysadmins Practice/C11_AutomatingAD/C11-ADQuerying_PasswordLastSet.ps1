# ~Finding users who haven't change password in last 30 days #############################################
# Filter for when users last password was set
Get-ADUser -Filter * -Properties PasswordLastSet | Select-Object Name,PasswordLastSet

$Today = Get-Date 
$30daysago = $Today.AddDays(-30)
    # Wordier alternative: Get-ADUser -Filter * -Properties PasswordLastSet | Where-Object {$_.PasswordLastSet -lt $30daysago} | Select-Object Name,PasswordLastSet
# Filter for all users who has last set a password earlier than 30 days ago
Get-ADUser -Filter "PasswordLastSet -lt '$30daysago'"
# Filter for only ENABLED users and previous condition
Get-ADUser -Filter "Enabled -eq '$True' -and PasswordLastSet -lt '$30daysago'"

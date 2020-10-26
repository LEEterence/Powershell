<# 
~ Grabbing random values, great for use during creating Test AD Users
#>

-join (Get-Random -Maximum 9 -Minimum 0 -Count 10)
$Var = -join (Get-Random -Maximum 9 -Minimum 0 -Count 10)

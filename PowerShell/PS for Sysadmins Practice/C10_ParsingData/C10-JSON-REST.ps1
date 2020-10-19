#http://api.postcodes.io/random/postcodes
#~ Querying postcodes.io API service to return a randome postcode in JSON form

# Slower Method
<# $result = Invoke-WebRequest -uri 'http://api.postcodes.io/random/postcodes'
# Convert to PowerShell Object
#$result.Content | ConvertFrom-Json
$ResultContents = $result.Content | ConvertFrom-Json
$ResultContents.result
 #>
 
# @Alternative Method (FASTER) - One command instead of two!
Invoke-RestMethod -Uri 'http://api.postcodes.io/random/postcodes'
$RestContents = Invoke-RestMethod -Uri 'http://api.postcodes.io/random/postcodes'
$RestContents.result

<# 
~ Moving database - typically done after rename
#>

#Typically store exchange database on a different drive
New-Item -Type Directory -Path "path/to/location" -Name "<Exchange Directory Name>"
Move-DatabasePath -identity "TerenceMDB" -EdbFilePath E:\TerenceMDB\TerenceMDB.edb -LogFolderPath E:\TerenceMDB
#Verify
Get-MailboxDatabase | Select-Object EdbFilePath
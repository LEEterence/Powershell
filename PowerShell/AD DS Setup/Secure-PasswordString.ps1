# Creating a secure password and storing
$Filelocation = ""


'Password1' | ConvertTo-SecureString -Force -AsPlainText | Export-Clixml -Path $Filelocation
<# 
~ Create mailbox DB
#>

# Note logs and edb stored in same folder
New-MailboxDatabase -Name "<Name of Mailbox DB" -EdbFilePath "path\to\db" -LogFolderPath "path\to\db" -server "<server_Name>"
# Verify database mounted (sometimes doesn't)
Get-MailboxDatabase -Status | Sort Name | Format-Table Name, Server, Mounted
Mount-Database -Identity DB02
# Example: New-MailboxDatabase -Name "DB01" -EdbFilePath E:\DB01\DB01.edb -LogFolderPath "E:\DB01" -Server "Lee.enron.com"

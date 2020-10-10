Get-MailboxDatabase -Status | Sort Name | Format-Table Name, Server, Mounted
Mount-Database -Identity DB02
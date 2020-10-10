
# Obtain name of Exchange mailbox and status
Get-MailboxDatabase
# Obtain physical path to the mailbox database (edbfilepath is the data path for the mailbox)
Get-MailboxDatabase -Status | select edbfilepath, logfolderpath | Format-List

# Gets all mailbox users within the specified mailbox database
Get-Mailbox -Database "MailboxDatabaseName"
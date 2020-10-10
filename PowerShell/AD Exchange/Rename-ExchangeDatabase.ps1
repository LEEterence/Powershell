<# 
~ Finds and Renames database
@ Must be done in (EMS) Exchange Management Shell (ExchangeServer2016-x64-cu14 Installed)
#>

Get-MailboxDatabase
# Rename database
Set-MailboxDatabase "<Name of the Database>" -Name "<New Name>"

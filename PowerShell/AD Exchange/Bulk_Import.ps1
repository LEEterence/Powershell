# Ensure file formats are named correctly 
# Base Folder Ex) Terence Lee
# File Path Ex) terence_lee.pst

Get-ChildItem \\SERVER01\PSTshareRO\Recovered\*.pst | ForEach-Object { New-MailboxImportRequest -Name RecoveredPST -BatchName Recovered -Mailbox $_.BaseName -FilePath $_.FullName}
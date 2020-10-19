$rootdir="DMIT2512Quiz1"
if(Test-Path "C:\$rootdir")
{
	Remove-Item –path "C:\$rootdir" –recurse -force
}
sleep 5
New-Item -ItemType Directory -Path "C:\$rootdir"
Get-WindowsFeature | Where-Object name -eq "RSAT-AD-Powershell" | where-Object InstallState -eq "Available" | Install-WindowsFeature
Import-Module -Name ActiveDirectory
Get-User Juan.Acertijo | Select-Object Name,SamAccountName,WindowsEmailAddress,Phone,Department >> C:\$rootdir\$($rootdir)JuanBrief.txt
Get-User Juan.Acertijo | fl >> C:\$rootdir\$($rootdir)JuanVerbose.txt
Get-ADPrincipalGroupMembership Juan.Acertijo | select name >> C:\$rootdir\$($rootdir)JuanGroups.txt
Get-Mailbox Juan.Acertijo >> C:\$rootdir\$($rootdir)JuanMail.txt


dir "C:\$rootdir" -Recurse | Get-FileHash -ea 0 | Format-Table -Wrap -Autosize > C:\$rootdir\hashes.txt
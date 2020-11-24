<# 
~ Create share folder granting permissions to each group within a domain
# Source: https://adamtheautomator.com/how-to-manage-ntfs-permissions-with-powershell/#Modifying_NTFS_NTFS_Permissions_With_SetAcl
#>

$FilePath = "E:\_git\test"


if(Test-Path $FilePath)
{
	Remove-Item –path $FilePath –recurse -force
}
Start-Sleep 5
#$FilePath = "E:\_git\test"
#test-path $filepath

if (Get-ChildItem -Path $FilePath | Where-Object {$_.Name -in ("Sleepygeeks","SoftwareJuice","Learning.SoftwareJuice")}){
    Write-Host "Share exists" 
    Remove-item "SleepyGeeks" 
    Remove-item "SoftwareJuice"
    Remove-item "Learning.SoftwareJuice"
}else{
    New-Item -ItemType Directory -Path $FilePath -Name "Sleepygeeks"
    New-Item -ItemType Directory -Path $FilePath -Name "SoftwareJuice"
    New-Item -ItemType Directory -Path $FilePath -Name "Learning.SoftwareJuice"
}

$SG = Get-Acl $FilePath\"SleepyGeeks"
$SJ = Get-Acl $FilePath\"SoftwareJuice"
$LSJ = Get-Acl $FilePath\"Learning.SoftwareJuice"
# Get all ACLs- [enum]::GetValues('System.Security.AccessControl.FileSystemRights')

# Get all groups in specific domain ### 


# Set ACLS - Modify identity!####
$identity = 'domain\user'
$rights = 'Modify' #Other options: [enum]::GetValues('System.Security.AccessControl.FileSystemRights')
$inheritance = 'ContainerInherit, ObjectInherit' #Other options: [enum]::GetValues('System.Security.AccessControl.InheritanceFlags')
$propogation = 'None' #Other options: [enum]::GetValues('System.Security.AccessControl.PropagationFlags')
$type = 'Allow' #Other options: [enum]::GetValues('System.Security.AccessControl.AccessControlType')
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propogation, $type)




#Get-ADGroup -Filter * -Server sleepygeeks.com -SearchBase "ou=department users,dc=sleepygeeks,dc=com" | select Name


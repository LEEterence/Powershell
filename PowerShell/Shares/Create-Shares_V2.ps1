<# 
~ Create share folder granting permissions to each group within a domain
# Source: https://adamtheautomator.com/how-to-manage-ntfs-permissions-with-powershell/#Modifying_NTFS_NTFS_Permissions_With_SetAcl
#>

$FilePath = "C:\"
$NameList = @("Sleepygeeks","SoftwareJuice","Learning.SoftwareJuice")

#if(Test-Path $FilePath)
#{
#	Remove-Item –path $FilePath –recurse -force
#}
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

#$SG = Get-Acl $FilePath\"SleepyGeeks"
#$SJ = Get-Acl $FilePath\"SoftwareJuice"
#$LSJ = Get-Acl $FilePath\"Learning.SoftwareJuice"
# Get all ACLs- [enum]::GetValues('System.Security.AccessControl.FileSystemRights')

# Get all groups in specific domain ### 
$Domains = (Get-ADforest).domains
foreach($Domain in $Domains){
    $split = $Domain.Split(".")


    if ($split.Count -gt 2){
        $child = $split[0]
        $prefix = $split[1]
        $suffix = $split[2]
        Get-ADGroup -Filter * -Server $Domain -SearchBase "ou=department users,dc=$child,dc=$prefix,dc=$suffix" | select Name | Out-File "C:\Users\Administrator\Desktop\$($prefix).csv"
    }else{
        $prefix = $split[0]
        $suffix = $split[1]
        Get-ADGroup -Filter * -Server $Domain -SearchBase "ou=department users,dc=$prefix,dc=$suffix" | select Name | Out-File "C:\Users\Administrator\Desktop\$($prefix).csv"
    }

}


# Set ACLS - Modify identity!####
$identity = 'domain\user'
$rights = 'Modify' #Other options: [enum]::GetValues('System.Security.AccessControl.FileSystemRights')
$inheritance = 'ContainerInherit, ObjectInherit' #Other options: [enum]::GetValues('System.Security.AccessControl.InheritanceFlags')
$propogation = 'None' #Other options: [enum]::GetValues('System.Security.AccessControl.PropagationFlags')
$type = 'Allow' #Other options: [enum]::GetValues('System.Security.AccessControl.AccessControlType')
$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propogation, $type)



# Parse through all groups on domain
$Domains = (Get-ADforest).domains
#Get-ADGroup -Filter * -Server sleepygeeks.com -SearchBase "ou=department users,dc=sleepygeeks,dc=com" | select Name


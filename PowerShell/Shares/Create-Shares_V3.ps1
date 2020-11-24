<# 
~ Create share folder granting permissions to each group within a domain
# Source: https://adamtheautomator.com/how-to-manage-ntfs-permissions-with-powershell/#Modifying_NTFS_NTFS_Permissions_With_SetAcl
#>

$FilePath = "C:\"

if (Get-ChildItem -Path $FilePath | Where-Object {$_.Name -in $NameList}){
    Write-Host "Share exists" 
    #for($i=0;$i -lt $($NameList.Count);$i++){
    #    Remove-Item -Path "C:\Server Knowledge Base"
    #}
    Remove-item "C:\Server Knowledge Base"
    Remove-item "C:\Network Knowledge Base"
}else{
    New-Item -ItemType Directory -Path $FilePath -Name "Server Knowledge Base"
        # Set ACLS - Modify identity!####
    $identity = 'SleepyGeeks\Srv Support Edmonton'
    $rights = 'Modify' #Other options: [enum]::GetValues('System.Security.AccessControl.FileSystemRights')
    $inheritance = 'ContainerInherit, ObjectInherit' #Other options: [enum]::GetValues('System.Security.AccessControl.InheritanceFlags')
    $propogation = 'None' #Other options: [enum]::GetValues('System.Security.AccessControl.PropagationFlags')
    $type = 'Allow' #Other options: [enum]::GetValues('System.Security.AccessControl.AccessControlType')
    $ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propogation, $type)

    # Get initial access rules
    $Acl = Get-Acl -Path "$Filelocation\Server Knowledge Base"
    $Acl.AddAccessRule($ACE)

    # Add ACE to ACL
    Set-Acl -Path "C:\Server Knowledge Base" -AclObject $Acl

    # Verify
    (Get-Acl -Path "$Filelocation\Server Knowledge Base").Access | Format-Table -Autosize

    # Create share
    New-SmbShare -name "Server Support Share" -Path "C:\Server Knowledge Base" -ChangeAccess 'SleepyGeeks\Srv Support Edmonton' -FullAccess 'SleepyGeeks\Domain Admins'
    # Cmd prompt version of assigning a drive letter
    #runas /user:administrator net use Z: "\\TEST01\TestShare" /persistent
    # Powershell version of assigning drive letter
    #New-PSDrive –Name “Z” –PSProvider FileSystem –Root "\\SG-TESTDC\Server Support Share" –Persist


    #######################################################################################
    $FileName = "Network Knowledge Base"
    New-Item -ItemType Directory -Path $FilePath -Name $FileName
    # Set ACLS - Modify identity!####
    $identity = 'SleepyGeeks\Net Support Edmonton'
    $rights = 'Modify' #Other options: [enum]::GetValues('System.Security.AccessControl.FileSystemRights')
    $inheritance = 'ContainerInherit, ObjectInherit' #Other options: [enum]::GetValues('System.Security.AccessControl.InheritanceFlags')
    $propogation = 'None' #Other options: [enum]::GetValues('System.Security.AccessControl.PropagationFlags')
    $type = 'Allow' #Other options: [enum]::GetValues('System.Security.AccessControl.AccessControlType')
    $ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propogation, $type)

    # Get initial access rules
    $Acl = Get-Acl -Path "C:\$($FileName)"
    $Acl.AddAccessRule($ACE)

    # Add ACE to ACL
    Set-Acl -Path "C:\$FileName" -AclObject $Acl

    # Verify
    (Get-Acl -Path "C:\$FileName").Access | Format-Table -Autosize

    # Create share
    New-SmbShare -name "Network Support Share" -Path C:\$FileName -ChangeAccess 'SleepyGeeks\Net Support Edmonton' -FullAccess 'SleepyGeeks\Domain Admins'
    # Cmd prompt version of assigning a drive letter
    #runas /user:administrator net use Z: "\\TEST01\TestShare" /persistent
    # Powershell version of assigning drive letter
    #New-PSDrive –Name “Y” –PSProvider FileSystem –Root "\\SG-TESTDC\Network Support Share" –Persist
}


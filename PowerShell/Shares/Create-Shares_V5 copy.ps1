<# 
~ Create share folder granting permissions to each group within a domain
# Source: https://adamtheautomator.com/how-to-manage-ntfs-permissions-with-powershell/#Modifying_NTFS_NTFS_Permissions_With_SetAcl
#>

$Filelocation = "C:\NTFS-Shares"

if (Get-ChildItem -Path $FilePath | Where-Object {$_.Name -like "Server Knowledge Base" -or "Network Knowledge Base"}){
    Write-Host "Share exists" 
    #for($i=0;$i -lt $($NameList.Count);$i++){
    #    Remove-Item -Path "C:\Server Knowledge Base"
    #}
    Remove-item "$Filelocation\Server Knowledge Base"
    Remove-item "$Filelocation\Network Knowledge Base"
}

    $FileName = "Server Knowledge Base"
    New-Item -ItemType Directory -Path $FilePath -Name $FileName
        # Set ACLS - Modify identity!####
    $identity = 'softwarejuice\Srv Support Edmonton'
    $rights = 'Modify' #Other options: [enum]::GetValues('System.Security.AccessControl.FileSystemRights')
    $inheritance = 'ContainerInherit, ObjectInherit' #Other options: [enum]::GetValues('System.Security.AccessControl.InheritanceFlags')
    $propogation = 'None' #Other options: [enum]::GetValues('System.Security.AccessControl.PropagationFlags')
    $type = 'Allow' #Other options: [enum]::GetValues('System.Security.AccessControl.AccessControlType')
    $ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propogation, $type)

    # Get initial access rules
    $Acl = Get-Acl -Path "$Filelocation\$FileName"
    $Acl.AddAccessRule($ACE)

    # Add ACE to ACL
    Set-Acl -Path "$Filelocation\$FileName" -AclObject $Acl

    # Verify
    (Get-Acl -Path "$Filelocation\$FileName").Access | Format-Table -Autosize

    # Create share
    New-SmbShare -name "Server Support Share" -Path "$Filelocation\$FileName" -ChangeAccess 'softwarejuice\Srv Support Edmonton' -FullAccess 'softwarejuice\Domain Admins'
    # Cmd prompt version of assigning a drive letter
    #runas /user:administrator net use Z: "\\TEST01\TestShare" /persistent
    # Powershell version of assigning drive letter
    #New-PSDrive –Name “Z” –PSProvider FileSystem –Root "\\SG-DC02\Server Support Share" –Persist


    #######################################################################################
    $FileName = "Network Knowledge Base"
    New-Item -ItemType Directory -Path $FilePath -Name $FileName
    # Set ACLS - Modify identity!####
    $identity = 'softwarejuice\Net Support Edmonton'
    $rights = 'Modify' #Other options: [enum]::GetValues('System.Security.AccessControl.FileSystemRights')
    $inheritance = 'ContainerInherit, ObjectInherit' #Other options: [enum]::GetValues('System.Security.AccessControl.InheritanceFlags')
    $propogation = 'None' #Other options: [enum]::GetValues('System.Security.AccessControl.PropagationFlags')
    $type = 'Allow' #Other options: [enum]::GetValues('System.Security.AccessControl.AccessControlType')
    $ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propogation, $type)

    # Get initial access rules
    $Acl = Get-Acl -Path "$Filelocation\$($FileName)"
    $Acl.AddAccessRule($ACE)

    # Add ACE to ACL
    Set-Acl -Path "$Filelocation\$FileName" -AclObject $Acl

    # Verify
    (Get-Acl -Path "$Filelocation\$FileName").Access | Format-Table -Autosize

    # Create share
    New-SmbShare -name "Network Support Share" -Path $Filelocation\$FileName -ChangeAccess 'softwarejuice\Net Support Edmonton' -FullAccess 'softwarejuice\Domain Admins'
    # Cmd prompt version of assigning a drive letter
    #runas /user:administrator net use Z: "\\TEST01\TestShare" /persistent
    # Powershell version of assigning drive letter
    #New-PSDrive –Name “Y” –PSProvider FileSystem –Root "\\SG-DC02\Network Support Share" –Persist



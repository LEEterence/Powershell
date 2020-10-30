# Set Base Folder containing Exported VM Templates 
$VHDImagePath = "E:\VMTemplates"
# Set Windows OS Folder Name used inside VM Templates 
$windowsOSFolder = "Windows"
# Set Base Folder containing downloaded Windows Updates 
$updatePath = "E:\Updates"
# Set Scratch Folder to use when extracting Windows Updates 
$tempPath ="E:\Temp"
# Find all VHD and VHDX files in the Template Folder 
$VHDImages = Get-ChildItem -Path $VHDImagePath -Include *.vhd,*.vhdx -Recurse -Force | Select-Object -Property FullName
# Find all MSU and CAB file updates in the Update Folder 
$windowsUpdates = Get-ChildItem -Path $updatePath -Include *.msu,*.cab -Recurse -Force | Select-Object -Property FullName
# Apply the updates using Offline Services for each VHD or VHDX template  
ForEach ( $VHDImage in $VHDImages ){
    Write-Output "Processing: " $VHDImage.FullName          
    
    # Mount the VHD or VHDX file           
    $mountedVHD = [string](Mount-VHD -Path $VHDImage.FullName -Passthru | Get-Disk | Get-Partition | Get-Volume | Where-Object -Property FileSystemLabel -NE "System Reserved").DriveLetter + ":\"
    $mountedVHD = $mountedVHD.Substring($mountedVHD.Length-3,3)
    # Test whether mounted VHD or VHDX file is an OS Image           
    If ( Test-Path $mountedVHD$windowsOSFolder )         
    {
        # Apply all updates to the Mounted VHD or VHDX           
        ForEach ( $windowsUpdate in $windowsUpdates )         
        {
            Write-Output "Applying Update: " $windowsUpdate.FullName
            # Apply a single Update           
            Add-WindowsPackage -Path $mountedVHD -PackagePath $windowsUpdate.FullName -ScratchDirectory $tempPath -WindowsDirectory $windowsOSFolder
        }
    }
}

# New VM ###### (Change the vm and vhd paths)
New-VM -Name “[VMNAMEHERE]” –MemoryStartupBytes 4096MB –Path “[PATHHERE]” –NewVHDPath “[VHDPATHHERE].vhdx” –NewVHDSizeBytes 25GB
	# If the VM folders still exist for any of the paths - must remove them FIRST
	# MUST specify iso FIRST, avoids extra headache
	# MUST DISABLE CHOOSING ISO (will ask for boot device each time)

# Setting ISO file ###########
Set-VMDvdDrive -VMName TestVM -Path .\WinBuild.iso

# Get VM ################ (Obtain all installed vms)
Get-VM

 Remove VM ####################### (change name)
Remove-VM “MyWin10” –Force
	 DISK AND VM FOLDERS WILL REMAIN - MUST REMOVE THEM FIRST (or remove using gui)
	# Remove-Item 'PATHTOVIRTUALMACHINE' -Force
	# Remove-item 'PATHTOVDISKS' -force

# Add vms to switches ###############
Connect-VMNetworkAdapter –Vmname [VMNAME] –SwitchName “[SWITCHNAME]”

# New Virtual Disks ###########################
New-VHD -Path "PathtoVM.vhdx" -SizeBytes 5GB -Dynamic
	# Test it exists # Test-Path -Path "PathtoVM.vhdx"
Get-VM -Name SRV01 | Add-VMHardDiskDrive -Path "PATHtoABOVEcreatedvm.vhdx"
	# Get-VM -VMname * # to find all VMs

# Changing VM associated with Virtual Disks ###############
Get-VMHardDiskDrive -VMName *
	# to find all VM HARD DISKS
Get-VMHardDiskDrive –VMName SRV01
Get-VMHardDiskDrive –VMName SRV01 –ControllerType SCSI –ControllerNumber 1
	# controller type and controller number are OPTIONAL
Get-VMHardDiskDrive –VMName SRV01 –ControllerType SCSI –ControllerNumber 1 | Remove-VMHardDiskDrive
	# Get-VMHardDiskDrive -VMName [VMNAME]  # verifies disk has removed

# METHOD 1 - VH disks ONLINE and INITILIAZE, format and add letter drives ##################
# NOTE: MUST BE DONE ON THE GUEST/DEPLOYMENT
try {
	#Set all disks, except the first disk, to online and writable
	Get-Disk | where-object?{$_.number -ne 0}| Set-Disk -IsOffline $False
	Get-Disk | where-object{$_.number -ne 0}| Set-Disk -isReadOnly $False

	#Initialize all disks
	Get-Disk | where-object{$_.number -ne 0}| Initialize-Disk -PartitionStyle GPT
}catch{
	Write-Host $_.Exception.Message
}
try {
	#Create Partition on all disk, auto assign letter and use maximum size
	Get-Disk | ?{$_.number -ne 0}| New-Partition -AssignDriveLetter -UseMaximumSize
	#Get all partitions and format them
	Get-Disk | ?{$_.number -ne 0}| Get-Partition |?{$_.type -like "Basic"}| Format-Volume -Confirm:$false
}catch{
	Write-Host $_.Exception.Message
}

	# METHOD 2 - online, initialize ######################
	#(PASSTHRU returns the output so we can see in the gui)
	Get-Disk | Where-Object PartitionStyle -eq 'RAW' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition  -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -Confirm:$false

# REMOVING VIRTUAL HARD DISKS ######################
$a = get-vm srv01 | Select-Object -ExpandProperty HardDrives | Where-Object controllernumber -eq 1 |select-object path
$b = $a.path
	# even though $a has the object for path - it also has the column header (Path), filename, etc. Specifying path further isolates path value
stop-vm srv01
	# must stop-vm to prevent errors
remove-item -path $b
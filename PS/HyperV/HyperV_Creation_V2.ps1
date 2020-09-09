<#
?Automated Hyper-V Creation user parameters
?What we need: HyperV or VMWare Workstation, ISO - Windows server and Windows 10, VM/VHD File Paths
#>

# METHOD 2 - online, initialize ###################### @COMMENT out if done already
	#(PASSTHRU returns the output so we can see in the gui)
	Get-Disk | Where-Object PartitionStyle -eq 'RAW' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition  -Driveletter E -UseMaximumSize | Format-Volume -FileSystem NTFS -Confirm:$false
  #use New-Partition -Assigndriveletter to assign the next available drive letter

<#
Creating folders to house VMs, VHDs, and ISOs in separate E: drive
@Comment OUT if done already
#>
mkdir "E:\Virtual Machines"
mkdir "E:\Virtual Harddisks"
mkdir "E:\ISOs"

<#
Creating new VM Switch
#>
#Private Switch (only connects VMs, no connection to Host)
$NewVMParam = @{
  Name = "PrivateSwitch"
  SwitchType = Private
}
New-VMSwitch -Name "PrivateSwitch" -SwitchType = Private

<#
@Creating New VM
Change: Name, VM, VHD paths
Optional Change: MemoryStartupBytes,NewVHDSizeBytes
#>
$NewVMParam = @{
  #@change
  Name               = 'DC01'
  #*change
  MemoryStartUpBytes = 4GB
  #@change
  Path               = "E:\Virtual Machines"
  SwitchName         = "Private VM Switch"
  #@change
  NewVHDPath         = "E:\Virtual Hard Disks\Disk1.vhdx"
  #*change
  NewVHDSizeBytes    = 60GB
  Generation =
  ErrorAction        = 'Stop'
  Verbose            = $True
}
$VM = New-VM @NewVMParam

<#
Setting VM Paramters
Change:
Optional Change: ProcessorCount, MemoryMinimumBytes, MemoryMaximumBytes
#>
$SetVMParam = @{
  ProcessorCount     = 2
  DynamicMemory      = $True
  MemoryMinimumBytes = 512MB
  MemoryMaximumBytes = 2Gb
  ErrorAction        = 'Stop'
  PassThru           = $True
  Verbose            = $True
}
$VM = $VM | Set-VM @SetVMParam
<#
New Virtual Hard Disk
Change: Path
Optional Change: Dynamic, SizeBytes
#>
$NewVHDParam = @{
  #@change
  Path        = 'E:\Virtual Hard Disks\Disk1.vhdx'
  Dynamic     = $True
  SizeBytes   = 60GB
  ErrorAction = 'Stop'
  Verbose     = $True
}
New-VHD @NewVHDParam
# $VHD is never used
# $VHD = New-VHD @NewVHDParam

<#
Add VHD to VM
Change: Path
Optional Change: ControllerType, ControllerLocation
#>
$AddVMHDDParam = @{
  #@ change
  Path               = 'E:\Virtual Hard Disks\Disk1.vhdx'
  ControllerType     = 'SCSI'
  ControllerLocation = 1
}
$VM | Add-VMHardDiskDrive @AddVMHDDParam
<#
Setting ISO used by VM
Change: VMName, Path
Optional Change:
#>
$VMDVDParam = @{
  #@Change
  VMName      = 'DC01'
  #@Change
  Path        = 'E:\ISOs\Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO'
  ErrorAction = 'Stop'
  Verbose     = $True
}
Set-VMDvdDrive @VMDVDParam
<#
Adding vm to virtual switch
Change:
Optional Change:
#>
$AddVMNICParam = @{
  SwitchName = 'External'
}
$VM | Add-VMNetworkAdapter @AddVMNICParam
<#
Starting Hyper-V VM
#>
$VM | Start-VM -Verbose

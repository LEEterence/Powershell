<#
? Automated Hyper-V Creation user parameters
? What we need: HyperV or VMWare Workstation, ISO - Windows server and Windows 10, VM/VHD File Paths

! CHECK SAMIs PS creation for VHDs, current script comments out all VHD modifications
#>

# METHOD 2 - online, initialize ######################
#(PASSTHRU returns the output so we can see in the gui)
Get-Disk | Where-Object PartitionStyle -eq 'RAW' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition  -Driveletter E -UseMaximumSize | Format-Volume -FileSystem NTFS -Confirm:$false
#use New-Partition -Assigndriveletter to assign the next available drive letter or -Driveletter to specify

<#
Creating folders to house VMs, VHDs, and ISOs in separate E: drive
@Comment OUT if done already
#>
mkdir "E:\Virtual Machines"
mkdir "E:\Virtual Harddisks"
mkdir "E:\ISOs"

<#
@Creating new VM Switch, comment out if done already
#>
#Private Switch (only connects VMs, no connection to Host)
New-VMSwitch -Name "PrivateSwitch" -SwitchType Private

<#
@New Virtual Hard Disk, not really necessary since the vhd is created in New-VM cmdlet
#
Change: Path
Optional Change: Dynamic, SizeBytes
#>
#$NewVHDParam = @{
#  #@change
#  Path        = 'E:\Virtual HardDisks\WSUS01.vhdx'
#  Dynamic     = $True
#  SizeBytes   = 60GB
#  ErrorAction = 'Stop'
#  Verbose     = $True
#}
#New-VHD @NewVHDParam
##$VHD is never used..
# $VHD = New-VHD @NewVHDParam

<#
@Creating New VM
Change: Name, VM, VHD paths
Optional Change: MemoryStartupBytes,NewVHDSizeBytes
#>
$NewVMParam = @{
  #@change
  Name               = 'WSUS01'
  #*change
  MemoryStartUpBytes = 4GB
  Generation         = 1
  ##@change
  NewVHDPath         = "E:\Virtual HardDisks\WSUS01.vhdx"
  ##*change
  NewVHDSizeBytes    = 60GB
  #! Error: "New-VM : Sequence contains more than one element" - IF THERE IS MORE THAN ONE SWITCH WITH THE SAME NAME
  SwitchName         = "PrivateSwitch"
  Path               = "E:\Virtual Machines"
  ##@change
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
  # Memory min and max may not work well for some reason..
  MemoryMinimumBytes = 512MB
  MemoryMaximumBytes = 4096MB
  ErrorAction        = 'Stop'
  PassThru           = $True
  Verbose            = $True
}
$VM = $VM | Set-VM @SetVMParam

<#
  @Add VHD to VM, not necessary... new-vm creates and associates a new vhd
  Change: Path
  Optional Change: ControllerType, ControllerLocation
  #>
#$AddVMHDDParam = @{
#  #@ change
#  Path               = 'E:\Virtual HardDisks\WSUS01.vhdx'
#  ControllerType     = 'SCSI'
#  ControllerLocation = 1
#}
#$VM | Add-VMHardDiskDrive @AddVMHDDParam

<#
  Setting ISO used by VM
  Change: VMName, Path
  Optional Change:
  #>
$VMDVDParam = @{
  #@Change
  VMName      = 'WSUS01'
  #@Change
  #controllerlocation = 0
  #controllernumber = 1
  Path        = "E:\ISOs\Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO"
  ErrorAction = 'Stop'
  Verbose     = $True
}
Set-VMDvdDrive @VMDVDParam
Get-VMDvdDrive -VMName 'WSUS01'
<#
  Adding vm to virtual switch - #!ONLY FOR EXTERNAL NETWORKS (which simluate physical machines and can access host and internet)
  Change:
  Optional Change:
  #>
#$AddVMNICParam = @{
#  SwitchName = 'Private'
#}
#$VM | Add-VMNetworkAdapter @AddVMNICParam
<#
  Starting Hyper-V VM
  #>
$VM | Start-VM -Verbose

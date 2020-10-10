##~ online and initialize disks ##############################################################
#(PASSTHRU returns the output so we can see in the gui)
Get-Disk | Where-Object PartitionStyle -eq 'RAW' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition  -Driveletter E -UseMaximumSize | Format-Volume -FileSystem NTFS -Force
# change "New-Partition -Driveletter E" to "New-partition -assigndriveletter" to assign the next available drive letter instead of specifying
#verification
Get-Disk

# Turning disk online
Get-Disk | Where-Object -Property OperationalStatus -eq "offline" | Set-Disk -IsOffline $false
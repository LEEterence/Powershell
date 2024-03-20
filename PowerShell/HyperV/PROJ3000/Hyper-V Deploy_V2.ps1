function New-CustomHyperV{
    <# 
    .Description
    This file to imports users based on existing OUs
    
    .EXAMPLE
    Add-BulkUsers -VMName "hmcdc01" -WorkSheetName Toronto
    Running based on users with Toronto WorkSheet 
    
    #>
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $true)]
        [String] $VMName,
    
        [parameter(Mandatory = $false)] #here VM configs are stored
        [String] $VMPath = "C:\Hyper-V\VM Conf",
    
        [parameter(Mandatory = $false)] #CHANGE THIS LATER!!!!!!!!!!!!!!!!!!
        [String] $SysVHDPath = "C:\Hyper-V\VHDs\Sysprep Templates\WS2022", # This is folder path on test server.
    
        [parameter(Mandatory = $false)]
        [ValidateSet(1,2)]
        [int16] $Generation = 2, #Default to Generation 2
    
        [parameter(Mandatory = $false)]
        [ValidateSet("dynamic","static")]
        [string] $MemoryType = "dynamic",
    
        [parameter(Mandatory = $false)]
        [int64] $StaticMemoryAmount = 4GB,
    
        [parameter(Mandatory = $false)]
        [int16] $ProcessorCount = 1,
    
        [parameter(Mandatory = $true)]
        [String] $VMSwitchName,
    
        [parameter(Mandatory = $true)]
        [ValidateSet("internal","private", "external")]
        [string] $SwitchType,
    
        [parameter(Mandatory = $false)] #If sysprepping, don't need VHD size
        [String] $VHDSize
    )
    ######################################################
    ###           VM Creation and Configuration        ###
    ######################################################
    
    ## Network Adapter Check
    
    # Check if the network adapter exists
    $existingAdapter = Get-VMNetworkAdapter -VMName $VMName -ErrorAction SilentlyContinue
    $existingSwitch = Get-VMSwitch -Name $VMSwitchName -ErrorAction SilentlyContinue
    
    if ($existingAdapter) {
        
        Write-Host "Network adapter already exists in VM '$vmName'."
        
        New-VM -Name $VMName `
            -Path $VMPath `
            -NoVHD `
            -Generation $Generation `
            -MemoryStartupBytes $StaticMemoryAmount 
            -SwitchName $VMSwitchName
    }
    else {
        # Add a new network adapter
        ## Creation of the VM
        # Creation without VHD and with a default memory value (will be changed after)
        Write-Host "Creating new VM '$VMName'"
        Write-Host "Creating new network adapter '$VMSwitchName'"
    
        New-VM -Name $VMName `
               -Path $VMPath `
               -NoVHD `
               -Generation $Generation `
               -MemoryStartupBytes $StaticMemoryAmount 
               #-SwitchName $VMSwitchName
    
    
        #if ($AutoStartAction -eq 0){$StartAction = "Nothing"}
        #Elseif ($AutoStartAction -eq 1){$StartAction = "Start"}
        #Else{$StartAction = "StartIfRunning"}
        #
        #if ($AutoStopAction -eq 0){$StopAction = "TurnOff"}
        #Elseif ($AutoStopAction -eq 1){$StopAction = "Save"}
        #Else{$StopAction = "Shutdown"}
    
        ## Changing the number of processor and the memory
        # If Static Memory
        if (!$MemoryType){
        
            Set-VM -Name $VMName `
                   -ProcessorCount $ProcessorCount `
                   -StaticMemory `
                   -MemoryStartupBytes $StaticMemory `
                   -AutomaticStartAction $StartAction `
                   -AutomaticStartDelay $AutoStartDelay `
                   -AutomaticStopAction $StopAction
    
    
        }
        # If Dynamic Memory
        Else{
            Set-VM -Name $VMName `
                   -ProcessorCount $ProcessorCount `
                   -DynamicMemory 
                   #-MemoryMinimumBytes $MinMemory `
                   #-MemoryStartupBytes $StartupMemory `
                   #-MemoryMaximumBytes $MaxMemory `
                   #-AutomaticStartAction $StartAction `
                   #-AutomaticStartDelay $AutoStartDelay `
                   #-AutomaticStopAction $StopAction
    
        }
    
    
        # Create virtual switch
        if($SwitchType -eq "external"){
            Add-VMNetworkAdapter -VMName $vmName -Name "NewAdapterName"
            New-VMSwitch -name $VMSwitchName -NetAdapterName  -AllowManagementOS $true
            Write-Host "Added a new network adapter to VM '$vmName'."
        }
        else
        {
            New-VMSwitch -Name $VMSwitchName -SwitchType $SwitchType
            Add-VMNetworkAdapter -VMName $vmName -SwitchName $VMSwitchName -Name "NewAdapterName"
            Write-Host "Added a new network adapter to VM '$vmName'."
        }
    
    
    
        ## Set the primary network adapters
        $PrimaryNetAdapter = Get-VM $VMName | Get-VMNetworkAdapter
        if ($VlanId -gt 0){$PrimaryNetAdapter | Set-VMNetworkAdapterVLAN -Access -VlanId $VlanId}
        else{$PrimaryNetAdapter | Set-VMNetworkAdapterVLAN -untagged}
        <#
        if ($VMQ){$PrimaryNetAdapter | Set-VMNetworkAdapter -VmqWeight 100}
        Else {$PrimaryNetAdapter | Set-VMNetworkAdapter -VmqWeight 0}
    
        if ($IPSecOffload){$PrimaryNetAdapter | Set-VMNetworkAdapter -IPsecOffloadMaximumSecurityAssociation 512}
        Else {$PrimaryNetAdapter | Set-VMNetworkAdapter -IPsecOffloadMaximumSecurityAssociation 0}
    
        if ($SRIOV){$PrimaryNetAdapter | Set-VMNetworkAdapter -IovQueuePairsRequested 1 -IovInterruptModeration Default -IovWeight 100}
        Else{$PrimaryNetAdapter | Set-VMNetworkAdapter -IovWeight 0}
    
        if ($MacSpoofing){$PrimaryNetAdapter | Set-VMNetworkAdapter -MacAddressSpoofing on}
        Else {$PrimaryNetAdapter | Set-VMNetworkAdapter -MacAddressSpoofing off}
    
        if ($DHCPGuard){$PrimaryNetAdapter | Set-VMNetworkAdapter -DHCPGuard on}
        Else {$PrimaryNetAdapter | Set-VMNetworkAdapter -DHCPGuard off}
    
        if ($RouterGuard){$PrimaryNetAdapter | Set-VMNetworkAdapter -RouterGuard on}
        Else {$PrimaryNetAdapter | Set-VMNetworkAdapter -RouterGuard off}
    
        if ($NicTeaming){$PrimaryNetAdapter | Set-VMNetworkAdapter -AllowTeaming on}
        Else {$PrimaryNetAdapter | Set-VMNetworkAdapter -AllowTeaming off}
        #>
    
    
    
    
        ## VHD(X) OS disk copy
        $OsDiskInfo = Get-Item $SysVHDPath
        Copy-Item -Path $SysVHDPath -Destination $($VMPath + "\" + $VMName)
        Rename-Item -Path $($VMPath + "\" + $VMName + "\" + $OsDiskInfo.Name) -NewName $($OsDiskName + $OsDiskInfo.Extension)
    
        # Attach the VHD(x) to the VM
        Add-VMHardDiskDrive -VMName $VMName -Path $($VMPath + "\" + $VMName + "\" + $OsDiskName + $OsDiskInfo.Extension)
    
        $OsVirtualDrive = Get-VMHardDiskDrive -VMName $VMName -ControllerNumber 0
         
        # Change the boot order to the VHDX first
        Set-VMFirmware -VMName $VMName -FirstBootDevice $OsVirtualDrive
    
        # For additional each Disk in the collection
        Foreach ($Disk in $ExtraDrive){
            # if it is dynamic
            if ($Disk.Type -like "Dynamic"){
                New-VHD -Path $($Disk.Path + "\" + $Disk.Name + ".vhdx") `
                        -SizeBytes $Disk.Size `
                        -Dynamic
            }
            # if it is fixed
            Elseif ($Disk.Type -like "Fixed"){
                New-VHD -Path $($Disk.Path + "\" + $Disk.Name + ".vhdx") `
                        -SizeBytes $Disk.Size `
                        -Fixed
            }
    
            # Attach the VHD(x) to the Vm
            Add-VMHardDiskDrive -VMName $VMName `
                                -Path $($Disk.Path + "\" + $Disk.Name + ".vhdx")
        }
    
        $i = 2
        # foreach additional network adapters
        Foreach ($NetAdapter in $NICs){
            # add the NIC
            Add-VMNetworkAdapter -VMName $VMName -SwitchName $NetAdapter.VMSwitch -Name "Network Adapter $i"
        
            $ExtraNic = Get-VM -Name $VMName | Get-VMNetworkAdapter -Name "Network Adapter $i" 
            # Configure the NIC regarding the option
            if ($NetAdapter.VLAN -gt 0){$ExtraNic | Set-VMNetworkAdapterVLAN -Access -VlanId $NetAdapter.VLAN}
            else{$ExtraNic | Set-VMNetworkAdapterVLAN -untagged}
    
            if ($NetAdapter.VMQ){$ExtraNic | Set-VMNetworkAdapter -VmqWeight 100}
            Else {$ExtraNic | Set-VMNetworkAdapter -VmqWeight 0}
    
            if ($NetAdapter.IPSecOffload){$ExtraNic | Set-VMNetworkAdapter -IPsecOffloadMaximumSecurityAssociation 512}
            Else {$ExtraNic | Set-VMNetworkAdapter -IPsecOffloadMaximumSecurityAssociation 0}
    
            if ($NetAdapter.SRIOV){$ExtraNic | Set-VMNetworkAdapter -IovQueuePairsRequested 1 -IovInterruptModeration Default -IovWeight 100}
            Else{$ExtraNic | Set-VMNetworkAdapter -IovWeight 0}
    
            if ($NetAdapter.MacSpoofing){$ExtraNic | Set-VMNetworkAdapter -MacAddressSpoofing on}
            Else {$ExtraNic | Set-VMNetworkAdapter -MacAddressSpoofing off}
    
            if ($NetAdapter.DHCPGuard){$ExtraNic | Set-VMNetworkAdapter -DHCPGuard on}
            Else {$ExtraNic | Set-VMNetworkAdapter -DHCPGuard off}
    
            if ($NetAdapter.RouterGuard){$ExtraNic | Set-VMNetworkAdapter -RouterGuard on}
            Else {$ExtraNic | Set-VMNetworkAdapter -RouterGuard off}
    
            if ($NetAdapter.NicTeaming){$ExtraNic | Set-VMNetworkAdapter -AllowTeaming on}
            Else {$ExtraNic | Set-VMNetworkAdapter -AllowTeaming off}
    
            $i++
            }
    
    }
    
    
    
    
    }
    
    New-CustomHyperV
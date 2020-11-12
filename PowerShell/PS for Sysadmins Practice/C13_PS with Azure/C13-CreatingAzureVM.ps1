<# 
~ Building an Azure VM along with dependencies:
    1. Resource Group
    2. Virtual Stack
    3. Storage Account
    4. Public IP Address
    5. Network Interface
    6. OS Image

#>

# 1. Resource Group #########################################
    # Find locations
    Get-AzLocation
    # Create new resource group and set its location
    New-AzResourceGroup -Name 'PowerShellForSysAdmins-RG' -Location 'West US'

# 2. Creating Virtual Stack #########################################
    # Subnet: New-AzVirtualNetworkSubnetConfig
    $newSubnetParams = @{
        'Name' = 'PowerShellForSysAdmins-Subnet'
        'AddressPrefix' = '10.0.1.0/24'
    }
    $subnet = New-AzVirtualNetworkSubnetConfig @newSubnetParams
    # Virtual Network: New-AzVirtualNetwork
    $newVNetParams = @{
        'Name' = 'PowerShellForSysAdmins-vNet'
        'ResourceGroupName' = 'PowerShellForSysAdmins-RG'
        'Location' = 'West US'
        'AddressPrefix' = '10.0.0.0/16'
    }
    $vNet = New-AzVirtualNetwork @newVNetParams -Subnet $subnet
    # Public IP Address: New-AzPublicIPAddress
    $newPublicIpParams = @{
        'Name' = 'PowerShellForSysAdmins-PubIp'
        'ResourceGroupName' = 'PowerShellForSysAdmins-RG'
        'AllocationMethod' = 'Dynamic' ## Dynamic or Static
        'Location' = 'West US'
    }
    $publicIp = New-AzPublicIpAddress @newPublicIpParams
    # Virtual Network Adapter (vNIC): New-AzNetworkInterface
    $newVNicParams = @{
        'Name' = 'PowerShellForSysAdmins-vNIC'
        'ResourceGroupName' = 'PowerShellForSysAdmins-RG'
        'Location' = 'West US'
        'SubnetId' = $vNet.Subnets[0].Id
        'PublicIpAddressId' = $publicIp.Id
    }
    $vNic = New-AzNetworkInterface @newVNicParams

# 3. Storage Account #########################################
    # Create storage to store VMs
    $newStorageAcctParams = @{
        # ! NOTE: 'Name' MUST BE UNIQUE IN ALLLL OF AZURE - cannot be unique with just my resourcegroups, subscriptions, etc.
        'Name' = 'p45llsafd834hdf17283'
        'ResourceGroupName' = 'PowerShellForSysAdmins-RG'
        'Type' = 'Standard_LRS'
        'Location' = 'West US'
    }
    $storageAccount = New-AzStorageAccount @newStorageAcctParams

# 4. Creating the OS Image #########################################
    # Obtain all vm sizes
    Get-AzVMSize -Location 'West US'
    # Defining OS Configuration Settings: New-AzVMConfig
    $newConfigParams = @{
        'VMName' = 'PowerShellForSysAdmins-VM'
        'VMSize' = 'Standard_B2s'
    }
        # @ CHECK IF VM SIZE IS AVAILABLE!! ###########
        Get-AzComputeResourceSku | Where-Object {$_.Locations -icontains "eastus" -and $_.ResourceType.Contains("virtualMachines")}
        Get-AzComputeResourceSku | Where-Object {$_.Locations -icontains "eastus" -and $_.ResourceType.Contains("virtualMachines") -and $_.name -like "*B1ms*"}
    $vmConfig = New-AzVMConfig @newConfigParams
    # Create OS object: Set-AzVMOperatingSystem
    $newVmOsParams = @{
        'Windows' = $true
        'ComputerName' = 'Automate-VM'
        'Credential' = (Get-Credential -Message 'Type the name and password of the local administrator account.')
        'EnableAutoUpdate' = $true
        'VM' = $vmConfig
    }
    $vm = Set-AzVMOperatingSystem @newVmOsParams

    # Finding all Azure VM publishers
    Get-AzVMImagePublisher -Location "West US" | Where-Object {$_.PublisherName -like "*WindowsServer*"} | Select-Object PublisherName
        # RESULT: all publisher names (Windows Server is MicrosoftWindowsServer)
    # Find all VM offers
    Get-AzVMImageOffer -Location "West US" -PublisherName "MicrosoftWindowsServer" | Select-Object Offer   
        # RESULT: all offers by the publisher (shows all Windows Server versions)
    # Find all SKUs
    Get-AzVMImageSku -Location "West US" -PublisherName "MicrosoftWindowsServer" -Offer "Windowsserver" 
    # Find SKUs availble to that location, note the "NotAvailableForSubscription"
    Get-AzComputeResourceSku | Where-Object {$_.Locations -icontains "westus"}
    Get-AzComputeResourceSku | Where-Object {$_.Locations.Contains("westus") -and $_.ResourceType.Contains("virtualMachines") -and $_.Name.Contains("v3")} | Format-Custom
    # Find all versions of SKU
    Get-AzVMImage -Location "West US" -PublisherName "MicrosoftWindowsServer" -Offer "windowsserver" -Skus "2016-Datacenter"
    # @ Source: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/cli-ps-findimage

    # Create VM Offer
    $Offer = Get-AzVMImageOffer -Location 'West US' –PublisherName 'MicrosoftWindowsServer' | Where-Object { $_.Offer -eq 'WindowsServer' }
    # Create source image: Set-AzVMSourceImage
    $newSourceImageParams = @{
        'PublisherName' = 'MicrosoftWindowsServer'
        'Version' = 'latest'
        'Skus' = '2016-Datacenter'
        'VM' = $vm
        'Offer' = $offer.Offer
    }
    $vm = Set-AzVMSourceImage @newSourceImageParams
    # Assign Image to VM Object: Set-AzVMOSDisk
    $osDiskName = 'PowerShellForSysAdmins-Disk'
    $osDiskUri = '{0}vhds/PowerShellForSysAdmins-VM{1}.vhd' -f $storageAccount.PrimaryEndpoints.Blob.ToString(), $osDiskName
    $vm = Set-AzVMOSDisk -Name OSDisk -CreateOption 'fromImage' -VM $vm -VhdUri $osDiskUri
    # Attach to vNIC
    $vm = Add-AzVMNetworkInterface -VM $vm -Id $vNic.Id
    # @ CREATE VM (billing starts here)
    New-AzVM -VM $vm -ResourceGroupName 'PowerShellForSysAdmins-RG' -Location 'West US'

    # Verify 
    Get-AzVm -ResourceGroupName 'PowerShellForSysAdmins-RG' -Name PowerShellForSysAdmins-VM
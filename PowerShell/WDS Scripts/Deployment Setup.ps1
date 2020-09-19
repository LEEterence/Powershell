## Beginning
Install-Windowsfeature -Name WDS -includemanagementools 
# Initializing WDS server
$wdsUtilResults = wdsutil /initialize-server /remInst:"E:\RemoteInstall"
$wdsUtilResults | select -last 1

# MOUNT the ISO first 
$InstallGroupName = "Windows 10"
$InstallSource = "F:\sources\install.wim"
$BootSource = "F:\sources\boot.wim"
New-WdsInstallImageGroup -Name $InstallGroupName
    # Get-WindowsImage obtains all images at source
Get-WindowsImage -imagePath $InstallSource | select Imagename
Import-WdsBootImage -Path $BootSource
    # Image name obtained from get-windowsimage
$imageName = 'Windows 10 Enterprise Evaluation'
Import-WdsInstallImage -ImageGroup $InstallGroupName -Path $InstallSource -ImageName $imageName
## We can test PXE boot at this point ####

## Deployment Share Creation
New-Item -Path "E:\DeploymentShare" -ItemType directory
New-SmbShare -Name "DeploymentShare$" -Path "E:\DeploymentShare" -FullAccess Administrators
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
new-PSDrive -Name "DS001" -PSProvider "MDTProvider" -Root "E:\DeploymentShare" -Description "MDT Deployment Share" -NetworkPath "\\SRV02\DeploymentShare$" -Verbose | add-MDTPersistentDrive -Verbose

## Importing OS
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
New-PSDrive -Name "DS001" -PSProvider MDTProvider -Root "E:\DeploymentShare"
import-mdtoperatingsystem -path "DS001:\Operating Systems" -SourcePath "F:\" -DestinationFolder "Windows 10 Enterprise Evaluation x64" -Verbose

## Task Sequence Creation 
# Task Sequence requires OS to be imported first, specify password
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
New-PSDrive -Name "DS001" -PSProvider MDTProvider -Root "E:\DeploymentShare"
import-mdttasksequence -path "DS001:\Task Sequences" -Name "Windows 10 Enterprise Deployment" -Template "Client.xml" -Comments "" -ID "Win10" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows 10 Enterprise Evaluation" -FullName "Windows User" -OrgName "Marvel Comics" -HomePage "about:blank" -AdminPassword "Password1" -Verbose
<#
NOTE: must delete WDS boot and install image each time a change is made in the deployment share. Must add the boot image back each time in WDS!
NOTE 2: uncheck x86 in Deployment Tools to speed up update, disable iso for x86 and x64 in Deploymentshare properties (deployment tools) since we are using a .wim not .iso
NOTE 3: Only Boot Image needs to be added back into WDS, Install image is handled by MDT?
#>
## Updating Deployment Share
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
New-PSDrive -Name "DS001" -PSProvider MDTProvider -Root "E:\DeploymentShare"
update-MDTDeploymentShare -path "DS001:" -Verbose

# Edit Customsettings.ini and bootstrap.ini
# Note: customsettings.ini is on the main page and the bootstrap must be opened separately

<# 
Troubleshooting:

Enable "everyone" sharing permissions in the deployment share

Issue: Cannot access domain after login
Solution: Check DHCP option for DNS servers has been created 

Issue: Connection failed to deployment Share
Solution: must REGENERATE fully when updating deployment share (if customsettings/boot are modified) - do not optimize

Issue: cannot create Catalogue file for Windows Image
Solution: MUST USE ADK 1809, x64 not support properly in some later versions

Issue: importing install.wim into WDS leads to "Invalid Data Issue"
Solution: Refresh WDS server

Check "Windows Deployment Settings for MDT Zero Touch files"
#>

<#
wim vs ISO
 - both can be used to deploy devices, but wims are modifiable and work better within MS environment since they are file-based (less overhead to opening files)
 - ISOs are more portable than .wim
 - must use WinPE to convert wim to iso

#>



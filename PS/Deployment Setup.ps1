## Deployment Share Creation
New-Item -Path "E:\DeploymentShare" -ItemType directory
New-SmbShare -Name "DeploymentShare$" -Path "E:\DeploymentShare" -FullAccess Administrators
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
new-PSDrive -Name "DS001" -PSProvider "MDTProvider" -Root "E:\DeploymentShare" -Description "MDT Deployment Share" -NetworkPath "\\SRV02\DeploymentShare$" -Verbose | add-MDTPersistentDrive -Verbose

## Task Sequence Creation 
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
New-PSDrive -Name "DS001" -PSProvider MDTProvider -Root "E:\DeploymentShare"
import-mdttasksequence -path "DS001:\Task Sequences" -Name "Windows 10 Enterprise Deployment" -Template "Client.xml" -Comments "" -ID "Win10" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows 10 Enterprise Evaluation" -FullName "Windows User" -OrgName "Marvel Comics" -HomePage "about:blank" -AdminPassword "Password1" -Verbose

## Updating Deployment Share
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
New-PSDrive -Name "DS001" -PSProvider MDTProvider -Root "E:\DeploymentShare"
update-MDTDeploymentShare -path "DS001:" -Verbose

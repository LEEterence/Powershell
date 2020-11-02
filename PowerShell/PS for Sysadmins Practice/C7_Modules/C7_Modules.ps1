<# 
All about modules listing
#>


# List of all INSTALLED & imported modules
Get-Module
Get-Module -Name "Microsoft.PowerShell.Security"
# Getting exported commands from Installed modules
Get-Command -Module "Microsoft.PowerShell.Security"

# Finds a module from the Repositories (by default is PowerShell Gallery)
Find-Module -Name PowerShellGet
# Find based on description
Find-Module -Filter "OU"

# Install Module
Find-Module -Name PowerShellGet | Install-Module

# Uninstall Module
Uninstall-Module -Name PowerShellGet

#@ Creating Module Template
# Create Folder within one of the Default Module Paths (in this case - All users)
mkdir 'C:\Program Files\WindowsPowerShell\Modules\Software'
# create a .psm1
new-item  "E:\_Git\Powershell\PowerShell\AD Users\New-ADTestLab\New-ADTestLab.psm1"
Add-Content 'C:\Program Files\WindowsPowerShell\Modules\Software\Software.psm1'
# create a .psd1
New-ModuleManifest -Path 'C:\Program Files\WindowsPowerShell\Modules\Software\Software.psd1' `
-Author 'Terence Lee' `
-RootModule Software.psm1  `
-Description 'Module Practice: This module helps in deploying software.'
# Verification
Get-Module -Name Software -List
<# 

Project: Working with AD CS using powershell 

#>


# Import additional capabilities
Import-Module PKI

# Find PS-Providers and PS-Drives
Get-PSProvider
Get-PSDrive

# Accessing the PS Drive for the certificate store (faster than adding MMC Snap-ins)
Set-Location Cert:\LocalMachine
# Note usually we will be accessing computer certificates instead of user or service account certificates
# Obtain thumbprints and subjects by accessing directories inside LocalMachine or CurrentUser

# Obtain all properties
GET-CHILDITEM –RECURSE | FORMAT-LIST –PROPERTY *
GET-CHILDITEM –RECURSE | FORMAT-LIST –PROPERTY * | OUT-FILE –PATH “C:\FILE\OUTPUT.TXT”

# Obtain certificate expiring in a certain number of days
GET-CHILDITEM –RECURSE –EXPIRINGINDAYS 1000
# Obtain certificate expiring AT A CERTAIN DATE


# Export Certificate - Find the Certificate thumbprint first 
$selectedcert = (Get-ChildItem –Path cert:\LocalMachine\My\DE53B1272E43C14545A448FB892F7C07A217A765)
Export-Certificate –Cert $selectedcert –FilePath c:\test\export.cer
# Import Certificate (after moving the previous exported certificate to destination machine)
Get-ChildItem C:\import\export.cer Import-Certificate -CertStoreLocation Cert:\LocalMachine\My

# Remove Certificate
Remove-Item –Path Cert:\LocalMachine\My\DE53B1272E43C14545A448FB892F7C07A217A765


# Additional Filtering Techniques #####################################################
# Friendly Certificate Name
dir cert: -Recurse | Where-Object { $_.FriendlyName -like "*DigiCert*" }
# Thumbprint
# This will list any certificates that isn't valid after the 31 Dec 2018
dir cert: -Recurse | Where-Object { $_.Thumbprint -like "*0563B8630D62D75ABBC8AB1E4B*" }
#Expiry Date
dir cert: -Recurse | Where-Object { $_.NotAfter -lt (Get-Date 2018-12-31) }
#This will list any certificates that will expire the upcomming year, from now and one year ahead
dir cert: -Recurse | Where-Object { $_.NotAfter -gt (Get-Date) -and $_.NotAfter -lt (Get-Date).AddYears(1) }

<# 
Source:
https://docs.microsoft.com/en-ca/archive/blogs/scotts-it-blog/working-with-certificates-in-powershell 

Third-party CA powershell modules:
Install Instructions: https://www.pkisolutions.com/tools/pspki/
Download from:  https://www.powershellgallery.com/packages/PSPKI/3.4.2.0

#>
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

# Thumbprint

#Expiry Date

<# 
Source:
https://docs.microsoft.com/en-ca/archive/blogs/scotts-it-blog/working-with-certificates-in-powershell 

Third-party CA powershell modules:
Install Instructions: https://www.pkisolutions.com/tools/pspki/
Download from:  https://www.powershellgallery.com/packages/PSPKI/3.4.2.0

#>
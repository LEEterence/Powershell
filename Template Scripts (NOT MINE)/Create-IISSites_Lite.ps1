# The following code will create an IIS site and it associated Application Pool. 
# Please note that you will be required to run PS with elevated permissions. 
# Visit http://ifrahimblog.wordpress.com/2014/02/26/run-powershell-elevated-permissions-import-iis-module/ 

# set-executionpolicy unrestricted

$SiteFolderPath = "C:\WebSite"              # Website Folder
$SiteAppPool = "MyAppPool"                  # Application Pool Name
$SiteName = "MySite"                        # IIS Site Name
$SiteHostName = "www.MySite.com"            # Host Header

New-Item $SiteFolderPath -type Directory
Set-Content $SiteFolderPath\Default.htm "<h1>Hello IIS</h1>"
New-Item IIS:\AppPools\$SiteAppPool
New-Item IIS:\Sites\$SiteName -physicalPath $SiteFolderPath -bindings @{protocol="http";bindingInformation=":80:"+$SiteHostName}
Set-ItemProperty IIS:\Sites\$SiteName -name applicationPool -value $SiteAppPool

# Complete
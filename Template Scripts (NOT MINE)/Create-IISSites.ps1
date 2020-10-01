<# 
Source: https://4sysops.com/archives/create-iis-websites-with-powershell/

#>

<#
 .SYNOPSIS
     .
 .DESCRIPTION
     Creates a number of websites as well as folder structure and 
     default application pools under them. Also sets up bindings 
     for the newly created websites.
 .PARAMETER WebSiteName
     This is the site name you are going to create. It will be complemented
     by the site number if you are creating more than one site.
 .PARAMETER WebSitesNumber
     Specifies the number of websites that will be created.  
 .PARAMETER RootFSFolder
     Specifies a root folder where all the websites will be created.
 .PARAMETER Hostheaders
     Specifies host headers that will be added to each website.
     Use quotes for this parameter to avoid errors. 
 .PARAMETER EnviromentName
     Specifies an environment name for the site name. If you omit this,
     you will create a site without an environment name.
 .PARAMETER DefaultAppPoolName
     Specifies default name for application pool. If omitted, the 
     WebSiteName will be used as the default app pool name.
 .PARAMETER Help
     Displays the help screen.
     
 .EXAMPLE
     C:\PS>.\createIISSites.ps1 -WebSiteName app -WebSitesNumber 3 -RootFSFolder c:\webs -EnviromentName lab -DefaultAppPoolName platformsc -Hostheaders ".contentexpress.lan, .enservio.com"
     
     Creates 3 IIS sites with the names app1lab, app2lab, app3lab, root folder c:\web   
     and subfolders for each site like c:\webs\app1lab, c:\webs\app2lab etc., 
     default app pools for those sites with the names platformsc1, platformsc2 etc.,
     and hostheaders for each site with the names app1.contentexpress.lan,  
     app2.contentexpress.lan, app2.enservio.com etc.
 
 .NOTES
     Author: Alex Chaika
     Date:   May 16, 2016
     test commment    
 #>
 
 
 [CmdletBinding()]
 Param(
   [Parameter(Mandatory=$True)]
    [string]$WebSiteName,
   [Parameter(Mandatory=$True)]
    [int]$WebSitesNumber,
   [Parameter(Mandatory=$True)]
    [string]$RootFSFolder,
   [Parameter(Mandatory=$False)]
    [string]$Hostheaders,
   [Parameter(Mandatory=$False)]
    [string]$EnviromentName,
   [Parameter(Mandatory=$False)]
    [string]$DefaultAppPoolName
   
 )
 
 if(-not $DefaultAppPoolName){
 $DefaultAppPoolName = $WebSiteName}
 
 import-module WebAdministration
 Function CreateAppPool {
         Param([string] $appPoolName)
 
         if(Test-Path ("IIS:\AppPools\" + $appPoolName)) {
             Write-Host "The App Pool $appPoolName already exists" -ForegroundColor Yellow
             return
         }
 
         $appPool = New-WebAppPool -Name $appPoolName
     }
 
 function CreatePhysicalPath {
     Param([string] $fpath)
     
     if(Test-path $fpath) {
         Write-Host "The folder $fpath already exists" -ForegroundColor Yellow
         return
         }
     else{
         New-Item -ItemType directory -Path $fpath -Force
        }
 }
 
 Function SetupBindings {
 Param([string] $hostheaders)
 $charCount = ($hostheaders.ToCharArray() | Where-Object {$_ -eq ','} | Measure-Object).Count + 1
 $option = [System.StringSplitOptions]::RemoveEmptyEntries
 $hhs=$hostheaders.Split(',',$charCount,$option)
 
 #@ Might change to:  get-Website | ? {$_.Name -eq $Websitename} ###
 get-Website | Where-Object {$_.Name -ne "Default Web Site"} | ForEach-Object {
     foreach ($h in $hhs){
        $header=$_.Name + $h.Trim() 
        New-WebBinding -Name $_.Name -HostHeader $header -IP "*" -Port 80 -Protocol http
        }
     }
 Get-WebBinding | Where-Object {($_.bindingInformation).Length -eq 5} | Remove-WebBinding
 }
 
 
 for ($i=1;$i -le $WebSitesNumber;$i++) {
      $fpath = $RootFSFolder + "\" + $WebSiteName + $i + $EnviromentName + "\" + $DefaultAppPoolName + $i + $EnviromentName
      CreatePhysicalPath $fpath
      $appPoolName = $DefaultAppPoolName + $i + $EnviromentName
      $GenWebSiteName = $WebSiteName +$i + $EnviromentName
      CreateAppPool $appPoolName
      If(!(Test-Path "IIS:\Sites\$GenWebSiteName")){
          New-Website -Name $GenWebSiteName -PhysicalPath $fpath  -ApplicationPool $appPoolName
          
          }
      else {
          Write-Host "The IIS site $GenWebSiteName already exists" -ForegroundColor Yellow
          exit
      }
 }
 
 SetupBindings $Hostheaders
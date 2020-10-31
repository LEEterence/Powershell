
# Prerequisites - note MUST install-module as admin => Locate Az modules under C:\users\administrator\documents\PowerShell\Modules => Copy and paste into All users directory at C:\Program Files\PowerShell\Modules
Import-Module Az
#Requires -Module Az

# Enabling authentication
Connect-AzAccount
    # Find information for subscription (essential for later commands)
    Get-AzSubscription 
    # Subscription ID
    (Get-AzSubscription -SubscriptionName "Azure for Students").Id
    #Tenant ID
    (Get-AzSubscription -SubscriptionName "Azure for Students").TenantId
    # Select another subscription
    Get-AzContext -ListAvailable
    Set-AzContext -Name "Azure for Students"

# Creating service account to automate authentication
# NOTE: MUST be global admin of the subscription (Azure for Students doesn't give global admin)
$securepass = ConvertTo-SecureString -AsPlainText -Force "Password1"
$myApp = New-AzADApplication -DisplayName AppForServicePrincipal -IdentifierUris 'http://chapter13.com' -Password $securepass
    # IdentifierURLs is custom specified

# Create the new service principal
$sp = New-AzADServicePrincipal -ApplicationId $myApp.ApplicationId







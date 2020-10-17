#Gets available websites
Get-website
#Obtains authentication modes
Get-IISConfigAttributeValue -ConfigElement "system.webServer/security/access" -AttributeName sslFlags

# Grabs Certificate info with the following template name
$templateName = 'Terence-10 Web Server'
Get-ChildItem 'Cert:\LocalMachine\My' | Where-Object{ $_.Extensions | Where-Object{ ($_.Oid.FriendlyName -eq 'Certificate Template Information') -and ($_.Format(0) -match $templateName) }} | Select FriendlyName,Subject,EnhancedKeyUsageList,Issuer

# Obtains SSL Bindings
Get-ChildItem -Path IIS:SSLBindings | ForEach-Object -Process `
{
    if ($_.Sites)
    {
        $certificate = Get-ChildItem -Path CERT:\LocalMachine\My |
            Where-Object -Property Thumbprint -EQ -Value $_.Thumbprint

        [PsCustomObject]@{
            Sites                        = $_.Sites.Value
            CertificateFriendlyName      = $certificate.FriendlyName
            CertificateDnsNameList       = $certificate.DnsNameList
            CertificateNotAfter          = $certificate.NotAfter
            CertificateIssuer            = $certificate.Issuer
        }
    }
}

# Obtains Virtual Directory
Get-WebVirtualDirectory
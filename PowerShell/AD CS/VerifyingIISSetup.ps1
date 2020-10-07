# Grabs Certificate info with the following template name from Web Server
$templateName = 'Terence-10 Web Server'
Get-ChildItem 'Cert:\LocalMachine\My' | Where-Object{ $_.Extensions | Where-Object{ ($_.Oid.FriendlyName -eq 'Certificate Template Information') -and ($_.Format(0) -match $templateName) }} | Select FriendlyName,Subject,EnhancedKeyUsageList,Issuer

# Obtains SSL binding if my websites have thumbrpints from Web servers personal drive matching thumbprints for the certificate currently binded to HTTPS
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

# Obtains user virtual directory
Get-WebVirtualDirectory

# Obtains a list only the enabled authentication types
Get-WebConfiguration system.webServer/security/authentication/* -Recurse | where {$_.enabled -eq $true} | format-table
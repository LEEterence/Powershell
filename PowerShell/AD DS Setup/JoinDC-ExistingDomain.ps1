	
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Install-ADDSDomainController -DomainName "domain.tld" -InstallDns:$true -Credential (Get-Credential "DOMAIN\administratreur")
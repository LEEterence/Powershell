## OPTIONAL - Join to Domain (Specify “-Computername” if adding multiple computers remotely
$DomainName = "terence.local"   # ex. dmit2023.local
$DomainCred = "terence.local\administrator"    # ex. dmit2023.local\administrator

Add-Computer -DomainName $DomainName -Restart -DomainCredential $DomainCred -verbose

# Basic add computer to domain
Add-Computer -DomainName Domain01 -Restart
# Adding to workgroup
Add-Computer -WorkgroupName WORKGROUP
# Adding local computer to domain
Add-Computer -DomainName Domain01 -Server Domain01\DC01 -PassThru -Verbose
# Adding to specific OU
Add-Computer -DomainName Domain02 -OUPath "OU=testOU,DC=domain,DC=Domain,DC=com"
# Add group of PCs to domain, specifying join & unjoin credentials
Add-Computer -ComputerName Server01, Server02, localhost -DomainName Domain02 -LocalCredential Domain01\User01 -UnjoinDomainCredential Domain01\Admin01 -Credential Domain02\Admin01 -Restart
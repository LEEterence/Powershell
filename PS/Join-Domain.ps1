## OPTIONAL - Join to Domain (Specify “-Computername” if adding multiple computers remotely
$DomainName = "terence.local"   # ex. dmit2023.local
$DomainCred = "terence.local\administrator"    # ex. dmit2023.local\administrator

Add-Computer -DomainName $DomainName -Restart -DomainCredential $DomainCred -verbose
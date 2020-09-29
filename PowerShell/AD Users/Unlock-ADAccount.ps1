<# 
~ Administration

#>

# Reset password using distringuished name
Set-ADAccountPassword -Identity 'CN=Test User,OU=TestOU,DC=TestDC,DC=com' -reset -newPassword(Convertto-Securestring -Asplaintext -force "P@ssword1")

# Change password
Set-ADAccountPassword -Identity 'Test User' -oldPassword (Convertto-SecureString -Asplaintext -Force "Password1") -newPassword(Convertto-Securestring -Asplaintext -force "P@ssword1")
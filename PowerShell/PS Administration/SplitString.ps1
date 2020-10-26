<# 
~ Using split method
#>

# Grab parent OU using Split MEthod (lowest, most direct OU)
$DN= "ou=edmonton users,ou=Department Users,dc=sleepygeeks,dc=com"
$dn.Split('OU=|,OU=')[1]
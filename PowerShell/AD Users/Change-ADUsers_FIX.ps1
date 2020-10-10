<# 
~ Script changes based on Display Name. Distinguished name is required since Display name isn't unique. 

@ This fixed a weird csv error where all Users Display Names were commas but everything else was fine... Check my script again or csv.
#>

# For only users within a specific OU, didn't want to mess with other groups!
$Users = Get-ADUser -SearchBase "ou=Departments,dc=enron,dc=com" -Filter {(GivenName -Like "*") -And (Surname -Like "*")} -Properties DisplayName | Select DisplayName, GivenName, Surname, Name, DistinguishedName
ForEach ($User In $Users)
{
    $DN = $User.DistinguishedName
    $First = $User.GivenName
    $Last = $User.Surname
    $CN = $User.Name
    $Display = $User.DisplayName
    $NewName = "$First $Last"
    If ($Display -ne $NewName) {Set-ADUser -Identity $DN -DisplayName $NewName}
    If ($CN -ne $NewName) {Rename-ADObject -Identity $DN -NewName $NewName}
}
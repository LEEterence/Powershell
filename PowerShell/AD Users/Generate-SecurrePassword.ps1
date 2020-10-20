# Generating secure random password using System.Web.Security.Membership object
Add-Type -AssemblyName 'System.Web'
# Generate a password with a min of 20 characters and max of 32
$password = [System.Web.Security.Membership]::GeneratePassword(
    (Get-Random Minimum 20 -Maximum 32), 3)
$secPw = ConvertTo-SecureString -String $password -AsPlainText -Force
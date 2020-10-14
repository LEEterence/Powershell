<# 
~ Remote scripting examples and information

#>
# Local Variables
$folderLocation = "C:\testfolder"
Invoke-Command -ComputerName Desktop01 -ScriptBlock {Write-Host "Local variable with ArgumentList: $folderLocation" -ForegroundColor Cyan} 
    # Won't work because remote computer doesn't have this folder location!!!!

# Fixing with Argumentlist 
$folderLocation = "C:\testfolder"
Invoke-Command -ComputerName Desktop01 -ScriptBlock {Write-Host "Local variable with ArgumentList: $($args[0])" -ForegroundColor Cyan} -ArgumentList $folderLocation

# Fixing with Using 
$folderLocation = "C:\testfolder"
Invoke-Command -ComputerName Desktop01 -ScriptBlock {Write-Host "Local variable with Using: $using:folderlocation" -ForegroundColor Green} 
    # NOTE: this method may seem easier - but CANNOT USE WITH PESTER

# PS Sessions: more efficient b/c doesn't have to open and close a session each time,
# Create session
New-PSSession -ComputerName Desktop01
# Obtain session information to put in variable for reuse
Get-PSSession 
$session = Get-PSSession -Id 15   #or whatever identifying information)
# Invoke-Command with Session
Invoke-Command -Session $session -ScriptBlock {hostname}
    # Session will REMEMBER VARIABLES CREATED IN SCRIPTBLOCK (as long as current local PowerShell instance stays open)
    Invoke-Command -Session $session -ScriptBlock {$rememberMe = "Witness me!!"}
    Invoke-Command -Session $session -ScriptBlock {$rememberMe}
    # After the PSSession has been closed and reopened Running the following will result "Session state is disconnected error"
    $session = Get-PSSession -ComputerName Desktop01
    Invoke-Command -Session $session -ScriptBlock {$rememberMe}
# Access session
Enter-PSSession -Session $session 
# Disconnect Sessions
Get-PSSession | Disconnect-PSSession
# Remove Sessions
Get-PSSession | Remove-PSSession

# Interactive PS Sessions
Enter-Pssession -ComputerName Desktop01

# Double Hop problem: Entering PS session of a computer and then attempting to access resources of another remote computer in the initial PS session
    # Example: Enter-pssession into a web server and then attempting to access a resource from a file server in
# WORKAROUND: CredSSP - set the initial remote computer as client and the other remote computer as the server
# 1. Setup CredSSP on the client (initial computer)
    # Can use "-delegatecomputer *" to specify all computers but this is a security concern
Enable-WSManCredSSP -Role Client -DelegateComputer Desktop01
# 2. Setup CredSSP  on the server (second remote computer) 
    #@ Delegate Computer and Computer name have to be the same!
invoke-command -ComputerName Desktop01 -ScriptBlock {Enable-WSManCredSSP -Role Server}
# 3. Execution 
#@ NOTE: TAKES A LONG TIME
invoke-command -ComputerName Desktop01 -ScriptBlock {Get-ChildItem "\\rds01\C$"} -Authentication Credssp -Credential terence\tlee37
# 4. (OPTIONAL) Disable CredSSP afterwards
Disable-WSManCredSSP
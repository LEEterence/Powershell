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

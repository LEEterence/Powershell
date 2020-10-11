<# 
~ Similar to functions - packaged into a single executable unit
Scriptblocks are called upon LITERALLY
Must execute them, cannot simply call on the variable
#>

$testScript = {Write-Host "This is in a script block" -ForegroundColor Cyan}
    # Output: Write-Host "This is in a script block" -ForegroundColor Cyan
$testScript
# Executing the Ps Code with an Ampersand
& $testScript 

# Reminder: Comparison to a function (which doesn't require an ampersand to execute)
function TestScriptFunction{
    Param()
    Write-Host "`nThis is in a function" -ForegroundColor Yellow
} 
TestScriptFunction

# 
$filePath = E:\_Git\Powershell
Invoke-Command -ComputerName Master-01 -ScriptBlock {Write-Host "Find powershell files at $filepath"} -Credential .\administrator

$ScriptFilePath = C:\_POWERSHELL\Practice_Gethostname.ps1
Invoke-Command -ComputerName TL -ScriptBlock {Write-Host "Server path: " + $($args[0])} -ArgumentList $ScriptFilePath -Credential lee\administrator

$ScriptFilePath = "C:\Users\Administrator"
# First Method: can test with pester
#Invoke-Command -ComputerName win10-1 -ScriptBlock {Write-Host "Server path:  $($args[0])"} -ArgumentList $ScriptFilePath #-Credential lee\administrator

# Second Method: more readable than argument list BUT CANNOT TEST WITH PESTER
# Invoke-Command -ComputerName Win10-1 -ScriptBlock{Write-Host "Server path: $using:scriptfilepath"}

# Increasing interactivity
New-PSSession 
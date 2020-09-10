<#
    .Synopsis
        Menu system which loops through and only exits on "exit" option
    .DESCRIPTION
        Creating a menu system for DMIT1532. There are several options to 
        find more information about the local computer and the remote computer.
        Some of these include finding computername, creating a local user, 
        IP configuration, and testing connectivity.

    Written By: Terence Lee
    Date: 04/22/2019


    CREDITS:

    https://www.computerperformance.co.uk/powershell/test-path/
    https://www.computerperformance.co.uk/powershell/loops-do-while/
    https://www.gngrninja.com/script-ninja/2016/5/24/powershell-calculating-folder-sizes
    https://osric.com/chris/accidental-developer/2018/09/setting-a-static-ip-default-gateway-and-nameservers-via-powershell/
    https://stackoverflow.com/questions/26494744/powershell-folder-size-of-folders-without-listing-subdirectories/35981872
    https://www.virtualizationhowto.com/2016/09/change-default-gateway-powershell/
    https://osric.com/chris/accidental-developer/2018/09/setting-a-static-ip-default-gateway-and-nameservers-via-powershell/
    https://social.technet.microsoft.com/Forums/windowsserver/en-US/03afb508-12f2-4173-a94d-273dc7b848b4/how-to-stop-getting-prompted-to-quotconfirmquot?forum=winserverpowershell
    https://ridicurious.com/2018/11/14/4-ways-to-validate-ipaddress-in-powershell/
    https://social.technet.microsoft.com/Forums/azure/en-US/bff649e6-47d5-42c8-be2f-f32e3dfdf0d6/change-default-gateway-using-netipaddress-cmdlet?forum=winserverpowershell
    
    Alot of what I learned was from an online course:
    https://learning.oreilly.com/learning-paths/learning-path-powershell

#>

# Returns value 'local' or 'remote' depending if user 
# using local or remote computer
function UserPrompt 
{
    clear-host
    $userinput = Readhost("Local or remote host?")
    return $userinput
}

# Error handling for cases where an empty value is entered
# or whitespaces are entered
function ReadHost($userprompt)
{
    do{
        $string = read-host $userprompt
        if ([string]::IsNullOrWhiteSpace($string) -or [string]::IsNullOrEmpty($string))
        {
            Write-Host "ERROR: Cannot enter empty value" -ForegroundColor Red
        }
        else
        {
            $cmdQuit = 'N'
            return $string
        }
    }until($cmdQuit = 'N')
}

# The option selection menu
function MainMenu 
{
    write-host "`n==================================================================" -foregroundcolor cyan
    write-host "=                          MAIN MENU                             =" -foregroundcolor cyan
    write-host "==================================================================" -foregroundcolor cyan
    write-host "`nChoose your selection." -foregroundcolor cyan
    write-host "`t1. Report Computer Name and the OS Version 
    2. Report on Disk Space 
    3. Report on FolderSpace for Specified folder
    4. Create a folder and copy all text files from a specified folder on local machine
    5. Create a local user
    6. Stop or Start a Service based on it display name
    7. Set the IP address (on local host only)
    8. Test connectivity to a machine return True (active) or False (no response)
    9. Exit"
}

# Error handling - Checking if a remote host is available by 
# using cmdlet test-connection
function CheckRemote ($str)
{
    $str = "Not yet"
    do
    {
        $name = ReadHost("Enter remote computer name")
        write-host "Testing connection..." -ForegroundColor Green
        try
        {
            $connection = Test-Connection $name -Quiet
        }
        catch
        {
            break
        }
        if ($connection -eq $false)
        {
            Write-Host "Invalid computer name" -ForegroundColor Red 
            $str = ReadHost("Select again? (Y/N)")
        }
        elseif ($connection -eq $true)
        {
            write-host "Success!" -foregroundcolor yellow
            
            $str = 'n'
            return $name
        }
    }until ($str -eq 'n')
}

# Error handling to check if a folder is legitimate by testing
# the path using the cmdlet test-path. Outputs an error that 
# the folder path cannot be found. Used for option 3
function CheckPath ($sourceFolder)
{
    do
    {
        $sourceFolder = ReadHost ("Enter path of source folder")
        $realPath = Test-Path $sourceFolder 
        if ($realPath -eq  $true)
        {
            "Success!";$cmdQuit = 'n'
        }
        else
        {
            Write-Host "Source folder path cannot be found" -ForegroundColor Red
            $cmdQuit = ReadHost ("Select again? (Y/N)")
            return 'N'
        }
    }until($cmdQuit -eq 'N')
}


# For option 4 - error handling to determine if a created folder
# already exists and output an error noting the duplicate
function CheckCreateFolder ($createdFolder)
{
    $cmdQuit = 'Not Yet'
    $createdPath = Test-Path $createdFolder
    if ($createdPath -eq $false)
    {
        Write-Host "Success" -ForegroundColor Yellow
        $sourceFolder = ReadHost("Enter Source Folder path")
        $cmdQuitCheck2 = CheckSourceFolder($sourceFolder)
        if ($cmdQuitCheck2 -eq 'N')
        {
            return 'N'
            break
        }
        else
        {
            return $sourceFolder
        }
    } 
    else
    {
        Write-Host "ERROR: Duplicate folder name found" -ForegroundColor Red
    }
}
# For Option 4 - error handling that is a alternate version of
# earlier CheckPath
function CheckSourceFolder
{
    $sourcePath = Test-Path $sourceFolder
    if ($sourcePath -eq $true)
    {
        Write-Host "Success" -ForegroundColor Yellow
    }
    else
    {
        Write-Host "ERROR: Source folder path could not be found" -ForegroundColor Red
        return 'N'
    }
}

# For Option 5 - error handling to determine if a user exists already
# and output a corresponding error. Invoke-command is used because 
# I could not find a -computername parameter that could be used. The
# code is actually all part of the same -ScriptBlock because I found that 
# I was unable to run the command if the code was on the next line rather 
# than the same line.
function CheckUserExists($remote)
{
    try
    {
        Invoke-Command -ComputerName $remote -ScriptBlock {$username = Read-Host "Enter username"
            $userexists = Get-LocalUser | Where-Object {$_.Name -eq $username}
            if ([string]::IsNullOrWhiteSpace($username) -or [string]::IsNullOrEmpty($username))
            {
                Write-Host "ERROR: Cannot enter empty value" -ForegroundColor Red
            }
            elseif ( -not $userexists)
            {
                $password = Read-Host -AsSecureString -Prompt "Enter users password" 
                Write-Host "Success" -ForegroundColor Yellow
                New-LocalUser $username -Password $password -ErrorAction SilentlyContinue | Out-host
                $cmdQuit = 'N'
            }
            else
            {
                Write-host "Error: User already exists" -ForegroundColor Red
            }
        }
    }
    catch
    {
        return 'N' | Out-Null
    }
}

# For Option 6 - error handling to ensure user enters either the
# option to 'start' or 'stop' a service.
function CheckServiceAction($service)
{
    $serviceaction = ReadHost("Start or stop service?")
    if ($serviceaction -eq "Start")
    {
        Start-Service $service -ErrorAction Stop; $cmdQuit = "N"
        Get-Service $service
    }
    elseif ($serviceaction -eq "Stop")
    {
        Stop-Service $service -Force 
        Get-Service $service
    }
    else
    {
        "Error: Must enter start or stop"
    }
}

# The code for finding the folder size in option 3. 
# Checks for an empty/whitespace input and if the path is
# valid. Only used for local machine. Had to use invoke-command
# for use on remote computers.
function Option3
{
    
    do
    {
        $path = Read-Host "Enter path of folder"
        try
        {
            $FileExists = Test-Path $path
        }
        catch
        {
            Write-Host "ERROR: Cannot enter empty value" -ForegroundColor Red
            $cmdQuit = ReadHost("Select again? (Y/N)")
        }
        if ($FileExists -eq $true)
        {
            [Long]$actualSize = 0
            foreach ($item in (Get-ChildItem $path -recurse | Where {-not $_.PSIsContainer} | ForEach-Object {$_.FullName})) 
            {
                $actualSize += (Get-Item $item).length
            }

            write-host "Folder Size: " $actualSize "Bytes"
            $cmdQuit = "N"
        }
        else
        {
            Write-Host "ERROR: Folder path cannot be found" -ForegroundColor Red
            $cmdQuit = ReadHost("Select again? (Y/N)")
        }
    }until($cmdQuit -eq 'N')
    
}

# Code for option 4. Checks that the created folder isn't a duplicate
# then checks if the source folder path is legitimate. Also error
# handling done for empty/whitespace values 
function Option4
{
    do
    {
        $createdFolder = ReadHost("Enter New Folder Path")
        $sourceFolder = CheckCreateFolder($createdFolder)

        Write-Host $sourcefolder
        if ($sourceFolder -ne 'N' -and -not [string]::IsNullOrWhiteSpace($sourceFolder))
        {
            mkdir $createdFolder
            Copy-Item $sourceFolder\* -Destination $createdFolder -Recurse
            ls $createdFolder
            $cmdQuit = 'N'
        }
        else
        {
            $cmdQuit = ReadHost("Select again? (Y/N)") 
        }
    }until($cmdQuit -eq 'N')
}

# Code for option 6. Checks if the service can be found first.
# Then checks if user wants to start or stop the service. Error
# handling for whitespace/empty is done as well.
function Option6
{
    do
    {
        try
        {
            $service = ReadHost("Enter service")
            Get-Service $service -ErrorAction Stop | Out-Null 
            CheckServiceAction($service); $cmdQuit = 'N'
            Get-Service $service | Out-Host
        }
        catch
        {
            Write-Host "Service cannot be found." -ForegroundColor Red
            $cmdQuit = ReadHost("Select again? (Y/N)")
        }
    }until($cmdQuit -eq 'N')
}

# For option 7. Automation of the menu allowing using several options
# to configure IP details.
function IPMenu
{
    Write-Host "`nDefault interface is 'Ethernet0'.`n" -ForegroundColor Magenta
    Write-host '1. Change IP Address' 
    Write-host '2. Change Subnet Mask' 
    Write-host '3. Change Default Router' 
    Write-host '4. Change DNS Server' 
    Write-host '5. Exit'
}

# For option 7. For the bonus marks, checks if the IP address entered 
# is valid and validates against non-numeric characters and numeric 
# values outside the allowed octet range.
function ReadHost-IPAddress($userprompt)
{
    $string = ReadHost($userprompt)
    try
    {
        [ipaddress] $string | Out-Null
        return $string
    }
    catch
    {
        Write-Host "ERROR: IP Address must be numeric characters and each octet must be within a range of 0-255" -ForegroundColor Red
    }
}

# For Option 7. The code for changing the IP address details. I found that 
# it was easiest to create a new net ip address each time. I would then get 
# the current IP details for as many necessary components and include them 
# as part of the configruration. For example, before default gateway is changed 
# by the user, I get the details for the IP address and mask. Then remove the 
# interface and recreate it using the changed values along with unchanged. I also
# used Ethernet0 as the default interface as it was not specified.
function ChangeIPv4
{

    $mask = 24
    do
    {
        #gets the IP address for Ethernet0
        $GetIPv4 = Get-NetIPAddress | Where-Object {$_.InterfaceAlias -like "Ethernet0"} | Select-Object -Property "IPAddress" 
        $IPv4 = $GetIpv4.IPAddress

        IPMenu
        $userprompt = ReadHost("`nSelect from the menu")
        
        switch ($userprompt)
        {
            '1' 
            {
                try
                {
                    $GetMask = Get-NetIPAddress | Where-Object {$_.InterfaceAlias -like "Ethernet0"} | Select-Object -Property "PrefixLength"
                    $mask = $GetMask.PrefixLength

                    $ipv4 = ReadHost-IPAddress("Change IP Address")
                    Remove-NetIPAddress -InterfaceAlias "Ethernet0" -Confirm:$false 
                    New-NetIPAddress -InterfaceAlias "Ethernet0" -IPAddress $IPv4 -PrefixLength $mask
                    Get-NetIPAddress | Where-Object {$_.InterfaceAlias -like "Ethernet0"} | Select-Object -Property "IPAddress"
                }
                catch
                {
                    break
                } 
            }
            '2' 
            {
                $mask = ReadHost("Enter Subnet Mask (Prefix Length)")
                Remove-NetIPAddress -InterfaceAlias "Ethernet0" -Confirm:$false 
                New-NetIPAddress -InterfaceAlias "Ethernet0" -IPAddress $IPv4 -PrefixLength $mask -ErrorAction Continue
                Get-NetIPAddress | Where-Object {$_.InterfaceAlias -like "Ethernet0"} | Select-Object -Property "PrefixLength"
            } 
            '3' 
            {
                try
                {
                    $GetIPv4 = Get-NetIPAddress | Where-Object {$_.InterfaceAlias -like "Ethernet0"} | Select-Object -Property "IPAddress" 
                    $IPv4 = $GetIpv4.IPAddress
                    $GetMask = Get-NetIPAddress | Where-Object {$_.InterfaceAlias -like "Ethernet0"} | Select-Object -Property "PrefixLength"
                    $mask = $GetMask.PrefixLength
                
                    $default_gate = ReadHost-IPAddress("Enter Default Gateway")
                    Remove-NetIPAddress -InterfaceAlias "Ethernet0" -Confirm:$false 
                    New-NetIPAddress -InterfaceAlias "Ethernet0" -IPAddress $IPv4 -PrefixLength $mask -DefaultGateway $default_gate -ErrorAction SilentlyContinue
                    Get-NetIPAddress | Where-Object {$_.InterfaceAlias -like "Ethernet0"} | Select-Object -Property "PrefixLength"
                }
                catch
                {
                    break
                }
            }
            '4' 
            {
                try
                {
                    $dns = ReadHost-IPAddress("Enter DNS Server Address")
                    Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses $dns
                }
                catch
                {
                    break
                }
            }
            '5' 
            {
                'Bye'
            }
            Default 
            {
                write-host 'ERROR: Must choose between 1-5' -ForegroundColor Red
            }
        }
    }until($userprompt -eq '5')
}


# MAIN CODE ####################################################
do 
{
    MainMenu
    $userinput = Read-Host "`n`tSelect 1-9"
    # Gets the OS version and computer name of local and remote computers
    if ($userinput -eq "1")
    {
        $cmdQuit = "Not Yet"
	    $OS = (Get-WmiObject Win32_OperatingSystem)
        do
        {
            $name = UserPrompt
            if ($name -eq "Local")
            {
                $version = $OS.version 
                "Computer name: " + $env:COMPUTERNAME + "`n" + "Operating System: " + $version  
                $cmdQuit = "N"
                  
            }
            elseif ($name -eq "Remote")
            {
                try
                {
                    $remote = CheckRemote($name)
                    $OS = (Get-WmiObject Win32_OperatingSystem -ComputerName $remote -ErrorAction stop).version 
                    $remote_name = (Get-WmiObject Win32_ComputerSystem -ComputerName $remote -ErrorAction Stop).name
                    "Computer name: " + $remote_name + "`n" + "Operating System: " + $OS
                    $cmdquit = "N"
                }
                catch
                {
                    Write-Host "ERROR: Computername cannot be found or empty" -ForegroundColor Red
                    $cmdQuit = "N"
                }
            }
            else
            {
                Write-Host "Enter 'Local' or 'Remote'" -ForegroundColor Red
                $cmdQuit = ReadHost("Select again? (Y/N)")
            }
        }
        until ($cmdQuit -eq "N")
    }
    # Gets the disk space for local or remote
    elseif ($userinput -eq "2")
    {
        $cmdQuit = "Not Yet"
        do
        {
            $name = UserPrompt
            if ($name -eq "local")
            {
                Get-WmiObject win32_logicaldisk | Select-Object DeviceID, FreeSpace, Size | Format-Table
                $cmdQuit = "N"
            }
            elseif ($name -eq "remote")
            {
                $remote = CheckRemote($name)

                Get-WmiObject Win32_LogicalDisk -ComputerName $remote | Select-Object DeviceID, FreeSpace, Size | Format-Table
                $cmdQuit = "N"
            }
            else
            {
                Write-Host "Enter 'Local' or 'Remote'" -ForegroundColor Red
                $cmdQuit = ReadHost("Select again? (Y/N)")
            } 
        }
        until ($cmdQuit -eq "N")
    }
    elseif ($userinput -eq "3")
    {
        $cmdQuit = "Not Yet"
        do
        {
            $name = UserPrompt
            if ($name -eq "local")
            {
                Option3
                $cmdQuit = "N"
            }
            elseif ($name -eq "remote")
            {
                $remote = CheckRemote
                if ([string]::IsNullOrWhiteSpace($remote) -or [string]::IsNullOrEmpty($remote))
                {
                    break
                }
                else
                {
                    Invoke-Command -ComputerName $remote -ScriptBlock{
                        do
                        {
                            $path = Read-Host "Enter path of folder"
                            try
                            {
                                $FileExists = Test-Path $path
                                if ($FileExists -eq $true)
                                {
                                    # This function gets each item from the directory I've selected
                                    # then it finds the length property of each item in the directory
                                    # and adds it to the actualSize variable
                                    [Long]$actualSize = 0
                                    foreach ($item in (Get-ChildItem $path -recurse | Where {-not $_.PSIsContainer} | ForEach-Object {$_.FullName})) 
                                    {
                                        $actualSize += (Get-Item $item).length
                                    }

                                    write-host "Folder Size: " $actualSize "Bytes"
                                    $cmdQuit = "N"
                                }
                                else
                                {
                                    Write-Host "ERROR: Folder path cannot be found" -ForegroundColor Red
                                    $cmdQuit = ReadHost("Select again? (Y/N)")
                                }
                            }
                            catch
                            {
                                Write-Host "ERROR: Cannot enter empty value" -ForegroundColor Red
                                $cmdQuit = Read-Host "Select again? (Y/N)"
                            }
                            
                        }until($cmdQuit -eq 'N')
                    }    
                    $cmdQuit = 'N'
                }
                
            }
            else
            {
                Write-Host "Enter 'Local' or 'Remote'" -ForegroundColor Red
                $cmdQuit = ReadHost("Select again? (Y/N)") 
            } 
        }until ($cmdQuit -eq "N")
    }
    elseif ($userinput -eq "4")
    {
        $cmdQuit = "Not Yet"
        do
        {
            $name = UserPrompt
            if ($name -eq "local")
            {
                Option4
                $cmdQuit = "N"
            }
            elseif ($name -eq "remote")
            {
                $remote = CheckRemote($name)
                if ([string]::IsNullOrWhiteSpace($remote) -or [string]::IsNullOrEmpty($remote))
                {
                    $cmdQuit = "N"
                    break
                }
                else
                {

                    Invoke-Command -ComputerName $remote -ScriptBlock{ 

                        # For Option 4 - error handling that is a alternate version of
                        # earlier CheckPath
                        $cmdcheck = "not yet"
                        do
                        {
                            try
                            {
                                $createdFolder = Read-Host "Enter full new folder path"
                                $createdPath = Test-Path $createdFolder
                                if ($createdPath -eq $false)
                                {
                                    Write-Host "Success" -ForegroundColor Yellow
                                    $sourceFolder = Read-Host "Enter full source folder path"
                                    $sourcePath = Test-Path $sourceFolder
                                    if ($sourcePath -eq $true)
                                    {
                                        Write-Host "Success" -ForegroundColor Yellow
                                    }
                                    else
                                    {
                                        Write-Host "ERROR: Source folder path could not be found" -ForegroundColor Red
                                        $cmdcheck1 = Read-Host "Select again? (Y/N)" 
                                    }
                                } 
                                else
                                {
                                    Write-Host "ERROR: Duplicate folder name found" -ForegroundColor Red
                                    $cmdcheck2 = Read-Host "Select again? (Y/N)" 

                                }
                                # Accounting for idea that user will not want to
                                # select again at either a failed creation or failed
                                # source folder
                                if($cmdcheck1 -eq 'N' -or $cmdcheck2 -eq 'N')
                                { 
                                    $cmdQuit = 'N'
                                }
                                elseif ($cmdcheck1 -ne 'N' -and -not [string]::IsNullOrWhiteSpace($sourceFolder))
                                {
                                    mkdir $createdFolder
                                    Copy-Item $sourceFolder\* -Destination $createdFolder -Recurse
                                    ls $createdFolder
                                    $cmdQuit = 'N'
                                }
                            }
                            catch
                            {
                                Write-Host "ERROR: Cannot enter empty value" -ForegroundColor Red
                                $cmdQuit = Read-Host "Select again? (Y/N)"
                            }
                        }until($cmdQuit -eq 'N')
                    }
                    $cmdQuit = "N"
                }
            }
            else
            {
                Write-Host "Enter 'Local' or 'Remote'" -ForegroundColor Red
                $cmdQuit = ReadHost("Select again? (Y/N)")
            } 
        }until($cmdQuit -eq "N")
    }
    elseif ($userinput -eq "5")
    {
        do
        {
            $name = UserPrompt
            if ($name -eq "local")
            {
                $username = ReadHost("Enter username")
               
                # Error handling - Checking for an existing user
                $check = Get-LocalUser $username -ErrorAction SilentlyContinue
                if ($check.Name -eq $username)
                {
                    Write-host "ERROR: User exists - creation failed" -ForegroundColor Red
                    break
                }
                else
                {
                    $password = Read-Host -AsSecureString -Prompt "Enter users password: "
                    # Had to use silentlycontinue to account for a password complexity error
                    New-LocalUser $username -Password $password -ErrorAction SilentlyContinue | Out-Host
                    Get-LocalUser $username
                }
                    
                
                $cmdQuit = "N"
            }
            elseif ($name -eq "remote")
            {
                $remote = CheckRemote($name)
                if ($remote -eq 'N')
                {
                    $cmdQuit = 'N'
                }
                else
                {
                    CheckUserExists($remote)
                    $cmdQuit = 'N'
                }
            }
            else
            {
                Write-Host "Enter 'Local' or 'Remote'" -ForegroundColor Red
                $cmdQuit = ReadHost("Select again? (Y/N)")
            } 
        }until($cmdQuit -eq 'N')
    }
    elseif ($userinput -eq "6")
    {
        $cmdQuit = "Not Yet"
        do
        {
            $name = UserPrompt
            if ($name -eq "local")
            {
                Option6
                $cmdQuit = "N"
            }
            elseif ($name -eq "remote")
            {
                $remote = CheckRemote($name)
                #remote returns nothing if the computer name is invalid
                if ([string]::IsNullOrWhiteSpace($remote) -or [string]::IsNullOrEmpty($remote))
                {
                    $cmdQuit = "N"
                    break
                }
                else
                {
                    Option6
                    $cmdQuit = "N"
                }
            }
            else
            {
                Write-Host "Enter 'Local' or 'Remote'" -ForegroundColor Red
                $cmdQuit = ReadHost("Select again? (Y/N)")
            } 
        }until($cmdQuit -eq "N")
    }
    elseif ($userinput -eq "7")
    {
        # All code is located in the function "ChangeIPv4"
        ChangeIPv4
    }
    elseif ($userinput -eq "8")
    {
        $name = ReadHost("Enter machine to test connectivity")
        Write-Host "Testing..." -ForegroundColor Green
        # Tests connection, if an pings succeed then returns true, otherwise if all pings fail then returns False
        $connection = Test-Connection $name -Quiet
        if ($connection -eq $true)
        {
            Write-Host "True - Active connection to $name"
        }
        else
        {
            Write-Host "False - No response to $name"
        }
    }
    # Exits the program
    elseif ($userinput -eq "9")
    {
        Write-Host "`nBye!" -BackgroundColor Black
    }
    else
    {
        Clear-Host
        Write-host "ERROR: Select an integer from 1-9" -foregroundcolor Red  
    }
}until($userinput -eq "9")
<# 
~ Adjust parameter for new user
Goals:
    Dynamically create a username for user based on the first name and last name
    Create and assign the user a random password
    Force the user to change their password at logon
    Set the department attribute based on the department given
    Assign the user an internal employee number

#>

# @ NOTE: BELOW IS NOT A COMMENT - it checks modules to see if I have ActiveDirectory module installed & imported

#Requires -Module ActiveDirectory
function NewUser{
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$FirstName,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$LastName,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Department,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int]$EmployeeNumber
    )

    try{
        
        # Obtain Domain (Must expand property since the object will be returned a PS object in hashtable format)
        $Domain = Get-ADDomain | Select-Object -ExpandProperty Forest
        # First try to create username
        $num = 1
        $username = "{0}.{1}$num" -f $FirstName,$LastName

        # Verifying if the username has been taken
        while (Get-ADUser -Filter "SamAccountName -eq '$userName'"){
            $username = "{0}.{1}$num" -f $FirstName,$LastName
            Write-Warning -Message "The username [$($userName)] already exists. Trying another..."
            Start-Sleep -Seconds 1
            $num++    
        }

        # Verifying users Department exists
        if(-not($ou = Get-ADOrganizationalUnit -Filter "Name -eq '$Department'")){
            throw "Organizational Unit [$Department] could not be found."
        #}elseif(-not(Get-ADGroup -Filter "Name -eq '$Department'")){
        #   throw "Group [$Department] could not be found."
        }else{
            #$ou = Get-ADOrganizationalUnit -Filter 'Name -eq "$Department"'
            # NOTE: UPN has to be unique in the forest, SamAccountName/username must be unique in domain, CN attribute/Name must be unique witth OU
            $Password = "Password1"
            $NewUserParameters = @{
                Name = $username
                SamAccountName = $username
                UserPrincipalName = $username + '@' + $Domain
                GivenName = $FirstName 
                Surname = $LastName
                Department = $Department
                AccountPassword = (ConvertTo-SecureString $Password -asplaintext -Force)
                Enabled = $true
                EmployeeNumber = $EmployeeNumber
                Path = $ou.distinguishedname
                #ChangePasswordAtLogon = $true
                #Confirm = $false
            }
            New-ADUser @NewUserParameters 
        }
    }
    catch{
        Write-Error -Message $_.Exception.Message
        #$ErrorVar = $_.Exception.Message
    }
}

## Username format: Terence.Lee1, Terence.Lee2
#$num = 1
#while (Get-ADUser -Filter "samAccountName -eq '$userName'"){
#    Write-Warning -Message "The username [$($userName)] already exists. Trying another..."
#    $username = "{0}.{1}$num" -f 'Terence','Lee'
#    Start-Sleep -Seconds 1
#    $num++    
#}
#
## Username format: tlee, telee, terlee, terelee.... 
## Start at 2 because this code is already assuming the user exists! THerefore, at least the first character of the first name has been used to create a username
#$i = 2
## -notlikek $FirstName stops the loop once all letters in the firstname have been exhausted
#while ((Get-ADUser -Filter "samAccountName -eq '$userName'") –and ($userName -notlike "$FirstName*")) {
#    Write-Warning -Message "The username [$($userName)] already exists. Trying another..."
#    $userName = '{0}{1}' -f $FirstName.Substring(0, $i), $LastName
#    Start-Sleep -Seconds 1
#    $i++
#}
#
## Generating secure random password using System.Web.Security.Membership object
#Add-Type -AssemblyName 'System.Web'
## Generate a password with a min of 20 characters and max of 32
#$password = [System.Web.Security.Membership]::GeneratePassword(
#    (Get-Random Minimum 20 -Maximum 32), 3)
#$secPw = ConvertTo-SecureString -String $password -AsPlainText -Force
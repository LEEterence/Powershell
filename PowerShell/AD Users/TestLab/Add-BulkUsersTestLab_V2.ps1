<# 
Add-BulkUsers_Lite_V2: 

Changes:
	Adjusted for CSVs requiring more details and with more AD property friendly names
	Ex) Previously CSV had firstname, lastname, username, etc. Now we have AD specific Name, GivenName, Surname, samAccount

	Also changed foreach to foreach method, which is more efficient than foreach statement (see v1 for example)
#>




# Import active directory module for running AD cmdlets
Install-Module ImportExcel
Import-Module ImportExcel
Import-Module activedirectory

#Requires -Module ImportExcel
#Requires -Module ActiveDirectory

#@ Adjust where lcation of csv file is
$Filelocation = "C:\Users\Administrator\Desktop\Full User Sheet.xlsx"  # Ex) C:\Users\Administrators\desktop\bulk_users.csv

#Store the data from Filelocation into the $ADUsers variable
$ADUsers = Import-Excel $Filelocation -WorksheetName Edmonton

#Loop through each row containing user details in the CSV file 
#@ NOTE: Foreach method doesn't work for creating New Groups OR OUs
$ADusers.foreach({
    # Obtain Domain
    $Domain = Get-ADDomain | Select-Object -ExpandProperty Forest

    # First try to create username
    $num = 1
    $SamAccountName = "{0}.{1}$num" -f $_.GivenName,$_.Surname
    # Verifying if the username has been taken
    while (Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'"){
        $SamAccountName = "{0}.{1}$num" -f $_.GivenName,$_.Surname
        Write-Warning -Message "The username [$($SamAccountName)] already exists. Trying another..."
        Start-Sleep -Seconds 1
        $num++    
    }

    # Sort OUs from most to least members and select the OU with the least members to be the path
    # NOTE: at this point I had to manually configure the SearchBase
    $OUs = Get-ADOrganizationalUnit -Filter * -SearchBase "ou=edmonton users,ou=Department Users,dc=sleepygeeks,dc=com" -Properties Name  -SearchScope OneLevel| 
        Select-Object -ExpandProperty DistinguishedName
    $OUMemberCount = [System.Collections.ArrayList]@()
    ForEach($OU in $OUs){
        $OUMemberCount.Add(
            [pscustomobject]@{
            OU = $ou
            Members = (Get-ADUser -Filter * -SearchBase "$ou").count 
        }) | Out-Null
    }
    $FewestOUCount = $($OUMemberCount | Sort-Object Members | Select-Object -First 1).OU
    $FewestOUCount


    # Grab parent OU using Split Method (lowest, most direct OU). Used for department
    #$DN= "ou=edmonton users,ou=Department Users,dc=sleepygeeks,dc=com"
    $Department = $FewestOUCount.Split('OU=|,OU=')[1]
    
    # Determining city and Company (turn this into a switch)
    switch ($_.Statefull)
    {
        'Alberta' {
            $City = 'Edmonton'
            $Company = 'SleepyGeeks'
            break
        }
        'British Columbia' {
            $Company = 'SleepyGeeks'
            $City = 'Vancouver'
            break
        }
        'Ontario' {
            $City = 'Toronto'
            $Company = 'SleepyGeeks'
            break
        }
        'New York'{
            $City = 'New York'
            $Company = 'SoftwareJuice Learning'
            break
        }
        'Nunuvaut'{
            $City = 'YellowKnife'
            $Company = 'SoftwareJuice'
            break
        }
        # London has not state so default will be based on that
        Default {
            $City = 'London'
            $Company = 'SoftwareJuice'
        }
    }

    # Employee ID
    $EmployeeID = -join(Get-Random -Maximum 999999999 -Minimum 100000000)


	#Read user data from each field in each row and assign the data to a variable as below
	$NewUserParam = @{
		Name 				    = $_.GivenName + ' ' + $_.Surname
		# Change this if not test environment
		AccountPassword 	    = (convertto-securestring 'Password1' -AsPlainText -Force)
		GivenName 			    = $_.GivenName
		Surname 			    = $_.Surname
        Initials                = $_.MiddleInitial
        DisplayName             = $_.GivenName + ' ' + $_.Surname
        # Change description in the future
        Description             = $Department + "User"
        # Might change office in the future
        office                  = "$Department Office"
        EmailAddress            = $SamAccountName + '@' + $Domain
        StreetAddress           = $_.StreetAddress
        City                    = $City
        state                   = $_.Statefull
        postalcode              = $_.ZipCode
        country                 = $_.Country
        Company                 = $Company
        # Not sure what to do with group
        #memberof               = 
		SamAccountName 		    = $SamAccountName
		OfficePhone			    = $_.TelephoneNumber
		Department			    = $Department
		Path				    = $FewestOUCount
		UserPrincipalName	    = $SamAccountName + '@' + $Domain
        EmployeeID              = $EmployeeID
        # Might have to implement manager AFTERWARDS
        #Manager                = 
        Enabled                 = $true
        ChangePasswordAtLogon   = $false
	}

    #Check to see if the user already exists in AD
	if (Get-ADUser -Filter {SamAccountName -eq $SamAccountName})
	{
		 #If user does exist, give a warning
		 Write-Warning "A user account with username $SamAccountName already exist in Active Directory."
	}
	else
	{
		#User does not exist then proceed to create the new user account
		
        #Account will be created in the OU provided by the $OU variable read from the CSV file
		New-ADUser @NewUserParam -Whatif -Verbose 
	}
})

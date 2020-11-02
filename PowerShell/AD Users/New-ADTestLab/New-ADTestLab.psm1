Install-Module PowerShellGet -Force
Install-Module ImportExcel
Import-Module ImportExcel
Import-Module activedirectory

#Requires -Module ImportExcel
#Requires -Module ActiveDirectory 

function New-BulkOUs {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [String]
        $FileLocation
    )
    $CheckExists = Test-Path $FileLocation
    if (-not($CheckExists -eq $true)){
        Write-Host "CSV at this location doesn't exist" -ForegroundColor Red
    }else {
        $OUPath = Import-Csv $FileLocation
        foreach($ou in $OUPath){
            try{
                $CheckOU = Get-ADOrganizationalUnit -Filter "Name -eq '$($ou.name)'" #-SearchBase $ou.Path
                if (-not($null -eq $CheckOU)){
                    Write-Host "$($ou.Name) already exists. Skipping." -ForegroundColor DarkMagenta
                }else {
                    New-ADOrganizationalUnit `
                        -Name $ou.Name `
                        -DisplayName $ou.Name `
                        -Path $ou.path `
                        -ProtectedFromAccidentalDeletion $false
                    Write-Host "$($ou.Name) at the path $($ou.path) added successfully." -ForegroundColor Green
                }
            }
            catch{
                Write-Host "$($ou.Name) at the path $($ou.path) could not be found. Check csv for errors." -ForegroundColor Red
            }
        }
    }
}
function New-BulkGroups {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [String]
        $FileLocation
    )
    $GroupPath = Import-Csv $FileLocation
    if (-not($CheckExists -eq $true)){
        Write-Host "CSV at this location doesn't exist" -ForegroundColor Red
    }else {
        foreach($group in $GroupPath){
            try{
                # Verify if group already exists
                $CheckGroup = Get-ADGroup -Filter "SamAccountName -eq '$($group.SamAccountName)'" #-SearchBase $ou.Path
                if (-not($null -eq $CheckGroup)){
                    Write-Host "$($group.Name) already exists. Skipping." -ForegroundColor DarkMagenta
                }else{
                    # Execute group add, based on CSV
                    New-ADGroup `
                        -Name $group.Name `
                        -DisplayName $group.Displayname `
                        -Path $group.path `
                        -GroupScope $group.GroupScope `
                        -GroupCategory $group.GroupCategory `
                        -Whatif
                    
                        Write-Host "[$($group.Name)] created successfully in $($Group.path)." 
                }
            }
            catch{
                Write-Host "$($group.Name) at the path $($group.path) could not be found. Check csv for errors." -ForegroundColor Red
            }
        }
    }
}

function New-BulkUsers{
    <# 
    .Description
    This file to imports users based on existing OUs

    .EXAMPLE
    Add-BulkUsers -FileLocation "C:\Users\Administrator\Desktop\Full User Sheet.xlsx" -WorkSheetName Toronto
    Running based on users with Toronto WorkSheet 

    #>
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $true)]
        [String] $FileLocation,

        [parameter(Mandatory = $true)]
        [ValidateSet('Edmonton','Vancouver','New York','London','Toronto','YellowKnife')]
        [String] $WorkSheetName
    )
    $ADUsers = Import-Excel $FileLocation -WorksheetName $WorkSheetName

    #Loop through each row containing user details in the CSV file 
    #@ NOTE: Foreach method doesn't work for creating New Groups OR OUs
    $ADusers.foreach({
        # Obtain Domain
        $Domain = Get-ADDomain | Select-Object -ExpandProperty Forest
        # Obtain dc of distinguishedname to change domains 
        $DC = (Get-ADDomain).Name
        # Grabbing full DN
        $DN = (Get-ADDomain).distinguishedname

        # First try to create username
        $num = 1
        $SamAccountName = "{0}.{1}$num" -f $_.GivenName,$_.Surname
        # Verifying if the username has been taken
        while (Get-ADUser -Filter {SamAccountName -eq $SamAccountName}){
            $SamAccountName = "{0}.{1}$num" -f $_.GivenName,$_.Surname
            Write-Warning -Message "The username [$($SamAccountName)] already exists. Trying another..."
            Start-Sleep -Seconds 1
            $num++    
        }

        # Sort OUs from most to least members and select the OU with the least members to be the path
        # NOTE: searchbase leads to a very specific OU naming structure
        $OUs = Get-ADOrganizationalUnit -Filter * -SearchBase "ou=$($WorkSheetName) users,ou=Department Users,$DN" -Properties Name  -SearchScope OneLevel| 
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

        # Grab parent OU using Split Method (lowest, most direct OU). Used for department
        #$DN= "ou=edmonton users,ou=Department Users,dc=sleepygeeks,dc=com"
        #$Department = $FewestOUCount.Split('OU=|,OU=')[1]
        $Department = $FewestOUCount.Split(',=')[1]
        
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
            'Nunuvat'{
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

        # Random Employee ID
        $EmployeeID = -join(Get-Random -Maximum 999999999 -Minimum 100000000)

        # Generating generic title names to be combined with Department
        $TitleList = 'Analyst','Specialist','Lead','Aide','II'
        $Title = Get-Random -InputObject $TitleList

        #Read user data from each field in each row and assign the data to a variable as below
        $NewUserParam = @{
            Name 				    = $_.GivenName + ' ' + $_.Surname
            # Change this if not test environment
            AccountPassword 	    = (convertto-securestring 'Password1' -AsPlainText -Force)
            GivenName 			    = $_.GivenName
            Surname 			    = $_.Surname
            Initials                = $_.MiddleInitial
            DisplayName             = $_.GivenName + ' ' + $_.Surname
            # Might description in the future
            Description             = "$Department User"
            # Might change office in the future
            office                  = "$Department Office"
            EmailAddress            = $SamAccountName + '@' + $Domain
            StreetAddress           = $_.StreetAddress
            City                    = $City
            state                   = $_.Statefull
            postalcode              = $_.ZipCode
            country                 = $_.Country
            # Not Implemented - 
            #memberof               = 
            SamAccountName 		    = $SamAccountName
            OfficePhone			    = $_.TelephoneNumber
            Department			    = $Department
            Path				    = $FewestOUCount
            UserPrincipalName	    = $SamAccountName + '@' + $Domain
            EmployeeID              = $EmployeeID
            Company                 = $Company
            Title                   = "$Department $Title" 
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
            New-ADUser @NewUserParam -Verbose 
        }
    })
}

<#
    From a csv of OUs:
    1. Check if the OU has members, if not move to next OU in CSV
    2. For OUs with members, obtain a list of groups
    3. Iterate through each user (assuming user doesn't have a group yet)
    4. For each user, obtain a list of groups and sort by least to most - taking the group with least members
    5. Add the current selected user in the foreach loop into the group (with the fewest members) 
    6. Repeat 3-5
#>

function Add-BulkGroupsUsersToGroup {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [String]
        $FileLocation
    )
    $OUs = Import-csv $Filelocation

    if (-not($CheckExists -eq $true)){
        Write-Host "CSV at this location doesn't exist" -ForegroundColor Red
    }else {
        foreach($ou in $OUs){
            $groups = Get-ADGroup -Filter * -SearchBase "ou=$($ou.Name),$($ou.Path)" -SearchScope OneLevel| Select-Object samaccountname
            $Users = Get-ADUser -Filter * -SearchBase "ou=$($ou.Name),$($ou.Path)" -SearchScope OneLevel | Select-Object samaccountname
        
            if ($null -eq $groups){
                Write-Host "$($ou.Name) has no groups, skipping..." -ForegroundColor Magenta
            }elseif(-not($null -eq $Users)){
                write-host "$($ou.Name) group has members" -ForegroundColor Green
        
                # Random add to group, $count is an arraylist containing the number of members in each group in the csv
                foreach ($user in $users){
                    $count = [System.Collections.ArrayList]@()
                    
                    # Obtain user count for each group
                    foreach ($group in $groups) {
                        $count.Add([pscustomobject]@{Group=$group;Members=(Get-ADGroup -identity $group.samaccountname -Properties Member).Member.Count}) | Out-Null
                    } 
                    # Once count of group members has completed - sort by the members which automatically goes least to greatest. Grab the first value (the lowest) and obtain only the 'Group' parameter. Then add the current user from $ADusers to the group
                    $FewestGroupUsercount = $($count | Sort-Object Members | Select-Object -First 1).Group
                    $null = Add-ADGroupMember -Identity $FewestGroupUsercount.samaccountname -Members $user.samaccountname -WhatIf
                    Write-Host "[$($user.samaccountname)] added to the group [$FewestGroupUsercount]" -ForegroundColor Green
                }
            }
        }
    }
}




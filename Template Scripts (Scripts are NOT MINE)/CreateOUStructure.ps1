<#
.Synopsis
This script is to validate and create an OU structure based on the input from an CSV file or from direct input.

.Description
This script is to create OU strcuture using PowerShell. Script will take the input from a CSV file and first validate if the OU is already exist
in the path mentioned in the CSV file. If OU is already exist script will throw a message the OU already exist otherwise it will create the 
OU in the path mentioned. Script will work from direct input by providing OU name and OU path.

.Example
Create-OuStructureFromDirectInput -ouname test -oupath 'dc=azure-lab,dc=local'

This will create an OU name test in the location 'dc=azure-lab,dc=local'.

.Example
Create-OuStructureFromCSVFile -pathofcsvfile E:\Scripts\OUStructureUp.csv

This command will create an OU structure from a CSV input. CSV file must need to have column as "OUName" & "OUPath". OU Path is the Distringuished name
of the OU location.

Author: Manash Maitra (manas.maitra@accenture.com)
#>

Function Create-OuStructureFromCSVFile{
    [Cmdletbinding()]
    Param(
        [Parameter(Mandatory = $True,
                   HelpMessage = 'Please provide the path of the CSV file containing the OU name and OU path')]
        [String]$pathofcsvfile
    )

# Provide the path of the csv having the OU name and path to be created
$oufile = Import-Csv $pathofcsvfile

#Create the loop
foreach ($entry in $oufile)
{
    $ouname = $entry.ouname
    $oupath = $entry.oupath

    ## Validation, if the OU is already exist
    $ouidentity = "OU=" + $ouname + "," + $oupath
    $oucheck = [adsi]::Exists("LDAP://$ouidentity")

    ## Condition of creation
    If($oucheck -eq "True"){Write-host -ForegroundColor Red "OU $ouname is already exist in the location $oupath"}
    Else {
        ## Create the OU with Accidental Deletion enabled
        Write-Output "Creating the OU $ouname ....."
        New-ADOrganizationalUnit -Name $ouname -Path $oupath
        Write-Host -ForegroundColor Green "OU $ouname is created in the location $oupath"}
}

}

Function Create-OuStructureFromDirectInput{
    [Cmdletbinding()]
    Param(
        [Parameter(Mandatory = $True,
                   HelpMessage = 'Please provide the name of the OU')]
        [String]$ouname,
        [Parameter(Mandatory = $True,
                   HelpMessage = 'Please provide the path of the OU in DN format')]
        [String]$oupath
    )

# Provide the path of the csv having the OU name and path to be created

    ## Validation, if the OU is already exist
    $ouidentity = "OU=" + $ouname + "," + $oupath
    $oucheck = [adsi]::Exists("LDAP://$ouidentity")

    ## Condition of creation
    If($oucheck -eq "True"){Write-host -ForegroundColor Red "OU $ouname is already exist in the location $oupath"}
    Else {
        ## Create the OU with Accidental Deletion enabled
        Write-Output "Creating the OU $ouname ....."
        New-ADOrganizationalUnit -Name $ouname -Path $oupath
        Write-Host -ForegroundColor Green "OU $ouname is created in the location $oupath"}
}










#~ Practice creating functions with parameters

# TEMPLATE #################

#Function Install-Software{
#	[CmdletBinding()]
#	param(
#		[Parameter()]
#		[Variable type] $Variable
#	)
#}

# TEMPLATE ##################

function Install-Software {
    [Cmdletbinding()]
    param(
        # Setting a mandatory parameter, setting the $True IS NOT necessary, but it improves readability
        [Parameter(Mandatory = $True)]
        [string] $Name,
        # Setting default value for $Version
        [Parameter()]
        [ValidateSet(1,2,3)]
        [int32] $Version = 3,
        # Getting the Date for fun
        [Parameter()]
        [datetime] $Date,
        # Obtaining Computer names by enabling piping
        # @ NOTE - this will only have the last value in the array piped into it
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $ComputerName 
    )
    # @ Include a PROCESS Block to allow multiple objects to be piped into the function (instead of only one...)
    Process{
        $Date = Get-date    
        Write-Host "[$Date] $Name Updated to Version $version for server: $ComputerName" -ForegroundColor Green
    }
}

# Practice
function Test-Software {
    [Cmdletbinding()]
    param(
        [Parameter()]
        [Int32] $Var
    )
}
#~ Practice creating functions with paramters
function Install-Software {
    [Cmdletbinding()]
    param(
        # Setting a mandatory parameter
        [Parameter(Mandatory)]
        [string] $Name,
        # Setting default value for $Version
        [Parameter()]
        [int32] $Version = 3,

        [Parameter()]
        [datetime] $Date

    )
    $Date = Get-date    
    Write-Host "[$Date] $Name Updated to Version $version" -ForegroundColor Green
}
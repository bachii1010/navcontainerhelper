﻿<# 
 .Synopsis
  Get the version of NAV in a Nav container or a Nav container image
 .Description
  Returns the version of NAV in the format major.minor.build.release-country
 .Parameter containerOrImageName
  Name of the container or container image for which you want to get the version
 .Example
  Get-NavContainerNavVersion -containerOrImageName navserver
 .Example
  Get-NavContainerNavVersion -containerOrImageName microsoft/dynamics-nav:2017
#>
function Get-NavContainerNavVersion {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]$containerOrImageName
    )

    Process {
        $inspect = docker inspect $containerOrImageName | ConvertFrom-Json
        if ($inspect.Config.Labels.psobject.Properties.Match('nav').Count -eq 0) {
            throw "Container $containerOrImageName is not a NAV container"
        }
        return "$($inspect.Config.Labels.version)-$($inspect.Config.Labels.country)"
    }
}
Set-Alias -Name Get-BCContainerNavVersion -Value Get-NavContainerNavVersion
Export-ModuleMember -Function Get-NavContainerNavVersion -Alias Get-BCContainerNavVersion

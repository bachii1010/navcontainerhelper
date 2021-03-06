﻿<# 
 .Synopsis
  Uninstall Nav App in Nav container
 .Description
  Creates a session to the Nav container and runs the Nav CmdLet Uninstall-NavApp in the container
 .Parameter containerName
  Name of the container in which you want to uninstall the app (default navserver)
 .Parameter appName
  Name of app you want to uninstall in the container
 .Parameter appVersion
  Version of app you want to uninstall in the container
 .Parameter doNotSaveData
  Include this flag to indicate that you do not wish to save data when uninstalling the app
 .Example
  Uninstall-NavContainerApp -containerName test2 -appName myapp
 .Example
  Uninstall-NavContainerApp -containerName test2 -appName myapp -doNotSaveData
#>
function UnInstall-NavContainerApp {
    Param(
        [Parameter(Mandatory=$false)]
        [string]$containerName = "navserver",
        [Parameter(Mandatory=$false)]
        [string]$tenant = "default",
        [Parameter(Mandatory=$true)]
        [string]$appName,
        [Parameter()]
        [string]$appVersion,
        [switch]$doNotSaveData,
        [switch]$Force
    )

    Invoke-ScriptInNavContainer -containerName $containerName -ScriptBlock { Param($appName, $appVersion, $tenant, $doNotSaveData, $Force)
        Write-Host "Uninstalling $appName from $tenant"
        $parameters = @{
            "ServerInstance" = "NAV";
            "Name" = $appName;
            "Tenant" = $tenant
        }
        if ($appVersion) {
            $parameters += @{ "Version" = $appVersion }
        }
        if ($doNotSaveData) {
            $parameters += @{ "DoNotSaveData" = $true }
        }
        if ($Force) {
            $parameters += @{ "Force" = $true }
        }
        Uninstall-NavApp @parameters
    } -ArgumentList $appName, $appVersion, $tenant, $doNotSaveData, $Force
    Write-Host -ForegroundColor Green "App successfully uninstalled"
}
Set-Alias -Name UnInstall-BCContainerApp -Value UnInstall-NavContainerApp
Export-ModuleMember -Function UnInstall-NavContainerApp -Alias UnInstall-BCContainerApp

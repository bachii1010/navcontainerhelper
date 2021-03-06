﻿<# 
 .Synopsis
  Extract metadata from a container to be able to give more specific information when reporting an issue on GitHub.
 .Description
  Returns the debugging info for a container when reporting an issue on GitHUb
 .Parameter containerName
  Name of the container for which you want to get the debugging info
 .Parameter ExcludeEnvVars
  Add this switch if you want to exclude environment variables in the debugging info
 .Parameter ExcludeDockerInfo
  Add this switch if you want to exclude docker info in the debugging info
 .Parameter ExcludeDockerLogs
  Add this switch if you want to exclude docker logs in the debugging info
 .Parameter includeSensitiveInformation
  Add this switch to include sensitive information in the debugging info (passwords and urls)
 .Parameter CopyToClipboard
  Add this switch if you want the debugging info to automatically be added to the clipboard
 .Example 
  Get-NavContainerDebugInfo -containerName navserver -includeSensitiveInformation
  Get all debug information including sensitive information
  .Example
  Get-NavContainerDebugInfo -containerName navserver -ExcludeDockerInfo
  Get debug information excluding sensitive information and excluding docker info
  .Example
  Get-NavContainerDebugInfo -containerName navserver -ExcludeEnvVars -ExcludeDockerInfo -ExcludeDockerLogs -CopyToClipboard
  Get basic debug information and copy it into the clipboard.
#>
function Get-NavContainerDebugInfo {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]$containerName,
        [Parameter()]
        [switch]$ExcludeEnvVars,
        [Parameter()]
        [switch]$ExcludeDockerInfo,
        [Parameter()]
        [switch]$ExcludeDockerLogs,
        [Parameter()]
        $ExcludePing,
        [Parameter()]
        [switch]$IncludeSensitiveInformation,
        [Parameter()]
        [switch]$CopyToClipboard
    )

    Process {
        $debugInfo = @{}
        $inspect = docker inspect $containerName | ConvertFrom-Json

        if ($inspect.Config.Labels.psobject.Properties.Match('nav').Count -eq 0) {
            throw "Container $containerName is not a NAV container"
        }
        
        $debugInfo.Add('container.labels', $inspect.Config.Labels)
        
        if (!$ExcludeEnvVars) {
            $envs = $inspect.Config.Env.GetEnumerator() | ForEach-Object {
                if ($includeSensitiveInformation) {
                    $_
                } elseif ($_.ToLowerInvariant().Contains("password=") -or 
                          $_.ToLowerInvariant().Startswith("navdvdurl=") -or 
                          $_.ToLowerInvariant().Startswith("countryurl=") -or 
                          $_.ToLowerInvariant().Startswith("licensefile=") -or 
                          $_.ToLowerInvariant().Startswith("bakfile=") -or 
                          $_.ToLowerInvariant().Startswith("folders=") -or 
                          $_.ToLowerInvariant().Startswith("vsixurl=")) {
                    ($_.Split("=")[0] + "=<specified>")
                } else {
                    $_
                }
            }
            if ($envs) {
                $debugInfo.Add('container.env', $envs)
            }
        }

        if (!$ExcludeDockerInfo) {
            $dockerInfo = docker info
            if ($dockerInfo) {
                $debugInfo.Add('docker.info', $dockerInfo)
            }
        }

        if (!$ExcludeDockerLogs) {
            $logs = docker logs $containerName
            if ($logs) {
                $debugInfo.Add('container.logs', $logs)
            }
        }

        if (!$ExcludePing) {
            $ping = ping $containerName
            if ($ping) {
                $debugInfo.Add('container.ping', $ping)
            }
        }

        $debugInfoJson = ConvertTo-Json $debugInfo

        if ($CopyToClipboard) {
            $debugInfoJson | Set-Clipboard
        }
        
        return $debugInfoJson
    }
}
Set-Alias -Name Get-BCContainerDebugInfo -Value Get-NavContainerDebugInfo
Export-ModuleMember -Function Get-NavContainerDebugInfo -Alias Get-BCContainerDebugInfo

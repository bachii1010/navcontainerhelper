﻿$VerbosePreference="SilentlyContinue"

# Version, Author, CompanyName and nugetkey
. (Join-Path $PSScriptRoot "settings.ps1")

Clear-Host
#Invoke-ScriptAnalyzer -Path $PSScriptRoot -Recurse -Settings PSGallery -Severity Warning

Get-ChildItem -Path $PSScriptRoot -Recurse | % { Unblock-File -Path $_.FullName }

Remove-Module NavContainerHelper -ErrorAction Ignore
Uninstall-module NavContainerHelper -ErrorAction Ignore

$modulePath = Join-Path $PSScriptRoot "NavContainerHelper.psm1"
Import-Module $modulePath -DisableNameChecking

$functionsToExport = (get-module -Name NavContainerHelper).ExportedFunctions.Keys | Sort-Object
$aliasesToExport = (get-module -Name NavContainerHelper).ExportedAliases.Keys | Sort-Object
Update-ModuleManifest -Path (Join-Path $PSScriptRoot "NavContainerHelper.psd1") `
                      -RootModule "NavContainerHelper.psm1" `
                      -FileList @("ContainerHandling\docker.ico") `
                      -ModuleVersion $version `
                      -Author $author `
                      -FunctionsToExport $functionsToExport `
                      -AliasesToExport $aliasesToExport `
                      -CompanyName $CompanyName `
                      -ReleaseNotes (get-content (Join-Path $PSScriptRoot "ReleaseNotes.txt")) 

Publish-Module -Path $PSScriptRoot -NuGetApiKey $nugetkey

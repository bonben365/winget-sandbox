<#
==================================================================================================================
Name:           
Description:    
Version:        1.0
Date :          26/2/2023
Website:        https://bonben365.com
Script by:      https://github.com/bonben365
For detailed script execution: https://bonben365.com/
=================================================================================================================
#>

Add-AppxPackage "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"

# Create temporary directory
$null = New-Item -Path $env:temp\temp -ItemType Directory -Force
Set-Location $env:temp\temp
$path = "$env:temp\temp"

#Download and extract Nuget
$url = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
(New-Object Net.WebClient).DownloadFile($url, "$env:temp\temp\nuget.exe")
.\nuget.exe install Microsoft.UI.Xaml -Version 2.7

Add-AppxPackage -Path "$path\Microsoft.UI.Xaml.2.7.0\tools\AppX\x64\Release\Microsoft.UI.Xaml.2.7.appx" -ErrorAction:SilentlyContinue

#Download winget and license file
function getLink($match) {
    $uri = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
    $get = Invoke-RestMethod -uri $uri -Method Get -ErrorAction stop
    $data = $get[0].assets | Where-Object name -Match $match
    return $data.browser_download_url
}

$url = getLink("msixbundle")
$licenseUrl = getLink("License1.xml")

# Finally, install winget
$fileName = 'winget.msixbundle'
$licenseName = 'license1.xml'

(New-Object Net.WebClient).DownloadFile($url, "$env:temp\temp\$fileName")
(New-Object Net.WebClient).DownloadFile($licenseUrl, "$env:temp\temp\$licenseName")

Add-AppxProvisionedPackage -Online -PackagePath $fileName -LicensePath $licenseName

# Cleanup
Remove-Item $path\* -Recurse -Force

Write-Host
Write-Host ============================================================
Write-Host Installed packages...
Write-Host ============================================================
Write-Host
$packages = @("Microsoft.VCLibs","DesktopAppInstaller","UI.Xaml")
ForEach ($package in $packages){Get-AppxPackage -Name *$package* | select Name,Version,Status }

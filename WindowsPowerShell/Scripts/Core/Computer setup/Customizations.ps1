# Toggle regions: Ctrl + M

#region Demo setup
Write-Warning 'This is a demo script which should be run line by line or sections at a time, stopping script execution'

break

<#

    Author:      Jan Egil Ring
    Name:        Customizations.ps1
    Description: This demo script is part of the presentation 
                 Manage your IT Pro computer using PowerShell
                 
#>

#region Basics

# Computername and domain membership
Rename-Computer -NewName DEMOPC05 -Restart -Force
Add-Computer -DomainName lab.local -OUPath "OU=Clients,DC=local,DC=lab"


# Map drives (can also be performed in environment-specific setup as shown later)
New-PSDrive -name H -Root \\server\share -Credential $cred -PSProvider Filesystem -Persist

#endregion

#region Packages and Modules

# Remove unnecessary built-in app packages
# http://mikefrobbins.com/2015/08/20/remove-app-packages-from-windows-10-enterprise-edition/

Get-AppxPackage | Sort-Object -Property Name | Select-Object -Property Name

'Microsoft.3DBuilder', 'Microsoft.BingFinance', 'Microsoft.BingNews',
'Microsoft.BingSports', 'Microsoft.MicrosoftSolitaireCollection',
'Microsoft.People', 'Microsoft.Windows.Photos', 'Microsoft.WindowsCamera',
'microsoft.windowscommunicationsapps', 'Microsoft.WindowsPhone',
'Microsoft.WindowsSoundRecorder', 'Microsoft.XboxApp', 'Microsoft.ZuneMusic',
'Microsoft.ZuneVideo' |
ForEach-Object {
    Get-AppxPackage -Name $_ |
    Remove-AppxPackage
}

#region Packages

$PackageSource = 'CrayonPackages'

Register-PackageSource -Name $PackageSource -Location 'https://packages.demo.crayon.com/nuget' -Provider Chocolatey -Trusted -Verbose
Get-PackageSource

$packages = @('7zip','git','googlechrome','javaruntime','notepadplusplus','vlc','sysinternals','putty','dropbox','sublimetext3','sublimetext3.packagecontrol','teamviewer','windirstat','sourcetree','FoxitReader', 'Snagit', 'githubforwindows','lastpass','royalts')


foreach ($package in $packages) {


    if (-not (Get-Package -Name $package -ErrorAction SilentlyContinue)) {

        Install-Package -Name $PackageSource -Source $PackageSource

    }


}

#endregion

#region Modules

$repository = 'CrayonModules'

Register-PSRepository -Name $repository –SourceLocation 'https://powershellget.demo.crayon.com/nuget/' -PublishLocation 'https://powershellget.demo.crayon.com/nuget/Packages' -InstallationPolicy Trusted
Get-PSRepository

$modules = @('await','PSCX')


foreach ($module in $modules) {


    if (-not (Get-Module -Name $module -ListAvailable)) {

    Install-Module -Name $module -Repository $repository

    }


}

#endregion

#endregion

#region Tune various OS settings

<#

A module to customize settings and perform tweaks for Windows 10 by Jaap Brasser
-https://github.com/jaapbrasser/CustomizeWindows10
-http://www.powershellgallery.com/packages/CustomizeWindows10/


Future plans:
-Add DSC Resource
-Add more functionality, for example Explorer options such as show hidden files
-Watch this space, and feel free to contribute

#>

Find-Module -Name CustomizeWindows10
Find-Module -Name CustomizeWindows10| Install-Module

Get-Module -ListAvailable

Install-Module -Name CustomizeWindows10

Get-Command -Module CustomizeWindows10

Get-AppTheme
Get-OneDriveNavPane
Get-PowerShellWinX


<# Snap Assist

 Drag a window to the left or right edge of your screen until you see a transparent overlay appear, then drop the window to have it snap to that half of the screen. 

 Snap Assist will then show thumbnails of all other snappable windows in the available space on the other side for you to click/tap on one to choose, and it'll also automatically snap in to place.

 This feature allows users to snap two windows on either side of the screen. In previous version of Windows, after snapping a window on the screen, users had to wade through other app windows to find a second one to snap. But in Windows 10, once you snap a window, you will be offered a list of app windows which are opened, and you just need to click on it to snap it. That is why this feature has been called the name Snap Assist.

Read more: http://www.filecritic.com/snap-assist-corner-snap-and-snap-fill-in-windows-10-explained/#ixzz3k6DkOijq


 #>


Get-SnapAssist

<# Snap Fill

The feature will allow you to fit Windows independently – meaning that Windows will be able to fill empty spaces with various sized windows. 

Snapping a Window poses a slight issue, you may require a window to be larger than the other windows. Resizing a window manually will require you to adjust other windows manually too. To avoid this hassle, Windows 10 uses Snap Fill.

Read more: http://www.filecritic.com/snap-assist-corner-snap-and-snap-fill-in-windows-10-explained/#ixzz3k6DzdiDZ


#>

Get-SnapFill


Add-PowerShellWinX
Enable-SnapAssist
Enable-SnapFill

# http://blog.powershell.no/2010/02/26/pin-and-unpin-applications-from-the-taskbar-and-start-menu-using-windows-powershell/
# https://connect.microsoft.com/PowerShell/feedback/details/1609288/pin-to-taskbar-no-longer-working-in-windows-10

Set-PinnedApplication -Action PinToTaskbar -FilePath "C:\WINDOWS\system32\notepad.exe" 

# Registry tweaks (the goal is to put these into functions in the CustomizeWindows10 module)

# Show file extensions and hidden files
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name HideFileExt -Type DWord -Value 0
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name Hidden -Type DWord -Value 1
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowSuperHidden -Type DWord -Value 1

#region Power Plan

Get-CimInstance -Namespace root\cimv2\power -ClassName win32_powerplan -Filter "ElementName = 'Balanced'" | Invoke-CimMethod -MethodName Activate

#endregion


#endregion
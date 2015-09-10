#region Demo setup
Write-Warning 'This is a demo script which should be run line by line or sections at a time, stopping script execution'

break

<#

    Author:      Jan Egil Ring
    Name:        Initialize-Repository.ps1
    Description: This demo script is part of the presentation 
                 Manage your IT Pro computer using PowerShell
                 
#>


#region Environment info

<#


Windows 10 Enterprise default installation with the following customizations:
-Local user (admin-privileges) created
-All Windows Updates available per 01.09.2015 installed
-Internal root CA certifcate trusted
-Registered internal PackageManagement Source and installed Git client from internal repository (for the sake of time)
-The PackageManagement and PowerShellGet modules from the WMF 5 Production Preview (August 2015) is pre-installed (the build of PackageManagement in Windows 10 RTM is not being used due to a bug which caused packages to not install correctly)


#>

#endregion


# Increase PowerShell ISE Zoom level for demo purposes
$psISE.Options.Zoom = 140

# Create local folder for Git-repositories
 if (-not (Test-Path -Path ~\Git)) {

  New-Item -Path ~ -Name Git -ItemType Directory

 }


<#

The repositories used in the demo is internal NuGet instances running on Windows Server 2012 R2 IIS

NuGet
http://blogs.msdn.com/b/powershell/archive/2014/05/20/setting-up-an-internal-powershellget-repository.aspx
http://learn-powershell.net/2014/04/11/setting-up-a-nuget-feed-for-use-with-oneget/

ProGet (easier to set up and more features, 3rd party)
http://asaconsultant.blogspot.no/2014/05/build-your-local-powershell-module.html

#>


# Add root certificate for internal CA in order to trust internal PackageManagement/PowerShellGet repositories
Invoke-WebRequest -Uri 'http://pki.demo.crayon.com/crl/Crayon Demo Root CA.cer' -OutFile "$env:temp\Crayon Demo Root CA.cer"

certutil -addstore root "$env:temp\Crayon Demo Root CA.cer"


# Register internal PackageManagement repository and install Git client
Register-PackageSource -Name CrayonPackages -Location 'https://packages.demo.crayon.com/nuget' -Provider Chocolatey -Trusted -Verbose

Find-Package -Source CrayonPackages

Find-Package -Name git -RequiredVersion 2.5.0 -Source CrayonPackages | Install-Package -Force


# Download Git repository
$gitrepo = Join-Path -Path (Resolve-Path -Path ~\Git) -ChildPath CrayonDemo-ITPro-Computer

Start-Process -FilePath powershell.exe -ArgumentList "git --% clone https://git.crayon.com/janring/CrayonDemo-ITPro-Computer.git $gitrepo"


# Run remaining scripts from repository
dir ~\Git\CrayonDemo-ITPro-Computer

psedit ~\Git\CrayonDemo-ITPro-Computer\WindowsPowerShell\Scripts\Core\Demos\Invoke-ITProComputerDemoScripts.ps1
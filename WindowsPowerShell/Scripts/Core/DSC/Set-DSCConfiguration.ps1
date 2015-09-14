# Toggle regions: Ctrl + M

#region Demo setup
Write-Warning 'This is a demo script which should be run line by line or sections at a time, stopping script execution'

break

<#

    Author:      Jan Egil Ring
    Name:        Set-DSCConfiguration.ps1
    Description: This demo script is part of the presentation 
                 Manage your IT Pro computer using PowerShell
                 
#>


#region Variables

$Environment = 'DEMO'
$DSCRootDirectory = "~\Git\CrayonDemo-ITPro-Computer\WindowsPowerShell\Environments\$Environment\Scripts\DSC\"
$DSCMOFDirectory = Join-Path -Path $DSCRootDirectory -ChildPath MOF-files
$DSCCertificatesDirectory = Join-Path -Path $DSCRootDirectory -ChildPath Certificates

#endregion

#region Certificate for encrypting DSC credentials

# Check if valid certificate is already present    
$Certificate = Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Subject -eq "CN=Self Signed Cert - DSC" -AND $_.PrivateKey.KeyExchangeAlgorithm} | Select-Object -First 1

# If no certificate is available, create one
if (-not $Certificate) {
@'
[NewRequest]
Subject = "CN=Self Signed Cert - DSC"
ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
FriendlyName = "Created for use with PowerShell Desired State Configuration"
ValidityPeriod = Years
ValidityPeriodUnits = 5
RequestType = Cert
'@ | Out-File "$DSCCertificatesDirectory\DSC-certificate-template.inf"

$TemplateFile = Join-Path -Path (Resolve-Path $DSCCertificatesDirectory).Path -ChildPath DSC-certificate-template.inf
$CerFile = Join-Path -Path (Resolve-Path $DSCCertificatesDirectory).Path -ChildPath ($($env:computername) + '.cer')
certreq.exe -new -machine $TemplateFile $CerFile
}

# Check if valid certificate is already present    
$Certificate = Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Subject -eq "CN=Self Signed Cert - DSC" -AND $_.PrivateKey.KeyExchangeAlgorithm} | Select-Object -First 1


# Export certificate file
if (-not $(test-path $CerFile)) {
    $CertificateFile = Export-Certificate -Type CERT -FilePath $CerFile -Cert $Certificate
    }
else {$CertificateFile = $CerFile}

# Import certificate file to trusted root authorities so it is trusted on the local machine
if (-not $(Get-ChildItem 'Cert:\LocalMachine\Root' | Where-Object {$_.Thumbprint -eq $Certificate.Thumbprint})) {
    $Import = Import-Certificate -FilePath $CertificateFile -CertStoreLocation 'Cert:\LocalMachine\Root'
    }

#endregion

#region Local Configuration Manager



# Create LCM configuration    
[DSCLocalConfigurationManager()]
Configuration LCMConfig
{

node $env:computername {
    Settings
    {
    CertificateID = $Certificate.Thumbprint
    ConfigurationMode = 'ApplyAndAutoCorrect'
    RefreshMode = 'Push'
    ConfigurationModeFrequencyMins = 720 # Every 12 hours
    RebootNodeIfNeeded = $false
    DebugMode = 'All'
    }
  }
}

# Generate meta MOF
LCMConfig -OutputPath $DSCMOFDirectory

# Create WinRM listener (minimum requirement for DSC)
Set-WSManQuickConfig

# Optionally, enable PS Remoting if you intend to use it against your own machine
Enable-PSRemoting -Force

# Verify that a listener is created
Get-ChildItem WSMan:\localhost\Listener

# Verify that network profile is not set to Public
Get-NetConnectionProfile

# Optionally, change network profile to Private
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private

# Add local computer to the TrustedHosts property in the WSMan-client
Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value $env:COMPUTERNAME -Force -Concatenate
Get-Item -Path WSMan:\localhost\Client\TrustedHosts

# Apply the LCM configuration
Set-DscLocalConfigurationManager -Path $DSCMOFDirectory

# Verify the LCM configuration
Get-DscLocalConfigurationManager


#endregion

#region Modules

# Install modules required by the DSC Configuration. We are pre-installing these since a Pull Server is not used in this scenario.

# Install modules from PSGallery
$Modules = @('PackageManagementProviderResource','xComputerManagement')

foreach ($Module in $Modules) {

if (-not (Get-Module -Name $Module -ListAvailable)) {

Find-Module -Name $Module | Install-Module -Scope AllUsers -Force

  }
}

# Installing modules from local Git-repository (these are not available on PSGallery as of 31.08.2015)
if (-not (Test-Path $env:ProgramFiles\WindowsPowerShell\Modules\cPackageManagement)) {

Copy-Item -Path ~\Git\CrayonDemo-ITPro-Computer\WindowsPowerShell\Modules\cPackageManagement -Destination $env:ProgramFiles\WindowsPowerShell\Modules -Recurse -Force

}

# Pull CustomizeWindows10 module from local repository, since the latest version containing the DSC Resource isn`t available on PowerShell Gallery yet
Remove-Item $env:ProgramFiles\WindowsPowerShell\Modules\CustomizeWindows10 -Force -Recurse
Copy-Item -Path ~\Git\CrayonDemo-ITPro-Computer\WindowsPowerShell\Modules\CustomizeWindows10 -Destination $env:ProgramFiles\WindowsPowerShell\Modules -Recurse -Force

# Modules to be installed by DSC Configuration - these are modules you want available on the local machine which is not synced via source control
# Need a list of modules to be installed. As you know, this is very flexible in PowerShell. A couple of examples using hardcoded input and CSV-input:

$modules = @('await','PSCX')

$modules = Import-Csv -Path (Join-Path -Path $DSCRootDirectory -ChildPath Modules.csv)
$modules = $modules.Name

# Single module used for testing purposes
$modules = @('await')

#endregion

#region Packages

# Need a list of packages to be installed. As you know, this is very flexible in PowerShell. A couple of examples using hardcoded input and CSV-input:

$packages = @('7zip','git','googlechrome','javaruntime','notepadplusplus','vlc','sysinternals','putty','dropbox','sublimetext3','sublimetext3.packagecontrol','teamviewer','windirstat','sourcetree','FoxitReader', 'Snagit', 'githubforwindows','lastpass','royalts')

$packages = Import-Csv -Path (Join-Path -Path $DSCRootDirectory -ChildPath Packages.csv)
$packages = $packages.Name

# Single package used for testing purposes
$packages = @('7zip')

#endregion

#region AppxPackages

$AppxPackagesToRemove = @('Microsoft.3DBuilder', 'Microsoft.BingFinance', 'Microsoft.BingNews',
'Microsoft.BingSports', 'Microsoft.MicrosoftSolitaireCollection',
'Microsoft.People', 'Microsoft.Windows.Photos', 'Microsoft.WindowsCamera',
'microsoft.windowscommunicationsapps', 'Microsoft.WindowsPhone',
'Microsoft.WindowsSoundRecorder', 'Microsoft.XboxApp', 'Microsoft.ZuneMusic',
'Microsoft.ZuneVideo')

$AppxPackagesToRemove = Import-Csv -Path (Join-Path -Path $DSCRootDirectory -ChildPath AppXPackagesToRemove.csv)
$AppxPackagesToRemove = $AppxPackagesToRemove.Name

# Single package used for testing purposes
$AppxPackagesToRemove = @('Microsoft.3DBuilder')

#endregion

#region DSC Configuration
configuration ITPro {

Import-DscResource -ModuleName PSDesiredStateConfiguration, CustomizeWindows10, PackageManagementProviderResource, cPackageManagement, xComputerManagement

Node $AllNodes.Nodename {

xComputer ComputerName {

Name = $Node.Nodename
WorkGroupName = $Node.WorkGroupName
Credential = $Node.UserCredentials

}

CustomizeWindows10CompositeDSCResource WindowsSettings {

EnableWin10ConnectedStandby = $false
EnableDriverInstallationFromWindowsUpdate = $false
EnablePowerShellOnWinX = $true
EnableSnapFill = $true
EnableSnapAssist = $true
ShowFileExtensions = $true
ShowHiddenFiles = $true
ShowProtectedOSFiles = $true
ShowDesktopIcons = $false
WindowsUpdateMode = 'Notify'

UserCredentials = $Node.UserCredentials

}

PowerPlan PowerPlanSettings {

ActivePowerPlan = 'Balanced'
SleepAfterOnAC = '0'
SleepAfterOnDC = '0'
TurnOffDisplayAfterOnAC = '60'
TurnOffDisplayAfterOnDC = '10'

}

foreach ($package in $node.AppxPackagesToRemove) {

AppxPackageRemoval $package {

PackageName = $package
PSDSCRunAsCredential = $Node.UserCredentials

}

}

PackageManagementSource CrayonPackages {

Name = 'CrayonPackages'
Ensure = 'Present'
ProviderName = 'Chocolatey'
InstallationPolicy = 'Trusted'
SourceUri = $ConfigurationData.NonNodeData.PackageManagementSourceUri
PSDSCRunAsCredential = $Node.UserCredentials

}

PackageManagementSource CrayonModules {

Name = 'CrayonModules'
Ensure = 'Present'
ProviderName = 'PSModule'
InstallationPolicy = 'Trusted'
SourceUri = $ConfigurationData.NonNodeData.PowerShellGetSourceUri
PSDSCRunAsCredential = $Node.UserCredentials

}

foreach ($module in $node.modules) {

PSModule $module {

Name = $module
Ensure = 'Present'
InstallationPolicy = 'Trusted'
Repository =  $ConfigurationData.NonNodeData.ModuleSource
PSDSCRunAsCredential = $Node.UserCredentials
DependsOn = '[PackageManagementSource]CrayonModules'

}

}

foreach ($package in $node.packages) {

PackageManagement $package {

    PackageName = $package
    Ensure = 'Present'
    PackageProvider = 'Chocolatey'
    PackageSource = $ConfigurationData.NonNodeData.PackageSource
    PSDSCRunAsCredential = $Node.UserCredentials
    DependsOn = '[PackageManagementSource]CrayonPackages'

    }

}



}

}




# Define DSC Configuration Data (necessary to encrypt credentials)
$ConfigData = @{
        AllNodes = @(
            @{
                NodeName = $env:computername
                WorkGroupName = 'WORKGROUP'
                CertificateFile = Join-Path -Path (Resolve-Path $DSCCertificatesDirectory).Path -ChildPath ($($env:computername) + '.cer')
                UserCredentials = Get-Credential -UserName (whoami) -Message ' '
                Packages = $Packages
                Modules = $Modules
                AppxPackagesToRemove = $AppxPackagesToRemove
            }
        )
        NonNodeData = 
            @{
                PackageManagementSourceUri = 'https://packages.demo.crayon.com/nuget'
                PowerShellGetSourceUri = 'https://powershellget.demo.crayon.com/nuget/' #Gotcha: Must have trailing / for Get-PackageSource -Location to work
                PackageSource = 'CrayonPackages'
                ModuleSource = 'CrayonModules'
            }   
    }

# Verify data
$ConfigData.AllNodes

# Export to keep history
$ConfigData | ConvertTo-Json | Out-File -FilePath (Join-Path -Path $DSCRootDirectory\ConfigData -ChildPath ($($env:computername) + '_' + (Get-Date -Format yyyy-MM-dd) + '.json'))

# Generate DSC Configuration
ITPro -OutputPath $DSCMOFDirectory -ConfigurationData $ConfigData

# Apply DSC Configuration
Start-DscConfiguration –Path $DSCMOFDirectory –Wait –Verbose -Force


#endregion

# Toggle regions: Ctrl + M

#region Demo setup
Write-Warning 'This is a demo script which should be run line by line or sections at a time, stopping script execution'

break

<#

    Author:      Jan Egil Ring
    Name:        Register-ScheduledJob.ps1
    Description: This demo script is part of the presentation 
                 Manage your IT Pro computer using PowerShell
                 
#>

#region Credentials

# Store credentials locally since they are encrypted using DPAPI
$LocalCredPath = "$Env:AppData\WindowsPowerShell\Credentials"

$ScheduledJobCredential = Join-Path -Path $LocalCredPath -Childpath ($($env:username) + '.cred.xml')
$ScheduledJobCredential = Get-Credential -UserName (whoami) -Message 'Enter password'
$ScheduledJobCredential | Export-Clixml -Path $ScheduledJobCredential

#endregion

#region Update-Help

$ScheduledJobOption = New-ScheduledJobOption -RunElevated
$Trigger = New-JobTrigger -At 03:00:00 -Daily

Register-ScheduledJob -Name Update-Help -ScriptBlock {

Update-Help

} -Trigger $Trigger -ScheduledJobOption $ScheduledJobOption -Credential $ScheduledJobCredential -RunNow


Get-Job -Name Update-Help

#endregion

#region Update-Module

# This is something you might want to do manually

$ScheduledJobOption = New-ScheduledJobOption -RunElevated
$Trigger = New-JobTrigger -At 02:00:00 -Daily

Register-ScheduledJob -Name Update-Module -ScriptBlock {

# Todo: Add logging, for example Update-Module -Force -Verbose | Out-File -FilePath ~\Git\CrayonDemo-ITPro-Computer\WindowsPowerShell\Environments\ITPRO\Logs\PowerShellGet\Update-Module.log

Update-Module

# Alternatively: Limit autoupdated modules to specific modules
# Update-Module -Name ISESteroids


} -Trigger $Trigger -ScheduledJobOption $ScheduledJobOption -Credential $ScheduledJobCredential -RunNow


Get-ScheduledJob -Name Update-Module

#endregion

#region Clean-Folder

$ScheduledJobOption = New-ScheduledJobOption -RunElevated
$Trigger = New-JobTrigger -At 05:00:00 -Daily

Register-ScheduledJob -Name Clean-Folder -ScriptBlock {

# Desktop
Get-ChildItem -Path ~\Desktop\*.lnk | Remove-Item -Force
Get-ChildItem -Path C:\Users\Public\Desktop\*.lnk | Remove-Item -Force


# Downloads
if (-not (Test-Path ~\Downloads\_Clean)) {

New-Item -Path ~\Downloads -Name _Clean -ItemType Directory

}

Get-ChildItem -Path ~\Downloads -Exclude _Clean | Where-Object LastWriteTime -lt (Get-Date).AddDays(-2) | Move-Item -Destination ~\Downloads\_Clean -Force

Get-ChildItem -Path ~\Downloads\_Clean | Where-Object LastWriteTime -lt (Get-Date).AddDays(-30) | Remove-Item -Force


# Temp
if (-not (Test-Path C:\temp)) {

New-Item -Path C:\ -Name Temp -ItemType Directory

}

Get-ChildItem -Path C:\temp | Where-Object LastWriteTime -lt (Get-Date).AddDays(-14) | Remove-Item -Force


} -Trigger $Trigger -ScheduledJobOption $ScheduledJobOption -Credential $ScheduledJobCredential -RunNow


Get-Job -Name Clean-Folder

#endregion

#region Update-RoyalFolder

# More info: http://www.powershellmagazine.com/2015/01/08/introducing-the-royal-ts-powershell-module/

$LocalCredPath = "$Env:AppData\WindowsPowerShell\Credentials"

$ADCredentialPath = Join-Path -Path $LocalCredPath -Childpath 'AD.cred.xml'
$ADCredential = Get-Credential
$ADCredential | Export-Clixml -Path $ADCredentialPath


$ScheduledJobOption = New-ScheduledJobOption -RunElevated
$Trigger = New-JobTrigger -At 04:00:00 -Daily


$parameters = @{
Name = 'Update-RoyalFolder'
Trigger = $Trigger
ScheduledJobOption = $ScheduledJobOption
ScriptBlock = {
Write-Output "Started"

$LocalCredPath = "$Env:AppData\WindowsPowerShell\Credentials"

$ADCredentialPath = Join-Path -Path $LocalCredPath -Childpath 'AD.cred.xml'

try
{
    Test-Path -Path $ADCredentialPath -ErrorAction Stop
    $ADCredential  = Import-Clixml $ADCredentialPath -ErrorAction Stop
}
catch 
{
    throw "$ADCredentialPath does not exist or is invalid, aborting"
}


$RoyalDocumentPath = Join-Path -Path $env:TEMP -ChildPath CrayonDemo.rtsz
$TargetPath = '~\Documents\'

try {
Copy-Item -Path (Join-Path -Path $TargetPath -ChildPath CrayonDemo.rtsz) -Destination $RoyalDocumentPath -Force -ErrorAction Stop
}
catch {
}

$script = Join-Path -Path (Resolve-Path -Path ~\Git) -ChildPath 'ITPro-Computer\WindowsPowerShell\Scripts\Royal TS\Update-RoyalFolder.ps1'
& $script -RootOUPath 'OU=Servers,OU=DEMO,DC=demo,DC=crayon,DC=com' -ADCredential $ADCredential -ADDomainController 'demo.crayon.com' -RoyalDocumentPath $RoyalDocumentPath -RemoveInactiveComputerObjects -UpdateRoyalComputerProperties -UpdateRoyalFolderProperties -Verbose


Copy-Item -Path $RoyalDocumentPath -Destination $TargetPath -Force

Write-Output "Completed"
}
RunNow = $true
Credential = $ScheduledJobCredential
}


Register-ScheduledJob @parameters

Get-Job -Name Update-RoyalFolder

#endregion

# Inspect the scheduled jobs we configured
Get-ScheduledJob | Select-Object -Property Name,@{N='Frequency';E={$PSItem.JobTriggers[0].Frequency}},@{N='Time';E={$PSItem.JobTriggers[0].At}} | Out-GridView

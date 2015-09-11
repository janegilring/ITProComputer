#region Credentials

<#

Todo: Look into better ways to handle credentials, for example:

-Using the BetterCredentials module by Joel Bennett instead (http://www.powershellgallery.com/packages/BetterCredentials)
-Using Protect-CmsMessage available in V5 to store credentials using a certificate
-Using Dave Wyatt`s ProtectedData module (compatible back to V2) to store credentials using a certificate

#>

# Store credentials locally since they are encrypted using DPAPI
$LocalCredPath = "$Env:AppData\WindowsPowerShell\Credentials"

$LocalUserCredPath = Join-Path -Path $LocalCredPath -Childpath ($($env:username) + '.cred.xml')
$WorkCredPath = Join-Path -Path $LocalCredPath -Childpath 'Work.cred.xml'
$BabyStatsCredPath = Join-Path -Path $LocalCredPath -Childpath 'Babystats.cred.xml'
$TelldusCredPath = Join-Path -Path $LocalCredPath -Childpath 'Telldus.cred.xml'

if (-not (Test-Path $LocalCredPath)) {
New-Item -Path $Env:AppData\WindowsPowerShell -Name Credentials -ItemType Directory
}

if (-not (Test-Path $LocalUserCredPath)) {
Get-Credential | Export-Clixml -Path $LocalUserCredPath
}

if (-not (Test-Path $WorkCredPath)) {
Get-Credential | Export-Clixml -Path $WorkCredPath
}

if (-not (Test-Path $TelldusCredPath)) {
Get-Credential | Export-Clixml -Path $TelldusCredPath
}

if (-not (Test-Path $BabyStatsCredPath)) {
Get-Credential | Export-Clixml -Path $BabyStatsCredPath
}


$LocalCred = Import-Clixml -Path $LocalUserCredPath
$WorkCred = Import-Clixml -Path $WorkCredPath
$BabyStatsCred = Import-Clixml -Path $BabyStatsCredPath
$TelldusCred = Import-Clixml -Path $TelldusCredPath

#endregion

#region Children

Get-Baby

$stats = Get-BabyStats -Credential $BabyStatsCred

# View data
$stats | Out-GridView

# View sleep data
$stats | Where-Object Activity -eq 'Sleep' | Out-GridView

# View activity data
$stats | Where-Object Activity -eq 'Activity' | Out-GridView

# Group data
$stats| Group-Object Activity | Sort-Object count -Descending

#endregion

#region Home Automation

# Telldus (module created by Anders Wahlqvist, http://dollarunderscore.azurewebsites.net/?p=371)

$TDUsername = $TelldusCred.UserName
$TDPassword = (ConvertFrom-SecureToPlain -SecurePassword $TelldusCred.Password)

    $PSDefaultParameterValues += @{
        "*-TD*:Username" = $TDUsername
        "*-TD*:Password" = $TDPassword
    }

$TDDevices = Get-TDDevice

$TDDevices | Out-GridView

# Select single device and turn on
$TDDevices | Out-GridView -OutputMode Single -PipelineVariable TDDevice | foreach {Set-TDDevice -DeviceID $TDDevice.DeviceID -Action turnOn}

# Select single device and turn off
$TDDevices | Out-GridView -OutputMode Single -PipelineVariable TDDevice | foreach {Set-TDDevice -DeviceID $TDDevice.DeviceID -Action turnOff}

# Select devices to view sensor data
Get-TDSensor | Out-GridView -PassThru -PipelineVariable TDDevice | foreach {Get-TDSensorData -DeviceID $TDDevice.DeviceID} | Out-GridView

# Select devices to view rain sensor data
Get-TDSensor | Out-GridView -PassThru -PipelineVariable TDDevice | foreach {Get-TDRainSensorData -DeviceID $TDDevice.DeviceID} | Out-GridView

# Select devices to view wind sensor data
Get-TDSensor | Out-GridView -PassThru -PipelineVariable TDDevice | foreach {Get-TDWindSensorData -DeviceID $TDDevice.DeviceID} | Out-GridView

#endregion

#region Work

Get-Office365MailboxCalendarAppointment -NumberOfDays 5 -Cred $workcred

#endregion

#region Local computer

# Scheduled jobs
Get-ScheduledJob | Select-Object -Property Name,@{N='Frequency';E={$PSItem.JobTriggers[0].Frequency}},@{N='Time';E={$PSItem.JobTriggers[0].At}} | Out-GridView

# DSC Status
Get-DscConfigurationStatus -All
Get-DscLocalConfigurationManager
$dsctest = Test-DscConfiguration -Detailed
$dsctest | Select-Object -ExpandProperty ResourcesInDesiredState | Format-Table InstanceName,InDesiredState

#endregion

#region Misc
Connect-RDP

Find-Script -StartPath ~\Documents\WindowsPowerShell -Keyword cim

Get-Command -Module MyCoreTools

Show-Calendar

Get-SystemInfo

Get-Excuse

$psISE.CurrentPowerShellTab.VerticalAddOnTools.Where({$PSItem.Name -eq 'Azure Automation ISE add-on'}).ForEach({ $PSItem.IsVisible = $true })

$psISE.CurrentPowerShellTab.VerticalAddOnTools.Where({$PSItem.Name -eq 'Azure Automation ISE add-on'}).ForEach({ $PSItem.IsVisible = $false })

#endregion

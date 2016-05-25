# Press and hold Ctrl to skip profile loading
if ($host.Version.Major -gt 2) {


if ($host.Name -eq "ConsoleHost") {
Add-Type -AssemblyName PresentationCore
}


if([System.Windows.Input.Keyboard]::IsKeyDown("Ctrl")) { return }


}

#region Variables
$PSProfileRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
try {
. (Join-Path -Path $PSProfileRoot -ChildPath Environments\All\Variables.ps1 -Resolve -ErrorAction stop)
}
catch {Write-Warning "Variables-file not found"}
#endregion

#region Functions

try {
$functions = Join-Path -Path $PSProfileRoot -ChildPath Environments\All\Functions.ps1 -Resolve -ErrorAction stop
. $functions
}
catch {Write-Warning "Functions-file not found"}

#endregion

#region Modules

if (Get-Module -ListAvailable -Name MyCoreTools) {
Import-Module MyCoreTools
}

if ((Get-Module -ListAvailable -Name TabExpansionPlusPlus) -and $host.Version.Major -ge 3 -and $host.Name -eq "ConsoleHost") {
Import-Module TabExpansionPlusPlus
}

if ((Get-Module -ListAvailable -Name PSReadLine) -and $host.Version.Major -ge 3 -and $host.Name -eq "ConsoleHost") {
Import-Module PSReadLine
}

if (Get-Module -ListAvailable -Name FormatPx) {
Import-Module FormatPx
}

#endregion

#region PSDrives

try {

$PSDrive = Join-Path -Path $PSProfileRoot -ChildPath Scripts -Resolve -ErrorAction stop
New-PSDrive -Name Scripts -Root $PSDrive -PSProvider filesystem | Out-Null
}
catch {Write-Warning "Scripts-folder not found, PSDrive Scripts not loaded"}

#endregion

#region Environment specific set up

switch ($env:USERDOMAIN)
{
    'CRAYON' {
try {

$EnvironmentPath = Join-Path -Path $PSProfileRoot -ChildPath Environments\CRAYON\setup.ps1

if (Test-Path -Path $EnvironmentPath) {

# Dot source environment profile
. $EnvironmentPath

} else {

Write-Warning "Crayon customization script not available"

}

}
catch {
      
      Write-Warning "An error occured while loading environment profile $($EnvironmentPath)"
      Write-Warning $error[0].Exception

    }
}
    'CUSTOMER-A' {
try {

$EnvironmentPath = Join-Path -Path $PSProfileRoot -ChildPath Environments\CustomerA\setup.ps1

if (Test-Path -Path $EnvironmentPath) {

# Dot source environment profile
. $EnvironmentPath

} else {

Write-Warning "CustomerA customization script not available"

}

}
catch {
      
      Write-Warning "An error occured while loading environment profile $($EnvironmentPath)"
      Write-Warning $error[0].Exception

}
}
    'DEMO' {

try {

$EnvironmentPath = Join-Path -Path $PSProfileRoot -ChildPath Environments\DEMO\setup.ps1

if (Test-Path -Path $EnvironmentPath) {

# Dot source environment profile
. $EnvironmentPath

} else {

Write-Warning "Crayon Demo customization script not available"

}

}
catch {

      
      Write-Warning "An error occured while loading environment profile $($EnvironmentPath)"
      Write-Warning $error[0].Exception


}
    }

}

# Computer-specific
switch -Wildcard ($env:Computername)
{
    "DEMOPC*" {

try {

$EnvironmentPath = Join-Path -Path $PSProfileRoot -ChildPath Environments\DEMO\setup.ps1

if (Test-Path -Path $EnvironmentPath) {

# Dot source environment profile
. $EnvironmentPath

} else {

Write-Warning "Crayon Demo customization script not available"

}

}
catch {
      
      Write-Warning "An error occured while loading environment profile $($EnvironmentPath)"
      Write-Warning $error[0].Exception

}
    }

}
#endregion

#region Info

try {
[bool] $HasInternetAccess = (Test-Port -computer vg.no -TCP -port 80 -TCPtimeout 100).Open -eq "True"
}

catch {
Write-Warning "Test-Port not available"
}

Write-Host "PowerShell Host: $($Host.Name)"
Write-Host "Version: $($Host.Version)"
Write-Host "PS Drives loaded:" -ForegroundColor yellow
Get-PSDrive -PSProvider FileSystem | Format-Table Name,Root -AutoSize
if (Get-Module) {
Write-Host "Modules loaded on startup:" -ForegroundColor yellow
(Get-Module).Name
}
if ((Get-Command Get-QOTD -ErrorAction SilentlyContinue) -and $HasInternetAccess) {
Write-Host "Quote of the day:" -ForegroundColor yellow
Get-QOTD
}

if ($HasInternetAccess) {
Write-Host "Internet access: $HasInternetAccess" -ForegroundColor yellow
} else {
Write-Host "Internet access: $false" -ForegroundColor yellow
}

#endregion

#region Aliases
try {
. (Join-Path -Path $PSProfileRoot -ChildPath Environments\All\Aliases.ps1 -Resolve -ErrorAction stop)
}
catch {}
#endregion

#region Misc

# Location
Set-Location -Path ~

# Prompt

try {
. (Join-Path -Path $PSProfileRoot -ChildPath Scripts\Core\Set-Prompt.ps1 -Resolve -ErrorAction stop)
}
catch {Write-Warning "Prompt customization script not available"}
#endregion
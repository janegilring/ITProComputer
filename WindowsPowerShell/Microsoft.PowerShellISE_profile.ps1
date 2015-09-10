$PSProfileRoot = Split-Path $MyInvocation.MyCommand.Path -Parent

# Variables


# Functions


# Modules


# Info


# Custom aliases


# PSDrives


# Location


# ISE

if ($env:computername -eq "NOOSLJANRING" -or $env:computername -eq "MGMT01" -or $env:computername -eq "MGMT02") {

Import-Module ISESteroids

}

# PowerShell ISE 2.0 customizations
if ($Host.Name -eq "Windows PowerShell ISE Host" -and $host.Version -eq "2.0") {


$psISE.Options.OutputPaneBackgroundColor = "#012456"
$psISE.Options.OutputPaneForegroundColor = "#EEEDF0"
$psISE.Options.OutputPaneTextBackgroundColor = "#012456"
$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Open Current Script Folder",{Invoke-Item (split-path $psise.CurrentFile.fullpath)},"ALT+O") | out-Null
$psise.options.fontsize=16
$psise.options.fontname="Consolas"

}
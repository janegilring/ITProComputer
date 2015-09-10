
if ($Host.Name -eq "Windows PowerShell ISE Host") {

if ($env:COMPUTERNAME -eq 'RDS10006') {

. \\tine.no\IKTDrift\PowerShell\Modules\modules.ps1

Import-Module PsISEProjectExplorer

}

$parent = $psise.CurrentPowerShellTab.AddOnsMenu.SubMenus.Add('Tine', $null, $null)

#$null = $parent.Submenus.Add('', { psedit '' }, $null )

$null = $parent.Submenus.Add('AD - Operations', { psedit '\\tine.no\IKTDrift\Home\adminrinjan\Documents\WindowsPowerShell\Environments\TINE\Scripts\AD\AD - Operations.ps1' }, $null )

$null = $parent.Submenus.Add('Author-DSCConfiguration', { psedit '\\tine.no\IKTDrift\Home\adminrinjan\Documents\WindowsPowerShell\Environments\TINE\Scripts\DSC\Author-DSCConfiguration.ps1' }, $null )

$null = $parent.Submenus.Add('Author-SmaRunbook', { psedit '\\tine.no\IKTDrift\Home\adminrinjan\Documents\WindowsPowerShell\Environments\TINE\Scripts\SMA\Author-SmaRunbook.ps1' }, $null )

$null = $parent.Submenus.Add('Cisco UCS - Operations', { psedit '\\tine.no\IKTDrift\Home\adminrinjan\Documents\WindowsPowerShell\Environments\TINE\Scripts\Cisco UCS\Cisco UCS - operations.ps1' }, $null )

$null = $parent.Submenus.Add('Daily Operations', { psedit '\\tine.no\IKTDrift\Home\adminrinjan\Documents\WindowsPowerShell\Environments\TINE\Scripts\Tine - Daily.ps1' }, $null )

$null = $parent.Submenus.Add('EMC PS Tool Kit', { psedit '\\tine.no\IKTDrift\Home\adminrinjan\Documents\WindowsPowerShell\Environments\TINE\Scripts\EMC\EMCPSToolKit.ps1' }, $null )

$null = $parent.Submenus.Add('Event Logs - Operations', { psedit '\\tine.no\IKTDrift\Home\adminrinjan\Documents\WindowsPowerShell\Environments\TINE\Scripts\Event Logs\Event Logs - Operations.ps1' }, $null )

$null = $parent.Submenus.Add('Networking - Operations', { psedit '\\tine.no\IKTDrift\Home\adminrinjan\Documents\WindowsPowerShell\Environments\TINE\Scripts\Network\Networking - Operations.ps1' }, $null )

$null = $parent.Submenus.Add('Open WAP', { Start-Process https://wapadmin.tine.no }, $null )

$null = $parent.Submenus.Add('SCOM - Operations', { psedit '\\tine.no\IKTDrift\Home\adminrinjan\Documents\WindowsPowerShell\Environments\TINE\Scripts\SC OM\SCOM - Operations.ps1' }, $null )

$null = $parent.Submenus.Add('Storage - Operations', { psedit '\\tine.no\IKTDrift\Home\adminrinjan\Documents\WindowsPowerShell\Environments\TINE\Scripts\File Services\Storage - Operations.ps1' }, $null )

$null = $parent.Submenus.Add('Tine - environment setup', { psedit '\\tine.no\IKTDrift\Home\adminrinjan\Documents\WindowsPowerShell\Environments\TINE\setup.ps1' }, $null )

$null = $parent.Submenus.Add('Tine - Git folder', { Invoke-Item C:\Users\adminrinjan\Git }, $null )

}

try
{
    Get-PSDrive sysint -ErrorAction stop
}
catch
{
    New-PSDrive -Name sysint -Root \\tine.no\IKTDrift\Home\adminrinjan\Documents\Sysinternals -PSProvider filesystem | Out-Null
}


try
{
    Get-PSDrive H -ErrorAction stop
}
catch
{
    New-PSDrive -Name H -Root \\tine.no\IKTDrift\Home\adminrinjan\Documents -PSProvider filesystem | Out-Null
}


$MaximumHistoryCount = 2048
$Global:logfile = "\\tine.no\IKTDrift\Home\adminrinjan\Documents\WindowsPowerShell\log.csv"
$truncateLogLines = 100
$History = @()
$History += '#TYPE Microsoft.PowerShell.Commands.HistoryInfo'
$History += '"Id","CommandLine","ExecutionStatus","StartExecutionTime","EndExecutionTime"'
if (Test-Path $logfile) {$history += (get-content $LogFile)[-$truncateLogLines..-1] | where {$_ -match '^"\d+"'} }
$history > $logfile
$History | select -Unique  |
           Convertfrom-csv -errorAction SilentlyContinue |
           Add-History -errorAction SilentlyContinue

$dcdatasentral = @("dc10005","dc10006","dc10007","dc10008")
$dcdatasentralindustriell = @("dc10009","dc10010")
#$hyp10020 = @("hyp10007","hyp10008","hyp10009","hyp10010")
$hypc10002 = @("HYP10020","HYP10021","HYP10022","HYP10023","HYP10024","HYP10025","HYP10120","HYP10121","HYP10122","HYP10123","HYP10124","HYP10125")
#$hypc10050 = @("hyp10051","hyp10052")
$hypc123001 = @("hyp123001","hyp123002")
$hypc220001 = @("hyp220001","hyp220002","hyp220003","hyp220004")
$hypjaren = @("hyp220001","hyp220002","hyp220003","hyp220004","hyp220005","hyp220006")
$hypc311001 = @("hyp311001","hyp311002")
$hypc321002 = @("hyp321004","hyp321005")
$hypc403001 = @("hyp403001","hyp403002","hyp403003","hyp403004")

$coresccm2007client = "C:\Windows\SysWOW64\CCM\SMSRAP.cpl"
$coresccm2007cpl = "C:\Windows\SysWOW64\CCM\SMSCFGRC.cpl"
$coresccm2012cpl = "C:\Windows\CCM\SMSCFGRC.cpl"
$coresccm2012SoftwareCenter = "C:\Windows\CCM\SCClient.exe"

$SCOMAgentCP = "C:\Program Files\System Center Operations Manager\Agent\AgentControlPanel.exe"

$rpsettings = "C:\Program Files\EMC\Cluster-Enabler\Plugin\RP\RPInit.exe"

$isomake = "h:\Install\oscdimg.exe c:\temp\ c:\temp\file.iso -u2 -h -m"

$powerpathlic = "BGPH-AB4L-FFAM-QFRQ-MG9A-LHHM"

$powerpathlicreg = "emcpreg -add BGPH-AB4L-FFAM-QFRQ-MG9A-LHHM"

$powerpath = "C:\Program Files\EMC\PowerPath\EMC_PowerPath_Console.msc"

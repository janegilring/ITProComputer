# ISE

if ($Host.Name -eq "Windows PowerShell ISE Host") {
$parent = $psise.CurrentPowerShellTab.AddOnsMenu.SubMenus.Add('DEMO - Operations', $null, $null)

$null = $parent.Submenus.Add('AD - Operations', { psedit '~\Git\CrayonDemo-ITPro-Computer\WindowsPowerShell\Environments\DEMO\Scripts\Operations\AD - Operations.ps1' }, $null )

$null = $parent.Submenus.Add('Cisco UCS - Operations', { psedit '~\Git\CrayonDemo-ITPro-Computer\WindowsPowerShell\Environments\DEMO\Scripts\Operations\Cisco UCS\Cisco UCS - operations.ps1' }, $null )

$null = $parent.Submenus.Add('Daily - local computer', { psedit '~\Git\CrayonDemo-ITPro-Computer\WindowsPowerShell\Environments\DEMO\Scripts\Operations\Daily - local computer.ps1' }, $null )

$null = $parent.Submenus.Add('Networking - Operations', { psedit '~\Git\CrayonDemo-ITPro-Computer\WindowsPowerShell\Environments\DEMO\Scripts\Operations\Networking - Operations.ps1' }, $null )

}

# PS Drives
#New-PSDrive -Name scripts -Root '~\Git\CrayonDemo-ITPro-Computer\WindowsPowerShell\Environments\DEMO\Scripts' -PSProvider filesystem | Out-Null

#New-PSDrive -Name sysint -Root \\crayonlab.no\IKTDrift\AdminHome\adm_janring\Documents\Sysinternals -PSProvider filesystem | Out-Null
#New-PSDrive -Name h -Root \\crayonlab.no\IKTDrift\AdminHome\adm_janring\Documents -PSProvider filesystem | Out-Null

# Variables
$coresccm1 = "C:\Windows\SysWOW64\CCM\SMSRAP.cpl"
$coresccm2 = "C:\Windows\SysWOW64\CCM\SMSCFGRC.cpl"
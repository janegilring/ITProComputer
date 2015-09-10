#region Module import and configuration

Get-Module -ListAvailable -Name CiscoUcsPS

# Importere Cisco UCS modul (ikke nødvendig i PowerShell 3.0 og nyere hvor module autoloading er aktivert by default)
Import-Module CiscoUcsPS

#Get-UcsPowerToolConfiguration

Set-UcsPowerToolConfiguration -SupportMultipleDefaultUcs $true 

$configpath = '\\dfs-path\Scripts\Cisco UCS\UCS-config.xml' 


#endregion Module import and configuration

#region Initial connection (one time)
#Connect-Ucs <ucsm-ip1>  
#Connect-Ucs <ucsm-ip2> 
Get-UcsStatus  
Disconnect-Ucs

# Lagre credentials i variabel (blir spurt om å angi passord)
$cred = Get-Credential -UserName ucs-lab.local\ucsadmin -Message 'UCS login'

$UCSSystems = Import-Csv \\dfs-path\Scripts\Cisco UCS\UCS-systems.csv
Connect-Ucs -Name $UCSSystems -Credential $cred


# Store credentials in a file; the stored credentials are encrypted with a user-specified key: 
Export-UcsPSSession -LiteralPath $configpath
Disconnect-Ucs 

#endregion


# Initiate login from credentials stored in a file:
Connect-Ucs -LiteralPath $configpath

Disconnect-Ucs

# Log into an additional system and add the credentials to the file: 
#Connect-Ucs <ucsm-ip3>  Export-UcsPSSession -Path 'C:\Work\labs.xml' –Merg


#region Cisco UCS Manager GUI

# Launch a Cisco UCS Manager GUI from a previously connected Cisco UCS session: 
$ucs = Get-UcsPSSession | Out-GridView -PassThru
Start-UcsGuiSession -Ucs $ucs

# Launch a Cisco UCS Manager GUI to a Cisco UCS domain that does not have a previous Cisco UCS PowerTool session: 
Start-UcsGuiSession -Name 10.10.10.10

#endregion


#region KVM GUI session

$UcsServiceProfile = Get-UcsServiceProfile | Out-GridView -PassThru
$UcsServiceProfile | Start-UcsKvmSession 

# Launch a KVM GUI session to a specific Cisco UCS blade server: 
Get-UcsBlade -Chassis 1 -SlotId 1 | Start-UcsKvmSession 

# Launch a KVM GUI session to a specific Cisco UCS rack-mount server:
Get-UcsRackUnit -Id 1 | Start-UcsKvmSession 

# Launch a KVM GUI session to a specific Cisco UCS service profile: 
Get-UcsServiceProfile -Name testsp -Org root | Start-UcsKvmSession

#endregion



#region Misc

# Liste aktive PowerShell-sesjoner mot UCS
Get-UcsPSSession | ft name

# Liste alle UCS profiler
Get-UcsServiceProfile | ft name


# Koble til KVM sesjon (Java-konsoll åpnes)
Get-UcsServiceProfile -Name SRV01| Start-UcsKvmSession

# Starte/stopp/resette servere

gcm *-UcsServer

$ucsserver = Get-UcsServer | Out-GridView -PassThru

Get-UcsServer

Start-UcsServer

Stop-UcsServer

Restart-UcsServer

Reset-UcsServer



$CredFileKey = ConvertTo-SecureString 'Passw0rd' -AsPlainText –Force
Export-UcsPSSession -LiteralPath C:\temp\ucstest.xml -Key $CredFileKey

Connect-Ucs -Key $key -LiteralPath .\ucstest.xml

<#
The following are examples of ConvertTo-UcsCmdlet usage: Get the XML requests along with generated cmdlets: ConvertTo-UcsCmdlet -Verbose Generate cmdlets for objects passed via pipelined input: Get-UcsServiceProfile -Name testsp -Hierarchy | ConvertTo-UcsCmdlet Generate cmdlets for actions in the specified GUI log: ConvertTo-UcsCmdlet -GuiLog -LiteralPath 'C:\Work\centrale_4711.log' 
 ConvertTo-UcsCmdlet -GuiLog -Path 'C:\Work\centrale_47*.log.?' Generate cmdlets for the specified XML request:  ConvertTo-UcsCmdlet -Xml -Request '<lsClone dn=”org-root/ls-sp1” inTargetOrg=”org-root” inServerName=”sp2” inHierarchical=”false”></lsClone>' Generate cmdlets for the specified XML requests in file: ConvertTo-UcsCmdlet -Xml -LiteralPath 'C:\Work\config.xml' Generate cmdlets from a Cisco UCS backup:  ConvertTo-UcsCmdlet -UcsBackup -LiteralPath 'C:\Work\config-all-backup.xml' -OutputPath 'C:\Work\output.ps1' 
 #>

 #endregion
# http://blogs.technet.com/b/josebda/archive/2015/04/18/windows-powershell-equivalents-for-common-networking-commands-ipconfig-ping-nslookup.aspx
# http://www.happysysadm.com/2015/05/moving-from-ping-netstat-and-ipconfig.html

# ipconfig

Get-NetIPAddress | Sort InterfaceIndex | FT InterfaceIndex, InterfaceAlias, AddressFamily, IPAddress, PrefixLength -Autosize
Get-NetIPAddress | ? AddressFamily -eq IPv4 | FT –AutoSize
Get-NetAdapter Ethernet | Get-NetIPAddress | FT -AutoSize

$cimsession = New-CIMsession -Computername srv01
Get-NetIPConfiguration -CimSession $cimsession
$ipconf = Get-NetIPConfiguration
$ipconf.DNSServer

Clear-DnsClientCache
Register-DnsClient

# ping

# New-Alias -Name ping -Value Test-Connection
Test-NetConnection www.microsoft.com
Test-NetConnection -ComputerName www.microsoft.com -InformationLevel Detailed
Test-NetConnection -ComputerName www.microsoft.com | Select -ExpandProperty PingReplyDetails | FT Address, Status, RoundTripTime
1..10 | % { Test-NetConnection -ComputerName www.microsoft.com -RemotePort 80 } | FT -AutoSize

# nslookup

Resolve-DnsName www.microsoft.com
Resolve-DnsName microsoft.com -type SOA
Resolve-DnsName microsoft.com -Server 8.8.8.8 –Type A

# route

Get-NetRoute -Protocol Local -DestinationPrefix 10.0*
Get-NetAdapter Ethernet | Get-NetRoute

Get-NetRoute | Sort-Object RouteMetric

# tracert

Test-NetConnection www.vg.no –TraceRoute
Test-NetConnection outlook.com -TraceRoute | Select -ExpandProperty TraceRoute | % { Resolve-DnsName $_ -type PTR -ErrorAction SilentlyContinue }

# netstat

# The greatest strength of Get-NetTCPConnection over netstat is the possibility to filter on connection state on the fly
Get-NetTCPConnection -State Established

# This means that you can easily filter down all connections which are in the state SYN_SENT, that is connections that are being blocked by a security firewall
Get-NetTCPConnection -State SynSent

# For completeness, the possible connection states accepted by Get-NetTCPConnection are: Closed, Listen, SynSent, SynReceived, Established, FinWait1, FinWait2, CloseWait, Closing, LastAck, TimeWait and DeleteTCB.

Get-NetTCPConnection | Group State, RemotePort | Sort Count | FT Count, Name –Autosize
Get-NetTCPConnection | Group State, LocalPort | Sort Count | FT Count, Name –Autosize
Get-NetTCPConnection | ? State -eq Established | FT –Autosize
Get-NetTCPConnection | ? State -eq Established | ? RemoteAddress -notlike 127* | % { $_; Resolve-DnsName $_.RemoteAddress -type PTR -ErrorAction SilentlyContinue }

#PSnmap
cd ~\Documents\WindowsPowerShell\Scripts\Network\PSnmap

.\PSnmap.ps1 -ComputerName 10.0.1.1/24 -Port 80,22,443,3389,5985 -Dns | sort computername | ft -a
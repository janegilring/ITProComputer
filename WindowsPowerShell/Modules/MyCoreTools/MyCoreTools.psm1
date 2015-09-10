function Set-DemoPrompt {

function global:prompt {"PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) "}


}

Function Copy-LastCommand { (Get-History)[-1].commandline | clip}

function nic {explorer.exe '::{7007ACC7-3202-11D1-AAD2-00805FC1270E}'}

Function Get-GeoIP {
param (
    [string]$IP 
)
    ([xml](Invoke-WebRequest "http://freegeoip.net/xml/$IP").Content).Response
}

function Get-RebootHistory {

[xml]$xml=@'
<QueryList>
<Query Id="0" Path="System">
<Select Path="System">*[System[(EventID=6005)]]</Select>
</Query>
</QueryList>
'@
 
Get-WinEvent -FilterXml $xml

}

Function Get-QOTD {

    [cmdletBinding()]

    Param()

    Write-Verbose "Starting Get-QOTD"
    #create the webclient object
    $webclient = New-Object System.Net.WebClient  
    
    #define the url to connect to
    $url="http://feeds.feedburner.com/brainyquote/QUOTEBR"
    
    Write-Verbose "Connecting to $url" 
    Try
    {
        #retrieve the url and save results to an XML document
        [xml]$data =$webclient.downloadstring($url)
        #parse out the XML document to get the first item which
        #will be the most recent quote
        $quote=$data.rss.channel.item[0]
    }
    Catch
    {
        $msg="There was an error connecting to $url"
        $msg+=$_.Exception.Message
        Write-Warning $msg
    }

    if ($quote)
    {
        Write-Verbose $quote.OrigLink
        "{0} - {1}" -f $quote.Description,$quote.Title
    }
    else
    {
        Write-Warning "Failed to get data from $url"
    }

    Write-Verbose "Ending Get-QOTD"

} #end function



Function Get-OutlookAppointments {
	param (
			[Int] $NumDays = 7,
			[DateTime] $Start = [DateTime]::Now ,
	      	[DateTime] $End   = [DateTime]::Now.AddDays($NumDays)
	)

	Process {
		$outlook = New-Object -ComObject Outlook.Application

		$session = $outlook.Session
		$session.Logon()

		$apptItems = $session.GetDefaultFolder(9).Items
		$apptItems.Sort("[Start]")
		$apptItems.IncludeRecurrences = $true
		$apptItems = $apptItems

		$restriction = "[End] >= '{0}' AND [Start] <= '{1}'" -f $Start.ToString("g"), $End.ToString("g")

		foreach($appt in $apptItems.Restrict($restriction))
		{
		    If (([DateTime]$Appt.Start -[DateTime]$appt.End).Days -eq "-1") {
				"All Day Event : {0} Orgainzed by {1}" -f $appt.Subject, $appt.Organizer
			}
			Else {
				"{0:ddd hh:mmtt} - {1:hh:mmtt} : {2} Organized by {3}" -f [DateTime]$appt.Start, [DateTime]$appt.End, $appt.Subject, $appt.Organizer
			}

		}

		$outlook = $session = $null;
	}
}


function Add-Clock {
 $code = { 
    $pattern = '\d{2}:\d{2}:\d{2}'
    do {
      $clock = Get-Date -format 'HH:mm:ss'

      $oldtitle = [system.console]::Title
      if ($oldtitle -match $pattern) {
        $newtitle = $oldtitle -replace $pattern, $clock
      } else {
        $newtitle = "$clock $oldtitle"
      }
      [System.Console]::Title = $newtitle
      Start-Sleep -Seconds 1
    } while ($true)
  }

 $ps = [PowerShell]::Create()
 $null = $ps.AddScript($code)
 $ps.BeginInvoke()
}


Function Get-Uptime {
<#
.SYNOPSIS 
	Displays Uptime since last reboot
.PARAMETER  Computername
.EXAMPLE
 Get-Uptime Server1
.EXAMPLE
 "Server1", "Server2"|Get-Uptime
.EXAMPLE
 (Get-Uptime Sever1)."Time Since Last Reboot"
#>    
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [Alias("Name")]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    PROCESS {

            foreach ($computer in $computername) {

 	$Now=Get-Date
 	$LastBoot=[System.Management.ManagementDateTimeConverter]::ToDateTime((Get-WmiObject win32_operatingsystem -ComputerName $($computer)).lastbootuptime)
 	$Result=@{ "Server"=$($Computer);
 	    	   "Last Reboot"=$LastBoot;
 	    	   "Time Since Reboot"="{0} Days {1} Hours {2} Minutes {3} Seconds" -f ($Now - $LastBoot).days, `
 			($Now - $LastBoot).hours,($Now - $LastBoot).minutes,($Now - $LastBoot).seconds}
 	Write-Output (New-Object psobject -Property $Result|select Server, "Last Reboot", "Time Since Reboot")

            }
      }
}


# http://www.leeholmes.com/blog/2009/09/15/powershell-equivalent-of-net-helpmsg/
function Get-Win32Exception ($ErrorCode)
{
    $lookup = [convert]::ToInt32($ErrorCode)
    [ComponentModel.Win32Exception] $lookup
}

New-Alias -Name Get-NetHelpMsg -Value Get-Win32Exception

Function Get-FolderSize

{

 BEGIN{$fso = New-Object -comobject Scripting.FileSystemObject}

 PROCESS{

    $path = $input.fullname

    $folder = $fso.GetFolder($path)

    $size = $folder.size

    [PSCustomObject]@{'Name' = $path;'Size' = ($size / 1gb) } } }

function Find-Script
{
    param
    (
        [Parameter(Mandatory=$true)]
        $Keyword,

        $Maximum = 20,
        $StartPath = $env:USERPROFILE
    )

    Get-ChildItem -Path $StartPath -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue |
      Select-String -SimpleMatch -Pattern $Keyword -List |
      Select-Object -Property FileName, Path, Line -First $Maximum |
      Out-GridView -Title 'Select Script File' -PassThru |
      ForEach-Object { ise $_.Path }
} 

function Get-Excuse
{
  $url = 'http://pages.cs.wisc.edu/~ballard/bofh/bofhserver.pl'
  $ProgressPreference = 'SilentlyContinue'
  $page = Invoke-WebRequest -Uri $url -UseBasicParsing
  $pattern = '<br><font size = "\+2">(.+)'

  if ($page.Content -match $pattern)
  {
    $matches[1]
  }
}

function Get-ScriptContent {
param (
$ScriptRoot = "scripts:\*.ps1",
$Pattern = "test"
)
Get-ChildItem -Path $ScriptRoot -Recurse |
Select-String -Pattern $Pattern -SimpleMatch |
Select-Object -Property Path -Unique
}

 function Set-PresentationMode (

        [Parameter(ParameterSetName='Start')]
        [switch]
        $On, 
        [Parameter(ParameterSetName='Stop')]
        [switch]
        $Off

)
{


switch ($PsCmdlet.ParameterSetName) 
    { 
    "Start"  { PresentationSettings /start  } 
    "Stop"  { PresentationSettings /stop  } 
    } 

  
}

New-Alias -Name spm -Value Set-PresentationMode

function Get-SystemInfo
{
  param($ComputerName = $env:ComputerName)

      $header = 'Hostname','OSName','OSVersion','OSManufacturer','OSConfig','Buildtype',`
'RegisteredOwner','RegisteredOrganization','ProductID','InstallDate','StartTime','Manufacturer',`
'Model','Type','Processor','BIOSVersion','WindowsFolder','SystemFolder','StartDevice','Culture',`
'UICulture','TimeZone','PhysicalMemory','AvailablePhysicalMemory','MaxVirtualMemory',`
'AvailableVirtualMemory','UsedVirtualMemory','PagingFile','Domain','LogonServer','Hotfix',`
'NetworkAdapter'
      systeminfo.exe /FO CSV /S $ComputerName | 
            Select-Object -Skip 1 | 
            ConvertFrom-CSV -Header $header
}

function Edit-HostsFile
{
   param($ComputerName=$env:COMPUTERNAME)
 
   Start-Process notepad.exe -ArgumentList \\$ComputerName\admin$\System32\drivers\etc\hosts -Verb RunAs
}

function Connect-RDP {
 
  param (
    [Parameter(Mandatory=$true)]
    $ComputerName,
 
    [System.Management.Automation.Credential()]
    $Credential
  )

  # Example: Connect-RDP 10.20.30.40, 10.20.30.41, 10.20.30.42 -Credential testdomain\Administrator
 
  # take each computername and process it individually
  $ComputerName | ForEach-Object {
 
    # if the user has submitted a credential, store it
    # safely using cmdkey.exe for the given connection
    if ($PSBoundParameters.ContainsKey('Credential'))
    {
      # extract username and password from credential
      $User = $Credential.UserName
      $Password = $Credential.GetNetworkCredential().Password
 
      # save information using cmdkey.exe
      cmdkey.exe /generic:$_ /user:$User /pass:$Password
    }
 
    # initiate the RDP connection
    # connection will automatically use cached credentials
    # if there are no cached credentials, you will have to log on
    # manually, so on first use, make sure you use -Credential to submit
    # logon credential
 
    mstsc.exe /v $_ /f
  }
}

Function Wait-RDP {
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Connection
    )
    do
    {
        $ConTest = (Test-NetConnection -ComputerName $Connection -CommonTCPPort RDP).TcpTestSucceeded
    }
    until ($ConTest -eq "True")
    mstsc /v:$Connection
}

function Get-Driver {

    driverquery /V /FO CSV | ConvertFrom-Csv | Out-GridView

}

function Get-ADClientSite {

[DirectoryServices.ActiveDirectory.ActiveDirectorySite]::GetComputerSite().Name

}

function Show-Calendar {
    <#
        .SYNOPSIS
            Show calendar.
        .DESCRIPTION
            This function is a PowerShell version of the *NIX cal command and will show a
            calendar of the chosen month(s). The current day will be marked with a '*'.
 
            For best results, use together with the FormatPx module by Kirk Munro.
        .EXAMPLE
            Show-Calendar
            Will show a calendar view of the current month.
        .EXAMPLE
            Show-Calendar 1 2015 -m 3
            Will show a calendar view of the first three months in 2015.
        .EXAMPLE
            Show-Calendar 12 -MarkDay 25
            Will show a calendar view of december and mark December 25.
        .EXAMPLE
            Show-Calendar 1 2015 -m 12 -MarkDate (Get-Date -Year 2015 -Month 2 -Day 14)
            Will show a calendar view of 2015 and mark 14th of February.
        .LINK
            https://github.com/KirkMunro/FormatPx
        .NOTES
            Author: Ã˜yvind Kallstad
            Date: 21.12.2014
            Version: 1.0
    #>
    [CmdletBinding(DefaultParameterSetName = 'MarkDay')]
    param (
        # The starting month number. Default is current month.
        [Parameter(Position = 0)]
        [ValidateRange(1,12)]
        [int] $Month = [DateTime]::Now.Month,
 
        # The starting year. Default is current year.
        [Parameter(Position = 1)]
        [ValidateRange(1,9999)]
        [int32] $Year = [DateTime]::Now.Year,
 
        # How many months to show. Default is 1.
        [Parameter()]
        [Alias('m')]
        [ValidateRange(1,[int]::MaxValue)]
        [int32] $Months = 1,
 
        # Day to mark on the calendar.
        [Parameter(ParameterSetName = 'MarkDay')]
        [ValidateRange(1,31)]
        [int32] $MarkDay,
 
        # Date to mark on the calendar.
        [Parameter(ParameterSetName = 'MarkDate')]
        [datetime] $MarkDate,
 
        # Choose the first day of the week. Default is 'Monday'.
        [Parameter()]
        [ValidateSet('Monday','Sunday')]
        [string] $FirstDayofWeek = 'Monday'
    )
 
    $calendar = [System.Globalization.CultureInfo]::InvariantCulture.Calendar
    $thisMonth = $Month - 1
    $script:MarkDay_ = $MarkDay
    $script:MarkDate_ = $MarkDate
    $output = @()
 
    function New-Week {
        [CmdletBinding()]
        param (
            [Parameter(Position = 0)]
            [ValidateSet('Monday','Sunday')]
            [string] $FirstDayofWeek = 'Monday'
        )
  
        $week = [Ordered] @{
            'Tuesday' = $null
            'Wednesday' = $null
            'Thursday' = $null
            'Friday' = $null
            'Saturday' = $null
        }
  
        if ($firstDayOfWeek -eq 'Monday') {
            $week.Insert(0, 'Monday', $null)
            $week.Add('Sunday', $null)
        }
  
        else {
            $week.Insert(0, 'Sunday', $null)
            $week.Insert(1, 'Monday', $null)
        }
  
        Write-Output $week
    }
 
    # loop through the months
    for ($i = 1; $i -le $Months; $i++) {
 
        # increment month
        $thisMonth++
 
        # when month is greater than 12, a new year is triggered, so reset month to 1 and increment year
        if ($thisMonth -gt 12) {
            $thisMonth = 1
            $Year++
        }
 
        # get the number of days in the month
        $daysInMonth = $calendar.GetDaysInMonth($Year,$thisMonth)
 
        # define new week
        $thisWeek = New-Week $FirstDayofWeek
        $thisWeek.Insert(0, 'Month', $null)
        $thisWeek.Insert(1, 'Year', $null)
        $thisWeek.Insert(2, 'Week', $null)
 
        # loop through each day in the month
        for ($y = 1; $y -lt ($daysInMonth + 1); $y++) {
 
            # get a datetime object of the current date
            $thisDate = New-Object -TypeName 'System.DateTime' -ArgumentList ($Year,$thisMonth,$y)
 
            # if current date is the first day of a week (but not if it's the very first day of the month at the same time)
            if (($thisDate.DayOfWeek -eq $FirstDayOfWeek) -and ($y -gt 1)) {
  
                # add the week object to the output array
                $weekObject = New-Object -TypeName 'PSCustomObject' -Property $thisWeek
                $output += $weekObject
  
                # reset the week
                $thisWeek = New-Week $FirstDayofWeek
                $thisWeek.Insert(0, 'Month', $null)
                $thisWeek.Insert(1, 'Year', $null)
                $thisWeek.Insert(2, 'Week', $null)
            }
  
            # get string representation of the month and the current week number (if week number is 53, change to 1)
            $monthString = [System.Threading.Thread]::CurrentThread.CurrentCulture.TextInfo.ToTitleCase($thisDate.ToString('MMMM',[System.Globalization.CultureInfo]::InvariantCulture))
            $thisWeekNumber = $calendar.GetWeekOfYear($thisDate,[System.Globalization.DateTimeFormatInfo]::InvariantInfo.CalendarWeekRule,[System.DayOfWeek]::$FirstDayOfWeek)
            if ($thisWeekNumber -eq 53) { $thisWeekNumber = 1 }
  
            # overload the ToString method of the datetime object
            $thisDate | Add-Member -MemberType ScriptMethod -Name 'ToString' -Value {
                if ($This.Day -eq $MarkDay_) {
                    $this.Day.ToString() + '!'
                }
 
                elseif (($this.Date) -eq ($MarkDate_.Date)) {
                    $this.Day.ToString() + '!'
                }
                 
                elseif (($this.Date) -eq ([DateTime]::Now.Date)) {
                    $this.Day.ToString() + '*'
                }
 
                else {
                    $this.Day.ToString()
                }
            } -Force
  
            # update the week hashtable with the current day, week, month and year
            $thisWeek[($thisDate.DayOfWeek)] = $thisDate
            $thisWeek['Week'] = $thisWeekNumber
            $thisWeek['Month'] = $monthString
            $thisWeek['Year'] = $Year
        }
 
        # add the final week to the output array
        $weekObject = New-Object -TypeName 'PSCustomObject' -Property $thisWeek
        $output += $weekObject
    }
 
    # if FormatPx is loaded, use it to format the output
    if (Get-Module -Name 'FormatPx') {
        if ($FirstDayofWeek -eq 'Monday') {$formatProperties = @{Property = 'Week','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'}}
        else {$formatProperties = @{Property = 'Week','Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'}}
        Write-Output ($output | Format-Table @formatProperties -AutoSize -GroupBy @{Name = 'Month';Expression = {"$($_.Month) $($_.Year)"}} -PersistWhenOutput)
    }
  
    # else use default PowerShell formatting
    else {
        Write-Output $output
    }
}
 
New-Alias -Name 'cal' -Value 'Show-Calendar' -Force


function Get-Office365MailboxCalendarAppointment ($cred,$NumberOfDays)
{
    Invoke-RestMethod -Uri ("https://outlook.office365.com/ews/odata/Me/Calendar/Events?`$filter=Start le " + (Get-Date).ToUniversalTime().AddDays($NumberOfDays).ToString("yyyy-MM-ddThh:mm:ssZ").Replace('.',':') + " and End ge " + (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddThh:mm:ssZ").Replace('.',':')) -Credential $cred | foreach-object{$_.Value}  | ft subject,start

}

function Get-Office365MailboxInboxUnread ($cred)
{

Invoke-RestMethod -Uri "https://outlook.office365.com/ews/odata/Me/Inbox/Messages?`$filter=IsRead eq false" -Credential $cred | foreach-object{$_.value | select Subject}


}

function Get-Office365MailboxContacts ($cred)
{

Invoke-RestMethod -Uri "https://outlook.office365.com/ews/odata/Me/Contacts" -Credential $cred | foreach-object{$_.value} | sort fileas | ft fileas

}

function Get-Phonetic {
    <#
    .Synopsis
       Generates a table with phonetic spelling from a collection of characters
    .DESCRIPTION
       Generates a table with phonetic spelling from a collection of characters
    .EXAMPLE
       "gjIgsj" | Get-Phonetic

       Input text: gjIgsj

       Char Phonetic
       ---- --------
          g golf    
          j juliett 
          I INDIA   
          g golf    
          s sierra  
          j juliett 
       
    .OUTPUTS
       [String]
    .NOTES
       Written by Simon Wåhlin, blog.simonw.se
       I take no responsibility for any issues caused by this script.
    #>
    Param (
        # List of characters to translate to phonetic alphabet
        [Parameter(Mandatory=$true,ValueFromPipeLine=$true)]
        [Char[]]$Char,
        # Hashtable containing a char as key and phonetic word as value
        [HashTable]$PhoneticTable = @{
            'a' = 'alpha'   ;'b' = 'bravo'   ;'c' = 'charlie';'d' = 'delta';
            'e' = 'echo'    ;'f' = 'foxtrot' ;'g' = 'golf'   ;'h' = 'hotel';
            'i' = 'india'   ;'j' = 'juliett' ;'k' = 'kilo'   ;'l' = 'lima' ;
            'm' = 'mike'    ;'n' = 'november';'o' = 'oscar'  ;'p' = 'papa' ;
            'q' = 'quebec'  ;'r' = 'romeo'   ;'s' = 'sierra' ;'t' = 'tango';
            'u' = 'uniform' ;'v' = 'victor'  ;'w' = 'whiskey';'x' = 'x-ray';
            'y' = 'yankee'  ;'z' = 'zulu'    ;'0' = 'Zero'   ;'1' = 'One'  ;
            '2' = 'Two'     ;'3' = 'Three'   ;'4' = 'Four'   ;'5' = 'Five' ;
            '6' = 'Six'     ;'7' = 'Seven'   ;'8' = 'Eight'  ;'9' = 'Niner';
            '.' = 'Point'   ;'!' = 'Exclamationmark';'?' = 'Questionmark';
        }
    )
    Process {
        $Result = Foreach($Character in $Char) {
            if($PhoneticTable.ContainsKey("$Character")) {
                if([Char]::IsUpper([Char]$Character)) {
                    [PSCustomObject]@{
                        Char = $Character;Phonetic = $PhoneticTable["$Character"].ToUpper()
                    }
                }
                else {
                    [PSCustomObject]@{
                        Char = $Character;Phonetic = $PhoneticTable["$Character"].ToLower()
                    }
                }
            }
            else {
                [PSCustomObject]@{
                    Char = $Character;Phonetic = $Character
                }
            }
            
        }
        "`n{0}`n{1}" -f ('Input text: {0}'-f-join$Char), ($Result | Format-Table -AutoSize | Out-String)
    }
}

function Show-Object {

#############################################################################
##
## Show-Object
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
##############################################################################

<#

.SYNOPSIS

Provides a graphical interface to let you explore and navigate an object.


.EXAMPLE

PS > $ps = { Get-Process -ID $pid }.Ast
PS > Show-Object $ps

#>

param(
    ## The object to examine
    [Parameter(ValueFromPipeline = $true)]
    $InputObject
)

Set-StrictMode -Version 3

Add-Type -Assembly System.Windows.Forms

## Figure out the variable name to use when displaying the
## object navigation syntax. To do this, we look through all
## of the variables for the one with the same object identifier.
$rootVariableName = dir variable:\* -Exclude InputObject,Args |
    Where-Object {
        $_.Value -and
        ($_.Value.GetType() -eq $InputObject.GetType()) -and
        ($_.Value.GetHashCode() -eq $InputObject.GetHashCode())
}

## If we got multiple, pick the first
$rootVariableName = $rootVariableName| % Name | Select -First 1

## If we didn't find one, use a default name
if(-not $rootVariableName)
{
    $rootVariableName = "InputObject"
}

## A function to add an object to the display tree
function PopulateNode($node, $object)
{
    ## If we've been asked to add a NULL object, just return
    if(-not $object) { return }

    ## If the object is a collection, then we need to add multiple
    ## children to the node
    if([System.Management.Automation.LanguagePrimitives]::GetEnumerator($object))
    {
        ## Some very rare collections don't support indexing (i.e.: $foo[0]).
        ## In this situation, PowerShell returns the parent object back when you
        ## try to access the [0] property.
        $isOnlyEnumerable = $object.GetHashCode() -eq $object[0].GetHashCode()

        ## Go through all the items
        $count = 0
        foreach($childObjectValue in $object)
        {
            ## Create the new node to add, with the node text of the item and
            ## value, along with its type
            $newChildNode = New-Object Windows.Forms.TreeNode
            $newChildNode.Text = "$($node.Name)[$count] = $childObjectValue : " +
                $childObjectValue.GetType()

            ## Use the node name to keep track of the actual property name
            ## and syntax to access that property.
            ## If we can't use the index operator to access children, add
            ## a special tag that we'll handle specially when displaying
            ## the node names.
            if($isOnlyEnumerable)
            {
                $newChildNode.Name = "@"
            }

            $newChildNode.Name += "[$count]"
            $null = $node.Nodes.Add($newChildNode)               

            ## If this node has children or properties, add a placeholder
            ## node underneath so that the node shows a '+' sign to be
            ## expanded.
            AddPlaceholderIfRequired $newChildNode $childObjectValue

            $count++
        }
    }
    else
    {
        ## If the item was not a collection, then go through its
        ## properties
        foreach($child in $object.PSObject.Properties)
        {
            ## Figure out the value of the property, along with
            ## its type.
            $childObject = $child.Value
            $childObjectType = $null
            if($childObject)
            {
                $childObjectType = $childObject.GetType()
            }

            ## Create the new node to add, with the node text of the item and
            ## value, along with its type
            $childNode = New-Object Windows.Forms.TreeNode
            $childNode.Text = $child.Name + " = $childObject : $childObjectType"
            $childNode.Name = $child.Name
            $null = $node.Nodes.Add($childNode)

            ## If this node has children or properties, add a placeholder
            ## node underneath so that the node shows a '+' sign to be
            ## expanded.
            AddPlaceholderIfRequired $childNode $childObject
        }
    }
}

## A function to add a placeholder if required to a node.
## If there are any properties or children for this object, make a temporary
## node with the text "..." so that the node shows a '+' sign to be
## expanded.
function AddPlaceholderIfRequired($node, $object)
{
    if(-not $object) { return }

    if([System.Management.Automation.LanguagePrimitives]::GetEnumerator($object) -or
        @($object.PSObject.Properties))
    {
        $null = $node.Nodes.Add( (New-Object Windows.Forms.TreeNode "...") )
    }
}

## A function invoked when a node is selected.
function OnAfterSelect
{
    param($Sender, $TreeViewEventArgs)

    ## Determine the selected node
    $nodeSelected = $Sender.SelectedNode

    ## Walk through its parents, creating the virtual
    ## PowerShell syntax to access this property.
    $nodePath = GetPathForNode $nodeSelected

    ## Now, invoke that PowerShell syntax to retrieve
    ## the value of the property.
    $resultObject = Invoke-Expression $nodePath
    $outputPane.Text = $nodePath

    ## If we got some output, put the object's member
    ## information in the text box.
    if($resultObject)
    {
        $members = Get-Member -InputObject $resultObject | Out-String       
        $outputPane.Text += "`n" + $members
    }
}

## A function invoked when the user is about to expand a node
function OnBeforeExpand
{
    param($Sender, $TreeViewCancelEventArgs)

    ## Determine the selected node
    $selectedNode = $TreeViewCancelEventArgs.Node

    ## If it has a child node that is the placeholder, clear
    ## the placeholder node.
    if($selectedNode.FirstNode -and
        ($selectedNode.FirstNode.Text -eq "..."))
    {
        $selectedNode.Nodes.Clear()
    }
    else
    {
        return
    }

    ## Walk through its parents, creating the virtual
    ## PowerShell syntax to access this property.
    $nodePath = GetPathForNode $selectedNode 

    ## Now, invoke that PowerShell syntax to retrieve
    ## the value of the property.
    Invoke-Expression "`$resultObject = $nodePath"

    ## And populate the node with the result object.
    PopulateNode $selectedNode $resultObject
}

## A function to handle keypresses on the form.
## In this case, we capture ^C to copy the path of
## the object property that we're currently viewing.
function OnKeyPress
{
    param($Sender, $KeyPressEventArgs)

    ## [Char] 3 = Control-C
    if($KeyPressEventArgs.KeyChar -eq 3)
    {
        $KeyPressEventArgs.Handled = $true

        ## Get the object path, and set it on the clipboard
        $node = $Sender.SelectedNode
        $nodePath = GetPathForNode $node
        [System.Windows.Forms.Clipboard]::SetText($nodePath)

        $form.Close()
    }
}

## A function to walk through the parents of a node,
## creating virtual PowerShell syntax to access this property.
function GetPathForNode
{
    param($Node)

    $nodeElements = @()

    ## Go through all the parents, adding them so that
    ## $nodeElements is in order.
    while($Node)
    {
        $nodeElements = ,$Node + $nodeElements
        $Node = $Node.Parent
    }

    ## Now go through the node elements
    $nodePath = ""
    foreach($Node in $nodeElements)
    {
        $nodeName = $Node.Name

        ## If it was a node that PowerShell is able to enumerate
        ## (but not index), wrap it in the array cast operator.
        if($nodeName.StartsWith('@'))
        {
            $nodeName = $nodeName.Substring(1)
            $nodePath = "@(" + $nodePath + ")"
        }
        elseif($nodeName.StartsWith('['))
        {
            ## If it's a child index, we don't need to
            ## add the dot for property access
        }
        elseif($nodePath)
        {
            ## Otherwise, we're accessing a property. Add a dot.
            $nodePath += "."
        }

        ## Append the node name to the path
        $nodePath += $nodeName
    }

    ## And return the result
    $nodePath
}

## Create the TreeView, which will hold our object navigation
## area.
$treeView = New-Object Windows.Forms.TreeView
$treeView.Dock = "Top"
$treeView.Height = 500
$treeView.PathSeparator = "."
$treeView.Add_AfterSelect( { OnAfterSelect @args } )
$treeView.Add_BeforeExpand( { OnBeforeExpand @args } )
$treeView.Add_KeyPress( { OnKeyPress @args } )

## Create the output pane, which will hold our object
## member information.
$outputPane = New-Object System.Windows.Forms.TextBox
$outputPane.Multiline = $true
$outputPane.ScrollBars = "Vertical"
$outputPane.Font = "Consolas"
$outputPane.Dock = "Top"
$outputPane.Height = 300

## Create the root node, which represents the object
## we are trying to show.
$root = New-Object Windows.Forms.TreeNode
$root.Text = "$InputObject : " + $InputObject.GetType()
$root.Name = '$' + $rootVariableName
$root.Expand()
$null = $treeView.Nodes.Add($root)

## And populate the initial information into the tree
## view.
PopulateNode $root $InputObject

## Finally, create the main form and show it.
$form = New-Object Windows.Forms.Form
$form.Text = "Browsing " + $root.Text
$form.Width = 1000
$form.Height = 800
$form.Controls.Add($outputPane)
$form.Controls.Add($treeView)
$null = $form.ShowDialog()
$form.Dispose()

}

 
Function Get-WindowsUpdateLog {
[cmdletbinding()]
 
Param(
[Parameter(Position=0,ValueFromPipeline)]
[ValidateNotNullorEmpty()]
[string[]]$Computername = $env:COMPUTERNAME
)
 
Begin {
    Write-Verbose "Starting $($MyInvocation.Mycommand)"  
    $header = "Date","Time","PID","TID","Component","Message"
} #begin
 
Process {
    Write-Verbose "Processing Windows Update Log on $($($computername.toUpper()) -join ",")"
    #define a scriptblock to run remotely
    $sb = {
    Import-Csv -Delimiter `t -Header $using:header -Path C:\windows\WindowsUpdate.log |
    Select-Object @{Name="DateTime";Expression={
    "$($_.date) $($_.time.Substring(0,8))" -as [datetime]}},
    @{Name="PID";Expression={$_.PID -as [int]}},
    @{Name="TID";Expression={$_.TID -as [int]}},Component,Message
    }
 
    Try {
       Invoke-Command -ScriptBlock $sb -ComputerName $Computername -errorAction Stop |
       Select * -ExcludeProperty RunspaceID
 
    }
    Catch {
        Throw $_
    }
} #process
 
End {
    Write-Verbose "Ending $($MyInvocation.Mycommand)"
} #end
 
} #end function

function Out-OneNote
{
<#
.Synopsis
   Send a quick note to a OneNote page
.DESCRIPTION
   Requires OneNote 2013. 
.EXAMPLE
   Send-Note -Note "Remember to call Frank on 12/12 by lunch"

   will create a new page in OneNote in the General section with the message above
.NOTES
   General notes
.ROLE
   Get things done GTD
.FUNCTIONALITY
   Quickly make notes in OneNote from powershell
#>
[cmdletbinding()]
Param(
    [string]$Note
    ,
    [String]$SectionName = "General"
)
    #http://stackoverflow.com/questions/8186819/creating-new-one-note-2010-page-from-c-sharp
    $f = $MyInvocation.InvocationName
    Write-Verbose -Message "$f - START"

    $onenote = New-Object -ComObject OneNote.Application -ErrorAction SilentlyContinue
    if (-not $onenote)
    { 
        throw "Error - Unable to create OneNoe application object (COMobject error)"
    }

    $scope = [Microsoft.Office.Interop.OneNote.HierarchyScope]::hsPages
    [ref]$xml = ""

    $onenote.GetHierarchy($null, $scope, $xml)

    $schema = @{one="http://schemas.microsoft.com/office/onenote/2013/onenote"}
    
    $xpath = "//one:Notebook/one:Section"
    Select-Xml -Xml ([xml]$xml.Value) -Namespace $schema -XPath $xpath | foreach {
        if ($psitem.Node.Name -eq $SectionName)
        { 
            $SectionID = $psitem.Node.ID
        }
    }

    if (-not $SectionID)
    { 
        throw "Unable to find Section with name $SectionName"
    }

    [ref]$newpageID =""
    $onenote.CreateNewPage("$SectionID",[ref]$newpageID,[Microsoft.Office.Interop.OneNote.NewPageStyle]::npsBlankPageWithTitle)

    if (-not $newpageID.Value)
    { 
        throw "Unable to create new OneNote page"
    }

    [ref]$NewPageXML = ""
    $onenote.GetPageContent($newpageID.Value,[ref]$NewPageXML,[Microsoft.Office.Interop.OneNote.PageInfo]::piAll)

    if (-not $NewPageXML)
    { 
        throw "Unable to get OneNote page content"
    }

    [Reflection.Assembly]::LoadWithPartialName("System.Xml.Linq") | Out-Null
    $xDoc = [System.Xml.Linq.XDocument]::Parse($NewPageXML.Value)

    $title = $xDoc.Descendants() | where Name -like "*}T"

    if (-not $title)
    { 
        throw "Unable to get title of new onenote page"
    }

    $title.Value = "$Note"

    $onenote.UpdatePageContent($xDoc.ToString())

$here = @"
    <one:Page xmlns:one="http://schemas.microsoft.com/office/onenote/2013/onenote" ID="$($newpageID.Value)" >
            <one:Outline>
                <one:Position x="36.0" y="86.4000015258789" z="0" />
                <one:Size width="117.001953125" height="40.28314971923828" />
                <one:OEChildren> 
                    <one:OE>
                        <one:T><![CDATA[$Note]]></one:T>
                    </one:OE>
                </one:OEChildren>                
            </one:Outline>
    </one:Page>
"@

    $onenote.UpdatePageContent($here)
}

function Test-Port {
<#
.SYNOPSIS
    Tests port on computer.  

.DESCRIPTION
    Tests port on computer. 

.PARAMETER computer
    Name of server to test the port connection on.

.PARAMETER port
    Port to test 

.PARAMETER tcp
    Use tcp port 

.PARAMETER udp
    Use udp port  

.PARAMETER UDPTimeOut
    Sets a timeout for UDP port query. (In milliseconds, Default is 1000)  

.PARAMETER TCPTimeOut
    Sets a timeout for TCP port query. (In milliseconds, Default is 1000)

.NOTES
    Name: Test-Port.ps1
    Author: Boe Prox
    DateCreated: 18Aug2010
    List of Ports: http://www.iana.org/assignments/port-numbers  

    To Do:
        Add capability to run background jobs for each host to shorten the time to scan.
.LINK    

https://boeprox.wordpress.org

.EXAMPLE
    Test-Port -computer 'server' -port 80
    Checks port 80 on server 'server' to see if it is listening  

.EXAMPLE
    'server' | Test-Port -port 80
    Checks port 80 on server 'server' to see if it is listening 

.EXAMPLE
    Test-Port -computer @("server1","server2") -port 80
    Checks port 80 on server1 and server2 to see if it is listening  

.EXAMPLE
    Test-Port -comp dc1 -port 17 -udp -UDPtimeout 10000

    Server   : dc1
    Port     : 17
    TypePort : UDP
    Open     : True
    Notes    : "My spelling is Wobbly.  It's good spelling but it Wobbles, and the letters
            get in the wrong places." A. A. Milne (1882-1958)

    Description
    -----------
    Queries port 17 (qotd) on the UDP port and returns whether port is open or not

.EXAMPLE
    @("server1","server2") | Test-Port -port 80
    Checks port 80 on server1 and server2 to see if it is listening  

.EXAMPLE
    (Get-Content hosts.txt) | Test-Port -port 80
    Checks port 80 on servers in host file to see if it is listening 

.EXAMPLE
    Test-Port -computer (Get-Content hosts.txt) -port 80
    Checks port 80 on servers in host file to see if it is listening 

.EXAMPLE
    Test-Port -computer (Get-Content hosts.txt) -port @(1..59)
    Checks a range of ports from 1-59 on all servers in the hosts.txt file      

#>
[cmdletbinding(
    DefaultParameterSetName = '',
    ConfirmImpact = 'low'
)]
    Param(
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ParameterSetName = '',
            ValueFromPipeline = $True)]
            [array]$computer,
        [Parameter(
            Position = 1,
            Mandatory = $True,
            ParameterSetName = '')]
            [array]$port,
        [Parameter(
            Mandatory = $False,
            ParameterSetName = '')]
            [int]$TCPtimeout=1000,
        [Parameter(
            Mandatory = $False,
            ParameterSetName = '')]
            [int]$UDPtimeout=1000,
        [Parameter(
            Mandatory = $False,
            ParameterSetName = '')]
            [switch]$TCP,
        [Parameter(
            Mandatory = $False,
            ParameterSetName = '')]
            [switch]$UDP
        )
    Begin {
        If (!$tcp -AND !$udp) {$tcp = $True}
        #Typically you never do this, but in this case I felt it was for the benefit of the function
        #as any errors will be noted in the output of the report
        $ErrorActionPreference = "SilentlyContinue"
        $report = @()
    }
    Process {
        ForEach ($c in $computer) {
            ForEach ($p in $port) {
                If ($tcp) {
                    #Create temporary holder
                    $temp = "" | Select Server, Port, TypePort, Open, Notes
                    #Create object for connecting to port on computer
                    $tcpobject = new-Object system.Net.Sockets.TcpClient
                    #Connect to remote machine's port
                    $connect = $tcpobject.BeginConnect($c,$p,$null,$null)
                    #Configure a timeout before quitting
                    $wait = $connect.AsyncWaitHandle.WaitOne($TCPtimeout,$false)
                    #If timeout
                    If(!$wait) {
                        #Close connection
                        $tcpobject.Close()
                        Write-Verbose "Connection Timeout"
                        #Build report
                        $temp.Server = $c
                        $temp.Port = $p
                        $temp.TypePort = "TCP"
                        $temp.Open = "False"
                        $temp.Notes = "Connection to Port Timed Out"
                    } Else {
                        $error.Clear()
                        $tcpobject.EndConnect($connect) | out-Null
                        #If error
                        If($error[0]){
                            #Begin making error more readable in report
                            [string]$string = ($error[0].exception).message
                            $message = (($string.split(":")[1]).replace('"',"")).TrimStart()
                            $failed = $true
                        }
                        #Close connection
                        $tcpobject.Close()
                        #If unable to query port to due failure
                        If($failed){
                            #Build report
                            $temp.Server = $c
                            $temp.Port = $p
                            $temp.TypePort = "TCP"
                            $temp.Open = "False"
                            $temp.Notes = "$message"
                        } Else{
                            #Build report
                            $temp.Server = $c
                            $temp.Port = $p
                            $temp.TypePort = "TCP"
                            $temp.Open = "True"
                            $temp.Notes = ""
                        }
                    }
                    #Reset failed value
                    $failed = $Null
                    #Merge temp array with report
                    $report += $temp
                }
                If ($udp) {
                    #Create temporary holder
                    $temp = "" | Select Server, Port, TypePort, Open, Notes
                    #Create object for connecting to port on computer
                    $udpobject = new-Object system.Net.Sockets.Udpclient
                    #Set a timeout on receiving message
                    $udpobject.client.ReceiveTimeout = $UDPTimeout
                    #Connect to remote machine's port
                    Write-Verbose "Making UDP connection to remote server"
                    $udpobject.Connect("$c",$p)
                    #Sends a message to the host to which you have connected.
                    Write-Verbose "Sending message to remote host"
                    $a = new-object system.text.asciiencoding
                    $byte = $a.GetBytes("$(Get-Date)")
                    [void]$udpobject.Send($byte,$byte.length)
                    #IPEndPoint object will allow us to read datagrams sent from any source.
                    Write-Verbose "Creating remote endpoint"
                    $remoteendpoint = New-Object system.net.ipendpoint([system.net.ipaddress]::Any,0)
                    Try {
                        #Blocks until a message returns on this socket from a remote host.
                        Write-Verbose "Waiting for message return"
                        $receivebytes = $udpobject.Receive([ref]$remoteendpoint)
                        [string]$returndata = $a.GetString($receivebytes)
                        If ($returndata) {
                           Write-Verbose "Connection Successful"
                            #Build report
                            $temp.Server = $c
                            $temp.Port = $p
                            $temp.TypePort = "UDP"
                            $temp.Open = "True"
                            $temp.Notes = $returndata
                            $udpobject.close()
                        }
                    } Catch {
                        If ($Error[0].ToString() -match "\bRespond after a period of time\b") {
                            #Close connection
                            $udpobject.Close()
                            #Make sure that the host is online and not a false positive that it is open
                            If (Test-Connection -comp $c -count 1 -quiet) {
                                Write-Verbose "Connection Open"
                                #Build report
                                $temp.Server = $c
                                $temp.Port = $p
                                $temp.TypePort = "UDP"
                                $temp.Open = "True"
                                $temp.Notes = ""
                            } Else {
                                <#
                                It is possible that the host is not online or that the host is online,
                                but ICMP is blocked by a firewall and this port is actually open.
                                #>
                                Write-Verbose "Host maybe unavailable"
                                #Build report
                                $temp.Server = $c
                                $temp.Port = $p
                                $temp.TypePort = "UDP"
                                $temp.Open = "False"
                                $temp.Notes = "Unable to verify if port is open or if host is unavailable."
                            }
                        } ElseIf ($Error[0].ToString() -match "forcibly closed by the remote host" ) {
                            #Close connection
                            $udpobject.Close()
                            Write-Verbose "Connection Timeout"
                            #Build report
                            $temp.Server = $c
                            $temp.Port = $p
                            $temp.TypePort = "UDP"
                            $temp.Open = "False"
                            $temp.Notes = "Connection to Port Timed Out"
                        } Else {
                            $udpobject.close()
                        }
                    }
                    #Merge temp array with report
                    $report += $temp
                }
            }
        }
    }
    End {
        #Generate Report
        $report
    }
}

function Get-BabyStats {
param (

$Credential = (Get-Credential 'jan.egil.ring@outlook.com'),
$StartDate = ((Get-Date).Month.ToString() + '/' + (Get-Date).Day.ToString() + '/' + (Get-Date).Year.ToString()),
$Period = 'Day',
$Kid = '5751483690123264'

)

#Helper function
function ConvertFrom-SecureToPlain {
    
    param( [Parameter(Mandatory=$true)][System.Security.SecureString] $SecurePassword)
    
    # Create a "password pointer"
    $PasswordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
    
    # Get the plain text version of the password
    $PlainTextPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto($PasswordPointer)
    
    # Free the pointer
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($PasswordPointer)
    
    # Return the plain text password
    $PlainTextPassword
    
}

switch ($Period) {

'Day' {$DataUri = "https://www.baby-connect.com/GetCmd?cmd=StatusExport&kid=$Kid&exportType=1&dt=$StartDate"}
'Week' {$DataUri = "https://www.baby-connect.com/GetCmd?cmd=StatusExport&kid=$Kid&exportType=3&dt=$StartDate"}
'Month' {$DataUri = "https://www.baby-connect.com/GetCmd?cmd=StatusExport&kid=$Kid&exportType=2&dt=$StartDate"}

}

Write-Verbose -Message "DataUri: $DataUri"

$URL = 'https://www.baby-connect.com/login'
$req = Invoke-WebRequest -Uri $URL -SessionVariable bc
 
$form = $req.Forms[0]
 
$form.Fields["email"]=$Credential.UserName
$form.Fields["pass"]=(ConvertFrom-SecureToPlain -SecurePassword $Credential.Password)
 
$req2 = Invoke-WebRequest -Uri ("https://www.baby-connect.com" + $form.Action) -WebSession $bc -Method POST -Body $form.Fields

$tempfile = (New-TemporaryFile).fullname
Invoke-WebRequest -Uri $DataUri -WebSession $bc -OutFile $tempfile

Import-Csv -Path $tempfile

Write-Verbose -Message "Temp-file: $tempfile"


}

function Get-Baby {
 
param($Name)
 
[pscustomobject] @{
Name = 'Samuel'
Gender = 'Boy'
Height = '51 cm'
Weight = '4 400 g'
Born = (Get-Date 'torsdag 14. mai 2015 12.22.00')
  } | Format-Table -AutoSize
 
 
}  


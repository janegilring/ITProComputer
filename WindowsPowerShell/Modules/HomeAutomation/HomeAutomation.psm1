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


function Get-TDDevice
{
    <#
    .SYNOPSIS
    Retrieves all devices associated with a Telldus Live! account.

    .DESCRIPTION
    This command will list all devices associated with an Telldus Live!-account and their current status and other information.

    .EXAMPLE
    Get-TDDevice -Username myemail@telldus.com -Password MyTelldusPassword

    .EXAMPLE
    Get-TDDevice -Username myemail@telldus.com -Password MyTelldusPassword | Format-Table

    .PARAMETER Username
    The username (e-mail) used to log into Telldus Live!

    .PARAMETER Password
    The password used to log into Telldus Live!

    #>

    param(
      [Parameter(Mandatory=$True)] [string] $Username,
      [Parameter(Mandatory=$True)] [string] $Password
    )

    $LoginPostURI="https://login.telldus.com/openid/server?openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.mode=checkid_setup&openid.return_to=http%3A%2F%2Fapi.telldus.com%2Fexplore%2Fclients%2Flist&openid.realm=http%3A%2F%2Fapi.telldus.com&openid.ns.sreg=http%3A%2F%2Fopenid.net%2Fextensions%2Fsreg%2F1.1&openid.sreg.required=email&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select#"
    $turnOffURI="http://api.telldus.com/explore/device/turnOff"
    $deviceListURI="http://api.telldus.com/explore/devices/list"
    $PostActionURI="http://api.telldus.com/explore/doCall"
    $Action='list'
    $SupportedMethods=19
    $TelldusWEB = Invoke-WebRequest $turnOffURI -SessionVariable Telldus

    $form = $TelldusWEB.Forms[0]
    $form.Fields["email"] = $Username
    $form.Fields["password"] = $Password

    $TelldusWEB = Invoke-WebRequest -Uri $LoginPostURI -WebSession $Telldus -Method POST -Body $form.Fields

    $request = @{'group'='devices';'method'= $Action;'param[supportedMethods]'= $SupportedMethods;'responseAsXml'='xml'}

    [xml] $ActionResults=Invoke-WebRequest -Uri $PostActionURI -WebSession $Telldus -Method POST -Body $request

    $Results=$ActionResults.devices.ChildNodes

    foreach ($Result in $Results)
    {
        $PropertiesToOutput = @{
                             'Name' = $Result.name;
                             'State' = switch ($Result.state)
                                       {
                                             1 { "On" }
                                             2 { "Off" }
                                            16 { "Dimmed" }
                                            default { "Unknown" }
                                       }
                             'DeviceID' = $Result.id;
                             

                             'Statevalue' = $Result.statevalue
                             'Methods' = switch ($Result.methods)
                                         {
                                             3 { "On/Off" }
                                            19 { "On/Off/Dim" }
                                            default { "Unknown" }
                                         }
                             'Type' = $Result.type;
                             'Client' = $Result.client;
                             'ClientName' = $Result.clientName;
                             'Online' = switch ($Result.online)
                                        {
                                            0 { $false }
                                            1 { $true }
                                        }
                             }

        $returnObject = New-Object -TypeName PSObject -Property $PropertiesToOutput
        Write-Output $returnObject | Select-Object Name, DeviceID, State, Statevalue, Methods, Type, ClientName, Client, Online
    }
}

function Set-TDDevice
{

    <#
    .SYNOPSIS
    Turns a device on or off.

    .DESCRIPTION
    This command can set the state of a device to on or off through the Telldus Live! service.

    .EXAMPLE
    Set-TDDevice -Username myemail@telldus.com -Password MyTelldusPassword -DeviceID 123456 -Action turnOff

    .EXAMPLE
    Set-TDDevice -Username myemail@telldus.com -Password MyTelldusPassword -DeviceID 123456 -Action turnOn

    .PARAMETER Username
    The username (e-mail) used to log into Telldus Live!

    .PARAMETER Password
    The password used to log into Telldus Live!

    .PARAMETER DeviceID
    The DeviceID of the device to turn off or on. (Pipelining possible)

    .PARAMETER Action
    What to do with that device. Possible values are "turnOff" or "turnOn".

    #>

    [CmdletBinding()]
    param(

      [Parameter(Mandatory=$True, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
      [Alias('id')]
      [string] $DeviceID,
      [Parameter(Mandatory=$True)]
      [ValidateSet("turnOff","turnOn")]
      [string] $Action,
      [Parameter(Mandatory=$True)] [string] $Username,
      [Parameter(Mandatory=$True)] [string] $Password
    )


    BEGIN {
        $LoginPostURI="https://login.telldus.com/openid/server?openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.mode=checkid_setup&openid.return_to=http%3A%2F%2Fapi.telldus.com%2Fexplore%2Fclients%2Flist&openid.realm=http%3A%2F%2Fapi.telldus.com&openid.ns.sreg=http%3A%2F%2Fopenid.net%2Fextensions%2Fsreg%2F1.1&openid.sreg.required=email&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select#"
        $turnOffURI="http://api.telldus.com/explore/device/turnOff"
        $PostActionURI="http://api.telldus.com/explore/doCall"

        $TelldusWEB = Invoke-WebRequest $turnOffURI -SessionVariable Telldus

        $form = $TelldusWEB.Forms[0]
        $form.Fields["email"] = $Username
        $form.Fields["password"] = $Password

        $TelldusWEB = Invoke-WebRequest -Uri $LoginPostURI -WebSession $Telldus -Method POST -Body $form.Fields
    }

    PROCESS {
        $request = @{'group'='device';'method'= $Action;'param[id]'= $DeviceID;'responseAsXml'='xml'}

        [xml] $ActionResults=Invoke-WebRequest -Uri $PostActionURI -WebSession $Telldus -Method POST -Body $request

        $Results=$ActionResults.device.status -replace "\s"

        $returnObject = New-Object System.Object
        $returnObject | Add-Member -Type NoteProperty -Name DeviceID -Value $DeviceID
        $returnObject | Add-Member -Type NoteProperty -Name Action -Value $Action
        $returnObject | Add-Member -Type NoteProperty -Name Results -Value $Results

        Write-Output $returnObject
    }
}

function Get-TDSensor
{
    <#
    .SYNOPSIS
    Retrieves all sensors associated with a Telldus Live! account.

    .DESCRIPTION
    This command will list all sensors associated with an Telldus Live!-account and their current status and other information.

    .EXAMPLE
    Get-TDSensor -Username myemail@telldus.com -Password MyTelldusPassword

    .EXAMPLE
    Get-TDSensor -Username myemail@telldus.com -Password MyTelldusPassword | Format-Table

    .PARAMETER Username
    The username (e-mail) used to log into Telldus Live!

    .PARAMETER Password
    The password used to log into Telldus Live!

    #>

    param(
      [Parameter(Mandatory=$True)] [string] $Username,
      [Parameter(Mandatory=$True)] [string] $Password
    )

    $LoginPostURI="https://login.telldus.com/openid/server?openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.mode=checkid_setup&openid.return_to=http%3A%2F%2Fapi.telldus.com%2Fexplore%2Fclients%2Flist&openid.realm=http%3A%2F%2Fapi.telldus.com&openid.ns.sreg=http%3A%2F%2Fopenid.net%2Fextensions%2Fsreg%2F1.1&openid.sreg.required=email&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select#"
    $turnOffURI="http://api.telldus.com/explore/device/turnOff"
    $sensorListURI="http://api.telldus.com/explore/sensors/list"
    $PostActionURI="http://api.telldus.com/explore/doCall"

    $TelldusWEB = Invoke-WebRequest $turnOffURI -SessionVariable Telldus

    $form = $TelldusWEB.Forms[0]
    $form.Fields["email"] = $Username
    $form.Fields["password"] = $Password

    $TelldusWEB = Invoke-WebRequest -Uri $LoginPostURI -WebSession $Telldus -Method POST -Body $form.Fields

    $SensorList=Invoke-WebRequest -Uri $sensorListURI -WebSession $Telldus
    $SensorListForm=$SensorList.Forms

    $ActionResults=$null

    [xml] $ActionResults=Invoke-WebRequest -Uri $PostActionURI -WebSession $Telldus -Method POST -Body $SensorListForm.Fields
    [datetime] $TelldusDate="1970-01-01 00:00:00"

    $TheResults=$ActionResults.sensors.ChildNodes

    foreach ($Result in $TheResults) {
        $SensorInfo=$Result

        $DeviceID=$SensorInfo.id.trim()
        $SensorName=$SensorInfo.name.trim()
        $SensorLastUpdated=$SensorInfo.lastupdated.trim()
        $SensorLastUpdatedDate=$TelldusDate.AddSeconds($SensorLastUpdated)
        $clientid=$SensorInfo.client.trim()
        $clientName=$SensorInfo.clientname.trim()
        $sensoronline=$SensorInfo.online.trim()

        $returnObject = New-Object System.Object
        $returnObject | Add-Member -Type NoteProperty -Name DeviceID -Value $DeviceID
        $returnObject | Add-Member -Type NoteProperty -Name Name -Value $SensorName
        $returnObject | Add-Member -Type NoteProperty -Name LocationID -Value $clientid
        $returnObject | Add-Member -Type NoteProperty -Name LocationName -Value $clientName
        $returnObject | Add-Member -Type NoteProperty -Name LastUpdate -Value $SensorLastUpdatedDate
        $returnObject | Add-Member -Type NoteProperty -Name Online -Value $sensoronline

        Write-Output $returnObject
    }
}

function Get-TDSensorData
{
    <#
    .SYNOPSIS
    Retrieves the sensordata of specified sensor.

    .DESCRIPTION
    This command will retrieve the sensordata associated with the specified ID.

    .EXAMPLE
    Get-TDSensorData -Username myemail@telldus.com -Password MyTelldusPassword -DeviceID 123456

    .PARAMETER DeviceID
    The DeviceID of the sensor which data you want to retrieve.

    .PARAMETER Username
    The username (e-mail) used to log into Telldus Live!

    .PARAMETER Password
    The password used to log into Telldus Live!

    #>

    [CmdletBinding()]
    param(

      [Parameter(Mandatory=$True, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)] [Alias('id')] [string] $DeviceID,
      [Parameter(Mandatory=$True)] [string] $Username,
      [Parameter(Mandatory=$True)] [string] $Password
    )

    BEGIN {
        $LoginPostURI="https://login.telldus.com/openid/server?openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.mode=checkid_setup&openid.return_to=http%3A%2F%2Fapi.telldus.com%2Fexplore%2Fclients%2Flist&openid.realm=http%3A%2F%2Fapi.telldus.com&openid.ns.sreg=http%3A%2F%2Fopenid.net%2Fextensions%2Fsreg%2F1.1&openid.sreg.required=email&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select#"
        $turnOffURI="http://api.telldus.com/explore/device/turnOff"
        $sensorDataURI="http://api.telldus.com/explore/sensor/info"
        $PostActionURI="http://api.telldus.com/explore/doCall"

        $TelldusWEB = Invoke-WebRequest $turnOffURI -SessionVariable Telldus

        $form = $TelldusWEB.Forms[0]
        $form.Fields["email"] = $Username
        $form.Fields["password"] = $Password

        $TelldusWEB = Invoke-WebRequest -Uri $LoginPostURI -WebSession $Telldus -Method POST -Body $form.Fields
    }

    PROCESS {
        $request = @{'group'='sensor';'method'= 'info';'param[id]'= $DeviceID;'responseAsXml'='xml'}

        [xml] $ActionResults=Invoke-WebRequest -Uri $PostActionURI -WebSession $Telldus -Method POST -Body $request
        [datetime] $TelldusDate="1970-01-01 00:00:00"

        $SensorInfo=$ActionResults.sensor
        $SensorData=$ActionResults.sensor.data

        $SensorName=$SensorInfo.name.trim()
        $SensorLastUpdated=$SensorInfo.lastupdated.trim()
        $SensorLastUpdatedDate=$TelldusDate.AddSeconds($SensorLastUpdated)
        $clientName=$SensorInfo.clientname.trim()
        $SensorTemp=($SensorData | ? name -eq "temp").value | select -First 1
        $SensorHumidity=($SensorData | ? name -eq "humidity").value | select -First 1

        $returnObject = New-Object System.Object
        $returnObject | Add-Member -Type NoteProperty -Name DeviceID -Value $DeviceID
        $returnObject | Add-Member -Type NoteProperty -Name Name -Value $SensorName
        $returnObject | Add-Member -Type NoteProperty -Name LocationName -Value $clientName
        $returnObject | Add-Member -Type NoteProperty -Name Temperature -Value $SensorTemp
        $returnObject | Add-Member -Type NoteProperty -Name Humidity -Value $SensorHumidity
        $returnObject | Add-Member -Type NoteProperty -Name LastUpdate -Value $SensorLastUpdatedDate

        Write-Output $returnObject
    }
}


function Get-TDRainSensorData
{
    <#
    .SYNOPSIS
    Retrieves the sensordata of specified sensor.

    .DESCRIPTION
    This command will retrieve the sensordata associated with the specified ID.

    .EXAMPLE
    Get-TDSensorData -Username myemail@telldus.com -Password MyTelldusPassword -DeviceID 123456

    .PARAMETER DeviceID
    The DeviceID of the sensor which data you want to retrieve.

    .PARAMETER Username
    The username (e-mail) used to log into Telldus Live!

    .PARAMETER Password
    The password used to log into Telldus Live!

    #>

    [CmdletBinding()]
    param(

      [Parameter(Mandatory=$True, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)] [Alias('id')] [string] $DeviceID,
      [Parameter(Mandatory=$True)] [string] $Username,
      [Parameter(Mandatory=$True)] [string] $Password
    )

    BEGIN {
        $LoginPostURI="https://login.telldus.com/openid/server?openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.mode=checkid_setup&openid.return_to=http%3A%2F%2Fapi.telldus.com%2Fexplore%2Fclients%2Flist&openid.realm=http%3A%2F%2Fapi.telldus.com&openid.ns.sreg=http%3A%2F%2Fopenid.net%2Fextensions%2Fsreg%2F1.1&openid.sreg.required=email&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select#"
        $turnOffURI="http://api.telldus.com/explore/device/turnOff"
        $sensorDataURI="http://api.telldus.com/explore/sensor/info"
        $PostActionURI="http://api.telldus.com/explore/doCall"

        $TelldusWEB = Invoke-WebRequest $turnOffURI -SessionVariable Telldus

        $form = $TelldusWEB.Forms[0]
        $form.Fields["email"] = $Username
        $form.Fields["password"] = $Password

        $TelldusWEB = Invoke-WebRequest -Uri $LoginPostURI -WebSession $Telldus -Method POST -Body $form.Fields
    }

    PROCESS {
        $request = @{'group'='sensor';'method'= 'info';'param[id]'= $DeviceID;'responseAsXml'='xml'}

        [xml] $ActionResults=Invoke-WebRequest -Uri $PostActionURI -WebSession $Telldus -Method POST -Body $request
        [datetime] $TelldusDate="1970-01-01 00:00:00"

        $SensorInfo=$ActionResults.sensor
        $SensorData=$ActionResults.sensor.data

        $SensorName=$SensorInfo.name.trim()
        $SensorLastUpdated=$SensorInfo.lastupdated.trim()
        $SensorLastUpdatedDate=$TelldusDate.AddSeconds($SensorLastUpdated)
        $clientName=$SensorInfo.clientname.trim()
        $SensorRainRate=($SensorData | ? name -eq "rtot").value | select -First 1
        $SensorRainTotal=($SensorData | ? name -eq "rrate").value | select -First 1

        $returnObject = New-Object System.Object
        $returnObject | Add-Member -Type NoteProperty -Name DeviceID -Value $DeviceID
        $returnObject | Add-Member -Type NoteProperty -Name Name -Value $SensorName
        $returnObject | Add-Member -Type NoteProperty -Name LocationName -Value $clientName
        $returnObject | Add-Member -Type NoteProperty -Name RainRate -Value $SensorRainRate
        $returnObject | Add-Member -Type NoteProperty -Name RainTotal -Value $SensorRainTotal
        $returnObject | Add-Member -Type NoteProperty -Name LastUpdate -Value $SensorLastUpdatedDate

        Write-Output $returnObject
    }
}

function Get-TDWindSensorData
{
    <#
    .SYNOPSIS
    Retrieves the sensordata of specified sensor.

    .DESCRIPTION
    This command will retrieve the sensordata associated with the specified ID.

    .EXAMPLE
    Get-TDSensorData -Username myemail@telldus.com -Password MyTelldusPassword -DeviceID 123456

    .PARAMETER DeviceID
    The DeviceID of the sensor which data you want to retrieve.

    .PARAMETER Username
    The username (e-mail) used to log into Telldus Live!

    .PARAMETER Password
    The password used to log into Telldus Live!

    #>

    [CmdletBinding()]
    param(

      [Parameter(Mandatory=$True, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)] [Alias('id')] [string] $DeviceID,
      [Parameter(Mandatory=$True)] [string] $Username,
      [Parameter(Mandatory=$True)] [string] $Password
    )

    BEGIN {
        $LoginPostURI="https://login.telldus.com/openid/server?openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.mode=checkid_setup&openid.return_to=http%3A%2F%2Fapi.telldus.com%2Fexplore%2Fclients%2Flist&openid.realm=http%3A%2F%2Fapi.telldus.com&openid.ns.sreg=http%3A%2F%2Fopenid.net%2Fextensions%2Fsreg%2F1.1&openid.sreg.required=email&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select#"
        $turnOffURI="http://api.telldus.com/explore/device/turnOff"
        $sensorDataURI="http://api.telldus.com/explore/sensor/info"
        $PostActionURI="http://api.telldus.com/explore/doCall"

        $TelldusWEB = Invoke-WebRequest $turnOffURI -SessionVariable Telldus

        $form = $TelldusWEB.Forms[0]
        $form.Fields["email"] = $Username
        $form.Fields["password"] = $Password

        $TelldusWEB = Invoke-WebRequest -Uri $LoginPostURI -WebSession $Telldus -Method POST -Body $form.Fields
    }

    PROCESS {
        $request = @{'group'='sensor';'method'= 'info';'param[id]'= $DeviceID;'responseAsXml'='xml'}

        [xml] $ActionResults=Invoke-WebRequest -Uri $PostActionURI -WebSession $Telldus -Method POST -Body $request
        [datetime] $TelldusDate="1970-01-01 00:00:00"

        $SensorInfo=$ActionResults.sensor
        $SensorData=$ActionResults.sensor.data

        $SensorName=$SensorInfo.name.trim()
        $SensorLastUpdated=$SensorInfo.lastupdated.trim()
        $SensorLastUpdatedDate=$TelldusDate.AddSeconds($SensorLastUpdated)
        $clientName=$SensorInfo.clientname.trim()
        $SensorWindAvg=($SensorData | ? name -eq "wavg").value | select -First 1
        $SensorWindGust=($SensorData | ? name -eq "wgust").value | select -First 1
        $SensorWindDir=($SensorData | ? name -eq "wdir").value | select -First 1

        $returnObject = New-Object System.Object
        $returnObject | Add-Member -Type NoteProperty -Name DeviceID -Value $DeviceID
        $returnObject | Add-Member -Type NoteProperty -Name Name -Value $SensorName
        $returnObject | Add-Member -Type NoteProperty -Name LocationName -Value $clientName
        $returnObject | Add-Member -Type NoteProperty -Name WindAverage -Value $SensorWindAvg
        $returnObject | Add-Member -Type NoteProperty -Name WindGust -Value $SensorWindGust
        $returnObject | Add-Member -Type NoteProperty -Name WindDirection -Value $SensorWindDir
        $returnObject | Add-Member -Type NoteProperty -Name LastUpdate -Value $SensorLastUpdatedDate

        Write-Output $returnObject
    }
}

function Set-TDDimmer
{
    <#
    .SYNOPSIS
    Dims a device to a certain level.

    .DESCRIPTION
    This command can set the dimming level of a device to through the Telldus Live! service.

    .EXAMPLE
    Set-TDDimmer -Username myemail@telldus.com -Password MyTelldusPassword -DeviceID 123456 -Level 89

    .EXAMPLE
    Set-TDDimmer -Username myemail@telldus.com -Password MyTelldusPassword -DeviceID 123456 -Level 180

    .PARAMETER Username
    The username (e-mail) used to log into Telldus Live!

    .PARAMETER Password
    The password used to log into Telldus Live!

    .PARAMETER DeviceID
    The DeviceID of the device to dim. (Pipelining possible)

    .PARAMETER Level
    What level to dim to. Possible values are 0 - 255.

    #>

    [CmdletBinding()]
    param(

      [Parameter(Mandatory=$True,
                 ValueFromPipeline=$true,
                 ValueFromPipelineByPropertyName=$true,
                 HelpMessage="Enter the DeviceID.")] [Alias('id')] [string] $DeviceID,

      [Parameter(Mandatory=$True,
                 HelpMessage="Enter the level to dim to between 0 and 255.")]
      [ValidateRange(0,255)]
      [int] $Level,

      [Parameter(Mandatory=$True)] [string] $Username,
      [Parameter(Mandatory=$True)] [string] $Password
    )


    BEGIN {

        $LoginPostURI="https://login.telldus.com/openid/server?openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.mode=checkid_setup&openid.return_to=http%3A%2F%2Fapi.telldus.com%2Fexplore%2Fclients%2Flist&openid.realm=http%3A%2F%2Fapi.telldus.com&openid.ns.sreg=http%3A%2F%2Fopenid.net%2Fextensions%2Fsreg%2F1.1&openid.sreg.required=email&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select#"
        $turnOffURI="http://api.telldus.com/explore/device/turnOff"
        $PostActionURI="http://api.telldus.com/explore/doCall"

        $TelldusWEB = Invoke-WebRequest $turnOffURI -SessionVariable Telldus

        $form = $TelldusWEB.Forms[0]
        $form.Fields["email"] = $Username
        $form.Fields["password"] = $Password

        $TelldusWEB = Invoke-WebRequest -Uri $LoginPostURI -WebSession $Telldus -Method POST -Body $form.Fields

    }

    PROCESS {
        $Action='dim'

        $request = @{'group'='device';'method'= $Action;'param[id]'= $DeviceID;'param[level]'= $Level;'responseAsXml'='xml'}

        [xml] $ActionResults=Invoke-WebRequest -Uri $PostActionURI -WebSession $Telldus -Method POST -Body $request

        $Results=$ActionResults.device.status -replace "\s"

        $returnObject = New-Object System.Object
        $returnObject | Add-Member -Type NoteProperty -Name DeviceID -Value $DeviceID
        $returnObject | Add-Member -Type NoteProperty -Name Action -Value $Action
        $returnObject | Add-Member -Type NoteProperty -Name Results -Value $Results

        Write-Output $returnObject
    }
}
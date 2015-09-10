# The Get-TargetResource cmdlet.
function Get-TargetResource
{
    [OutputType([Hashtable])]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$PackageName,
	    [string]$PackageSource,
	    [string]$PackageProvider
    )

        # Latest OneGet experimental build used due to PackageManagement not working in Windows 10 RTM
        #Import-Module -Name OneGet-Edge

        $package = Get-Package -Name $PackageName -Verbose -ErrorAction SilentlyContinue -ProviderName Chocolatey

        if ($package -ne $null)
        {
            @{
                PackageName = $PackageName + " " + $package.Version
            }
        }
}

# The Set-TargetResource cmdlet.
function Set-TargetResource
{
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$PackageName,

        [ValidateSet("Present", "Absent")]
        [string]$Ensure = "Present",
	    [string]$PackageSource,
	    [string]$PackageProvider
    )

        # Latest OneGet experimental build used due to PackageManagement not working in Windows 10 RTM
        #Import-Module -Name OneGet-Edge

    if ($Ensure -eq 'Present')
    {
        Write-Verbose "Installing package $PackageName"
        Install-Package -Name $PackageName -Force -Verbose -ProviderName $PackageProvider -Source $PackageSource
    }
    elseif ($Ensure -eq 'Absent')
    {
        Write-Verbose "Uninstalling package $PackageName"
        Uninstall-Package -Name $PackageName -Force -Verbose -ProviderName $PackageProvider
    }
}

# The Test-TargetResource cmdlet.
function Test-TargetResource
{
	[OutputType([Boolean])]
        param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$PackageName,

        [ValidateSet("Present", "Absent")]
        [string]$Ensure = "Present",
	    [string]$PackageSource,
	    [string]$PackageProvider
    )

        # Latest OneGet experimental build used due to PackageManagement not working in Windows 10 RTM
        # Import-Module -Name OneGet-Edge

    $package = Get-Package -Name $PackageName -Verbose -ErrorAction SilentlyContinue -ProviderName $PackageProvider

    if (($Ensure -eq 'Present') -and ($package -eq $null))
    {
        Write-Verbose "Ensure is set to $Ensure, but package is absent"
        return $false
    }
    elseif (($Ensure -eq 'Absent') -and ($package -eq $null))
    {
        Write-Verbose "Ensure is set to $Ensure, and package is absent"
        return $true
    }
    elseif (($Ensure -eq 'Present') -and ($package -ne $null))
    {
        Write-Verbose "Ensure is set to $Ensure, and package is present"
        return $true
    }
    elseif (($Ensure -eq 'Absent') -and ($package -ne $null))
    {
        Write-Verbose "Ensure is set to $Ensure, but package is present"
        return $false
    }

    Write-Verbose "Ensure is set to $Ensure, but package is $package"
	return $false

}

Export-ModuleMember -Function *-TargetResource
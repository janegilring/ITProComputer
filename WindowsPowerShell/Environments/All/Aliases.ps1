Set-Alias -Name "cd"  -Value push-location -option AllScope
Set-Alias -Name "cd-" -Value Pop-Location
Set-Alias -Name gpm -Value Get-Parameter

New-Alias -Name ping -Value Test-Connection

if([Environment]::OSVersion.Version -ge (new-object 'Version' 6,2)) {Set-Alias -Name ipconfig -Value Get-NetIPConfiguration}

if (Test-Path -Path 'C:\Program Files\Git\bin\git.exe'){

New-Alias -Name git -Value 'C:\Program Files\Git\bin\git.exe' -Scope Global

}
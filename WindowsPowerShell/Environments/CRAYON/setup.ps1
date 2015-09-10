New-PSDrive -Name dropbox -Root C:\Users\janring\Dropbox -PSProvider filesystem | Out-Null
New-PSDrive -Name skydrive -Root C:\Users\janring\Skydrive -PSProvider filesystem | Out-Null
New-PSDrive -Name sysint -Root C:\Users\janring\Dropbox\Sysinternals -PSProvider filesystem | Out-Null
New-PSDrive -Name h -Root C:\Users\janring\Documents -PSProvider filesystem | Out-Null
New-PSDrive -Name demo -Root C:\Users\janring\Documents\WindowsPowerShell\Scripts\Demo -PSProvider filesystem | Out-Null

$MaximumHistoryCount = 2048

# If running PowerShell v3 set default parameter values
if ($psversiontable.psversion -eq "3.0") {
    $PSDefaultParameterValues = @{
        "Send-MailMessage:From" = "jan.egil.ring@powershell.no"
        "Send-MailMessage:SmtpServer" = "mail.powershell.no"
    }
    # If current session has admin privileges, update powershell help files
    if(([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
        Write-Host -ForegroundColor Yellow "Updating help..." 
        #Update-Help -UICulture en-us -ea silentlycontinue
    } 
}
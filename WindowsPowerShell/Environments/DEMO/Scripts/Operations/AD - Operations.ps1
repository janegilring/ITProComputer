Import-Module ActiveDirectory

Search-ADAccount -Lockedout | Select-Object name,samaccountname | Out-GridView

Unlock-ADAccount -Identity user01

~\Git\CrayonDemo-ITPro-Computer\WindowsPowerShell\Scripts\AD\Get-LockedOutUser.ps1 -UserName user01


Search-ADAccount -PasswordExpired

Get-ADDefaultDomainPasswordPolicy
Get-ADFineGrainedPasswordPolicy -Filter *


$dte = (Get-Date).AddDays(-1)

Get-ADObject -Filter 'whenchanged -gt $dte' | Group-Object objectclass
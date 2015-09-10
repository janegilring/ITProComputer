# Set-Prompt.ps1 (Dot-Source from your profile)
###################################################
# This should go OUTSIDE the prompt function, it doesn't need re-evaluation
# We're going to calculate a prefix for the window title 
# Our basic title is "PoSh - C:\Your\Path\Here" showing the current path
if(!$global:WindowTitlePrefix) {
   # But if you're running "elevated" on vista, we want to show that ...
   if( ([System.Environment]::OSVersion.Version.Major -gt 5) -and ( # Vista and ...
         new-object Security.Principal.WindowsPrincipal (
            [Security.Principal.WindowsIdentity]::GetCurrent()) # current user is admin
            ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) )
   {
      $global:WindowTitlePrefix = "PowerShell - (Administrator)"
   } else {
      $global:WindowTitlePrefix = "PowerShell"
   }
}

function global:prompt {
   # FIRST, make a note if there was an error in the previous command
   $err = !$?

   # Make sure Windows and .Net know where we are (they can only handle the FileSystem)
   [Environment]::CurrentDirectory = (Get-Location -PSProvider FileSystem).ProviderPath
   # Also, put the path in the title ... (don't restrict this to the FileSystem
   $Host.UI.RawUI.WindowTitle = "{0} - {1} ({2})" -f $global:WindowTitlePrefix,$pwd.Path,$pwd.Provider.Name
   
   # Determine what nesting level we are at (if any)
   $Nesting = "$([char]0xB7)" * $NestedPromptLevel

   # Generate PUSHD(push-location) Stack level string
   $Stack = "+" * (Get-Location -Stack).count
   
   # my New-Script and Get-PerformanceHistory functions use history IDs
   # So, put the ID of the command in, so we can get/invoke-history easier
   # eg: "r 4" will re-run the command that has [4]: in the prompt
   #$nextCommandId = (Get-History -count 1).Id + 1
   if (-not ($global:nextCommandId)) {
   $global:nextCommandId = 0
   }
   $global:nextCommandId ++
   # Output prompt string
   # If there's an error, set the prompt foreground to "Red", otherwise, "Yellow"
   #if($err) { $fg = "Red" } else { $fg = "Yellow" }
   $fg = "Yellow"
   # Notice: no angle brackets, makes it easy to paste my buffer to the web
   Write-Host "PS [${Nesting}${nextCommandId}${Stack}]:" -NoNewLine -Fore $fg
   
   return " "
}
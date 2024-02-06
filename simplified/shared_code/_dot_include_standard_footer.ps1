<#
    Tied/Paired with _dot_include_standard_header.ps1. Won't work if header not included.
#>                                                                                       
        
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Scope='Function', Target='Log-*')] # We don't need no stinkin' badges
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '', Scope='Function', Target='*')] # Why?

param()

Write-Host

Format-Humanize $scriptTimer

# Log-ScriptCompleted
          
try {Stop-Transcript}catch{}

exit 0
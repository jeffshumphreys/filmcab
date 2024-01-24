<#
    Tied/Paired with _dot_include_standard_header.ps1. Won't work if header not included.
#>                                                                                       

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Scope='Function', Target='Log-*')] # We don't need no stinkin' badges
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '', Scope='Function', Target='*')] # Why?

param()


$elapsed = $scriptTimer.Elapsed # Tada!!

Write-Host

if ($elapsed.Days -gt 0) {
    Format-Plural 'Day' $($elapsed.Days) -includeCount
}
elseif ($elapsed.Hours -gt 0) {
    Format-Plural 'Hour' $($elapsed.Hours) -includeCount
}
elseif ($elapsed.Minutes -gt 0) {
    Format-Plural 'Minute' $($elapsed.Minutes) -includeCount
}
elseif ($elapsed.Seconds -gt 0) {
    Format-Plural 'Second' $($elapsed.Seconds) -includeCount
}
elseif ($elapsed.Milliseconds -gt 0) {
    Format-Plural 'Millisecond' $($elapsed.Milliseconds) -includeCount
}
elseif ($elapsed.Microseconds -gt 0) {
    Format-Plural 'Microsecond' $($elapsed.Microseconds) -includeCount
}
elseif ($elapsed.Ticks -gt 0) {
    Format-Plural 'Tick' $($elapsed.Ticks) -includeCount
}

# Log-ScriptCompleted


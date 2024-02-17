<#
    Tied/Paired with _dot_include_standard_header.ps1. Won't work if header not included.
#>                                                                                       
        
Write-Host

if ($Script:WriteCounts.Count -gt 0) {
    $MaxLengthLabel = 0
    $MaxNumber = 0
                                 
    Write-Host
    ForEach($entry in $Script:WriteCounts) {
        if ($entry.CountLabel.Length -gt $MaxLengthLabel) {$MaxLengthLabel = $entry.CountLabel.Length}
        if ($entry.Count -gt $MaxNumber) {$MaxNumber = $entry.Count}
    }
     
    $MaxNumberSpace = ($MaxNumber).ToString('N0')
    $MaxNumberWidth = $MaxNumberSpace.Length

    ForEach($entry in $Script:WriteCounts) {
        if ($entry.CountLabel -ne '') {
        $title = ($entry.CountLabel + ' '*($MaxLengthLabel)).Substring(0,$MaxLengthLabel)
        $CountAsRightJustified = "$($entry.Count)".PadLeft($MaxNumberWidth)
        Write-Host "$title    `:   $CountAsRightJustified"
        }
    }
}   

Format-Humanize $scriptTimer

# Log-ScriptCompleted

Log-ScriptCompleted

try {Stop-Transcript}catch{}

exit 0
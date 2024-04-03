<#
    Tied/Paired with _dot_include_standard_header.ps1. Won't work if header not included.
#>                                                                                       

try {
Write-AllPlaces

if ($Script:WriteCounts.Count -gt 0) {
    $MaxLengthLabel = 0
    $MaxNumber = 0
                                 
    Write-AllPlaces
    ForEach($entry in $Script:WriteCounts) {
        if ($entry.CountLabel.Length -gt $MaxLengthLabel) {$MaxLengthLabel = $entry.CountLabel.Length}
        if ($entry.Count -gt $MaxNumber) {$MaxNumber = $entry.Count}
    }
     
    $MaxNumberSpace = ($MaxNumber).ToString('N0')
    $MaxNumberWidth = $MaxNumberSpace.Length

    ForEach($entry in $Script:WriteCounts) {
        if ($entry.CountLabel -ne '') {
        $title                       = ($entry.CountLabel + ' '*($MaxLengthLabel)).Substring(0,$MaxLengthLabel)
        if ($null -ne $entry.Count) {
        $countWithThousandsSeparator = [string]::Format('{0:N0}', $entry.Count)
        $CountAsRightJustified       = "$countWithThousandsSeparator".PadLeft($MaxNumberWidth)
        Write-AllPlaces "$title    `:   $CountAsRightJustified"
        } else {
            Write-AllPlaces "$title : Count is null??"
        }
        }
    }
}   

Format-Humanize $scriptTimer

$elapsedTime = $scriptTimer.Elapsed
$secondsRan  = $elapsedTime.TotalSeconds
Log-Line "Stopping Normally after $secondsRan Second(s)"

End-BatchRunSessionTaskEntry
      
} catch {
    Show-Error "Untrapped exception in footer" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}                                            

try {Stop-Transcript}catch{}

exit 0
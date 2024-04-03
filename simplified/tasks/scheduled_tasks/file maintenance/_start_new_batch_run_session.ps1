<#
 #    FilmCab Daily morning batch run process: Start tracking # for this batch run session.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Basics in place; scheduling.
 #    ###### Wed Jan 24 12:16:40 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #    Set a number and UUID for this session so we can track upstream activity to downstream consequences.  Bet the lovely Meridian School District IT team (bless them) never considered that. Gary, the fat worm.
 #>
                                            
# This is the first task in the batch run session. A stub.

try {

    . .\_dot_include_standard_header.ps1 
                                                                            
}
catch {
    Write-Host "Catch"
    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}                                  
finally {
    Write-AllPlaces "Finally" -ForceStartOnNewLine
    Write-Host "footer"

    . .\_dot_include_standard_footer.ps1
}
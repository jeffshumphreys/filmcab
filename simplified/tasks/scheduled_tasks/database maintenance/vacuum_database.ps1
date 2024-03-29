<#
 #    FilmCab Daily morning batch run process: Clean-up space left by updates and deletes.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Retesting in lineup
 #    ###### Tue Jan 23 18:23:11 MST 2024
 #    ###### Fri Feb 16 16:32:24 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #
 #>

try {
. .\_dot_include_standard_header.ps1

Write-AllPlaces "Starting Vacuum"                                                      

###### Sun Feb 11 17:17:35 MST 2024 "VACUUM (FULL, VERBOSE)" takes 31+ minutes
###### Sun Feb 11 17:17:19 MST 2024 "VACUUM" takes < 3 minutes
###### Sun Feb 11 18:17:39 MST 2024 VACUUM VERBOSE took a second after above.  Where does the output go?

$reader = WhileReadSql "SELECT tablename FROM pg_catalog.pg_tables WHERE schemaname = 'simplified' ORDER BY tablename" 

While ($reader.Read()) {
    Invoke-Sql "VACUUM (VERBOSE) $tablename"|Out-Host
}

Write-AllPlaces "Done Vacuuming"
                          
}
catch {
    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}                                  
finally {
    Write-AllPlaces "Finally" -ForceStartOnNewLine
    . .\_dot_include_standard_footer.ps1
}
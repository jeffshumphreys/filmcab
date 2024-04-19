<#
 #    FilmCab Daily morning batch run process: link our cleaned up and all deleted removed across all the stages:payload, published, and backup.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Conception
 #    ###### Sat Feb 3 22:20:01 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #>

try {

. .\_dot_include_standard_header.ps1

# Track some stats. Useful for finding bugs. For instance, kept getting 12 new junction points, the same ones. turns out the test was bad.

$howManyNewDirectoriesWhereFound = 0

# Fetch a string array of paths to search.
                                                                
$reader = WhileReadSql "SELECT search_directory, search_directory_id FROM search_directories ORDER BY search_directory_id" 

While ($reader.Read()) {
 
# Search down each search path for directories that are different or missing from our data store.

    $search_directory
    $search_directory_id
    $howManyNewDirectoriesWhereFound++
}


# Display counts. If nothing is happening in certain areas, investigate.
Write-AllPlaces # Get off the last nonewline
Write-AllPlaces

Write-Count howManyNewDirectoriesWhereFound Directory

}
catch {
    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}                                  
finally {
    Write-AllPlaces "Finally"
    . .\_dot_include_standard_footer.ps1
}
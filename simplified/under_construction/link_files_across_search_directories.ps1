<#
 #    FilmCab Daily morning batch run process: link our cleaned up and all physically or logically deleted files across all the stages:payload, published, and backup.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Conception
 #    ###### Sat Feb 3 22:20:01 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 # TODO: ignore deleted files???
 #>
   
 try {
. .\_dot_include_standard_header.ps1

$howManyFilesAreMappedAcross   = 0

# Fetch a string array of paths to search.

$filesLinkedAcrossSearchDirectories = WhileReadSql 'SELECT file_name_no_ext from files_linked_across_search_directories_v' # All the directories across my volumes that I think have some sort of movie stuff in them.

# Search down each search path for directories that are different or missing from our data store.

while ($filesLinkedAcrossSearchDirectories.Read()) {
    Write-AllPlaces $file_name_no_ext
    $howManyFilesAreMappedAcross++
}

Write-Count howManyFilesAreMappedAcross Files

}
catch {
    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}                                  
finally {
    Write-AllPlaces "Finally"
    . .\_dot_include_standard_footer.ps1
}
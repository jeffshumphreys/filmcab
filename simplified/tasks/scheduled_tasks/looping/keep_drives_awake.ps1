<#
 #    FilmCab Daily morning batch run process: Damn published drive goes to sleep; annoying in morning
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Conception
 #    ###### Sat Feb 3 22:20:01 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #>

. .\_dot_include_standard_header.ps1

$volumesForSearchDirectories = WhileReadSql 'SELECT DISTINCT drive_letter from search_directories_ext_v ORDER BY 1' # All the directories across my volumes that I think have some sort of movie stuff in them.
    
# Search down each search path for directories that are different or missing from our data store.

while ($volumesForSearchDirectories.Read()) {
    $TestPath = "$drive_letter`:\"
    Flush-Volume $drive_letter                             
    Get-ChildItem -Path $TestPath|Out-Null # Just tapping the reader
}

. .\_dot_include_standard_footer.ps1
<#
 #    FilmCab Daily morning batch run process: Extract all the "_" folders and determine what genre to assign the directory.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Prepping for addition to schedule.
 #    ###### Tue Jan 23 18:23:11 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #>
 
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()

. D:\qt_projects\filmcab\simplified\_dot_include_standard_header.ps1

# Track some stats. Useful for finding bugs. For instance, kept getting 12 new junction points, the same ones. turns out the test was bad.

$howManyGenreFolders = 0

# Fetch a string array of paths to search.

$loop_sql = "
SELECT 
     directory_path                      /* What we are going to search for new files     */
   , directory_hash                      /* Links back to directories table               */
   , is_symbolic_link                    /* Don't go into these?                          */
   , is_junction_link                    /* We'll still want to log things added to these */
   , root_genre
   , sub_genre
FROM 
    directories
";

$readerHandle = Walk-Sql $loop_sql
$reader = $readerHandle.Value # Now we can unbox!  Ta da!
              
While ($reader.Read()) {
    # 
}


# Display counts. If nothing is happening in certain areas, investigate.
Write-Host # Get off the last nonewline
Write-Host
Write-Host "How many genres directories were found:                      $howManyGenreFolders"           $(Format-Plural 'Directory' $howManyGenreFolders) 
#TODO: Update counts to session table

# Da Fuutar!!!
. D:\qt_projects\filmcab\simplified\_dot_include_standard_footer.ps1
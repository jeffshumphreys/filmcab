<#
 #    FilmCab Daily morning batch run process: link our cleaned up and all physically or logically deleted files across all the stages:payload, published, and backup.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Conception
 #    ###### Sat Feb 3 22:20:01 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #>
 

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()

. D:\qt_projects\filmcab\simplified\shared_code\_dot_include_standard_header.ps1

# Track some stats. Useful for finding bugs. For instance, kept getting 12 new junction points, the same ones. turns out the test was bad.

$howManyNewDirectories = 0
$howManyUpdatedDirectories = 0
$howManyDirectoriesFlaggedToScan = 0
$howManyNewSymbolicLinks = 0
$howManyNewJunctionLinks= 0
$hoWManyRowsUpdated = 0
$hoWManyRowsInserted = 0
$hoWManyRowsDeleted = 0

# Fetch a string array of paths to search.

$searchPathsHandle = Walk-Sql 'SELECT * from files_linked_across_search_paths_v' # All the directories across my volumes that I think have some sort of movie stuff in them.
$searchPaths = $searchPathsHandle.Value

# Search down each search path for directories that are different or missing from our data store.

while ($searchPaths.Read()) {
    $SearchPath = $searchPaths.GetString(0)
    $SearchPathId = $searchPaths.GetInt32(1)
    #Load first level of hierarchy
}


# Display counts. If nothing is happening in certain areas, investigate.
Write-Host # Get off the last nonewline
Write-Host
Write-Host "How many new directories were found:                      $howManyNewDirectories"           $(Format-Plural 'Directory' $howManyNewDirectories) 
Write-Host "How many old directories were updated:                    $howManyUpdatedDirectories"       $(Format-Plural 'Directory' $howManyUpdatedDirectories) 
Write-Host "How many rows were updated:                               $howManyRowsUpdated"              $(Format-Plural 'Row'       $howManyRowsUpdated) 
Write-Host "How many rows were inserted:                              $hoWManyRowsInserted"             $(Format-Plural 'Row'       $hoWManyRowsInserted) 
Write-Host "How many rows were deleted:                               $hoWManyRowsDeleted"              $(Format-Plural 'Row'       $hoWManyRowsDeleted) 
Write-Host "How many new junction linked directories were found:      $howManyNewJunctionLinks"         $(Format-Plural 'Link'      $howManyNewJunctionLinks) 
Write-Host "How many new symbolically linked directories were found:  $howManyNewSymbolicLinks"         $(Format-Plural 'Link'      $howManyNewSymbolicLinks) 
Write-Host "How many directories were flagged for scanning:           $howManyDirectoriesFlaggedToScan" $(Format-Plural 'Directory' $howManyDirectoriesFlaggedToScan) 
#TODO: Update counts to session table

# Da Fuutar!!!
. D:\qt_projects\filmcab\simplified\shared_code\_dot_include_standard_footer.ps1
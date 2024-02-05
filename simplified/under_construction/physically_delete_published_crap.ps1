<#
 #    FilmCab Daily morning batch run process: There is a lot of stuff that gets downloaded with payloads. These messy the linking across batch run stages.
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

$howManyPossibleCrapFiles = 0
$howManyFilesWouldHaveBeenDeleted = 0
$howManyDirectoriesFlaggedToScan = 0
$howManyNewSymbolicLinks = 0
$howManyNewJunctionLinks= 0
$hoWManyRowsUpdated = 0
$hoWManyRowsInserted = 0
$hoWManyRowsDeleted = 0

$files_to_delete = @(
    'Torrent_downloaded_from_Demonoid.me.txt',
    '[TGx]Downloaded from torrentgalaxy.to .txt',
    'Torrent downloaded from Demonoid - www demonoid pw .txt',
    'How to play HEVC (THIS FILE).txt'
)

$files_to_keep = @(
    'spud.txt', 'Read Me.txt', 'Info.txt', '_NO_SUBTITLES.txt'
)              

$extensions_to_delete = @('par2', 'IFO', 'BUP')
# Fetch a string array of paths to search.

$rando_download_files_to_ignore = @('cs', 'ps1', 'exe', 'ini', 'htm', 'h', 'idl')

$possibleCrapFilesHandle = Walk-Sql "
    SELECT
        file_name_with_ext,
        final_extension,
        directory_path,
        search_path_tag
    FROM 
        files_ext_v 
    WHERE 
        final_extension NOT IN('srt', 'mkv', 'avi', 'mp4', 'wmv', 'm4v', 'mov', 'mpeg', 'VOB', 'exe', 'sub', 'idx', 'AVI', 'zip') 
    AND 
        directly_deletable
    AND
        final_extension NOT IN('nfo')
    AND NOT 
        file_deleted
    " 
# All the directories across my volumes that I think have some sort of movie stuff in them.

$possibleCrapFiles = $possibleCrapFilesHandle.Value

# Search down each search path for directories that are different or missing from our data store.

while ($possibleCrapFiles.Read()) {
    $howManyPossibleCrapFiles++
    $file_name_with_ext = Get-SqlFieldValue $possibleCrapFilesHandle file_name_with_ext
    $final_extension = Get-SqlFieldValue $possibleCrapFilesHandle final_extension
    $directory_path = Get-SqlFieldValue $possibleCrapFilesHandle directory_path
    $search_path_tag= Get-SqlFieldValue $possibleCrapFilesHandle search_path_tag

    if ($search_path_tag -eq 'download' -and $final_extension -in $rando_download_files_to_ignore) {
        # Ignore these
    } 
    if ($file_name_with_ext -cin $files_to_delete -and -not ($file_name_with_ext -cin $files_to_keep)) {
        #Write-Host "DELETE $file_name_with_ext"
    } elseif ($final_extension -cin $extensions_to_delete) {
        #Write-Host "DELETE $file_name_with_ext"           
    } else {
        
        @("Keep $file_name_with_ext", $directory_path)|Format-Table
    }
    #Load first level of hierarchy
}


# Display counts. If nothing is happening in certain areas, investigate.
Write-Host # Get off the last nonewline
Write-Host
Write-Host "How many possible crap files were found:                  " $(Format-Plural 'File'      $howManyPossibleCrapFiles -includeCount) 
Write-Host "How many files would have been deleted:                   " $(Format-Plural 'File'      $howManyFilesWouldHaveBeenDeleted -includeCount) 
Write-Host "How many rows were updated:                               " $(Format-Plural 'Row'       $howManyRowsUpdated -includeCount) 
Write-Host "How many rows were inserted:                              " $(Format-Plural 'Row'       $hoWManyRowsInserted -includeCount) 
Write-Host "How many rows were deleted:                               " $(Format-Plural 'Row'       $hoWManyRowsDeleted -includeCount) 
Write-Host "How many new junction linked directories were found:      " $(Format-Plural 'Link'      $howManyNewJunctionLinks -includeCount) 
Write-Host "How many new symbolically linked directories were found:  " $(Format-Plural 'Link'      $howManyNewSymbolicLinks -includeCount) 
Write-Host "How many directories were flagged for scanning:           " $(Format-Plural 'Directory' $howManyDirectoriesFlaggedToScan -includeCount) 
#TODO: Update counts to session table

# Da Fuutar!!!
. D:\qt_projects\filmcab\simplified\shared_code\_dot_include_standard_footer.ps1

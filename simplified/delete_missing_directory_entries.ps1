<#
    FilmCab Daily morning process: Verify the paths and files and volumes stored in the files table exist on some hard drive.
    Status: Working in Test
    Should/Must Run After: scan_for_file_directories.ps1
    Should/Must Run Before       : scan_file_directories_for_files.ps1
    ###### Fri Jan 26 13:38:09 MST 2024

    This is done early in the batch so as to reduce labor later, trying to generate hashes on nonexistent files, listing files a dups when one doesn't exist.
#>

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()

. D:\qt_projects\filmcab\simplified\_dot_include_standard_header.ps1 # 

$HowManyDirectoryEntriesMapToExistingDirectories = 0    
$HowManyDirectoryEntriesNoLongerMapToExistingDirectories= 0
$HowManyDirectoryEntriesUpdated = 0

if ($DatabaseConnectionIsOpen) {
    $sql = "
    SELECT 
        directory_path,                         /* Deleted or not, we want to validate it. Probably more efficient filter is possible. Skip ones I just added, for instance. Don't descend deleted trees. */
        COALESCE(deleted, False) AS deleted
    FROM 
        directories
    "
    $readerHandle = (Select-Sql $sql) # Cannot return reader value directly from a function or it blanks, so return it boxed
    $reader = $readerHandle.Value # Now we can unbox!  Ta da!                                                                                                    

    Do { # Buggy problem: My "Select-Sql" does an initial read.  If it came back with no rows, this would crash. Ugh. Maybe a "Walk-Sql" that does not do a read.
        $directoryPath = $reader.GetValue(0)
        $escapedDirectoryPath = $directoryPath.Replace("'", "''")
        $alreadyMarkedAsDeleted = $reader.GetBoolean(1)

        if ([System.IO.File]::Exists($directoryPath)) {
            Write-Host -NoNewline '=.' # Found          
            $HowManyDirectoryEntriesMapToExistingDirectories++ 
            if ($alreadyMarkedAsDeleted) {                 
                Invoke-Sql "UPDATE directories SET deleted = False /* Leave any deleted_on value */ WHERE directory_path = '$escapedDirectoryPath'">$null
                $HowManyDirectoryEntriesUpdated++
            }                                    
        } else {             
            Write-Host -NoNewline '-.' # Missing
            $HowManyDirectoryEntriesNoLongerMapToExistingDirectories++
            if (-not $alreadyMarkedAsDeleted) {
                Invoke-Sql "UPDATE directories SET deleted = True, deleted_on = clock_timestamp() WHERE directory_path = '$escapedDirectoryPath'" >$null
                $HowManyDirectoryEntriesUpdated++
            }
        }
    } While ($reader.Read())

    $reader.Close()
                                                                    
    Write-Host # Get off the last nonewline
    Write-Host
    Write-Host "How many directory entries point to existing directories:                      $HowManyDirectoryEntriesMapToExistingDirectories"           $(Format-Plural 'Directory' $HowManyDirectoryEntriesMapToExistingDirectories) 
    Write-Host "How many directory entries no longer point to existing directories:            $HowManyDirectoryEntriesNoLongerMapToExistingDirectories"           $(Format-Plural 'Directory' $HowManyDirectoryEntriesNoLongerMapToExistingDirectories) 
    Write-Host "How many directory entries actually updated:                                   $HowManyDirectoryEntriesUpdated"           $(Format-Plural 'Directory' $HowManyDirectoryEntriesUpdated) 

}

. D:\qt_projects\filmcab\simplified\_dot_include_standard_footer.ps1
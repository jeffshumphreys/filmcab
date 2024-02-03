<#
    FilmCab Daily morning process: Verify the paths stored in the directories table exist on some hard drive.
    Status: Working in Test
    Should/Must Run After: scan_for_file_directories.ps1
    Should/Must Run Before       : scan_file_directories_for_files.ps1
    ###### Tue Jan 30 13:14:00 MST 2024

    This is done early in the batch so as to reduce labor later, trying to generate hashes on nonexistent files, listing files a dups when one doesn't exist.
#>

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()

. D:\qt_projects\filmcab\simplified\shared_code\_dot_include_standard_header.ps1

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
    $readerHandle = Walk-Sql $sql # Cannot return reader value directly from a function or it blanks, so return it boxed
    $reader = $readerHandle.Value # Now we can unbox!  Ta da!                                                                                                    

    While ($reader.Read()) {
        $directoryPath = $reader.GetValue(0)
        $escapedDirectoryPath = $directoryPath.Replace("'", "''")
        $alreadyMarkedAsDeleted = $reader.GetBoolean(1)

        if (Test-Path -LiteralPath $directoryPath) {
            Write-Host -NoNewline '=.' # Found          
            $HowManyDirectoryEntriesMapToExistingDirectories++ 
            if ($alreadyMarkedAsDeleted) {                 
                Invoke-Sql "UPDATE directories SET deleted = False WHERE directory_path = '$escapedDirectoryPath'" | Out-Null
                $HowManyDirectoryEntriesUpdated++
            }                                    
        } else {             
            Write-Host -NoNewline '-.' # Missing
            $HowManyDirectoryEntriesNoLongerMapToExistingDirectories++
            if (-not $alreadyMarkedAsDeleted) {
                Invoke-Sql "UPDATE directories SET deleted = True WHERE directory_path = '$escapedDirectoryPath'" | Out-Null
                $HowManyDirectoryEntriesUpdated++
            }
        }
    }

    $reader.Close()
                                                                    
    Write-Host # Get off the last nonewline
    Write-Host
    Write-Host "How many directory entries point to existing directories:                      $HowManyDirectoryEntriesMapToExistingDirectories"           $(Format-Plural 'Directory' $HowManyDirectoryEntriesMapToExistingDirectories) 
    Write-Host "How many directory entries no longer point to existing directories:            $HowManyDirectoryEntriesNoLongerMapToExistingDirectories"   $(Format-Plural 'Directory' $HowManyDirectoryEntriesNoLongerMapToExistingDirectories) 
    Write-Host "How many directory entries actually updated:                                   $HowManyDirectoryEntriesUpdated"                            $(Format-Plural 'Directory' $HowManyDirectoryEntriesUpdated) 

}

. D:\qt_projects\filmcab\simplified\shared_code\_dot_include_standard_footer.ps1
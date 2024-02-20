<#
    FilmCab Daily morning process: Verify the paths stored in the directories table exist on some hard drive.
    Status: Working in Test
    Should/Must Run After: scan_for_file_directories.ps1
    Should/Must Run Before       : scan_file_directories_for_files.ps1
    ###### Tue Jan 30 13:14:00 MST 2024

    This is done early in the batch so as to reduce labor later, trying to generate hashes on nonexistent files, listing files a dups when one doesn't exist.
#>

. .\_dot_include_standard_header.ps1

$HowManyDirectoryEntriesMapToExistingDirectories         = 0
$HowManyDirectoryEntriesNoLongerMapToExistingDirectories = 0
$HowManyDirectoryEntriesCorrected                        = 0

if ($DatabaseConnectionIsOpen) {
    $sql = "
                        SELECT 
                            directory_path           AS directory_path        , /* Deleted or not, we want to validate it. Probably more efficient filter is possible. Skip ones I just added, for instance. Don't descend deleted trees. */
                            COALESCE(deleted, False) AS directory_deleted
                        FROM 
                            directories
    "
    $reader = $reader = WhileReadSql $sql

    While ($reader.Read()) {
        $escapedDirectoryPath = $directory_path.Replace("'", "''")
        Write-AllPlaces -NoNewline '.'
        if (Test-Path -LiteralPath $directory_path) {
            $HowManyDirectoryEntriesMapToExistingDirectories++ 
            if ($directory_deleted) {                 
                Write-AllPlaces -NoNewline '✔️' # Found          (only shows up in Core, 6+)
                Invoke-Sql "UPDATE directories SET deleted = False WHERE directory_path = '$escapedDirectoryPath'" | Out-Null
                $HowManyDirectoryEntriesCorrected++
            }                                    
        } else {             
            $HowManyDirectoryEntriesNoLongerMapToExistingDirectories++
            if (-not $directory_deleted) {
                Write-AllPlaces -NoNewline '❌' # Missing                                 
                Invoke-Sql "UPDATE directories SET deleted = True WHERE directory_path = '$escapedDirectoryPath'" | Out-Null
                $HowManyDirectoryEntriesCorrected++
            }
        }
    }

    Write-Count HowManyDirectoryEntriesMapToExistingDirectories         Directory
    Write-Count HowManyDirectoryEntriesNoLongerMapToExistingDirectories Directory
    Write-Count HowManyDirectoryEntriesCorrected                        Directory

}

. .\_dot_include_standard_footer.ps1
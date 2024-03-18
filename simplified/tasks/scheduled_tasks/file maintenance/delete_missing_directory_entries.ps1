<#
    FilmCab Daily morning process: Verify the paths stored in the directories table exist on some hard drive.
    Status: Working in Test
    Should/Must Run After: scan_for_file_directories.ps1
    Should/Must Run Before       : scan_file_directories_for_files.ps1
    ###### Tue Jan 30 13:14:00 MST 2024

    This is done early in the batch so as to reduce labor later, trying to generate hashes on nonexistent files, listing files a dups when one doesn't exist.
#>
  
try {
. .\_dot_include_standard_header.ps1

$HowManyDirectoryEntriesMapToExistingDirectories         = 0
$HowManyDirectoryEntriesNoLongerMapToExistingDirectories = 0
$HowManyDirectoryEntriesCorrected                        = 0

if ($DatabaseConnectionIsOpen) {
    $reader = WhileReadSql "
        SELECT 
            directory             /* Deleted or not, we want to validate it. Probably a more efficient filter is possible. Skip ones I just added, for instance. Don't descend deleted trees. */
        ,   directory_escaped
        ,   directory_deleted
        FROM 
            directories_ext_v
    "

    While ($reader.Read()) {
        if (Test-Path -LiteralPath $directory) {
            $HowManyDirectoryEntriesMapToExistingDirectories++ 

            if ($directory_deleted) {                 
                _TICK_Found_Existing_Object
                Invoke-Sql "UPDATE directories_v SET directory_deleted = False WHERE directory = '$directory_escaped'" | Out-Null
                $HowManyDirectoryEntriesCorrected++
            }                                    
        } else {             
            $HowManyDirectoryEntriesNoLongerMapToExistingDirectories++

            if (-not $directory_deleted) {
                _TICK_Object_Marked_Deleted
                Invoke-Sql "UPDATE directories_v SET directory_deleted = True WHERE directory = '$directory_escaped'" | Out-Null
                $HowManyDirectoryEntriesCorrected++
            }
        }
    }

    Write-Count HowManyDirectoryEntriesMapToExistingDirectories         Directory
    Write-Count HowManyDirectoryEntriesNoLongerMapToExistingDirectories Directory
    Write-Count HowManyDirectoryEntriesCorrected                        Directory

}

}
catch {
    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}                                  
finally {
    Write-AllPlaces "Finally" -ForceStartOnNewLine
    . .\_dot_include_standard_footer.ps1
}
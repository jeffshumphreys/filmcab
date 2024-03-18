<#
    FilmCab Daily morning process: Verify the paths and files and volumes stored in the files table exist on some hard drive.
    Status: Writing
    Should/Must Run After: delete_file_entries_in_deleted_directories
    Should/Must Run Before       : delete_references_to_missing_files
    ###### Tue Jan 30 13:21:06 MST 2024

    After this and the fill missing hashes, we're ready to do real work.
#>

try {
. .\_dot_include_standard_header.ps1
             
$HowManyFileEntriesMapToExistingFiles        = 0
$HowManyFileEntriesNoLongerMapToExistingFile = 0
$HowManyFileEntriesUpdated                   = 0
$HowManyFileEntriesDeleted                   = 0
$HowManyFileEntriesUndeleted                 = 0

if ($DatabaseConnectionIsOpen) {
    $reader = WhileReadSql "
        SELECT 
            file_path,
            file_deleted,
            file_id
        FROM 
            files_ext_v
        "

    While ($reader.Read()) {
        if (Test-Path -LiteralPath $file_path) {
            _TICK_Found_Existing_Object
            $HowManyFileEntriesMapToExistingFiles++ 
            if ($file_deleted) {                                                      
                _TICK_Update_Object_Status # Need an undelete tick.
                Invoke-Sql "UPDATE files_v SET file_deleted = False WHERE file_id = $file_id" | Out-Null
                $HowManyFileEntriesUpdated++
                $HowManyFileEntriesUndeleted++
            }                                    
        } else {             
            _TICK_Sought_Object_Not_Found
            $HowManyFileEntriesNoLongerMapToExistingFile++
            if (-not $file_deleted) {                                                           
                _TICK_Update_Object_Status
                Invoke-Sql "UPDATE files_v SET file_deleted = True WHERE file_id = $file_id" | Out-Null
                $HowManyFileEntriesUpdated++                                                        
                $HowManyFileEntriesDeleted++
            }
        }
    } 
                                                             
    #TODO: Have footer just grab ANY int variables that start with "HowMany"????? Cray-Cray!
    
    Write-Count  HowManyFileEntriesMapToExistingFiles        File
    Write-Count  HowManyFileEntriesNoLongerMapToExistingFile File
    Write-Count  HowManyFileEntriesUpdated                   File
    Write-Count  HowManyFileEntriesDeleted                   File
    Write-Count  HowManyFileEntriesUndeleted                 File

}

}
catch {
    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}                                  
finally {
    Write-AllPlaces "Finally" -ForceStartOnNewLine
    . .\_dot_include_standard_footer.ps1
}
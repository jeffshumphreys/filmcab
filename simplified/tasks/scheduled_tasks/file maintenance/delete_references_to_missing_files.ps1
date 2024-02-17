<#
    FilmCab Daily morning process: Verify the paths and files and volumes stored in the files table exist on some hard drive.
    Status: Writing
    Should/Must Run After: delete_file_entries_in_deleted_directories
    Should/Must Run Before       : delete_references_to_missing_files
    ###### Tue Jan 30 13:21:06 MST 2024

    After this and the fill missing hashes, we're ready to do real work.
#>

. .\_dot_include_standard_header.ps1
             
$HowManyFileEntriesMapToExistingFiles        = 0
$HowManyFileEntriesNoLongerMapToExistingFile = 0
$HowManyFileEntriesUpdated                   = 0
$HowManyFileEntriesDeleted                   = 0
$HowManyFileEntriesUndeleted                 = 0

if ($DatabaseConnectionIsOpen) {
    $sql = "
                    SELECT 
                        d.directory_path || '\' || f.file_name_no_ext || CASE WHEN f.final_extension <> '' THEN '.' || f.final_extension ELSE '' END AS file_path,
                        COALESCE(f.deleted, False)                                                                                                   AS file_deleted,
                        f.file_id                                                                                                                    AS file_id
                    FROM 
                        files       f
                    JOIN
                        directories d  USING(directory_hash)
                    WHERE 
                        d.deleted is distinct from true
    "
    $reader = WhileReadSql $sql # Cannot return reader value directly from a function or it blanks, so return it boxed

    While ($reader.Read()) {
        if (Test-Path -LiteralPath $file_path) {
            Write-Host -NoNewline '=' # Found          
            $HowManyFileEntriesMapToExistingFiles++ 
            if ($file_deleted) {                 
                Invoke-Sql "UPDATE files SET deleted = False WHERE file_id = $file_id" | Out-Null
                $HowManyFileEntriesUpdated++
                $HowManyFileEntriesUndeleted++
            }                                    
        } else {             
            Write-Host -NoNewline '-' # Missing
            $HowManyFileEntriesNoLongerMapToExistingFile++
            if (-not $file_deleted) {
                Invoke-Sql "UPDATE files SET deleted = True WHERE file_id = $file_id" | Out-Null
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

. .\_dot_include_standard_footer.ps1
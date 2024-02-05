<#
    FilmCab Daily morning process: Verify the paths and files and volumes stored in the files table exist on some hard drive.
    Status: Writing
    Should/Must Run After: delete_file_entries_in_deleted_directories
    Should/Must Run Before       : delete_references_to_missing_files
    ###### Tue Jan 30 13:21:06 MST 2024

    After this and the fill missing hashes, we're ready to do real work.
#>

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()

. D:\qt_projects\filmcab\simplified\shared_code\_dot_include_standard_header.ps1
             
$HowManyFileEntriesMapToExistingFiles = 0
$HowManyFileEntriesNoLongerMapToExistingFile = 0
$HowManyFileEntriesUpdated = 0
$HowManyFileEntriesDeleted = 0
$HowManyFileEntriesUndeleted = 0

if ($DatabaseConnectionIsOpen) {
    $sql = "
    SELECT 
        d.directory_path || '\' || f.file_name_no_ext || CASE WHEN f.final_extension <> '' THEN '.' || f.final_extension ELSE '' END AS file_path,
        COALESCE(f.deleted, False)                                                                                               AS file_deleted,
        f.file_id                                                                                                                AS file_id
    FROM 
        files       f
    JOIN
        directories d  USING(directory_hash)
    WHERE 
        d.deleted is distinct from true
    "
    $readerHandle = Walk-Sql $sql # Cannot return reader value directly from a function or it blanks, so return it boxed
    $reader = $readerHandle.Value # Now we can unbox!  Ta da!                                                                                                    

    While ($reader.Read()) {
        $filePath = $reader.GetValue(0)
        $alreadyMarkedAsDeleted = $reader.GetBoolean(1)                                                        
        $fileId = $reader.GetInt32(2)

        if (Test-Path -LiteralPath $filePath) {
            Write-Host -NoNewline '=' # Found          
            $HowManyFileEntriesMapToExistingFiles++ 
            if ($alreadyMarkedAsDeleted) {                 
                Invoke-Sql "UPDATE files SET deleted = False WHERE file_id = $fileId" | Out-Null
                $HowManyFileEntriesUpdated++
                $HowManyFileEntriesUndeleted++
            }                                    
        } else {             
            Write-Host -NoNewline '-' # Missing
            $HowManyFileEntriesNoLongerMapToExistingFile++
            if (-not $alreadyMarkedAsDeleted) {
                Invoke-Sql "UPDATE files SET deleted = True WHERE file_id = $fileId" | Out-Null
                $HowManyFileEntriesUpdated++                                                        
                $HowManyFileEntriesDeleted++
            }
        }
    } 

    $reader.Close()
                                                                    
    Write-Host # Get off the last nonewline
    Write-Host
    Write-Host "How many file entries point to existing files:             $HowManyFileEntriesMapToExistingFiles"       $(Format-Plural 'File' $HowManyFileEntriesMapToExistingFiles) 
    Write-Host "How many file entries no longer point to existing files:   $HowManyFileEntriesNoLongerMapToExistingFile"$(Format-Plural 'File' $HowManyFileEntriesNoLongerMapToExistingFile) 
    Write-Host "How many file entries updated:                             $HowManyFileEntriesUpdated"                  $(Format-Plural 'File' $HowManyFileEntriesUpdated) 
    Write-Host "How many file entries deleted:                             $HowManyFileEntriesDeleted"                  $(Format-Plural 'File' $HowManyFileEntriesDeleted) 
    Write-Host "How many file entries undeleted:                           $HowManyFileEntriesUndeleted"                $(Format-Plural 'File' $HowManyFileEntriesUndeleted) 

}

. D:\qt_projects\filmcab\simplified\shared_code\_dot_include_standard_footer.ps1
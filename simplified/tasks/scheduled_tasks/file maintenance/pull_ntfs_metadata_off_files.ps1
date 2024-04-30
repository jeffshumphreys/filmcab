<#
 #    FilmCab Daily morning batch run process: Get internal id of files to detect name changes that mean no actual backup.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Concept
 #    ###### Tue Jan 23 18:23:11 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #
 # ###### Thu Mar 21 13:44:58 MDT 2024 Took 10 minutes to go through 40,489 real files and no updates since ntfs_ids matched.  Not bad but I hate redundancy.
 #>

try {
. .\_dot_include_standard_header.ps1

$howManyUpdatedFiles     = 0
$howManyEmptiesPopulated = 0
$howManyChangedValue     = 0

# Let's traverse all the undeleted directories flagged for scan. scan_for_file_directories sets the flag before this daily.

$walkThruAllFilesReader = WhileReadSql <#sql#>"
    SELECT 
        file_id
    ,   file_path
    ,   file_ntfs_id         AS in_db_file_ntfs_id
    ,   how_many_real_files /* Use this for progress bar is possible. */
    FROM 
        files_ext_v
    WHERE
        is_real_file
"

While ($walkThruAllFilesReader.Read()) {
    if ((Test-Path -LiteralPath $file_path)) {
        _TICK_Found_Existing_Object
        $on_fs_file_ntfs_id = (fsutil file queryfileid $file_path).Substring(13) # Trim off annoying lead text
        $in_db_file_ntfs_id = Convert-ByteArrayToHexString ($in_db_file_ntfs_id)

        # Must be able to get an id from fsutil.  Either we're on linux or some cases don't return an id.
        if ($null -eq $on_fs_file_ntfs_id) {
            # We weren't able to get an id from the file
            _TICK_Impossible_Outcome
            Show-Error "Unable to get an ntfs_id from fsutil for this file"
        }

        # Either an id is missing or they've changed. Should track changes to id separately.

        if ($null -eq $in_db_file_ntfs_id -or $on_fs_file_ntfs_id -ne $in_db_file_ntfs_id) {
            _TICK_Existing_Object_Actually_Changed
            Invoke-Sql "
                UPDATE 
                    files_v 
                SET 
                    file_ntfs_id = '$on_fs_file_ntfs_id'::bytea     /* You'd think it'd be an integer, but it's too big */
                WHERE 
                    file_id = $file_id
            "|Out-Null
            $howManyUpdatedFiles++
            if ($null -eq $in_db_file_ntfs_id) {
                $howManyEmptiesPopulated++
            }               
            elseif ($on_fs_file_ntfs_id -ne $in_db_file_ntfs_id) { # Note that in PS, $null can not equal a not-null. Hence the elseif
                $howManyChangedValue++
            }
        }
            
        # optimizemetadata 	This performs an immediate compaction of the metadata for a given file.
        # queryoptimizemetadata 	Queries the metadata state of a file.
        # fsutil file layout $file_path    
    }
}

Write-Count howManyUpdatedFiles          File
Write-Count howManyEmptiesPopulated      Id
Write-Count howManyChangedValue          Id
}
catch {
    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}                                  
finally {
    Write-AllPlaces "Finally" -ForceStartOnNewLine
    . .\_dot_include_standard_footer.ps1
}
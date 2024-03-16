<#
 #    FilmCab Daily morning batch run process: Get internal id of files to detect name changes that mean no actual backup.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Concept
 #    ###### Tue Jan 23 18:23:11 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
  #>

. .\_dot_include_standard_header.ps1

$howManyUpdatedFiles     = 0

# Let's traverse all the undeleted directories flagged for scan. scan_for_file_directories sets the flag before this daily.

$walkThruAllFilesReader = WhileReadSql <#sql#>"
    SELECT 
        file_id
    ,   file_path
    ,   file_ntfs_id         AS in_db_file_ntfs_id
    FROM 
        files_ext_v
    WHERE
        NOT directory_deleted
    AND
        NOT directory_is_symbolic_link
    AND
        NOT directory_is_junction_link
    AND                      
        NOT file_deleted
    AND
        NOT file_is_symbolic_link
    AND
        NOT file_is_hard_link
"

While ($walkThruAllFilesReader.Read()) {
    if ((Test-Path -LiteralPath $file_path)) {
        _TICK_Existing_Object_Edited
        $on_fs_file_ntfs_id = (fsutil file queryfileid $file_path).Substring(13) # Trim off annoying lead text
        $file_streams = Get-Item -LiteralPath $file_path -Stream *

        if ($null -eq $on_fs_file_ntfs_id -or $on_fs_file_ntfs_id -ne $in_db_file_ntfs_id) {
            _TICK_Existing_Object_Actually_Changed
            Invoke-Sql "UPDATE files_v SET file_ntfs_id = '$on_fs_file_ntfs_id'::bytea WHERE file_id = $file_id"|Out-Null
            $howManyUpdatedFiles++
        }
            
        # optimizemetadata 	This performs an immediate compaction of the metadata for a given file.
        # queryoptimizemetadata 	Queries the metadata state of a file.
        # fsutil file layout $file_path    
    }
}

Write-Count howManyUpdatedFiles           File

. .\_dot_include_standard_footer.ps1
<#
 #    FilmCab Daily morning batch run process: Fill any missing hashes.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Runs manually; prepping for lineup.
 #    ###### Tue Jan 23 18:23:11 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #
 #>

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()

. D:\qt_projects\filmcab\simplified\_dot_include_standard_header.ps1

$DEFAULT_POWERSHELL_TIMESTAMP_FORMAT = "yyyy-MM-dd HH:mm:ss.ffffff zzz"      # 2024-01-22 05:37:00.450241 -07:00    ONLY to 6 places (microseconds). Windows has 7 places, which won't match with Postgres's 6
# FYI: $DEFAULT_POSTGRES_TIMESTAMP_FORMAT = "yyyy-mm-dd hh24:mi:ss.us tzh:tzm"    # 2024-01-22 05:36:46.489043 -07:00

# Found example on Internet that uses a LIFOstack. Changed it to FIFO Queue would pull current search path first and possibly save a little time.

# Track some stats. Useful for finding bugs. For instance, kept getting 12 new junction points, the same ones. turns out the test was bad.

$howManyUpdatedFiles = 0

# Let's traverse all the undeleted directories flagged for scan. scan_for_file_directories sets the flag before this daily.

if ($DatabaseConnectionIsOpen) {
    $sql = "
    SELECT 
        d.directory_path || '\' || f.file_name_no_ext || CASE WHEN final_extension <> '' THEN '.' || final_extension ELSE '' END AS file_path,
        f.file_id                                                                                                                AS file_id
    FROM 
        files       f
    JOIN
        directories d  USING(directory_hash)
    WHERE 
        d.deleted is distinct from true
    AND 
        f.is_symbolic_link is distinct from true
    AND
        f.is_hard_link is distinct from true
    AND
        f.file_hash IS NULL
    "
    $readerHandle = Walk-Sql $sql # Cannot return reader value directly from a function or it blanks, so return it boxed
    $reader = $readerHandle.Value # Now we can unbox!  Ta da!                                                                                                    

    While ($reader.Read()) {
        $file_path = $reader.GetString(0)
        $file_id = $reader.GetInt32(1)
        
        if ((Test-Path $file_path)) {
            $on_fs_file_hash = (Get-FileHash -LiteralPath $file_path -Algorithm MD5).Hash
                    $update_sql = "
                        UPDATE
                            files
                        SET 
                            file_hash         = '$in_db_file_hash'::bytea
                        WHERE
                            file_id = '$file_id'
                    "
                    $howManyRowsUpdated = Invoke-Sql $update_sql
                    if ($howManyRowsUpdated -ne 1) {
                        throw [Exception]"Update failed to update anything or too many: $howManyRowsUpdated"
                    }                                                                  

                    Write-Host '>' -NoNewline 
                    $howManyUpdatedFiles++
        }
    } 
}


# Display counts. If nothing is happening in certain areas, investigate.
Write-Host # Get off the last nonewline
Write-Host
Write-Host "How many files were updated:                    $howManyUpdatedFiles"       $(Format-Plural 'File' $howManyUpdatedFiles) 
#TODO: Update counts to session table

# Da Fuutar!!!
. D:\qt_projects\filmcab\simplified\_dot_include_standard_footer.ps1
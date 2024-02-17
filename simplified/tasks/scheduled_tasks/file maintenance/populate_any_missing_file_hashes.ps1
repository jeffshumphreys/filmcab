<#
 #    FilmCab Daily morning batch run process: Fill any missing hashes.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Runs manually; prepping for lineup.
 #    ###### Tue Jan 23 18:23:11 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #
 #>

. .\_dot_include_standard_header.ps1

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
                        d.deleted IS DISTINCT FROM true    
                    AND 
                        f.is_symbolic_link IS DISTINCT FROM true
                    AND
                        f.is_hard_link IS DISTINCT FROM true
                    AND
                        f.file_hash IS NULL
    "
    $reader = WhileReadSql $sql # Cannot return reader value directly from a function or it blanks, so return it boxed

    While ($reader.Read()) {
        if ((Test-Path $file_path)) {
            $on_fs_file_hash = (Get-FileHash -LiteralPath $file_path -Algorithm MD5).Hash
                    $update_sql = "
                        UPDATE
                            files
                        SET 
                            file_hash         = '$on_fs_file_hash'::bytea
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

Write-Count howManyUpdatedFiles File

#TODO: Update counts to session table

. .\_dot_include_standard_footer.ps1
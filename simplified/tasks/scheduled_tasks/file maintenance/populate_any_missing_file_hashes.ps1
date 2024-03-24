<#
 #    FilmCab Daily morning batch run process: Fill any missing hashes.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Runs manually; prepping for lineup.
 #    ###### Tue Jan 23 18:23:11 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #    Note: Not sure anything ever happens.
 #>

try {
. .\_dot_include_standard_header.ps1

$howManyUpdatedFiles = 0

# Let's traverse all the undeleted directories flagged for scan. scan_for_file_directories sets the flag before this daily.

if ($DatabaseConnectionIsOpen) {
    $reader = WhileReadSql "
        SELECT 
            file_path,
            file_id
        FROM 
            files_ext_v       
        WHERE 
            is_real_file
        AND
            file_hash IS NULL
    "

    While ($reader.Read()) {
        if ((Test-Path $file_path)) {
            $on_fs_file_hash = (Get-FileHash -LiteralPath $file_path -Algorithm MD5).Hash
                    
                    Invoke-Sql "
                        UPDATE
                            files_v
                        SET 
                            file_hash   = '$on_fs_file_hash'::bytea
                        WHERE
                            file_id     = $file_id
                    " -OneAndOnlyOne |Out-Null

                    _TICK_Existing_Object_Actually_Changed
                    $howManyUpdatedFiles++
        }
    } 
}

Write-Count howManyUpdatedFiles File

#TODO: Update counts to session table

}
catch {
    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}                                  
finally {
    Write-AllPlaces "Finally" -ForceStartOnNewLine
    . .\_dot_include_standard_footer.ps1
}
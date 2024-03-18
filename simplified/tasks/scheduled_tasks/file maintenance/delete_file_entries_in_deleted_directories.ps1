<#
    FilmCab Daily morning process: Delete any files where directory is marked deleted.
    Status: Undeveloped
    Should/Must Run After: delete_missing_directory_entries.ps1
    Should/Must Run Before       : delete_references_to_missing_files.ps1
    ###### Mon Jan 29 18:12:26 MST 2024
#>

try {
. .\_dot_include_standard_header.ps1

$HowManyFilesDeleted = 0    

if ($DatabaseConnectionIsOpen) {
    $HowManyFilesDeleted = Invoke-Sql "
    WITH
        directories_marked_as_deleted AS (
            SELECT 
                directory_hash
            FROM               
                files_ext_v
            WHERE
                directory_deleted
            AND
                NOT file_deleted /* We won't bother updatin' ones that are already deleted */
            )
    UPDATE files_v
        SET file_deleted = TRUE 
    FROM 
        directories_marked_as_deleted 
    WHERE 
        files_v.directory_hash = directories_marked_as_deleted.directory_hash
    "

    Write-Count HowManyFilesDeleted File

}

}
catch {
    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}                                  
finally {
    Write-AllPlaces "Finally" -ForceStartOnNewLine
    . .\_dot_include_standard_footer.ps1
}
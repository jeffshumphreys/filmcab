<#
    FilmCab Daily morning process: Delete any files where directory is marked deleted.
    Status: Undeveloped
    Should/Must Run After: delete_missing_directory_entries.ps1
    Should/Must Run Before       : delete_references_to_missing_files.ps1
    ###### Mon Jan 29 18:12:26 MST 2024
#>

. .\_dot_include_standard_header.ps1 # 

$HowManyFilesDeleted = 0    

if ($DatabaseConnectionIsOpen) {
    $sql = "
    WITH x AS (
    SELECT 
        f.directory_hash
    FROM               
        files f JOIN directories d USING (directory_hash) 
    WHERE
        d.deleted IS TRUE
    AND
        f.deleted IS DISTINCT FROM TRUE /* We won't bother updatin' ones that are already deleted */
    )
    UPDATE files SET deleted = true
    FROM x WHERE files.directory_hash = x.directory_hash
    "

    $HowManyFilesDeleted = Invoke-Sql $sql

    Write-Count HowManyFilesDeleted File

}

. .\_dot_include_standard_footer.ps1
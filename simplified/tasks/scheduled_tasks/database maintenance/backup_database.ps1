<#
 #    FilmCab Daily morning batch run process: Backup the database.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Runs manually; prepping for lineup.
 #    ###### Tue Jan 23 18:23:11 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #
 #>
 
 try {
. .\_dot_include_standard_header.ps1

$RidiculousLongTimestamp = (Get-Date).DateTime -replace ':', ' ' # ":" is an illegal file name character

# format c = Output a custom-format archive suitable for input into pg_restore. Together with the directory output format, this is the most flexible output format in that it allows manual selection and reordering of archived items during restore. This format is also compressed by default

$file_name_base = "$($Config.backup_path)/dump-$($Config.database)-database-data-$($Config.database_schema)-schema.$RidiculousLongTimestamp.sql"
      
Write-AllPlaces "base to all backups: $file_name_base"
                                                    
$backup_file_path = "$file_name_base-compressed.sql"
#TODO: Convert following to function
$output = & pg_dump.exe --verbose --format=custom --file "$backup_file_path" --dbname=$($Config.database) --schema=$($Config.database_schema) 2>&1 
Write-AllPlaces "(1) pg_dump to $backup_file_path completed"

$stdout = $output | ?{ $_ -isnot [System.Management.Automation.ErrorRecord] }
$stderr = $output | ?{ $_ -is [System.Management.Automation.ErrorRecord] }
            
if ($null -ne $stdout) {
    $stdout = $stdout.Replace("[", [System.Environment]::NewLine)
    Write-AllPlaces $stdout # TEST:
}

if ($null -ne $stderr) {
    $stderr|% {
        Write-AllPlaces $_
    }
}
                                                                                                                           
Get-Item $backup_file_path|Select ResolvedTarget, Name, Length, CreationTime, CreationTimeUTC, Attributes
# format p = simple text

$targetPath = "$file_name_base-in_text.sql"
pg_dump.exe --verbose --format=plain --file "$targetPath"  --dbname=$($Config.database) --schema=$($Config.database_schema) --blobs|Out-Host
Write-AllPlaces "(2) pg_dump to $targetPath completed"

$targetPath = "$file_name_base-table-files-in_text.sql"
pg_dump.exe --verbose --format=plain --file "$targetPath" --dbname=$($Config.database) --schema=$($Config.database_schema) --table=$($Config.database_schema).files --blobs|Out-Host
Write-AllPlaces "(3) pg_dump to $targetPath completed"
                                                                                     
$file_name_base        = "$($Config.backup_path)/dump-$($Config.database)-database-$($Config.database_schema)-schema-only.$RidiculousLongTimestamp.sql"
$file_name_to_codebase = "$($Config.backup_path)/dump-$($Config.database)-database-$($Config.database_schema)-schema-only.sql"
                                            
$targetPath = "$file_name_base-in_text.sql"
pg_dump.exe --verbose --format=plain --file "$targetPath" --schema-only --dbname=$($Config.database) --schema=$($Config.database_schema) --blobs|Out-Host
Write-AllPlaces "(4) pg_dump to $targetPath completed"

######################################################################################################################################################################################
#
#         Compare new and previous schemas for material differences. If any difference, push new schema to github local project folder.
#
######################################################################################################################################################################################

# Step 1: Determine hash for new schema without touching project folder.

$new_schema_path = $targetPath

$temp_file_for_new_schema = New-TemporaryFile

$new_schema = Get-Content $new_schema_path
$clean_new_schema_lines = @()

Foreach ($line in $new_schema) {
    if ($line -notmatch "^-- (Started|Completed) on \d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d$" -and
        $line -notmatch "^-- TOC entry" -and
        $line -notmatch "^-- Dependencies:"
    ) {
        $clean_new_schema_lines+= $line
    }
}                                
$clean_new_schema_lines|Set-Content -Path $temp_file_for_new_schema

$new_sql_hash      = (Get-FileHash -Path $temp_file_for_new_schema -Algorithm MD5).Hash

$path_base_for_all = "$($Config.local_path)\$($Config.subfolder)"

$file_name_in_codebase               = "$path_base_for_all/sql/dump-$($Config.database)-database-$($Config.database_schema)-schema-only.sql"
$file_name_in_codebase_previous_copy = "$path_base_for_all/sql/dump-$($Config.database)-database-$($Config.database_schema)-schema-only.prev.sql"

Write-AllPlaces "`$file_name_in_codebase               = $file_name_in_codebase"
Write-AllPlaces "`$file_name_in_codebase_previous_copy = $file_name_in_codebase_previous_copy"

# Step 2: Determine hash for previous schema if there is a previous schema.

$prev_schema_path = $file_name_in_codebase_previous_copy
$previous_sql_hash = "0"

$temp_file_for_prev_schema = New-TemporaryFile

if (Test-Path $prev_schema_path) {
    $prev_schema = Get-Content $prev_schema_path
    $clean_prev_schema_lines = @()
    
    Foreach ($line in $prev_schema) {
        if ($line -notmatch "^-- (Started|Completed) on \d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d$" -and
        $line -notmatch "^-- TOC entry" -and
        $line -notmatch "^-- Dependencies:"
        ) {
            $clean_prev_schema_lines+= $line
        }
    }                     
    $clean_prev_schema_lines|Set-Content -Path $temp_file_for_prev_schema
    $previous_sql_hash = (Get-FileHash -LiteralPath $temp_file_for_prev_schema -Algorithm MD5).Hash
}

if ($previous_sql_hash -ne $new_sql_hash) {
    Write-AllPlaces "Difference between new and last DDL detected."
    Copy-Item $temp_file_for_prev_schema -Destination $file_name_in_codebase_previous_copy -Force -Verbose
    Copy-Item $temp_file_for_new_schema -Destination $file_name_in_codebase -Force -Verbose # Will trigger github changes    
} else {
    Write-AllPlaces "No material difference between new and last DDL detected."
}

}
catch {
    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}                                  
finally {
    Write-AllPlaces "Finally" -ForceStartOnNewLine
    . .\_dot_include_standard_footer.ps1
}
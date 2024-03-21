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

$RidiculousLongTimestamp = (Get-Date).DateTime -replace ':', ' '

# format c = Output a custom-format archive suitable for input into pg_restore. Together with the directory output format, this is the most flexible output format in that it allows manual selection and reordering of archived items during restore. This format is also compressed by default
                                                                      
$file_name_base = "C:\FilmCab Backups/dump-filmcab-database-data-simplified-schema.$RidiculousLongTimestamp"
      
Write-AllPlaces "base to all backups: $file_name_base"
                                                    
$backup_file_path = "$file_name_base-compressed.sql"
#TODO: Convert following to function
$output = & pg_dump.exe --verbose --format=c --file "$backup_file_path" --dbname=filmcab --schema=simplified 2>&1 
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

pg_dump.exe --verbose --format=p --file "$file_name_base-in_text.sql" --dbname=filmcab --schema=simplified --blobs|Out-Host

pg_dump.exe --verbose --format=p --file "$file_name_base-table-files-in_text.sql" --dbname=filmcab --schema=simplified --table=files --blobs|Out-Host

$file_name_base = "C:\FilmCab Backups/dump-filmcab-database-simplified-schema-only-.$RidiculousLongTimestamp"
$file_name_to_codebase = "C:\FilmCab Backups/dump-filmcab-database-simplified-schema-only.sql"
                                                                       
pg_dump.exe --verbose --format=p --file "$file_name_base-in_text.sql" --schema-only --dbname=filmcab --schema=simplified --blobs|Out-Host

$schema = Get-Content "$file_name_base-in_text.sql"
$date_free_schema = @()

Foreach ($line in $schema) {
    if ($line -notmatch "^-- (Started|Completed) on \d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d$") {
        $date_free_schema+= $line
    }
}                                
$date_free_schema|Set-Content -Path $file_name_to_codebase
                                   
$file_name_in_codebase = "D:\qt_projects/filmcab/simplified/sql/dump-filmcab-database-simplified-schema-only.sql"
$file_name_in_codebase_previous_copy = "D:\qt_projects/filmcab/simplified/sql/dump-filmcab-database-simplified-schema-only.$RidiculousLongTimestamp.sql"
    
$previous_sql_hash = (Get-FileHash -LiteralPath $file_name_to_codebase -Algorithm MD5).Hash
$new_sql_hash = (Get-FileHash -LiteralPath $file_name_in_codebase -Algorithm MD5).Hash

if ($previous_sql_hash -ne $new_sql_hash) {
    Copy-Item $file_name_in_codebase -Destination $file_name_in_codebase_previous_copy -Force -Verbose
    Copy-Item $file_name_to_codebase -Destination $file_name_in_codebase -Force -Verbose # Will trigger github changes    
    Copy-Item $file_name_to_codebase -Destination $file_name_in_codebase -Force -Verbose
}

}
catch {
    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}                                  
finally {
    Write-AllPlaces "Finally" -ForceStartOnNewLine
    . .\_dot_include_standard_footer.ps1
}
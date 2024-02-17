<#
 #    FilmCab Daily morning batch run process: Backup the database.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Runs manually; prepping for lineup.
 #    ###### Tue Jan 23 18:23:11 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #
 #>

 [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
 [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
 param()
 
. .\_dot_include_standard_header.ps1

$RidiculousLongTimestamp = (Get-Date).DateTime -replace ':', ' '

# format c = Output a custom-format archive suitable for input into pg_restore. Together with the directory output format, this is the most flexible output format in that it allows manual selection and reordering of archived items during restore. This format is also compressed by default
                                                                      
$file_name_base = "C:\FilmCab Backups/dump-filmcab-database-data_and_schema-.$RidiculousLongTimestamp"

pg_dump.exe --verbose --format=c --file "$file_name_base-compressed.sql" --dbname=filmcab --schema=simplified --blobs
                                                                                                                                                  
# format p = simple text

pg_dump.exe --verbose --format=p --file "$file_name_base-in_text.sql" --dbname=filmcab --schema=simplified --blobs

pg_dump.exe --verbose --format=p --file "$file_name_base-table-files-in_text.sql" --dbname=filmcab --schema=simplified --table=files --blobs

$file_name_base = "C:\FilmCab Backups/dump-filmcab-database-schema-only-.$RidiculousLongTimestamp"
                                                                       
pg_dump.exe --verbose --format=p --file "$file_name_base-in_text.sql" --schema-only --dbname=filmcab --schema=simplified --blobs

. .\_dot_include_standard_footer.ps1
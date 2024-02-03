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
 
. D:\qt_projects\filmcab\simplified\shared_code\_dot_include_standard_header.ps1

'pg_dump.exe --verbose --host=localhost --port=5432 ****** --format=c --file "C:\filmcab backups/dump-filmcab-database.sql" -n "simplified" filmcab'

. D:\qt_projects\filmcab\simplified\shared_code\_dot_include_standard_footer.ps1
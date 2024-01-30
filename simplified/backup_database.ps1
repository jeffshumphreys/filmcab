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
 

'pg_dump.exe --verbose --host=localhost --port=5432 ****** --format=c --file C:\filmcab backups/dump-filmcab-202401301323.sql -n "simplified" filmcab'

. D:\qt_projects\filmcab\simplified\_dot_include_standard_footer.ps1
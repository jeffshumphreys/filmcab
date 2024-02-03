<#
 #    FilmCab Daily morning batch run process: Clean-up space left by updates and deletes.
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
 
Invoke-Sql 'VACUUM (FULL, VERBOSE);'

. D:\qt_projects\filmcab\simplified\_dot_include_standard_footer.ps1
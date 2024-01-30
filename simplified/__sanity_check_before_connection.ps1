<#
 #    FilmCab Daily morning batch run process: Check things like if we are on Windows, or what version of PowerShell, what's the server, all before connecting to a database.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: No Work Done
 #    ###### Tue Jan 23 18:23:11 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #
 #>

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()

. D:\qt_projects\filmcab\simplified\_dot_include_standard_header.ps1

$DEFAULT_POWERSHELL_TIMESTAMP_FORMAT = "yyyy-MM-dd HH:mm:ss.ffffff zzz"      # 2024-01-22 05:37:00.450241 -07:00    ONLY to 6 places (microseconds). Windows has 7 places, which won't match with Postgres's 6

# Is this Windows, Linux, or Mac?

# Is Task Scheduler History enabled?

# Is there space on drives?

# Is PostgreSQL installed?

# Is ODBC driver installed?


# Da Fuutar!!!
. D:\qt_projects\filmcab\simplified\_dot_include_standard_footer.ps1
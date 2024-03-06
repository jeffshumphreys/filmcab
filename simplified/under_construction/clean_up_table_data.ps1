<#
 #    FilmCab Daily morning batch run process: Various data flaws can exist when logic has changed for inserted stuff but not regressed into previously added data.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Conception
 #    ###### Sat Feb 3 22:20:01 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #>

 . .\_dot_include_standard_header.ps1

Invoke-Sql "UPDATE directories SET folder = reverse((string_to_array(reverse(replace(directory_path::text, '\'::text, '\\'::text)), '\'))[1]) WHERE folder IS NULL"
Invoke-Sql "UPDATE directories SET parent_folder = reverse((string_to_array(reverse(replace(directory_path::text, '\'::text, '\\'::text)), '\'))[2]) WHERE parent_folder IS NULL"
Invoke-Sql "UPDATE directories SET grandparent_folder = reverse((string_to_array(reverse(replace(directory_path::text, '\'::text, '\\'::text)), '\'))[3]) WHERE grandparent_folder IS NULL"

. .\_dot_include_standard_footer.ps1

#>
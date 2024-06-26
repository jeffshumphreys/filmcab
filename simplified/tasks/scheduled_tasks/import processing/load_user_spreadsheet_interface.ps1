<#
 #    FilmCab Daily morning batch run process: Import user's spreadsheet of movies they've seen or want to see.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Complete
 #    ###### Tue Jan 23 18:23:11 MST 2024
 #    Reviewed and refactored: ###### Sat Feb 17 12:02:04 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #    Last run time: 21 seconds
 #>

try {
. .\_dot_include_standard_header.ps1

$targettable     = 'user_spreadsheet_interface'
$copyfrompath    = "D:\qt_projects\filmcab\simplified\_data\$targettable.ods" # Extension must be xls for ImportExcel to work even though I'm using ods Calc.
$copytodirectory = "D:\qt_projects\filmcab\simplified\_data" # Extension must be xls for ImportExcel to work even though I'm using ods Calc.
$copytopath      = "$copytodirectory\$targettable.csv" # Extension must be xls for ImportExcel to work even though I'm using ods Calc.

Stop-Process -Name 'excel' -Force -ErrorAction Ignore

soffice --headless --convert-to csv  $copyfrompath --outdir $copytodirectory
$NewExcelCSVFileGenerated = $true

Invoke-Sql "TRUNCATE TABLE $targettable RESTART IDENTITY" -LogSqlToHost
#TODO: Pull these from the spreadsheet?
$columns_csv = "
    seen,
    have,
    title,                    /* column 1 of index */
    year_of_season,
    season,                   /* column 3 of index */
    episode,                  /* column 4 of index */
    tags,
    type_of_media,            /* column 2 of index */
    people,
    characters,
    akas,
    series_in,
    date_watched,
    set_in_year,
    greatest_line,
    source_of_item,
    last_save_time,
    file_creation_date"

$columns = ($columns_csv.Replace("`r`n", ' ') -replace '\s+', ' ').Split(",")
$widestcolumnname = 0;
foreach($columnname in $columns) {if ($columnname.Length -gt $widestcolumnname) { $widestcolumnname = $columnname.Length}}

if ($DatabaseConnectionIsOpen -and $NewExcelCSVFileGenerated) {
    try {
        $sql = "COPY $targettable(" + [System.Environment]::NewLine
        foreach($columnname in $columns)
        {
            $sql+= " "*4 + $columnname.PadRight($widestcolumnname)  + $(If($columnname -eq $columns[-1]) {")"} else {","}) + [System.Environment]::NewLine;
        }

        $sql+= "FROM '$copytopath' CSV HEADER;" + [System.Environment]::NewLine;
        Invoke-Sql $sql -LogSqlToHost |Out-Null
    } catch {
        Show-Error $sql -exitcode 2
    }
}

}
catch {
    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}
finally {
    Write-AllPlaces "Finally" -ForceStartOnNewLine
    . .\_dot_include_standard_footer.ps1
}
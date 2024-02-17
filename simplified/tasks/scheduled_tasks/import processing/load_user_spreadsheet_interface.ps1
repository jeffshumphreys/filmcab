<#
 #    FilmCab Daily morning batch run process: Import user's spreadsheet of movies they've seen or want to see.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Complete
 #    ###### Tue Jan 23 18:23:11 MST 2024
 #    Reviewed and refactored: ###### Sat Feb 17 12:02:04 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #>

. .\_dot_include_standard_header.ps1
                                                                             
$targettable     = 'user_spreadsheet_interface'
$copyfrompath    = "D:\qt_projects\filmcab\simplified\_data\$targettable.ods" # Extension must be xls for ImportExcel to work even though I'm using ods Calc.
$copytodirectory = "D:\qt_projects\filmcab\simplified\_data" # Extension must be xls for ImportExcel to work even though I'm using ods Calc.
$copytopath      = "$copytodirectory\$targettable.csv" # Extension must be xls for ImportExcel to work even though I'm using ods Calc.

Stop-Process -Name 'excel' -Force -ErrorAction Ignore

soffice --headless --convert-to csv  $copyfrompath --outdir $copytodirectory
$NewExcelCSVFileGenerated = $true
                     
#TODO: Pull these from the spreadsheet?
$columns_csv = "
    seen, 
    have, 
    manually_corrected_title, 
    genres_csv_list, 
    ended_with_right_paren, 
    type_of_media, 
    source_of_item, 
    who_csv_list, 
    aka_slsh_list, 
    characters_csv_list, 
    video_wrapper, 
    series_in, 
    imdb_id, 
    imdb_added_to_list_on, 
    imdb_changed_on_list_on, 
    release_year, 
    imdb_rating, 
    runtime_in_minutes, 
    votes, 
    released_on, 
    directors_csv_list, 
    imdb_my_rating, 
    imdb_my_rating_made_on, 
    date_watched, 
    last_save_time, 
    creation_date"
    
$columns = ($columns_csv.Replace("`r`n", ' ') -replace '\s+', ' ').Split(",")
$widestcolumnname = 0;
foreach($columnname in $columns) {if ($columnname.Length -gt $widestcolumnname) { $widestcolumnname = $columnname.Length}}

if ($DatabaseConnectionIsOpen -and $NewExcelCSVFileGenerated) {
    $DatabaseCommand = $DatabaseConnection.CreateCommand();
    if (1 -eq 1) {                   
        try {
            Invoke-Sql "DROP TABLE IF EXISTS $targettable;" > $null
        } catch {
            Show-Error $sql -exitcode 0
        }

        try {
            $sql = "CREATE TABLE $targettable (LIKE public.template_for_docking_tables INCLUDING ALL," + [System.Environment]::NewLine;
            foreach($columnname in $columns)
            {
                $sql+= " "*4 + $columnname.PadRight($widestcolumnname) + " TEXT," + [System.Environment]::NewLine;
            }

            $sql+= " "*4 + "hash_of_all_columns text GENERATED ALWAYS AS(encode(sha256(("+ [System.Environment]::NewLine;
            foreach($columnname in $columns)
            {                                                                                                                                            
                $sep = if($columnname -eq $columns[-1]) {""} else {"||"}
                # Postgresql automatically converts the string 'null' to a NULL value.
                $sql+= " "*8 + "COALESCE(" + $columnname.PadRight($widestcolumnname) + " , 'NULL')" + $(if($columnname -eq $columns[-1]) {""} else {"||"}) + [System.Environment]::NewLine;
            }

            $sql+= " "*8 + ") ::bytea), 'hex')) STORED" + [System.Environment]::NewLine;
            $sql+= " "*8 + ", dictionary_sortable_title TEXT" + [System.Environment]::NewLine;
            $sql+= " "*8 + ", record_added_on  timestamptz default clock_timestamp()" + [System.Environment]::NewLine;
            $sql+= " "*8 + ", CONSTRAINT ak_hash_of_all_columns UNIQUE(hash_of_all_columns)" + [System.Environment]::NewLine;        # Enforce unique rows.
            $sql+= " "*8 + ", CONSTRAINT ak_title_release_year UNIQUE(manually_corrected_title)" + [System.Environment]::NewLine;
            $sql+= " "*4 + ");" + [System.Environment]::NewLine;

            Invoke-Sql $sql > $null
        } catch {
            Show-Error $sql -exitcode 1
        }
        
        try {
            $sql = "COPY $targettable("
            foreach($columnname in $columns)
            {
                $sql+= " "*4 + $columnname.PadRight($widestcolumnname)  + $(If($columnname -eq $columns[-1]) {")"} else {","}) + [System.Environment]::NewLine;
            }

            $sql+= "FROM '$copytopath' CSV HEADER;" + [System.Environment]::NewLine;
            Invoke-Sql $sql > $null
        } catch {
            Show-Error $sql -exitcode 2
        }
    }

    $sql = "SELECT manually_corrected_title FROM $targettable WHERE (seen NOT IN('y', 's', '?') or seen is null) and (have not in('n', 'x', 'd', 'na', 'c', 'h', 'y') or have is null)"; 

    $reader = WhileReadSql $sql
    $HowManyMoviesAreUnmarked = 0;

    while ($Reader.Read()) {
        Write-Host "$manually_corrected_title"                         
        # TODO: SEARCH database for a match first!!!!!!! Duh!
        $HowManyMoviesAreUnmarked++;
    }                               

    Write-Count HowManyMoviesAreUnmarked Movie
}

. .\_dot_include_standard_footer.ps1
<#
 #   FilmCab Daily morning batch run process: Pull in an excel file we know to have our movie list in it.
 #   Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #   Status: Scheduled with bugs
 #   Admin mode: Not required
 #   ###### Wed Jan 24 16:21:20 MST 2024
 #   https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #
 #   ###### Tue Jan 16 19:10:55 MST 2024 - Moved to Yet Another Subfolder. Updated actual task. Exported.
 #
 #   Stuff it into receiving one-to-one table, no cleanup
 #   Validate the data as counts.
 #   If any non-zero counts, look deeper, and fix IN EXCEL
 #   run filmcab to detect new torrent downloads, new published files, and new backup entries.
 #   check which published videos are in our excel list; update table and excel (?)
 #   check folders in backups that are not in published. Delete.
 #   check hashes from published to torrent downloads. What's missing?
 #
 #   ###### Sat Jan 20 18:59:12 MST 2024
 #   We are no longer using transactions. They lock and block everything if debugging is going on.
 #
 #   ###### Fri Jan 26 15:37:19 MST 2024
 #   Uh, looks like the excel.dll now has an immovable popup when called from Task Scheduler, though it will run manually.
 #   Turns out Import-Module ImportExcel works easier. and is UTF8 (OpenXML). https://github.com/dfinke/ImportExcel
 #
 #   ###### Sat Jan 27 13:55:17 MST 2024
 #   Not sure what's causing the locking so,
 #    - Get rid of the empty VB macro.
 #    - Go back to saving locally.  I don't reference the thing from my phone anymore. I use Keep.   
 #    - Use the "copy a locked file" trick
#>

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()

. D:\qt_projects\filmcab\simplified\_dot_include_standard_header.ps1
                                                                             
$copyfrompath = "D:\qt_projects\filmcab\simplified\_data\user_excel_interface.xlsx"
$copytopath                                                                        = "D:\qt_projects\filmcab\simplified\_data\user_excel_interface.readablecopy.xlsx" # TODO: convert to temp
$inpath = $copytopath
$outpath = "D:\qt_projects\filmcab\simplified\_data\user_excel_interface.UTF8.csv"
$targettable = 'user_excel_interface'
                                                                                                                                                           
Remove-Item -Path $copytopath -Force -ErrorAction Ignore
Copy-Item -Path $copyfrompath -Destination $copytopath -Force

$NewExcelCSVFileGenerated = $false
$spreadsheet = Import-Excel $inpath

$spreadsheet | Export-Csv $outpath

$NewExcelCSVFileGenerated = $true 

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
    
$columns = (($columns_csv.Replace("`r`n", ' ')) -replace '\s+', ' ').Split(", ")
$widestcolumnname = 0;
foreach($columnname in $columns) {if ($columnname.Length -gt $widestcolumnname) { $widestcolumnname = $columnname.Length}}

# TODO: load last timestamp from target table and compare to current excel file timestamp. Only reload if changed.

<#
    Issues:
    - Locked files
    - Blocking after creating and trying to replace
    https://learn.microsoft.com/en-us/dotnet/api/system.data.odbc.odbcconnection?view=dotnet-plat-ext-7.0
#>

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
                # Postgresql automatically converts the string 'null' to a NULL value.
                $sql+= " "*8 + "COALESCE(" + $columnname.PadRight($widestcolumnname) + " , 'NULL')" + ($columnname -eq $columns[-1] ? "" : "||") + [System.Environment]::NewLine;
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
                $sql+= " "*4 + $columnname.PadRight($widestcolumnname)  + ($columnname -eq $columns[-1] ? ")" : ",") + [System.Environment]::NewLine;
            }

            $sql+= "FROM '$outpath' CSV HEADER;" + [System.Environment]::NewLine;
            Invoke-Sql $sql > $null
        } catch {
            Show-Error $sql -exitcode 2
        }
    }

    $DatabaseCommand.CommandText = "SELECT manually_corrected_title FROM user_excel_interface where (seen not in('y', 's', '?') or seen is null) and (have not in('n', 'x', 'd', 'na', 'c', 'h', 'y') or have is null)"; 

    $Reader = $DatabaseCommand.ExecuteReader();
    $matchcount = 0;

    while ($Reader.Read()) {
        $title = $Reader["manually_corrected_title"]
        Write-Host "$title"                         
        # TODO: SEARCH database for a match first!!!!!!! Duh!
        $matchcount++;
    }
    $Reader.Close() 
    $matchcount

    $DatabaseCommand.CommandText = "SELECT COUNT(*) FROM $targettable"; $howManyRows = $DatabaseCommand.ExecuteScalar(); Write-Output "How many rows: $howManyRows"
    $DatabaseCommand.CommandText = "SELECT COUNT(*) FROM $targettable where right(manually_corrected_title, 1) <> ')' and type_of_media <> 'Movie about…'"; $howManyBadParens = $DatabaseCommand.ExecuteScalar(); Write-Output "How many titles not end in right parens: $howManyBadParens"
    $DatabaseCommand.CommandText = "SELECT COUNT(*) FROM $targettable where manually_corrected_title like '%  %'"; $howManyMultiSpacedTitles = $DatabaseCommand.ExecuteScalar(); Write-Output "How many titles have multiple spaces: $howManyMultiSpacedTitles"
    $DatabaseCommand.CommandText = "SELECT COUNT(*) FROM $targettable where regexp_match(manually_corrected_title, '\((\d\d\d\d)\)') is null and type_of_media <> 'Movie about…' and not regexp_like(manually_corrected_title, '\(pending\)')"; $howManyTitlesMisformedYears = $DatabaseCommand.ExecuteScalar(); Write-Output "How many titles have malformed years: $howManyTitlesMisformedYears"
    $DatabaseCommand.CommandText = "SELECT COUNT(*) FROM $targettable where trim(manually_corrected_title) <> manually_corrected_title"; $howManyTitlesAreUntrim = $DatabaseCommand.ExecuteScalar(); Write-Output "How many titles trailing or leading spaces: $howManyTitlesAreUntrim";
    $DatabaseCommand.CommandText = "SELECT COUNT(*) FROM $targettable where regexp_match(manually_corrected_title, '\((\d\d\d\d)\)') is not null and (regexp_match(manually_corrected_title, '\((\d\d\d\d)\)')::numeric[])[1] not between 1900 and 2026 and type_of_media <> 'Movie about…' and not regexp_like(manually_corrected_title, '\(pending\)')"; $howManyTitleYearsOutOfReasonableAge = $DatabaseCommand.ExecuteScalar(); Write-Output "How many titles have unreal years: $howManyTitleYearsOutOfReasonableAge"
    
    $DatabaseConnection.Close();
    $DatabaseConnection.Dispose();
}

. D:\qt_projects\filmcab\simplified\_dot_include_standard_footer.ps1
<#
 #   FilmCab Daily morning batch run process: Pull in an excel file we know to have our movie list in it.
 #   Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #   Status: Haven't scheduled, need to test a little more
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
#>

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()

. D:\qt_projects\filmcab\simplified\_dot_include_standard_header.ps1

#$inpath = "D:\OneDrive\Documents\user_excel_interface.xlsm"
$inpath = "https://d.docs.live.net/89bc08e19187b035/Documents/user_excel_interface.xlsm" # Trying to get live file.
$outpath = "D:\qt_projects\filmcab\simplified\_data\user_excel_interface.UTF8.csv"
$targettable = 'user_excel_interface'

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

$NewExcelCSVFileGenerated = $false

if (1 -eq 1) {
    # Install-module PSExcel
    <#
                Fastest way to convert an Excel (xlsx) document to a utf8 csv that I know.
                I get stuck on doing it in Qt and C++, but this is fast.
                Warning: this is dependent on Windows Excel being installed. So not cross-compatible.
    #>
    Import-Module PSExcel
    $AssemblyFile = (Get-ChildItem $env:windir\assembly -Recurse Microsoft.Office.Interop.Excel.dll | Select-Object -first 1).FullName
    Add-Type -Path $AssemblyFile
    $MicrosoftOfficeInteropExcelXlFileFormatxlCSVUTF8 = 62
    $Excel= New-Object -ComObject Excel.Application
    $Excel.Visible  = $false
    $Excel.DisplayAlerts = $false
    
    # Following returns "Excel cannot open the file 'user_excel_interface.xlsm' because the file format or file extension is not valid. Verify that the file has not been corrupted and that the file extension matches the format of the file." if file is open.
    
    try {
        $wb = $Excel.Workbooks.Open($inpath)
        $ws = $wb.Worksheets[1]
        $ws.SaveAs($outpath, $MicrosoftOfficeInteropExcelXlFileFormatxlCSVUTF8)
        $wb.Close($true)
        $NewExcelCSVFileGenerated = $true
    }
    finally {
        $Excel.Quit()
    }
}

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
                $sql+= " "*8 + "COALESCE(" + $columnname.PadRight($widestcolumnname) + " , 'null')" + ($columnname -eq $columns[-1] ? "" : "||") + [System.Environment]::NewLine;
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

    # List out some that I haven't seen, don't have, haven't reviewed yet. Ignore any we might have watched, should want to see (heehee), will never see based on it's topic, that are not available yet, or are just getting for completeness, and aren't downloading right now.
    # These are ones that make me go hmmmmm. Need reviewing, classifying, downloading.
        
    # $DatabaseCommand.CommandText = "SELECT * FROM $targettable where right(manually_corrected_title, 1) <> ')' and type_of_media <> 'Movie about…'"; $howManyBadParens = $DatabaseCommand.ExecuteScalar(); Write-Output "How many titles not end in right parens: $howManyBadParens"
    # $DatabaseCommand.CommandText = "SELECT * FROM $targettable where manually_corrected_title like '%  %'"; $howManyMultiSpacedTitles = $DatabaseCommand.ExecuteScalar(); Write-Output "How many titles have multiple spaces: $howManyMultiSpacedTitles"
    # $DatabaseCommand.CommandText = "SELECT * FROM $targettable where regexp_match(manually_corrected_title, '\((\d\d\d\d)\)') is null and type_of_media <> 'Movie about…' and not regexp_like(manually_corrected_title, '\(pending\)')"; $howManyTitlesMisformedYears = $DatabaseCommand.ExecuteScalar(); Write-Output "How many titles have malformed years: $howManyTitlesMisformedYears"
    # $DatabaseCommand.CommandText = "SELECT * FROM $targettable where trim(manually_corrected_title) <> manually_corrected_title"; $howManyTitlesAreUntrim = $DatabaseCommand.ExecuteScalar(); Write-Output "How many titles trailing or leading spaces: $howManyTitlesAreUntrim";
    # $DatabaseCommand.CommandText = "SELECT * FROM $targettable where regexp_match(manually_corrected_title, '\((\d\d\d\d)\)') is not null and (regexp_match(manually_corrected_title, '\((\d\d\d\d)\)')::numeric[])[1] not between 1900 and 2026 and type_of_media <> 'Movie about…' and not regexp_like(manually_corrected_title, '\(pending\)')"; $howManyTitleYearsOutOfReasonableAge = $DatabaseCommand.ExecuteScalar(); Write-Output "How many titles have unreal years: $howManyTitleYearsOutOfReasonableAge"

    $DatabaseConnection.Close();
    $DatabaseConnection.Dispose();
}

. D:\qt_projects\filmcab\simplified\_dot_include_standard_footer.ps1
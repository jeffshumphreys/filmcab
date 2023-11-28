<#
    Pull in an excel file we know to have our movie list in it
    Stuff it into receiving one-to-one table, no cleanup
    Validate the data as counts.
    If any non-zero counts, look deeper, and fix IN EXCEL
    run filmcab to detect new torrent downloads, new published files, and new backup entries.
    check which published videos are in our excel list; update table and excel (?)
    check folders in backups that are not in published. Delete.
    check hashes from published to torrent downloads. What's missing?
#>
$inpath = "D:\qt_projects\filmcab\all_my_keep_and_imdb_lists.xlsm"
$outpath = "D:\qt_projects\filmcab\all_my_keep_and_imdb_lists.UTF8.csv"
$MyServer = "localhost"
$MyPort  = "5432"
$MyDB = "filmcab"
$MyUid = "postgres"
$MyPass = "postgres"

$columns_csv = "seen, have, manually_corrected_title, genres_csv_list, ended_with_right_paren, type_of_media, source_of_item, who_csv_list, aka_slsh_list, characters_csv_list, video_wrapper, series_in, imdb_id, imdb_added_to_list_on, imdb_changed_on_list_on, release_year, imdb_rating, runtime_in_minutes, votes, released_on, directors_csv_list, imdb_my_rating, imdb_my_rating_made_on, date_watched, last_save_time, creation_date"
$columns = $columns_csv.Split(", ")
$widestcolumnname = 0;
foreach($columnname in $columns) {if ($columnname.Length -gt $widestcolumnname) { $widestcolumnname = $columnname.Length}}

if (1 -eq 0) {
    # Install-module PSExcel
    <#
                Fastest way to convert an Excel (xlsx) document to a utf8 csv that I know.
                I get stuck on doing it in Qt and C++, but this is fast.
                Warning: this is dependent on Windows Excel being installed. So not cross-compilable for now.
    #>
    import-module psexcel
    $AssemblyFile = (get-childitem $env:windir\assembly -Recurse Microsoft.Office.Interop.Excel.dll | Select-Object -first 1).FullName
    Add-Type -Path $AssemblyFile
    $MicrosoftOfficeInteropExcelXlFileFormatxlCSVUTF8 = 62
    $Excel = New-Object -ComObject Excel.Application
    $Excel.Visible = $false
    $Excel.DisplayAlerts = $false
    $wb = $Excel.Workbooks.Open($inpath)
    $ws = $wb.Worksheets[1]
    $ws.SaveAs($outpath, $MicrosoftOfficeInteropExcelXlFileFormatxlCSVUTF8)
    $wb.Close($true)
    $Excel.Quit()
}

# https://www.postgresql.org/ftp/odbc/versions/msi/ 
# https://ftp.postgresql.org/pub/odbc/versions/msi/psqlodbc_15_00_0000-x64.zip
# psqlodbc_x64.msi


$DBConnectionString = "Driver={PostgreSQL UNICODE(x64)};Server=$MyServer;Port=$MyPort;Database=$MyDB;Uid=$MyUid;Pwd=$MyPass;"
$DBConn = New-Object System.Data.Odbc.OdbcConnection;
$DBConn.ConnectionString = $DBConnectionString;
$dbconnopen = $false
try {
    $DBConn.Open();
    $dbconnopen = $true;
} catch {
    Write-Error "Message: $($_.Exception.Message)"
    Write-Error "StackTrace: $($_.Exception.StackTrace)"
    Write-Error "LoaderExceptions: $($_.Exception.LoaderExceptions)"
    $dbconnopen = $false;
}

# Check date of input. Changed from what's in database?


<#
    Issues:
    - Locked files
    - Blocking after creating and trying to replace
    https://learn.microsoft.com/en-us/dotnet/api/system.data.odbc.odbcconnection?view=dotnet-plat-ext-7.0
#>

if ($dbconnopen) {
    $DBCmd = $DBConn.CreateCommand();
    if (1 -eq 0) {
        $transaction = $DBConn.BeginTransaction();
        $DBCmd.Transaction = $transaction;
        try {
            $DBCmd.CommandText = "DROP TABLE IF EXISTS receiving_dock.all_my_keep_and_imdb_lists;";
            $i = $DBCmd.ExecuteNonQuery();
        } catch {
            $transaction.Rollback();
            Write-Error "Message: $($_.Exception.Message)"; Write-Error "StackTrace: $($_.Exception.StackTrace)"; Write-Error "LoaderExceptions: $($_.Exception.LoaderExceptions)";
            $transaction.Dispose();
            exit(0);
        }

        try {
            $sqlcmd = "CREATE TABLE receiving_dock.all_my_keep_and_imdb_lists (LIKE public.template_for_docking_tables INCLUDING ALL," + [System.Environment]::NewLine;
            foreach($columnname in $columns)
            {
                $sqlcmd+= " "*4 + $columnname.PadRight($widestcolumnname) + " TEXT," + [System.Environment]::NewLine;
            }

            $sqlcmd+= " "*4 + "hash_of_all_columns text GENERATED ALWAYS AS(encode(sha256(("+ [System.Environment]::NewLine;
            foreach($columnname in $columns)
            {
                # Postgresql automatically converts the string 'null' to a NULL value.
                $sqlcmd+= " "*8 + "COALESCE(" + $columnname.PadRight($widestcolumnname) + " , 'null')" + ($columnname -eq $columns[-1] ? "" : "||") + [System.Environment]::NewLine;
            }

            $sqlcmd+= " "*8 + ") ::bytea), 'hex')) STORED" + [System.Environment]::NewLine;
            $sqlcmd+= " "*8 + ", dictionary_sortable_title TEXT" + [System.Environment]::NewLine;
            $sqlcmd+= " "*8 + ", record_added_on  timestamptz default clock_timestamp()" + [System.Environment]::NewLine;
            $sqlcmd+= " "*8 + ", CONSTRAINT ak_hash_of_all_columns UNIQUE(hash_of_all_columns)" + [System.Environment]::NewLine;        # Enforce unique rows.
            $sqlcmd+= " "*8 + ", CONSTRAINT ak_title_release_year UNIQUE(manually_corrected_title)" + [System.Environment]::NewLine;
            $sqlcmd+= " "*4 + ");" + [System.Environment]::NewLine;

            $DBCmd.CommandText = $sqlcmd;
            $i = $DBCmd.ExecuteNonQuery();
        } catch {
            $transaction.Rollback();
            Write-Error "Message: $($_.Exception.Message)"; Write-Error "StackTrace: $($_.Exception.StackTrace)"; Write-Error "LoaderExceptions: $($_.Exception.LoaderExceptions)";
            $transaction.Dispose();
            exit(0);
        }

        try {
            $sqlcmd = "COPY receiving_dock.all_my_keep_and_imdb_lists("
            foreach($columnname in $columns)
            {
                $sqlcmd+= " "*4 + $columnname.PadRight($widestcolumnname)  + ($columnname -eq $columns[-1] ? ")" : ",") + [System.Environment]::NewLine;
            }

            $sqlcmd+= "FROM 'D:\qt_projects\filmcab\all_my_keep_and_imdb_lists.UTF8.csv' CSV HEADER;" + [System.Environment]::NewLine;
            $DBCmd.CommandText = $sqlcmd;
            $i = $DBCmd.ExecuteNonQuery();
        } catch {
            $transaction.Rollback();
            Write-Error "Message: $($_.Exception.Message)"; Write-Error "StackTrace: $($_.Exception.StackTrace)"; Write-Error "LoaderExceptions: $($_.Exception.LoaderExceptions)";
            $transaction.Dispose();
            exit(0);
        }
        $DBCmd.Transaction = $null;
        $transaction.Commit();
        $transaction.Dispose();
    }
    $DBCmd.CommandText = "SELECT COUNT(*) FROM receiving_dock.all_my_keep_and_imdb_lists"; $howManyRows = $DBCmd.ExecuteScalar(); Write-Output "How many rows: $howManyRows"
    $DBCmd.CommandText = "SELECT COUNT(*) FROM receiving_dock.all_my_keep_and_imdb_lists where right(manually_corrected_title, 1) <> ')' and type_of_media <> 'Movie about…'"; $howManyBadParens = $DBCmd.ExecuteScalar(); Write-Output "How many titles not end in right parens: $howManyBadParens"
    $DBCmd.CommandText = "SELECT COUNT(*) FROM receiving_dock.all_my_keep_and_imdb_lists where manually_corrected_title like '%  %'"; $howManyMultiSpacedTitles = $DBCmd.ExecuteScalar(); Write-Output "How many titles have multiple spaces: $howManyMultiSpacedTitles"
    $DBCmd.CommandText = "SELECT COUNT(*) FROM receiving_dock.all_my_keep_and_imdb_lists where regexp_match(manually_corrected_title, '\((\d\d\d\d)\)') is null and type_of_media <> 'Movie about…' and not regexp_like(manually_corrected_title, '\(pending\)')"; $howManyTitlesMisformedYears = $DBCmd.ExecuteScalar(); Write-Output "How many titles have malformed years: $howManyTitlesMisformedYears"
    $DBCmd.CommandText = "SELECT COUNT(*) FROM receiving_dock.all_my_keep_and_imdb_lists where trim(manually_corrected_title) <> manually_corrected_title"; $howManyTitlesAreUntrim = $DBCmd.ExecuteScalar(); Write-Output "How many titles trailing or leading spaces: $howManyTitlesAreUntrim";
    $DBCmd.CommandText = "SELECT COUNT(*) FROM receiving_dock.all_my_keep_and_imdb_lists where regexp_match(manually_corrected_title, '\((\d\d\d\d)\)') is not null and (regexp_match(manually_corrected_title, '\((\d\d\d\d)\)')::numeric[])[1] not between 1900 and 2026 and type_of_media <> 'Movie about…' and not regexp_like(manually_corrected_title, '\(pending\)')"; $howManyTitleYearsOutOfReasonableAge = $DBCmd.ExecuteScalar(); Write-Output "How many titles have unreal years: $howManyTitleYearsOutOfReasonableAge"

    # List out some that I haven't seen, don't have, haven't reviewed yet. Ignore any we might have watched, should want to see (heehee), will never see based on it's topic, that are not available yet, or are just getting for completeness, and aren't downloading right now.
    # These are ones that make me go hmmmmm. Need reviewing, classifying, downloading.

    $DBCmd.CommandText = "SELECT manually_corrected_title FROM receiving_dock.all_my_keep_and_imdb_lists where (seen not in('y', 's', '?') or seen is null) and (have not in('n', 'x', 'd', 'na', 'c', 'h', 'y') or have is null)"; 

    $Reader = $DBCmd.ExecuteReader();
    $matchcount = 0;

    while ($Reader.Read()) {
        $title = $Reader["manually_corrected_title"]
        Write-Host "$title"
        $matchcount++;
    }
    $Reader.Close() 
    $matchcount

    # Scan all our downloaded movies again
    
    # D:\qt_projects\build-filmcab-Desktop_Qt_6_5_3_MinGW_64_bit-Release\filmcab.exe
    <#
    ---------------------------
    filmcab.exe - System Error
    ---------------------------
    The code execution cannot proceed because Qt6Sql.dll was not found. Reinstalling the program may fix this problem. 
    ---------------------------
    OK   
    ---------------------------
    #>
    # Added D:\Qt\6.5.3\mingw_64\bin to path for dlls.  Don't want to do a full deployment. https://wiki.qt.io/CQtDeployer
    <#
    ---------------------------
    filmcab.exe - Entry Point Not Found
    ---------------------------
    The procedure entry point _Z11qt_assert_xPKcS0_S0_i could not be located in the dynamic link library D:\qt_projects\build-filmcab-Desktop_Qt_6_5_3_MinGW_64_bit-Debug\debug\filmcab.exe. 
    ---------------------------
    OK   
    ---------------------------
    #>
    # http://www.dependencywalker.com/
    # C:\Program Files (x86)\dotnet\shared\Microsoft.NETCore.App\3.1.32 has api-ms-win-core-synch-l1-2-0.dll in it.  Now dependency walker doesn't finish spinning.

    <#
    ---------------------------
    filmcab.exe - Entry Point Not Found
    ---------------------------
    The procedure entry point _ZNSt3pmr20get_default_resourceEv could not be located in the dynamic link library D:\Qt\6.5.3\mingw_64\bin\Qt6Core.dll. 
    ---------------------------
    OK   
    ---------------------------
    #>
    <#
    DISM.exe /Online /Cleanup-image /Scanhealth 
    DISM.exe /Online /Cleanup-image /Restorehealth 
    DISM.exe /online /cleanup-image /startcomponentcleanup 
    sfc /scannow


    #>
    $DBConn.Close();
    
}
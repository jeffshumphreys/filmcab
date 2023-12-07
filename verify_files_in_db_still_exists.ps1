$MyServer = "localhost";$MyPort  = "5432";$MyDB = "filmcab";$MyUid = "postgres";$MyPass = "postgres"
$DBConn = New-Object System.Data.Odbc.OdbcConnection;
$DBConn.ConnectionString = "Driver={PostgreSQL UNICODE(x64)};Server=$MyServer;Port=$MyPort;Database=$MyDB;Uid=$MyUid;Pwd=$MyPass;";
$dbconnopen = $false
try {
    $DBConn.Open();
    $dbconnopen = $true;
} catch {
    Write-Error "Message: $($_.Exception.Message)"
    Write-Error "StackTrace: $($_.Exception.StackTrace)"
    Write-Error "LoaderExceptions: $($_.Exception.LoaderExceptions)"
    $dbconnopen = $false;
    exit(2);
}

$DBCmd = $DBConn.CreateCommand();

function Invoke-Sql ($sql) {
    $DBCmd.CommandText = $sql
    try {
        $rtn = $DBCmd.ExecuteNonQuery();
    } catch {
        Write-Error $sql
        Write-Error "Message: $($_.Exception.Message)"
        Write-Error "StackTrace: $($_.Exception.StackTrace)"
        Write-Error "LoaderExceptions: $($_.Exception.LoaderExceptions)"
        exit(1);
    }
}

#$rtnrows = New-Object System.Data.Odbc.OdbcDataReader

function Query-Sql ($sql) {
    $DBCmd.CommandText = $sql
    try {
         $rtnrows = $DBCmd.ExecuteReader();
    } catch {
        Write-Error $sql
        Write-Error "Message: $($_.Exception.Message)"
        Write-Error "StackTrace: $($_.Exception.StackTrace)"
        Write-Error "LoaderExceptions: $($_.Exception.LoaderExceptions)"
        exit(1);
    }
}

$listoffilesmissing = @()
$listoffilesfound = @()
if ($dbconnopen) {
    $DBCmd.CommandText = "SELECT f.txt path FROM stage_for_master.files f WHERE (f.record_deleted IS NULL OR f.record_deleted is false)
        and (f.file_lost IS NULL OR f.file_lost is false)
        and (f.file_deleted is null or f.file_deleted is false);";
    $rtnrows = $DBCmd.ExecuteReader();
    while ($rtnrows.Read()) {
        $lastknownpath = $rtnrows.GetValue(0)
        if ([System.IO.File]::Exists($lastknownpath)) {
            $listoffilesfound+= $lastknownpath
            Write-Host -NoNewline '.'
            #            Write-Host -ForegroundColor Green $lastknownpath
        } else {
            $listoffilesmissing+= $lastknownpath
            Write-Host -NoNewline '.'
            #            Write-Host -ForegroundColor Red $lastknownpath
        }
    }
    $rtnrows.Close()
    
    foreach ($missingfile in $listoffilesmissing)
    {
        $escapedfile = $missingfile.Replace("'", "''")
        Invoke-sql "UPDATE stage_for_master.files SET file_lost = true, file_loss_detected_on_ts_wth_tz = clock_timestamp() WHERE txt = '$escapedfile'"
        Write-Host -NoNewline '.'
    }
    foreach ($missingfile in $listoffilesmissing)
    {
        $escapedfile = $missingfile.Replace("'", "''")
        Invoke-sql "UPDATE stage_for_master.files SET last_verified_full_path_present_on_ts_wth_tz = clock_timestamp() WHERE txt = '$escapedfile'"
        Write-Host -NoNewline '.' 
    }
}


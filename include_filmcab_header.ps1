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

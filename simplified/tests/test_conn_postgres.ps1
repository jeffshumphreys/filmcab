$MyServer = "localhost"
$MyPort  = "5432"
$MyDB = "filmcab"
$MyUid = "postgres"
$MyPass = "postgres"
# https://www.postgresql.org/ftp/odbc/versions/msi/ 
# https://ftp.postgresql.org/pub/odbc/versions/msi/psqlodbc_15_00_0000-x64.zip

$DBConnectionString = "Driver={PostgreSQL UNICODE(x64)};Server=$MyServer;Port=$MyPort;Database=$MyDB;Uid=$MyUid;Pwd=$MyPass;"
$DBConn = New-Object System.Data.Odbc.OdbcConnection;
$DBConn.ConnectionString = $DBConnectionString;
$DBConn.Open();
#if ($DBConn.State == ) {
    $DBCmd = $DBConn.CreateCommand();
    $DBCmd.CommandText = "SELECT * FROM receiving_dock.all_my_keep_and_imdb_lists;";
    $Reader = $DBCmd.ExecuteReader();
    while ($Reader.Read()) {
        Write-Host $Reader["manually_corrected_title"] 
    }
    $Reader.Close();
    $DBConn.Close();
#}
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$MyServer = "localhost";$MyPort  = "5432";$MyDB = "filmcab";$MyUid = "postgres";$MyPass = "postgres"
$DBConn = New-Object System.Data.Odbc.OdbcConnection;
$connString = "Driver={PostgreSQL UNICODE(x64)};Server=$MyServer;Port=$MyPort;Database=$MyDB;Uid=$MyUid;Pwd=$MyPass;";
$DBConn.ConnectionString = $connString
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

function Get-SqlFieldValue {
    param ([System.Data.Common.DbDataReader]$reader, $ordinal)
    [object]$ob = $null

    if ($ordinal -is [Int32]) {
        $ob = $reader.GetValue($ordinal)
    } else {
        $i = $reader.GetSchemaTable() | Select-Object ColumnName, ColumnOrdinal|Where-Object ColumnName -eq $ordinal|Select-Object ColumnOrdinal
        $i = $i.ColumnOrdinal
        if ($i -ne -1) {
            $ob = $reader.GetValue($i)
        } else {
            # Throw error.
        }
    }
    if ($ob -is [System.DBNull]) {
        return $null
    }
    return $ob
}


$TestSql = 'SELECT 1 as TheNumberOne;' # Passed ###### Mon Feb 12 17:59:35 MST 2024
$TestSql = $null  # Test empty. # CommandText property has not been initialized.  -2146233079 ###### Mon Feb 12 18:17:01 MST 2024 [InvalidOperationException]=>ErrorRecord
$TestSql = 'SELECT 1 das TheNumberOne;' # [System.Data.Odbc.OdbcException]
Function main() {
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

    try {
        $DBConn.Open();
        $DBCmd = $DBConn.CreateCommand();
        $DBCmd.CommandText = $TestSql;
        $Reader = $DBCmd.ExecuteReader();
        while ($Reader.Read()) {
            Write-AllPlaces $Reader["TheNumberOne"] 
        }
        $Reader.Close();
        $DBConn.Close();
        Write-AllPlaces "Exit Fine"
        exit 0 # Bubbles up to (0x0)
    }
    catch [System.Data.Odbc.OdbcException] {
        # NOTE: No ErrorDetails property
        Write-AllPlaces "Exit Error"
        @($_.ScriptStackTrace.Split("`n"))[0]
        # Exactly where the error occurred: at main, D:\qt_projects\filmcab\simplified\tests\test_return_error_code_on_sql_error.ps1: line 21
        # Where called in file: at <ScriptBlock>, D:\qt_projects\filmcab\simplified\tests\test_return_error_code_on_sql_error.ps1: line 50  This is inside the VS Editor, debugger.
        # at <ScriptBlock>, <No file>: line 1

        $callStack = Get-PSCallStack -Verbose
        foreach ($line in $callStack) {
            # $line is [CallStackFrame]
            # ScriptLineNo
            # Position
            # GetScriptLocation
            # GetFrameVariables
            # FunctionName
            # Location
            # Command
            # Arguments
            # ScriptName
            # InvocationInfo
            #     PositionMessage, InvocationName, Pipeline, ExpectingInput, CommandOrigin, PSCommandPath
            Write-AllPlaces $line
        }
        #exit 1      # Bubbles up to (0x1), Action return code 2147942401    "{0:X}" -f 2147942401     2147942401 -band 65535 -> 1
        #exit 2      # Bubbles up to (0x2), Action return code 2147942402
        #exit 3      # Bubbles up to (0x3), Action return code 2147942403
        #exit -1     # Bubbles up to (0xFFFFFFFF), Action return code 4294967295
        #exit -2     # Bubbles up to (0xFFFFFFFE), Action return code 4294967294                       4294967294 -band (2)
        exit -256   # Bubbles up to (0xFFFFFF00)
        exit -65536  # Bubbles up to (0xFFFF0000), Action returns code 4294967040  "{0:X}" -f 4294967040 = "FFFFFF00"
        #$hex = "0x"+"{0:x}" -f  $task.LastTaskResult
        $code = [Int32]1
        $returncode = 2147942401
        $realcodeexited = 0
        if ($returncode -ge 65536) {
            $transform = [bigint]::Pow(2,16)-1
            $realcodeexited = $realcodeexited -band $transform
        }
                                                              
        Write-AllPlaces "Action return code $returncode is really $realcodeexited"

        # ([Int32]"0x80131501") ==> -2146233087 CORRECT! What HResult was.
        # EventData\Data\ResultCode=2148734209 "{0:X}" -f 2148734209 ==> 80131501 CORRECT. Do not use Format-Hex.
    
    }
    catch [InvalidOperationException] {
        # Cannot convert the "ExecuteReader: CommandText property has not been initialized" value of type "System.Management.Automation.ErrorRecord" to type "System.InvalidOperationException".
        [System.Management.Automation.ErrorRecord]$invop = $_
        $message = $invop.Message
        # ExecuteReader: CommandText property has not been initialized
        # CommandText property has not been initialized
        $HResult = $invop.Exception.HResult # -2146233079
        
        Write-AllPlaces
    }
    catch {
        Write-AllPlaces $_.Exception
    }
}

Write-AllPlaces "Starting Main"
main
Write-AllPlaces "Post Main"

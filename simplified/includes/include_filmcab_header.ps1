$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$scriptTimer = [Diagnostics.Stopwatch]::StartNew()   # Host to use: $scriptTimer.Elapsed.TotalSeconds                  

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

function Start-Log {
    $indent = 0

    $p = Get-CimInstance -Class Win32_Process -Filter "ProcessId = $PID"
    While ($true) {
        $processid = $p.ProcessId
        $processname = $p.name
        $pprocessid = $p.ParentProcessId
        Write-Host (' ' * $indent) "Process Id = $ProcessId, '$processname'"
        $indent+= 4
        $p = Get-CimInstance -Class Win32_Process -Filter "ProcessId = $pprocessid"
    }
    <#
        CommandLine                : "C:\Program Files\PowerShell\7\pwsh.exe" -NoProfile -ExecutionPolicy Bypass -Command "Import-Module 'c:\Users\jeffs\.vscode\extensions\ms-vscode.powershell-2023.8.0\modules\PowerShellEditorServices\PowerShellEditorServices.psd1'; 
                                    Start-EditorServices -HostName 'Visual Studio Code Host' -HostProfileId 'Microsoft.VSCode' -HostVersion '2023.8.0' -AdditionalModules @('PowerShellEditorServices.VSCode') -BundledModulesPath
                                    'c:\Users\jeffs\.vscode\extensions\ms-vscode.powershell-2023.8.0\modules' -EnableConsoleRepl -StartupBanner \"PowerShell Extension v2023.8.0
                                    Copyright (c) Microsoft Corporation.

                                    https://aka.ms/vscode-powershell
                                    Type 'help' to get help.
                                    \" -LogLevel 'Normal' -LogPath 'c:\Users\jeffs\AppData\Roaming\Code\User\globalStorage\ms-vscode.powershell\logs\1703703190-6a342b20-9f18-4146-9c66-4be137369db21703703189042\EditorServices.log' -SessionDetailsPath
                                    'c:\Users\jeffs\AppData\Roaming\Code\User\globalStorage\ms-vscode.powershell\sessions\PSES-VSCode-30100-896957.json' -FeatureFlags @() "
        ExecutablePath             : C:\Program Files\PowerShell\7\pwsh.exe
        ProcessId                  : 27276
        ParentProcessId            : 26752 (Code.exe)
        Grand-ParentProcessId      : 30100 (Code.exe)

    #>  
}
Function Convert-SidToUser {
    param($sidString)
    try {
        $sid = new-object System.Security.Principal.SecurityIdentifier($sidString)
        $user = $sid.Translate([System.Security.Principal.NTAccount])
        $user.value
    } catch {
        return $sidString
    }
}

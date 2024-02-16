<#
    Put in profile? No, I want it to be part of the codebase. Else any idiot using this code will be in the lurch.
    Rename to "standard_include_header"? But leave it as a cut&paste copy into app folders? Makes git easier. Or we make a module. Hmmmmmmm.

    Framework Notes: 
        ###### Fri Jan 19 12:50:09 MST 2024
        PS Core 7.4.1 (C:\Program Files\PowerShell\7\pwsh.exe)
        PowerShell for Visual Studio Code: v2024.1.0 Pre-Release
        Install-Module -Name PowerShellGet -Repository PSGallery -Scope CurrentUser -Force -AllowClobber.
        Install-Module -Name 'PSRule' -Repository PSGallery -Scope CurrentUser           # https://microsoft.github.io/PSRule/stable/install-instructions/

        Will try to remember if I'm using any other modules. Obviously I'm using win32. Sowwy. ☹
#>                                                                                                

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')] # We don't need no stinkin' badges
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')] # Why?
param()

# Following code seems to close the popup console window almost immediately if you're calling from Windows Task Scheduler. At least very fast.  I like things that run in the background to run in the background.

    Add-Type -name user32 -namespace win32 -memberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
    $consoleHandle = (get-process -id $pid).mainWindowHandle
    [void][win32.user32]::showWindow($consoleHandle, 0)

    Import-Module PowerShellHumanizer

############## Environment things FORCED on the user of this dot file.

    # Flush all variables because new code above their definitions will RUN fine until to restart anything.

    # WARNING: Error on line Start-Transcript -Path "D:\qt_projects\filmcab\simplified\_log\$ScriptName.transcript.log" -IncludeInvocationHeader
    ## You cannot call a method on a null-valued expression.
    ###  $Result += $Global:__VSCodeOriginalPrompt.Invoke()
    #### SOOOOOOOOOOOOOOO, I just need to shut down powershell EVERY FUCKING TIME I RUN?????????????
    #  CANNOT DO: Get-Variable -Exclude PWD,*Preference | Remove-Variable -EA 0
    
    # Stop on an error, please.  Lazy shits at City of Boise prefer scripts that NEVER error in production - even if there's an issue.
    $ErrorActionPreference = 'Stop'            

    # This makes the run Stop if attempting to use an unassigned variable. Lazy shits at City of Boise prefer scripts that NEVER error in production - even if there's an issue. How did I ever survive in this crap worthless world of hacks???

    Set-StrictMode -Version Latest

    # Considered somewhat standard to avoid failures importing, including, etc., due to Microtoff's every increasing security layers everytime they get hacked.
    
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
    
    # Can't do Scheduled Task work anymore (Win 10) without admin privs. Example of above Sec Fetish.

    $amRunningAsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    # Always time everything.  Eventually you will always want to know how long the damn script ran.

    [Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '')]
    $scriptTimer = [Diagnostics.Stopwatch]::StartNew()   # Host to use: $scriptTimer.Elapsed.TotalSeconds                  

############ Capture some common globals.  I don't remember "$env:". Ever.
                                                                                                                                
    [Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '')]
    $MyComputerName = $env:COMPUTERNAME     # DSKTP-HOME-JEFF            
    [Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '')]
    $OneDriveDirectory = $env:OneDrive   # D:\OneDrive
    [Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '')]
    $OSUserName = $env:USERNAME   # jeffs
    [Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '')]
    $OSUserFiles       = $env:USERPROFILE    # C:\Users\jeffs

    [Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '')]
    $DEFAULT_POWERSHELL_TIMESTAMP_FORMAT = "yyyy-MM-dd HH:mm:ss.ffffff zzz"      # 2024-01-22 05:37:00.450241 -07:00    ONLY to 6 places (microseconds). Windows has 7 places, which won't match with Postgres's 6
    [Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '')]
    $DEFAULT_POSTGRES_TIMESTAMP_FORMAT = "yyyy-mm-dd hh24:mi:ss.us tzh:tzm"    # 2024-01-22 05:36:46.489043 -07:00

    # The following pulls the CALLER path.  If you are running this dot file directly, there is no caller set.

    $MasterScriptPath = $MyInvocation.ScriptName  # I suppose you could call this a "Name".  It's a file path.

    if ([String]::IsNullOrEmpty($masterScriptPath)) {                                                                
        # So instead of "ScriptName", we've got "Line", "Statement", "MyCommand" (which is actually the Script Name), and "PositionMessage" which is a bit messy, but could be used to get the caller.
        $MasterScriptPath = $MyInvocation.Line.Trim("`'. ") # No ScriptName if running this file directly, just Line = . 'D:\qt_projects\filmcab\simplified\_dot_include_standard_header.ps1'  This of course will devolve over PS versions. Why? Because developer constantly finesse stuff and break code.
    }                                          
    
    # For debugging/logging, when was this file changed? When a script changes, you can toss all previous testing out the window.  This script HASNT been tested.  When did your error first occur? Right after the last write time changed? Interesting, maybe it was what changed that broke.
                                                                                          
    [Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '')]
    $FileTimeStampForParentScript = (Get-Item -Path $MasterScriptPath).LastWriteTime
    
    # We're going to call "scriptName" the Name WITHOUT the bloody directory it's in. I'm torn on name with or without extension - BUT since two files can have same base name with different extensions, and soon there'll be a "ps2" (kidding?), we might as well be careful.
     
    [Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '')]
    $ScriptName                 = (Get-Item -Path $masterScriptPath).Name # Unlike "BaseName" this includes the extension
    [Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '')]
    $ScriptNameWithoutExtension = (Get-Item -Path $masterScriptPath).BaseName   # Base name is nice for labelling

    $ProjectRoot  = (Get-Location).Path  # in debug, D:\qt_projects\filmcab
    
    $PathToConfig = $ProjectRoot + '\config.json'
    $Config       = Get-Content -Path $PathToConfig | ConvertTo-Json

    # Maybe grab HistoryId for how many runs in this session. Debug meta? Note that it resets if the powershell terminal is killt.
                                                                                          
    [Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '')]
    $CurrentDebugSessionNo = $MyInvocation.HistoryId
                                               
    $tryToStartTranscriptAttempts = 0
    
    # Transcript logging is weak, but it's something, as long as you can deal with the locking issues, and not starting and not stopping.
    # It locks up in debugging if you restart too soon, and don't hit the Stop-Transcript in the footer.  One try is probably enough
    while ($tryToStartTranscriptAttempts -lt 3) {
        try {
            $tryToStartTranscriptAttempts++
            Start-Transcript -Path "D:\qt_projects\filmcab\simplified\_log\$ScriptName.transcript.log" -IncludeInvocationHeader
            break
        }
        catch [System.IO.IOException]{
            # Close it, then try, at least two more times.
            # Transcription cannot be started due to the error: The process cannot access the file 'D:\qt_projects\filmcab\simplified\_log\pull_scheduled_task_definitions.ps1.transcript.log' because it is being used by another process.
            try {
                Stop-Transcript "D:\qt_projects\filmcab\simplified\_log\$ScriptName.transcript.log"
                Start-Sleep -Milliseconds 10.0
            }                                                                                      
            catch {
                # Fails so ignore.
            }
        }                                  
    }

    <#
    .SYNOPSIS
    Converts a time duration to a more readable form
    
    .DESCRIPTION
    I always like to do this.  I want to see "1 Day" vs. "300000 Seconds"
    
    .PARAMETER ob
    Parameter description
    
    .EXAMPLE
    An example
    
    .NOTES
    #TODO: Switch to humanizer?
    #>
Function Format-Humanize($ob) {
    if ($ob -is [Diagnostics.Stopwatch]) {
        $ob = $ob.Elapsed
    }                    
    
    if ($ob -is [timespan]) {
        if ($ob.Days -gt 0) {
            Format-Plural 'Day' $($ob.Days) -includeCount
        }
        elseif ($ob.Hours -gt 0) {
            Format-Plural 'Hour' $($ob.Hours) -includeCount
        }
        elseif ($ob.Minutes -gt 0) {
            Format-Plural 'Minute' $($ob.Minutes) -includeCount
        }
        elseif ($ob.Seconds -gt 0) {
            Format-Plural 'Second' $($ob.Seconds) -includeCount
        }
        elseif ($ob.Milliseconds -gt 0) {
            Format-Plural 'Millisecond' $($ob.Milliseconds) -includeCount
        }
        elseif ($ob.Microseconds -gt 0) {
            Format-Plural 'Microsecond' $($ob.Microseconds) -includeCount
        }
        elseif ($ob.Ticks -gt 0) {
            Format-Plural 'Tick' $($ob.Ticks) -includeCount
        }
    }
}
<#
.SYNOPSIS
More details on script activity.

.DESCRIPTION
Needs testing.

.EXAMPLE
An example

.NOTES
General notes
#>
Function Enable-PSScriptBlockLogging
{
    $basePath = 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' 

    if(-not (Test-Path $basePath)) {     
        $null = New-Item $basePath -Force     
        New-ItemProperty $basePath -Name "EnableScriptBlockLogging" -PropertyType Dword 
        New-ItemProperty $basePath -Name "EnableInvocationHeader" -PropertyType Dword
        New-ItemProperty $basePath -Name "OutputDirectory" -PropertyType String
    } 
    
    if ($amRunningAsAdmin) {
        Set-ItemProperty $basePath -Name "EnableScriptBlockLogging" -Value "1"
        Set-ItemProperty $basePath -Name "EnableInvocationHeader" -Value "1"
        # TODO: Set-ItemProperty $basePath -Name "OutputDirectory" -Value $OutputDirectory
    }
}

<#
.SYNOPSIS
Use in parameter [ValidateScript] call.  Only way I can find to fully document and test for the possibilities.

.DESCRIPTION
Trap these problems as early as possible, and get good error messages about what happened.

.PARAMETER s
The string we're testing.

.PARAMETER varname
The name of the parameter testing for documentation only.

.EXAMPLE
 [CmdletBinding()]
    param(           
        [Parameter(Position=0,Mandatory=$true)][ValidateScript({Assert-MeaningfulString $_ 'sql'})]        [string] $sql
    )

.NOTES
General notes
#>
function Assert-MeaningfulString([string]$s, $varname = 'string') {
    if ($null -eq $s){                            # Inquiring minds want to know.  Send me 4 spaces?  Big clue.  Not the same as being sent a null.
        throw "Your $varname is null."
    } elseif ([string]::IsNullOrEmpty($s)){
        throw "Your $varname is an empty string."
    } elseif ([string]::IsNullOrWhiteSpace($s)){                 # The number of blanks may matter.  I've had places where secretaries cut and paste from the web or Excel and drop an NL in there.  Worth a test (need to add)
        throw "Your $varname is an blank string of $($s.Length)."
    } else {
        $true
    }
}
<#
.SYNOPSIS
Display all the error messages availale and exit.

.DESCRIPTION
Initially I had cut and pasted this code around - until I suddenly noticed it was only display the first "Write-Error"!  I converted to Write-Host, but all the copies. Ugh.  And the failing on LoaderExceptions which isn't always there.

.PARAMETER scriptWhichProducedError
Usually sql, but not necessarily. Yes it reveals secrets to the hack types, I don't care I want to see what failed.  Maintenance before security.

.PARAMETER exitcode
If DontExit is false, then what number to return to the OS?

.PARAMETER DontExit
I default to exiting when there's an error.  My thing. Even in production. Explicitly tell me you've got it covered.

.EXAMPLE
Show-Error -exitcode 23920  #(Int32 I think is Windows limit)

.NOTES
Could be enhanced. Log to file. Detect new errors, which are more important in debugging. Often lazy developers ignore errors in a priority basis.
#>
Function Show-Error {
    param(
        [Parameter(Position=0,mandatory=$false)]        [string]$scriptWhichProducedError,    
        [Parameter(Position=1,mandatory=$false)]        [int32] $exitcode = 1, # non-zero generally means failure in executable world
        [switch]$DontExit # switches always default to false. I forget that sometimes.
    )                                                                        

    # WARNING: DONT use Write-Error. The code will stop. It's really "Write-then-Error"
    Write-Host $scriptWhichProducedError
    Write-Host "Message: $($_.Exception.Message)"
    Write-Host "StackTrace: $($_.Exception.StackTrace)"             
    Write-Host "Failed on $($_.InvocationInfo.ScriptLineNumber)"
    $Exception = $_.Exception
    $HResult = 0

    if (Test-Path variable:Exception) {
    if ($Exception.InnerException) {
        $HResult = $Exception.InnerException.HResult # 
    } else {
        $HResult = $Exception.HResult
    }                              
    if ($Exception.ErrorRecord) { Write-Host "Error Record= $($Exception.ErrorRecord)"}
    # ([Int32]"0x80131501") ==> -2146233087 CORRECT! What HResult was.
    # EventData\Data\ResultCode=2148734209 "{0:X}" -f 2148734209 ==> 80131501 CORRECT. Do not use Format-Hex.
    }

    Get-PSCallStack
    
    try {
        Write-Host "LoaderExceptions: $($_.Exception.LoaderExceptions)"   # Some exceptions don't have a loader exception.
    } catch {}
    
    if (-not $DontExit) {    
        Write-VolumeCache D # So that log stuff gets written out in case of fatal crash                                                          # Double-negative. Meh.
        exit $HResult # These SEEM to be getting back to Task Scheduler 
    }
    return $HResult
}

Function PrepForSql {
    param (
        $val,
        [Switch]$KeepEmpties
    )
    if ($null -eq$val) { return 'NULL'}      
                 
    if ($val.Trim() -eq '' -and -not $KeepEmpties) { return 'NULL'}
    return "'" + $val.Replace("'", "''") + "'"
}


<#
.SYNOPSIS
Execute SQL commands.

.DESCRIPTION                                                                                                          
Also captures as much error detail as it can. Forces a stoppage even if ErrorAction is not Stop.  That's probably bad.
Mostly just to reduce caller bloat.  There's no $DatabaseCommand.ExecuteNonQuery("Select 1") like there is in C#. And I don't think Powershell supports extended functions.
Doesn't capture return values.

.PARAMETER sql
Script to execute.

.EXAMPLE
Invoke-Sql 'SET search_path = simplified, "$user", public'

.NOTES
Also good way to enforce some sort of error response. Damn! Even displays the sql executed!!!!!!! Hell has broken out on the face of the Earth!
#>
Function Invoke-Sql {
    [CmdletBinding()]
    param(           
        [Parameter(Position=0,Mandatory=$true)][ValidateScript({Assert-MeaningfulString $_ 'sql'})]        [string] $sql
    )
    try {
        $DatabaseCommand.CommandText = $sql                # Worry: is dbcmd set? Set in main. Below.

        # Hypothetically, you could determine if the sql was a select or an update/insert, and run the right function?

        [Int32] $howManyRowsAffected = $DatabaseCommand.ExecuteNonQuery();
        return $howManyRowsAffected
    } catch {   
        Show-Error $sql -exitcode 1 # Try (not too hard) to have some unique DatabaseColumnValue returned. meh.
    }
}

# https://gist.github.com/Jaykul/dfc355598e0f233c8c7f288295f7bb56
#https://gist.github.com/Jaykul/dfc355598e0f233c8c7f288295f7bb56#file-you-need-to-implement-non-generic-md
class __WhileSqlGenerator : System.Collections.IEnumerator {
    [string]$sql
    [System.Data.Odbc.OdbcCommand]$DatabaseCommand
    $readerObject
    [int]$Actual = 0
    $ResultSetColumnDefinitions
    
    __WhileSqlGenerator() {
        throw [Exception] "Please provide a sql"
    }

    __WhileSqlGenerator([string]$sql) {
        $this.sql                         = $sql
        $this.DatabaseCommand             = $Script:DatabaseConnection.CreateCommand()
        $this.DatabaseCommand.CommandText = $sql
        $this.readerObject                      = [REF]$this.DatabaseCommand.ExecuteReader();
        $local_reader = $this.readerObject.Value                             
    #    $local_reader.Read()

        $this.ResultSetColumnDefinitions       = $local_reader.GetSchemaTable()
        foreach ($ResultSetColumnDefinition in $this.ResultSetColumnDefinitions) {             
            $DatabaseColumnName = $ResultSetColumnDefinition.ColumnName
            #$DatabaseColumnValue  = Get-SqlFieldValue $this.readerObject $DatabaseColumnName
                                                         
            New-Variable -Name $DatabaseColumnName -Scope Script -Option AllScope -Value $null -Force -Visibility Public
            
            #$DatabaseDriverTypeNo = $ResultSetColumnDefinition.ProviderType
        }
                
    }

    [object]get_Current() {
        return $this.Actual
    }

    [bool] MoveNext() {
       # if ($anyMoreRecordsToRead) {
        $local_reader = $this.readerObject.Value                             
        $anyMoreRecordsToRead = $local_reader.Read()
        if ($anyMoreRecordsToRead) {
        $this.ResultSetColumnDefinitions       = $local_reader.GetSchemaTable()
        foreach ($ResultSetColumnDefinition in $this.ResultSetColumnDefinitions) {             
            $DatabaseColumnName = $ResultSetColumnDefinition.ColumnName
            $DatabaseColumnValue  = Get-SqlFieldValue $this.readerObject $DatabaseColumnName
            Set-Variable -Name $DatabaseColumnName -Value $DatabaseColumnValue
        }                           
    }
        return $anyMoreRecordsToRead
    }

    [void] Reset() {
        $this.Actual = 0
    }

    [void] Dispose() {
        # Close reader
    }
}

# class WhileSqlGenerator : __WhileSqlGenerator, System.Collections.Generic.IEnumerator[int] {
#     WhileSqlGenerator([string]$sql) : base($sql) {}
#     [int]get_Current() {
#         return $this.Actual
#     }
# }

<#
.SYNOPSIS
Simple while loop through sql

.DESCRIPTION
Long description

.PARAMETER sql
Parameter description

.EXAMPLE
While (While-Sql "SELECT y from x") { Write-Host $y }

.NOTES
Collections.Generic.IEnumerable[string]
Enumerable.ToList()
#>
Function While-Sql {
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true)][ValidateScript({Assert-MeaningfulString $_ 'sql'})]        [string] $sql
    )
    $DatabaseCommand             = $DatabaseConnection.CreateCommand()
    $DatabaseCommand.CommandText = $sql
    $reader                      = $DatabaseCommand.ExecuteReader();
    $ResultSetColumnDefinitions  = $reader.GetSchemaTable()

    foreach ($ResultSetColumnDefinition in $ResultSetColumnDefinitions) {             
        $DatabaseColumnName = $ResultSetColumnDefinition.ColumnName
        $DatabaseColumnType = $ResultSetColumnDefinition.DataType
        $DatabaseDriverTypeNo = $ResultSetColumnDefinition.ProviderType
        $DatabaseColumnValue  = Get-SqlFieldValue $reader $DatabaseColumnName
    }

}
<#
.SYNOPSIS
Select a query but don't read the first row so the caller can use a While

.DESCRIPTION
Long description

.EXAMPLE
$readerHandle = Walk-Sql $sql
$reader = $readerHandle.Value 
While ($reader.Read()) {
} 

$reader.Close() # Optional

.NOTES
General notes
#>
Function Walk-Sql {
    [CmdletBinding()]
    param(           
        [Parameter(Position=0,Mandatory=$true)][ValidateScript({Assert-MeaningfulString $_ 'sql'})]        [string] $sql
    )
    Select-Sql $sql -skipInitialRead
}                                   


<#
.SYNOPSIS
Execute a SELECT statement and return a traversable cursor.

.DESCRIPTION
Tired of rekeying this code over and over. I usually (always) only need one reader ever open in on thread. So this works.

.PARAMETER sql
SQL script that I guess could execute a function (stored proc) that returned a result set, but I use it for selects. Not for batches, though.

.EXAMPLE
$readerHandle = (Select-Sql $sql) # Cannot return reader value directly from a function or it blanks, so return it boxed
$reader = $readerHandle.Value # Now we can unbox!  Ta da!                                                                                                    
Do { # Buggy problem: My "Select-Sql" does an initial read.  If it came back with no rows, this would crash. Ugh. Maybe a "Walk-Sql" that does not do a read.
} While ($reader.Read())

$reader.Close()

.NOTES
There is no way to return a LOCALLY INSTANTIATED ODBCDataReader object as a DatabaseColumnValue. It will always ALWAYS resolve to null for the caller. I wish the example would be "$reader = Select-Sql 'select 1'" but I can't get it to work. hmmmmmmm
Better name for a command that runs a query and returns a cursor?  Invoke is more like it does something and leaves it.
"Read-Sql"? GetHandleToSQLInvokationOutput?  Maybe it's a Get-Sql. Traverse-Sql? Browse? Walk? ForEach-Sql?  That's what happens when you return the reader. Return an enumerator perhaps.  Even While-Sql
#>
Function Select-Sql {
    [CmdletBinding()]
    param(           
        [Parameter(Position=0,Mandatory=$true)][ValidateScript({Assert-MeaningfulString $_ 'sql'})]        [string] $sql,
        [Switch]$skipInitialRead
    )
    try { 
        $DatabaseCommand = $DatabaseConnection.CreateCommand()
        $DatabaseCommand.CommandText = $sql
        $reader = [REF]$DatabaseCommand.ExecuteReader(); # Too many refs?
        $reader = $reader.Value 
        if (-not $skipInitialRead) {        $reader.Read() >> $null   }
        return [REF]$reader                      # Forces caller to deref!!!!! But only way to get it to work.
    } catch {
        Show-Error $sql -exitcode 2
    }   
}

<#
.SYNOPSIS
Convert select output to a string array (no hashtable!).

.DESCRIPTION
Long description

.PARAMETER sql
Parameter description

.EXAMPLE
$sql = "
SELECT 
    directory_path                         /* Deleted or not, we want to validate it. Probably more efficient filter is possible. Skip ones I just added, for instance. Don't descend deleted trees. */
FROM 
    directories
"
$readerHandle = (Select-Sql $sql) # Cannot return reader value directly from a function or it blanks, so return it boxed
$reader = $readerHandle.Value # Now we can unbox!  Ta da!
$olddirstillexists          = Get-SqlFieldValue $readerHandle directory_still_exists
$val = $reader.GetValue(0)

.NOTES
I don't like the verb "Show".  But this function just to blow a select output on the screen is sorely lacking for the lazy developer.
"Out-Sql" isn't great. I want the output. Select-Sql returns a reader. I suppose "Select-Sql" would behave more like a Select both PS and SQL.
"Out-Sql" might be more of a block or copy command to a database.  Treating the server as a device.
#>
Function Out-SqlToList {
    [CmdletBinding()]
    param(           
        [Parameter(Position=0,Mandatory=$true)][ValidateScript({Assert-MeaningfulString $_ 'sql'})]        [string] $sql,
        [Switch]$DontOutputToConsole,
        [Switch]$DontWriteSqlToConsole
    )
    try {
        $DatabaseCommand = $DatabaseConnection.CreateCommand()
        $DatabaseCommand.CommandText = $sql
        $adapter = New-Object System.Data.Odbc.OdbcDataAdapter $DatabaseCommand 
        $dataset = New-Object System.Data.DataSet
        $adapter.Fill($dataSet) | out-null
        if (-not $DontWriteSqlToConsole) {
            Write-Host $sql
        }
        if (-not $DontOutputToConsole) {
            
            $dataset.Tables[0].Rows|Select * -ExcludeProperty RowError, RowState, Table, ItemArray, HasErrors|Out-Host # Make it a little concise.
        }      
        
        $stringlist = @()
        foreach ($s in $dataset.Tables[0].Rows)
        {
            $v = $s[0].ToString()
            $stringlist+= $v
        }
        return $stringlist
    } catch {
        Show-Error $sql -exitcode 3
    }   
}
                               
#Insert-One
#Delete-One
#Update-One
#Get-One
<#
.SYNOPSIS
Return true/false from a sql based on row count

.DESCRIPTION
Long description

.PARAMETER sql
Parameter description

.PARAMETER DontOutputToConsole
Parameter description

.PARAMETER DontWriteSqlToConsole
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>#
Function Test-Sql {
    [CmdletBinding()]
    param(           
        [Parameter(Position=0,Mandatory=$true)][ValidateScript({Assert-MeaningfulString $_ 'sql'})]        [string] $sql,
        [Switch]$DontOutputToConsole,
        [Switch]$DontWriteSqlToConsole
    )
    try {
        $DatabaseCommand = $DatabaseConnection.CreateCommand()
        $DatabaseCommand.CommandText = $sql
        $reader = $DatabaseCommand.ExecuteReader()
        if (-not $reader.HasRows) { return $false}
        # Error if more than one row returned??
        return $true
    } catch {
        Show-Error $sql -exitcode 6
    }   
}

<#
.SYNOPSIS
Returns a dataset that I can "." reference properties from.

.DESCRIPTION
Long description

.PARAMETER sql
SQL script that returns a result set, probably a small set?

.PARAMETER DontOutputToConsole
Parameter description

.PARAMETER DontWriteSqlToConsole
Parameter description

.EXAMPLE
$state_of_session = Out-SqlToDataset "SELECT batch_run_session_id, started FROM batch_run_sessions WHERE running"
if ($null -ne $state_of_session) {
if ($state_of_session.batch_run_session_id -lt 100000) {...}

.NOTES
General notes
#>
Function Out-SqlToDataset {
    [CmdletBinding()]
    param(           
        [Parameter(Position=0,Mandatory=$true)][ValidateScript({Assert-MeaningfulString $_ 'sql'})]        [string] $sql,
        [Switch]$DontOutputToConsole,
        [Switch]$DontWriteSqlToConsole
    )
    try {
        $DatabaseCommand = $DatabaseConnection.CreateCommand()
        $DatabaseCommand.CommandText = $sql
        $adapter = New-Object System.Data.Odbc.OdbcDataAdapter $DatabaseCommand 
        $dataset = New-Object System.Data.DataSet
        $adapter.Fill($dataSet) | out-null
        if (-not $DontWriteSqlToConsole) {
            Write-Host $sql
        }
        if (-not $DontOutputToConsole) {
            
            $dataset.Tables[0].Rows|Select * -ExcludeProperty RowError, RowState, Table, ItemArray, HasErrors|Out-Host # Make it a little concise.
        }                          
        return $dataset.Tables[0].Rows
        
    } catch {
        Show-Error $sql -exitcode 4
    }   
}

<#
.SYNOPSIS
Fetch a typed DatabaseColumnValue from a reader by either ordinal or name.

.DESCRIPTION
Not as easy as it looks. The various and sorded ways information is gotten are mixed between what PostgreSQL returns, what ODBC driver interprets, and finally what the .Net driver interprets as the right return type.

.PARAMETER reader
Must be open, or it will crash. I use DbDataReader because it's abstract.

.PARAMETER ordinalNoOrColumnName
Allows you pass in the ordinal number, usually the position of the field, or the name of the field.  I prefer passing in names rather than ordinals, and if I change the sql order, oops. 😬

.EXAMPLE
 $DatabaseColumnValue          = Get-SqlFieldValue $reader $DatabaseColumnName
 $DatabaseColumnValue          = Get-SqlFieldValue $reader 1
 $olddirstillexists          = Get-SqlFieldValue $reader directory_still_exists  # comes back [bool] if set, [object] if not set (Was DbNull internally somewhere)

.NOTES
Far from perfect. Only solution I can find is to do my own pg_types query and get the postgres column type, and if it's an array. Maybe if I type the columns in the SQL?
#>
function Get-SqlFieldValue {
    param (
        [Parameter(Position=0,Mandatory=$true)][Object] $readerOb, # Child types are DataTableReader, Odbc.OdbcDataReader, OleDb.OleDbDataReader, SqlClient.SqlDataReader
        [Parameter(Position=1,Mandatory=$true)][Object] $ordinalNoOrColumnName
    )
             
    $reader = $null

    if ($readerOb -is [System.Data.Common.DbDataReader])
    {
        $reader = $readerOb
    }                      
    else {
        $reader = $readerOb.Value # readers have to be wrapped or they go blank.
    }
    
    [Int32]$ordinal = $null
    [object]$columnValue = $null

    $columnODBCMetadata = $null

    if ($ordinalNoOrColumnName -is [Int32]) {
        $columnODBCMetadata = $reader.GetSchemaTable() | Select-Object *|Where-Object ColumnOrdinal -eq $ordinalNoOrColumnName
    } else {
        $columnODBCMetadata = $reader.GetSchemaTable() | Select-Object *|Where-Object ColumnName -eq $ordinalNoOrColumnName
    }

    if ($null -eq $columnODBCMetadata) {
        throw [System.Exception] "GetSchemaTable returned nothing for $ordinalNoOrColumnName"
    }        

    $ordinal = $columnODBCMetadata.ColumnOrdinal

    if ($ordinal -eq -1) { # Not sure this happens.
        throw [System.Exception] "ordinal not set or found for $ordinalNoOrColumnName"
    }
                                             
    ##### Nows to the typing of our DatabaseColumnValue, which we want to maintain in the script. Only tested for Postgres 15
    
    $columnValue = $reader.GetValue($ordinal)
    if ($columnValue -is [System.DBNull]) {
        $columnValue = $null
    }
    
    $columnDataType = $columnODBCMetadata.DataType
    $columnPostgresTypeId = $columnODBCMetadata.ProviderType # Only way to distinguish
    $columnPostgresType = [type][String] # Default type

    switch ($columnPostgresTypeId)
    {
         9 {$columnPostgresType = [type][byte[]]}
        11 {$columnPostgresType = [type][datetime]}                                               # timestamp in database
        23 {$columnPostgresType = [type][datetime]}                                               # date in database
        24 {$columnPostgresType = [type][timespan]}                                               # time in database
        22 {
            $columnPostgresType = [type][bool]
            $columnValue = [Int32]$columnValue # The string "0" -as System.Boolean = $True !!! So unfortunate
            $columnValue = [bool]$columnValue
        }
        12 {$columnPostgresType = [type][string]}                                                 # varchar in database
         1 {                                    
            if ($columnDataType -eq 'Int64') {    # May alter the connection string to force int8 returns
                $columnPostgresType = [type][Int64]
            } else {
                $columnPostgresType = [type][string]
            }
        }                                                 # char in database
        13 {$columnPostgresType = [type][string]}                                                 # name in database
         4 {$columnPostgresType = [type][Int32]}                                                  
        10 {$columnPostgresType = [type][Int32]}                                                  # int4 in database
         5 {
            if ($columnDataType.Name -eq 'DateTime') { # More bugs!!!!
                $columnPostgresType = [type][datetime]
            } else {
                $columnPostgresType = [type][Int16]
            }
        }                                                  
        17 {$columnPostgresType = [type][Int16]}                                                  # int2 in database
        14 {$columnPostgresType = [type][single]}                                                 # float4 in database
         8 {$columnPostgresType = [type][double]}                                                 # float8 in database
         7 {$columnPostgresType = [type][decimal]}                                                # numeric in database
        15 {$columnPostgresType = [type][guid]}                                                   # uuid in database
        
        default { 
            throw [System.Exception] "Unimplemented type $columnPostgresTypeId for data type $columnDataType and column $ordinalNoOrColumnName"
        }
    }

    $columnValue = $columnValue -as $columnPostgresType
    
    # Warning: Nulls will NOT return as typed. No can do.
    return $columnValue
}

<#
.SYNOPSIS
Write a string line to file defined in Start-Log

.DESCRIPTION
Long description

.PARAMETER Text
Parameter description

.PARAMETER Restart
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Log-Line {
    [CmdletBinding()]
    param(
        [Parameter(Position=1, Mandatory=$false)][string] $Text,
        [switch]$Restart
    )
    #$mtx = New-Object System.Threading.Mutex($false, 'FileMtx')
    #[void] $mtx.WaitOne()
    
    if ($null -eq $Text) {
        Write-LogLineToFile "*** null string" 
    }
    elseif ( '' -eq $Text) {
        Write-LogLineToFile "*** empty string" 
    } 
    else {
        
        try{
            $HashArguments = @{}
            if ($Restart) {
                $HashArguments = @{Force = $true}
            } else {
                $HashArguments = @{Append = $true}

            }
            Write-LogLineToFile $Text $HashArguments
            #Write-LogLineToFile "Wrote line"
        }catch{
            $HashArguments = @{}
            $err = $_.Exception.Message
            Write-LogLineToFile "Catching"
            Write-LogLineToFile "$err" 
        }finally{
            #[void] $mtx.ReleaseMutex()
            #$mtx.Dispose()
            #$HashArguments = @{}
           
        }
    }
}
<#            
.SYNOPSIS
Yet another layer, but keeping the file name path, encoding, even that it's out to a file, that helps reduce code.

.DESCRIPTION
Long description

.PARAMETER text
Parameter description

.PARAMETER arguments
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Write-LogLineToFile {
    param([string]$text, [hashtable]$arguments)
    #"HERE"| Out-File "$ScriptRoot\text.txt" -Encoding utf8 -Append
    if ($null -eq $text) {
        "NULL"|  Out-File "$Script:LogFilePath" -Encoding utf8 -Append
    } 

    if ($null -eq $arguments) {
        $text | Out-File "$Script:LogFilePath" -Encoding utf8 -Append
    } else {
        $text | Out-File "$Script:LogFilePath" -Encoding utf8 @arguments
    }
    # TOO SLOW!!! Write-VolumeCache D # So that log stuff gets written out in case of fatal crash
}
function Log-SqlConnection {
    # Database, driver, etc. Even user!!!!!!!!!!!
}

function Log-Sql {

}

function Log-SqlError {

}

function Log-SqlChangedObject {
    # New columns, indexes, constraints, updated function, new postgres version, new extensions
}

function Log-HttpRequest {

}

function Log-Wait {

}
function Log-SkipSection {

}

function Log-EmptyElseClause {

}

function Log-Unimplemented {

}
function Log-Branch {

}

function Log-OutOfBandValue {

}

<#
.SYNOPSIS
Get better data typing on a query's columns.

.DESCRIPTION
Needs work. Right now it just displays them.  

.PARAMETER reader
Data reader object.  These can be passed in if created at the callers level.

.EXAMPLE
$reader = (Select-Sql 'SELECT * FROM t').Value # Cannot return DatabaseColumnValue directly
Get-SqlColDefinitions $reader

.NOTES
Dependent on Get-SqlFieldValue so that's why it's up above.
#>
Function Get-SqlColDefinitions {
    param(
        [Parameter(Position=0,Mandatory=$true)] [Data.Common.DbDataReader] $reader 
    )
    
    $ResultSetColumnDefinitions = $reader.GetSchemaTable()

    foreach ($ResultSetColumnDefinition in $ResultSetColumnDefinitions) {             
        $DatabaseColumnName = $ResultSetColumnDefinition.ColumnName
        $DatabaseColumnType = $ResultSetColumnDefinition.DataType
        $DatabaseDriverTypeNo = $ResultSetColumnDefinition.ProviderType
        $DatabaseColumnValue          = Get-SqlFieldValue $reader $DatabaseColumnName

        if ($null -eq $DatabaseColumnValue) {
            "column {0} is column type {1}, and value of null, provider type #{3}" -f 
            $DatabaseColumnName, $DatabaseColumnType, $DatabaseColumnValue, $DatabaseDriverTypeNo
        } else {
            $DatabaseColumnValueType = $DatabaseColumnValue.GetType().Name
            "column {0} is column type {1} and a value of {2}, provider type #{3}, and a value type of {4}" -f 
            $DatabaseColumnName, $DatabaseColumnType, $DatabaseColumnValue, $DatabaseDriverTypeNo, $DatabaseColumnValueType
        }
    }
}
                                                
<#
.SYNOPSIS
Set up persistent logging.

.DESCRIPTION                                                                                                                                                      
Looked for my perfect logging tool. Made one myself. All the githubs I looked at were a bit off for my needs.  Easy-Peezy with buttloads of detail is what I want.
My goal was to make it easy for the caller. Least number of parameters you have to send. So 'Log' is a verb.  Not 'Write-LogInfo", "Write-LogError", etc.
Requirement: Call Start-Log, with no params if you like. It captures as much as it can, regardless of the performance.

.EXAMPLE
Start-Log

.NOTES
Over complicated and adds risk and delay.  aka - Features.
#>

function Log-ScriptCompleted {
    $elapsedTime = $scriptTimer.Elapsed
    $secondsRan = $elapsedTime.TotalSeconds
    Log-Line "Stopping Normally after $secondsRan Second(s)"
    # Timestamp
    # Elapsed time in human form
    # CPU used? etc.
    # Rows written? Deleted? Updated? Found but no change?
}

$Script:Caller = 'TBD'

function Start-Log {
    [CmdletBinding()]
    param(
        # i.e., Override filename
    )

    # https://stackoverflow.com/questions/56551241/difference-between-a-runspace-and-external-request-in-powershell#56558837
        # Internal = The command was dispatched by the msh engine as a result of a dispatch request from an already running command.
        # Runspace = The command was submitted via a runspace.

    New-Variable -Name ScriptRoot -Scope Script -Option ReadOnly -Value ([System.IO.Path]::GetDirectoryName($MyInvocation.PSCommandPath)) -Force
    $DSTTag = If ((Get-Date).IsDaylightSavingTime()) { "DST"} else { "No DST"} # DST can seriously f-up ordering.
    
    $Script:LogDirectory = "$ScriptRoot\_log"
    
    New-Item -ItemType Directory -Force -Path $Script:LogDirectory|Out-Null
                                                        
    $Script:LogFileName = $ScriptName + '.log.txt' 
    $Script:LogFilePath = $Script:LogDirectory + '\' + $Script:LogFileName

    # Header Line 1
    Log-Line "Starting Log $(Get-Date) on $((Get-Date).DayOfWeek) $DSTTag in $((Get-Date).ToString('MMMM')), by Windows User <$($env:UserName)>" -Restart
    
    $PSVersion       = $PSVersionTable.PSVersion
    $PEdition        = $PSVersionTable.PSEdition
    $ScriptFullPath  = $MyInvocation.ScriptName
    $CommandOrigin   = $MyInvocation.CommandOrigin
    $CurrentFunction = $MyInvocation.MyCommand

    # Header Line 2   
    Log-Line "`$ScriptFullPath: $ScriptFullPath, `$PSVersion = $PSVersion, `$PEdition = $PEdition, `$CommandOrigin = $CommandOrigin, Current Function = $CurrentFunction"

    # Get all our parent processes to detect (try) what started us
    
    $p = Get-CimInstance -Class Win32_Process -Filter "ProcessId = $PID"
    $processtree = @()

    While ($p) {
        $processtree+= $p
        $p = Get-CimInstance -Class Win32_Process -Filter "ProcessId = $($p.ParentProcessId)"
    }

    # If being run inside Visual Code editor: Explorer.exe -> Code.exe -> Code.exe ->powershell.exe
    # If being run from Scheduler: wininit.exe -> services.exe -> svchost.exe -> powershell.exe
    # cmd  /K "chcp 1252"
    if ($processtree.Count -ge 2) {
        $determinorOfCaller = $processtree[1]
        if ($null -eq $determinorOfCaller.CommandLine) { 
            Log-Line "processtree 1 CommandLine is null"
        } else {
            Log-Line "processtree 1 CommandLine is not null: $($determinorOfCaller.CommandLine)" # C:\WINDOWS\system32\svchost.exe -k netsvcs -p -s Schedule
        }
                                                        
        $partofcmdline = $determinorOfCaller.CommandLine

        if ($partofcmdline.Length -gt 100) {$partofcmdline = $determinorOfCaller.CommandLine.SubString(0,100)}
     
        # Called from Windows Task Scheduler?

        if ($determinorOfCaller.Name -eq 'svchost.exe' -and $determinorOfCaller.CommandLine -ilike "*schedule*") {
            Log-Line "Called from Windows Task Scheduler"
            $Script:Caller = 'Windows Task Scheduler'

            # Get a list of all defined tasks on this machine. We want to match our execute and arguments to 1 or more tasks' actions.
            # Hopefully we can guess at which one called us.

    
            $cmdlineofstartargs = $processtree[0].CommandLine
            Log-Line "Scanning Get-ScheduledTasks"
            Log-Line $cmdlineofstartargs

            # $possibleTaskCallingMe = $allregisteredtasks|Where-Object CommandLine -eq $cmdlineofstartargs
            # if ($null -eq $possibleTaskCallingMe) {
            #     Log-Line "Null count"
            # } else {
            #     Log-Line "Found some tasks"
            # }
            # $howmanyfound = $possibleTaskCallingMe.Count
           
            # Log-Line "Finished Scanning"
            # if ($null -eq $howmanyfound -or $howmanyfound -eq 0) {  #THIS LINE FAILS TO DO ANYTHING
            #     Log-Line "None found"
            # } else {
            #     Log-Line "Some found"
            # }
        
            Log-Line "Finished Scanning (2)"
            exit

            # if ($howmanyfound -eq 1) {
            #     $TaskThatProbablyCalledUs = $possibleTaskCallingMe.Uri
            #     Log-Line "Task that probably called us is <$TaskThatProbablyCalledUs>"
            # }
            # elseif ($howmanyfound -ge 2) {
            #     Log-Line "Found $howmanyfound Tasks with same command line + arguments"
            # }
            # else {
            #     Log-Line "Unable to find any existing non-disabled tasks with this command line and arguments"
            # }

            # TODO: Check history to see if that task just ran
            
        } elseif ($determinorOfCaller.Name -eq 'Code.exe') {
            Log-Line "Called whilest in Visual Code Editor"
            $Script:Caller = 'Visual Code Editor'
        } elseif ($determinorOfCaller.CommandLine -ilike "cmd *") {  
            Log-Line "Called whilest in Command Line"
            $Script:Caller = 'Command Line'
        } else {
            Log-Line "Caller not detected"
            $Script:Caller = ($determinorOfCaller.CommandLine)
            Log-Line ($determinorOfCaller.CommandLine)
            # Other callers could be the command line, JAMS, a bat file, another powershell script, that one at Simplot, the other one at Ivinci, the one at BofA
        }

        #Log-Li
    }
    else {
        Log-Line "gfgfasgadgads"
        $Script:Caller = 'ProcessTree Count less than 2'
    }
    if (1 -eq 0) {
        $ordinal = 0
        ForEach ($p in $processtree) {
            $partofcmdline = ""
            if ($p.CommandLine -eq $null) {
                $partofcmdline = "(empty)"

            
            } elseif ($p.CommandLine.Length -lt 100) {

                $partofcmdli
                $partofcmdline = $p.CommandLine
            } else {
                $partofcmdline = $p.CommandLine.SubString(0,100)
            }
            Log-Line "$ordinal $($p.Name), #$($p.ProcessId), $partofcmdline"
            $ordinal++
        }
    }
}

<#
.SYNOPSIS
Return the best readable string for a SID DatabaseColumnValue.

.DESCRIPTION
Hack reductive way to get annoying sid strings to something readable.  But, to keep the call simple, if a user id or name is passed in and we can't convert it to a name, it just returns that string.  Making life easier, one day at a time.


.PARAMETER sidString
Either a sid, or a user's login id, machine id, etc.

.EXAMPLE
An example

.NOTES
This function is necessary since an unrecognized sid throws an error.
#>
Function Convert-SidToUser {
    param($sidString)
    try {
        $sid = New-Object System.Security.Principal.SecurityIdentifier($sidString)
        $user = $sid.Translate([System.Security.Principal.NTAccount])
        $user.Value
    } catch {
        return $sidString
    }
}

<#
.SYNOPSIS
Generate an ordinal column inside a pipeline block.

.DESCRIPTION
Many arrays output by cmdlets are just an ordered list without any index. I had to join one list to another keyless list, and there's no way to do that without a slow ForEach.
Our "trick" to get a running index in "Select "

.EXAMPLE
$idxfunctor = New-ArrayIndex
Get-Process| Select *, @{Name='idx'; Expression= { & $idxfunctor}}

.NOTES
Each instance you create is separate running values. Very helpful in the Scheduled Task event logs, joining up eventdata attribute names and attribute values, only linkable by position in returned arrays.
#>
Function New-ArrayIndex {
    $index = 0;
    {
        $script:index+= 1
        $index
    }.GetNewClosure()
}                    

Function Least([array]$things) {
    return ($things|Measure -Minimum).Minimum
}                                            

Function Left([string]$val, [int32]$howManyChars = 1) {
    if ([String]::IsNullOrEmpty($val)) { 
        # Made up rule: Empty doesn't have a Leftmost character
        return $null
    }               
    $actualLengthWeWillGet = Least $howManyChars  $val.Length
    return $val.Substring(0,$actualLengthWeWillGet)
}

Function Starts-With($str, $startswith) {
    throw [System.NotImplementedException]
}   

Function Ends-With($str, $startswith) {
    throw [System.NotImplementedException]
}   

Function Right([string]$val, [int32]$howManyChars = 1) {
    if ([String]::IsNullOrEmpty($val)) { 
        return $null
    }               
    $actualLengthWeWillGet = Least $howManyChars  $val.Length
    
    return $val.Substring($val.Length - $actualLengthWeWillGet)           
}

Function Greatest([array]$things) {
    return ($things|Measure -Maximum).Maximum
}                                            

# Note: Stopping a run in debug does not close the connection
# Close does not delete the entry from pg_stat_activity, nor does Dispose
# It seems to decay on it's own.

<#
.SYNOPSIS
Humanize labels for numbers in output to humans.

.DESCRIPTION
Long description

.PARAMETER singularLabel
Parameter description

.PARAMETER number
Parameter description

.PARAMETER pluralLabel
Parameter description

.EXAMPLE
Write-Host "How many genre directories were found:          " $(Format-Plural 'Folder' $howManyGenreFolders -includeCount) 

.NOTES
General notes
#>
Function Format-Plural ([string]$singularLabel, [Int64]$number, [string]$pluralLabel = $null, [switch]$includeCount, [string]$variableName = $null) {
    $ct = ""

    if ($null -ne $variableName -and -not [string]::IsNullOrWhiteSpace($variableName)) {
        
        $ct+= $variableName.Humanize() + ": "
        $number = Get-Variable -Name $variableName -Scope Global -Value
        $includeCount = $true
    }


    if ($includeCount) {
        $ct+= $number.ToString() + " "
    }   

    if ($number -eq 1) {return ($ct + $singularLabel)}
    If ([String]::IsNullOrEmpty($pluralLabel)) {
        $LastCharacter = Right $singularLabel
        $Last2Characters = Right $singularLabel 2
        $SecondLastCharacter = Left $Last2Characters # Concise. Dont repit yourself.

        $Irregulars     = @{Man = 'Men'; Foot='Feet';Mouse='Mice';Person='People';Child='Children';'Goose'='Geese';Ox='Oxen';Woman='Women';Genus='Genera';Index='Indices';Datum='Data'}
        $NonCount= @('Moose', 'Fish', 'Species', 'Deer', 'Aircraft', 'Series', 'Salmon', 'Trout', 'Swine', 'Sheep')
        $OnlyS = @('photo', 'halo', 'piano')                                                                                                                
        $ExceptionsToFE = @('chef', 'roof')      
           
        if ($singularLabel -in $NonCount) {
            $plurallabel = $singularLabel 
        }                                                                        
        elseif ($singularLabel -in $Irregulars.Keys) {
            $plurallabel = $Irregulars[$singularLabel]
        }
        elseif ($singularLabel -in $OnlyS -or $singularLabel -in $ExceptionsToFE) {
            $plurallabel = $singularLabel + 's'
        }
        elseif ($LastCharacter -in @('s', 'ss', 'ch', 'x', 'sh', 'o', 'z') -or $Last2Characters -in @('s', 'ss', 'ch', 'x', 'sh', 'o', 'z')) { 
            $pluralLabel = $singularLabel + 'es'
        }  
        elseif ($Last2Characters -in @('f', 'fe')) { 
            $pluralLabel = $singularLabel.TrimEnd($Last2Characters) + 'ves' # Wife => Wives
        }  
        elseif ($LastCharacter -in @('f', 'fe')) { 
            $pluralLabel = $singularLabel.TrimEnd($LastCharacter) + 'ves'   # Calf => Calves
        }  
        elseif ($Last2Characters -in @('us')) {  
            $pluralLabel = $singularLabel.TrimEnd($Last2Characters) + 'i'   # Cactus => Cacti
        }  
        elseif ($Last2Characters -in @('is')) {  
            $pluralLabel = $singularLabel.TrimEnd($Last2Characters) + 'es'   # Analysis => analyses
        }  
        elseif ($Last2Characters -in @('on')) {  
            $pluralLabel = $singularLabel.TrimEnd($Last2Characters) + 'a'   # Phenomenon => Phenomena
        }  
        elseif ($LastCharacter -in @('y') -and $SecondLastCharacter -notin @('a','e','i','o','u')) { 
            $pluralLabel = $singularLabel.TrimEnd($LastCharacter) + 'ies' # City => Cities
        }  
        else {
            $pluralLabel = $singularLabel + 's'                             # Cat => Cats
        }
    }   

    if ($number -ge 2 -or $number -eq 0) { return ($ct + $pluralLabel)}
    return ($ct + $singularLabel)
}   
                                                                                                         
<#
.SYNOPSIS
Writes a named variable in humanized form.

.DESCRIPTION
Long description

.PARAMETER variableName
Parameter description

.PARAMETER singularLabel
Parameter description

.PARAMETER pluralLabel
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
Function Write-Count ([string]$variableName = $null, [string]$singularLabel, [string]$pluralLabel = $null) {
    $ct = ""

    if ($null -ne $variableName -and -not [string]::IsNullOrWhiteSpace($variableName)) {
        
        $ct+= $variableName.Humanize() + ": "
        $number = Get-Variable -Name $variableName -Scope Global -Value
        $includeCount = $true
    }


    if ($includeCount) {
        $ct+= $number.ToString() + " "
    }   

    if ($number -eq 1) {return ($ct + $singularLabel)}
    If ([String]::IsNullOrEmpty($pluralLabel)) {
        $LastCharacter = Right $singularLabel
        $Last2Characters = Right $singularLabel 2
        $SecondLastCharacter = Left $Last2Characters # Concise. Dont repit yourself.

        $Irregulars     = @{Man = 'Men'; Foot='Feet';Mouse='Mice';Person='People';Child='Children';'Goose'='Geese';Ox='Oxen';Woman='Women';Genus='Genera';Index='Indices';Datum='Data'}
        $NonCount= @('Moose', 'Fish', 'Species', 'Deer', 'Aircraft', 'Series', 'Salmon', 'Trout', 'Swine', 'Sheep')
        $OnlyS = @('photo', 'halo', 'piano')                                                                                                                
        $ExceptionsToFE = @('chef', 'roof')      
           
        if ($singularLabel -in $NonCount) {
            $plurallabel = $singularLabel 
        }                                                                        
        elseif ($singularLabel -in $Irregulars.Keys) {
            $plurallabel = $Irregulars[$singularLabel]
        }
        elseif ($singularLabel -in $OnlyS -or $singularLabel -in $ExceptionsToFE) {
            $plurallabel = $singularLabel + 's'
        }
        elseif ($LastCharacter -in @('s', 'ss', 'ch', 'x', 'sh', 'o', 'z') -or $Last2Characters -in @('s', 'ss', 'ch', 'x', 'sh', 'o', 'z')) { 
            $pluralLabel = $singularLabel + 'es'
        }  
        elseif ($Last2Characters -in @('f', 'fe')) { 
            $pluralLabel = $singularLabel.TrimEnd($Last2Characters) + 'ves' # Wife => Wives
        }  
        elseif ($LastCharacter -in @('f', 'fe')) { 
            $pluralLabel = $singularLabel.TrimEnd($LastCharacter) + 'ves'   # Calf => Calves
        }  
        elseif ($Last2Characters -in @('us')) {  
            $pluralLabel = $singularLabel.TrimEnd($Last2Characters) + 'i'   # Cactus => Cacti
        }  
        elseif ($Last2Characters -in @('is')) {  
            $pluralLabel = $singularLabel.TrimEnd($Last2Characters) + 'es'   # Analysis => analyses
        }  
        elseif ($Last2Characters -in @('on')) {  
            $pluralLabel = $singularLabel.TrimEnd($Last2Characters) + 'a'   # Phenomenon => Phenomena
        }  
        elseif ($LastCharacter -in @('y') -and $SecondLastCharacter -notin @('a','e','i','o','u')) { 
            $pluralLabel = $singularLabel.TrimEnd($LastCharacter) + 'ies' # City => Cities
        }  
        else {
            $pluralLabel = $singularLabel + 's'                             # Cat => Cats
        }
    }   

    if ($number -ge 2 -or $number -eq 0) { return ($ct + $pluralLabel)}
    return ($ct + $singularLabel)
}   

Function NullIf([string]$val, [string]$ifthis = '') {
    if ($null -eq $val -or $val.Trim() -eq $ifthis) {return $null}
    return $val
}                        

Function TrimToMillseconds([datetime]$date) # Format only for PowerShell! Not Postgres!
{
    # Only way I know to flush micro AND nanoseconds is to convert to string and back. And adding negative microseconds back leaves trailing Nanoseconds, which have no function to clear.  Can't add negative Nanoseconds.
    [DateTime]::ParseExact($date.ToString("yyyy-MM-dd hh:mm:ss.fff"), "yyyy-MM-dd hh:mm:ss.fff", $null)
}                                

Function TrimToMicroseconds([datetime]$date) # Format only for PowerShell! Not Postgres!
{
    # Only way I know to flush micro AND nanoseconds is to convert to string and back. And adding negative microseconds back leaves trailing Nanoseconds, which have no function to clear.  Can't add negative Nanoseconds.
    [DateTime]::ParseExact($date.ToString("yyyy-MM-dd HH:mm:ss.ffffff"), "yyyy-MM-dd HH:mm:ss.ffffff", $null)
}                                

<#
.SYNOPSIS
Move identically-named properties between objects.

.DESCRIPTION
We also have to test if they exist first.

.PARAMETER targetob
Parameter description

.PARAMETER sourceob
Parameter description

.PARAMETER prop
Parameter description

.EXAMPLE
Fill-Property $triggerDef $taskTrigger.CalendarTrigger.Repetition 'Duration'
Fill-Property $triggerDef $taskTrigger.CalendarTrigger.Repetition # Not implemented: Would move over all properties

.NOTES
All types are string types :)
#>
Function Fill-Property ($targetob, $sourceob, $prop) {
    # TODO: Add property if not found.
    # TODO: take in an array of properties all at once!!!!
    # IDEA: Could just move all properties over???
    $propAlreadyInTarget = @($targetob.PSObject.Properties|Where Name -eq "$prop").Count
                                
    if (-not $propAlreadyInTarget) {
        $targetob | Add-Member -MemberType NoteProperty -Name $prop -Value ''
    }
    
    if ($sourceob -is [String] -or $sourceob -is [Int32] -or $sourceob -is [datetime]) {
        $targetob.$prop = $sourceob.ToString()
    }                             
    else {
        $targetob.$prop = (if(@($sourceob.PSObject.Properties.Name -eq "$prop").Count -eq 1) {$sourceob.$prop } else { ''})
    }
}

Function Get-Property ($sourceob, $prop) {
    (If(@($sourceob.PSObject.Properties|Where Name -eq "$prop").Count -eq 1) { $sourceob.$prop } else {''})
}

Function Has-Property ($sourceob, $prop) {
    return @($sourceob.PSObject.Properties|Where Name -eq "$prop").Count -eq 1
}

<#
.SYNOPSIS
Execute any actions standard across all scripts in this folder.

.DESCRIPTION
Long description

.EXAMPLE
An example

.NOTES
General notes
#>
Function main_for_dot_include_standard_header() {
    [Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingCmdletAliases', '')]
    param()
                            
    # Make sure the log folder is there

    $null = New-Item -Path D:\qt_projects\filmcab\simplified\_log -ItemType Directory -ErrorAction Ignore
    # https://adamtheautomator.com/powershell-logging-2/

    Enable-PSScriptBlockLogging # Event Type Id = 4104
    
    #Start-Log

    # Test: Format-Plural 'Directory' 2
    # Test: Format-Plural 'Second' 1 -includeCount

    # Hide these variables inside here. Why? So that callers can update this script instead of adding hacks to their scripts, like "if driver -eq then do this." Centralize my hacks.

    $MyOdbcDatabaseDriver    = "PostgreSQL Unicode(x64)"
    $MyDatabaseServer        = "localhost";
    $MyDatabaseServerPort    = "5432";
    $MyDatabaseName          = "filmcab";
    $MyDatabaseUserName      = "filmcab_superuser";
    $MyDatabaseUsersPassword = "filmcab_superuser"  # Hmmmm. Will I ever lock down a database securely?  Is my ass white?

    # Options from https://odbc.postgresql.org/docs/config-opt.html
    # https://odbc.postgresql.org/docs/config.html                                                     
    # Display Optional Error Message: Display optional(detail, hint, statement position etc) error messages.
    <#
    Parse Statements: Tell the driver how to gather the information about result columns of queries, if the application requests that information before executing the query. See also ServerSide Prepare options.
    The driver checks this option first. If disabled then it checks the Server Side Prepare option.
    If this option is enabled, the driver will parse an SQL query statement to identify the columns and tables and gather statistics about them such as precision, nullability, aliases, etc. It then reports this information in SQLDescribeCol, SQLColAttributes, and SQLNumResultCols.
    When this option is disabled (the default), the query is sent to the server to be parsed and described. If the parser can not deal with a column (because it is a function or expression, etc.), it will fall back to describing the statement in the server. The parser is fairly sophisticated and can handle many things such as column and table aliases, quoted identifiers, literals, joins, cross-products, etc. It can correctly identify a function or expression column, regardless of the complexity, but it does not attempt to determine the data type or precision of these columns.
    #>     
    ############# WARNING: DO NOT INCLUDE SPACES AROUND "DRIVER={"  WILL THROW Error Record= Exception calling "Open" with "0" argument(s): "ERROR [IM002] [Microsoft][ODBC Driver Manager] Data source name not found and no default driver specified"
    ############# WARMOMG" NO SPACES ANYWHERE!!!!!!!!!!!!!!!!!!! "0" argument(s): "ERROR [08001] connection to server at "localhost" (::1), port 5432 failed: FATAL:  database " filmcab" does not exist
    $DatabaseConnectionString = "
    Driver={$MyOdbcDatabaseDriver};
    Servername=$MyDatabaseServer;
    Port=$MyDatabaseServerPort;
    Database=$MyDatabaseName;
    Username=$MyDatabaseUserName;
    Password=$MyDatabaseUsersPassword;
    Parse=True;
    OptionalErrors=True;
    BoolsAsChar=False;
    ";                    
    # The above, if any invalid syntax, will break when ConnectionString is set, not on Open, with:Exception setting "ConnectionString": "Format of the initialization string does not conform to specification starting at index 194."
    $Script:DatabaseConnection= New-Object System.Data.Odbc.OdbcConnection; # Probably useful to expose to caller.
    $Script:DatabaseConnection.ConnectionString = $DatabaseConnectionString               
    $Script:DatabaseConnection.ConnectionTimeout = 10
    
    # https://www.sqlskills.com/blogs/jonathan/capturing-infomessage-output-print-raiserror-from-sql-server-using-powershell/
    $informationalmessagehandler = [System.Data.Odbc.OdbcInfoMessageEventHandler] {param($sender, $event) Write-Host $event.Message }; 
    $Script:DatabaseConnection.add_InfoMessage($informationalmessagehandler) # WARNING: add_InfoMessage will not show up anywere in autocomplete.
    <#
        StateChange event
        Disposed Event
        ChangeDatabase
        CreateBatch
        CanCreateBatch                              
        Site
        Container
        Database, DataSource, Driver, State, ServerVersion
    #>
    # Rather than cloning this code everywhere, do it once.  The dot includer may not be using a database, but for now, (me) I'm only ever connecting to one database locally.
    # Granted, it assumes the dot includer wants any data connection
    $Script:AttemptedToConnectToDatabase = $false
    $Script:DatabaseConnectionIsOpen = $false
    try {
        $Script:DatabaseConnection.Open();
        $Script:DatabaseConnectionIsOpen = $true;
    } catch {
        Show-Error -exitcode 3 -DontExit # dot includer can decide if having no db connection is bad or not.
        $Script:DatabaseConnectionIsOpen = $false;
    }               
    $Script:AttemptedToConnectToDatabase = $true

    if ($DatabaseConnectionIsOpen) {                                                                   
        $Script:DatabaseCommand = [System.Data.Odbc.OdbcCommand]$DatabaseConnection.CreateCommand() # Must be visible to including script.
        $Script:DatabaseCommand.CommandTimeout = 0
        $Script:DBReaderCommand = [System.Data.Odbc.OdbcCommand]$DatabaseConnection.CreateCommand() # Must be visible to including script.
        $Script:DBReaderCommand.CommandTimeout = 0
        $Script:DBReaderCommand.CommandText = 'Select 1' # Can't instantiate a reader without a query.
        $Script:reader = [System.Data.Odbc.OdbcDataReader]$Script:DBReaderCommand.ExecuteReader()
        # PostgreSql specific settings, also specific to filmcab, and the simplified effort.
        Invoke-Sql "SET application_name to '$($Script:ScriptName)'" > $null
        Invoke-Sql 'SET search_path = simplified, "$user", public' > $null      # I'm in the simplified folder. So just set this here.

        #Test $searchPathCursor = Out-SqlToArray 'SELECT search_path FROM search_paths ORDER BY search_path_id'

    }

    Start-Log
}

main_for_dot_include_standard_header # So as not to collide with dot includer
                                  
# If we don't see this in log, then it broke.
Log-Line "Exiting standard_header"
<#
    Put in profile? No, I want it to be part of the codebase. Else any idiot using this code will be in the lurch.
    Rename to "standard_include_header"? But leave it as a cut&paste copy into app folders? Makes git easier. Or we make a module. Hmmmmmmm.
#>                                                                                                                

# Seems to close the popup console window almost immediately if you're calling from Windows Task Scheduler.

add-type -name user32 -namespace win32 -memberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
$consoleHandle = (get-process -id $pid).mainWindowHandle
[void][win32.user32]::showWindow($consoleHandle, 0)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$scriptTimer = [Diagnostics.Stopwatch]::StartNew()   # Host to use: $scriptTimer.Elapsed.TotalSeconds                  

# This needs parameterization, obviously.  Don't steal my password!

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
                                                                                        
<#
.SYNOPSIS
Mostly just to reduce caller bloat.  There's no $DBCmd.ExecuteNonQuery("Select 1") like there is in C#. And I don't think Powershell supports extended functions.

.DESCRIPTION                                                                                                          
Also captures as much error detail as it can. Forces a stoppage even if ErrorAction is not Stop.  That's probably bad.

.PARAMETER sql
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Invoke-Sql ($sql) {
    $DBCmd.CommandText = $sql
    try {

        [void] $DBCmd.ExecuteNonQuery();
    } catch {
        Write-Error $sql
        Write-Error "Message: $($_.Exception.Message)"
        Write-Error "StackTrace: $($_.Exception.StackTrace)"
        Write-Error "LoaderExceptions: $($_.Exception.LoaderExceptions)"
        exit(1);
    }
}

<#
.SYNOPSIS
Getting a value from a DbDataReader record is a tad more typing, and remembering than I like.

.DESCRIPTION
I wanted to get a column value either by it's ordinal # or it's column name. And, if it happens to be DBNull, pretty please just return a $null?  Is that rally hard?

.PARAMETER reader
Parameter description

.PARAMETER ordinal
Either an integer or a string. I suppose if you send a string ordinal over, it'll crash.

.EXAMPLE
An example

.NOTES
General notes
#>
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
           
<#
.SYNOPSIS
Looked for my perfect logging tool. Made one myself. All the githubs I looked at were a bit off for my needs.  Easy-Peezy with buttloads of detail is what I want.

.DESCRIPTION
My goal was to make it easy for the caller. Least number of parameters you have to send. So 'Log' is a verb.  Not 'Write-LogInfo", "Write-LogError", etc.
Requirement: Call Start-Log, with no params if you like. It captures as much as it can, regardless of the performance.

.EXAMPLE
Start-Log

.NOTES
The inevitable always happens. Hence inevitable. You don't wish you have gooder logging until your production system fails, the original developer was hit by a bus, and you have no idea what happened.
You start stuffing debugs everywhere. You reinvent the wheel.
For instance, say your app failed in the middle of the night. You assume it was called from the Windows Task Scheduler. ASS(outa)U(and)ME.  Maybe some crazy developer is running from his JAMS instance? ran it from the command line to try an emergency fix? Or kicked the task manually? Who kicked it?
The code to identify who and what started your code, it's not floating around the Internet. And it's not intuitive.
First, this code deals with the process id (PID) and traverses up the call heirarchy getting process detail. A lot can be determined from the process tree.
So I can tell:
    a) Code.exe: There are usually two of these in the tree if you're in VS Code.  This means it's running under a user in the editor, and may well be developing and changing the code. The output of this code is suspect. Often in dev, I hit a breakpoint and stop, and I don't continue through the rest of a loop.
       I set "Select * -First 1".  Will that count be helpful in stats?
    b) svchost.exe: If the CommandLine includes the text "schedule", We're running the Windows Task Scheduler. Now we have a complexity using Get-WinEvents to pull down which Task this Probably is. It's more a heuristic.
    c) "command line": I don't know what command string will be since I haven't tried it from the command line yet. posh.exe? cmd.exe? powershell.exe? Or from ISE, which has some oddities in behavior.

Get the "deets".  And start up the file in the default "..\log\[yyyymmdd][nameofapp].txt"  Not ".log" Write out a standard header line or two.
Can't stand all the other log libs and their complexity of targets, running in the background, etc. Though to catch abend, we probably need a background process.
#>

function Start-Log {
    [CmdletBinding()]
    param(
        # Override filename
    )

    New-Variable -Name ScriptRoot -Scope Script -Option ReadOnly -Value ([System.IO.Path]::GetDirectoryName($MyInvocation.PSCommandPath)) -Force
    $DSTTag = If ((Get-Date).IsDaylightSavingTime()) { "DST"} else { "No DST"}
    
    # Header 1
    Log-Line "Starting Log $(Get-Date) on $((Get-Date).DayOfWeek) $DSTTag in $((Get-Date).ToString('MMMM')), by Windows User <$($env:UserName)>" -Restart
    
    $PSVersion       = $PSVersionTable.PSVersion
    $PEdition        = $PSVersionTable.PSEdition
    $ScriptFullPath  = $MyInvocation.ScriptName
    $CommandOrigin   = $MyInvocation.CommandOrigin
    $CurrentFunction = $MyInvocation.MyCommand

    # Header 2
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

    if ($processtree.Count -ge 2) {
        $determinorOfCaller = $processtree[1]
        $partofcmdline = $determinorOfCaller.CommandLine.SubString(0,100)
     
        $allregisteredtasks = Import-Clixml -Path 'D:\qt_projects\filmcab\scheduled_tasks.xml' # Written periodically, sloooooow, especially if lots of tasks

        if ($null -eq $allregisteredtasks) {
            Log-Line "Error: cannot Get-ScheduledTask listing"
        }
        # Filter out disabled tasks as not eligible to have started this run

        #$allregisteredtasks = $allregisteredtasks | Where-Object State -ne Disabled
        $taskcount = $allregisteredtasks.Count
        $msg = ("Have $taskcount registered tasks")
        Log-Line $msg

        # Called from Windows Task Scheduler?

        if ($determinorOfCaller.Name -eq 'svchost.exe' -and $determinorOfCaller.CommandLine -ilike "*schedule*") {
            Log-Line "Called from Windows Task Scheduler"
            # Get a list of all defined tasks on this machine. We want to match our execute and arguments to 1 or more tasks' actions.
            # Hopefully we can guess at which one called us.

    
            $cmdlineofstartargs = $processtree[0].CommandLinewhi
            Log-Line "Scanning Get-ScheduledTasks"
            Log-Line $cmdlineofstartargs

            $possibleTaskCallingMe = $allregisteredtasks|Where-Object CommandLine -eq $cmdlineofstartargs
            if ($null -eq $possibleTaskCallingMe) {
                Log-Line "Null count"
            } else {
                Log-Line "Found some tasks"
            }
            $howmanyfound = $possibleTaskCallingMe.Count
           
            Log-Line "Finished Scanning"
            if ($null -eq $howmanyfound -or $howmanyfound -eq 0) {  #THIS LINE FAILS TO DO ANYTHING
                Log-Line "None found"
            } else {
                Log-Line "Some found"
            }
        
            Log-Line "Finished Scanning (2)"
            exit

            if ($howmanyfound -eq 1) {
                $TaskThatProbablyCalledUs = $possibleTaskCallingMe.Uri
                Log-Line "Task that probably called us is <$TaskThatProbablyCalledUs>"
            }
            elseif ($howmanyfound -ge 2) {
                Log-Line "Found $howmanyfound Tasks with same command line + arguments"
            }
            else {
                Log-Line "Unable to find any existing non-disabled tasks with this command line and arguments"
            }

            # TODO: Check history to see if that task just ran
            
        } elseif ($determinorOfCaller.Name -eq 'Code.exe') {
            Log-Line "Called whilest in Visual Code Editor"
        } else {
            Log-Line "Caller not detected"
            Log-Line ($determinorOfCaller.CommandLine)
            # Other callers could be the command line, JAMS, a bat file, another powershell script, that one at Simplot, the other one at Ivinci, the one at BofA
        }
    }
    else {
        Log-Line "gfgfasgadgads"
    }
    if (1 -eq 0) {
        $i = 0
        ForEach ($p in $processtree) {
            $partofcmdline = ""
            if ($p.CommandLine -eq $null) {
                $partofcmdline = "(empty)"
            } elseif ($p.CommandLine.Length -lt 100) {
                $partofcmdline = $p.CommandLine
            } else {
                $partofcmdline = $p.CommandLine.SubString(0,100)
            }
            Log-Line "$i $($p.Name), #$($p.ProcessId), $partofcmdline"
            $i++
        }
    }
}

<#
.SYNOPSIS
Hack reductive way to get annoying sid strings to something readable.  But, to keep the call simple, if a user id or name is passed in, it just returns that string.  Making life easier, one day at a time.

.DESCRIPTION
Long description

.PARAMETER sidString
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
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

<#
.SYNOPSIS
Our "trick" to get a running index in "Select "

.DESCRIPTION
Many arrays output by cmdlets are just an ordered list without any index. I had to join one list to another keyless list, and there's no way to do that without a slow ForEach.

.EXAMPLE
$idxfunctor = New-ArrayIndex
Get-Process| Select *, @{Name='idx'; Expression= { & $idxfunctor}}

.NOTES
General notes
#>
Function New-ArrayIndex {
    $index = 0;
    {
        $script:index+= 1
        $index
    }.GetNewClosure()
}                    

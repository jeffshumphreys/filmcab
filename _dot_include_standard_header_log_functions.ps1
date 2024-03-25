<#
 #    FilmCab Daily morning batch run process: First do inclusion from _dot_include_standard_header
 #    Included from from _dot_include_standard_header
 #    Status: In Production, but not all functions implemented.
 #    ###### Fri Mar 22 16:16:30 MDT 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #
 #    All logging to file functions. Also writes to host (terminal)
 #>                                                                                                

<#
.SYNOPSIS
Write a string line to file defined in Start-Log

.DESCRIPTION
Long description

.PARAMETER Text
Parameter description

.PARAMETER Restart
Passed down to Write-LogLineToFile, forget what for. Rebuild the file?

.EXAMPLE
An example

.NOTES
General notes
#>
function Log-Line {
    [CmdletBinding()]
    param(
        [Parameter(Position=1, Mandatory=$false)][string] $Text,
        [switch]$Restart,
        [switch]$NoNewLine
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
            if ($NoNewLine) {
                $HashArguments+= @{NoNewLine = $true}
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

    $DSTTag = If ((Get-Date).IsDaylightSavingTime()) { "DST"} else { "No DST"} # DST can seriously f-up ordering.
    
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
        } elseif ($determinorOfCaller.Name -eq 'Code - Insiders.exe') {
            Log-Line "Called whilest in Visual Code Editor (Preview)"
            $Script:Caller = 'Visual Code Editor'
        } elseif ($determinorOfCaller.CommandLine -ilike "cmd *") {  
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

Write-Host "Exiting standard_header (log functions)"
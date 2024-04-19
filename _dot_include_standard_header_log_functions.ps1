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
Log the end of a script so we can trace earliers point for last error log message, especially for unhandled exceptiond
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

<#
.SYNOPSIS
Start the log file, create and all Log-Lines go to this file.

.DESCRIPTION
Long description

.EXAMPLE
Start-Log # _dot_include_standard_header.ps1

.NOTES
General notes
#>
function Start-Log {
    [CmdletBinding()]
    param(
        [Switch]$TestScheduleDrivenTaskDetection
        # i.e., Override filename
    )

    # https://stackoverflow.com/questions/56551241/difference-between-a-runspace-and-external-request-in-powershell#56558837
        # Internal = The command was dispatched by the msh engine as a result of a dispatch request from an already running command.
        # Runspace = The command was submitted via a runspace.

    $Script:DSTTag = If ((Get-Date).IsDaylightSavingTime()) { "DST"} else { "No DST"} # DST can seriously f-up ordering.

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

    $Script:Caller = ''

    # HACK: Cannot test runs from scheduler since uh well were running from the scheduler and not the debugger
    if ($TestScheduleDrivenTaskDetection) {
        $Script:Caller = "Windows Task Scheduler"
        ## Override so that test_detect_who_starrted_scheduled_task.ps1 can simulate a scheduled run so we can debug!!!!
        $Script:ScriptNameWithoutExtension = $Script:PretendMyFileNameWithoutExtensionIs
    }
    elseif ($processtree.Count -ge 2) {
        $cmdlineofstartargs = $processtree[0].CommandLine
        Log-Line $cmdlineofstartargs
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

        } elseif ($determinorOfCaller.Name -eq 'Code.exe') {
            Log-Line "Called whilest in Visual Code Editor"
            $Script:Caller = 'Visual Code Editor'

        } elseif ($determinorOfCaller.Name -eq 'Code - Insiders.exe') {
            Log-Line "Called whilest in Visual Code Editor (Preview)"
            $Script:Caller = 'Visual Code Editor'

        } elseif ($determinorOfCaller.CommandLine -ilike "cmd *") {
            Log-Line "Called whilest in Command Line"
            $Script:Caller = 'Command Line'

        } else {
            Log-Line "Caller not deciphered"
            $Script:Caller = ($determinorOfCaller.CommandLine)
            Log-Line ($determinorOfCaller.CommandLine)
            # Other callers could be the command line, JAMS, a bat file, another powershell script, that one at Simplot, the other one at Ivinci, the one at BofA
        }
    }
    else {
        Log-Line "No Idea of what caller is"
        $Script:Caller = 'ProcessTree Count less than 2'
    }

    if ($Script:Caller -eq 'Windows Task Scheduler') {
        # Get a list of all defined tasks on this machine. We want to match our execute and arguments to 1 or more tasks' actions.
            # Hopefully we can guess at which one called us.

        $reader = WhileReadSql "
            SELECT
                scheduled_task_root_directory
            ,   scheduled_task_run_set_name
            FROM
                scheduled_tasks_ext_v
            WHERE
                scheduled_task_name = '$($ScriptNameWithoutExtension)'" -prereadfirstrow

        $fullTaskPath = "?"
        $sep = "\"
        # For some reason , first "row" is a boolean, and is $false if no rows found, even though 2 rows are always returned.
        if ($reader[0] -and $null -ne $Script:scheduled_task_run_set_name) {
            $scheduled_task_root_directory = "\$Script:scheduled_task_root_directory"
            $scheduled_task_run_set_name = "\$Script:scheduled_task_run_set_name"
            $fullTaskPath = "$scheduled_task_root_directory$scheduled_task_run_set_name$sep$ScriptNameWithoutExtension"
        } else {
            $scheduled_task_run_set_name = ""
            $scheduled_task_root_directory = ""
            $fullTaskPath = (Get-ScheduledTask -TaskName $ScriptNameWithoutExtension|Select URI).URI
        }


        $xmlfilter = @"
            <QueryList>
            <Query Id="0">
            <Select Path="Microsoft-Windows-TaskScheduler/Operational">*[EventData[Data[@Name="TaskName"]="$fullTaskPath"]]
            </Select>
            </Query>
            </QueryList>
"@
        # Get-WinEvent -ComputerName DS1 -LogName Security -FilterXPath "*[System[EventID=4670 and TimeCreated[timediff(@SystemTime) <= 86400000]] and EventData[Data[@Name='ObjectType']='File']]"  | fl
        Log-Line "Attempting to get triggering event for $($Script:ScriptNameWithoutExtension) for run set name $scheduled_task_run_set_name in root directory $scheduled_task_root_directory"
        <#
            If from task scheduler but triggered by user, it will be:
            Message = Task Scheduler launched "{1104927b-4d03-4388-b221-58ba3f2c3abd}"  instance of task "\FilmCab\schedule maintenance\pull_scheduled_task_definitions"  for user "jeffs" .
            TaskDisplayName = Task triggered by user
            TimeCreated = 3/25/2024 7:30:46 PM
            RecordId = 196741
            ProcessId =	1932
            ThreadId =	17308

            If from scheduled calendar, (Warning: not last event, but a few back)
            Message = Task Scheduler launched "{a9ea3af0-60a2-42e0-b0e2-a6325e71c252}"  instance of task "\FilmCab\schedule maintenance\pull_scheduled_task_definitions" due to a time trigger condition.
            TaskDisplayName = Task triggered on scheduler
            Time... 3/25/2024 12:13:21 AM	195195	1932	4408

        #>

        <#
            A chain of events is all linked by either ThreadId and/or ActivityId.
            1) Grab all recordids where ActivityId same, min and max.
            2) Grab their threadIds. any record ids between min and max and have no activity id, but share a threadid, include that in activity id.
        #>

        $lastEventWhileRunningIs = Get-WinEvent -FilterXml $xmlfilter -MaxEvents 100 -ErrorAction Ignore|Select Message, TaskDisplayName, TimeCreated, RecordId, ActivityId, ThreadId, ProcessId,
        @{Name='ResultCode'; Expression = {
                if ($_.Id -in @(203,716,201,715,714,305,713,316,315,717,202,718,105,205,104,712,103,306,204,101,307,311,331,403,711,702,126,303,703,130,704,705,706,707,708,709,413,412,113,146,410,408,401,115,116,710,404,409,151,150,406,407,148,405,701)) {
                              if ($_.Id -in @(716,715,717,718,712,702,703,704,705,413,412,410,408,115,710,409,406,407,405,701) -and $_.Version -eq 0) {
                $_.Properties[0].Value
                }          elseif ($_.Id -in @(714,713,316,315,105,205,306,204,307,403,711,126,130,707,709,113,146,401,116,404,150,148) -and $_.Version -eq 0) {
                $_.Properties[1].Value
                }          elseif ($_.Id -in @(305,104,101,331,303,706,708,151) -and $_.Version -eq 0) {
                $_.Properties[2].Value
                }          elseif ($_.Id -in @(203,202,103,311) -and $_.Version -eq 0) {
                $_.Properties[3].Value
                }          elseif ($_.Id -in @(201,202) -and $_.Version -eq 1) {
                $_.Properties[3].Value
                }          elseif ($_.Id -in @(201) -and $_.Version -eq 2) {
                $_.Properties[3].Value
                }
                }
             }},
            @{Name='UserContext'; Expression = {
                if ($_.Id -in @(110,100,101,106,330,102,103)) {
                              if ($_.Id -in @(100,101,106,102) -and $_.Version -eq 0) {
                $_.Properties[1].Value
                }          elseif ($_.Id -in @(110,330,103) -and $_.Version -eq 0) {
                $_.Properties[2].Value
                }
                }
             }},
            @{Name='UserName'; Expression = {
                if ($_.Id -in @(124,134,119,133,141,121,142,104,122,120,123,125,332,140)) {
                              if ($_.Id -in @(104) -and $_.Version -eq 0) {
                $_.Properties[0].Value
                }          elseif ($_.Id -in @(124,134,119,141,121,142,122,120,123,125,332,140) -and $_.Version -eq 0) {
                $_.Properties[1].Value
                }          elseif ($_.Id -in @(133) -and $_.Version -eq 0) {
                $_.Properties[2].Value
                }
                }
             }},
        ID|
        Where-Object {$_.ID -in
            107, <# Triggered on Scheduler (Message ends with "due to a time trigger condition")#>
            108, <# Triggered on Event #>
            109, <# Triggered by Registration #>
            110, <# Triggered by User #>
            117, <# Triggered on Idle #>
            118, <# Triggered by Computer startup #>
            119, <# Triggered on logon #>
            120, <# Triggered on local console connect#>
            121, <# Triggered on #>
            122, <# Triggered on #>
            123, <# Triggered on #>
            124, <# Triggered on Locking workstation #>
            125, <# Triggered on #>
            126, <# Triggered on #>
            127, <# Restarted On failure (Rejected) #>
            145  <# Triggered by coming out of suspend mode #>
        }|Select -First 1

        if ($null -ne $lastEventWhileRunningIs) {
            # get definition

            $Script:WindowsSchedulerTaskTriggeringEvent = $lastEventWhileRunningIs
            # If scheduler, which calendar trigger? Details of trigger?
            # If event, what are details of event trigger?
            # Pull task definition?????
            Write-AllPlaces "Got following event back: $($Script:WindowsSchedulerTaskTriggeringEvent.TaskDisplayName)"
            $timeTaskTriggered = $Script:WindowsSchedulerTaskTriggeringEvent.TimeCreated
            $taskActivityUUID  = $Script:WindowsSchedulerTaskTriggeringEvent.ActivityId
            $taskThreadId      = $Script:WindowsSchedulerTaskTriggeringEvent.ThreadId
            $taskProcessId     = $Script:WindowsSchedulerTaskTriggeringEvent.ProcessId
            $taskEventRecordId = $Script:WindowsSchedulerTaskTriggeringEvent.RecordId

            # Not currently using, just wanted to remember how to get this detail.  Good to know if last run failed, when it's expected to run next. Does Last Run Time mean now or previous?
            $scheduledTaskRunDetails = Get-ScheduledTaskInfo -TaskName $fullTaskPath
            # https://learn.microsoft.com/en-us/windows/win32/taskschd/registeredtask
            # Stop()
            # Run, RunEx
            # GetRunTimes
            # GetInstances
            # LastRunTime
            # LastTaskResult
            # NextRunTime                     Event triggered tasks won't have a next will they?
            # State
            # XML
            # NumberOfMissedRuns Gets the number of times the registered task has missed a scheduled run.
            $targetTable           = "batch_run_sessions"
            $targetTableIdCol      = "batch_run_session_id"
            $targetTableIdColValue = $Script:active_batch_run_session_id

            if ($Script:ScriptNameWithoutExtension -ne '_start_new_batch_run_session') {
                $targetTable           = "batch_run_session_tasks"
                $targetTableIdCol      = "batch_run_session_task_id"
                # Doesn't really get created until Much later
                if (-not(Test-Path Script:active_batch_run_session_task_id) -or $null -eq $Script:active_batch_run_session_task_id -or $Script:active_batch_run_session_task_id -eq -1) {
                    $Script:active_batch_run_session_task_id = Create-BatchRunSessionTaskEntry -batch_run_session_id $Script:active_batch_run_session_id -script_name $ScriptName
                }
                $targetTableIdColValue = $Script:active_batch_run_session_task_id
            }

            if ($true) {
                Set-StrictMode -Off # Critical to avoid not found errors on following attributes
                $triggers = Get-ScheduledTask -TaskName $ScriptNameWithoutExtension|
                SELECT -expandProperty Triggers|
                % {
                    $trigger = [PSCustomObject]@{
                        Id                          = $_.Id # Never set :(
                        TriggerType                 = (($_.pstypenames[0])-split '/')[-1]
                        TaskName                    = $_.TaskName
                        Enabled                     = $_.Enabled
                        StartBoundary               = $_.StartBoundary
                        EndBoundary                 = $_.EndBoundary
                        DaysInterval                = $_.DaysInterval
                        WeeksInterval               = $_.WeeksInterval
                        Weeks                       = $_.Weeks
                        DaysOfWeek                  = $_.DaysOfWeek # uint16
                        Months                      = $_.Months
                        MonthOfYear                 = $_.MonthOfYear
                        DaysOfMonth                 = $_.DaysOfMonth
                        RunOnLastWeekOfMonth        = $_.RunOnLastWeekOfMonth
                        WeeksOfMonth                = $_.WeeksOfMonth
                        ExecutionTimeLimit          = $_.ExecutionTimeLimit
                        RepetitionInterval          = $_.Repetition.Interval # MSFT_TaskRepetitionPattern    P<days>DT<hours>H<minutes>M<seconds>S
                        RepetitionDuration          = $_.Repetition.Duration
                        RepetitionStopAtDurationEnd = $_.Repetition.Duration            # PT4H
                        RandomDelay                 = $_.RandomDelay
                        Delay                       = $_.Delay                                          # PT15S
                        UserId                      = $_.UserId
                        StateChange                 = $_.StateChange
                        Subscription                = $_.Subscription
                        ValueQueries                = $_.ValueQueries
                        MatchingElement             = $_.MatchingElement
                        PeriodOfOccurrence          = $_.PeriodOfOccurrence
                        NumberOfOccurrences         = $_.NumberOfOccurrences
                    }
                    $trigger # Dump it to our triggers array
                }|Select *|Where Enabled
                Set-StrictMode -Version Latest
        # else target = batch_run_session_tasks
                $triggerType = $Script:WindowsSchedulerTaskTriggeringEvent.TaskDisplayName
                $triggerId = $Script:WindowsSchedulerTaskTriggeringEvent.Id

                $triggered_by_login = ''

                switch ($Script:WindowsSchedulerTaskTriggeringEvent.TaskDisplayName) {
                    ##############################################################################################################################################################################################################
                    "Task triggered by user" {         # If a non-lead task triggered by user, then do not attach it to whatever random floating id in active_run_session.
                        $triggerType = 'user'
                        $triggered_by_login = $lastEventWhileRunningIs.UserContext
                    }
                    ##############################################################################################################################################################################################################
                    "Task triggered on scheduler" {
                        $triggerType = 'schedule'
                        $triggers = $triggers|Where TriggerType -match 'Daily|Weekly|Monthly|Time'
                        #TODO: If more than one, which one is closest as to trigger time? Which one was for today? This week? Was there a random delay? Month??  Ugh.
                        $triggersWithSameStartTime = @()

                        # Loop all we found and pull out ones with nearly same schedule time and actually started time

                        $triggers| % {
                            if ($null -ne $_.StartBoundary) {
                                $scheduledStartTime = [DateTime]$_.StartBoundary
                                $nearnessOfRunStartToScheduledStart = $timeTaskTriggered.TimeOfDay - $scheduledStartTime.TimeOfDay
                                if ($nearnessOfRunStartToScheduledStart.TotalSeconds -in 0..2 ) {
                                    if ($null -ne $_.DaysOfWeek) {

                                    }
                                    if ($null -ne $_.DaysOfMonth) {

                                    }
                                    if ($null -ne $_.WeeksOfMonth) {

                                    }
                                    if ($null -ne $_.RunOnLastWeekOfMonth) {

                                    }
                                    if ($null -ne $_.MonthOfYear) {
                                        #if ($scheduledStartTime.Month -eq $timeTaskTriggered.Month)
                                    }
                                    # WARNING: Needs to check DaysOfWeek set and if it would include the day of week. Same for WeeksOfMonth, MonthsOfYear
                                    # This is the event? unless two are set

                                    $triggersWithSameStartTime+= $_
                                } else {
                                    # are we in the random delay period?
                                    # are we a repetition?
                                    # YIKES, the complexity - but only if more than one time trigger.
                                }
                            }
                        }

                        if ($triggersWithSameStartTime.Count -eq 0) {
                            # Ooops! How started with schedule? RandomDelay?
                        }
                        if ($triggersWithSameStartTime.Count -gt 1) {
                            # Hmmm, possible issue?
                        }
                        else {
                            # Just the one.  We need the "ID" or at least an index of which trigger it was.  Somehow categorize which trigger definition it is.
                        }

                        # Lots of parsing to figure out time if it's a complex trigger def
                        # Get time, match to task trigger definition
                        # Was there a delay, or randomdelay?
                        # If there was a repetition interval, does that match time?
                        # Check settings for Retry specifications
                    }
                    ##############################################################################################################################################################################################################
                    "Task triggered on event" {
                        $triggers = $triggers|Where TriggerType -match 'Event|Idle'
                        $triggerType = "event"
                        if ($triggers.Count -eq 1 -and $triggers[0].TriggerType -eq 'MSFT_TaskIdleTrigger') {
                            $triggerType = "Idle"
                        }
                            # Get time, match to task trigger definition
                        # match Event or Idle. Manually test since MSFT_TaskIdleTrigger comes in log as an event trigger.
                        # Which Event if there are several???
                    }
                    ##############################################################################################################################################################################################################
                    "Task triggered on logon" {
                        $triggers = $triggers|Where TriggerType -match 'Logon'
                        if ($triggers.Count -eq 1 -and $null -ne $triggers[0].UserId) {
                            $triggered_by_login = $triggers[0].UserId
                        }
                        # match Logon
                        $triggerType = 'logon'
                    }
                }
                Invoke-Sql "
                    UPDATE
                        $targetTable
                    SET
                        trigger_type       = '$triggerType',
                        triggered_by_login = '$triggered_by_login',
                        thread_id          = $taskThreadId,
                        process_id         = $taskProcessId,
                        activity_uuid      = '$taskActivityUUID',
                        trigger_id         = '$triggerId'
                    WHERE
                        $targetTableIdCol = $targetTableIdColValue"
            }

            $lastEventWhileRunningIs|Select *|ForEach-Object {
                Write-AllPlaces $_
            }
        } else {
            Write-AllPlaces "No events found for task <$ScriptNameWithoutExtension>"
        }

        Log-Line "Finished Scanning for caller details"
    }
}

Write-Host "Exiting standard_header (log functions)"
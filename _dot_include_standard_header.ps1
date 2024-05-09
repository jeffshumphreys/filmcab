Import-Module PowerShellHumanizer
Import-Module DellBIOSProvider

. .\_dot_include_standard_header_sql_functions.ps1

Function main_dot_include_standard_header() {
    DisplayTimePassed ("Start")

    # Attempt to clean up memory detritus when rerunning in interactive mode.

    Remove-Variable batch_run_session_task_id, batch_run_session_id, Caller, ScriptName, LogDirectory -Scope Script -ErrorAction SilentlyContinue

    # Settings

    Set-StrictMode -Version Latest
    $ErrorActionPreference                                      = 'Stop'
    Set-PSDebug -Off                                                                             # When the Trace parameter has a value of 1, each line of script is traced as it runs. When the parameter has a value of 2, variable assignments, function calls
    [Net.ServicePointManager]::SecurityProtocol                 = [Net.SecurityProtocolType]::Tls12;    # More to do with PowerShellGet issues, not Imports.
    $Script:OutputEncoding                                      = [System.Text.Encoding]::UTF8
    $Script:scriptTimer                                         = [Diagnostics.Stopwatch]::StartNew()
    $Script:SnapshotMasterRunDate                               = Get-Date                              # Capture "One timestamp to rule them all". Everything should be marked off this instead of Get-Date unless it really wants to know NOW

    # Constants

    $Script:DEFAULT_POWERSHELL_TIMESTAMP_FORMAT                 = "yyyy-MM-dd HH:mm:ss.ffffff zzz"      # 2024-01-22 05:37:00.450241 -07:00    Restrict to ONLY 6 places (microseconds). Windows has 7 places, which won't match with Postgres's 6, which then causes mismatches between timestamps in database with timestamps on files. They were always off by 4 100ths nanoseconds, and caused massive thrashing.
    $Script:DEFAULT_POSTGRES_TIMESTAMP_FORMAT                   = "yyyy-mm-dd hh24:mi:ss.us tzh:tzm"    # 2024-01-22 05:36:46.489043 -07:00
    $Script:DEFAULT_WINDOWS_TASK_SCHEDULER_TIMESTAMP_FORMAT_XML = 'yyyy-MM-ddTHH:mm:ss.fffffff'
    $Script:pretest_assuming_true                               = $true
    $Script:pretest_assuming_false                              = $false

    # Gettings

    $Script:DSTTag                                              = If (($Script:SnapshotMasterRunDate).IsDaylightSavingTime()) { "DST"} else { "No DST"} # DST can seriously f-up measuring durations of tasks.
    $Script:LastDisplayedTimeElapsed                            = $Script:SnapshotMasterRunDate
    $Script:TpmStatus                                           = ((Get-ChildItem -Path "DellSmbios:\TPMSecurity\TpmSecurity"|Select CurrentValue).CurrentValue -eq 'Enabled')
    $Script:amRunningAsAdmin                                    = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    $Script:AreWeRunningInteractively                           = [Environment]::UserInteractive                 # Under ISE and Powershell console it returns true, as a scheduled task it returns false.
    $Script:MyComputerName                                      = $env:COMPUTERNAME
    $Script:OneDriveDirectory                                   = $env:OneDrive
    $Script:OSUserName                                          = $env:USERNAME
    $Script:OSUserFiles                                         = $env:USERPROFILE
    $Script:CurrentDebugSessionNo                               = $MyInvocation.HistoryId
    $Script:PSVersion                                           = $PSVersionTable.PSVersion                       # 7.5.0-preview.2
    $Script:CommandOrigin                                       = $MyInvocation.CommandOrigin                     # Internal
    $Script:CurrentFunction                                     = $MyInvocation.MyCommand                         # _dot_include_standard_header.v2.ps1
    $Script:InvokationName                                      = $MyInvocation.InvocationName                    # always "." when included or ran direct.
    $Script:ProjectRoot                                         = (Get-Location).Path                             # D:\qt_projects\filmcab. May be to do with WorkingDirectory setting in Windows Task Scheduler for Exec commands.
    $Script:ScriptRoot                                          = ([System.IO.Path]::GetDirectoryName($MyInvocation.PSCommandPath)) # directory of including file, where we want to build logs.
    if ($null -eq $Script:ScriptRoot) {
        $Script:ScriptRoot                                      = (Get-Item -Path $masterScriptPath).DirectoryName
    }

    $Script:MasterScriptPath                                    = $MyInvocation.ScriptName                        # This is null if you are running this dot include directly.
    if ([String]::IsNullOrEmpty($MasterScriptPath)) {
        $Script:MasterScriptPath                                = $MyInvocation.Line
    }
    $Script:MasterScriptPath                                    = if ($Script:MasterScriptPath.StartsWith(". .\")) { $Script:MasterScriptPath.Substring(2)} else {$Script:MasterScriptPath}
    $Script:MasterScriptPath                                    = if ($Script:MasterScriptPath.StartsWith(". '"))  { $Script:MasterScriptPath.Substring(2)} else {$Script:MasterScriptPath}
    $Script:MasterScriptPath                                    = $Script:MasterScriptPath.Trim("'")

    if (-not (Test-Path $Script:MasterScriptPath)) {
        throw "Path to master calling/including script not valid. $($Script:MasterScriptPath)"
    }

    $Script:FileTimeStampForParentScript              = (Get-Item -Path $Script:MasterScriptPath).LastWriteTime
    $Script:ScriptName                                = (Get-Item -Path $Script:MasterScriptPath).Name       # Unlike "BaseName" this includes the extension
    $Script:ScriptNameWithoutExtension                = (Get-Item -Path $Script:MasterScriptPath).BaseName   # Base name is nice for labelling and searching scheduler tasks

    # Get Settings en masse

    $Script:PathToConfig                              = $ProjectRoot + '\config.json'
    $Script:Config                                    = (Get-Content -Path $Script:PathToConfig | ConvertFrom-Json) # Will fail if not exist, which is the desired outcome.
    $Script:SUPER_SECRET_SQUIRREL                     = (Get-Content -Path ($ProjectRoot + '\SUPER_SECRET_SQUIRREL.json') | ConvertFrom-Json) # Too on the nose?

    # Build out logging infrastructure

    $Script:LogDirectory                              = "$Script:ScriptRoot\_log"
    New-Item -ItemType Directory -Force -Path $Script:LogDirectory|Out-Null
    $Script:LogFileName                               = $Script:ScriptName + '.log.txt'
    $Script:LogFilePath                               = $Script:LogDirectory + '\' + $Script:LogFileName

    # Settings 2nd pass after key gettings

    if ($amRunningAsAdmin) {
        $ExtendedScriptLoggingRegistryPath                      = 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
        if(-not (Test-Path $ExtendedScriptLoggingRegistryPath)) {
            New-Item $ExtendedScriptLoggingRegistryPath -Force | Out-Null
            New-ItemProperty $ExtendedScriptLoggingRegistryPath -Name "EnableScriptBlockLogging" -PropertyType Dword
            New-ItemProperty $ExtendedScriptLoggingRegistryPath -Name "EnableInvocationHeader" -PropertyType Dword
            New-ItemProperty $ExtendedScriptLoggingRegistryPath -Name "OutputDirectory" -PropertyType String
        }
        Set-ItemProperty $ExtendedScriptLoggingRegistryPath -Name "EnableScriptBlockLogging" -Value "1"
        Set-ItemProperty $ExtendedScriptLoggingRegistryPath -Name "EnableInvocationHeader" -Value "1"
        Set-ItemProperty $ExtendedScriptLoggingRegistryPath -Name "OutputDirectory" -Value $Script:LogDirectory
    }

    # Start logging

    Log-Line "Starting Log $($Script:SnapshotMasterRunDate) on $(($Script:SnapshotMasterRunDate).DayOfWeek) $($Script:DSTTag) in $(($Script:SnapshotMasterRunDate).ToString('MMMM')), by Windows User <$($env:UserName)>" -Restart
    Log-Line "`$ScriptFullPath: $Script:MasterScriptPath, `$PSVersion = $($Script:PSVersion), `$PSEdition = $($Script:PSEdition), `$CommandOrigin = $($Script:CommandOrigin), Current Function = $($Script:CurrentFunction)"

    $Script:TranscriptFileName                        = $Script:ScriptName + '.transcript.log.txt'
    $Script:TranscriptFilePath                        = $Script:LogDirectory + '\' + $Script:TranscriptFileName

    Remove-Item -Path $Script:TranscriptFilePath -Force -ErrorAction Ignore # Otherwise, in Core it will just keep appending. Bug? Or an issue when in VS Code?

    $tryToStartTranscriptAttempts                     = 0
    while ($tryToStartTranscriptAttempts -lt 3) {
        try {
            $tryToStartTranscriptAttempts++
            Start-Transcript -Path $Script:TranscriptFilePath -IncludeInvocationHeader
            break
        }
        catch [System.IO.IOException] {
            try { Stop-Transcript} catch {}
            Start-Sleep -Milliseconds 10.0
        }
    }

    $MyOdbcDatabaseDriver    = "$($Config.database_driver)"
    $MyDatabaseServer        = "$($Config.database_server_ip_address)";
    $MyDatabaseServerPort    = "$($Config.database_server_port)";
    $MyDatabaseName          = "$($Config.database)";
    $MyDatabaseUserName      = "$($Config.database_user)";
    $MyDatabaseUsersPassword = "$($Config.database_password)"
    $MyDatabaseSchema        = "$($Config.database_schema)"

    # https://odbc.postgresql.org/docs/config-opt.html

    # WARNING: Do not add spaces to connectionstring. Will fail to connect

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
        KeepaliveTime=30;
        KeepaliveInterval=40;
        MaxLongVarcharSize=8190;
        MaxVarcharSize=8190;
        "

    DisplayTimePassed ("Connecting to db...")

    $Script:DatabaseConnection                   = New-Object System.Data.Odbc.OdbcConnection
    $Script:DatabaseConnection.ConnectionString  = $DatabaseConnectionString
    $Script:DatabaseConnection.ConnectionTimeout = 10

    $informationalmessagehandler = [System.Data.Odbc.OdbcInfoMessageEventHandler] {param($sender, $event) Write-AllPlaces $event.Message }
    $Script:DatabaseConnection.add_InfoMessage($informationalmessagehandler)

    $Script:AttemptedToConnectToDatabase = $false
    $Script:DatabaseConnectionIsOpen     = $false
    try {
        $Script:DatabaseConnection.Open();
        $Script:DatabaseConnectionIsOpen = $true
    } catch {
        Show-Error -exitcode 3 -DontExit # dot includer can decide if having no db connection is bad or not.
        $Script:DatabaseConnectionIsOpen = $false
    }
    $Script:AttemptedToConnectToDatabase = $true

    DisplayTimePassed ("Connected to db")

    if ($Script:DatabaseConnectionIsOpen) {
        DisplayTimePassed ("Setting some session parameters...")
        Invoke-Sql "SET application_name to '$($Script:ScriptName)'"|Out-Null
        Invoke-Sql @"
            SET search_path = $MyDatabaseSchema, "`$user", public;
            /*  Set to support offload_published_directories_selecting_using_gui.ps1 when it 1) creates a transaction, 2) starts a massive file move op, and then 3) updates and commits the transaction.
                This fails if it times out, still moves the files, but all the files tracking info is lost.
                Note that I need all the SQL BEFORE the move files, since move files are not atomic and do not rollback.
            */
            SET SESSION idle_in_transaction_session_timeout = '60min';
"@|Out-Null
    }

    $Script:Caller                   = 'ndef'
            $scheduledTaskForProject = $pretest_assuming_false

    if (-not(Test-Path variable:Script:__DISABLE_DETECTING_SCHEDULED_TASK) -and -not $Script:AreWeRunningInteractively) { # Over-engineered. Blocks "TestScheduleDrivenTaskDetection"
        DisplayTimePassed ("Getting process tree...")
        $processtree = @()
        $process_enumerator = Get-CimInstance -Class Win32_Process -Filter "ProcessId = $PID"              # SLOW! Only want for scheduled tasks
        $processtree+= $process_enumerator
        $process_enumerator = Get-CimInstance -Class Win32_Process -Filter "ProcessId = $($process_enumerator.ParentProcessId)" # SLOW! Only want for scheduled tasks
        $processtree+= $process_enumerator

        DisplayTimePassed ("Finished getting process tree")

        if ((Test-Path variable:Script:TestScheduleDrivenTaskDetection) -and $Script:TestScheduleDrivenTaskDetection) {
            $Script:Caller      = "Windows Task Scheduler"
            $Script:ScriptNameWithoutExtension = $Script:PretendMyFileNameWithoutExtensionIs # Fail if missing
        } elseif ($processtree.Count -ge 2) {
            $determinorOfCaller = $processtree[1]
            if ($determinorOfCaller.Name -eq 'svchost.exe' -and $determinorOfCaller.CommandLine -ilike "*schedule*") {
                $Script:Caller  = 'Windows Task Scheduler'
            } elseif ($determinorOfCaller.Name -eq 'Code.exe') {
                $Script:Caller  = 'Visual Code Editor'
            } elseif ($determinorOfCaller.Name -eq 'Code - Insiders.exe') {
                $Script:Caller  = 'Visual Code Editor'
            } elseif ($determinorOfCaller.CommandLine -ilike "cmd *") {
                $Script:Caller  = 'Command Line'
            } else {
                $Script:Caller  = ($determinorOfCaller.CommandLine)
                Log-Line ($determinorOfCaller.CommandLine)
                # Other callers could be the command line, JAMS, a bat file, another powershell script, that one at Simplot, the other one at Ivinci, the one at BofA
            }
        } else {
            $processInfo = "n/a"
            if ($processtree.Count -eq 1) {
                $processInfo = $processtree[0].Name
            }
            Show-Error -message "Error: Unable to determine caller from processtree: $processInfo" -exitcode 6
        }

        DisplayTimePassed ("Determination of caller completed")

        if ($Script:Caller -eq 'Windows Task Scheduler') {
            $scheduledTaskForProject = $pretest_assuming_true

            DisplayTimePassed ("Getting task detail...")

            $getScheduledTaskDetailIfFound = WhileReadSql "
                SELECT
                    scheduled_task_root_directory
                ,   scheduled_task_run_set_name
                ,   script_position_in_lineup
                FROM
                    scheduled_tasks_ext_v
                WHERE
                    scheduled_task_name = '$($Script:ScriptNameWithoutExtension)'" -PreReadFirstRow

            $fullScheduledTaskPath = "?"

            if ($getScheduledTaskDetailIfFound[0] -and $null -ne $Script:scheduled_task_run_set_name) {
                $scheduled_task_root_directory = "\$Script:scheduled_task_root_directory"
                $scheduled_task_run_set_name   = "\$Script:scheduled_task_run_set_name"
                $fullScheduledTaskPath         = "$scheduled_task_root_directory$scheduled_task_run_set_name\$($Script:ScriptNameWithoutExtension)"
            } else {
                $scheduled_task_run_set_name   = ""
                $scheduled_task_root_directory = ""
                $fullScheduledTaskPath         = (Get-ScheduledTask -TaskName $Script:ScriptNameWithoutExtension|Select URI).URI
                $scheduledTaskForProject       = $false
            }

            $xmlToFilterGetWinEventsInvolvingTrigger = @"
            <QueryList><Query Id="0"><Select Path="Microsoft-Windows-TaskScheduler/Operational">*[EventData[Data[@Name="TaskName"]="$fullScheduledTaskPath"]]</Select></Query></QueryList>
"@
            DisplayTimePassed ("Getting last interest event for current task...")

            $lastEventsWhileRunningIs = Get-WinEvent -FilterXml $xmlToFilterGetWinEventsInvolvingTrigger -MaxEvents 100 -ErrorAction Ignore|Select Message, TaskDisplayName, TimeCreated, RecordId, ActivityId, ThreadId, ProcessId,
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

            DisplayTimePassed ("Completing getting last useful event for current task")
            if ($null -ne $lastEventsWhileRunningIs) {
                $Script:WindowsSchedulerTaskTriggeringEvent = $lastEventsWhileRunningIs
            }
            else {
                $Script:WindowsSchedulerTaskTriggeringEvent = $null
            }
        }
    }

} ##### Function main_dot_include_standard_header() {

<#########################################################################################################################################################################################################
.SYNOPSIS
Short description

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
##########################################################################################################################################################################################################>
Function DisplayTimePassed($point) {
            $now                     = (Get-Date)
            $timepassed              = $Script:LastDisplayedTimeElapsed - $now
    $Script:LastDisplayedTimeElapsed = $now
            $timepassedString        = $timepassed.Humanize()
    Write-Host "$point`: $timepassedString"
}

<#########################################################################################################################################################################################################
.SYNOPSIS
Short description

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
##########################################################################################################################################################################################################>
Function Write-LogLineToFile {
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

<#########################################################################################################################################################################################################
.SYNOPSIS
Short description

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
##########################################################################################################################################################################################################>
Function Log-Line {
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
        }
    }
}


<#########################################################################################################################################################################################################
.SYNOPSIS
Short description

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
##########################################################################################################################################################################################################>
$Script:CurrentXPosInTerminal = 0
Function Write-AllPlaces {
    param(
    [string]$s,
    [switch]$NoNewLine, [switch]$ForceStartOnNewLine,
    [switch]$NoLog <# For purely visual "I'm active" live viewing of the terminal, we don't need in the log#>
    )

    if ($ForceStartOnNewLine) {
        if ($Script:CurrentXPosInTerminal -gt 0) {
            Write-Host
            $Script:CurrentXPosInTerminal = 0 # Reset cursor tracking
        }
    }

    if ($NoNewLine) {
        Write-Host $s -NoNewline # To operator
        if (-Not $NoLog) {Log-Line $s -NoNewLine}
        $Script:CurrentXPosInTerminal+= $s.Length
        # or Write-Progress -CurrentOperation "EnablingFeatureXYZ" ( "Enabling feature XYZ ... " )
    } else {
        Write-Host $s # Always writes to Terminal
        $Script:CurrentXPosInTerminal = 0
        if (-Not $NoLog) { Log-Line $s}
        #Write-Output $s   # Doesn't always write to terminal? Writes to transcript????????????????????????????
    }
}

<#########################################################################################################################################################################################################
.SYNOPSIS
Short description

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
##########################################################################################################################################################################################################>
Function Get-CRC32 {
    [CmdletBinding()]
    param (
        # Array of Bytes to use for CRC calculation
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [byte[]]$InputObject
    )

    Begin {
        Function New-CrcTable {
            [uint32]$c = $null
            $crcTable = New-Object 'System.Uint32[]' 256

            for ($n = 0; $n -lt 256; $n++) {
                $c = [uint32]$n
                for ($k = 0; $k -lt 8; $k++) {
                    if ($c -band 1) {
                        $c = (0xEDB88320 -bxor ($c -shr 1))
                    }
                    else {
                        $c = ($c -shr 1)
                    }
                }
                $crcTable[$n] = $c
            }

            Write-Output $crcTable
        }

        function Update-Crc ([uint32]$crc, [byte[]]$buffer, [int]$length) {
            [uint32]$c = $crc

            if (-not (Test-Path variable:script:crcTable)) {
                $script:crcTable = New-CrcTable
            }

            for ($n = 0; $n -lt $length; $n++) {
                $c = ($script:crcTable[($c -bxor $buffer[$n]) -band 0xFF]) -bxor ($c -shr 8)
            }

            Write-output $c
        }

        $dataArray = @()
    }

    Process {
        foreach ($item  in $InputObject) {
            $dataArray += $item
        }
    }

    End {
        $inputLength = $dataArray.Length
        Write-Output ((Update-Crc -crc 0xffffffffL -buffer $dataArray -length $inputLength) -bxor 0xffffffffL)
    }
}

<#########################################################################################################################################################################################################
.SYNOPSIS
Short description

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
##########################################################################################################################################################################################################>
$_EXITCODE_UNTRAPPED_EXCEPTION           = 4001
$_EXITCODE_GENERIC_AND_USELESS_EXCEPTION = -2146233087
$_EXITCODE_VARIABLE_NOT_FOUND            = 15631964        # Get-CRC32 -shr 8
$_EXITCODE_SCRIPT_NOT_FOUND              = 4479237

Function Show-Error {
    param(
        [Parameter(Position=0,mandatory=$false)]        [string]$scriptWhichProducedError,
        [Parameter(Position=1,mandatory=$false)]        [int32] $exitcode = 1, # non-zero generally means failure in executable world
        [string] $message="",
        [switch]$DontExit # switches always default to false. I forget that sometimes.
    )

    # WARNING: DONT use Write-Error. The code will stop. It's really "Write-then-Error"
    Write-AllPlaces $scriptWhichProducedError
    if ($message -ne '')
    {
        Write-AllPlaces $message -ForceStartOnNewLine
    }

    Get-PSCallStack -Verbose|Out-Host

    $WasAnException        = $pretest_assuming_true
    $FullyQualifiedErrorId = "na"

    try {
        $_
    }
    catch {
        # There is no exception
        $WasAnException = $false
    }
    if ($WasAnException) {
        Write-AllPlaces "Message: $($_.Exception.Message)"
        Write-AllPlaces "StackTrace: $($_.Exception.StackTrace)"
        Write-AllPlaces "Failed on line #: $($_.InvocationInfo.ScriptLineNumber)"
        Write-AllPlaces "of Script: $($_.InvocationInfo.ScriptName)"        # Critical, or else we have to guess where the error occurred
        Write-AllPlaces "in line: $($_.InvocationInfo.Line)"                # Partial. For multiline commands, only the line where the bug is
        Write-AllPlaces "in statement: $($_.InvocationInfo.Statement)"      # Not super valuable

        $Exception = $_.Exception
        $HResult   = 0

        if (Test-Path variable:Exception) {
            if (Test-Path variable:Exception.WasThrownFromThrowStatement) {
                $WasThrownFromThrowStatement = $_.Exception.WasThrownFromThrowStatement # An interesting property
                if ($WasThrownFromThrowStatement) { Write-AllPlaces "This exception was from a throw statement"}
            }

            if ($null -ne $Exception.InnerException) {
                $HResult = $Exception.InnerException.HResult #
            } else {
                $HResult = $Exception.HResult
            }
            if ($Exception.PSObject.Properties.Name -match 'ErrorRecord') {
                Write-AllPlaces "Error Record= $($Exception.ErrorRecord)"
                # HResult is STUPID GENERIC!!!!!
                $FullyQualifiedErrorId = $Exception.ErrorRecord.FullyQualifiedErrorId
                Write-AllPlaces "Exception.ErrorRecord.FullyQualifiedErrorId = $FullyQualifiedErrorId"
            }
        }

        if (Has-Property  $_.Exception LoaderExceptions) {
            Write-AllPlaces "LoaderExceptions: $($_.Exception.LoaderExceptions)"   # Some exceptions don't have a loader exception.
        }

        if ($null -ne $HResult -and $HResult -ne 0 -and $exitcode -ne 1) # One is the default.
        {
            # You set a value on calling, and we have an hresult from an actual exception, then that's the code we'll use
            Write-AllPlaces "LASTEXITCODE to real exception HRESULT"
            $exitcode = $HResult
        }
    }

    if ($exitcode -eq $_EXITCODE_GENERIC_AND_USELESS_EXCEPTION -and $FullyQualifiedErrorId -ne 'na') {
        Write-AllPlaces "Generating a specific code from CRC32 since PowerShell giving us useless HResult" # Make a hash
        $exitcode64 = [System.Text.Encoding]::ASCII.GetBytes($FullyQualifiedErrorId) | Get-CRC32
        $exitcode = ($exitcode64 -shr 8)
    }
    Write-AllPlaces "Exiting all code with LASTEXITCODE of $exitcode"
    if (-not $DontExit) {
        Write-VolumeCache D # BAD DESIGN: So that log stuff gets written out in case of fatal crash                                                          # Double-negative. Meh.
        exit $exitcode # These SEEM to be getting back to Task Scheduler
    }
    return $exitcode
}

<#########################################################################################################################################################################################################
.SYNOPSIS
Short description

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
##########################################################################################################################################################################################################>
Function Assert-MeaningfulString([string]$s, $varname = 'string') {
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

<#########################################################################################################################################################################################################
.SYNOPSIS
Short description

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
##########################################################################################################################################################################################################>
Function Has-Property ($sourceob, $prop) {
    return @($sourceob.PSObject.Properties|Where Name -eq "$prop").Count -eq 1
}

<#########################################################################################################################################################################################################
.SYNOPSIS
Short description

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
##########################################################################################################################################################################################################>
Function Get-LastEventsForTask ($fullScheduledTaskPath, $howManyEvents = 1, [Switch]$LastRunOnly) {
    $xmlToFilterGetWinEventsInvolvingTrigger = @"
    <QueryList><Query Id="0"><Select Path="Microsoft-Windows-TaskScheduler/Operational">*[EventData[Data[@Name="TaskName"]="$fullScheduledTaskPath"]]</Select></Query></QueryList>
"@
    $lastEventsWhileRunningIs = Get-WinEvent -FilterXml $xmlToFilterGetWinEventsInvolvingTrigger -MaxEvents 100 -ErrorAction Ignore|Select Message, TaskDisplayName, TimeCreated, RecordId, ActivityId, ThreadId, ProcessId,
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
        145,  <# Triggered by coming out of suspend mode #>
        100, <# Task Started #>
        101, <# Task Start failed #>
        102, <# Task Completed #>
        200, <# Action started #>
        203, <# Action Start failed #>
        201, <# Action completed #>
        111 <# Task terminated #>
    }|Select -First $howManyEvents|
    Sort RecordId -Descending

    if ($null -ne $lastEventsWhileRunningIs) {
        if ($LastRunOnly) {
            $lastActivityId =$lastEventsWhileRunningIs[0].ActivityId
            $lastEventsWhileRunningIs = ($lastEventsWhileRunningIs|Where ActivityId -eq $lastActivityId)
        }
    }
    return [array]$lastEventsWhileRunningIs
}
#####################################################################################################################################################################################################################################################
# Bootstrap Ordered Stage 8 - Persist Batch Run Session Detail
# Dependencies: scheduledTaskForProject, WindowsSchedulerTaskTriggeringEvent, ScriptName, ScriptNameWithoutExtension, Caller
#####################################################################################################################################################################################################################################################

if ($scheduledTaskForProject -and $null -ne $Script:WindowsSchedulerTaskTriggeringEvent) {
    Set-StrictMode -Off # Critical to avoid not found errors on following attributes
    DisplayTimePassed ("Fetch task trigger details...")
    $triggers = Get-ScheduledTask -TaskName $ScriptNameWithoutExtension|
    SELECT -expandProperty Triggers|
    % {
        $trigger = [PSCustomObject]@{
            Id                          = $_.Id # Only set if I generated the script in generate_clean_project_scheduled_tasks.ps1
            TriggerType                 = (($_.pstypenames[0])-split '/')[-1]
            TaskName                    = $_.TaskName
            Enabled                     = $_.Enabled
            StartBoundary               = $_.StartBoundary
            EndBoundary                 = $_.EndBoundary
            DaysInterval                = $_.DaysInterval
            WeeksInterval               = $_.WeeksInterval
            Weeks                       = $_.Weeks
            DaysOfWeek                  = $_.DaysOfWeek                    # uint16
            Months                      = $_.Months
            MonthOfYear                 = $_.MonthOfYear
            DaysOfMonth                 = $_.DaysOfMonth
            RunOnLastWeekOfMonth        = $_.RunOnLastWeekOfMonth
            WeeksOfMonth                = $_.WeeksOfMonth
            ExecutionTimeLimit          = $_.ExecutionTimeLimit
            RepetitionInterval          = $_.Repetition.Interval            # MSFT_TaskRepetitionPattern    P<days>DT<hours>H<minutes>M<seconds>S
            RepetitionDuration          = $_.Repetition.Duration
            RepetitionStopAtDurationEnd = $_.Repetition.Duration            # PT4H
            RandomDelay                 = $_.RandomDelay
            Delay                       = $_.Delay                          # PT15S
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
    $triggerType        = $Script:WindowsSchedulerTaskTriggeringEvent.TaskDisplayName
    $triggerId          = $Script:WindowsSchedulerTaskTriggeringEvent.Id
    $timeTaskTriggered  = $Script:WindowsSchedulerTaskTriggeringEvent.TimeCreated
    $triggered_by_login = ''

    switch ($Script:WindowsSchedulerTaskTriggeringEvent.TaskDisplayName) {
        ##############################################################################################################################################################################################################
        "Task triggered by user" {         # If a non-lead task triggered by user, then do not attach it to whatever random floating id in active_run_session.
            $triggerType = 'user'
            $triggered_by_login = $lastEventsWhileRunningIs.UserContext
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
                $triggerType = "idle"
            }
        }
        ##############################################################################################################################################################################################################
        "Task triggered on logon" {
            $triggers = $triggers|Where TriggerType -match 'Logon'
            if ($triggers.Count -eq 1 -and $null -ne $triggers[0].UserId) {
                $triggered_by_login = $triggers[0].UserId
            }
            # match Logon
            $triggerType = 'logon'
        } else {
            Show-Error -message "Unprocessed task type $($Script:WindowsSchedulerTaskTriggeringEvent.TaskDisplayName)" -exitcode 99
        }
    }

    DisplayTimePassed ("Completing getting task trigger details")
    DisplayTimePassed ("Detect active batch run session...")
    $Script:active_batch_run_session_id            = Get-SqlValue "SELECT batch_run_session_id FROM batch_run_sessions_v WHERE running"
            $FileTimeStampForParentScriptFormatted = $FileTimeStampForParentScript.ToString($DEFAULT_POWERSHELL_TIMESTAMP_FORMAT)
            $script_name_prepped_for_sql           = PrepForSql $Script:ScriptName

    ############################################################################################################################
    if ($script_position_in_lineup -in 'Starting', 'Starting-Ending') {
        .\__sanity_check_without_db_connection.ps1 'without_db_connection' 'before_session_starts'
        if ($null -ne $Script:active_batch_run_session_id) {
            Invoke-Sql "UPDATE batch_run_sessions_v SET running = NULL, session_ending_script = '$ScriptName', marking_ended_after_overrun = CURRENT_TIMESTAMP WHERE running" -LogSqlToHost|Out-Null
        }
        DisplayTimePassed ("Creating or ending(?) session entry...")

        $Script:active_batch_run_session_id = Get-SqlValue "
            INSERT INTO batch_run_sessions_v(
                last_script_ran
            ,   session_starting_script
            ,   caller_starting
            ,   triggered_by_login
            ,   trigger_type
            ,   trigger_id
            ) VALUES(
                '$Script:ScriptName'
            ,   '$Script:ScriptName'
            ,   '$Script:Caller'
            ,   '$triggered_by_login'
            ,   '$triggerType'
            ,   '$triggerId'
            )
            RETURNING batch_run_session_id
            " -LogSqlToHost
        Invoke-Sql "UPDATE batch_run_session_active_running_values_ext_v SET active_batch_run_session_id  = $($Script:active_batch_run_session_id)" -LogSqlToHost|Out-Null # Flush active session regardless of how this script was run.
        $Script:batch_run_session_task_id      = Get-SqlValue("
        INSERT INTO
            batch_run_session_tasks_v(
                batch_run_session_id,
                script_changed,
                script_name,
                triggered_by_login,
                trigger_type,
                trigger_id
            )
            VALUES(
                $($Script:active_batch_run_session_id),
                '$FileTimeStampForParentScriptFormatted'::TIMESTAMPTZ,
                $script_name_prepped_for_sql
            ,   '$triggered_by_login'
            ,   '$triggerType'
            ,   '$triggerId'
                    )
            RETURNING batch_run_session_task_id
        ") -LogSqlToHost
    ############################################################################################################################
    } elseif ($script_position_in_lineup -in 'Ending', 'Starting-Ending') {
        DisplayTimePassed ("Ending(?) session entry...")
        if ($triggerType -eq 'event') {
            if ($null -eq $Script:active_batch_run_session_id) {
                Invoke-Sql "UPDATE batch_run_sessions_v SET running = NULL, session_ending_script = '$ScriptName', ended = CURRENT_TIMESTAMP WHERE running" -LogSqlToHost|Out-Null
                # For safety, in case using the "running" flag fails.
                Invoke-Sql "UPDATE batch_run_sessions_v SET running = NULL, session_ending_script = '$ScriptName', ended = CURRENT_TIMESTAMP WHERE batch_run_session_id  = $($Script:active_batch_run_session_id)" -LogSqlToHost|Out-Null
            }
        }
        . .\__sanity_check_without_db_connection.ps1 'without_db_connection' 'after_session_ends'
        Invoke-Sql "DELETE FROM batch_run_session_active_running_values_ext_v" -LogSqlToHost|Out-Null
    ############################################################################################################################
    } elseif ($script_position_in_lineup -eq 'In-Between') {
        DisplayTimePassed ("inbetween session entry...")
        # if user, skip messing with tasks. If downstream event from starting midstream user?????  Somehow cancel this?
        # if there is not an active session??????? Crash?????
        if ($triggerType -eq 'Event') {
            if (-not (Test-Path variable:Script:TestScheduleDrivenTaskDetection)) {
                $Script:TestScheduleDrivenTaskDetection = 'NULL'
            }
            # UPDATE open (previous) task log
            $Script:active_batch_run_session_id    = Get-SqlValue("SELECT active_batch_run_session_id FROM batch_run_session_active_running_values_ext_v")
            $Script:batch_run_session_task_id      = Get-SqlValue("
                INSERT INTO
                    batch_run_session_tasks_v(
                        batch_run_session_id,
                        script_changed,
                        script_name,
                        triggered_by_login,
                        trigger_type,
                        trigger_id,
                        is_testscheduledriventaskdetection
                    )
                    VALUES(
                        $($Script:active_batch_run_session_id),
                        '$FileTimeStampForParentScriptFormatted'::TIMESTAMPTZ,
                        $script_name_prepped_for_sql
                    ,   '$triggered_by_login'
                    ,   '$triggerType'
                    ,   '$triggerId'
                    ,   $($Script:TestScheduleDrivenTaskDetection)
                    )
                    RETURNING batch_run_session_task_id
                ") -LogSqlToHost
        }
    }
}

<#########################################################################################################################################################################################################
.SYNOPSIS
Short description

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
##########################################################################################################################################################################################################>
Function End-BatchRunSessionTaskEntry() {
    if ((Test-Path variable:Script:batch_run_session_task_id) -and
        (Test-Path variable:script:active_batch_run_session_id)) {
        $tied_batch_run_session_task = Get-SqlValue "
            SELECT batch_run_session_task_id
            FROM batch_run_session_tasks_v
            WHERE batch_run_session_task_id = $($Script:batch_run_session_task_id)
            AND batch_run_session_id        = $($Script:active_batch_run_session_id)
            AND running
            "
        if ($null -eq $tied_batch_run_session_task) {
            Show-Error -message "ERROR trying to find task log record that goes with this session. batch_run_session_task_id = $($Script:batch_run_session_task_id), batch_run_session_id = $($Script:active_batch_run_session_id)"
        }

        Invoke-Sql "
            UPDATE
                batch_run_session_tasks_v
            SET
                running = false
            , ended   = CURRENT_TIMESTAMP
            WHERE
                batch_run_session_task_id = $tied_batch_run_session_task
            " -OneAndOnlyOne
        }
}

<#########################################################################################################################################################################################################
.SYNOPSIS
Short description

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
##########################################################################################################################################################################################################>
Function TrimToMicroseconds([datetime]$date) # Format only for PowerShell! Not Postgres!
{
    # Only way I know to flush micro AND nanoseconds is to convert to string and back. And adding negative microseconds back leaves trailing Nanoseconds, which have no function to clear.  Can't add negative Nanoseconds.
    [DateTime]::ParseExact($date.ToString("yyyy-MM-dd HH:mm:ss.ffffff"), "yyyy-MM-dd HH:mm:ss.ffffff", $null)
}

<#########################################################################################################################################################################################################
.SYNOPSIS
Short description

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
##########################################################################################################################################################################################################>
Function Least([array]$things) {
    return ($things|Measure -Minimum).Minimum
}

<#########################################################################################################################################################################################################
.SYNOPSIS
Short description

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
##########################################################################################################################################################################################################>
Function Right([string]$val, [int32]$howManyChars = 1) {
    if ([String]::IsNullOrEmpty($val)) {
        return $null
    }
    $actualLengthWeWillGet = Least $howManyChars  $val.Length

    return $val.Substring($val.Length - $actualLengthWeWillGet)
}

<#########################################################################################################################################################################################################
.SYNOPSIS
Short description

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
##########################################################################################################################################################################################################>
Function Left([string]$val, [int32]$howManyChars = 1) {
    if ([String]::IsNullOrEmpty($val)) {
        # Made up rule: Empty doesn't have a Leftmost character. $null should break the caller.  Returning an empty string as "leftmost character" is a fudge, and causes problems.
        return $null
    }
    $actualLengthWeWillGet = Least $howManyChars  $val.Length
    return $val.Substring(0,$actualLengthWeWillGet)
}

<#########################################################################################################################################################################################################
.SYNOPSIS
Short description

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
##########################################################################################################################################################################################################>
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

<#########################################################################################################################################################################################################
.SYNOPSIS
Short description

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
##########################################################################################################################################################################################################>
Function Format-Humanize([Diagnostics.Stopwatch]$ob) {
    [timespan]$elapsed = $ob.Elapsed

    if ($elapsed.TotalDays -ge 1) {
            Format-Plural 'Day' $($elapsed.TotalDays) -includeCount
    }
    elseif ($elapsed.TotalHours -ge 1) {
        Format-Plural 'Hour' $($elapsed.TotalHours) -includeCount
    }
    elseif ($elapsed.TotalMinutes -ge 1) {
        Format-Plural 'Minute' $($elapsed.TotalMinutes) -includeCount
    }
    elseif ($elapsed.TotalSeconds -ge 1) {
        Format-Plural 'Second' $($elapsed.TotalSeconds) -includeCount
    }
    elseif ($elapsed.TotalMilliseconds -ge 1) {
        Format-Plural 'Millisecond' $($elapsed.TotalMilliseconds) -includeCount
    }
    elseif ($elapsed.TotalMicroseconds -ge 1) {
        Format-Plural 'Microsecond' $($elapsed.TotalMicroseconds) -includeCount
    }
    elseif ($elapsed.Ticks-gt 0) {
        Format-Plural 'Tick' $($elapsed.Ticks) -includeCount
    }
}

Function NullIf([string]$val, [string]$ifthis = '') {
    if ($null -eq $val -or $val.Trim() -eq $ifthis) {return $null}
    return $val
}

<#########################################################################################################################################################################################################
.SYNOPSIS
Short description

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
##########################################################################################################################################################################################################>
Function __TICK ($tick_emoji) {
    # Only write to terminal if not a scheduled task run
    if ($Script:Caller -ne 'Windows Task Scheduler') {
        Write-AllPlaces $tick_emoji -NoNewline -NoLog
    }
}
$NEW_OBJECT_INSTANTIATED             = '✨'; Function _TICK_New_Object_Instantiated             {__TICK $NEW_OBJECT_INSTANTIATED}
$FOUND_EXISTING_OBJECT               = '✔️'; Function _TICK_Found_Existing_Object               {__TICK $FOUND_EXISTING_OBJECT}
$FOUND_EXISTING_OBJECT_BUT_NO_CHANGE = '🥱'; Function _TICK_Found_Existing_Object_But_No_Change {__TICK $FOUND_EXISTING_OBJECT_BUT_NO_CHANGE}
$EXISTING_OBJECT_EDITED              = '📝'; Function _TICK_Existing_Object_Edited              {__TICK $EXISTING_OBJECT_EDITED}
$EXISTING_OBJECT_ACTUALLY_CHANGED    = '🏳️‍🌈'; Function _TICK_Existing_Object_Actually_Changed    {__TICK $EXISTING_OBJECT_ACTUALLY_CHANGED} # Warning: Comes out different in terminal than editor. fonts. Geez.
$OBJECT_MARKED_DELETED               = '❌'; Function _TICK_Object_Marked_Deleted               {__TICK $OBJECT_MARKED_DELETED}   # Was a file or row deleted? Or just marked?
$SCAN_OBJECTS                        = '👓'; Function _TICK_Scan_Objects                        {__TICK $SCAN_OBJECTS}
$SOUGHT_OBJECT_NOT_FOUND             = '😱'; Function _TICK_Sought_Object_Not_Found             {__TICK $SOUGHT_OBJECT_NOT_FOUND}  # As in database says it's there but it's not physically on file.
$UPDATE_OBJECT_STATUS                = '🚩'; Function _TICK_Update_Object_Status                {__TICK $UPDATE_OBJECT_STATUS}
$IMPOSSIBLE_OUTCOME                  = '🤷‍♂️'; Function _TICK_Impossible_Outcome                  {__TICK $IMPOSSIBLE_OUTCOME}

<#########################################################################################################################################################################################################
.SYNOPSIS
Short description

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
##########################################################################################################################################################################################################>
$Script:WriteCounts = @([PSCustomObject]@{
    CountLabel = '';
    Count      = 0;
    Tag        = 'x';
})

Function Write-Count ([string]$variableName = $null, [string]$singularLabel, [string]$pluralLabel = $null) {
    $countLabel = ""

    $countLabel = $variableName.Humanize()
    $number = Get-Variable -Name $variableName -Scope Global -Value

    if ($number -eq 1) {
        $Script:WriteCounts+= [PSCustomObject]@{
            CountLabel = $countLabel;
            Count      = $number;
            Tag        = $singularLabel;
        }
        return
    } else {
        # FIX: This code duplicated from Format-Plural!
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
        $Script:WriteCounts+= [PSCustomObject]@{
            CountLabel = $countLabel;
            Count      = $number;
            Tag        = $pluralLabel;
        }
    }
}

<#########################################################################################################################################################################################################
.SYNOPSIS
Short description

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
##########################################################################################################################################################################################################>
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

<#########################################################################################################################################################################################################
.SYNOPSIS
Short description

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
##########################################################################################################################################################################################################>
Function Convert-ByteArrayToHexString ([byte[]] $bytearray) {
    if ($null -eq $bytearray) {return $null}
    return @($bytearray|Format-Hex|Select ascii).Ascii -join ''
}

<#########################################################################################################################################################################################################
.SYNOPSIS
Short description

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
##########################################################################################################################################################################################################>
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
        $propval = $null

        if(@($sourceob.PSObject.Properties.Name -eq "$prop").Count -eq 1) {$propval = $sourceob.$prop } else { $propval= ''}
        $targetob.$prop = $propval
    }
}

<#########################################################################################################################################################################################################
.SYNOPSIS
Short description

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
##########################################################################################################################################################################################################>
Function HumanizeCount([Int64]$i) {
    return [string]::Format('{0:N0}', $i)
}

<#########################################################################################################################################################################################################
.SYNOPSIS
Short description

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
##########################################################################################################################################################################################################>
Function EllipseString($string, $cutoff) {
    if ($string.Length -lt $cutoff) {
        return $string
    }

    return "$($string.Substring(0, $cutoff-3))..."
}

<#########################################################################################################################################################################################################
.SYNOPSIS
Short description

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
##########################################################################################################################################################################################################>
Function ReplaceAll($string, $what, $with) {
    if ([string]::IsNullOrEmpty($what)) {return $string}
    if ($null -eq $with) {return $string}
    if ($with -contains $what) {return $string}

    $newstring = $string
    while ($newstring -contains $what) {
        $newstring = $newstring -replace $what, $with
    }

    return $newstring
}
# Version (untested) with progress bars.
# Question: What is a PSDrive?
<#########################################################################################################################################################################################################
.SYNOPSIS
Short description

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
##########################################################################################################################################################################################################>
Function Copy-File {
    param( [string]$from, [string]$to)
    $ffile = [io.file]::OpenRead($from)
    #$tofile = [io.file]::OpenWrite($to)
    $tofile = [io.file]::Create($to)
    Write-Progress -Activity "Copying file" -status "$from -> $to" -PercentComplete 0
    try {
        [byte[]]$buff = new-object byte[] 4096
        [long]$total = [int]$count = 0
        do {
            $count = $ffile.Read($buff, 0, $buff.Length)
            $tofile.Write($buff, 0, $count)
            $total += $count
            if ($total % 1mb -eq 0) {
                Write-Progress -Activity "Copying file" -status "$from -> $to" -PercentComplete ([long]($total * 100 / $ffile.Length))
            }
        } while ($count -gt 0)
    }
    finally {
        $ffile.Dispose()
        $tofile.Dispose()
        Write-Progress -Activity "Copying file" -Status "Ready" -Completed
    }
}

main_dot_include_standard_header

DisplayTimePassed ("Finished header.")

Log-Line "Exiting standard_header v2"
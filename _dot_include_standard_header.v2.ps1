[Net.ServicePointManager]::SecurityProtocol       = [Net.SecurityProtocolType]::Tls12;   # More to do with PowerShellGet issues, not Imports.
Import-Module PowerShellHumanizer
Import-Module DellBIOSProvider                                      

Remove-Variable batch_run_session_task_id, batch_run_session_id, Caller, ScriptName, LogDirectory -Scope Script -ErrorAction Ignore

#####################################################################################################################################################################################################################################################
# Bootstrap Ordered Stage 1 - Set environment control
#####################################################################################################################################################################################################################################################

# Lists every line executed, every if branch, and converts simple expressions when assigned to variables to their evaluated constants.
# Set-PSDebug -Trace 2
# Set-PSDebug -Off
Set-StrictMode -Version Latest
$ErrorActionPreference                            = 'Stop'            
$Script:OutputEncoding                            = [System.Text.Encoding]::UTF8
$Script:scriptTimer                               = [Diagnostics.Stopwatch]::StartNew() 
$Script:SnapshotMasterRunDate                     = Get-Date
$Script:DEFAULT_POWERSHELL_TIMESTAMP_FORMAT       = "yyyy-MM-dd HH:mm:ss.ffffff zzz"      # 2024-01-22 05:37:00.450241 -07:00    Restrict to ONLY 6 places (microseconds). Windows has 7 places, which won't match with Postgres's 6, which then causes mismatches between timestamps in database with timestamps on files. They were always off by 4 100ths nanoseconds, and caused massive thrashing.
$Script:pretest_assuming_true                     = $true
$Script:pretest_assuming_false                    = $false

#####################################################################################################################################################################################################################################################
# Bootstrap Ordered Stage 2 - Load configuration file
#####################################################################################################################################################################################################################################################

$Script:ProjectRoot                               = (Get-Location).Path                                                   # D:\qt_projects\filmcab. May be to do with WorkingDirectory setting in Windows Task Scheduler for Exec commands.
$Script:PathToConfig                              = $ProjectRoot + '\config.json'
$Script:Config                                    = (Get-Content -Path $Script:PathToConfig | ConvertFrom-Json)

#####################################################################################################################################################################################################################################################
# Bootstrap Ordered Stage 3 - Get Script Name and Path
# Dependencies: None
#####################################################################################################################################################################################################################################################

$Script:MasterScriptPath                          = $MyInvocation.ScriptName                               # This is null if you are running this dot include directly.
if ([String]::IsNullOrEmpty($MasterScriptPath)) {                                                                
    $Script:MasterScriptPath                      = $MyInvocation.Line
}                                          
$Script:MasterScriptPath                          = if ($Script:MasterScriptPath.StartsWith(". .\")) { $Script:MasterScriptPath.Substring(2)} else {$Script:MasterScriptPath}
$Script:MasterScriptPath                          = if ($Script:MasterScriptPath.StartsWith(". '"))  { $Script:MasterScriptPath.Substring(2)} else {$Script:MasterScriptPath}
$Script:MasterScriptPath                          = $Script:MasterScriptPath.Trim("'")
$Script:FileTimeStampForParentScript              = (Get-Item -Path $Script:MasterScriptPath).LastWriteTime
$Script:ScriptName                                = (Get-Item -Path $Script:MasterScriptPath).Name       # Unlike "BaseName" this includes the extension
$Script:ScriptNameWithoutExtension                = (Get-Item -Path $Script:MasterScriptPath).BaseName   # Base name is nice for labelling and searching scheduler tasks
$Script:ScriptRoot                                = ([System.IO.Path]::GetDirectoryName($MyInvocation.PSCommandPath))
if ($null -eq $Script:ScriptRoot) {
    $Script:ScriptRoot                            = (Get-Item -Path $masterScriptPath).DirectoryName
}
$Script:LogDirectory                              = "$Script:ScriptRoot\_log"
New-Item -ItemType Directory -Force -Path $Script:LogDirectory|Out-Null
$Script:LogFileName                               = $Script:ScriptName + '.log.txt' 
$Script:LogFilePath                               = $Script:LogDirectory + '\' + $Script:LogFileName

#####################################################################################################################################################################################################################################################
# Bootstrap Ordered Stage 4 - Start Transcript 
# Dependent on: ScriptName, LogDirectory
#####################################################################################################################################################################################################################################################

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

#####################################################################################################################################################################################################################################################
# Bootstrap Ordered Stage 5 - Start Log
#####################################################################################################################################################################################################################################################
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

$Script:DSTTag                                              = If (($Script:SnapshotMasterRunDate).IsDaylightSavingTime()) { "DST"} else { "No DST"} # DST can seriously f-up ordering.
$Script:PSVersion                                           = $PSVersionTable.PSVersion                       # 7.5.0-preview.2
$Script:PS_Edition                                          = $PSVersionTable.PSEdition                       # Core
$Script:CommandOrigin                                       = $MyInvocation.CommandOrigin                     # Internal
$Script:CurrentFunction                                     = $MyInvocation.MyCommand                         # _dot_include_standard_header.v2.ps1
$Script:InvokationName                                      = $MyInvocation.InvocationName                    # .
    
Log-Line "Starting Log $($Script:SnapshotMasterRunDate) on $(($Script:SnapshotMasterRunDate).DayOfWeek) $($Script:DSTTag) in $(($Script:SnapshotMasterRunDate).ToString('MMMM')), by Windows User <$($env:UserName)>" -Restart
Log-Line "`$ScriptFullPath: $Script:MasterScriptPath, `$PSVersion = $($Script:PSVersion), `$PSEdition = $($Script:PSEdition), `$CommandOrigin = $($Script:CommandOrigin), Current Function = $($Script:CurrentFunction)"

$basePath                                                   = 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' 
$Script:amRunningAsAdmin                                    = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if(-not (Test-Path $basePath)) {     
    $null = New-Item $basePath -Force     
    New-ItemProperty $basePath -Name "EnableScriptBlockLogging" -PropertyType Dword
    New-ItemProperty $basePath -Name "EnableInvocationHeader" -PropertyType Dword
    New-ItemProperty $basePath -Name "OutputDirectory" -PropertyType String
} 

if ($amRunningAsAdmin) {
    Set-ItemProperty $basePath -Name "EnableScriptBlockLogging" -Value "1"
    Set-ItemProperty $basePath -Name "EnableInvocationHeader" -Value "1"
    Set-ItemProperty $basePath -Name "OutputDirectory" -Value $Script:LogDirectory
}

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
        Write-AllPlaces "Message: $($_.Exception.Message)" # Will null output if no exception
        Write-AllPlaces "StackTrace: $($_.Exception.StackTrace)"             # Will null output if no exception
        Write-AllPlaces "Failed on line #: $($_.InvocationInfo.ScriptLineNumber)"                                      # Will null output if no exception
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
        
        if ($null -ne $HResult -and $HResult -ne 0 -and $exitcode -ne 1)
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
                      
Function Has-Property ($sourceob, $prop) {
    return @($sourceob.PSObject.Properties|Where Name -eq "$prop").Count -eq 1
}
                                                       
. .\_dot_include_standard_header_sql_functions.ps1

#####################################################################################################################################################################################################################################################
# Bootstrap Ordered Stage 6 - Connect Database
#####################################################################################################################################################################################################################################################

$MyOdbcDatabaseDriver    = "$($Config.database_driver)"
$MyDatabaseServer        = "$($Config.database_server_ip_address)";
$MyDatabaseServerPort    = "$($Config.database_server_port)";
$MyDatabaseName          = "$($Config.database)";
$MyDatabaseUserName      = "$($Config.database_user)";
$MyDatabaseUsersPassword = "$($Config.database_password)"     
$MyDatabaseSchema        = "$($Config.database_schema)"

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
    "                  
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

if ($Script:DatabaseConnectionIsOpen) {
    Invoke-Sql "SET application_name to '$($Script:ScriptName)'"|Out-Null
    Invoke-Sql @"
        SET search_path = $MyDatabaseSchema, "`$user", public
"@|Out-Null
}

#####################################################################################################################################################################################################################################################
# Bootstrap Ordered Stage 7 - Detect Caller                              
# Dependencies: PID
#####################################################################################################################################################################################################################################################

$process_enumerator = Get-CimInstance -Class Win32_Process -Filter "ProcessId = $PID"
$processtree = @()

While ($process_enumerator) {
    $processtree+= $process_enumerator
    $process_enumerator = Get-CimInstance -Class Win32_Process -Filter "ProcessId = $($process_enumerator.ParentProcessId)"
}

$Script:Caller = 'ndef'
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

$scheduledTaskForProject = $pretest_assuming_false

if ($Script:Caller -eq 'Windows Task Scheduler') {
    $scheduledTaskForProject = $pretest_assuming_true

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
    $lastEventWhileRunningIs = Get-WinEvent -FilterXml $xmlToFilterGetWinEventsInvolvingTrigger -MaxEvents 100 -ErrorAction Ignore|Select Message, TaskDisplayName, TimeCreated, RecordId, ActivityId, ThreadId, ProcessId, 
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
        $Script:WindowsSchedulerTaskTriggeringEvent = $lastEventWhileRunningIs
    }                                              
    else {
        $Script:WindowsSchedulerTaskTriggeringEvent = $null
    }
}

#####################################################################################################################################################################################################################################################
# Bootstrap Ordered Stage 8 - Persist Batch Run Session Detail
# Dependencies: scheduledTaskForProject, WindowsSchedulerTaskTriggeringEvent, ScriptName, ScriptNameWithoutExtension, Caller
#####################################################################################################################################################################################################################################################

if ($scheduledTaskForProject -and $null -ne $Script:WindowsSchedulerTaskTriggeringEvent) {
    Set-StrictMode -Off # Critical to avoid not found errors on following attributes
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
    $triggerType = $Script:WindowsSchedulerTaskTriggeringEvent.TaskDisplayName
    $triggerId   = $Script:WindowsSchedulerTaskTriggeringEvent.Id

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
            
    $Script:active_batch_run_session_id = Get-SqlValue "SELECT batch_run_session_id FROM batch_run_sessions_v WHERE running"
    ############################################################################################################################
    if ($script_position_in_lineup -in 'Starting', 'Starting-Ending') {
        .\__sanity_check_without_db_connection.ps1 'without_db_connection' 'before_session_starts'        
        if ($null -ne $Script:active_batch_run_session_id) {
            Invoke-Sql "UPDATE batch_run_sessions_v SET running = NULL, session_ending_script = '$ScriptName', marking_ended_after_overrun = CURRENT_TIMESTAMP WHERE running" -LogSqlToHost|Out-Null
        }
        $Script:active_batch_run_session_id = Get-SqlValue "
            INSERT INTO batch_run_sessions_v(
                last_script_ran
            ,   session_starting_script
            ,   caller_starting
            ) VALUES(
                '$Script:ScriptName'
            ,   '$Script:ScriptName'
            ,   '$Script:Caller'
            )" -OneAndOnlyOne -LogSqlToHost|Out-Null
        Invoke-Sql "UPDATE batch_run_session_active_running_values_ext_v SET active_batch_run_session_id  = $($Script:active_batch_run_session_id)" -LogSqlToHost|Out-Null # Flush active session regardless of how this script was run.
    ############################################################################################################################
    } elseif ($script_position_in_lineup -in 'Ending', 'Starting-Ending') {
        if ($triggerType -eq 'event') {
            if ($null -ne $Script:active_batch_run_session_id) {
                Invoke-Sql "UPDATE batch_run_sessions_v SET running = NULL, session_ending_script = '$ScriptName', ended = CURRENT_TIMESTAMP WHERE running" -LogSqlToHost|Out-Null
                # For safety.
                Invoke-Sql "UPDATE batch_run_sessions_v SET running = NULL, session_ending_script = '$ScriptName', ended = CURRENT_TIMESTAMP WHERE active_batch_run_session_id  = $($Script:active_batch_run_session_id)" -LogSqlToHost|Out-Null
            }
        }                                                                                                                                                                 
        Invoke-Sql "DELETE batch_run_session_active_running_values_ext_v" -LogSqlToHost|Out-Null

        # Update counts, times.
        # Update active record, close out, set inactive
        # UPDATE open (previous) task log as closed.
        # DELETE batch_run_session_active_running_values_ext_v
    ############################################################################################################################
    } elseif ($script_position_in_lineup -eq 'In-Between') {
        # if user, skip messing with tasks. If downstream event from starting midstream user?????  Somehow cancel this?
        # if there is not an active session??????? Crash?????
        $FileTimeStampForParentScriptFormatted = $FileTimeStampForParentScript.ToString($DEFAULT_POWERSHELL_TIMESTAMP_FORMAT)
        $script_name_prepped_for_sql           = PrepForSql $script_name      
        if ($triggerType -eq 'Event') {   
            # UPDATE open (previous) task log 
            $Script:active_batch_run_session_id    = Get-SqlValue("SELECT active_batch_run_session_id FROM batch_run_session_active_running_values_ext_v")
            $Script:batch_run_session_task_id      = Get-SqlValue("
                INSERT INTO 
                    batch_run_session_tasks(
                        batch_run_session_id,
                        script_changed,
                        script_name
                    )
                    VALUES(
                        $($Script:batch_run_session_id),
                    '$FileTimeStampForParentScriptFormatted'::TIMESTAMPTZ,
                        $script_name_prepped_for_sql
                    )
                    RETURNING batch_run_session_task_id
                ")
        }
    }
}   

#####################################################################################################################################################################################################################################################
# Bootstrap Final steps, no dependencies. Define global constants
#####################################################################################################################################################################################################################################################

$Script:TpmStatus                                           = ((Get-ChildItem -Path "DellSmbios:\TPMSecurity\TpmSecurity"|Select CurrentValue).CurrentValue -eq 'Enabled')
$Script:MyComputerName                                      = $env:COMPUTERNAME     # DSKTP-HOME-JEFF
$Script:OneDriveDirectory                                   = $env:OneDrive         # D:\OneDrive
$Script:OSUserName                                          = $env:USERNAME         # jeffs
$Script:OSUserFiles                                         = $env:USERPROFILE      # C:\Users\jeffs
$Script:DEFAULT_POSTGRES_TIMESTAMP_FORMAT                   = "yyyy-mm-dd hh24:mi:ss.us tzh:tzm"    # 2024-01-22 05:36:46.489043 -07:00
$Script:DEFAULT_WINDOWS_TASK_SCHEDULER_TIMESTAMP_FORMAT_XML = 'yyyy-MM-ddTHH:mm:ss.fffffff'
$Script:CurrentDebugSessionNo                               = $MyInvocation.HistoryId

# Do we need?

. .\_dot_include_standard_header_helper_functions.ps1
                                                
Log-Line "Exiting standard_header v2"
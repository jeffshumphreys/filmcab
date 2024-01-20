#C:\Users\jeffs\.vscode\extensions\ms-vscode.powershell-2023.8.0\examples\PSScriptAnalyzerSettings.psd1
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Scope='Function', Target='Log-*')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '', Scope='Function', Target='*')]
param()

# Seems to close the popup console window almost immediately

add-type -name user32 -namespace win32 -memberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
$consoleHandle = (get-process -id $pid).mainWindowHandle
[void][win32.user32]::showWindow($consoleHandle, 0)

Set-StrictMode -Version Latest
<#
.SYNOPSIS
Great simple everything you always want to know when looking at ooooooooooooold log files

.DESCRIPTION
Get the "deets".  And start up the file in the default "..\log\[yyyymmdd][nameofapp].txt"  Not ".log" Write out a standard header line or two.

.EXAMPLE
Start-Log

.NOTES
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
Instead of fake symmetry, just because we have "Start-Log" I don't have to have a Stop-Log.  There's nothing to do.  Rather, I want to Log that the program came to a normal end.

.DESCRIPTION
Long description

.EXAMPLE
An example

.NOTES
General notes
#>
function Log-Stop {
    Log-Line "Stopping Normally"
    # Timestamp
    # Elapsed time in human form
    # CPU used? etc.
    # Rows written? Deleted? Updated? Found but no change?
}
<#
.SYNOPSIS
Keep it simple. Users just have to "Log-Line" and the rest is taken care of. Other superfunctions add layers of detail for common scenarios.

.DESCRIPTION
Long description

.PARAMETER Text
Parameter description

.PARAMETER Restart
Does it delete and recreate the log? Not sure. But doesn't append text

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
        "NULL"|  Out-File "$ScriptRoot\text.txt" -Encoding utf8 -Append
    } 

    if ($null -eq $arguments) {
        $text | Out-File "$ScriptRoot\text.txt" -Encoding utf8 -Append
    } else {
        $text | Out-File "$ScriptRoot\text.txt" -Encoding utf8 @arguments
    }
    Write-VolumeCache D # So that log stuff gets written out in case of fatal crash
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


$rtn =  Start-Log
Log-Stop
return $rtn
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
    #$Script:LoggingRunspace.EngineEventJob = Register-EngineEvent -SourceIdentifier ([System.Management.Automation.PsEngineEvent]::Exiting) -Action $OnRemoval
    # $Script:LoggingEventQueue.Add($logMessage)
    <#
       $logMessage = [hashtable] @{
            timestamp    = [datetime]::now
            timestamputc = [datetime]::UtcNow
            level        = Get-LevelName -Level $levelNumber
            levelno      = $levelNumber
            lineno       = $invocationInfo.ScriptLineNumber
            pathname     = $invocationInfo.ScriptName
            filename     = $fileName
            caller       = $invocationInfo.Command
            message      = [string] $Message
            rawmessage   = [string] $Message
            body         = $Body
            execinfo     = $ExceptionInfo
            pid          = $PID
        }
        [System.Management.Automation.ErrorRecord] $ExceptionInfo = $null
         $invocationInfo = (Get-PSCallStack)[$Script:Logging.CallerScope]
         #$Script:InitialSessionState = [initialsessionstate]::CreateDefault()
            Modules
            Providers {Registry, Alias, ....
            Assemblies
            Commands

DynamicParam {
        New-LoggingDynamicParam -Level -Mandatory $false -Name "Level"
        $PSBoundParameters["Level"] = "INFO"
    }
    # Split-Path throws an exception if called with a -Path that is null or empty.
        [string] $fileName = [string]::Empty
        f ($PSBoundParameters.ContainsKey('Arguments')) {
            $logMessage["message"] = [string] $Message -f $Arguments
            $logMessage["args"] = $Arguments

         [TimeSpan]$ConsumerStartupTimeout = "00:00:10"

     if ($Script:InitialSessionState.psobject.Properties['ApartmentState']) {
        $Script:InitialSessionState.ApartmentState = [System.Threading.ApartmentState]::MTA
    }

    #>
    
    #Get-PSCallStack
    <#
        Start-Log        {}        test_log_sys.ps1: line 3 
        test_log_sys.ps1 {}        test_log_sys.ps1: line 85
        <ScriptBlock>    {}        <No file>

    # If invoked via powershell.exe, re-invoke via pwsh.exe
if ((Get-Process -Id $PID).Name -eq 'powershell') {
   # $PSCommandPath is the current script's full file path,
   # and @PSBoundParameters uses splatting to pass all 
   # arguments that were bound to declared parameters through.
   # Any extra arguments, if present, are passed through with @args
   pwsh -ExecutionPolicy Bypass -File $PSCommandPath @PSBoundParameters @args
   exit $LASTEXITCODE
}
    piping $PSBoundParameters to Out-Host in order to force synchronous output of the (default) table-formatted representation of its value. The same would apply to outputting any other values that would result in implicit Format-Table formatting not based on predefined formatting data ($args, as an array whose elements are strings isn't affected). (Note that While Out-Host output normally isn't suitable for data output from inside a PowerShell session, it does write to an outside caller's stdout.)
    powershell.exe, the Windows PowerShell CLI; pwsh, the PowerShell (Core) 7+ CLI.
    #>
    #$PSScriptRoot  Where this script sits: D:\qt_projects\filmcab\General
    #Split-Path $MyInvocation.MyCommand.Source
    # https://github.com/RootITUp/Logging/blob/master/Logging/targets/Slack.ps1
<#

$events = @(
     Get-WinEvent  -FilterXml @'
     <QueryList>
      <Query Id="0" Path="Microsoft-Windows-TaskScheduler/Operational">
       <Select Path="Microsoft-Windows-TaskScheduler/Operational">
        *[EventData/Data[@Name='TaskName']='\ttasskkk']
       </Select>
      </Query>
     </QueryList>
'@  -ErrorAction Stop -MaxEvents 2
)
$events

    # Automatic Variables I have in pwsh:
    #  [Environment]::CommandLine  "C:\Program Files\PowerShell\7\pwsh.dll" 
    #            -NoProfile 
    #            -ExecutionPolicy Bypass 
    #            -Command "Import-Module 'c:\Users\jeffs\.vscode\extensions\ms-vscode.powershell-2023.8.0\modules\PowerShellEditorServices\PowerShellEditorServices.psd1'; 
    #  Start-EditorServices 
    #            -HostName 'Visual Studio Code Host' 
    #            -HostProfileId 'Microsoft.VSCode' 
    #            -HostVersion '2023.8.0' 
    #            -AdditionalModules @('PowerShellEditorServices.VSCode') 
    #            -BundledModulesPath 'c:\Users\jeffs\.vscode\extensions\ms-vscode.powershell-2023.8.0\modules' 
    #            -EnableConsoleRepl 
    #            -StartupBanner \"PowerShell Extension v2023.8.0\" 
    #            -LogLevel 'Normal' 
    #            -LogPath 'c:\Users\jeffs\AppData\Roaming\Code\User\globalStorage\ms-vscode.powershell\logs\1703869456-5af92832-835c-4bc5-83d3-2319bce9ec0e1703869454783\EditorServices.log' 
    #            -SessionDetailsPath 'c:\Users\jeffs\AppData\Roaming\Code\User\globalStorage\ms-vscode.powershell\sessions\PSES-VSCode-43552-725051.json' 
    #            -FeatureFlags @() 
    #  $PSBoundVariables

    # Automatic Variable NOT VISIBLE at breakpoint:
    #   $MyInvocation | Format-List -Property *
    #      MyCommand   : Start-Log
    #      PSScriptRoot: D:\qt_projects\filmcab\General
    #      ScriptLineNo: 183 (????)
    #      ScriptName  : D:\qt_projects\filmcab\General\test_log_sys.ps1
    #      CommandOrigin: Internal
    # $MyInvocation | Format-List -Property *

    {CalendarTrigger, , RegistrationTrigger, TimeTrigger}
    NextRunTime, UserId, LastRunTime, LastTaskResult, NumberOfMissedRuns, Enabled
    Author             : $(@%SystemRoot%\system32\Autopilot.dll,-600)
#>
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

# Following code seems to close the popup console window almost immediately if you're calling from Windows Task Scheduler. At least very fast.  I like things that run in the background to run in the background.

Add-Type -name user32 -namespace win32 -memberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
$consoleHandle = (get-process -id $pid).mainWindowHandle
[void][win32.user32]::showWindow($consoleHandle, 0)

Import-Module PowerShellHumanizer # See Write-Count for usage.

Import-Module DellBIOSProvider                                      
                                                                            
# Just an example.

[Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '')]
$TpmStatus = ((Get-ChildItem -Path "DellSmbios:\TPMSecurity\TpmSecurity"|Select CurrentValue).CurrentValue -eq 'Enabled')

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
[Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '')]
$DEFAULT_WINDOWS_TASK_SCHEDULER_TIMESTAMP_FORMAT_XML = 'yyyy-MM-ddTHH:mm:ss.fffffff'

$OutputEncoding = [System.Text.Encoding]::UTF8 

# Just some FYI hey these look cool, but I'm trying to use the TICK functions below in including code.
# https://www.compart.com/en/unicode/category/So
#$UNICODE_SMILEY_FACE                  = 0x1F600            # 😀
#$$UNICODE_BALLOT_X                     = 0x2717             # ✗
#$UNICODE_CROSS_MARK                   = 0x274C             # ❌
#$UNICODE_SPARKLES                     = 0x2728             # ✨
#$UNICODE_HEAVY_EXCLAMATION_MARK       = 0x2757             # ❗
#$UNICODE_BLACK_QUESTION_MARK_ORNAMENT = 0x2753             # ❓
# inspect? 🔬
# push? 💨
# refactor? 🧹
#$UNICODE_OK_HAND_SIGN                 = 0xD83D 0xDC4C
# ⭐
                                                                                                                                        
$pretest_assuming_true = $true                                                         
[Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '')] # Not sure if this is used anywhere, but it's one of my inventions.  Don't set a flag to false without some indication  that "hey this is a presumptive non-value for a variable that cannot hold a null as a type, and it will only have meaning after the following test or successful action."
$pretest_assuming_false = $false

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

# The following pulls the CALLER path.  If you are running this dot file directly, there is no caller set.

$MasterScriptPath = $MyInvocation.ScriptName  # I suppose you could call this a "Name".  It's a file path.

if ([String]::IsNullOrEmpty($masterScriptPath)) {                                                                
    # So instead of "ScriptName", we've got "Line", "Statement", "MyCommand" (which is actually the Script Name), and "PositionMessage" which is a bit messy, but could be used to get the caller.
    Write-Host "`$MyInvocation.ScriptName is empty. Grabbing `MyInvocation.Line"
    $MasterScriptPath = $MyInvocation.Line#.Trim("`' ").TrimEnd('.') # No ScriptName if running this file directly, just Line = . 'D:\qt_projects\filmcab\simplified\_dot_include_standard_header.ps1'  This of course will devolve over PS versions. Why? Because developer constantly finesse stuff and break code.
}                                          

$MasterScriptPath = if ($MasterScriptPath.StartsWith(". .\")) { $MasterScriptPath.Substring(2)} else {$MasterScriptPath}
# For debugging/logging, when was this file changed? When a script changes, you can toss all previous testing out the window.  This script HASNT been tested.  When did your error first occur? Right after the last write time changed? Interesting, maybe it was what changed that broke.
$MasterScriptPath = if ($MasterScriptPath.StartsWith(". '")) { $MasterScriptPath.Substring(2)} else {$MasterScriptPath}                                                                               
$MasterScriptPath = $MasterScriptPath.Trim("'")
# At times, the following code breaks with "Cannot find path 'D:\_dot_include_standard_header.ps1' because it does not exist."
# This cannot be tested by running THIS file. Only calling from a container, and then only intermittently(!) Even exiting VS Code can fail to recause the error.
[Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '')]
$FileTimeStampForParentScript = (Get-Item -Path $MasterScriptPath).LastWriteTime

# We're going to call "scriptName" the Name WITHOUT the bloody directory it's in. I'm torn on name with or without extension - BUT since two files can have same base name with different extensions, and soon there'll be a "ps2" (kidding?), we might as well be careful.
    
[Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '')]
$ScriptName                 = (Get-Item -Path $masterScriptPath).Name # Unlike "BaseName" this includes the extension
[Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '')]
$ScriptNameWithoutExtension = (Get-Item -Path $masterScriptPath).BaseName   # Base name is nice for labelling

$ProjectRoot  = (Get-Location).Path  # in debug, D:\qt_projects\filmcab

New-Variable -Name ScriptRoot -Scope Script -Option ReadOnly -Value ([System.IO.Path]::GetDirectoryName($MyInvocation.PSCommandPath)) -Force
$Script:LogDirectory = "$ScriptRoot\_log"

New-Item -ItemType Directory -Force -Path $Script:LogDirectory|Out-Null
                                                    
$Script:LogFileName = $ScriptName + '.log.txt' 
$Script:LogFilePath = $Script:LogDirectory + '\' + $Script:LogFileName

# Not heavily used yet. Oh well.
$PathToConfig = $ProjectRoot + '\config.json'                                         
[Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '')]
$Config       = (Get-Content -Path $PathToConfig | ConvertFrom-Json)

# Maybe grab HistoryId for how many runs in this session. Debug meta? Note that it resets if the powershell terminal is killt.
                                                                                        
[Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '')]
$CurrentDebugSessionNo = $MyInvocation.HistoryId
                                            
$tryToStartTranscriptAttempts = 0

# Transcript logging is weak, but it's something, as long as you can deal with the locking issues, and not starting and not stopping.
# It locks up in debugging if you restart too soon, and don't hit the Stop-Transcript in the footer.  One try is probably enough     
# Warning: There is no dynamic transcript updates, only on stop-transcript does it write out.
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
        }                                                                                      
        catch {
            # Fails so ignore.
        }
        Start-Sleep -Milliseconds 10.0
    }                                  
}

<#

                        88888888b                              dP   oo                      888888ba           .8888b oo          oo   dP   oo                            
                        88                                     88                           88    `8b          88   "                  88                                 
                        a88aaaa    dP    dP 88d888b. .d8888b. d8888P dP .d8888b. 88d888b.    88     88 .d8888b. 88aaa  dP 88d888b. dP d8888P dP .d8888b. 88d888b. .d8888b. 
                        88        88    88 88'  `88 88'  `""   88   88 88'  `88 88'  `88    88     88 88ooood8 88     88 88'  `88 88   88   88 88'  `88 88'  `88 Y8ooooo. 
                        88        88.  .88 88    88 88.  ...   88   88 88.  .88 88    88    88    .8P 88.  ... 88     88 88    88 88   88   88 88.  .88 88    88       88 
                        dP        `88888P' dP    dP `88888P'   dP   dP `88888P' dP    dP    8888888P  `88888P' dP     dP dP    dP dP   dP   dP `88888P' dP    dP `88888P' 
                        ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

#>                                                

# Bring in libraries that were spread apart just for readability


. .\_dot_include_standard_header_log_functions.ps1

. .\_dot_include_standard_header_sql_functions.ps1

Function Get-CRC32 {
    <#
        .SYNOPSIS
            Calculate CRC.
        .DESCRIPTION
            This function calculates the CRC of the input data using the CRC32 algorithm.
        .EXAMPLE
            Get-CRC32 $data
        .EXAMPLE
            $data | Get-CRC32
        .NOTES
            C to PowerShell conversion based on code in https://www.w3.org/TR/PNG/#D-CRCAppendix

            Author: Øyvind Kallstad
            Date: 06.02.2017
            Version: 1.0
            Returns a 64-bit value, so the "32" is a bit perverse.
        .INPUTS
            byte[]
        .OUTPUTS
            uint32
        .LINK
            https://communary.net/
        .LINK
            https://www.w3.org/TR/PNG/#D-CRCAppendix

    #>
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


<#
.SYNOPSIS
Try and get data to both the terminal AND the log file AND the transcript

.DESCRIPTION
It's hard, but at least it's all in one place.

.PARAMETER s
What to print

.EXAMPLE
An example

.NOTES
#TODO: Switch to humanizer?
#>    

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
          
Function Convert-ByteArrayToHexString ([byte[]] $bytearray) {
    if ($null -eq $bytearray) {return $null}
    return @($bytearray|Format-Hex|Select ascii).Ascii -join ''
}
$md5provider = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
$utf8provider = New-Object -TypeName System.Text.UTF8Encoding

<#
.SYNOPSIS
Generate MD5 hash from string 

.DESCRIPTION
Impossible to remember

.PARAMETER s
Parameter description

.EXAMPLE
An example

.NOTES
Forgot where I was going use it?
#>
Function Hash-String($s) {
    return [System.BitConverter]::ToString($md5provider.ComputeHash($utf8provider.GetBytes($s)))    
}
# Avoid returning these numbers other than where they belong, as in, "exit 39202" just to try and randomly avoid collision and give some sort of searchable number.  A fine idea but we should have numbers tied to mneumonics, and return the string not the digits. Why? Because eventually, in the scheduler, I see a 4001 value, I go "Oh! untrapped! New problem!"

[Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '')]
$_EXITCODE_UNTRAPPED_EXCEPTION           = 4001
$_EXITCODE_GENERIC_AND_USELESS_EXCEPTION = -2146233087

# See Show-Error for how these are generated
[Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '')] # These were hard numbers to generate in order to establish meaningful distinct codes for specific issues. HRESULT is the above generic code in the following cases.
# These are hashes generated from the distinct messages we get when HRESULT is $_EXITCODE_GENERIC_AND_USELESS_EXCEPTION
$_EXITCODE_VARIABLE_NOT_FOUND            = 15631964        # Get-CRC32 -shr 8                                                                                                                                                                              
[Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '')]
$_EXITCODE_SCRIPT_NOT_FOUND              = 4479237
<#
.SYNOPSIS
Display all the error messages availale and exit.

.DESCRIPTION
Initially I had cut and pasted this code around - until I suddenly noticed it was only display the first "Write-Error"!  I converted to Write-AllPlaces, but all the copies. Ugh.  And the failing on LoaderExceptions which isn't always there.

.PARAMETER scriptWhichProducedError
Usually sql, but not necessarily. Yes it reveals secrets to the hack types, I don't care I want to see what failed.  Maintenance before security.

.PARAMETER exitcode
If DontExit is false, then what number to return to the OS?

.PARAMETER DontExit
I default to exiting when there's an error.  My thing. Even in production. Explicitly tell me you've got it covered.

.EXAMPLE
Show-Error -exitcode 23920  #(Int32 I think is Windows limit)
Show-Error -message "ERROR!: I'm running zzz_end_batch_run_session.ps1 AND NO SESSION IS ACTIVE!!!! (1)" -exitcode 2

.NOTES
Could be enhanced. Log to file. Detect new errors, which are more important in debugging. Often lazy developers ignore errors in a priority basis.
#>
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
                               
    $WasAnException = $pretest_assuming_true
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
        $HResult = 0
        $WasThrownFromThrowStatement = $_.Exception.WasThrownFromThrowStatement # An interesting property
        if ($WasThrownFromThrowStatement) { Write-AllPlaces "This exception was from a throw statement"}

        if (Test-Path variable:Exception) {
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
        # ([Int32]"0x80131501") ==> -2146233087 CORRECT! What HResult was.
        # EventData\Data\ResultCode=2148734209 "{0:X}" -f 2148734209 ==> 80131501 CORRECT. Do not use Format-Hex.
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

                                                
$Script:Caller = 'TBD'

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
        # Made up rule: Empty doesn't have a Leftmost character. $null should break the caller.  Returning an empty string as "leftmost character" is a fudge, and causes problems.
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
Write-AllPlaces "How many genre directories were found:          " $(Format-Plural 'Folder' $howManyGenreFolders -includeCount) 

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
    
# TODO: Inflector methods. https://github.com/Humanizr/Humanizer?tab=readme-ov-file#inflector-methods

Function HumanizeCount([Int64]$i) {
    return [string]::Format('{0:N0}', $i)
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
    
<#
.SYNOPSIS
Prep a .NET date time for insertion into a PostgreSQL query.

.DESCRIPTION
Postgres, without a type extension, can only support 6 decimal places of time accuracy.  .NET and Windows and SQL Server support 7, so inprecise comparisons cause accidental difference detection between file timestamps when they are in fact the same.

.PARAMETER date
Powershell Date type, wi  th 7 decimal (100 nanosecond) precision

.EXAMPLE
An example              
                
.NOTES
General notes
#>
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
        $propval = $null

        if(@($sourceob.PSObject.Properties.Name -eq "$prop").Count -eq 1) {$propval = $sourceob.$prop } else { $propval= ''}
        $targetob.$prop = $propval
    }
}

Function Get-Property ($sourceob, $prop) {
    (If(@($sourceob.PSObject.Properties|Where Name -eq "$prop").Count -eq 1) { $sourceob.$prop } else {''})
}

Function Has-Property ($sourceob, $prop) {
    return @($sourceob.PSObject.Properties|Where Name -eq "$prop").Count -eq 1
}
               
Function Create-BatchRunSessionTaskEntry (
    [Int32] $batch_run_session_id,
    [string]$script_name
    ) {  
        
        $FileTimeStampForParentScriptFormatted = $FileTimeStampForParentScript.ToString($DEFAULT_POWERSHELL_TIMESTAMP_FORMAT)
        $script_name_prepped_for_sql = PrepForSql $script_name
        $Script:batch_run_session_task_id = Get-SqlValue("
            INSERT INTO 
                batch_run_sessions_tasks(
                    batch_run_session_id,
                    script_changed,
                    script_name
                )
                VALUES(
                    $batch_run_session_id,
                    '$FileTimeStampForParentScriptFormatted'::TIMESTAMPTZ,
                    $script_name_prepped_for_sql
                )
                RETURNING batch_run_session_task_id
            ")
        return $Script:batch_run_session_task_id
    }
Function Convert-HexStringToByteArray {
    ################################################################
    #.Synopsis
    # Convert a string of hex data into a System.Byte[] array. An
    # array is always returned, even if it contains only one byte.
    #.Parameter String
    # A string containing hex data in any of a variety of formats,
    # including strings like the following, with or without extra
    # tabs, spaces, quotes or other non-hex characters:
    # 0x41,0x42,0x43,0x44
    # \x41\x42\x43\x44
    # 41-42-43-44
    # 41424344
    # The string can be piped into the function too.
    ################################################################
    [CmdletBinding()]
    Param ( [Parameter(Mandatory = $True, ValueFromPipeline = $True)] [String] $String )
    
    #Clean out whitespaces and any other non-hex crud.
    $String = $String.ToLower() -replace '[^a-f0-9\\,x\-\:]',"
    
    #Try to put into canonical colon-delimited format.
    $String = $String -replace '0x|\x|\-|,',':'
    
    #Remove beginning and ending colons, and other detritus.
    $String = $String -replace '^:+|:+$|x|\',"
    
    #Maybe there's nothing left over to convert...
    if ($String.Length -eq 0) { ,@() ; return }
    
    #Split string with or without colon delimiters.
    if ($String.Length -eq 1)
    { ,@([System.Convert]::ToByte($String,16)) }
    elseif (($String.Length % 2 -eq 0) -and ($String.IndexOf(":") -eq -1))
    { ,@($String -split '([a-f0-9]{2})' | foreach-object { if ($_) {[System.Convert]::ToByte($_,16)}}) }
    elseif ($String.IndexOf(":") -ne -1)
    { ,@($String -split ':+' | foreach-object {[System.Convert]::ToByte($_,16)}) }
    else
    { ,@() }
    #The strange ",@(...)" syntax is needed to force the output into an
    #array even if there is only one element in the output (or none).
}
<#
.SYNOPSIS
Execute any actions standard across all scripts in this folder. Generate any helper functions.

.DESCRIPTION
Greatly reduces complexity of client scripts.

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
    BI=1  : BIGINT comes back as Int32
    BI=5  : BIGINT comes back as Int16
    BI=6  : BIGINT comes back as DOUBLE
    BI=2  : BIGINT comes back as Decimal
    BI=7  : BIGINT comes back as Single
    ODBC Enum list doesn't check out: https://learn.microsoft.com/en-us/dotnet/api/system.data.odbc.odbctype?view=dotnet-plat-ext-8.0
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
    $informationalmessagehandler = [System.Data.Odbc.OdbcInfoMessageEventHandler] {param($sender, $event) Write-AllPlaces $event.Message }; 
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
        Invoke-Sql "SET application_name to '$($Script:ScriptName)'" | Out-Null
        Invoke-Sql 'SET search_path = simplified, "$user", public'  | Out-Null    # I'm always in the simplified folder. So just set this here.
                                                                                                                                                   
        # In the first of the first scripts, BEFORE it has run, there is no batch_session_id. We don't create a task id if no session.

        if ($ScriptName -notin('_start_new_batch_run_session.ps1', 'zzz_end_batch_run_session.ps1', '_dot_include_standard_header.ps1') -and
            (Test-Path variable:script:active_batch_run_session_id) -and 
            $Script:active_batch_run_session_id -ne -1) 
        {
            $Script:active_batch_run_session_task_id = Create-BatchRunSessionTaskEntry -batch_run_session_id $Script:active_batch_run_session_id -script_name $ScriptName
        }        
    }

    Start-Log
                                                                   
    if ((Test-Path variable:script:active_batch_run_session_id)) {
        Log-Line "active_batch_run_session_id # = $($Script:active_batch_run_session_id)"
    }

}
                                 
main_for_dot_include_standard_header # So as not to collide with dot includer
                                  
# If we don't see this in log, then it broke.
Log-Line "Exiting standard_header"
<#
 #    FilmCab Daily morning batch run process: Pull in new scheduled task events for identifying which tasks are okay, failing, running long, not getting kicked off.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Prepping.
 #    ###### Tue Jan 23 18:23:11 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #>
 <#
    In support of the logging system, I want to capture what scheduled task ran a script from within the Start-Log of any script. See test_log_sys.ps1
    I hope to avoid unnecessary performance delay to scripts calling Start-Log, but when debugging, it's important to know how a script got started, and with what arguments.
        Was this started from within VS Code?  A debugging run where the user can stop, skip, and completely drop from finishing? If a script run is stopped before completion, that
        can account for odd output. For example, a job run record in a log table with no end stamp, no error caught, no return code, no duration caught.
        Was it run manually from cmd.exe?  I don't know if we can capture if it was a bat file.

        But, if it was called from a Windows Scheduler Registered Task, there are then two possibilities: Either a user kicked it, or a trigger kicked it.

    Warnings:
        A full reload on my small system, for 14,100 events, took 5.5 minutes. This is mostly the part where I extract the custom attributes.
        This filters out events heavily
            1) Task Scheduler Operations - no Maintenance
            2) Events 800 and 808 are alot, and useless

            3) All Microsoft\Windows tasks are excluded
            The heavy filtering reduces both the Get-WinEvents time and the merging eventdata names and values.
            The use of the FilterXML parameter is the key to the best performance in testing
    Questions:
        What does versions 0,1, and 2 indicate in Get-WinEvent? Task versions or
        What's an activity id?
        What is QueuedTaskInstanceId?
        Where is the #cdata? We know it's there. Is it only on maintenance tasks?
        EventType Keywords: ForcedIdleProcessing on record #197
    TODO:
        Deal with rollover, check for ext files.
        Store to database
        Strip out the conversion of '' to null. It doesn't take until extraction.
        Faster???
        Use Quartz.Net?
        Convert Write-AllPlaces to Write-Debug?
    Idea:
        Flush log for speed after we get it to file and/or database
#>
  
try {
. .\_dot_include_standard_header.ps1 # 

$newtaskSchedulerEvents      = @()
$oldtaskSchedulerEvents      = @()

                                        
$TaskSchedulerEventsFileName = 'D:\qt_projects\filmcab\simplified\_data\scheduled-task-events.xml'

<# 
    Force full reload: Warning: YOU WILL LOSE ALL HISTORY!!!!!!! Warning
    Remove-Item -Path "$TaskSchedulerEventsFileName" -Force   # Rebuilds all new, removed attributes.
#>

if (Test-Path $TaskSchedulerEventsFileName -PathType Leaf) {
    $oldtaskSchedulerEvents = Import-Clixml -Path $TaskSchedulerEventsFileName
    $file = Get-Item $TaskSchedulerEventsFileName
    $Script:lastSavedEventCreatedDate = $file.CreationTime
} else {
    $Script:lastSavedEventCreatedDate = 0 # Force a full reload
}

    # Highest performance of Get-WinEvents in testing came from use of FilterXml with the Suppress attribute.  The list of excluded tasknames is maxed out; I think it's the string size on the filter that is limited.
    # $XPath = "*[EventData[Data[@Name='TargetUserName'] and (Data='User1' or Data='User2' or Data='User3')] and System[TimeCreated[timediff(@SystemTime) <= 86400000]]]"
$xmlfilter = @"
<QueryList>
<Query Id="0" Path="Microsoft-Windows-TaskScheduler/Operational">
<Select Path="Microsoft-Windows-TaskScheduler/Operational">*</Select>
<Suppress Path="Microsoft-Windows-TaskScheduler/Operational">
(*[EventData[(Data[@Name='TaskName']='\Microsoft\Windows\LanguageComponentsInstaller\Installation')]]) or
(*[EventData[(Data[@Name='TaskName']='\Microsoft\Windows\UpdateOrchestrator\Schedule Maintenance Work')]]) or
(*[EventData[(Data[@Name='TaskName']='\Microsoft\Windows\UpdateOrchestrator\Schedule Wake To Work')]]) or
(*[EventData[(Data[@Name='TaskName']='\Microsoft\Windows\UpdateOrchestrator\Schedule Work')]]) or
(*[EventData[(Data[@Name='TaskName']='\GoogleUpdateTaskMachine{UAAFF76B46-DA4A-40B7-A0A6-9A0E506CD5DB}')]]) or
(*[EventData[(Data[@Name='TaskName']='\MicrosoftEdgeUpdateTaskMachineUA')]]) or
(*[EventData[(Data[@Name='TaskName']='\Microsoft\Windows\Flighting\OneSettings\RefreshCache')]]) or
(*[EventData[(Data[@Name='TaskName']='\Microsoft\Windows\MemoryDiagnostic\RunFullMemoryDiagnostic')]]) or
(*[EventData[(Data[@Name='TaskName']='\Microsoft\Windows\WindowsUpdate\RUXIM\PLUGScheduler')]]) or
(*[EventData[(Data[@Name='TaskName']='\Microsoft\Windows\WindowsUpdate\Scheduled Start')]]) or
(*[EventData[(Data[@Name='TaskName']='\Microsoft\Office\Office Automatic Updates 2.0')]]) or
(*[EventData[(Data[@Name='TaskName']='\Adobe Acrobat Update Task')]]) or
(*[EventData[(Data[@Name='TaskName']='\Microsoft\Office\Office Feature Updates')]]) or
(*[EventData[(Data[@Name='TaskName']='\Microsoft\Windows\Windows Error Reporting\QueueReporting')]]) or
(*[EventData[(Data[@Name='TaskName']='\Microsoft\Windows\Customer Experience Improvement Program\Consolidator')]]) or
(*[EventData[(Data[@Name='TaskName']='\Mozilla\Firefox Background Update 308046B0AF4A39CB')]]) or
(*[EventData[(Data[@Name='TaskName']='\Microsoft\Windows\CertificateServicesClient\SystemTask')]]) or
(*[EventData[(Data[@Name='TaskName']='\Microsoft\Windows\CertificateServicesClient\UserTask')]]) or
(*[EventData[(Data[@Name='TaskName']='\Microsoft\Office\Office ClickToRun Service Monitor')]]) or
(*[EventData[(Data[@Name='TaskName']='\Mozilla\Firefox Background Update 308046B0AF4A39CB')]]) or
(*[EventData[(Data[@Name='TaskName']='\Microsoft\Windows\SoftwareProtectionPlatform\SvcRestartTask')]])
</Suppress>
</Query>
</QueryList>
"@       
$newtaskSchedulerEvents =
    Get-WinEvent -FilterXml $xmlfilter|                                         
Where TimeCreated -ge $lastSavedEventCreatedDate|                   
Where Id -NotIn @(800, 808)|                                               
Select @{Name = 'event_type_id'      ; Expression = {$_.Id}}            ,
    @{Name = 'event_type_name'       ; Expression={$_.TaskDisplayName}},   # is it taskdisplay? event code? event id?
    @{Name = 'event_version'         ; Expression= {$_.Version}},          # I think this is the task version?
    @{Name = 'general_operation_code'; Expression={$_.OpcodeDisplayName}},
    @{Name = 'event_created'         ; Expression= {$_.TimeCreated}},
    @{Name = 'event_message'         ; Expression= {$_.Message}}    ,
    @{Name = 'event_message_template'; Expression= {[string]$null}}  ,       # Filled in later
    @{Name = 'user_id'               ; Expression = {$_.UserId.Value}},     # UserId is a PSCustomObject, so take the string value
    @{Name = 'activity_id'           ; Expression = {$_.ActivityId}},     # Somehow, this is storing nulls instead of empty string. aka correlation_id
    @{Name = 'record_id'             ; Expression = {$_.RecordId}},     # A rollover record id, but it gives us something to reference singular events. Sort of.
    @{Name='Account'; Expression = {
        if ($_.Id -in @(711)) {
                      if ($_.Id -in @(711) -and $_.Version -eq 0) {
        $_.Properties[0].Value
        }
        }
     }},
    @{Name='ActionName'; Expression = {
        if ($_.Id -in @(201,202,203,200)) {
                      if ($_.Id -in @(201,200) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }          elseif ($_.Id -in @(200) -and $_.Version -eq 1) {
        $_.Properties[1].Value
        }          elseif ($_.Id -in @(202,203) -and $_.Version -eq 0) {
        $_.Properties[2].Value
        }          elseif ($_.Id -in @(201,202) -and $_.Version -eq 1) {
        $_.Properties[2].Value
        }          elseif ($_.Id -in @(201) -and $_.Version -eq 2) {
        $_.Properties[2].Value
        }
        }
     }},
    @{Name='Command'; Expression = {
        if ($_.Id -in @(310,311)) {
                      if ($_.Id -in @(310,311) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }
        }
     }},
    @{Name='Context'; Expression = {
        if ($_.Id -in @(105)) {
                      if ($_.Id -in @(105) -and $_.Version -eq 0) {
        $_.Properties[0].Value
        }
        }
     }},
    @{Name='CurrentQuota'; Expression = {
        if ($_.Id -in @(131,132)) {
                      if ($_.Id -in @(132) -and $_.Version -eq 0) {
        $_.Properties[0].Value
        }          elseif ($_.Id -in @(131) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }
        }
     }},
    @{Name='DATA'; Expression = {
        if ($_.Id -in @(511)) {
                      if ($_.Id -in @(511) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }
        }
     }},
    @{Name='DATA1'; Expression = {
        if ($_.Id -in @(510)) {
                      if ($_.Id -in @(510) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }
        }
     }},
    @{Name='DATA2'; Expression = {
        if ($_.Id -in @(510)) {
                      if ($_.Id -in @(510) -and $_.Version -eq 0) {
        $_.Properties[2].Value
        }
        }
     }},
    @{Name='DetectionResult'; Expression = {
        if ($_.Id -in @(512)) {
                      if ($_.Id -in @(512) -and $_.Version -eq 0) {
        $_.Properties[0].Value
        }
        }
     }},
    @{Name='EnginePID'; Expression = {
        if ($_.Id -in @(202,201,200)) {
                      if ($_.Id -in @(200) -and $_.Version -eq 1) {
        $_.Properties[3].Value
        }          elseif ($_.Id -in @(202) -and $_.Version -eq 1) {
        $_.Properties[4].Value
        }          elseif ($_.Id -in @(201) -and $_.Version -eq 2) {
        $_.Properties[4].Value
        }
        }
     }},
    @{Name='ErrorCode'; Expression = {
        if ($_.Id -in @(802,803,801)) {
                      if ($_.Id -in @(802,801) -and $_.Version -eq 0) {
        $_.Properties[0].Value
        }          elseif ($_.Id -in @(803) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }
        }
     }},
    @{Name='ErrorDescription'; Expression = {
        if ($_.Id -in @(401,403,404,303,311,104)) {
                      if ($_.Id -in @(401,403,404) -and $_.Version -eq 0) {
        $_.Properties[0].Value
        }          elseif ($_.Id -in @(303,104) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }          elseif ($_.Id -in @(311) -and $_.Version -eq 0) {
        $_.Properties[2].Value
        }
        }
     }},
    @{Name='Failure Reason'; Expression = {
        if ($_.Id -in @(809)) {
                      if ($_.Id -in @(809) -and $_.Version -eq 0) {
        $_.Properties[0].Value
        }
        }
     }},
    @{Name='File'; Expression = {
        if ($_.Id -in @(998)) {
                      if ($_.Id -in @(998) -and $_.Version -eq 0) {
        $_.Properties[2].Value
        }
        }
     }},
    @{Name='hc_stateid'; Expression = {
        if ($_.Id -in @(800)) {
                      if ($_.Id -in @(800) -and $_.Version -eq 0) {
        $_.Properties[0].Value
        }
        }
     }},
    @{Name='HRESULT'; Expression = {
        if ($_.Id -in @(998)) {
                      if ($_.Id -in @(998) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }
        }
     }},
    @{Name='IdleTaskId'; Expression = {
        if ($_.Id -in @(501,504,500,505,502,503)) {
                      if ($_.Id -in @(501,504,500,505,502,503) -and $_.Version -eq 0) {
        $_.Properties[0].Value
        }
        }
     }},
    @{Name='InfoCode'; Expression = {
        if ($_.Id -in @(806)) {
                      if ($_.Id -in @(806) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }
        }
     }},
    @{Name='InstanceId'; Expression = {
        if ($_.Id -in @(123,120,122,125,121,111,118,117,114,110,109,108,107,103,102,100,119,124)) {
                      if ($_.Id -in @(111,118,117,114,110,109,108,107,103) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }          elseif ($_.Id -in @(123,120,122,125,121,102,100,119,124) -and $_.Version -eq 0) {
        $_.Properties[2].Value
        }
        }
     }},
    @{Name='LastRunDateTime'; Expression = {
        if ($_.Id -in @(800)) {
                      if ($_.Id -in @(800) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }
        }
     }},
    @{Name='LauncherId'; Expression = {
        if ($_.Id -in @(807)) {
                      if ($_.Id -in @(807) -and $_.Version -eq 0) {
        $_.Properties[0].Value
        }
        }
     }},
    @{Name='Line'; Expression = {
        if ($_.Id -in @(998)) {
                      if ($_.Id -in @(998) -and $_.Version -eq 0) {
        $_.Properties[3].Value
        }
        }
     }},
    @{Name='LogPoint'; Expression = {
        if ($_.Id -in @(151)) {
                      if ($_.Id -in @(151) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }
        }
     }},
    @{Name='Name'; Expression = {
        if ($_.Id -in @(998)) {
                      if ($_.Id -in @(998) -and $_.Version -eq 0) {
        $_.Properties[0].Value
        }
        }
     }},
    @{Name='NewTaskInstanceId'; Expression = {
        if ($_.Id -in @(323)) {
                      if ($_.Id -in @(323) -and $_.Version -eq 0) {
        $_.Properties[2].Value
        }
        }
     }},
    @{Name='NoIdleReason'; Expression = {
        if ($_.Id -in @(510)) {
                      if ($_.Id -in @(510) -and $_.Version -eq 0) {
        $_.Properties[0].Value
        }
        }
     }},
    @{Name='NotificationType'; Expression = {
        if ($_.Id -in @(509)) {
                      if ($_.Id -in @(509) -and $_.Version -eq 0) {
        $_.Properties[0].Value
        }
        }
     }},
    @{Name='Parameter'; Expression = {
        if ($_.Id -in @(414)) {
                      if ($_.Id -in @(414) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }
        }
     }},
    @{Name='Path'; Expression = {
        if ($_.Id -in @(129)) {
                      if ($_.Id -in @(129) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }
        }
     }},
    @{Name='Priority'; Expression = {
        if ($_.Id -in @(129)) {
                      if ($_.Id -in @(129) -and $_.Version -eq 0) {
        $_.Properties[3].Value
        }
        }
     }},
    @{Name='ProcessId'; Expression = {
        if ($_.Id -in @(501,502,310,503,500,129,300,505,504)) {
                      if ($_.Id -in @(501,502,503,500,300,505,504) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }          elseif ($_.Id -in @(310,129) -and $_.Version -eq 0) {
        $_.Properties[2].Value
        }
        }
     }},
    @{Name='QueuedTaskInstanceId'; Expression = {
        if ($_.Id -in @(325,324)) {
                      if ($_.Id -in @(325,324) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }
        }
     }},
    @{Name='Reason'; Expression = {
        if ($_.Id -in @(512)) {
                      if ($_.Id -in @(512) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }
        }
     }},
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
    @{Name='RunningTaskInstanceId'; Expression = {
        if ($_.Id -in @(324)) {
                      if ($_.Id -in @(324) -and $_.Version -eq 0) {
        $_.Properties[2].Value
        }
        }
     }},
    @{Name='SecurityDescriptor'; Expression = {
        if ($_.Id -in @(708)) {
                      if ($_.Id -in @(708) -and $_.Version -eq 0) {
        $_.Properties[0].Value
        }
        }
     }},
    @{Name='State'; Expression = {
        if ($_.Id -in @(509)) {
                      if ($_.Id -in @(509) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }
        }
     }},
    @{Name='StoppedTaskInstanceId'; Expression = {
        if ($_.Id -in @(323)) {
                      if ($_.Id -in @(323) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }
        }
     }},
    @{Name='String'; Expression = {
        if ($_.Id -in @(999)) {
                      if ($_.Id -in @(999) -and $_.Version -eq 0) {
        $_.Properties[0].Value
        }
        }
     }},
    @{Name='Task'; Expression = {
        if ($_.Id -in @(805,803,808,804,806)) {
                      if ($_.Id -in @(805,803,808,804,806) -and $_.Version -eq 0) {
        $_.Properties[0].Value
        }
        }
     }},
    @{Name='TaskCount'; Expression = {
        if ($_.Id -in @(309)) {
                      if ($_.Id -in @(309) -and $_.Version -eq 0) {
        $_.Properties[0].Value
        }
        }
     }},
    @{Name='TaskEngineName'; Expression = {
        if ($_.Id -in @(320,319,318,317,316,315,314,313,312,311,301,300,133,304,303,305,306,307,134,308,309,310)) {
                      if ($_.Id -in @(320,319,318,317,316,315,314,313,312,311,301,300,303,306,307,134,308,310) -and $_.Version -eq 0) {
        $_.Properties[0].Value
        }          elseif ($_.Id -in @(133,304,305,309) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }
        }
     }},
    @{Name='TaskInstanceId'; Expression = {
        if ($_.Id -in @(331,329,328,200,330,327,201,322,203,320,202,304)) {
                      if ($_.Id -in @(331,329,328,330,327,322,203,320,202) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }          elseif ($_.Id -in @(201,202) -and $_.Version -eq 1) {
        $_.Properties[1].Value
        }          elseif ($_.Id -in @(201) -and $_.Version -eq 2) {
        $_.Properties[1].Value
        }          elseif ($_.Id -in @(200,201,304) -and $_.Version -eq 0) {
        $_.Properties[2].Value
        }          elseif ($_.Id -in @(200) -and $_.Version -eq 1) {
        $_.Properties[2].Value
        }
        }
     }},
    @{Name='TaskName'; Expression = {
        if ($_.Id -in @(108,102,121,122,123,124,125,126,127,128,129,130,131,133,101,706,707,119,708,109,107,110,111,714,112,713,113,106,114,116,117,118,709,103,120,135,148,331,332,140,330,329,328,327,326,201,325,333,324,323,322,319,202,203,204,205,305,304,334,100,149,200,141,414,142,146,147,153,150,152,151)) {
                      if ($_.Id -in @(108,102,121,122,123,124,125,126,127,128,129,130,131,133,101,706,707,119,109,107,110,111,714,112,713,113,106,114,116,117,118,709,103,120,135,148,331,332,140,330,329,328,327,326,201,325,333,324,323,322,202,203,204,205,305,304,334,100,149,141,414,200,142,146,147,153,150,152,151) -and $_.Version -eq 0) {
        $_.Properties[0].Value
        }          elseif ($_.Id -in @(201,202,200) -and $_.Version -eq 1) {
        $_.Properties[0].Value
        }          elseif ($_.Id -in @(201) -and $_.Version -eq 2) {
        $_.Properties[0].Value
        }          elseif ($_.Id -in @(708,319) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }
        }
     }},
    @{Name='TaskPath'; Expression = {
        if ($_.Id -in @(155)) {
                      if ($_.Id -in @(155) -and $_.Version -eq 0) {
        $_.Properties[0].Value
        }
        }
     }},
    @{Name='TaskStatus'; Expression = {
        if ($_.Id -in @(706)) {
                      if ($_.Id -in @(706) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }
        }
     }},
    @{Name='ThreadID'; Expression = {
        if ($_.Id -in @(310)) {
                      if ($_.Id -in @(310) -and $_.Version -eq 0) {
        $_.Properties[3].Value
        }
        }
     }},
    @{Name='TimeSinceUserNotPresent'; Expression = {
        if ($_.Id -in @(511)) {
                      if ($_.Id -in @(511) -and $_.Version -eq 0) {
        $_.Properties[0].Value
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
     }}|
    Where TaskName -NotLike '\Microsoft*'|  # I would get rid of these in the XMLFilter, but there's a string size limit that breaks
    Where TaskName -NotLike '\OneDrive*'|
    Where TaskName -NotLike '\Mozilla*'|
    Where TaskName -NotLike '\Google*'|
    Where TaskName -NotLike 'NT Task*'|
    Where TaskName -NotLike '\Git for Windows*'

Write-AllPlaces "Completed pull from API"
$scriptTimer.Elapsed.TotalSeconds
 
$taskSchedulerEvents = @()

$howManyOldEvents = @($oldtaskSchedulerEvents).Count

if ($howManyOldEvents -ne 0 ){
    $taskSchedulerEvents+= $oldtaskSchedulerEvents
}

$howManyNewEvents = @($newtaskSchedulerEvents).Count

if ($howManyNewEvents -ne 0) {
    if ($howManyOldEvents -ne 0) {
        $taskSchedulerEvents+= $newtaskSchedulerEvents
    } else {
        $taskSchedulerEvents = $newtaskSchedulerEvents
    }
    $taskSchedulerEvents|Export-Clixml -Path $TaskSchedulerEventsFileName
    Write-AllPlaces "Wrote to xml file, $howManyNewEvents new events"                                      
    
    # Set the file date to the event date, thereby having an easy metadata value without creating other stores.
    
    $file = Get-Item $TaskSchedulerEventsFileName          
    $Script:latestEventCreatedDate = ($taskSchedulerEvents|Select event_created).event_created|Sort -Descending|Select -first 1
    $file.CreationTime = $Script:latestEventCreatedDate
}

# Scan our pile for any new task creations or deletions, or updates
                                                        
$taskSchedulerEvents|
Select *|
Where event_type_id -in @(113, 106, 116, 140, 141, 115, 142, 107, 100, 102, 129)|
Select  record_id, 
        event_type_name, 
        event_created,                                   
        @{Name='task_full_path'                       ; Expression={$_.TaskName}}, 
        @{Name='event_created_as_sortable_str_with_ms'; Expression={$_.event_created.ToString('yyyy-MM-dd HH:mm:ss:ffffff')}},  # The default output of datetime is only to seconds, and many of these related events are within milliseconds of each other, so ordering and understanding is improved when we can see which came first, and not depend on record_id
        @{Name='UserName'                             ; Expression={if($_.UserName -eq '') { $null } else { $_.UserName.Replace($computer + '\', '')}}}, 
        @{Name='UserContext'                          ; Expression={if($_.UserContext -eq '') { $null } else { $_.UserContext.Replace($computer + '\', '')}}}|
        Select *,
        @{Name='merged_user_id'                       ; Expression={if($_.UserName -ne $null) {$_.UserName} else {$_.UserContext}}} -ExcludeProperty user_id |
        Select *,
        @{Name='user_id'                              ; Expression={Convert-SidToUser($_.merged_user_id)}} |
        Select * -ExcludeProperty merged_user_id, UserName, UserContext|
        Sort event_created|  # Looks like datetime sorts including the ms portion even if it's not visible.
        Format-Table

# Load Scheduled Defs from file if present

# Traverse our list: Any relevant user task ddl changes?

# Is last task def in storage older than latest scanned event task creation event?

# Yes? Pull new tasks and add to our storage

}
catch {
    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}                                  
finally {
    Write-AllPlaces "Finally"
    . .\_dot_include_standard_footer.ps1
}

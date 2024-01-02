<####################################################################################################################################################################

     *** Reload all registered scheduled tasks. Very slow. ***

####################################################################################################################################################################>

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Scope='Function', Target='Log-*', Justification='Log is a verb. It shortens my code not using Write-Log etc.')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', Justification='Phrases like "Select" and "Where" are more logical than Select-Object, Where-Object')]
param()

$path_to_extracted_task_xml = "D:\qt_projects\filmcab\simplified\all_sched_tasks.xml"

#if (-Not (Test-Path $path_to_extracted_task_xml -PathType Leaf)) { 
$taskobjects = @()

if ($true) { 
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $ErrorActionPreference = 'Stop' # Mandatory for Catch to work
    $registeredtaskobjects = Get-ScheduledTask|Select *
    $registeredtasksxml = @()
    $howmanyregisteredtasks = $registeredtaskobjects.Count
    #$howmanyregisteredtasks = 1
    $registeredtaskobject = [PSCustomObject]@{
        task_id                         = [int]-1;
        task_path                       = '';
        task_name                       = '';
        task_full_path                  = '';
        task_description                = '';
        task_author                     = '';
        task_state                      = '';
        task_source                     = '';
        task_creation_date              = [datetime]0;
        AllowDemandStart                = [bool]$null;
        AllowHardTerminate              = [bool]$null;  #True
        Compatibility                   = '';  #Vista
        DeleteExpiredTaskAfter          = ''; #
        DisallowStartIfOnBatteries      = [bool]$null;  #True
        Enabled                         = [bool]$null;  #True
        ExecutionTimeLimit              = '';  #PT72H
        Hidden                          = [bool]$null;  #False
        IdleSettings                    = '';  #MSFT_TaskIdleSettings
            IdleDuration                = ''; #PT10M
            RestartOnIdle               = [bool]$null;
            StopOnIdleEnd               = [bool]$null;
            WaitTimeout                 = ''; # PT1H
            #PSComputerName
        MultipleInstances               = '';  #IgnoreNew, Parallel
        NetworkSettings                 = '';  #MSFT_TaskNetworkSettings
            NetworkId                   = 
            NetworkName 
            NetworkComputerName 
        Priority                        = [int]-1;  #7, 4
        RestartCount                    = [int]-1;  #0, 2
        RestartInterval                 = ''; #
        RunOnlyIfIdle                   = [bool]$null;  #False
        RunOnlyIfNetworkAvailable       = [bool]$null;  #False
        StartWhenAvailable              = [bool]$null;  #True
        StopIfGoingOnBatteries          = [bool]$null;  #True
        WakeToRun                       = [bool]$null;  #False
        DisallowStartOnRemoteAppSession = [bool]$null;  #False
        UseUnifiedSchedulingEngine      = [bool]$null;  #False, True
        MaintenanceSettings             = ''; #
            Deadline                    = ''; # P2D
            Exclusive                   = [bool]$null; #False
            Period                      = ''; # P1D
            #PSComputerName
        volatile                        = [bool]$null;  #False
        PSComputerName                  = '';  #
        task_xml                        = [XML]$null;
    }
    $startatindex = 0
    for (($task_index = $startatindex); $task_index -lt $howmanyregisteredtasks; $task_index++) {
                Write-Host "Reading details for Task #$task_index"
                try {
                    $registeredtaskobjectraw = $registeredtaskobjects[$task_index]
                    $registeredtaskobject.task_id            = $task_index
                    $registeredtaskobject.task_path          = $registeredtaskobjectraw.TaskPath
                    $registeredtaskobject.task_name          = $registeredtaskobjectraw.TaskName
                    $registeredtaskobject.task_full_path     = $registeredtaskobjectraw.URI
                    $registeredtaskobject.task_creation_date = $registeredtaskobjectraw.Date
                    $registeredtaskobject.task_description   = $registeredtaskobjectraw.Description
                    $registeredtaskobject.task_state         = $registeredtaskobjectraw.State
                    $registeredtaskobject.task_source        = $registeredtaskobjectraw.Source
                    $registeredtaskobject.task_author        = $registeredtaskobjectraw.Author
                    $registeredtaskobject.task_xml           = [XML](Export-ScheduledTask -TaskPath $registeredtaskobject.task_path -TaskName $registeredtaskobject.task_name)
                }
                catch {
                    Write-Host "Error on #$task_index"
                }
                $taskobjects+= $registeredtaskobject
            }
    $sw.Stop()
    $sw.Elapsed

    $registeredtasksxml|Export-Clixml -Path $path_to_extracted_task_xml
}


<####################################################################################################################################################################

     Load previously extracted registered scheduled tasks.

###################################################################################################################################################################>

$registeredtasksxml = Import-Clixml -Path $path_to_extracted_task_xml

# Parse the XML hierarchy into 3 arrays: The Tasks, their Actions, and their Triggers. Principals are part of the task since they appear to be one-to-one.

$tasksExpanded = 
$registeredtasksxml|
    Select @{Name ='task_id';expression = {$_.id}} -Expand xmldata|
    Select task_id -Expand Task

$taskRegistrationInfo = 
$tasksExpanded|
    Select task_id, 
        @{Name ='task_full_name'          ; Expression = {$_.URI}},
        @{Name ='task_creation_date'      ; Expression = {$_.Date}},
        @{Name ='task_author'             ; Expression = {$_.Author}},
        @{Name ='task_description'        ; Expression = {$_.Description}},
        @{Name ='task_security_descriptor'; Expression = {$_.SecurityDescriptor}},
        @{Name ='task_source'             ; Expression = {$_.Source}}

$tasksSettings =
$tasksExpanded|
    Select task_id -Expand Settings|
    Select task_id, 
        @{Name ='MultipleInstancesPolicy'        ; Expression = {$_.MultipleInstancesPolicy}},# : IgnoreNew
        @{Name ='DisallowStartIfOnBatteries'     ; Expression = {$_.DisallowStartIfOnBatteries}},# : false
        @{Name ='StopIfGoingOnBatteries'         ; Expression = {$_.StopIfGoingOnBatteries}},# : false
        @{Name ='AllowHardTerminate'             ; Expression = {$_.URI}},# : true
        @{Name ='StartWhenAvailable'             ; Expression = {$_.URI}},# : true
        @{Name ='RunOnlyIfNetworkAvailable'      ; Expression = {$_.URI}},# : false
        @{Name ='IdleSettings'                   ; Expression = {$_.URI}},# : IdleSettings
        @{Name ='AllowStartOnDemand'             ; Expression = {$_.URI}},# : true
        @{Name ='Enabled'                        ; Expression = {$_.URI}},# : true
        @{Name ='Hidden'                         ; Expression = {$_.URI}},# : false
        @{Name ='RunOnlyIfIdle'                  ; Expression = {$_.URI}},# : false
        @{Name ='DisallowStartOnRemoteAppSession'; Expression = {$_.URI}},# : false
        @{Name ='UseUnifiedSchedulingEngine'     ; Expression = {$_.URI}},# : false
        @{Name ='WakeToRun'                      ; Expression = {$_.URI}},# : false
        @{Name ='ExecutionTimeLimit'             ; Expression = {$_.URI}},# : PT12H5M
        @{Name ='Priority'                       ; Expression = {$_.URI}}# : 7

$taskPrincipals = 
$tasksExpanded|
    Select task_id -Expand Principals|
    Select task_id -Expand Principal|
    Select task_id, 
        @{Name ='principal_id';Expression={$_.id}}, 
        @{Name ='user_id'     ; Expression= {$_.UserId}}, 
        @{Name ='logon_type'  ; Expression= {$_.LogonType}}, 
        @{Name ='group_id'    ; Expression = {$_.GroupId}}, 
        @{Name ='run_level'   ; Expression = {$_.RunLevel}}

<#
    Most Actions are of type Exec, the rest are two separate paired objects: Context and ComHandle, not something I expect will trigger, so I'm not loading them.
#>
$taskActionsExec = 
$registeredtasksxml|
        Select @{Name ='task_id';expression = {$_.id}} -Expand xmldata|
        Select task_id -Expand Task|
        Select task_id -Expand Actions|
        ForEach-Object {$index = 0} {
            [PSCustomObject] @{
                task_id    = $_.task_id;
                action_command_path = $_.Exec.Command; 
                action_command_arguments = $_.Exec.Arguments; 
                action_command_working_dir = $_.Exec.WorkingDirectory;
                };
                $index++; 
        }| Where action_command_path -ne $null

$taskActionsExec = 
# $registeredtasksxml|ForEach-Object {$index = 0} {
#     Select @{Name ='task_id';expression = {$_.id}} -Expand xmldata|Select task_id -Expand Task|
#     {
#         $_.task_id
#     }
#     }

$taskCalendarTriggers = 
$registeredtasksxml| ForEach-Object {
    $_|
    Select @{Name ='task_id';expression = {$_.id}} -Expand xmldata|Select task_id -Expand Task|Select task_id -Expand Triggers|Select task_id -Expand CalendarTrigger -ErrorAction Ignore|
        ForEach-Object {$index = 0} {
            [PSCustomObject] @{ 
                task_id = $_.task_id; 
                task_trigger_no = $index; 
                start_date = $_.StartBoundary;
                stop_date = $_.EndBoundary;
                trigger_is_enabled = $_.Enabled;
                random_delay_code = $_.RandomDelay;
                }; 
                $index++
        }
    }

$taskCalendarTriggerSchedByDay = $registeredtasksxml|Select @{Name ='task_id';expression = {$_.id}} -Expand xmldata|Select task_id -Expand Task|Select task_id -Expand Triggers|Select task_id -Expand CalendarTrigger -ErrorAction Ignore|Select task_id -Expand ScheduleByDay -ErrorAction Ignore
$taskCalendarTriggerSchedByWeek = $registeredtasksxml|Select @{Name ='task_id';expression = {$_.id}} -Expand xmldata|Select task_id -Expand Task|Select task_id -Expand Triggers|Select task_id -Expand CalendarTrigger -ErrorAction Ignore|Select task_id -Expand ScheduleByWeek -ErrorAction Ignore
$taskCalendarTriggerSchedByWeekWhichDays = $registeredtasksxml|Select @{Name ='task_id';expression = {$_.id}} -Expand xmldata|Select task_id -Expand Task|Select task_id -Expand Triggers|Select task_id -Expand CalendarTrigger -ErrorAction Ignore|Select task_id -Expand ScheduleByWeek -ErrorAction Ignore|
    Select task_id, WeeksInterval -Expand DaysOfWeek
$taskCalendarTriggerSchedByMonth = $registeredtasksxml|Select @{Name ='task_id';expression = {$_.id}} -Expand xmldata|Select task_id -Expand Task|Select task_id -Expand Triggers|Select task_id -Expand CalendarTrigger -ErrorAction Ignore|Select task_id -Expand ScheduleByMonth -ErrorAction Ignore

Class TaskFlatDef {
    [int]     $task_id                        = -1
    [string]  $task_full_name                 = ''
    [datetime] $task_creation_date            = 0
    [string]   $task_description              = '' # Cannot be null or I can't get a type
    [string]   $task_author                   = ''
    [string]   $task_security_descriptor      = ''
    [string]   $task_source                   = ''
    [string]   $principal_id                  = ''
    [string]   $user_id                       = ''
    [string]   $logon_type                    = ''
    [string]   $group_id                      = ''
    [string]   $run_level                     = ''
    [string]   $action_command_path           = ''
    [string]   $action_command_arguments      = ''
    [string]   $action_command_working_dir    = ''

    TaskFlatDef([PSCustomObject]$ob) {
        $ob.psobject.properties | Foreach { 
            $type = $_.TypeNameOfValue
            #Write-Host "input type = $type"
            $targettype = ($this.($_.Name)).GetType().Name
            #Write-Host "target type = $targettype"
            if ($targettype -eq 'datetime' -and $null -eq $_.Value) {
                $this.($_.Name) = 0
            } else {
                $this.($_.Name) = $_.Value
            }
        }
    }
    InitFromPSCustOb([PSCustomObject]$ob) {
        $ob.psobject.properties | Foreach { 
            $type = $_.TypeNameOfValue
            #Write-Host "input type = $type for target $($_.Name)"
            $targettype = "String"

            if ($null -ne ($this.($_.Name))) {
                $targettype = ($this.($_.Name)).GetType().Name
            }
            #Write-Host "target type = $targettype"
            if ($targettype -eq 'datetime' -and $null -eq $_.Value) {
                $this.($_.Name) = 0
            } else {
                $this.($_.Name) = $_.Value
            }
        }
    }
    TaskFlatDef() {$this.Init(@{}) }
    TaskFlatDef([hashtable]$Properties) { $this.Init($Properties) }
    [void] Init([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }
}

$TaskFlatDefInst = [TaskFlatDef]::new($taskRegistrationInfo[0])
$TaskFlatDefInst.InitFromPSCustOb($taskPrincipals[0])

Class TaskActionExecDef {
    [int]    $task_id                        = -1
    [string] $action_command_path  = ''
    [string] $action_command_arguments = ''
    [string] $action_command_working_dir = ''
    TaskActionExecDef([PSCustomObject]$ob) {
        $ob.psobject.properties | Foreach { 
            $type = $_.TypeNameOfValue
            #Write-Host "input type = $type"
            $targettype = ($this.($_.Name)).GetType().Name
            #Write-Host "target type = $targettype"
            if ($targettype -eq 'datetime' -and $null -eq $_.Value) {
                $this.($_.Name) = 0
            } else {
                $this.($_.Name) = $_.Value
            }
        }
    }
}

Class TaskTriggerCalFlatDef {
    [int]     $task_id                        = -1
    [int]     $task_trigger_no                = -1
    [datetime] $start_date                    = 0
    [datetime] $stop_date                     = 0
    [bool]     $trigger_is_enabled            = $false
    [string]   $random_delay_code             = ''
    [string]   $daysinterval                  = ''
    [string]   $weeksinterval                 = ''
    [string]   $daysofweek                    = ''
    TaskTriggerCalFlatDef([PSCustomObject]$ob) {
        $ob.psobject.properties | Foreach { 
            $type = $_.TypeNameOfValue
            #Write-Host "input type = $type"
            $targettype = ($this.($_.Name)).GetType().Name
            #Write-Host "target type = $targettype"
            if ($targettype -eq 'datetime' -and $null -eq $_.Value) {
                $this.($_.Name) = 0
            } else {
                $this.($_.Name) = $_.Value
            }
        }
    }

}

$TaskTriggerCalFlatDefInst = [TaskTriggerCalFlatDef]::new($taskCalendarTriggers[0])

Class TaskTriggerFlatDef {
    [int]     $task_id                        = -1
}


$taskLogonTriggers = $registeredtasksxml|Select @{Name ='task_id';expression = {$_.id}} -Expand xmldata|Select task_id -Expand Task|Select task_id -Expand Triggers| Select task_id -Expand LogonTrigger -ErrorAction Ignore
#$taskLogonTriggerRepetitions = $registeredtasksxml|Select @{Name ='task_id';expression = {$_.id}} -Expand xmldata|Select task_id -Expand Task|Select task_id -Expand Triggers| Select task_id -Expand LogonTrigger -ErrorAction Ignore|Select task_id -Expand Repetition -ErrorAction Ignore

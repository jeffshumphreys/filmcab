<####################################################################################################################################################################

     *** Reload all registered scheduled tasks. Very slow. ***

####################################################################################################################################################################>

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Scope='Function', Target='Log-*', Justification='Log is a verb. It shortens my code not using Write-Log etc.')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()

$path_to_extracted_task_xml = "D:\qt_projects\filmcab\simplified\all_sched_tasks.xml"

$taskobjects = @()
$taskactions = @()
$tasktriggers = @()

<#
    if ((Test-Path $path_to_extracted_task_xml -PathType Leaf)) { 
        # Get file timestamp
        # Get last task registration event timestamps
        if > than file time
            reload entirety?
            Or just load those entries added. But, the index will not match. Maybe just add to end?  Hmmm
        else
            use file, no reload
#>

if ($true) { 
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $ErrorActionPreference = 'Stop' # Mandatory for Catch to work
    $registeredtaskobjects = Get-ScheduledTask|Select *
    $registeredtasksxml = @()
    $howmanyregisteredtasks = $registeredtaskobjects.Count
    #$howmanyregisteredtasks = 1
    $startatindex = 0
    for (($task_index = $startatindex); $task_index -lt $howmanyregisteredtasks; $task_index++) {
        $registeredtaskobject = [PSCustomObject]@{
            task_id                              = [int]-1;
            task_path                            = '';
            task_name                            = '';
            task_full_path                       = '';
            task_description                     = '';
            task_author                          = '';
            task_state                           = '';
            task_source                          = '';
            task_version                         = '';
            task_creation_date                   = [datetime]0;
            task_multi_inst_run_rule             = ''; #MultipleInstances = '';  #IgnoreNew, Parallel
            execution_time_limit                 = '';  #PT72H
            security_descriptor                  = '';
            compatibility                        = '';  #Vista
            delete_expired_task_after            = ''; #
            task_is_enabled                      = [bool]$null;  #True
            task_is_hidden                       = [bool]$null;  #False
            allow_demand_start                   = [bool]$null;
            allow_hard_terminate                 = [bool]$null;  #True
            disallow_start_if_on_batteries       = [bool]$null;  #True
            priority                             = [int]-1;  #7,           4
            restart_count                        = [int]-1;  #0,           2
            restart_interval                     = ''; #
            run_only_if_idle                     = [bool]$null;  #False
            run_only_if_network_available        = [bool]$null;  #False
            start_when_available                 = [bool]$null;  #True
            stop_if_going_on_batteries           = [bool]$null;  #True
            wake_to_run                          = [bool]$null;  #False
            disallow_start_on_remote_app_session = [bool]$null;  #False
            use_unified_scheduling_engine        = [bool]$null;  #False,   True
            volatile                             = [bool]$null;  #False
            restart_on_idle                      = [bool]$null;
            stop_on_idle_end                     = [bool]$null;
            task_computer                        = ''; #PSComputerName    = '';  #
            network_id                           = '';
            network_name                         = '';
            network_computer                     = '';
            idle_duration                        = ''; #PT10M
            idle_wait_timeout                    = ''; # PT1H
            idle_computer                        = ''; #PSComputerName
            maintenance_deadline                 = ''; # P2D
            maintenance_run_exclusive                = [bool]$null; #False
            maintenance_period                   = ''; # P1D
            maintenance_computer                 = '' #PSComputerName
            principal_id                         = ''
            principal_display_name               = ''
            user_id                              = ''
            required_privileges                  = [string[]] {''}
            logon_type                           = ''
            group_id                             = ''
            run_level                            = ''
            process_token_sid_type               = ''
            principal_computer                   = ''
            task_xml                             = [XML]$null;
        }
        try {
            $registeredtaskobjectraw = $registeredtaskobjects[$task_index]
            $registeredtaskobject.task_id                              = $task_index
            $registeredtaskobject.task_path                            = $registeredtaskobjectraw.TaskPath
            $registeredtaskobject.task_name                            = $registeredtaskobjectraw.TaskName
            $registeredtaskobject.task_full_path                       = $registeredtaskobjectraw.URI
            $registeredtaskobject.task_creation_date                   = $registeredtaskobjectraw.Date
            $registeredtaskobject.task_description                     = $registeredtaskobjectraw.Description
            $registeredtaskobject.task_state                           = $registeredtaskobjectraw.State
            $registeredtaskobject.task_source                          = $registeredtaskobjectraw.Source
            $registeredtaskobject.task_author                          = $registeredtaskobjectraw.Author
            $registeredtaskobject.task_version                         = $registeredtaskobjectraw.Version
            $registeredtaskobject.task_is_enabled                      = $registeredtaskobjectraw.Settings.Enabled
            $registeredtaskobject.task_is_hidden                       = $registeredtaskobjectraw.Settings.Hidden
            $registeredtaskobject.task_multi_inst_run_rule             = $registeredtaskobjectraw.Settings.MultipleInstances
            $registeredtaskobject.task_computer                        = $registeredtaskobjectraw.PSComputerName
            $registeredtaskobject.execution_time_limit                 = $registeredtaskobjectraw.Settings.ExecutionTimeLimit
            $registeredtaskobject.security_descriptor                  = $registeredtaskobjectraw.SecurityDescriptor
            $registeredtaskobject.allow_demand_start                   = $registeredtaskobjectraw.Settings.AllowDemandStart
            $registeredtaskobject.allow_hard_terminate                 = $registeredtaskobjectraw.Settings.AllowHardTerminate
            $registeredtaskobject.compatibility                        = $registeredtaskobjectraw.Settings.Compatibility
            $registeredtaskobject.delete_expired_task_after            = $registeredtaskobjectraw.Settings.DeleteExpiredTaskAfter
            $registeredtaskobject.disallow_start_if_on_batteries       = $registeredtaskobjectraw.Settings.DisallowStartIfOnBatteries
            $registeredtaskobject.disallow_start_on_remote_app_session = $registeredtaskobjectraw.Settings.DisallowStartOnRemoteAppSession
            $registeredtaskobject.priority                             = $registeredtaskobjectraw.Settings.Priority
            $registeredtaskobject.restart_count                        = $registeredtaskobjectraw.Settings.RestartCount
            $registeredtaskobject.restart_interval                     = $registeredtaskobjectraw.Settings.RestartInterval
            $registeredtaskobject.run_only_if_idle                     = $registeredtaskobjectraw.Settings.RunOnlyIfIdle
            $registeredtaskobject.run_only_if_network_available        = $registeredtaskobjectraw.Settings.RunOnlyIfNetworkAvailable
            $registeredtaskobject.start_when_available                 = $registeredtaskobjectraw.Settings.StartWhenAvailable
            $registeredtaskobject.stop_if_going_on_batteries           = $registeredtaskobjectraw.Settings.StopIfGoingOnBatteries
            $registeredtaskobject.wake_to_run                          = $registeredtaskobjectraw.Settings.WakeToRun
            $registeredtaskobject.use_unified_scheduling_engine        = $registeredtaskobjectraw.Settings.UseUnifiedSchedulingEngine
            $registeredtaskobject.principal_id                         = $registeredtaskobjectraw.Principal.Id
            $registeredtaskobject.principal_display_name               = $registeredtaskobjectraw.Principal.DisplayName
            $registeredtaskobject.group_id                             = $registeredtaskobjectraw.Principal.GroupId
            $registeredtaskobject.user_id                              = $registeredtaskobjectraw.Principal.UserId
            $registeredtaskobject.principal_computer                   = $registeredtaskobjectraw.Principal.PSComputerName
            $registeredtaskobject.required_privileges                  = $registeredtaskobjectraw.Principal.RequiredPrivilege #array
            $registeredtaskobject.logon_type                           = $registeredtaskobjectraw.Principal.LogonType
            $registeredtaskobject.process_token_sid_type               = $registeredtaskobjectraw.Principal.ProcessTokenSidType
            $registeredtaskobject.run_level                            = $registeredtaskobjectraw.Principal.RunLevel            
            
            if (@($registeredtaskobjectraw.Settings.psobject.properties|Where Name -eq "NetworkSettings").Count -eq 1) {
                $registeredtaskobject.network_id         = $registeredtaskobjectraw.Settings.NetworkSettings.Id
                $registeredtaskobject.network_name       = $registeredtaskobjectraw.Settings.NetworkSettings.Name
                $registeredtaskobject.network_computer   = $registeredtaskobjectraw.Settings.NetworkSettings.PSComputerName
            }
            if (@($registeredtaskobjectraw.Settings.psobject.properties|Where Name -eq "IdleSettings").Count -eq 1) {
                $registeredtaskobject.idle_duration      = $registeredtaskobjectraw.Settings.IdleSettings.IdleDuration
                $registeredtaskobject.restart_on_idle    = $registeredtaskobjectraw.Settings.IdleSettings.RestartOnIdle
                $registeredtaskobject.stop_on_idle_end   = $registeredtaskobjectraw.Settings.IdleSettings.StopOnIdleEnd            
                $registeredtaskobject.idle_computer      = $registeredtaskobjectraw.Settings.IdleSettings.PSComputerName
            }
            if (@($registeredtaskobjectraw.Settings.psobject.properties|Where Name -eq "MaintenanceSettings").Count -eq 1) {
                if ($null -ne $registeredtaskobjectraw.Settings.MaintenanceSettings) {
                    $registeredtaskobject.maintenance_deadline      = $registeredtaskobjectraw.Settings.MaintenanceSettings.Deadline
                    $registeredtaskobject.maintenance_run_exclusive = $registeredtaskobjectraw.Settings.MaintenanceSettings.Exclusive
                    $registeredtaskobject.maintenance_period        = $registeredtaskobjectraw.Settings.MaintenanceSettings.Period
                    $registeredtaskobject.maintenance_computer      = $registeredtaskobjectraw.Settings.MaintenanceSettings.PSComputerName
                }
            }              
            
            # Actions
            # Triggers
            $registeredtaskobject.task_xml               = [XML](Export-ScheduledTask -TaskPath $registeredtaskobject.task_path -TaskName $registeredtaskobject.task_name)
        }
        catch {
            Write-AllPlaces "Error on #$task_index"
        }
        $taskobjects+= $registeredtaskobject
    }
    $sw.Stop()
    $sw.Elapsed

    $taskobjects|Export-Clixml -Path $path_to_extracted_task_xml
}

exit
<####################################################################################################################################################################

     Load previously extracted registered scheduled tasks.

###################################################################################################################################################################>

$registeredtasksxml = Import-Clixml -Path $path_to_extracted_task_xml

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
            #Write-AllPlaces "input type = $type"
            $targettype = ($this.($_.Name)).GetType().Name
            #Write-AllPlaces "target type = $targettype"
            if ($targettype -eq 'datetime' -and $null -eq $_.Value) {
                $this.($_.Name) = 0
            } else {
                $this.($_.Name) = $_.Value
            }
        }
    }
    InitFromPSCustOb([PSCustomObject]$ob) {
        $ob.psobject.properties | Foreach { 
            $targettype = "String"

            if ($null -ne ($this.($_.Name))) {
                $targettype = ($this.($_.Name)).GetType().Name
            }

            if ($targettype -eq 'datetime' -and $null -eq $_.Value) {
                $this.($_.Name) = 0 # Cannot assign a $null to a datetime
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
            #Write-AllPlaces "input type = $type"
            $targettype = ($this.($_.Name)).GetType().Name
            #Write-AllPlaces "target type = $targettype"
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
            #Write-AllPlaces "input type = $type"
            $targettype = ($this.($_.Name)).GetType().Name
            #Write-AllPlaces "target type = $targettype"
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

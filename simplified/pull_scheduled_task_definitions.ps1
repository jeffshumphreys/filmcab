<#
 #    FilmCab Daily morning batch run process: Pull scheduled task definitions for documentation.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Prepping for deployment.
 #    ###### Wed Jan 24 13:27:54 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #    Pull all scheduled task definitions registered to the Windows Task Scheduler on localhost.

    Performance Measurements:
    - Measure-Command {[void](Get-ScheduledTask)}                     520 ms
    - Measure-Command {(Get-ScheduledTask -TaskPath '\')}             501 ms
 #>
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()

. .\simplified\_dot_include_standard_header.ps1


$scheduled_task_definitions = @()
$scheduled_task_action_definitions = @()
$scheduled_task_trigger_definitions = @()

$scheduledTaskDefPaths = (Get-ScheduledTask -TaskPath '\FilmCab\*')|Select TaskPath, TaskName

foreach ($scheduledTaskDefPath in $scheduledTaskDefPaths) {
    $taskPath = $scheduledTaskDefPath.TaskPath
    $taskName = $scheduledTaskDefPath.TaskName              
    $taskXML = [XML](Export-ScheduledTask -TaskName "$taskName" -TaskPath "$taskPath")

    $taskDef = [PSCustomObject]@{}    
    
    Fill-Property $taskDef $taskPath 'TaskPath'
    Fill-Property $taskDef $taskName 'TaskName'
    Fill-Property $taskDef $taskXML.Task.RegistrationInfo 'Version'
    Fill-Property $taskDef $taskXML.Task.RegistrationInfo 'Date'
    Fill-Property $taskDef $taskXML.Task.RegistrationInfo  'Author'
    Fill-Property $taskDef $taskXML.Task.RegistrationInfo  'Source'
    Fill-Property $taskDef $taskXML.Task.RegistrationInfo  'Description'
    Fill-Property $taskDef $taskXML.Task.RegistrationInfo  'Documentation'
    Fill-Property $taskDef $taskXML.Task.RegistrationInfo  'SecurityDescriptor'
    Fill-Property $taskDef $taskXML.Task.Principals.Principal 'id'
    Fill-Property $taskDef $taskXML.Task.Principals.Principal 'UserId'
    Fill-Property $taskDef $taskXML.Task.Principals.Principal 'LogonType'
    Fill-Property $taskDef $taskXML.Task.Principals.Principal 'GroupId'
    Fill-Property $taskDef $taskXML.Task.Principals.Principal 'DisplayName'
    Fill-Property $taskDef $taskXML.Task.Principals.Principal 'ProcessTokenSidType'
    Fill-Property $taskDef $taskXML.Task.Principals.Principal 'RunLevel'
    Fill-Property $taskDef $taskXML.Task.Settings 'MultipleInstancesPolicy'
    Fill-Property $taskDef $taskXML.Task.Settings 'DisallowStartIfOnBatteries'
    Fill-Property $taskDef $taskXML.Task.Settings 'StopIfGoingOnBatteries'
    Fill-Property $taskDef $taskXML.Task.Settings 'AllowHardTerminate'
    Fill-Property $taskDef $taskXML.Task.Settings 'StartWhenAvailable'
    Fill-Property $taskDef $taskXML.Task.Settings 'NetworkProfileName'
    Fill-Property $taskDef $taskXML.Task.Settings 'RunOnlyIfNetworkAvailable'
    Fill-Property $taskDef $taskXML.Task.Settings 'AllowStartOnDemand'
    Fill-Property $taskDef $taskXML.Task.Settings 'Enabled'
    Fill-Property $taskDef $taskXML.Task.Settings 'Hidden'
    Fill-Property $taskDef $taskXML.Task.Settings 'RunOnlyIfIdle'
    Fill-Property $taskDef $taskXML.Task.Settings 'DisallowStartOnRemoteAppSession'
    Fill-Property $taskDef $taskXML.Task.Settings 'UseUnifiedSchedulingEngine'
    Fill-Property $taskDef $taskXML.Task.Settings 'WakeToRun'
    Fill-Property $taskDef $taskXML.Task.Settings 'ExecutionTimeLimit'
    Fill-Property $taskDef $taskXML.Task.Settings 'Priority'
    Fill-Property $taskDef $taskXML.Task.Settings 'DeleteExpiredTaskAfter'

    if (Has-Property $taskXML.Task.Settings 'IdleSettings') {
        Fill-Property $taskDef $taskXML.Task.Settings.IdleSettings 'Duration'
        Fill-Property $taskDef $taskXML.Task.Settings.IdleSettings 'WaitTimeout'
        Fill-Property $taskDef $taskXML.Task.Settings.IdleSettings 'StopOnIdleEnd'  
        Fill-Property $taskDef $taskXML.Task.Settings.IdleSettings 'Duration'
        Fill-Property $taskDef $taskXML.Task.Settings.IdleSettings 'RestartOnIdle'
    }

    if (Has-Property $taskXML.Task.Settings 'RestartOnFailure') {
        Fill-Property $taskDef $taskXML.Task.Settings.RestartOnFailure 'Interval'
        Fill-Property $taskDef $taskXML.Task.Settings.RestartOnFailure 'Count'
    }

    if (Has-Property $taskXML.Task.Settings 'NetworkSettings') {
        Fill-Property $taskDef $taskXML.Task.Settings.NetworkSettings 'Name'
        Fill-Property $taskDef $taskXML.Task.Settings.NetworkSettings 'Id'
    }

    if (Has-Property $taskXML.Task.Principals.Principal 'RequiredPrivileges') {
        # Loop! Travers sequence of Privilege where each is a "Se-"
    }


    $scheduled_task_definitions+= $taskDef
    
    $taskActionsXML = $taskXML.Task.Actions

    foreach ($taskAction in $taskActionsXML) {
        $actionType = ($taskAction.PSObject.Properties|Where MemberType -eq 'Property'|Where TypeNameOfValue -eq 'System.Xml.XmlElement'|Select Name).Name
        $actionDef= [PSCustomObject]@{
            task_full_path = $taskXML.Task.RegistrationInfo.URI # For linking
        }

        if ($actionType -eq 'Exec') {
            Fill-Property $actionDef $taskAction 'Context'
            Fill-Property $actionDef $taskAction.Exec 'Command'
            Fill-Property $actionDef $taskAction.Exec 'Arguments'
            Fill-Property $actionDef $taskAction.Exec 'WorkingDirectory'
        }
        $scheduled_task_action_definitions+= $actionDef
    }                       
    
    $taskTriggersXML = $taskXML.Task.Triggers
    
    foreach ($taskTrigger in $taskTriggersXML) {
        $triggerType = ($taskTrigger.PSObject.Properties|Where Name -like '*Trigger'|Where TypeNameOfValue -eq 'System.Xml.XmlElement'|Select Name).Name
        $triggerDef        = [PSCustomObject]@{
            task_full_path = $taskXML.Task.RegistrationInfo.URI # For linking
            trigger_type = $triggerType
        }                                                 

        if ($triggerType -eq 'CalendarTrigger') {
            Fill-Property $triggerDef $taskTrigger.CalendarTrigger 'Enabled'
            Fill-Property $triggerDef $taskTrigger.CalendarTrigger 'StartBoundary'
            Fill-Property $triggerDef $taskTrigger.CalendarTrigger 'EndBoundary'
            Fill-Property $triggerDef $taskTrigger.CalendarTrigger 'ExecutionTimeLimit'
            Fill-Property $triggerDef $taskTrigger.CalendarTrigger 'RandomDelay'
            
            if (Has-Property $taskTrigger.CalendarTrigger 'Repetition') {
                Fill-Property $triggerDef $taskTrigger.CalendarTrigger.Repetition 'Duration'
                Fill-Property $triggerDef $taskTrigger.CalendarTrigger.Repetition 'Interval'
                Fill-Property $triggerDef $taskTrigger.CalendarTrigger.Repetition 'Duration'
                Fill-Property $triggerDef $taskTrigger.CalendarTrigger.Repetition 'StopAtDurationEnd'
            }                                                                                        
            
            if (Has-Property $taskTrigger.CalendarTrigger 'ScheduleByDay') {
                Fill-Property $triggerDef $taskTrigger.CalendarTrigger.ScheduleByDay 'DaysInterval'
            }                                  
            if (Has-Property $taskTrigger.CalendarTrigger 'ScheduleByWeek') {
                Fill-Property $triggerDef $taskTrigger.CalendarTrigger.ScheduleByWeek 'WeeksInterval'
            }                                  
            if (Has-Property $taskTrigger.CalendarTrigger 'ScheduleByMonth') {
                Fill-Property $triggerDef $taskTrigger.CalendarTrigger.ScheduleByMonth 'DaysOfMonth'
                Fill-Property $triggerDef $taskTrigger.CalendarTrigger.ScheduleByMonth 'Months'
            }                                  
            if (Has-Property $taskTrigger.CalendarTrigger 'ScheduleByMonthDayOfWeek') {
                Fill-Property $triggerDef $taskTrigger.CalendarTrigger.ScheduleByMonthDayOfWeek 'Weeks'
                Fill-Property $triggerDef $taskTrigger.CalendarTrigger.ScheduleByMonthDayOfWeek 'DaysOfWeek'
                Fill-Property $triggerDef $taskTrigger.CalendarTrigger.ScheduleByMonthDayOfWeek 'Months'
            }                                  
        }
        elseif ($triggerType -eq 'RegistrationTrigger') {
            Fill-Property $triggerDef $taskTrigger.RegistrationTrigger 'Delay'
        }
        elseif ($triggerType -eq 'EventTrigger') {
            Fill-Property $triggerDef $taskTrigger.EventTrigger 'Subscription'
            Fill-Property $triggerDef $taskTrigger.EventTrigger 'Delay'
            Fill-Property $triggerDef $taskTrigger.EventTrigger 'NumberOfOccurrences'
            Fill-Property $triggerDef $taskTrigger.EventTrigger 'MatchingElement'
            Fill-Property $triggerDef $taskTrigger.EventTrigger 'ValueQueries'
        }
        elseif ($triggerType -eq 'LogonTrigger') {
            Fill-Property $triggerDef $taskTrigger.LogonTrigger 'UserId'
            Fill-Property $triggerDef $taskTrigger.LogonTrigger 'Delay'
            
        }
        elseif ($triggerType -eq 'BootTrigger') {
            Fill-Property $triggerDef $taskTrigger.BootTrigger 'RandomDelay'
        }
        elseif ($triggerType -eq 'SessionStateChangeTrigger') {
            Fill-Property $triggerDef $taskTrigger.SessionStateChangeTrigger 'UserId'
            Fill-Property $triggerDef $taskTrigger.SessionStateChangeTrigger 'Delay'
            Fill-Property $triggerDef $taskTrigger.SessionStateChangeTrigger 'StateChange'
        }
        elseif ($triggerType -eq 'TimeTrigger') {
            Fill-Property $triggerDef $taskTrigger.TimeTrigger 'RandomDelay'
        }
    }

    $scheduled_task_trigger_definitions+= $triggerDef
}
    
$scheduled_task_definitions|Export-Clixml 'D:\qt_projects\filmcab\simplified\_data\scheduled-task-definitions.xml'
$scheduled_task_action_definitions|Export-Clixml 'D:\qt_projects\filmcab\simplified\_data\scheduled-task-actions-definitions.xml'
$scheduled_task_trigger_definitions|Export-Clixml 'D:\qt_projects\filmcab\simplified\_data\scheduled-task-triggers-definitions.xml'


. .\simplified\_dot_include_standard_footer.ps1
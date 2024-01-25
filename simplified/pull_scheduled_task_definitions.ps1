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

# Unlike Get-WinEvents, where you can prefilter out stuff by dates and such, Get-ScheduledTask gets either all or single. A few thousand tasks might be problematic.
$scheduledTaskDefPaths = (Get-ScheduledTask -TaskPath '\FilmCab\*')|Select TaskPath, TaskName

$taskDefs = @()
$actionDefs = @()
$triggerDefs = @()

foreach ($scheduledTaskDefPath in $scheduledTaskDefPaths) {
    $taskPath = $scheduledTaskDefPath.TaskPath
    $taskName = $scheduledTaskDefPath.TaskName              
    $taskXML = [XML](Export-ScheduledTask -TaskName "$taskName" -TaskPath "$taskPath")

    $taskDef = [PSCustomObject]@{
        task_full_path         = $taskXML.Task.RegistrationInfo.URI
        task_name              = $taskName
        task_path              = $taskPath
        task_xml_version       = $taskXML.Task.version
        task_creation_date    = (@($taskXML.Task.RegistrationInfo.PSObject.Properties.Name -eq 'Date').Count -eq 1 ? $taskXML.Task.RegistrationInfo.Date : '')
        task_author    = (@($taskXML.Task.RegistrationInfo.PSObject.Properties.Name -eq 'Author').Count -eq 1 ? $taskXML.Task.RegistrationInfo.Author : '')
        task_description    = (@($taskXML.Task.RegistrationInfo.PSObject.Properties.Name -eq 'Description').Count -eq 1 ? $taskXML.Task.RegistrationInfo.Description : '')
        task_source    = (@($taskXML.Task.RegistrationInfo.PSObject.Properties.Name -eq 'Source').Count -eq 1 ? $taskXML.Task.RegistrationInfo.Source : '')
        task_principal_id = (@($taskXML.Task.Principals.Principal.PSObject.Properties.Name -eq 'id').Count -eq 1 ? $taskXML.Task.Principals.Principal.Id : '')
        task_principal_user_id = (@($taskXML.Task.Principals.Principal.PSObject.Properties.Name -eq 'UserId').Count -eq 1 ? $taskXML.Task.Principals.Principal.UserId : '')
        task_principal_group_id = (@($taskXML.Task.Principals.Principal.PSObject.Properties.Name -eq 'GroupId').Count -eq 1 ? $taskXML.Task.Principals.Principal.GroupId : '')
        task_principal_logon_type = (@($taskXML.Task.Principals.Principal.PSObject.Properties.Name -eq 'LogonType').Count -eq 1 ? $taskXML.Task.Principals.Principal.LogonType : '')
        task_principal_run_level = (@($taskXML.Task.Principals.Principal.PSObject.Properties.Name -eq 'RunLevel').Count -eq 1 ? $taskXML.Task.Principals.Principal.RunLevel : '')
        # ProcessTokenSidType
        # DisplayName
        # RequiredPrivileges
        MultipleInstancesPolicy        = (@($taskXML.Task.Settings.PSObject.Properties.Name -eq 'MultipleInstancesPolicy'        ).Count -eq 1 ? $taskXML.Task.Settings.MultipleInstancesPolicy             : '')
        DisallowStartIfOnBatteries     = (@($taskXML.Task.Settings.PSObject.Properties.Name -eq 'DisallowStartIfOnBatteries').Count -eq 1 ? $taskXML.Task.Settings.DisallowStartIfOnBatteries          : '')
        StopIfGoingOnBatteries         = (@($taskXML.Task.Settings.PSObject.Properties.Name -eq 'StopIfGoingOnBatteries').Count -eq 1 ? $taskXML.Task.Settings.StopIfGoingOnBatteries              : '')
        AllowHardTerminate             = (@($taskXML.Task.Settings.PSObject.Properties.Name -eq 'AllowHardTerminate').Count -eq 1 ? $taskXML.Task.Settings.AllowHardTerminate                  : '')
        StartWhenAvailable             = (@($taskXML.Task.Settings.PSObject.Properties.Name -eq 'StartWhenAvailable').Count -eq 1 ? $taskXML.Task.Settings.StartWhenAvailable                  : '')
        RunOnlyIfNetworkAvailable      = (@($taskXML.Task.Settings.PSObject.Properties.Name -eq 'RunOnlyIfNetworkAvailable').Count -eq 1 ? $taskXML.Task.Settings.RunOnlyIfNetworkAvailable           : '')
        # NetworkProfileName
        StopOnIdleEnd                   = (@($taskXML.Task.Settings.PSObject.Properties.Name -eq 'IdleSettings').Count -eq 1 ? $taskXML.Task.Settings.IdleSettings.StopOnIdleEnd                        : '')
        RestartOnIdle                   = (@($taskXML.Task.Settings.PSObject.Properties.Name -eq 'IdleSettings').Count -eq 1 ? $taskXML.Task.Settings.IdleSettings.RestartOnIdle                        : '')
        AllowStartOnDemand             = (@($taskXML.Task.Settings.PSObject.Properties.Name -eq 'AllowStartOnDemand').Count -eq 1 ? $taskXML.Task.Settings.AllowStartOnDemand                  : '')
        Enabled                        = (@($taskXML.Task.Settings.PSObject.Properties.Name -eq 'Enabled').Count -eq 1 ? $taskXML.Task.Settings.Enabled                             : '')
        Hidden                         = (@($taskXML.Task.Settings.PSObject.Properties.Name -eq 'Hidden').Count -eq 1 ? $taskXML.Task.Settings.Hidden                              : '')
        RunOnlyIfIdle                  = (@($taskXML.Task.Settings.PSObject.Properties.Name -eq 'RunOnlyIfIdle').Count -eq 1 ? $taskXML.Task.Settings.RunOnlyIfIdle                       : '')
        DisallowStartOnRemoteAppSession= (@($taskXML.Task.Settings.PSObject.Properties.Name -eq 'DisallowStartOnRemoteAppSession').Count -eq 1 ? $taskXML.Task.Settings.DisallowStartOnRemoteAppSession     : '')
        UseUnifiedSchedulingEngine     = (@($taskXML.Task.Settings.PSObject.Properties.Name -eq 'UseUnifiedSchedulingEngine').Count -eq 1 ? $taskXML.Task.Settings.UseUnifiedSchedulingEngine          : '')
        WakeToRun                      = (@($taskXML.Task.Settings.PSObject.Properties.Name -eq 'WakeToRun').Count -eq 1 ? $taskXML.Task.Settings.WakeToRun                           : '')
        ExecutionTimeLimit             = (@($taskXML.Task.Settings.PSObject.Properties.Name -eq 'ExecutionTimeLimit').Count -eq 1 ? $taskXML.Task.Settings.ExecutionTimeLimit                  : '')
        Priority                       = (@($taskXML.Task.Settings.PSObject.Properties.Name -eq 'Priority').Count -eq 1 ? $taskXML.Task.Settings.Priority                            : '')
        # DeleteExpiredTaskAfter

    }    
    $taskDefs+= $taskDef
    
    $taskActionsXML = $taskXML.Task.Actions

    foreach ($taskAction in $taskActionsXML) {
        $actionType = (@($taskAction.PSObject.Properties.Name -eq 'Exec').Count -eq 1 ? 'Exec': '?')
        # Any value Yet? Used to be a user. $actionContext = (@($taskAction.PSObject.Properties.Name -eq 'Context').Count -eq 1 ? $taskAction.Context: '')
        $actionDef= [PSCustomObject]@{
            task_full_path = $taskXML.Task.RegistrationInfo.URI
            Command   = ''
            Arguments = ''
            WorkingDirectory = ''
        }

        if ($actionType -eq 'Exec') {
            $actionDef.Command = $taskAction.Exec.Command
            $actionDef.Arguments = $taskAction.Exec.Arguments
            $actionDef.WorkingDirectory = (@($taskAction.Exec.PSObject.Properties.Name -eq 'WorkingDirectory').Count -eq 1 ? $taskAction.Exec.WorkingDirectory : '')
        }
        # ComHandler (ClassId, Data)
        $actionDefs+= $actionDef
    }                       
    
    $taskTriggersXML = $taskXML.Task.Triggers
    
    foreach ($taskTrigger in $taskTriggersXML) {
        $triggerType = (@($taskTrigger.PSObject.Properties.Name -eq 'CalendarTrigger').Count -eq 1 ? 'Calendar': '?')  # Registration, Boot, Idle, Time, Event, Logon, SessionStateChange
        $triggerDef        = [PSCustomObject]@{
            task_full_path = $taskXML.Task.RegistrationInfo.URI
            trigger_type = ''
            Enabled        = ''
            StartBoundary = [Datetime]0
            EndBoundary = [Datetime]0
            Repetition = ''
            ExecutionTimeLimit = ''
            Interval           = ''
            Duration= ''
            StopAtDurationEnd= ''
            Delay= ''
            RandomDelay= ''
            Subscription= ''
            PeriodOfOccurrence= ''
            DaysInterval= ''
        }                                                 

        $triggerDef.trigger_type = $triggerType
        
        if ($triggerType -eq 'Calendar') {
            $triggerDef.Enabled = (@($taskTrigger.CalendarTrigger.PSObject.Properties.Name -eq 'Enabled').Count -eq 1 ? $taskTrigger.CalendarTrigger.Enabled : '')
            $triggerDef.StartBoundary = (@($taskTrigger.CalendarTrigger.PSObject.Properties.Name -eq 'StartBoundary').Count -eq 1 ? $taskTrigger.CalendarTrigger.StartBoundary : '')
            $triggerDef.EndBoundary = (@($taskTrigger.CalendarTrigger.PSObject.Properties.Name -eq 'EndBoundary').Count -eq 1 ? $taskTrigger.CalendarTrigger.EndBoundary : '')
            $triggerDef.ExecutionTimeLimit = (@($taskTrigger.CalendarTrigger.PSObject.Properties.Name -eq 'ExecutionTimeLimit').Count -eq 1 ? $taskTrigger.CalendarTrigger.ExecutionTimeLimit : '')
            # RandomDelay
            if (@($taskTrigger.CalendarTrigger.PSObject.Properties.Name -eq 'Repetition').Count -eq 1) {
                Fill-Property $triggerDef $taskTrigger.CalendarTrigger.Repetition 'Duration'
                $triggerDef.Interval = (@($taskTrigger.CalendarTrigger.Repetition.PSObject.Properties.Name -eq 'Interval').Count -eq 1 ? $taskTrigger.CalendarTrigger.Repetition.Interval : '')
                $triggerDef.Duration = (@($taskTrigger.CalendarTrigger.Repetition.PSObject.Properties.Name -eq 'Duration').Count -eq 1 ? $taskTrigger.CalendarTrigger.Repetition.Duration : '')
                $triggerDef.StopAtDurationEnd = (@($taskTrigger.CalendarTrigger.Repetition.PSObject.Properties.Name -eq 'StopAtDurationEnd').Count -eq 1 ? $taskTrigger.CalendarTrigger.Repetition.StopAtDurationEnd : '')
                
            }                                                                                           
            if (@($taskTrigger.CalendarTrigger.PSObject.Properties.Name -eq 'ScheduleByDay').Count -eq 1) {
                #DaysInterval (integer)
            }         
            # WeeksInterval
            # DaysOfWeek
            # DaysOfMonth
            # Months
            # Weeks
        # logonTrigger
        # eventTrigger (MatchingElement, ValueQueries)
        # RegistrationTrigger
        # TimeTrigger
        # bootTrigger
        # Session State (ConsolConnect/Disconnect, RemoteConnect/SessionLock)


        }
        $triggerDefs+= $triggerDef
    }
}


. .\simplified\_dot_include_standard_footer.ps1
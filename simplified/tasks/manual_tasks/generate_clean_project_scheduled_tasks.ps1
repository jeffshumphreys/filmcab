<#
 #    FilmCab Generations scripts
 #    Called manually for now
 #    Status: Writing, conception not finalized
 #    ###### Sat Feb 3 15:13:56 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #>

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()

. D:\qt_projects\filmcab\simplified\shared_code\_dot_include_standard_header.ps1

$SharedTimestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.fffffff' # All tasks will have same timestamp.

$ScheduledTaskDefsInSetOrderHandle = Walk-Sql '
    SELECT 
        scheduled_task_id,
        run_start_time,
        scheduled_task_directory,
        scheduled_task_name,
        uri,
        scheduled_task_short_description,
        previous_task_name,
        previous_uri,
        script_path_to_run,
        order_in_set
    FROM scheduled_tasks_ext_v 
    ORDER BY 
        scheduled_task_run_set_id, 
        order_in_set
    ' 
$ScheduledTaskDefsInSetOrder = $ScheduledTaskDefsInSetOrderHandle.Value

While ($ScheduledTaskDefsInSetOrder.Read()) {
    $scheduledTaskId = Get-SqlFieldValue $ScheduledTaskDefsInSetOrderHandle scheduled_task_id
    $RunStartTime = Get-SqlFieldValue $ScheduledTaskDefsInSetOrderHandle run_start_time
    $RunStartTimestamp = (Get-Date).ToString('yyyy-MM-dd').ToDateTime($null).AddTicks($RunStartTime.Ticks).ToString('yyyy-MM-ddTHH:mm:ss.fffffff')
    $scheduledTaskPath = Get-SqlFieldValue $ScheduledTaskDefsInSetOrderHandle scheduled_task_directory
    $scheduledTaskName = Get-SqlFieldValue $ScheduledTaskDefsInSetOrderHandle scheduled_task_name
    $uri= Get-SqlFieldValue $ScheduledTaskDefsInSetOrderHandle uri
    $previous_uri= Get-SqlFieldValue $ScheduledTaskDefsInSetOrderHandle previous_uri
    $scheduledTaskShortDescription = Get-SqlFieldValue $ScheduledTaskDefsInSetOrderHandle scheduled_task_short_description
    $PreviousTaskName= Get-SqlFieldValue $ScheduledTaskDefsInSetOrderHandle previous_task_name
    $scriptPathToRun= Get-SqlFieldValue $ScheduledTaskDefsInSetOrderHandle script_path_to_run
      
    $triggerScript = ""

    if ($PreviousTaskName -eq '') {
          $triggerScript = "
          <CalendarTrigger>
          <StartBoundary>$RunStartTimestamp</StartBoundary>
          <ExecutionTimeLimit>P3H</ExecutionTimeLimit>
          <Enabled>true</Enabled>
          <ScheduleByDay>
            <DaysInterval>1</DaysInterval>
          </ScheduleByDay>
        </CalendarTrigger>
          "
      }                            
else {
            $triggerScript = @"
            <EventTrigger>
            <Enabled>true</Enabled>
            <Subscription>&lt;QueryList&gt;&lt;Query Id="0" Path="Microsoft-Windows-TaskScheduler/Operational"&gt;&lt;Select Path="Microsoft-Windows-TaskScheduler/Operational"&gt;*[EventData[@Name='ActionSuccess'][Data [@Name='TaskName']='$previous_uri']] and *[EventData[@Name='ActionSuccess'][Data [@Name='ResultCode']='0']]&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription>
          </EventTrigger>
"@
    }

    # Build XML to import into scheduler
    
    $taskXMLTemplate = @"
<?xml version="1.0" encoding="UTF-16"?>
    <Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
      <RegistrationInfo>
        <Date>$SharedTimestamp</Date>
        <Author>DSKTP-HOME-JEFF\jeffs</Author>
        <Description>Part of FilmCab, $scheduledTaskShortDescription. # $scheduledTaskId</Description>
        <URI>$uri</URI>
      </RegistrationInfo>
      <Triggers>
        $triggerScript
      </Triggers>
      <Principals>
        <Principal id="Author">
          <UserId>S-1-5-21-260979430-3554011381-420227292-1001</UserId>
          <LogonType>Password</LogonType>
          <RunLevel>HighestAvailable</RunLevel>
        </Principal>
      </Principals>
      <Settings>
        <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
        <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
        <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
        <AllowHardTerminate>true</AllowHardTerminate>
        <StartWhenAvailable>false</StartWhenAvailable>
        <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
        <IdleSettings>
          <StopOnIdleEnd>true</StopOnIdleEnd>
          <RestartOnIdle>false</RestartOnIdle>
        </IdleSettings>
        <AllowStartOnDemand>true</AllowStartOnDemand>
        <Enabled>true</Enabled>
        <Hidden>false</Hidden>
        <RunOnlyIfIdle>false</RunOnlyIfIdle>
        <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
        <UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
        <WakeToRun>true</WakeToRun>
        <ExecutionTimeLimit>PT03H</ExecutionTimeLimit>
        <Priority>7</Priority>
      </Settings>
      <Actions Context="Author">
        <Exec>
          <Command>"C:\Program Files\PowerShell\7\pwsh.exe"</Command>
          <Arguments>-WindowStyle Hidden -ExecutionPolicy Bypass -Command ". '$scriptPathToRun'; exit `$LASTEXITCODE"</Arguments>
        </Exec>
      </Actions>
    </Task>    
"@
           
Register-ScheduledTask -Xml $taskXMLTemplate -TaskPath $scheduledTaskPath -TaskName $scheduledTaskName -User 'DSKTP-HOME-JEFF\jeffs' -Password 'Dill11ie!' -Force
# TODO: push to github folders

}

. D:\qt_projects\filmcab\simplified\shared_code\_dot_include_standard_footer.ps1

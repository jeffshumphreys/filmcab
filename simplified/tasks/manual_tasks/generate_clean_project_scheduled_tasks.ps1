<#
 #    FilmCab Generations scripts for Windows Task Scheduler.
 #    Called manually for now
 #    Status: In production, adding functionality
 #    ###### Sat Feb 3 15:13:56 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #>

. .\_dot_include_standard_header.ps1

$SharedTimestamp = Get-Date -Format $DEFAULT_WINDOWS_TASK_SCHEDULER_TIMESTAMP_FORMAT_XML # All tasks will have same timestamp.

# TODO: Check warning column for misaligned names

# TODO: check which is installed and use that.

$powershellInstance = "C:\Program Files\PowerShell\7\pwsh.exe"
$powershellInstance = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"  # Switched back to 5.1

$ScheduledTaskDefsInSetOrder = WhileReadSql 'SELECT * FROM scheduled_tasks_ext_v ORDER BY scheduled_task_run_set_id, order_in_set' 

  While ($ScheduledTaskDefsInSetOrder.Read()) {
    $RunStartTimestamp = (Get-Date).ToString('yyyy-MM-dd').ToDateTime($null).AddTicks($run_start_time.Ticks).ToString($DEFAULT_WINDOWS_TASK_SCHEDULER_TIMESTAMP_FORMAT_XML)
      
    $triggerScript = ""

    if ($previous_task_name -eq '') {
          $triggerScript = "
          <CalendarTrigger>
          <StartBoundary>$RunStartTimestamp</StartBoundary>
          <ExecutionTimeLimit>PT2H</ExecutionTimeLimit>
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
        <Author>DSKTP-HOME-JEFF\jeffers</Author>
        <Description>Part of FilmCab, $scheduled_task_short_description . # $scheduled_task_id</Description>
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
        <ExecutionTimeLimit>$execution_time_limit</ExecutionTimeLimit>
        <Priority>7</Priority>
      </Settings>
      <Actions Context="Author">
        <Exec>
          <Command>"$powershellInstance"</Command>
          <Arguments>-WindowStyle Hidden -ExecutionPolicy Bypass -Command ". '$script_path_to_run'; exit `$LASTEXITCODE"</Arguments>
          <WorkingDirectory>D:\qt_projects\filmcab</WorkingDirectory>
        </Exec>
      </Actions>
    </Task>    
"@
           
if (-not (Test-Path $script_path_to_run)) {
  throw [Exception]"Path <$script_path_to_run> Does not exist! Fix!"
}
Register-ScheduledTask -Xml $taskXMLTemplate -TaskPath $scheduled_task_directory -TaskName $scheduled_task_name -User 'DSKTP-HOME-JEFF\jeffs' -Password 'Dill11ie!' -Force

# TODO: Get file if there. compare: if no different, do not push. Ignore the datestamp.

$path_to_XML = $script_path_to_run.Replace('.ps1', '.xml').Replace($scheduled_task_run_set_name, $scheduled_task_run_set_name + '\_task_defs')
$taskXMLTemplate | Out-File $path_to_XML -Force
}

. .\_dot_include_standard_footer.ps1

<#
 #    FilmCab Generations scripts for Windows Task Scheduler.
 #    Called manually for now
 #    Status: In production, adding functionality
 #    ###### Sat Feb 3 15:13:56 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #    WARNING: Casing on "false" and "true" values is sensitive. "False" will block registration.
 #>

try {
. .\_dot_include_standard_header.ps1

$SharedTimestamp = Get-Date -Format $DEFAULT_WINDOWS_TASK_SCHEDULER_TIMESTAMP_FORMAT_XML # All tasks will have same timestamp.

# TODO: Check warning column for misaligned names

# TODO: check which is installed and use that.

$powershellInstance = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"  # WARNING: arguments differ from core 7.
$powershellInstance = "C:\Program Files\PowerShell\7\pwsh.exe"
$powershellInstance = "C:\Program Files\PowerShell\7-preview\pwsh.exe"

#WARNING: -WindowStyle Hidden blocks transcripts!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! IM SUCH A STUPID GIT!!!!!!!!!!

if (-not (Test-Path $powershellInstance)) {
  throw [Exception]"path to powershell/pwsh not found"
}

$ScheduledTaskDefsInSetOrder = WhileReadSql "
    SELECT
        scheduled_task_id
    ,   scheduled_task_name
    ,   scheduled_task_directory
    ,   scheduled_task_run_set_name
    ,   uri
    ,   scheduled_task_short_description
    ,   run_start_time
    ,   previous_task_name
    ,   previous_uri
    ,   task_execution_time_limit
    ,   script_path_to_run
    ,   repeat
    ,   repeat_interval
    ,   repeat_duration
    ,   stop_when_repeat_duration_reached
    ,   trigger_execution_time_limit
    FROM
        scheduled_tasks_ext_v
    ORDER BY
        scheduled_task_run_set_id
    ,   order_in_set
  "

  While ($ScheduledTaskDefsInSetOrder.Read()) {
    if ($null -eq $run_start_time) {
      $run_start_time = Get-Date # Just grab something since not one set.  This is common for loopings.
    }
    $RunStartTimestamp = (Get-Date).ToString('yyyy-MM-dd').ToDateTime($null).AddTicks($run_start_time.Ticks).ToString($DEFAULT_WINDOWS_TASK_SCHEDULER_TIMESTAMP_FORMAT_XML)

    # Build the trigger portion, either a scheduled (timed) start, or an event trigger from the previous task in set.

    $triggerScript = ""
    $repeatScript = ""

     if ($null -eq $trigger_execution_time_limit) {
         $trigger_execution_time_limit = 'P1D'
     }


    if ($repeat) {
         $repeatScript = "               <Repetition>
                     <Interval>$repeat_interval</Interval>
                     <Duration>$repeat_duration</Duration>
                     <StopAtDurationEnd>$($stop_when_repeat_duration_reached.ToString().ToLower())</StopAtDurationEnd>
                 </Repetition>"

    }
    if ([string]::IsNullOrWhiteSpace($previous_task_name)) {
          $triggerScript = @"
          <CalendarTrigger id="start_batch_run_session_on_time">
          $repeatScript
          <StartBoundary>         $RunStartTimestamp    </StartBoundary>
          <ExecutionTimeLimit>    $trigger_execution_time_limit                 </ExecutionTimeLimit>
          <Enabled>               true                  </Enabled>
          <ScheduleByDay>
            <DaysInterval> 1 </DaysInterval>
          </ScheduleByDay>
        </CalendarTrigger>
"@
      }
else {
            $triggerScript = @"
            <EventTrigger id="previous_task_completed_successfully">
            <Enabled> true </Enabled>
            <Subscription>&lt;QueryList&gt;&lt;Query Id="0" Path="Microsoft-Windows-TaskScheduler/Operational"&gt;&lt;Select Path="Microsoft-Windows-TaskScheduler/Operational"&gt;*[EventData[@Name='ActionSuccess'][Data [@Name='TaskName']='$previous_uri']] and *[EventData[@Name='ActionSuccess'][Data [@Name='ResultCode']='0']]&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription>
          </EventTrigger>
"@
    }

    # Build XML to import into scheduler
    # https://learn.microsoft.com/en-us/windows/win32/taskschd/task-scheduler-schema

    if ([string]::IsNullOrWhiteSpace($previous_task_name)) {
        $previous_task_name = "N/A"
    }

    $taskXMLTemplate = @"
<?xml version="1.0" encoding="UTF-16"?>
    <Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
      <RegistrationInfo>
        <Version>             1                                                                        </Version>
        <Source>              $previous_task_name                                                      </Source>
        <Date>                $SharedTimestamp                                                         </Date>
        <Author>              DSKTP-HOME-JEFF\jeffers                                                  </Author>
        <Description>         Part of FilmCab, $scheduled_task_short_description . # $scheduled_task_id</Description>
        <URI>                 $uri                                                                     </URI>
      </RegistrationInfo>
      <Triggers>
        $triggerScript
      </Triggers>
      <Principals>
        <Principal id="Author">
          <UserId>                         S-1-5-21-260979430-3554011381-420227292-1001</UserId>
          <LogonType>                      Password                                    </LogonType>
          <RunLevel>                       HighestAvailable                            </RunLevel>
        </Principal>
      </Principals>
      <Settings>
        <MultipleInstancesPolicy>          IgnoreNew                 </MultipleInstancesPolicy>
        <DisallowStartIfOnBatteries>       true                      </DisallowStartIfOnBatteries>
        <StopIfGoingOnBatteries>           true                      </StopIfGoingOnBatteries>
        <AllowHardTerminate>               true                      </AllowHardTerminate>
        <StartWhenAvailable>               false                     </StartWhenAvailable>
        <RunOnlyIfNetworkAvailable>        false                     </RunOnlyIfNetworkAvailable>
        <IdleSettings>
          <StopOnIdleEnd>                  true                      </StopOnIdleEnd>
          <RestartOnIdle>                  false                     </RestartOnIdle>
          <WaitTimeout>                    PT1H                      </WaitTimeout>
          <Duration>                       PT1M                      </Duration>
        </IdleSettings>
        <AllowStartOnDemand>               true                      </AllowStartOnDemand>
        <Enabled>                          true                      </Enabled>
        <Hidden>                           false                     </Hidden>
        <RunOnlyIfIdle>                    false                     </RunOnlyIfIdle>
        <DisallowStartOnRemoteAppSession>  false                     </DisallowStartOnRemoteAppSession>
        <UseUnifiedSchedulingEngine>       true                      </UseUnifiedSchedulingEngine>
        <WakeToRun>                        true                      </WakeToRun>
        <ExecutionTimeLimit>               $task_execution_time_limit</ExecutionTimeLimit>
        <Priority>                         7                         </Priority>
      </Settings>
      <Actions Context="Author">
        <Exec>
          <Command>"$powershellInstance"</Command>
          <Arguments>-ExecutionPolicy Bypass -Command ". '$script_path_to_run'; exit `$LASTEXITCODE"</Arguments>
          <WorkingDirectory>D:\qt_projects\filmcab</WorkingDirectory>
        </Exec>
      </Actions>
    </Task>
"@

if (-not (Test-Path $script_path_to_run)) {
  throw [Exception]"Path <$script_path_to_run> Does not exist! Fix!"
}
Write-AllPlaces "Creating task $scheduled_task_name"
# WARNING: Destroys all history. Set-ScheduledTask you can't pass in an XML block.
Register-ScheduledTask -Xml $taskXMLTemplate -TaskPath $scheduled_task_directory -TaskName $scheduled_task_name -User 'DSKTP-HOME-JEFF\jeffs' -Password 'Dill11ie!' -Force

$path_to_XML = $script_path_to_run.Replace('.ps1', '.xml').Replace($scheduled_task_run_set_name, $scheduled_task_run_set_name + '\_task_defs')
$taskXMLTemplate | Out-File $path_to_XML -Force
}

}
catch {
    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}
finally {
    Write-AllPlaces "Finally"
    . .\_dot_include_standard_footer.ps1
}
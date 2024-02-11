[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()
############### Test a Time (calendar) trigger
$taskName = '_start_new_batch_run_session'
############### Test an Event trigger
$taskName = 'back_up_unbackedup_published_media'
$xmlfilter = @"
<QueryList>
<Query Id="0" Path="Microsoft-Windows-TaskScheduler/Operational">
<Select Path="Microsoft-Windows-TaskScheduler/Operational">
(*[EventData[(Data[@Name='TaskName']='\FilmCab\file maintenance\$taskName')]])
</Select>
</Query>
</QueryList>
"@

$recentTaskEvents = Get-WinEvent -LogName 'Microsoft-Windows-TaskScheduler/Operational' -FilterXPath $xmlfilter -MaxEvents 20|
Select `
    @{Name = 'event_id'              ; Expression = {$_.RecordId}},     # A rollover record id, but it gives us something to reference singular events. Sort of.
    @{Name = 'correlation_id'        ; Expression = {$_.ActivityId.Guid}},     # Somehow, this is storing nulls instead of empty string. aka correlation_id
    @{Name = 'event_type_id'         ; Expression = {$_.Id}}            ,
    @{Name = 'event_type_name'       ; Expression={$_.TaskDisplayName}},   # is it taskdisplay? event code? event id?
    @{Name = 'event_created'         ; Expression= {$_.TimeCreated.ToString('yyyy-MM-dd HH:mm:ss:ffffff')}},
    @{Name = 'task_version'          ; Expression= {$_.Version}},          # I think this is the task version?
    @{Name='TaskFullPath'            ; Expression = {$_.Properties[0].Value}},
    @{Name='process_id'              ; Expression = {$_.Properties[2].Value}},
    @{Name='TriggerType'             ; Expression = {
        if ($_.Message -match 'time trigger'){'Time'} <# Essentially, Scheduler #>
        elseif ($_Id -eq 108) {'Event'}
        elseif ($_Id -eq 119) {'Logon'}
        elseif ($_Id -eq 109) {'Registration'}           <# Uh, aka ImmediateTrigger?? #>
        elseif ($_Id -eq 110) {'User'}
        elseif ($_Id -eq 117) {'Idle'}
        elseif ($_Id -eq 118) {'Startup'}                      <# No shutdown trigger #>
        elseif ($_Id -eq 120) {'Local Console Connect'}
        elseif ($_Id -eq 121) {'Local Console Disconnect'}
        elseif ($_Id -eq 122) {'Remote Console Connect'}       <# Uhhhhhh, Huh? #>
        elseif ($_Id -eq 123) {'Remote Console Disconnect'}
        elseif ($_Id -eq 124) {'Lock'}
        elseif ($_Id -eq 125) {'Unlock'}
        elseif ($_Id -eq 145) {'Unsuspended'} # 145 Task triggered by coming out of suspend mod
    }}

$mostRecentEvent = @($recentTaskEvents|Group event_created)[0]|Select -ExpandProperty Group|Select event_id, correlation_id, event_type_id, event_created
$mostRecentCorrelationId = $mostRecentEvent.correlation_id

$lastSetOfCorrelatedEvents = $recentTaskEvents|Where correlation_id -eq $mostRecentCorrelationId

##$lastSetOfCorrelatedEvents|Sort event_id|Format-Table

$firstEventIdInSet = @($lastSetOfCorrelatedEvents|Sort event_id)[0].event_id
$lastEventIdInSet = @($lastSetOfCorrelatedEvents|Sort event_id -Descending)[0].event_id

$lastEventCode = $lastSetOfCorrelatedEvents|Where event_id -eq $lastEventIdInSet
$triggeredBy = $lastSetOfCorrelatedEvents|Where event_type_id -in @(108, 119, 109, 110, 117 ,118, 120, 121, 122, 123, 124, 125, 145)

$recentTaskEvents|Where correlation_id -eq $null|Where event_id -gt $firstEventIdInSet|Where event_id -lt $lastEventIdInSet|Where event_type_name -eq 'Created Task Process'|
Select event_id,
@{Name='correlation_id'              ; Expression = {$mostRecentCorrelationId}},
@{Name='last_event_type_id'          ; Expression = {$lastEventCode.event_type_id}},
@{Name='last_event_type'             ; Expression = {$lastEventCode.event_type_name}},
@{Name='triggered_by_event_type_id'  ; Expression = {$triggeredBy.event_type_id}},
@{Name='triggered_by_event_type'     ; Expression = {$triggeredBy.event_type_name}},
process_id,
event_created,
task_version

#TODO: Grab task def and identity what events and tasks could trigger this.
#Question: Does an event trigger on task B for task A generate a task registraion updated event on task A? Hmmmmmmmmm.

    #### Failure to launch
        # 130 Launch condition not met, service busy
        # 112 Launch condition not met, network unavailable
        # 128 Launch condition not met, beyond end time 
        # 130 Launch condition not met, service busy
        # 131 Launch condition not met, quota exceeded                (Task Quota)
        # 132 Launch condition warning, quota approaching             (Task Quota)
        # 133 Launch condition not met, quota exceeded                (Engine quota)
        # 134 Launch condition warning, quota approaching             (Engine quota)
        # 135 Launch condition not met, machine not idle
        # 326 Launch condition not met, computer on batteries
        # 332 Launch condition not met, user not logged-on
        # 333 Launch condition not met, session is RemoteApp Session
        # 334 Launch condition not met, session is a Worker Session 
        # 306 Engine failed to receive the task                      
        # 322 Launch request ignored, instance already running 
        # 324 Launch request queued, instance already running
        # 203 Action failed to start
        # 146 Task loading at service startup failed
        # 151 Task Scheduler failed to instantiate task at service startup. 
        # 105 Impersonation failure 
        # 104 Logon failure
        # 325 Launch request queued
        # 204 Task failed to start on event 
        # 205 Task failed to start on event pattern match  
        # 305 Task failed to be sent to engine
        # 153 Missed task start rejected 

    #### Failure to complete
        # 202 Action failed
        # 303 Task engine shut down due to error 
        # 320 Task Engine received message to stop task
        # 323 Launch request acknowledged, current instance stopped
        # 327 Task stopping due to  switching to batteries                        [SIC]
        # 328 Task stopping due to computer not idle
        # 329 Task stopping due to timeout reached
        # 330 Task stopping due to user request
        # 331 Task failed to stop on timeout                       (Task may be hosed????)
        # 111 Task terminated
        # 303 Task engine shut down due to error

    #### Will No longer launch
        # 311 Task Engine failed to start    
        # 142 Task disabled
        # 303 Task engine shut down due to error  
        # 149 Task is using a combination of properties that is incompatible with the scheduling engine
        # 141 Task registration deleted  
        # 150 Task registration on event failed 

    #### Flag Watch for Launch
        # 319 Task Engine received message to start task             Expect to see task started
        # 304 Task sent to engine
        # 325 Launch request queued               
        # 324 Launch request queued, instance already running 

    #### Task Execution Environment Corrupt
        # 309 Engine orphaned
        # 401 Service failed to start 
        # 402 Service is shutting down
        # 403 Service critical error           
        # 404 Service RPC error                
        # 405 Service COM error        
        # 315 Service Engine connection failure         
        # 406 Cred store initialization error  
        # 407 LSA initialization error         
        # 408 Idle detection error                                Specifically Idle triggers
        # 410 Wakeup timer error     
        # 719 TaskScheduler Operational log was disabled   
        # 998 Method Failure      
        # 303 Task engine shut down due to error                    

    #### Task May not Function when Launched
        # 116 Task registered without credentials
        # 113 Task registered without some triggers
        # 414 Task Misconfiguration
        # 115 Task update or deletion error                       (TransactionRollbackFailure)

    #### Failure to Complete Re-launch
        # 114 Missed task started
        # 126 Task restarted on failure (Failed Task)
        # 127 Task restarted on failure (Rejected Task)
        # 148 Task image recovering failed after OS migration 

    #### May Effect Task Function
    # 411 Service signaled time change
    # 409 Time change notification error   
   

<#
    In support of the logging system, I want to capture what scheduled task ran a script from within the Start-Log of any script. See test_log_sys.ps1
    I hope to avoid unnecessary performance delay to scripts calling Start-Log, but when debugging, it's important to know how a script got started, and with what arguments.
        Was this started from within VS Code?  A debugging run where the user can stop, skip, and completely drop from finishing? If a script run is stopped before completion, that
        can account for odd output. For example, a job run record in a log table with no end stamp, no error caught, no return code, no duration caught.
        Was it run manually from cmd.exe?  I don't know if we can capture if it was a bat file.

        But, if it was called from a Windows Scheduler Registered Task, there are then two possibilities: Either a user kicked it, or a trigger kicked it.

    Warnings:
        A full reload on my small system, for 14,100 events, took 5.5 minutes. This is mostly the part where I extract the custom attributes.

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
        Convert Write-Host to Write-Debug?
#>
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Scope='Function', Target='Log-*')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '', Scope='Function', Target='*')]
param()

. .\simplified\includes\include_filmcab_header.ps1 # local to base directory of base folder for some reason.

$actionToTake  = $null
$processEvents = $null

# Force full reload: Remove-Item -Path 'clean-task-scheduler-events.xml' -Force   # Rebuilds all new, removed attributes.
if (Test-Path 'clean-task-scheduler-events.xml' -PathType Leaf) {
    $actionToTake = 'Scan for new events'

} else {
    $actionToTake = 'Replace from API'
    $processEvents = $true
}

$taskSchedulerEvents      = @()
$cleanTaskSchedulerEvents = @()

switch ($actionToTake) {
    'Scan for new events' {
        $cleanTaskSchedulerEvents = Import-Clixml -Path "clean-task-scheduler-events.xml"
        $file = Get-Item '.\clean-task-scheduler-events.xml'
        $Script:lastSavedEventCreatedDate = $file.CreationTime
        $actionToTake = 'Append new events'
    }
    'Replace from API' {
        $Script:lastSavedEventCreatedDate = 0 # Force a full reload
    }
    default {
        Write-Error "ERROR: Unrecognized action <$actionToTake> to determine form of event collection"
        throw
    }       
}

if ($actionToTake -in @('Replace from API', 'Append new events')) {
    $taskSchedulerEvents =
    Get-WinEvent -ProviderName 'Microsoft-Windows-TaskScheduler'| # Tested with FilterHashtable and no ProviderName Very slow. Using ProviderName seems faster. Need to test more vigorously.
    Where LogName -eq 'Microsoft-Windows-TaskScheduler/Operational'|
    Where TimeCreated -ge $lastSavedEventCreatedDate|
    Where Id -NotIn @(800, 808)|
    Select @{Name = 'event_type_id'      ; Expression = {$_.Id}},
        @{Name = 'event_type_name'       ; Expression={$_.TaskDisplayName}},     # is it taskdisplay? event code? event id?
        @{Name = 'general_operation_code'; Expression={$_.OpcodeDisplayName}},
        @{Name = 'event_version'         ; Expression= {$_.Version}},          # I think this is the task version?
        @{Name = 'event_created'         ; Expression= {$_.TimeCreated}},
        @{Name = 'event_message'         ; Expression= {$_.Message}},
        @{Name = 'event_message_template'; Expression= {[string]$null}},       # Filled in later
        @{Name = 'user_id'               ; Expression = {$_.UserId.Value}},     # UserId is a PSCustomObject, so take the string value
        @{Name = 'activity_id'           ; Expression = {$_.ActivityId}},     # Somehow, this is storing nulls instead of empty string.
        @{Name = 'record_id'             ; Expression = {$_.RecordId}},     # A rollover record id, but it gives us something to reference singular events. Sort of.
        @{Name = 'TaskName'              ; Expression = {[string]$null}},            
        @{Name = 'UserName'              ; Expression = {[string]$null}},           
        @{Name = 'InstanceId'            ; Expression = {[string]$null}},           
        @{Name = 'UserContext'           ; Expression = {[string]$null}},           
        @{Name = 'ActionName'            ; Expression = {[string]$null}},           
        @{Name = 'ProcessID'             ; Expression = {[Int32]$null}},           
        @{Name = 'EnginePID'             ; Expression = {[Int32]$null}},           
        @{Name = 'QueuedTaskInstanceId'  ; Expression = {[string]$null}},           
        @{Name = 'ResultCode'            ; Expression = {[string]$null}},           
        @{Name = 'Path'                  ; Expression = {[string]$null}},           
        @{Name = 'Priority'              ; Expression = {[Int32]$null}},           
            Properties     #|Select -First 100
    Write-Debug "Completed pull from API"
    $scriptTimer.Elapsed.TotalSeconds
    $processEvents = ($taskSchedulerEvents.Count -gt 0); 
}

if ($processEvents) {
    # Capture the various types in custom data, as string names so we can see if we need special handling.

    $allTheCustomPropertyTypes = @()

    # Since the properties of an event vary, we collect all the different ones here for review after.

    $allTheCustomProperties = [PSCustomObject]@{}

    # if no event run cache, create. Big time savings exluding the dumb info.
    # Let's get all the events and save off the interesting ones, for speed. cache 'em

    # Pull a list of events classes, not event instances

    $taskSchedulerEventTypes = (Get-WinEvent -ListProvider 'Microsoft-Windows-TaskScheduler').Events

    ############################################################################################################################################################################################################################################################################################################################################################################################################
    #
    #     Process all captured Events and pull apart the dynamically structured eventdata packet into discrete columns.
    #
    ############################################################################################################################################################################################################################################################################################################################################################################################################

    Foreach ($taskSchedulerEvent in $taskSchedulerEvents) {

        # We need the Event Id (aka Task, EventCode) to fetch the structure of the event data, mostly for the Template

        $eventTypeId = $taskSchedulerEvent.event_type_id
        $eventType   = $taskSchedulerEventTypes|Select *|Where Id -EQ $eventTypeId

        # Get some event type details

        $taskSchedulerEvent.event_message_template = $eventType.Description  # Example:  Task Scheduler successfully finished "%3" instance of the "%1" task for user "%2".
        # Example message: Task Scheduler successfully completed task "\Microsoft\Windows\LanguageComponentsInstaller\Installation" , instance "{b1182d83-1cb2-4d82-b44d-0372759de887}" , action "Language Components Installer" with return code 0.

        # Prep to merge data values and names

        $eventCustomProperties = @()

        # Multiple template nodes can exist.  The last one appears to be best?????????

        $lastTemplateIndex = @($eventType|Select Id -expand Template|Select-Xml -xpath '*').Count - 1

        # Get the event template from the specific event type so we can map eventdata values to attribute names

        $lastTemplate = @($eventType|Select -Expand Template|Select-Xml -xpath "*")[$lastTemplateIndex]
        $lastTemplate|
            Select -Expand Node|
            Select -Expand data|
            ForEach-Object {$i=0} <# WARNING: DO NOT PUT CURLY BRACE ON NEXT LINE! #>{ # The Powershell extension version 2023.8.0 mistakenly flags this as assigned but never used, which below you can see that it is used. We must add a unique id to each property since none is included, and all we get is an ordered list of column names: How can we pair these to the event instance's values? Only by order, unfortunately.
                $eventCustomProperty = [PSCustomObject]@{
                    property_id      = $i
                    property_name    = $_.name
                    property_value   = ''
                    property_type    = $_.outType.Substring(3) # Trim off the "xs:" prefix. That way it's easier to build new attributes (Members, Properties) with a ps-recognized type
                }
                $eventCustomProperties+= $eventCustomProperty
                $i++
            }

        # Now pull out the eventdata values

        $taskSchedulerEvent.Properties|Foreach-Object {$i=0} { <############ WARNING! DO NOT PUT CURLY BRACE ON NEXT LINE! #>
            $eventPropertyValue            = $_.Value # Save it BEFORE the switch DESTROYS the $_ and fills it with $eventPropertyValueType (ugh)
            $eventPropertyValueType    = $_.Value.GetType().Name
            $normalizedValue = ""

            switch ($eventPropertyValueType) {
                "String" {
                    $normalizedValue = $eventPropertyValue
                }
                "Guid" { # Some types need a bit o' processing first
                    $normalizedValue = $eventPropertyValue.Guid.ToString() # To string or it will still be a GUID object and not print.
                }
                "unsignedInt" {
                    $normalizedValue = $eventPropertyValue.ToString()
                }
                "UInt32" {
                    $normalizedValue = $eventPropertyValue.ToString()
                }
                default { 
                    $normalizedValue = "?"
                }
            }

            $eventCustomProperties[$i].property_value = $normalizedValue
            $i++
        }

        # Now we flatten out the hopefully reasonable sized set of various properties

        $eventCustomProperties|Foreach-Object {
            $eventPropertyName = $_.property_name
            $eventPropertyType = $_.property_type
            if ($eventPropertyType -eq 'GUID') {
                $eventPropertyType = 'string' # Let's not store and actual GUID type.
            }                         
            if ($eventPropertyType -eq 'string') {
                $eventPropertyType = 'System.String'
            }
            $eventPropertyInTaskSchedulerEvent = [bool]($taskSchedulerEvent.PSObject.Properties.Name -eq "$eventPropertyName")
            if (!$eventPropertyInTaskSchedulerEvent) {                                        
                $taskSchedulerEvent | Add-Member NoteProperty -Name $eventPropertyName -Value $v -TypeName $eventPropertyType
            }                                        

            $v = $_.property_value
            if ($v -eq '') {
                $v = $null
            }
            $taskSchedulerEvent.$eventPropertyName = $v

            if (@($allTheCustomProperties.PSObject.Properties).Count -eq 0) {
                $allTheCustomProperties|Add-Member NoteProperty -Name $eventPropertyName -Value $v -TypeName $eventPropertyType
            } else {
                $eventPropertyInMasterListOfCustomProperties = [bool]($allTheCustomProperties.PSObject.Properties.Name -eq "$eventPropertyName")
                if (!$eventPropertyInMasterListOfCustomProperties) {
                    $allTheCustomProperties|Add-Member NoteProperty -Name $eventPropertyName -Value $v -TypeName $eventPropertyType
                }
            }
            if (!$allTheCustomPropertyTypes.Contains($_.property_type))
            {
                $allTheCustomPropertyTypes+= $_.property_type
            }
        }

        $taskSchedulerEvent.PSObject.Properties.Remove('Properties')

        $cleanTaskSchedulerEvents+= $taskSchedulerEvent
    }
}

# List em out for dev review

Write-Host "Completed loading and tranforming events from API and into array"
$scriptTimer.Elapsed.TotalSeconds
            
$howManyEvents = $cleanTaskSchedulerEvents.Count

switch ($actionToTake) {
    'Replace from API' {
        $cleanTaskSchedulerEvents|Export-Clixml -Path "clean-task-scheduler-events.xml"
        Write-Host "Wrote to xml file (replaced), $howManyEvents events"                                      
    }
    'Append new events' {
        if ($processEvents) {
            $cleanTaskSchedulerEvents|Export-Clixml -Path "clean-task-scheduler-events.xml"
            Write-Host "Wrote to xml file (appended), $howManyEvents events"
        }
    }
    'Reload from store' {
        # Already done
    }
    default {
        Write-Error "ERROR: Unrecognized action <$actionToTake>"
        throw
    }
}

$file = Get-Item '.\clean-task-scheduler-events.xml'
$Script:latestEventCreatedDate = ($cleanTaskSchedulerEvents|Select event_created).event_created|Sort -Descending|Select -first 1
$file.CreationTime = $Script:latestEventCreatedDate
$scriptTimer.Elapsed.TotalSeconds

# Scan our pile for any new task creations or deletions, or updates
                                                        
$computer = $env:COMPUTERNAME

$cleanTaskSchedulerEvents|Select *|Where event_type_id -in @(113, 106, 116, 140, 141, 115, 142)|Where UserName -notin @('S-1-5-18')|
Where TaskName -NotMatch '\\Microsoft\\'|
Where TaskName -NotMatch '\\Adobe'|
Select record_id, 
        @{Name='task_full_path'; Expression={$_.TaskName}}, 
        event_type_name, 
        event_created,                                   
        @{Name='event_created_as_sortable_str_with_ms'; Expression={$_.event_created.ToString('yyyy-MM-dd HH:mm:ss:fffff')}},  # The default output of datetime is only to seconds, and many of these related events are within milliseconds of each other, so ordering and understanding is improved when we can see which came first, and not depend on record_id
        @{Name='UserName'; Expression={$_.UserName -eq '' ? $null : $_.UserName}}, 
        @{Name='UserContext'; Expression={$_.UserContext -eq '' ? $null : $_.UserContext}} |
        Select *, @{Name= 'user_id_raw'; Expression={($_.UserName ?? $_.UserContext).Replace($computer + '\', '')}}|
        Select *,
        @{Name='user_id'; Expression={Convert-SidToUser($_.user_id_raw)}} -ExcludeProperty UserContext, UserName|
        Select * -ExcludeProperty user_id_raw|Sort event_created|  # Looks like datetime sorts including the ms portion even if it's not visible.
        Format-Table
        
# 113 Task registered task "%1" , but not all specified triggers will start the task. User Action: Ensure all the task triggers are valid as configured. Additional Data: Error Value: %2.                                                                                                    <template xmlns="http://schemas.microsoft.com/win/2004/08/e...
# 106 User "DSKTP-HOME-JEFF\jeffs"  registered Task Scheduler task "\test_log_sys"; event_message_template=Us… 
# 116 Task Scheduler validated the configuration for task "%1" , but credentials could not be stored. User Action: Re-register the task ensuring the credentials are valid. Additional Data: Error Value: %2.                                                                                 <template xmlns="http://schemas.microsoft.com/win/2004/08/e...

# 140 User "WORKGROUP\DSKTP-HOME-JEFF$"  updated Task Scheduler task "\Microsoft\Windows\WindowsUpdate\RUXIM\… 

# 141 User "DSKTP-HOME-JEFF\jeffs"  deleted Task Scheduler task "\test_log_sys"; event_message_template=User … 
# 115 Task Scheduler failed to roll back a transaction when updating or deleting a task. Additional Data: Error Value: %1.                                                                                                                                                                    <template xmlns="http://schemas.microsoft.com/win/2004/08/e...
# 142 User "%2"  disabled Task Scheduler task "%1"                                                                                                                                                                                                                                            <template xmlns="http://schemas.microsoft.com/win/2004/08/e...

# 129 Task Scheduler launch task "%1" , instance "%2"  with process ID %3.            
# Get last task def we have in storage of task definitions

# Is last task def in storage older than latest scanned event task creation event?

# Yes? Pull new tasks and add to our storage

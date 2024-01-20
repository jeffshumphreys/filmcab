<#
    Pull all scheduled task definitions registered.

    Performance Measurements:
    - Measure-Command {[void](Get-ScheduledTask)}                     520 ms
    - Measure-Command {(Get-ScheduledTask -TaskPath '\')}             501 ms
#>
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Scope='Function', Target='Log-*')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '', Scope='Function', Target='*')]
param()

. .\simplified\_dot_include_standard_header.ps1 

function RecurseDownXSD($xml, [int32]$lvl=0) {
    foreach ($element in $xml.Items) {
        Write-Host "lvl= $lvl, $($element.Name)"                                          
        if ($element.ElementSchemaType -is [System.Xml.Schema.XmlSchemaComplexType]) {
            [System.Xml.Schema.XmlSchemaComplexType] $complexType = $element.ElementSchemaType;
            foreach ($item in $complexType.AttributeUses) {
                foreach ($n in $item.Values) {
                    Write-Host "lvl= $lvl,    attribute=$($n.Name)"
                    Write-Host "lvl= $lvl,    attribute use=$($n.Use)"
                }
            } 
            $particle = $complexType.Particle
            foreach ($item in $particle) {
                RecurseDownXSD $item ($lvl+1)
            }
    
        }
        elseif ($element.ElementSchemaType -is [System.Xml.Schema.XmlSchemaSimpleType]) {
            Write-Host "lvl = $lvl, type is$element.SchemaTypeName"
        }
        else {
            Write-Host "type?"
        }
    }
}    

function main() {
                                                    
    # Unlike Get-WinEvents, where you can prefilter out stuff by dates and such, Get-ScheduledTask gets either all or single. A few thousand tasks might be problematic.
    $scheduledTaskDefs = (Get-ScheduledTask)
            
    foreach ($scheduledTaskDef in $scheduledTaskDefs) {
        $taskPath = $scheduledTaskDef.TaskPath
        $taskName = $scheduledTaskDef.TaskName              
        $taskXML = [XML](Export-ScheduledTask -TaskName "$taskName" -TaskPath "$taskPath")
        $utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
        $sw = New-Object System.IO.StreamWriter('x.xml', $false, $utf8WithoutBom)
        $taskXML.Save($sw)     
        $sw.Close()
        $dataSet = New-Object -TypeName System.Data.DataSet
        $dataSet.ReadXml('x.xml') 
        $dataSet.WriteXmlSchema('x.xsd')
        #$taskXMLSchema = $dataSet.GetXMLSchema()
        $schemaSet = New-Object -TypeName 'System.Xml.Schema.XmlSchemaSet'
        $schemaSet.Add('http://schemas.microsoft.com/windows/2004/02/mit/task', 'x.xsd')
        $schemaSet.Compile()

        Write-Host "************************** $taskPath\$taskName ******************************"
        Write-Host
            
        $schema = $schemaSet.Schemas()[0]
        RecurseDownXSD $schema
    }
}
        
main

<#
    #$taskDetails = 
    $taskDef= [PSCustomObject]@{
        task_full_path         = $taskXML.Task.RegistrationInfo.URI
        task_name              = $taskName
        task_path              = $taskPath
        task_xml_version       = $taskXML.Task.version
        task_creation_date    = (@($taskXML.Task.RegistrationInfo.PSObject.Properties.Name -eq 'Date').Count -eq 1 ? $taskXML.Task.RegistrationInfo.Date : '')
        task_description    = (@($taskXML.Task.RegistrationInfo.PSObject.Properties.Name -eq 'Description').Count -eq 1 ? $taskXML.Task.RegistrationInfo.Description : '')
        task_source    = (@($taskXML.Task.RegistrationInfo.PSObject.Properties.Name -eq 'Source').Count -eq 1 ? $taskXML.Task.RegistrationInfo.Source : '')
        task_principal_id = (@($taskXML.Task.Principals.Principal.PSObject.Properties.Name -eq 'id').Count -eq 1 ? $taskXML.Task.Principals.Principal.Id : '')
        task_principal_user_id = (@($taskXML.Task.Principals.Principal.PSObject.Properties.Name -eq 'UserId').Count -eq 1 ? $taskXML.Task.Principals.Principal.UserId : '')
        task_principal_group_id = (@($taskXML.Task.Principals.Principal.PSObject.Properties.Name -eq 'GroupId').Count -eq 1 ? $taskXML.Task.Principals.Principal.GroupId : '')
        task_principal_logon_type = (@($taskXML.Task.Principals.Principal.PSObject.Properties.Name -eq 'LogonType').Count -eq 1 ? $taskXML.Task.Principals.Principal.LogonType : '')
        task_principal_run_level = (@($taskXML.Task.Principals.Principal.PSObject.Properties.Name -eq 'RunLevel').Count -eq 1 ? $taskXML.Task.Principals.Principal.RunLevel : '')
        MultipleInstancesPolicy        = (@($taskXML.Task.Settings.PSObject.Properties.Name -eq 'MultipleInstancesPolicy'        ).Count -eq 1 ? $taskXML.Task.Settings.MultipleInstancesPolicy             : '')
        DisallowStartIfOnBatteries     = (@($taskXML.Task.Settings.PSObject.Properties.Name -eq 'DisallowStartIfOnBatteries').Count -eq 1 ? $taskXML.Task.Settings.DisallowStartIfOnBatteries          : '')
        StopIfGoingOnBatteries         = (@($taskXML.Task.Settings.PSObject.Properties.Name -eq 'StopIfGoingOnBatteries').Count -eq 1 ? $taskXML.Task.Settings.StopIfGoingOnBatteries              : '')
        AllowHardTerminate             = (@($taskXML.Task.Settings.PSObject.Properties.Name -eq 'AllowHardTerminate').Count -eq 1 ? $taskXML.Task.Settings.AllowHardTerminate                  : '')
        StartWhenAvailable             = (@($taskXML.Task.Settings.PSObject.Properties.Name -eq 'StartWhenAvailable').Count -eq 1 ? $taskXML.Task.Settings.StartWhenAvailable                  : '')
        RunOnlyIfNetworkAvailable      = (@($taskXML.Task.Settings.PSObject.Properties.Name -eq 'RunOnlyIfNetworkAvailable').Count -eq 1 ? $taskXML.Task.Settings.RunOnlyIfNetworkAvailable           : '')
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

    }    
    $taskDefs+= $taskDef

    $taskActionsXML = $taskXML.Task.Actions

    foreach ($taskAction in $taskActionsXML) {
        $actionType = (@($taskAction.PSObject.Properties.Name -eq 'Exec').Count -eq 1 ? 'Exec': '?')
        $actionContext = (@($taskAction.PSObject.Properties.Name -eq 'Context').Count -eq 1 ? $taskAction.Context: '')
        $actionDef = [PSCustomObject]@{
            Command   = ''
            Arguments = ''
            WorkingDirectory = ''
        }

        if ($actionType -eq 'Exec') {
            $actionDef.Command = $taskAction.Exec.Command
            $actionDef.Arguments = $taskAction.Exec.Arguments
            $actionDef.WorkingDirectory = (@($taskAction.Exec.PSObject.Properties.Name -eq 'WorkingDirectory').Count -eq 1 ? $taskAction.Exec.WorkingDirectory : '')
        }
    }                       
    
    $taskTriggersXML = $taskXML.Task.Triggers

    # Get trigger type, then split out Calendars, Time, Event, etc.
}

$taskDefs
<#
RegistrationInfo : RegistrationInfo
Principals       : Principals
Settings         : Settings
Triggers         : Triggers
Actions          : Actions


<#
$Scheduledtasksxml = @()
$howmanyScheduledtasks = (Get-ScheduledTask).Count
for (($i = 0); $i -lt $howmanyScheduledtasks; $i++) {
    $i
    try {
        $Scheduledtaskxml = [XML]((Get-ScheduledTask)[$i] | Export-ScheduledTask)
        $Scheduledtasksxml+= [pscustomobject]@{id=$i; xmldata = $Scheduledtaskxml}
        }
        catch {
            Write-Host "Error on #$i"
            $blockedExport = (Get-ScheduledTask)[$i]
            $blockedTaskPath = $blockedExport.TaskPath
            $blockedTaskName = $blockedExport.TaskName
            $blockedtaskxml = [XML](Export-ScheduledTask -TaskName "$blockedTaskName" -TaskPath "$blockedTaskPath")
            $Scheduledtasksxml+= [pscustomobject]@{id=$i; xmldata = $blockedtaskxml}
        }
}
                     

<# 
    Force full reload: 
    Remove-Item -Path 'task-scheduler-events.xml' -Force   # Rebuilds all new, removed attributes.


if (Test-Path 'task-scheduler-defs.xml' -PathType Leaf) {
    $oldtaskSchedulerDefs = Import-Clixml -Path "task-scheduler-defs.xml"
    $file = Get-Item '.\task-scheduler-defs.xml'
    $Script:lastSavedDefCreatedDate = $file.CreationTime
} else {
    $Script:lastSavedDefCreatedDate = 0 # Force a full reload
}

# Write/Merge to file

$taskRegistrationInfo = $Scheduledtasksxml|Select  @{name = 'task_id';expression = {$_.id}} -expand xmldata|select task_id -expand task|Select task_id -ExpandProperty RegistrationInfo|
    Select task_id, 
        @{Name = 'task_full_name'; Expression = {$_.URI}},
        @{Name = 'task_creation_date'; Expression = {$_.Date}},
        @{Name = 'task_author'; Expression = {$_.Author}},
        @{Name = 'task_description'; Expression = {$_.Description}},
        @{Name = 'task_security_descriptor'; Expression = {$_.SecurityDescriptor}},
        @{Name = 'task_source'; Expression = {$_.Source}}|
        Select * 

$taskPrincipals = $Scheduledtasksxml|Select @{name = 'task_id';expression = {$_.id}} -ExpandProperty xmldata|select task_id -expand Task|select task_id -expand Principals|select task_id -expand Principal|select task_id, id, UserId, LogonType, GroupId, RunLevel

$taskActionsExec = $Scheduledtasksxml|Select @{name = 'task_id';expression = {$_.id}} -ExpandProperty xmldata|select task_id -expand Task|select task_id -expand Actions|select task_id -expand Exec -ErrorAction Ignore|Select task_id, Command, Arguments, WorkingDirectory
$taskActionsCom = $Scheduledtasksxml|
    Select @{name = 'task_id';expression = {$_.id}} -ExpandProperty xmldata|
    Select task_id -expand Task|select task_id -expand Actions|select task_id, Context -Expand ComHandler -ErrorAction Ignore|
    Select task_id, Context, ClassId, Data|
    Select task_id, Context, ClassId, Data -ExpandProperty Data
$taskActionsComData = $Scheduledtasksxml|Select @{name = 'task_id';expression = {$_.id}} -ExpandProperty xmldata|select task_id -expand Task|select task_id -expand Actions|select task_id, Context -Expand ComHandler -ErrorAction Ignore|Select -Expand Data -ErrorAction Ignore
$taskLogonTriggers = $Scheduledtasksxml|Select @{name = 'task_id';expression = {$_.id}} -ExpandProperty xmldata|select task_id -expand Task|select task_id -expand Triggers| Select task_id -expand LogonTrigger -ErrorAction Ignore
$taskCalendarTriggers = $Scheduledtasksxml| ForEach-Object {
    $_|Select @{name = 'task_id';expression = {$_.id}} -ExpandProperty xmldata|select task_id -expand Task|select task_id -expand Triggers|select task_id -ExpandProperty CalendarTrigger -ErrorAction Ignore|
        ForEach-Object {$index = 0} {
            [PSCustomObject] @{ Task_Id = $_.task_id; Index = $index; Object = $_ }; $index++
        }
    }

$taskLogonTriggerRepetitions = $Scheduledtasksxml|Select @{name = 'task_id';expression = {$_.id}} -ExpandProperty xmldata|select task_id -expand Task|select task_id -expand Triggers| Select task_id -expand LogonTrigger -ErrorAction Ignore|Select task_id -ExpandProperty Repetition -ErrorAction Ignore
$taskCalendarTriggerSchedByDay = $Scheduledtasksxml|Select @{name = 'task_id';expression = {$_.id}} -ExpandProperty xmldata|select task_id -expand Task|select task_id -expand Triggers|select task_id -ExpandProperty CalendarTrigger -ErrorAction Ignore|Select task_id -ExpandProperty ScheduleByDay -ErrorAction Ignore
$taskCalendarTriggerSchedByWeek = $Scheduledtasksxml|Select @{name = 'task_id';expression = {$_.id}} -ExpandProperty xmldata|select task_id -expand Task|select task_id -expand Triggers|select task_id -ExpandProperty CalendarTrigger -ErrorAction Ignore|Select task_id -ExpandProperty ScheduleByWeek -ErrorAction Ignore
$taskCalendarTriggerSchedByMonth = $Scheduledtasksxml|Select @{name = 'task_id';expression = {$_.id}} -ExpandProperty xmldata|select task_id -expand Task|select task_id -expand Triggers|select task_id -ExpandProperty CalendarTrigger -ErrorAction Ignore|Select task_id -ExpandProperty ScheduleByMonth -ErrorAction Ignore


Class TaskFlatDef {
    [int]     $task_id
    [string]  $task_full_name
    [datetime] $task_creation_date
    [string]   $task_description
    [string]   $task_author
    [string]   $task_security_descriptor
    [string]   $task_source

    TaskFlatDef([pscustomobject]$ob) {
        $ob.psobject.properties | Foreach { 
            $_.TypeNameOfValue
            # System.Int32
            $type = $_.TypeNameOfValue
            Write-Host "$type prope= = $type"
            if ($_.TypeNameOfValue -eq 'System.datetime' -and $null -eq $_.Value) {
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

#>
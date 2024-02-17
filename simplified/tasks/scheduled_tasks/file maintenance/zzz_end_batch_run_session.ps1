<#
 #    FilmCab Daily morning batch run process: End and close and check for oddities.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Starting to work on
 #    ###### Tue Jan 23 18:23:11 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #>
 
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()

. .\_dot_include_standard_header.ps1
                                   

# Track some stats. Useful for finding bugs. For instance, kept getting 12 new junction points, the same ones. turns out the test was bad.

# Check table: is it show as active?

# How long did we run? Same day?

# Did computer get rebooted since start of session?

# Did all the tasks run? About the right time?

# Unusual space amount eaten up?
                                                                    
# Check: $SanityCheckStatus|ConvertTo-Json|Out-File 'D:\qt_projects\filmcab\simplified\_data\__sanity_check_before_connection_before_session_starts.json'
# Changed??  Shouldn't have.

# Da Fuutar!!!
. .\_dot_include_standard_footer.ps1


. .\shared_code\__sanity_check_without_db_connection.ps1 'without_db_connection' 'after_session_ends'

# Copy and date days sanity checks to history

# Compare  D:\qt_projects\filmcab\simplified\_log\__sanity_checks\__sanity_check_before_connection_before_session_starts.json
#      to  D:\qt_projects\filmcab\simplified\_log\__sanity_checks\__sanity_check_before_connection_after_session_ends.json

$state_of_session = Out-SqlToDataset "SELECT batch_run_session_id, started FROM batch_run_sessions WHERE running"

# Check if old session still marked as active

if ($null -ne $state_of_session -and $state_of_session.Table.Rows.Count -eq 1) {

    # STATE: batch run session flagged as still running. Probably means the zzz_end_batch_run_session never updated it? Crashed? Was debugging?

    # Flush out the active marked record so we can start a new session.
    
    Invoke-Sql "UPDATE batch_run_sessions SET running = NULL, session_killing_script = '$ScriptName', stopped = CURRENT_TIMESTAMP, caller_stopping = '$Script:Caller' WHERE running" | Out-Null
}                                                                          
elseif ($null -ne $state_of_session -and $state_of_session.Table.Rows.Count -gt 1) {                         
    # Broken table constraint, only possibility, so note it and crash.
    throw [System.Exception]"ERROR: More than one session marked active: Query was 'SELECT batch_run_session_id, started FROM batch_run_sessions WHERE running', STOPPING!"
}                                                                                                                                                                         
elseif ($null -eq $state_of_session) {
    # No session active??
    throw [Exception]"ERROR!: I'm running zzz_end_batch_run_session.ps1 AND NO SESSION IS ACTIVE!!!!"
}


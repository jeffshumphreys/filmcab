<#
 #    FilmCab Daily morning batch run process: Start tracking # for this batch run session.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Basics in place; scheduling.
 #    ###### Wed Jan 24 12:16:40 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #    Set a number and UUID for this session so we can track upstream activity to downstream consequences.  Bet the lovely Meridian School District IT team (bless them) never considered that. Gary, the fat worm.
 #>
                                            
# This is the first task in the batch run session. So do a BEFORE sanity check.
# Granted, technically this IS the session, so semantics is important.  What is before session and first of session?  Will this ALWAYS be the first task, that is "_set_new_batch_run_session_id.ps1"?
# A better name would be "_start_new_batch_run_session" paired to "zzz_end_batch_run_session"

try {
. .\__sanity_check_without_db_connection.ps1 'without_db_connection' 'before_session_starts'

# Compare  D:\qt_projects\filmcab\simplified\_log\__sanity_checks\__sanity_check_before_connection_before_session_starts.json 
#      to  D:\qt_projects\filmcab\simplified\_log\__sanity_checks\__sanity_check_before_connection_after_session_ends.json (yesterdays)

# The header includes the database connection

. .\_dot_include_standard_header.ps1 
                                                                            
# . D:\qt_projects\filmcab\simplified\__sanity_check_with_db_connection.ps1
#
$state_of_session = Out-SqlToDataset "SELECT batch_run_session_id, started FROM batch_run_sessions WHERE running" -DontWriteSqlToConsole

# Check if old session still marked as active

if ($null -ne $state_of_session -and $state_of_session.Table.Rows.Count -eq 1) {

    # STATE: batch run session flagged as still running. Probably means the zzz_end_batch_run_session never updated it? Crashed? Was debugging?

    # Flush out the active marked record so we can start a new session.
    
    Invoke-Sql "UPDATE batch_run_sessions SET running = NULL, session_killing_script = '$ScriptName', marking_stopped_after_overrun = CURRENT_TIMESTAMP WHERE running" | Out-Null
}                                                                          
elseif ($null -ne $state_of_session -and $state_of_session.Table.Rows.Count -gt 1) {                         
    # Broken table constraint, only possibility, so note it and crash.
    throw [System.Exception]"ERROR: More than one session marked active: Query was 'SELECT batch_run_session_id, started FROM batch_run_sessions WHERE running', STOPPING!"
}                                                                                                                                                                         
elseif ($null -eq $state_of_session) {
    # No session active?? Hopefully???
    
}
    
# "Starts"
$rowsAdded = Invoke-Sql "INSERT INTO batch_run_sessions(last_script_ran, session_starting_script, caller, caller_starting) VALUES('$scriptName', '$scriptName', '$Script:Caller', '$Script:Caller')" 
Write-AllPlaces "Added $rowsAdded row(s) to batch run_session"

}
catch {
    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}                                  
finally {
    Write-AllPlaces "Finally"
    . .\_dot_include_standard_footer.ps1
}
<#
 #    FilmCab Daily morning batch run process: Start tracking # for this batch run session.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Basics in place; scheduling.
 #    ###### Wed Jan 24 12:16:40 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #    Set a number and UUID for this session so we can track upstream activity to downstream consequences.  Bet the lovely Meridian School District IT team (bless them) never considered that. Gary, the fat worm.
 #>
                                            
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()
    
# This is the first task in the batch run session. So do a BEFORE sanity check.
# Granted, technically this IS the session, so semantics is important.  What is before session and first of session?  Will this ALWAYS be the first task, that is "_set_new_batch_run_session_id.ps1"?
# A better name would be "_start_new_batch_run_session" paired to "zzz_end_batch_run_session"

. D:\qt_projects\filmcab\simplified\shared_code\__sanity_check_without_db_connection.ps1 'without_db_connection' 'before_session_starts'

# Compare  D:\qt_projects\filmcab\simplified\_log\__sanity_checks\__sanity_check_before_connection_before_session_starts.json 
#      to  D:\qt_projects\filmcab\simplified\_log\__sanity_checks\__sanity_check_before_connection_after_session_ends.json (yesterdays)

# The header includes the database connection
. D:\qt_projects\filmcab\simplified\shared_code\_dot_include_standard_header.ps1 
                                                                            
# . D:\qt_projects\filmcab\simplified\__sanity_check_with_db_connection.ps1
#
$state_of_session = Out-SqlToDataset "SELECT batch_run_session_id, started FROM batch_run_sessions WHERE running"

# Check if old session still marked as active

if ($null -ne $state_of_session) {
    # TODO: Check what's running??
    # Check what time: Is it like midnight??
    # Should child tasks lock the row?

    # Flush out the active marked record so we can start a new session.
    
    Invoke-Sql "UPDATE batch_run_sessions SET running = NULL, session_killing_script = '$ScriptName' WHERE running" | Out-Null
}
    
# "Starts"
Invoke-Sql "INSERT INTO batch_run_sessions(last_script_ran) VALUES('$scriptName')" | Out-Null

# Get last id from batch_run_sessions table.                    

. D:\qt_projects\filmcab\simplified\shared_code\_dot_include_standard_footer.ps1 
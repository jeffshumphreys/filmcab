<#
 #    FilmCab Daily morning batch run process: End and close and check for oddities.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Starting to work on
 #    ###### Tue Jan 23 18:23:11 MST 2024
 #    Reviewed and refactored: ###### Sat Feb 17 12:02:04 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #>

try {
. .\_dot_include_standard_header.ps1

$state_of_session = Out-SqlToDataset "SELECT batch_run_session_id, started FROM batch_run_sessions WHERE running"

# Check if old session still marked as active
                                                                         
if ($null -ne $state_of_session -and $state_of_session -isnot [String] -and $state_of_session.Count -eq 1) {
    if ( $state_of_session -is [System.Data.DataRow]) { # Out-SqlToDataset returns an object if only one row, hence
        Invoke-Sql "UPDATE batch_run_sessions SET running = NULL, session_killing_script = '$ScriptName', stopped = CURRENT_TIMESTAMP, caller_stopping = '$Script:Caller' WHERE running" | Out-Null
    } else {
        Show-Error -message "ERROR!: I'm running zzz_end_batch_run_session.ps1 AND NO SESSION IS ACTIVE!!!! (1)" -exitcode 2
    }
}
elseif ($null -ne $state_of_session -and $state_of_session -isnot [String] -and $state_of_session.Count -eq 2) {
                                                                  
    if ($state_of_session[0] -is [String] -and $state_of_session[1] -is [System.Data.DataRow]) {
        # STATE: batch run session flagged as still running. Probably means the zzz_end_batch_run_session never updated it? Crashed? Was debugging?

        # Flush out the active marked record so we can start a new session.
        
        Invoke-Sql "UPDATE batch_run_sessions SET running = NULL, session_killing_script = '$ScriptName', stopped = CURRENT_TIMESTAMP, caller_stopping = '$Script:Caller' WHERE running" | Out-Null
    } else {
        Show-Error -message "ERROR!: I'm running zzz_end_batch_run_session.ps1 AND UNRECOGNIZED TYPE SITU!" -exitcode 3
    }
}                                                                          
elseif ($null -ne $state_of_session -and $state_of_session -isnot [String] -and $state_of_session.Table.Count -gt 2) {                         
    # Broken table constraint, only possibility, so note it and crash.
    Show-Error -message "ERROR: More than one session marked active: Query was 'SELECT batch_run_session_id, started FROM batch_run_sessions WHERE running', STOPPING!" -exitcode 4
}                                                                                                                                                                         
elseif ($null -eq $state_of_session -or $state_of_session -is [String]) {
    # No session active??
    Show-Error -message "ERROR!: I'm running zzz_end_batch_run_session.ps1 AND NO SESSION IS ACTIVE!!!! (2)" -exitcode 5
}

# Track some stats. Useful for finding bugs. For instance, kept getting 12 new junction points, the same ones. turns out the test was bad.

# Check table: is it show as active?

# How long did we run? Same day?

# Did computer get rebooted since start of session?

# Did all the tasks run? About the right time?

# Unusual space amount eaten up?
                                                                    
# Check: $SanityCheckStatus|ConvertTo-Json|Out-File 'D:\qt_projects\filmcab\simplified\_data\__sanity_check_before_connection_before_session_starts.json'
# Changed??  Shouldn't have.

. .\__sanity_check_without_db_connection.ps1 'without_db_connection' 'after_session_ends'

}
catch {
    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}                                  
finally {
    Write-AllPlaces "Finally" -ForceStartOnNewLine
    . .\_dot_include_standard_footer.ps1
}
# Copy and date days sanity checks to history

# Compare  D:\qt_projects\filmcab\simplified\_log\__sanity_checks\__sanity_check_before_connection_before_session_starts.json
#      to  D:\qt_projects\filmcab\simplified\_log\__sanity_checks\__sanity_check_before_connection_after_session_ends.json

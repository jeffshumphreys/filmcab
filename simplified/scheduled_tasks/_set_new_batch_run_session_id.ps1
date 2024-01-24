<#
 #    FilmCab Daily morning batch run process: Verify SearchPaths on our specific volumes are recorded in the database.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Basics in place; scheduling.
 #    ###### Wed Jan 24 12:16:40 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #    Set a number and UUID for this session so we can track upstream activity to downstream consequences.  Bet the lovely Meridian School District IT team (bless them) never considered that. Gary, the fat worm.
 #>
                                            
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Scope='Function', Target='Log-*')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '', Scope='Function', Target='*')]
param()

. D:\qt_projects\filmcab\simplified\_dot_include_standard_header.ps1 
      
$state_of_session = Out-SqlToDataset "SELECT batch_run_session_id, started FROM batch_run_sessions WHERE running"

if ($null -ne $state_of_session) {
    # TODO: Check what's running??
    # Check what time: Is it like midnight??
    # Should child tasks lock the row?g
    Invoke-Sql "UPDATE batch_run_sessions SET running = NULL, session_killing_script = '$ScriptName' WHERE running" > $null
}

Invoke-Sql "INSERT INTO batch_run_sessions(last_script_ran) VALUES('$scriptName')" > $null

# Get last id from batch_run_sessions table.                    

. D:\qt_projects\filmcab\simplified\_dot_include_standard_footer.ps1 
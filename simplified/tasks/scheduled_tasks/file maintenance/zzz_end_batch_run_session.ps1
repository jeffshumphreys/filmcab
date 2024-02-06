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

. D:\qt_projects\filmcab\simplified\shared_code\_dot_include_standard_header.ps1
                                   

# Track some stats. Useful for finding bugs. For instance, kept getting 12 new junction points, the same ones. turns out the test was bad.

# Check table: is it show as active?

# How long did we run? Same day?

# Did computer get rebooted since start of session?

# Did all the tasks run? About the right time?

# Unusual space amount eaten up?
                                                                    
# Check: $SanityCheckStatus|ConvertTo-Json|Out-File 'D:\qt_projects\filmcab\simplified\_data\__sanity_check_before_connection_before_session_starts.json'
# Changed??  Shouldn't have.

# Da Fuutar!!!
. D:\qt_projects\filmcab\simplified\shared_code\_dot_include_standard_footer.ps1

. D:\qt_projects\filmcab\simplified\shared_code\__sanity_check_without_db_connection.ps1 'without_db_connection' 'after_session_ends'
                                                                                                                          
# Copy and date days sanity checks to history

# Compare  D:\qt_projects\filmcab\simplified\_log\__sanity_checks\__sanity_check_before_connection_before_session_starts.json
#      to  D:\qt_projects\filmcab\simplified\_log\__sanity_checks\__sanity_check_before_connection_after_session_ends.json
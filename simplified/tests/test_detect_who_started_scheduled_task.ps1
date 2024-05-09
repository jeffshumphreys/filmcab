<#
 #    Testing and fixing crashing Start-Log
 #    Status: Conception
 #    ###### Sat Feb 3 22:20:01 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #>

try {
    . .\__sanity_check_without_db_connection.ps1 'without_db_connection' 'before_session_starts'
# Fake out Start-Log for testing purposes.  You can't capture Windows Task Scheduler live events from a test, so fake!

$Script:TestScheduleDrivenTaskDetection     = $true
$Script:PretendMyFileNameWithoutExtensionIs = 'back_up_unbackedup_published_media'                    # event
$Script:PretendMyFileNameWithoutExtensionIs = 'MicrosoftEdgeUpdateTaskMachineCore'                    # event (Really is an Idle trigger!!!!!)
$Script:PretendMyFileNameWithoutExtensionIs = 'OneDrive Reporting Task-S-1-5-21-260979430-3554011381-420227292-1001' # One-Time
$Script:PretendMyFileNameWithoutExtensionIs = 'BackgroundDownload'                                    # idle?
$Script:PretendMyFileNameWithoutExtensionIs = 'nWizard_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}'        # Logon
$Script:PretendMyFileNameWithoutExtensionIs = 'VerifiedPublisherCertStoreCheck'                       # System Startup
$Script:PretendMyFileNameWithoutExtensionIs = '_start_new_batch_run_session'                          # scheduler, user

#WARNING: IF No active sessions, header code stuffs this on #1!!!! So testing can happen!

 . .\_dot_include_standard_header.v2.ps1

 if (Test-Path variable:Script:WindowsSchedulerTaskTriggeringEvent) {
    Write-AllPlaces "$($Script:WindowsSchedulerTaskTriggeringEvent.TaskDisplayName)"
    # Task triggered on scheduler                type: MSFT_TaskDailyTrigger
    # Task triggered by user
    # Task triggered on event
    # Task triggered on logon                    UserName=DSKTP-HOME-JEFF\jeffs

 }

 $Script:TestScheduleDrivenTaskDetection = $false
}
catch {
    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}
finally {
    Write-AllPlaces "Finally" -ForceStartOnNewLine
    . .\_dot_include_standard_footer.ps1
}

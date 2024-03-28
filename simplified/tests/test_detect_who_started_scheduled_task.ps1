<#
 #    Testing and fixing crashing Start-Log
 #    Status: Conception
 #    ###### Sat Feb 3 22:20:01 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #>

# Fake out Start-Log
$Script:TestScheduleDrivenTaskDetection = $true
$Script:PretendMyFileNameWithoutExtensionIs = 'nWizard_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}'          # Logon
$Script:PretendMyFileNameWithoutExtensionIs = 'MicrosoftEdgeUpdateTaskMachineCore'                      # event (Really is an Idle trigger!!!!!)
$Script:PretendMyFileNameWithoutExtensionIs = 'back_up_unbackedup_published_media'                      # event
$Script:PretendMyFileNameWithoutExtensionIs = '_start_new_batch_run_session'                            # scheduler, user

 . .\_dot_include_standard_header.ps1
 
 if (Test-Path variable:Script:WindowsSchedulerTaskTriggeringEvent) {
    Write-AllPlaces "$($Script:WindowsSchedulerTaskTriggeringEvent.TaskDisplayName)"
    # Task triggered on scheduler                type: MSFT_TaskDailyTrigger
    # Task triggered by user
    # Task triggered on event                                                                                  
    # Task triggered on logon                    UserName=DSKTP-HOME-JEFF\jeffs

 }
 . .\_dot_include_standard_footer.ps1
                                               
 $Script:TestScheduleDrivenTaskDetection = $false


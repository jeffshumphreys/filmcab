#C:\Users\jeffs\.vscode\extensions\ms-vscode.powershell-2023.8.0\examples\PSScriptAnalyzerSettings.psd1
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Scope='Function', Target='Log-*')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '', Scope='Function', Target='*')]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$taskname = 'test_log_sys'
try {
    Unregister-ScheduledTask $taskname -Confirm:$false
} catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException] {
    if ($_.CategoryInfo.Category -eq 'ObjectNotFound') {
        # Good, we can add it then
    } else {
        throw
    }
}

#$actions = (New-ScheduledTaskAction -Execute 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -Argument "-WindowStyle Hidden `"D:\qt_projects\filmcab\General\$taskname.ps1`"")
$actions = (New-ScheduledTaskAction -Execute 'C:\Program Files\PowerShell\7\pwsh.exe' -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass `"D:\qt_projects\filmcab\General\$taskname.ps1`"")
$trigger = New-ScheduledTaskTrigger -Daily -At '12:01 AM'
$principal = New-ScheduledTaskPrincipal -UserId 'dsktp-home-jeff\jeffs' -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -RunOnlyIfNetworkAvailable -WakeToRun
$task = New-ScheduledTask -Action $actions -Principal $principal -Trigger $trigger -Settings $settings -Description "Test the log system on run."
Register-ScheduledTask $taskname -InputObject $task 
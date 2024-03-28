$xmlfilter = @"
<QueryList>
<Query Id="0" Path="Microsoft-Windows-TaskScheduler/Operational">
<Select Path="Microsoft-Windows-TaskScheduler/Operational">
(*[EventData[(Data[@Name='TaskName']='\FilmCab\file maintenance\scan_file_directories_for_files')]])
</Select>
</Query>
</QueryList>
"@       
$lasteventWhileRunningIs = Get-WinEvent -FilterXml $xmlfilter|Select Message, TaskDisplayName, TimeCreated, RecordId, ThreadId, ActivityId, 
@{Name='ResultCode'; Expression = {
        if ($_.Id -in @(203,716,201,715,714,305,713,316,315,717,202,718,105,205,104,712,103,306,204,101,307,311,331,403,711,702,126,303,703,130,704,705,706,707,708,709,413,412,113,146,410,408,401,115,116,710,404,409,151,150,406,407,148,405,701)) {
                      if ($_.Id -in @(716,715,717,718,712,702,703,704,705,413,412,410,408,115,710,409,406,407,405,701) -and $_.Version -eq 0) {
        $_.Properties[0].Value
        }          elseif ($_.Id -in @(714,713,316,315,105,205,306,204,307,403,711,126,130,707,709,113,146,401,116,404,150,148) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }          elseif ($_.Id -in @(305,104,101,331,303,706,708,151) -and $_.Version -eq 0) {
        $_.Properties[2].Value
        }          elseif ($_.Id -in @(203,202,103,311) -and $_.Version -eq 0) {
        $_.Properties[3].Value
        }          elseif ($_.Id -in @(201,202) -and $_.Version -eq 1) {
        $_.Properties[3].Value
        }          elseif ($_.Id -in @(201) -and $_.Version -eq 2) {
        $_.Properties[3].Value
        }
        }
     }},
    @{Name='UserContext'; Expression = {
        if ($_.Id -in @(110,100,101,106,330,102,103)) {
                      if ($_.Id -in @(100,101,106,102) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }          elseif ($_.Id -in @(110,330,103) -and $_.Version -eq 0) {
        $_.Properties[2].Value
        }
        }
     }},
    @{Name='UserName'; Expression = {
        if ($_.Id -in @(124,134,119,133,141,121,142,104,122,120,123,125,332,140)) {
                      if ($_.Id -in @(104) -and $_.Version -eq 0) {
        $_.Properties[0].Value
        }          elseif ($_.Id -in @(124,134,119,141,121,142,122,120,123,125,332,140) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }          elseif ($_.Id -in @(133) -and $_.Version -eq 0) {
        $_.Properties[2].Value
        }
        }
     }},
    @{Name='InstanceId'; Expression = {
        if ($_.Id -in @(123,120,122,125,121,111,118,117,114,110,109,108,107,103,102,100,119,124)) {
                      if ($_.Id -in @(111,118,117,114,110,109,108,107,103) -and $_.Version -eq 0) {
        $_.Properties[1].Value
        }          elseif ($_.Id -in @(123,120,122,125,121,102,100,119,124) -and $_.Version -eq 0) {
        $_.Properties[2].Value
        }
        }
     }}| 
Out-GridView
#$lasteventWhileRunningIs = Get-WinEvent -FilterXml $xmlfilter|Select *

. .\include_filmcab_header.ps1
:doitallover while($true) {
$DBReader = $DBConn.CreateCommand()
$DBReader.CommandText = "SELECT txt AS file_path, id AS file_id, file_size FROM stage_for_master.files WHERE (file_lost IS NULL OR file_lost IS FALSE) AND (updated_file_hash IS NULL OR updated_file_hash IS FALSE)
                        ORDER BY file_id";
$rtnrows = $DBReader.ExecuteReader()
$jobMax        = 2
$jobs          = @()
Get-Job|Stop-Job > $null
Get-Job|Remove-Job > $null
$howmanyfilehashesupdated = 0

:readNextFileId while ($rtnrows.Read()) {
    [string]$file_path = $rtnrows.GetValue(0)
    [int64]$file_id    = $rtnrows.GetValue(1)
    [int64]$file_size  = $rtnrows.GetValue(2)
    $file_size_readable = $file_size.ToString('###,###,###,###,##0')
    :forceRetryOfAFileIdWhenStackWasFull while ($true) {
        if ($jobs.Count -lt $jobMax) { # This ends up counting correctly if you use -lt rather than -le.  Once it is 2, then it would add a third, get it?
            $job = Start-Job -Name $file_id -ScriptBlock {
                $file_path = $Using:file_path
                $file_id   = $Using:file_id
                $file_size = $Using:file_size

                if (Test-Path -LiteralPath $file_path -PathType Leaf) {
                    $file_hash             = Get-FileHash -LiteralPath $file_path -Algorithm MD5;
                    $Conn                  = New-Object System.Data.Odbc.OdbcConnection;
                    $Conn.ConnectionString = "Driver={PostgreSQL UNICODE(x64)};Server=$Using:MyServer;Port=$Using:MyPort;Database=$Using:MyDB;Uid=$Using:MyUid;Pwd=$Using:MyPass;";
                    $Conn.Open();
                    $Command               = $Conn.CreateCommand();
                    $Command.CommandText   = "UPDATE stage_for_master.files SET file_md5_hash = '$($file_hash.Hash)'::bytea, updated_file_hash = True WHERE id = $file_id";
                    $Command.ExecuteNonQuery();
                    $Conn.Close();
                } 
            } 
            $job_id = $job.Id
            $jobs+= $job
            $onstack = $jobs.Count
            Write-Host "Added job # $job_id for file_id $file_id at stack element #$onstack, for $file_size_readable bytes"
            continue readNextFileId
        } else {
            # Bug: The current job on the result set is skipped.
            $rmjb|Receive-Job >$null
            $rmjb = $jobs|Wait-Job -Any # Comes back right away, not when job finishes
            if ($rmjb.State -eq "Completed") { # Only remove a job from the queue if it completes, or is not running.
                $rmjb|Receive-Job >$null
                $howmanyfilehashesupdated++
                $newjobs = $jobs | Where-Object { $_.Id –ne $rmjb.Id } # A beautiful feature in PS is that if you delete an element from a 2 element array, it magically turns into an object.
                if ($newjobs.GetType().Name -eq "PSRemotingJob") {
                    $jobs = @()
                    $jobs+= $newjobs # An array of 1
                } else {
                    $jobs = $newjobs # An array of 2 or more
                }

                $remove_job_id = $rmjb.Id
                $remove_file_id = $rmjb.Name
                Write-Host "$howmanyfilehashesupdated runs so far, Dropping ended job # $remove_job_id for file_id $remove_file_id"
                if ($file_id -eq $remove_file_id) {
                    continue readNextFileId  # Did we already process this one? Then get a new one
                } else {
                        continue forceRetryOfAFileIdWhenStackWasFull # A different id, so force reprocess now that queue is lower.
                }
            } else {
                # Still running  (not hitting)
                Write-Host "still running"
                Start-Sleep -Milliseconds 250 # Wait and not hit again.
                continue forceRetryOfAFileIdWhenStackWasFull
            }
        }
    }
}
$jobs | Wait-Job
Receive-Job $jobs -Wait
Get-Job
Write-Host "How many file_ids corrected: $howmanyfilehashesupdated"

$DBReader = $DBConn.CreateCommand()
$DBReader.CommandText = "SELECT COUNT(*) FROM stage_for_master.files WHERE (file_lost IS NULL OR file_lost IS FALSE) AND (updated_file_hash IS NULL OR updated_file_hash IS FALSE)";
$rowsleft = $DBReader.ExecuteScalar()
if ($rowsleft) {
    Write-Host "Still rows!!!! $rowsleft"
    continue doitallllllover
}
}
Write-Host "Fine!"
<#
    FilmCab Daily morning process: Calculate MD5 hashes for new files.
    Status: Working in Test

    This calculates MD5 hashes on all massive movie files.  This runs after all new files and directories have been mapped into the files table, all files verified as still existing.

    So far MD5 hashes on contents have proven unique, though I don't know how long that will last. Should I use UUIDs?
    One nice thing using the hash as a foreign key, if a file goes missing and then is reacquired, they'll line right up.
    That and the hash will link up across any future tables.
#>

. .\simplified\includes\include_filmcab_header.ps1 # local to base directory of base folder for some reason.
:doitallover while($true) {
$DBReader = $DBConn.CreateCommand()
$DBReader.CommandText = "SELECT txt AS file_path, id AS file_id, file_size FROM stage_for_master.files WHERE file_lost IS DISTINCT FROM FALSE AND updated_file_hash IS DISTINCT FROM FALSE
                        ORDER BY file_id"; # Helps with watching ids finish up in the database.
$rtnrows = $DBReader.ExecuteReader()
$jobMax        = 2 # 2 results in 4 pwsh instances, 4 console window hosts. Visual Studio Code has 9 instances and I don't know why.  Will have to investigate. CPU bounces between 6 and 12%
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

                $Conn                  = New-Object System.Data.Odbc.OdbcConnection;
                $Conn.ConnectionString = $Using:connString;
                $Conn.Open();
                $Command               = $Conn.CreateCommand();

                if (Test-Path -LiteralPath $file_path -PathType Leaf) {
                    $file_hash             = Get-FileHash -LiteralPath $file_path -Algorithm MD5;
                    $Command.CommandText   = "UPDATE stage_for_master.files SET file_md5_hash = '$($file_hash.Hash)'::bytea, updated_file_hash = True WHERE id = $file_id";
                    $Command.ExecuteNonQuery();
                    $Conn.Close();
                } else {
                    $Command.CommandText   = "UPDATE stage_for_master.files SET file_lost = TRUE, file_loss_detected_on_ts_wth_tz = clock_timestamp() WHERE id = $file_id";
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
if ($jobs.Count -gt 0) {
    Receive-Job $jobs -Wait
    Get-Job
    Write-Host "How many file_ids corrected: $howmanyfilehashesupdated"
}
$DBReader = $DBConn.CreateCommand()
$DBReader.CommandText = "SELECT COUNT(*) FROM stage_for_master.files WHERE (file_lost IS NULL OR file_lost IS FALSE) AND (updated_file_hash IS NULL OR updated_file_hash IS FALSE)";
$rowsleft = $DBReader.ExecuteScalar()
if ($rowsleft -gt 0) {
    Write-Host "Still rows!!!! $rowsleft"
    continue doitallllllover
} else {
    break doitallover
}
}
Write-Host "Fine!"
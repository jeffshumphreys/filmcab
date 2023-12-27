<#
    FilmCab Daily morning process: Verify the paths and files and volumes stored in the files table exist on some hard drive.
    Status: Working in Test

    This is done early in the batch so as to reduce labor later, trying to generate hashes on nonexistent files, listing files a dups when one doesn't exist.
#>
. .\simplified\includes\include_filmcab_header.ps1 # local to base directory of base folder for some reason.

$listoffilesmissing = @()
$listoffilesfound = @()
if ($dbconnopen) {
    $DBCmd.CommandText = "
    SELECT f.txt path 
    FROM stage_for_master.files f 
    WHERE (f.record_deleted IS NULL OR f.record_deleted is false)
        and (f.file_lost IS NULL OR f.file_lost is false)";
    $rtnrows = $DBCmd.ExecuteReader();
    while ($rtnrows.Read()) {
        $lastknownpath = $rtnrows.GetValue(0)
        if ([System.IO.File]::Exists($lastknownpath)) {
            $listoffilesfound+= $lastknownpath
            Write-Host -NoNewline '=.' # Found
        } else {
            $listoffilesmissing+= $lastknownpath
            Write-Host -NoNewline '-.' # Missing
        }
    }
    $rtnrows.Close()
    
    foreach ($foundfile in $listoffilesfound)
    {
        $escapedfile = $foundfile.Replace("'", "''")
        Invoke-sql "UPDATE stage_for_master.files SET file_lost = false, last_verified_full_path_present_on_ts_wth_tz = clock_timestamp() WHERE txt = '$escapedfile'"
        Write-Host -NoNewline '=' 
    }
    foreach ($missingfile in $listoffilesmissing)
    {
        $escapedfile = $missingfile.Replace("'", "''")
        Invoke-sql "UPDATE stage_for_master.files SET file_lost = true, file_loss_detected_on_ts_wth_tz = clock_timestamp() WHERE txt = '$escapedfile'"
        Write-Host -NoNewline '-'
    }
}


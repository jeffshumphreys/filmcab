<#

#>
. .\include_filmcab_header.ps1
#  They sit somewhere in the 50 requests per second range. This limit could change at any time so be respectful of the service we have built and respect the 429 if you receive one.
#     url = "https://api.themoviedb.org/3/movie/latest"  (extract json id)

$Error.Clear()

$source_set = "tmdb"
$sourceid = "$($source_set)_id"
$data_set = "movie"
$target_table_enhancing = "receiving_dock.$($source_set)_$($data_set)_csv_data_cleaner"
$datapoint = "release_date"

if ($dbconnopen) {
    $DBReader = $DBConn.CreateCommand()
    $sql = "SELECT $sourceid, record_added_on 
    FROM $target_table_enhancing f WHERE f.$datapoint IS NULL AND f.$sourceid NOT IN 
        (
            SELECT 
                x.source_row_id F
            FROM receiving_dock.pull_attr_frm_src_log x 
            WHERE x.target_table = '$target_table_enhancing' 
            AND x.target_column = '$datapoint' 
            AND x.source_datapoint = '$datapoint'
            AND (
                (x.applied IS False and (x.source_datapoint_val IS NULL OR x.source_datapoint_val = ''))
            OR 
                (x.applied IS True and x.source_datapoint_val IS NOT NULL AND x.source_datapoint_val <> '')
            ) /* includes cases where there was a lookup error (404) */
        )"
    $sql
    $DBReader.CommandText = $sql
    $rtnrows = $DBReader.ExecuteReader();
 <#
    TMDB API key 0fd2887f5745eadb12b3eac6337d6897
    TMDB API Read Access Token
    curl --request GET --url 'https://api.themoviedb.org/3/movie/11' --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIwZmQyODg3ZjU3NDVlYWRiMTJiM2VhYzYzMzdkNjg5NyIsInN1YiI6IjY1NmQzOGRkOGVlMGE5MDEzZDZiOTc0MyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.J_8lkZUjAdPW8FtMm_w51iwjRbym8AReuWUcNhU-dRY'

    https://api.themoviedb.org/3/movie/550?api_key=0fd2887f5745eadb12b3eac6337d6897
    #>
    $hit_api_count = 0
    $stopwatch =  [system.diagnostics.stopwatch]::StartNew()
    $ms = 0

    while ($rtnrows.Read()) {
        $sourcerefid = $rtnrows.GetValue(0)
        $prevms = $ms
        $ms = $stopwatch.ElapsedMilliseconds;
        $elapsed = $ms - $prevms
        "$sourcerefid, api hit count=$hit_api_count, elapsed (ms)=$elapsed"

        $target_row_capt_dt = $rtnrows.GetValue(1)
        $uri = "https://api.themoviedb.org/3/$data_set/$sourcerefid"
        $uri
        $headers = @{
            'Authorization' = 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIwZmQyODg3ZjU3NDVlYWRiMTJiM2VhYzYzMzdkNjg5NyIsInN1YiI6IjY1NmQzOGRkOGVlMGE5MDEzZDZiOTc0MyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.J_8lkZUjAdPW8FtMm_w51iwjRbym8AReuWUcNhU-dRY'
        }

        $datapoint_pulled_val = $null
        try {
            $datapoint_pulled_val = $null
            $moviejsonpacket = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers
            $hit_api_count++
            $datapoint_pulled_val = $moviejsonpacket.$datapoint
            
            # Found something!

            if ($null -ne $datapoint_pulled_val) {
                # Setting the release_date will block the recurrence of an identical fetch.
                Invoke-Sql "UPDATE $target_table_enhancing SET $datapoint = to_date('$datapoint_pulled_val', 'yyyy-mm-dd') WHERE $sourceid = $sourcerefid"

            } else {
                $sql = "INSERT INTO receiving_dock.pull_attr_frm_src_log
                (source_row_id, source_datapoint, source_datapoint_val, source_row_capt_dt, target_row_id, target_table, target_column, target_column_orig_val, target_row_dt, applied)
                VALUES($sourcerefid, '$datapoint', '$datapoint_pulled_val', clock_timestamp(), $sourcerefid, '$target_table_enhancing', '$datapoint', NULL, '$target_row_capt_dt', false);
                "
                Invoke-Sql $sql
            }
        } catch {
            # Unable to read data from the transport connection: An existing connection was forcibly closed by the remote host..
            # 504 Gateway Time-out  504 Gateway Time-out   
            $Error
            $PSItem
            Write-AllPlaces $_.ScriptStackTrace
            $status_code = $_.Exception.Response.StatusCode.value__ # Not the 32 you see in the error, hmmm. rather, 404
            $status_message = $_.Exception.Response.StatusDescription # Empty!
            $request_message = $_.Exception.Response.RequestMessage.RequestUri.OriginalString
            $sql = "INSERT INTO receiving_dock.pull_attr_frm_src_log
            (source_row_id, source_datapoint, source_datapoint_val, source_row_capt_dt, target_row_id, target_table, target_column, target_column_orig_val, target_row_dt, applied, source_query_err, request_message)
            VALUES($sourcerefid, '$datapoint', '$datapoint_pulled_val', clock_timestamp(), $sourcerefid, '$target_table_enhancing', '$datapoint', NULL, '$target_row_capt_dt', false, $status_code, '$request_message');
            "
            Invoke-Sql $sql
            if ($status_code -eq '') {
                $status_code = '<blank>'
                $_.Exception
                $_.Exception.Response
                exit
           } elseif ($status_code -eq '504') {
                Start-Sleep 30
           }
       }

        Start-Sleep -Seconds .25 #Unable to read data from the transport connection: An existing connection was forcibly closed by the remote host..
    }
    $rtnrows.Close()
   
}
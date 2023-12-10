<#

#>
Set-StrictMode -Version 2.0
. .\include_filmcab_header.ps1
#  They sit somewhere in the 50 requests per second range. This limit could change at any time so be respectful of the service we have built and respect the 429 if you receive one.
#     url = "https://api.themoviedb.org/3/movie/latest"  (extract json id)


$Error.Clear()

$source_set = "tmdb"
$sourceid = "$($source_set)_id"
$data_set = "movie"
$target_table_enhancing = "receiving_dock.$($data_set)_data" # tmdb_json_data_expanded

$num_columns_changed = 0
$num_columns_meaningful_value_diff = 0
$num_columns_match = 0
$num_columns_now_empty_in_src = 0
$num_columns_upcast = 0 # 0.6 to 0.611 popularity for example
$queryAPIResponseTime = 0
$moviejsonpacket = $null
function Update-ChangeStatus {
    param (
        [string]$TargetColumnName,
        [string]$SourceColumnCurrentValue,
        [string]$TargetColumnCurrentValue,
        [string]$sourceid,
        [string]$sourcerefid
    )
    $TargetColumnIsEmpty = $false; $SourceColumnIsEmpty = $false;

    $mehValues = @('', ' ', '0', '0.0', '0.000')

    $SourceColumnCurrentValue = $SourceColumnCurrentValue.replace("'", "''").Trim()
    $TargetColumnCurrentValue = $TargetColumnCurrentValue.Replace("'", "''").Trim()

    if ($null -eq $TargetColumnCurrentValue -or $TargetColumnCurrentValue -in $mehValues) {  $TargetColumnIsEmpty = $true; }
    if ($null -eq $SourceColumnCurrentValue -or $SourceColumnCurrentValue -in $mehValues) { $SourceColumnIsEmpty = $true; }

    if ($TargetColumnIsEmpty -and !$SourceColumnIsEmpty) {
        Invoke-Sql "UPDATE $target_table_enhancing SET $TargetColumnName = '$SourceColumnCurrentValue', popped_$TargetColumnName = clock_timestamp()
        , change_status_$TargetColumnName = array_unique(array_append(change_status_$TargetColumnName, 'filled empty')), date_change_status_$TargetColumnName = clock_timestamp()
        WHERE $sourceid = $sourcerefid::TEXT"
        $global:num_columns_changed++
    }
    elseif ($TargetColumnIsEmpty -and $SourceColumnIsEmpty) {
        Invoke-Sql "UPDATE $target_table_enhancing SET change_status_$TargetColumnName = array_unique(array_append(change_status_$TargetColumnName, 'source is empty too')), date_change_status_$TargetColumnName = clock_timestamp()
        WHERE $sourceid = $sourcerefid::TEXT"
        $global:num_columns_match++
    }
    elseif (!$TargetColumnIsEmpty -and $SourceColumnIsEmpty) {
        Invoke-Sql "UPDATE $target_table_enhancing SET change_status_$TargetColumnName = array_unique(array_append(change_status_$TargetColumnName, 'source is empty keeping target')), date_change_status_$TargetColumnName = clock_timestamp()
        WHERE $sourceid = $sourcerefid::TEXT"
        $global:num_columns_now_empty_in_src++
    }
    elseif ($TargetColumnCurrentValue -eq $SourceColumnCurrentValue) {
        Invoke-Sql "UPDATE $target_table_enhancing SET change_status_$TargetColumnName = array_unique(array_append(change_status_$TargetColumnName, 'source and target values identical')), date_change_status_$TargetColumnName = clock_timestamp()
        WHERE $sourceid = $sourcerefid::TEXT"
        $global:num_columns_match++
    }
    else {
        # Can we upcast Decimal(2,1) to 4,3? Otherwise this will continually show up as difference when it's just more accurate.

        if ($TargetColumnCurrentValue -notmatch '[^0-9\.]+$' -and $SourceColumnCurrentValue -notmatch '[^0-9\.]+$' -and
            $TargetColumnCurrentValue.Length -le $SourceColumnCurrentValue.Length) { # If target is longer than source, don't bother.
            $SourceSameLenAsTarget = $SourceColumnCurrentValue.Substring(0, $TargetColumnCurrentValue.Length)
            if ($SourceSameLenAsTarget -eq $TargetColumnCurrentValue)
            {
                Invoke-Sql "UPDATE $target_table_enhancing SET $TargetColumnName = '$SourceColumnCurrentValue', popped_$TargetColumnName = clock_timestamp()
                , change_status_$TargetColumnName = array_unique(array_append(change_status_$TargetColumnName, 'upcast value to source accuracy')), date_change_status_$TargetColumnName = clock_timestamp()
                , trg_prev_val_$TargetColumnName = '$TargetColumnCurrentValue'
                WHERE $sourceid = $sourcerefid::TEXT"
                $global:num_columns_upcast++
            }
        }
        else {
            Invoke-Sql "UPDATE $target_table_enhancing SET change_status_$TargetColumnName = array_unique(array_append(change_status_$TargetColumnName, 'source and target values differ')), date_change_status_$TargetColumnName = clock_timestamp()
            , src_diff_val_$TargetColumnName = '$SourceColumnCurrentValue'
            WHERE $sourceid = $sourcerefid::TEXT"
            $global:num_columns_meaningful_value_diff++
        }
    }
}
if ($dbconnopen) {
    $DBReader = $DBConn.CreateCommand()
    $sql = "SELECT tmdb_id, imdb_tt_id, title, original_title, vote_average, vote_count, popularity, status, release_date, budget, revenue, runtime, homepage, overview, tagline, backdrop_path, poster_path, genres, original_language, production_companies, production_countries, spoken_languages, adult
    FROM $target_table_enhancing f WHERE (
    ((TRIM(f.imdb_tt_id           )   IN('', ' ', '0', '0.0', '0.000') or f.imdb_tt_id is null) and f.popped_imdb_tt_id is null) or
    ((TRIM(f.title                )   IN('', ' ', '0', '0.0', '0.000') or f.title is null) and f.popped_title is null) or
    ((TRIM(f.original_title       )   IN('', ' ', '0', '0.0', '0.000') or f.original_title is null) and f.popped_original_title is null) or
    ((TRIM(f.vote_average         )   IN('', ' ', '0', '0.0', '0.000') or f.vote_average is null) and f.popped_vote_average is null) or
    ((TRIM(f.vote_count           )   IN('', ' ', '0', '0.0', '0.000') or f.vote_count is null) and f.popped_vote_count is null) or
    ((TRIM(f.popularity           )   IN('', ' ', '0', '0.0', '0.000') or f.popularity is null) and f.popped_popularity is null) or
    ((TRIM(f.status               )   IN('', ' ', '0', '0.0', '0.000') or f.status is null) and f.popped_status is null) or
    ((TRIM(f.release_date         )   IN('', ' ', '0', '0.0', '0.000') or f.release_date is null) and f.popped_release_date is null) or
    ((TRIM(f.budget               )   IN('', ' ', '0', '0.0', '0.000') or f.budget is null) and f.popped_budget is null) or
    ((TRIM(f.revenue              )   IN('', ' ', '0', '0.0', '0.000') or f.revenue is null) and f.popped_revenue is null) or
    ((TRIM(f.runtime              )   IN('', ' ', '0', '0.0', '0.000') or f.runtime is null) and f.popped_runtime is null) or
    ((TRIM(f.homepage             )   IN('', ' ', '0', '0.0', '0.000') or f.homepage is null) and f.popped_homepage is null) or
    ((TRIM(f.overview             )   IN('', ' ', '0', '0.0', '0.000') or f.overview is null) and f.popped_overview is null) or
    ((TRIM(f.tagline              )   IN('', ' ', '0', '0.0', '0.000') or f.tagline is null) and f.popped_tagline is null) or
    ((TRIM(f.backdrop_path        )   IN('', ' ', '0', '0.0', '0.000') or f.backdrop_path is null) and f.popped_backdrop_path is null) or
    ((TRIM(f.poster_path          )   IN('', ' ', '0', '0.0', '0.000') or f.poster_path is null) and f.popped_poster_path is null) or
    ((TRIM(f.genres               )   IN('', ' ', '0', '0.0', '0.000') or f.genres is null) and f.popped_genres is null) or
    ((TRIM(f.original_language    )   IN('', ' ', '0', '0.0', '0.000') or f.original_language is null) and f.popped_original_language is null) or
    ((TRIM(f.production_companies )   IN('', ' ', '0', '0.0', '0.000') or f.production_companies is null) and f.popped_production_companies is null) or
    ((TRIM(f.production_countries )   IN('', ' ', '0', '0.0', '0.000') or f.production_countries is null) and f.popped_production_countries is null) or
    ((TRIM(f.spoken_languages     )   IN('', ' ', '0', '0.0', '0.000') or f.spoken_languages is null) and f.popped_spoken_languages is null) or
    ((TRIM(f.adult                )   IN('', ' ', '0', '0.0', '0.000') or f.adult is null) and f.popped_adult is null)
    )
    and f.tmdb_id_not_found_in_api is null /* We tried a Rest pull previously and got 404 */
    and (f.updated_column_change_ct is null) /* or EXTRACT(DAY FROM clock_timestamp() - f.updated_column_change_ct) > 90)*/
    and (f.captured_json_on is null) /*or EXTRACT(DAY FROM clock_timestamp() - f.captured_json_on) > 90)*/
            "
    $sql
    $DBReader.CommandText = $sql
    $rtnrows = $DBReader.ExecuteReader();
 <#
    TMDB API key 0fd2887f5745eadb12b3eac6337d6897
    TMDB API Read Access Token
    curl --request GET --url 'https://api.themoviedb.org/3/movie/11' --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIwZmQyODg3ZjU3NDVlYWRiMTJiM2VhYzYzMzdkNjg5NyIsInN1YiI6IjY1NmQzOGRkOGVlMGE5MDEzZDZiOTc0MyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.J_8lkZUjAdPW8FtMm_w51iwjRbym8AReuWUcNhU-dRY'

    https://api.themoviedb.org/3/movie/550?api_key=0fd2887f5745eadb12b3eac6337d6897
    #>
    $hit_api_count    = 0
    $stopwatch        = [system.diagnostics.stopwatch]::StartNew()
    $ms               = 0

    while ($rtnrows.Read()) {
        $sourcerefid                    = $rtnrows.GetValue(0)
        $prevms                         = $ms
        $ms                             = $stopwatch.ElapsedMilliseconds;
        $elapsed                        = $ms - $prevms
        "api hit count = $hit_api_count, elapsed (ms)=$elapsed, responsetime=$queryAPIResponseTime`ms, $sourceid = $sourcerefid"

        
        $uri = "https://api.themoviedb.org/3/$data_set/$sourcerefid"
        $uri
        $headers = @{
            'Authorization' = 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIwZmQyODg3ZjU3NDVlYWRiMTJiM2VhYzYzMzdkNjg5NyIsInN1YiI6IjY1NmQzOGRkOGVlMGE5MDEzZDZiOTc0MyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.J_8lkZUjAdPW8FtMm_w51iwjRbym8AReuWUcNhU-dRY'
        }

        $original_imdb_tt_id              = $rtnrows.GetValue(1)
        $original_title                   = $rtnrows.GetValue(2)
        $original_original_title          = $rtnrows.GetValue(3)
        $original_vote_average            = $rtnrows.GetValue(4)
        $original_vote_count              = $rtnrows.GetValue(5)
        $original_popularity              = $rtnrows.GetValue(6)
        $original_status                  = $rtnrows.GetValue(7)
        $original_release_date            = $rtnrows.GetValue(8)
        $original_budget                  = $rtnrows.GetValue(9)
        $original_revenue                 = $rtnrows.GetValue(10)
        $original_runtime                 = $rtnrows.GetValue(11)
        $original_homepage                = $rtnrows.GetValue(12)
        $original_overview                = $rtnrows.GetValue(13)
        $original_tagline                 = $rtnrows.GetValue(14)
        $original_backdrop_path           = $rtnrows.GetValue(15)
        $original_poster_path             = $rtnrows.GetValue(16)
        $original_genres                  = $rtnrows.GetValue(17)
        $original_original_language       = $rtnrows.GetValue(18)
        $original_production_companies    = $rtnrows.GetValue(19)
        $original_production_countries    = $rtnrows.GetValue(20)
        $original_spoken_languages        = $rtnrows.GetValue(21)
        $original_adult                   = $rtnrows.GetValue(22)

        try {
            
            $t = Measure-Command {
                $global:moviejsonpacket = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers
            }

            $queryAPIResponseTime = $t.Milliseconds

            [string]$s = $global:moviejsonpacket
            $s = $s.Replace("'", "''")
            $hit_api_count++
            Invoke-Sql "UPDATE $target_table_enhancing SET captured_json = to_json('$s'::TEXT), captured_json_on = clock_timestamp() WHERE $sourceid = $sourcerefid::TEXT"
            
            $imdb_tt_id_pulled_val              = $global:moviejsonpacket.imdb_id
            $title_pulled_val                   = $global:moviejsonpacket.title
            $original_title_pulled_val          = $global:moviejsonpacket.original_title
            $vote_average_pulled_val            = $global:moviejsonpacket.vote_average
            $vote_count_pulled_val              = $global:moviejsonpacket.vote_count
            $popularity_pulled_val              = $global:moviejsonpacket.popularity
            $status_pulled_val                  = $global:moviejsonpacket.status
            $release_date_pulled_val            = $global:moviejsonpacket.release_date
            $budget_pulled_val                  = $global:moviejsonpacket.budget
            $revenue_pulled_val                 = $global:moviejsonpacket.revenue
            $runtime_pulled_val                 = $global:moviejsonpacket.runtime
            $homepage_pulled_val                = $global:moviejsonpacket.homepage
            $overview_pulled_val                = $global:moviejsonpacket.overview
            $tagline_pulled_val                 = $global:moviejsonpacket.tagline
            $backdrop_path_pulled_val           = $global:moviejsonpacket.backdrop_path
            $poster_path_pulled_val             = $global:moviejsonpacket.poster_path
            $genres_pulled_val                  = $global:moviejsonpacket.genres
            $original_language_pulled_val       = $global:moviejsonpacket.original_language
            $production_companies_pulled_val    = $global:moviejsonpacket.production_companies
            $production_countries_pulled_val    = $global:moviejsonpacket.production_countries
            $spoken_languages_pulled_val        = $global:moviejsonpacket.spoken_languages
            $adult_pulled_val                   = $global:moviejsonpacket.adult
            # video
            # belongs_to_collection

            # Prepare all column variations, so 22*4?
            # PREPARE fooplan (int, text, bool, numeric) AS INSERT INTO foo VALUES($1, $2, $3, $4);
            # EXECUTE fooplan(1, 'Hunter Valley', 't', 200.00); 
            # UPDATE $target_table_enhancing SET change_status_$TargetColumnName = array_unique(array_append(change_status_$TargetColumnName, '$1')), date_change_status_$TargetColumnName = clock_timestamp()
            # WHERE $sourceid::INTEGER = $2"

            # If target column is empty and source column is not, then apply it

            update-changestatus -TargetColumnName 'imdb_tt_id' -SourceColumnCurrentValue $imdb_tt_id_pulled_val -TargetColumnCurrentValue $original_imdb_tt_id -sourceid $sourceid -sourcerefid $sourcerefid
            update-changestatus -TargetColumnName 'title' -SourceColumnCurrentValue $title_pulled_val -TargetColumnCurrentValue $original_title -sourceid $sourceid -sourcerefid $sourcerefid
            update-changestatus -TargetColumnName 'original_title' -SourceColumnCurrentValue $original_title_pulled_val -TargetColumnCurrentValue $original_original_title -sourceid $sourceid -sourcerefid $sourcerefid
            update-changestatus -TargetColumnName 'vote_average' -SourceColumnCurrentValue $vote_average_pulled_val -TargetColumnCurrentValue $original_vote_average -sourceid $sourceid -sourcerefid $sourcerefid
            update-changestatus -TargetColumnName 'vote_count' -SourceColumnCurrentValue $vote_count_pulled_val -TargetColumnCurrentValue $original_vote_count -sourceid $sourceid -sourcerefid $sourcerefid
            update-changestatus -TargetColumnName 'popularity' -SourceColumnCurrentValue $popularity_pulled_val -TargetColumnCurrentValue $original_popularity -sourceid $sourceid -sourcerefid $sourcerefid
            update-changestatus -TargetColumnName 'status' -SourceColumnCurrentValue $status_pulled_val -TargetColumnCurrentValue $original_status -sourceid $sourceid -sourcerefid $sourcerefid
            update-changestatus -TargetColumnName 'release_date' -SourceColumnCurrentValue $release_date_pulled_val -TargetColumnCurrentValue $original_release_date -sourceid $sourceid -sourcerefid $sourcerefid
            update-changestatus -TargetColumnName 'budget' -SourceColumnCurrentValue $budget_pulled_val -TargetColumnCurrentValue $original_budget -sourceid $sourceid -sourcerefid $sourcerefid
            update-changestatus -TargetColumnName 'revenue' -SourceColumnCurrentValue $revenue_pulled_val -TargetColumnCurrentValue $original_revenue -sourceid $sourceid -sourcerefid $sourcerefid
            update-changestatus -TargetColumnName 'runtime' -SourceColumnCurrentValue $runtime_pulled_val -TargetColumnCurrentValue $original_runtime -sourceid $sourceid -sourcerefid $sourcerefid
            update-changestatus -TargetColumnName 'homepage' -SourceColumnCurrentValue $homepage_pulled_val -TargetColumnCurrentValue $original_homepage -sourceid $sourceid -sourcerefid $sourcerefid
            update-changestatus -TargetColumnName 'overview' -SourceColumnCurrentValue $overview_pulled_val -TargetColumnCurrentValue $original_overview -sourceid $sourceid -sourcerefid $sourcerefid
            update-changestatus -TargetColumnName 'tagline' -SourceColumnCurrentValue $tagline_pulled_val -TargetColumnCurrentValue $original_tagline -sourceid $sourceid -sourcerefid $sourcerefid
            update-changestatus -TargetColumnName 'backdrop_path' -SourceColumnCurrentValue $backdrop_path_pulled_val -TargetColumnCurrentValue $original_backdrop_path -sourceid $sourceid -sourcerefid $sourcerefid
            update-changestatus -TargetColumnName 'poster_path' -SourceColumnCurrentValue $poster_path_pulled_val -TargetColumnCurrentValue $original_poster_path -sourceid $sourceid -sourcerefid $sourcerefid
            update-changestatus -TargetColumnName 'genres' -SourceColumnCurrentValue $genres_pulled_val -TargetColumnCurrentValue $original_genres -sourceid $sourceid -sourcerefid $sourcerefid
            update-changestatus -TargetColumnName 'original_language' -SourceColumnCurrentValue $original_language_pulled_val -TargetColumnCurrentValue $original_original_language -sourceid $sourceid -sourcerefid $sourcerefid
            update-changestatus -TargetColumnName 'production_companies' -SourceColumnCurrentValue $production_companies_pulled_val -TargetColumnCurrentValue $original_production_companies -sourceid $sourceid -sourcerefid $sourcerefid
            update-changestatus -TargetColumnName 'production_countries' -SourceColumnCurrentValue $production_countries_pulled_val -TargetColumnCurrentValue $original_production_countries -sourceid $sourceid -sourcerefid $sourcerefid
            update-changestatus -TargetColumnName 'spoken_languages' -SourceColumnCurrentValue $spoken_languages_pulled_val -TargetColumnCurrentValue $original_spoken_languages -sourceid $sourceid -sourcerefid $sourcerefid
            update-changestatus -TargetColumnName 'adult' -SourceColumnCurrentValue $adult_pulled_val -TargetColumnCurrentValue $original_adult -sourceid $sourceid -sourcerefid $sourcerefid

            if ($num_columns_upcast -gt 0) { Write-Host "upcast values in $num_columns_upcast columns"}
            if ($num_columns_meaningful_value_diff -gt 0) { Write-Host "different values (but didn't do anything with) in $num_columns_meaningful_value_diff columns"}
            if ($num_columns_now_empty_in_src -gt 0) { Write-Host "source no longer has values for $num_columns_now_empty_in_src columns"}
            if ($num_columns_changed -gt 0) { Write-Host "target updated values in $num_columns_changed columns"}

            Invoke-Sql "UPDATE $target_table_enhancing SET num_columns_changed = $num_columns_changed, num_columns_match = $num_columns_match, num_columns_meaningful_value_diff = $num_columns_meaningful_value_diff
            , num_columns_now_empty_in_src = $num_columns_now_empty_in_src, num_columns_upcast = $num_columns_upcast
            , updated_column_change_ct = clock_timestamp() WHERE $sourceid = $sourcerefid::TEXT"
            
            $num_columns_changed = 0; $num_columns_match = 0; $num_columns_meaningful_value_diff = 0; $num_columns_now_empty_in_src = 0; $num_columns_upcast = 0

        } catch {
            # Unable to read data from the transport connection: An existing connection was forcibly closed by the remote host..
            # 504 Gateway Time-out  504 Gateway Time-out   
            $Error
            $PSItem
            Write-Host $_.ScriptStackTrace
            $status_code = "-1"
            if ( [bool]($_.Exception.PSobject.Properties.name -match "Response"))
            {
                $status_code     = $_.Exception.Response.StatusCode.value__ # Not the 32 you see in the error, hmmm. rather, 404
            }

            #$status_message  = $_.Exception.Response.StatusDescription # Empty!
            #$request_message = $_.Exception.Response.RequestMessage.RequestUri.OriginalString
            if ($status_code -eq '404') {
                $sql = "UPDATE $target_table_enhancing SET tmdb_id_not_found_in_api = clock_timestamp() WHERE $sourceid = $sourcerefid::TEXT"
                Invoke-Sql $sql
            }
            elseif ($status_code -eq '504') {
                Get-Date
                Start-Sleep 60
                #Start-Process -FilePath "powershell.exe" -ArgumentList '-NoExit', '-File', """D:\qt_projects\filmcab\fetch_tmdb_all_missing_datapoints_from_api.ps1"""
                . $PSCommandPath
                exit
            }
            else {
                Write-Error "Error not handled: $status_code"
            }
       }

        #Start-Sleep -Seconds .30 #LEARNT! "." values end up as zero!
        #Start-Sleep -Milliseconds 250 Just read: The limit is 50/sec, so no reason to sleep, Also can run several, like 20 threads per IP.
        # Note: Regular vacuum fulls more than double speed. 10.99 days at 1 per second, so 5 days at 1/2 second.  
    }
    $rtnrows.Close()
   
}
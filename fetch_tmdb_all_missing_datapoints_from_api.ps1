<#

#>
. .\include_filmcab_header.ps1
#  They sit somewhere in the 50 requests per second range. This limit could change at any time so be respectful of the service we have built and respect the 429 if you receive one.
#     url = "https://api.themoviedb.org/3/movie/latest"  (extract json id)


$Error.Clear()

$source_set = "tmdb"
$sourceid = "$($source_set)_id"
$data_set = "movie"
$target_table_enhancing = "receiving_dock.$($source_set)_$($data_set)_csv_data"

function update-changestatus ($attribute) {
    if ($null -ne $imdb_tt_id_pulled_val -and $imdb_tt_id_pulled_val -notin @('', '0', '0.000') -and ($original_imdb_tt_id -eq '' -or $null -eq $original_imdb_tt_id)) {
        Invoke-Sql "UPDATE $target_table_enhancing SET imdb_tt_id = '$imdb_tt_id_pulled_val', popped_imdb_tt_id = clock_timestamp() WHERE $sourceid = $sourcerefid"
        }
}
if ($dbconnopen) {
    $DBReader = $DBConn.CreateCommand()
    $sql = "SELECT tmdb_id, imdb_tt_id, title, original_title, vote_average, vote_count, popularity, status, release_date, budget, revenue, runtime, homepage, overview, tagline, backdrop_path, poster_path, genres, original_language, production_companies, production_countries, spoken_languages, adult
    FROM $target_table_enhancing f WHERE 
        ((f.imdb_tt_id = '' or f.imdb_tt_id is null) and f.popped_imdb_tt_id is null) or
        ((f.title = '' or f.title is null) and f.popped_title is null) or
        ((f.original_title = '' or f.original_title is null) and f.popped_original_title is null) or
        ((f.vote_average = '' or f.vote_average is null) and f.popped_vote_average is null) or
        ((f.vote_count = '' or f.vote_count is null) and f.popped_vote_count is null) or
        ((f.popularity = '' or f.popularity is null) and f.popped_popularity is null) or
        ((f.status = '' or f.status is null) and f.popped_status is null) or
        ((f.release_date = '' or f.release_date is null) and f.popped_release_date is null) or
        ((f.budget = '' or f.budget is null) and f.popped_budget is null) or
        ((f.revenue = '' or f.revenue is null) and f.popped_revenue is null) or
        ((f.runtime = '' or f.runtime is null) and f.popped_runtime is null) or
        ((f.homepage = '' or f.homepage is null) and f.popped_homepage is null) or
        ((f.overview = '' or f.overview is null) and f.popped_overview is null) or
        ((f.tagline = '' or f.tagline is null) and f.popped_tagline is null) or
        ((f.backdrop_path = '' or f.backdrop_path is null) and f.popped_backdrop_path is null) or
        ((f.poster_path = '' or f.poster_path is null) and f.popped_poster_path is null) or
        ((f.genres = '' or f.genres is null) and f.popped_genres is null) or
        ((f.original_language = '' or f.original_language is null) and f.popped_original_language is null) or
        ((f.production_companies = '' or f.production_companies is null) and f.popped_production_companies is null) or
        ((f.production_countries = '' or f.production_countries is null) and f.popped_production_countries is null) or
        ((f.spoken_languages = '' or f.spoken_languages is null) and f.popped_spoken_languages is null) or
        ((f.adult = '' or f.adult is null) and f.popped_adult is null) 
        and f.tmdb_id_not_found_in_api is null /* Did we try a Rest pull previously and got 404 */
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
    $hit_api_count = 0
    $stopwatch =  [system.diagnostics.stopwatch]::StartNew()
    $ms = 0

    while ($rtnrows.Read()) {
        $sourcerefid = $rtnrows.GetValue(0)
        $prevms = $ms
        $ms = $stopwatch.ElapsedMilliseconds;
        $elapsed = $ms - $prevms
        "$sourcerefid, api hit count=$hit_api_count, elapsed (ms)=$elapsed"

        
        $uri = "https://api.themoviedb.org/3/$data_set/$sourcerefid"
        $uri
        $headers = @{
            'Authorization' = 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIwZmQyODg3ZjU3NDVlYWRiMTJiM2VhYzYzMzdkNjg5NyIsInN1YiI6IjY1NmQzOGRkOGVlMGE5MDEzZDZiOTc0MyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.J_8lkZUjAdPW8FtMm_w51iwjRbym8AReuWUcNhU-dRY'
        }

        $original_imdb_tt_id = $rtnrows.GetValue(1)
        $original_title = $rtnrows.GetValue(2)
        $original_original_title = $rtnrows.GetValue(3)
        $original_vote_average = $rtnrows.GetValue(4)
        $original_vote_count = $rtnrows.GetValue(5)
        $original_popularity = $rtnrows.GetValue(6)
        $original_status = $rtnrows.GetValue(7)
        $original_release_date = $rtnrows.GetValue(8)
        $original_budget = $rtnrows.GetValue(9)
        $original_revenue = $rtnrows.GetValue(10)
        $original_runtime = $rtnrows.GetValue(11)
        $original_homepage = $rtnrows.GetValue(12)
        $original_overview = $rtnrows.GetValue(13)
        $original_tagline = $rtnrows.GetValue(14)
        $original_backdrop_path = $rtnrows.GetValue(15)
        $original_poster_path = $rtnrows.GetValue(16)
        $original_genres = $rtnrows.GetValue(17)
        $original_original_language = $rtnrows.GetValue(18)
        $original_production_companies = $rtnrows.GetValue(19)
        $original_production_countries = $rtnrows.GetValue(20)
        $original_spoken_languages = $rtnrows.GetValue(21)
        $original_adult = $rtnrows.GetValue(22)

        try {
            $moviejsonpacket = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers
            [string]$s = $moviejsonpacket
            $s = $s.Replace("'", "''")
            $hit_api_count++
            Invoke-Sql "UPDATE $target_table_enhancing SET captured_json = to_json('$s'::TEXT), captured_json_on = clock_timestamp() WHERE $sourceid::INTEGER = $sourcerefid"

            $imdb_tt_id_pulled_val = $moviejsonpacket.imdb_tt_id
            $title_pulled_val = $moviejsonpacket.title
            $original_title_pulled_val = $moviejsonpacket.original_title
            $vote_average_pulled_val = $moviejsonpacket.vote_average
            $vote_count_pulled_val = $moviejsonpacket.vote_count
            $popularity_pulled_val = $moviejsonpacket.popularity
            $status_pulled_val = $moviejsonpacket.status
            $release_date_pulled_val = $moviejsonpacket.release_date
            $budget_pulled_val = $moviejsonpacket.budget
            $revenue_pulled_val = $moviejsonpacket.revenue
            $runtime_pulled_val = $moviejsonpacket.runtime
            $homepage_pulled_val = $moviejsonpacket.homepage
            $overview_pulled_val = $moviejsonpacket.overview
            $tagline_pulled_val = $moviejsonpacket.tagline
            $backdrop_path_pulled_val = $moviejsonpacket.backdrop_path
            $poster_path_pulled_val = $moviejsonpacket.poster_path
            $genres_pulled_val = $moviejsonpacket.genres
            $original_language_pulled_val = $moviejsonpacket.original_language
            $production_companies_pulled_val = $moviejsonpacket.production_companies
            $production_countries_pulled_val = $moviejsonpacket.production_countries
            $spoken_languages_pulled_val = $moviejsonpacket.spoken_languages
            $adult_pulled_val = $moviejsonpacket.adult

            # If target column is empty and source column is not, then apply it

            update-changestatus $imdb_tt_id_pulled_val $original_imdb_tt_id -columnname 'imdb_tt_id'
            if ($null -ne $title_pulled_val -and $title_pulled_val -notin @('', '0', '0.000') -and ($original_title -eq '' -or $null -eq $original_title)) {
            Invoke-Sql "UPDATE $target_table_enhancing SET title = '$title_pulled_val', popped_title = clock_timestamp() WHERE $sourceid = $sourcerefid"
            }
            if ($null -ne $original_title_pulled_val -and $original_title_pulled_val -notin @('', '0', '0.000') -and ($original_original_title -eq '' -or $null -eq $original_original_title)) {
            Invoke-Sql "UPDATE $target_table_enhancing SET original_title = '$original_title_pulled_val', popped_original_title = clock_timestamp() WHERE $sourceid = $sourcerefid"
            }
            if ($null -ne $vote_average_pulled_val -and $vote_average_pulled_val -notin @('', '0', '0.000') -and ($original_vote_average -eq '' -or $null -eq $original_vote_average)) {
            Invoke-Sql "UPDATE $target_table_enhancing SET vote_average = '$vote_average_pulled_val', popped_vote_average = clock_timestamp() WHERE $sourceid = $sourcerefid"
            }
            if ($null -ne $vote_count_pulled_val -and $vote_count_pulled_val -notin @('', '0', '0.000') -and ($original_vote_count -eq '' -or $null -eq $original_vote_count)) {
            Invoke-Sql "UPDATE $target_table_enhancing SET vote_count = '$vote_count_pulled_val', popped_vote_count = clock_timestamp() WHERE $sourceid = $sourcerefid"
            }
            if ($null -ne $popularity_pulled_val -and $popularity_pulled_val -notin @('', '0', '0.000') -and ($original_popularity -eq '' -or $null -eq $original_popularity)) {
            Invoke-Sql "UPDATE $target_table_enhancing SET popularity = '$popularity_pulled_val', popped_popularity = clock_timestamp() WHERE $sourceid = $sourcerefid"
            }
            if ($null -ne $status_pulled_val -and $status_pulled_val -notin @('', '0', '0.000') -and ($original_status -eq '' -or $null -eq $original_status)) {
            Invoke-Sql "UPDATE $target_table_enhancing SET status = '$status_pulled_val', popped_status = clock_timestamp() WHERE $sourceid = $sourcerefid"
            }
            if ($null -ne $release_date_pulled_val -and $release_date_pulled_val -notin @('', '0', '0.000') -and ($original_release_date -eq '' -or $null -eq $original_release_date)) {
            Invoke-Sql "UPDATE $target_table_enhancing SET release_date = '$release_date_pulled_val', popped_release_date = clock_timestamp() WHERE $sourceid = $sourcerefid"
            }
            if ($null -ne $budget_pulled_val -and $budget_pulled_val -notin @('', '0', '0.000') -and ($original_budget -eq '' -or $null -eq $original_budget)) {
            Invoke-Sql "UPDATE $target_table_enhancing SET budget = '$budget_pulled_val', popped_budget = clock_timestamp() WHERE $sourceid = $sourcerefid"
            }
            if ($null -ne $revenue_pulled_val -and $revenue_pulled_val -notin @('', '0', '0.000') -and ($original_revenue -eq '' -or $null -eq $original_revenue)) {
            Invoke-Sql "UPDATE $target_table_enhancing SET revenue = '$revenue_pulled_val', popped_revenue = clock_timestamp() WHERE $sourceid = $sourcerefid"
            }
            if ($null -ne $runtime_pulled_val -and $runtime_pulled_val -notin @('', '0', '0.000') -and ($original_runtime -eq '' -or $null -eq $original_runtime)) {
            Invoke-Sql "UPDATE $target_table_enhancing SET runtime = '$runtime_pulled_val', popped_runtime = clock_timestamp() WHERE $sourceid = $sourcerefid"
            }
            if ($null -ne $homepage_pulled_val -and $homepage_pulled_val -notin @('', '0', '0.000') -and ($original_homepage -eq '' -or $null -eq $original_homepage)) {
            Invoke-Sql "UPDATE $target_table_enhancing SET homepage = '$homepage_pulled_val', popped_homepage = clock_timestamp() WHERE $sourceid = $sourcerefid"
            }
            if ($null -ne $overview_pulled_val -and $overview_pulled_val -notin @('', '0', '0.000') -and ($original_overview -eq '' -or $null -eq $original_overview)) {
            Invoke-Sql "UPDATE $target_table_enhancing SET overview = '$overview_pulled_val', popped_overview = clock_timestamp() WHERE $sourceid = $sourcerefid"
            }
            if ($null -ne $tagline_pulled_val -and $tagline_pulled_val -notin @('', '0', '0.000') -and ($original_tagline -eq '' -or $null -eq $original_tagline)) {
            Invoke-Sql "UPDATE $target_table_enhancing SET tagline = '$tagline_pulled_val', popped_tagline = clock_timestamp() WHERE $sourceid = $sourcerefid"
            }
            if ($null -ne $backdrop_path_pulled_val -and $backdrop_path_pulled_val -notin @('', '0', '0.000') -and ($original_backdrop_path -eq '' -or $null -eq $original_backdrop_path)) {
            Invoke-Sql "UPDATE $target_table_enhancing SET backdrop_path = '$backdrop_path_pulled_val', popped_backdrop_path = clock_timestamp() WHERE $sourceid = $sourcerefid"
            }
            if ($null -ne $poster_path_pulled_val -and $poster_path_pulled_val -notin @('', '0', '0.000') -and ($original_poster_path -eq '' -or $null -eq $original_poster_path)) {
            Invoke-Sql "UPDATE $target_table_enhancing SET poster_path = '$poster_path_pulled_val', popped_poster_path = clock_timestamp() WHERE $sourceid = $sourcerefid"
            }
            if ($null -ne $genres_pulled_val -and $genres_pulled_val -notin @('', '0', '0.000') -and ($original_genres -eq '' -or $null -eq $original_genres)) {
            Invoke-Sql "UPDATE $target_table_enhancing SET genres = '$genres_pulled_val', popped_genres = clock_timestamp() WHERE $sourceid = $sourcerefid"
            }
            if ($null -ne $original_language_pulled_val -and $original_language_pulled_val -notin @('', '0', '0.000') -and ($original_original_language -eq '' -or $null -eq $original_original_language)) {
            Invoke-Sql "UPDATE $target_table_enhancing SET original_language = '$original_language_pulled_val', popped_original_language = clock_timestamp() WHERE $sourceid = $sourcerefid"
            }
            if ($null -ne $production_companies_pulled_val -and $production_companies_pulled_val -notin @('', '0', '0.000') -and ($original_production_companies -eq '' -or $null -eq $original_production_companies)) {
            Invoke-Sql "UPDATE $target_table_enhancing SET production_companies = '$production_companies_pulled_val', popped_production_companies = clock_timestamp() WHERE $sourceid = $sourcerefid"
            }
            if ($null -ne $production_countries_pulled_val -and $production_countries_pulled_val -notin @('', '0', '0.000') -and ($original_production_countries -eq '' -or $null -eq $original_production_countries)) {
            Invoke-Sql "UPDATE $target_table_enhancing SET production_countries = '$production_countries_pulled_val', popped_production_countries = clock_timestamp() WHERE $sourceid = $sourcerefid"
            }
            if ($null -ne $spoken_languages_pulled_val -and $spoken_languages_pulled_val -notin @('', '0', '0.000') -and ($original_spoken_languages -eq '' -or $null -eq $original_spoken_languages)) {
            Invoke-Sql "UPDATE $target_table_enhancing SET spoken_languages = '$spoken_languages_pulled_val', popped_spoken_languages = clock_timestamp() WHERE $sourceid = $sourcerefid"
            }
            if ($null -ne $adult_pulled_val -and $adult_pulled_val -notin @('', '0', '0.000') -and ($original_adult -eq '' -or $null -eq $original_adult)) {
            Invoke-Sql "UPDATE $target_table_enhancing SET adult = '$adult_pulled_val', popped_adult = clock_timestamp() WHERE $sourceid = $sourcerefid"
            }
        } catch {
            # Unable to read data from the transport connection: An existing connection was forcibly closed by the remote host..
            # 504 Gateway Time-out  504 Gateway Time-out   
            $Error
            $PSItem
            Write-Host $_.ScriptStackTrace
            $status_code = $_.Exception.Response.StatusCode.value__ # Not the 32 you see in the error, hmmm. rather, 404
            $status_message = $_.Exception.Response.StatusDescription # Empty!
            $request_message = $_.Exception.Response.RequestMessage.RequestUri.OriginalString
            if ($status_code -eq '404') {
                $sql = "UPDATE $target_table_enhancing SET tmdb_id_not_found_in_api = clock_timestamp() WHERE $sourceid = $sourcerefid"
                Invoke-Sql $sql
            }

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
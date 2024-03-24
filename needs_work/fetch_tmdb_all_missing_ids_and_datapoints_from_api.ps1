<#

#>
Set-StrictMode -Version 2.0
. .\include_filmcab_header.ps1
#  They sit somewhere in the 50 requests per second range. This limit could change at any time so be respectful of the service we have built and respect the 429 if you receive one.
#     url = "https://api.themoviedb.org/3/movie/latest"  (extract json id)


$Error.Clear()

$source_set             = "tmdb"
$sourceid               = "$($source_set)_id"
$data_set               = "video"
$api_endpoint           = "movie"
$target_table_enhancing = "receiving_dock.$($data_set)_data" # tmdb_json_data_expanded
$global:num_columns_changed               = 0
$global:num_columns_meaningful_value_diff = 0
$global:num_columns_match                 = 0
$global:num_columns_now_empty_in_src      = 0
$global:num_columns_upcast                = 0 # 0.6 to 0.611 popularity for example
$queryAPIResponseTime              = 0
$moviejsonpacket                   = $null

if ($dbconnopen) {
    $DBReader = $DBConn.CreateCommand()
    $sql = "SELECT x.new_tmdb_id FROM receiving_dock.new_tmdb_ids x left join receiving_dock.video_data y
    on x.new_tmdb_id = y.tmdb_id_as_integer
    where y.id is null
    "
    $sql
    $DBReader.CommandText = $sql
    $rtnrows = $DBReader.ExecuteReader();
    $hit_api_count    = 0
    $stopwatch        = [system.diagnostics.stopwatch]::StartNew()
    $ms               = 0

    while ($rtnrows.Read()) {
        $sourcerefid                    = $rtnrows.GetValue(0)
        $prevms                         = $ms
        $ms                             = $stopwatch.ElapsedMilliseconds;
        $elapsed                        = $ms - $prevms
        "api hit count = $hit_api_count, elapsed (ms)=$elapsed, responsetime=$queryAPIResponseTime`ms, $sourceid = $sourcerefid"

        $uri = "https://api.themoviedb.org/3/$api_endpoint/$sourcerefid"
        $uri
        $headers = @{
            'Authorization' = 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIwZmQyODg3ZjU3NDVlYWRiMTJiM2VhYzYzMzdkNjg5NyIsInN1YiI6IjY1NmQzOGRkOGVlMGE5MDEzZDZiOTc0MyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.J_8lkZUjAdPW8FtMm_w51iwjRbym8AReuWUcNhU-dRY'
        }

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

            if ($null -ne $imdb_tt_id_pulled_val -and $imdb_tt_id_pulled_val.GetType().Name -eq 'String') { $imdb_tt_id_pulled_val = $imdb_tt_id_pulled_val.Replace("'", "''")}
            if ($null -ne $title_pulled_val -and $title_pulled_val.GetType().Name -eq 'String') { $title_pulled_val = $title_pulled_val.Replace("'", "''")}
            if ($null -ne $original_title_pulled_val -and $original_title_pulled_val.GetType().Name -eq 'String') { $original_title_pulled_val = $original_title_pulled_val.Replace("'", "''")}
            if ($null -ne $vote_average_pulled_val -and $vote_average_pulled_val.GetType().Name -eq 'String') { $vote_average_pulled_val = $vote_average_pulled_val.Replace("'", "''")}
            if ($null -ne $vote_count_pulled_val -and $vote_count_pulled_val.GetType().Name -eq 'String') { $vote_count_pulled_val = $vote_count_pulled_val.Replace("'", "''")}
            if ($null -ne $popularity_pulled_val -and $popularity_pulled_val.GetType().Name -eq 'String') { $popularity_pulled_val = $popularity_pulled_val.Replace("'", "''")}
            if ($null -ne $status_pulled_val -and $status_pulled_val.GetType().Name -eq 'String') { $status_pulled_val = $status_pulled_val.Replace("'", "''")}
            if ($null -ne $release_date_pulled_val -and $release_date_pulled_val.GetType().Name -eq 'String') { $release_date_pulled_val = $release_date_pulled_val.Replace("'", "''")}
            if ($null -ne $budget_pulled_val -and $budget_pulled_val.GetType().Name -eq 'String') { $budget_pulled_val = $budget_pulled_val.Replace("'", "''")}
            if ($null -ne $revenue_pulled_val -and $revenue_pulled_val.GetType().Name -eq 'String') { $revenue_pulled_val = $revenue_pulled_val.Replace("'", "''")}
            if ($null -ne $runtime_pulled_val -and $runtime_pulled_val.GetType().Name -eq 'String') { $runtime_pulled_val = $runtime_pulled_val.Replace("'", "''")}
            if ($null -ne $homepage_pulled_val -and $homepage_pulled_val.GetType().Name -eq 'String') { $homepage_pulled_val = $homepage_pulled_val.Replace("'", "''")}
            if ($null -ne $overview_pulled_val -and $overview_pulled_val.GetType().Name -eq 'String') { $overview_pulled_val = $overview_pulled_val.Replace("'", "''")}
            if ($null -ne $tagline_pulled_val -and $tagline_pulled_val.GetType().Name -eq 'String') { $tagline_pulled_val = $tagline_pulled_val.Replace("'", "''")}
            if ($null -ne $backdrop_path_pulled_val -and $backdrop_path_pulled_val.GetType().Name -eq 'String') { $backdrop_path_pulled_val = $backdrop_path_pulled_val.Replace("'", "''")}
            if ($null -ne $poster_path_pulled_val -and $poster_path_pulled_val.GetType().Name -eq 'String') { $poster_path_pulled_val = $poster_path_pulled_val.Replace("'", "''")}
            if ($null -ne $genres_pulled_val -and $genres_pulled_val.GetType().Name -eq 'String') { $genres_pulled_val = $genres_pulled_val.Replace("'", "''")}
            if ($null -ne $original_language_pulled_val -and $original_language_pulled_val.GetType().Name -eq 'String') { $original_language_pulled_val = $original_language_pulled_val.Replace("'", "''")}
            if ($null -ne $production_companies_pulled_val -and $production_companies_pulled_val.GetType().Name -eq 'String') { $production_companies_pulled_val = $production_companies_pulled_val.Replace("'", "''")}
            if ($null -ne $production_countries_pulled_val -and $production_countries_pulled_val.GetType().Name -eq 'String') { $production_countries_pulled_val = $production_countries_pulled_val.Replace("'", "''")}
            if ($null -ne $spoken_languages_pulled_val -and $spoken_languages_pulled_val.GetType().Name -eq 'String') { $spoken_languages_pulled_val = $spoken_languages_pulled_val.Replace("'", "''")}
            if ($null -ne $adult_pulled_val -and $adult_pulled_val.GetType().Name -eq 'String') { $adult_pulled_val = $adult_pulled_val.Replace("'", "''")}
            
            # If target column is empty and source column is not, then apply it

            Invoke-Sql "INSERT INTO $target_table_enhancing(
                tmdb_id,
                tmdb_id_as_integer,
                imdb_tt_id,
                title,
                original_title,
                vote_average,
                vote_count,
                popularity,
                status,
                release_date,
                budget,
                revenue,
                runtime,
                homepage,
                overview,
                tagline,
                backdrop_path,
                poster_path,
                genres,
                original_language,
                production_companies,
                production_countries,
                spoken_languages,
                adult,
                captured_json,
                captured_json_on
            )
            VALUES(
                '$sourcerefid',
                $sourcerefid,
                '$imdb_tt_id_pulled_val',          
                '$title_pulled_val',               
                '$original_title_pulled_val',      
                '$vote_average_pulled_val',        
                '$vote_count_pulled_val',          
                '$popularity_pulled_val',          
                '$status_pulled_val',              
                '$release_date_pulled_val',        
                '$budget_pulled_val',              
                '$revenue_pulled_val',             
                '$runtime_pulled_val',             
                '$homepage_pulled_val',            
                '$overview_pulled_val',            
                '$tagline_pulled_val',             
                '$backdrop_path_pulled_val',       
                '$poster_path_pulled_val',         
                '$genres_pulled_val',              
                '$original_language_pulled_val',   
                '$production_companies_pulled_val',
                '$production_countries_pulled_val',
                '$spoken_languages_pulled_val',    
                '$adult_pulled_val',
                to_json('$s'::TEXT), 
                clock_timestamp()
            )
            "
        } catch {
            # Unable to read data from the transport connection: An existing connection was forcibly closed by the remote host..
            # 504 Gateway Time-out  504 Gateway Time-out   
            $Error
            $status_code = "-1"
            if ( [bool]($_.Exception.PSobject.Properties.name -match "Response"))
            {
                $status_code     = $_.Exception.Response.StatusCode.value__ # Not the 32 you see in the error, hmmm. rather, 404
            }
            # TODO: Insert a stub! reseource not found
            #$status_message  = $_.Exception.Response.StatusDescription # Empty!
            #$request_message = $_.Exception.Response.RequestMessage.RequestUri.OriginalString
            if ($status_code -eq '404') {
                Write-Output "Updating that id not found"
                Invoke-Sql "UPDATE $target_table_enhancing SET tmdb_id_not_found_in_api = clock_timestamp() WHERE $sourceid = $sourcerefid::TEXT"
                # Add a pause because it's so fast, I'll get 50 in a second if 50 don't come back found, which is the per second limit.
                Start-Sleep -Milliseconds 250
            }
            # 429: "too many requests" is known to happen for some users.
            elseif ($status_code -eq '504') {
                Get-Date
                Start-Sleep 60
                #Start-Process -FilePath "powershell.exe" -ArgumentList '-NoExit', '-File', """D:\qt_projects\filmcab\fetch_tmdb_all_missing_datapoints_from_api.ps1"""
                . $PSCommandPath
                exit
            }
            else {
                Write-Error "Error not handled: $status_code"
                Start-Sleep -Milliseconds 250
            }
       }

        #Start-Sleep -Seconds .30 #LEARNT! "." values end up as zero!
        #Start-Sleep -Milliseconds 250 Just read: The limit is 50/sec, so no reason to sleep, Also can run several, like 20 threads per IP.
        # Note: Regular vacuum fulls more than double speed. 10.99 days at 1 per second, so 5 days at 1/2 second.  
    }
    $rtnrows.Close()
   
}

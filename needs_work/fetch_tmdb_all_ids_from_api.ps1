<#
    https://developer.themoviedb.org/docs/daily-id-exports
    http://files.tmdb.org/p/exports/movie_ids_MM_DD_YYYY.json.gz
    tv_series_ids_MM_DD_YYYY.json.gz
    person_ids_MM_DD_YYYY.json.gz
    collection_ids_MM_DD_YYYY.json.gz
    tv_network_ids_MM_DD_YYYY.json.gz
    keyword_ids_MM_DD_YYYY.json.gz
    production_company_ids_MM_DD_YYYY.json.gz
    https://api.themoviedb.org/3/keyword/30 => name: individual: The movie is about an individual
    https://api.themoviedb.org/3/keyword/233 => name: japan
        'https://api.themoviedb.org/3/keyword/30/movies?include_adult=false&language=en-US&page=1'
        https://api.themoviedb.org/3/discover/movie
            with_watch_monetization_types possible values are: [flatrate, free, ads, rent, buy]
            with_watch_providers
            without_keywords
            year
            with_release_type 1,2,3,4,5,6
            with_keywords
    https://api.themoviedb.org/3/account/{account_id}/lists
        'https://api.themoviedb.org/3/account/20784959/lists?page=1' (I have no lists yet)
    https://api.themoviedb.org/3/certification/movie/list
        E, G, PG, M, MA 15+, R 18+, X 18+, RC, D, X, B, C, A... per country. Pull into table.
    https://developer.themoviedb.org/reference/configuration-details
          "change_keys": [
    "adult",
    "air_date",
    "also_known_as",
    "alternative_titles",
    "biography",
    "birthday",
    "budget",
    "cast",
    "certifications",
    "character_names",
    "created_by",
    "crew",
    "deathday",
    "episode",
    "episode_number",
    "episode_run_time",
    "freebase_id",
    "freebase_mid",
    "general",
    "genres",
    "guest_stars",
    "homepage",
    "images",
    "imdb_id",
    "languages",
    "name",
    "network",
    "origin_country",
    "original_name",
    "original_title",
    "overview",
    "parts",
    "place_of_birth",
    "plot_keywords",
    "production_code",
    "production_companies",
    "production_countries",
    "releases",
    "revenue",
    "runtime",
    "season",
    "season_number",
    "season_regular",
    "spoken_languages",
    "status",
    "tagline",
    "title",
    "translations",
    "tvdb_id",
    "tvrage_id",
    "type",
    "video",
    "videos"

    https://api.themoviedb.org/3/configuration/jobs
        by department
    https://api.themoviedb.org/3/configuration/countries
        iso_3166_1 codes (2-character)
    https://api.themoviedb.org/3/find/{external_id}
        IMDB, Facebook, Instagram, TheTVDB, TickTok, Twitter, Wikidata, Youtube
    https://developer.themoviedb.org/reference/watch-providers-movie-list
        Fimtaskic Amazon Channel
        VUDU Free
        FlixFlink
        My5
        ...
#>
Set-StrictMode -Version 2.0
. .\include_filmcab_header.ps1

$Error.Clear()

$source_set             = "tmdb"
$data_set               = "movie" # movie, tv_series, person, collection, tv_network, keyword, production_company
$data_set               = "tv_series"
$data_set               = "person" 
$data_set               = "collection"
#XXXX$data_set               = "tv_network" # Does not exist anymore
$data_set               = "keyword"
$data_set               = "production_company"
#$data_set               = "network" # <Code>AccessDenied</Code>   <Message>Access Denied</Message>

$sourceid               = "$($source_set)_$($data_set)_id"

$target_table_enhancing = "receiving_dock.$($source_set)_$($data_set)_data" # tmdb_json_data_expanded

$Error.Clear()
$date = Get-Date
$datestring = $date.ToShortDateString().Replace('/', '_')
$target_path = "N:\Video AllInOne Metadata\$source_set"
$json_file_path = "$target_path\$data_set`_ids_$datestring.json"
$download_path = "http://files.tmdb.org/p/exports/$data_set`_ids_$datestring.json.gz"
$json_zipped_file_path = "$target_path\$data_set`_ids.json.gz"
# if file same date exists, skip
Invoke-WebRequest $download_path -OutFile $json_zipped_file_path
Remove-Item $json_file_path -Force
& "C:\Program Files\7-Zip\7z.exe" e "$json_zipped_file_path" -o"$target_path" -y

if (Test-Path "$json_file_path") {
    # if object populated, skip
    $ids_json = (Get-Content "$json_file_path" | ConvertFrom-Json)
    # {"adult":false,"id":3924,"original_title":"Blondie","popularity":6.006,"video":false}
    $DBReader = $DBConn.CreateCommand()
    $sql = "SELECT count(*) matchcount FROM $target_table_enhancing f WHERE f.$sourceid = ?"
    $DBReader.CommandText = $sql
    $DBReader.Prepare()
    $DBParam = New-Object System.Data.Odbc.OdbcParameter
    $DBParam.DbType = 'Int32'
    $DBParam.ParameterName = "@ID"
    $DBParam.Direction = 'Input'
    $DBParam.Value = $id
    $DBReader.Parameters.Add($DBParam)

    foreach($id in $ids_json.id)
    {
        #$id
        #if ($id -lt 366119) {
        #    continue
        #}

        Write-AllPlaces -NoNewline "."
        $DBReader.Parameters[0].Value = $id
        $rtnct = $DBReader.ExecuteScalar()
        
        if ($rtnct -eq 0) {
            Write-Output "$sourceid #$id is in the $source_set cloud but not in our database"
            # Insert into receiving_dock.new_tmdb_ids($id)
            Invoke-Sql "INSERT INTO receiving_dock.new_tmdb_$data_set`_ids(new_$sourceid) VALUES($id) ON CONFLICT DO NOTHING"
        }  
        $rtnrows.Close();
    }
    # 6,681 found, so another update into video_data
    # But not update, insert. So no test for empty.

}

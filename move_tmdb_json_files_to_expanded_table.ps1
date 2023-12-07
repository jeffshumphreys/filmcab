    # https://developer.imdb.com/non-commercial-datasets/
    # https://datasets.imdbws.com/
    # https://datasets.imdbws.com/name.basics.tsv.gz
    # https://datasets.imdbws.com/title.akas.tsv.gz
    # https://datasets.imdbws.com/title.basics.tsv.gz
    # https://datasets.imdbws.com/title.crew.tsv.gz

$source_meta_agg = "tmdb"
$source_content_class = "movies"; $content_source_id = 1
$source_content_class = "series";  $content_source_id = 2

$inpath = "N:\Video AllInOne Metadata\$source_meta_agg\$source_content_class";

$MyServer = "localhost";$MyPort  = "5432";$MyDB = "filmcab";$MyUid = "postgres";$MyPass = "postgres"
$DBConn = New-Object System.Data.Odbc.OdbcConnection;
$DBConn.ConnectionString = "Driver={PostgreSQL UNICODE(x64)};Server=$MyServer;Port=$MyPort;Database=$MyDB;Uid=$MyUid;Pwd=$MyPass;";
$dbconnopen = $false
try {
    $DBConn.Open();
    $dbconnopen = $true;
} catch {
    Write-Error "Message: $($_.Exception.Message)"
    Write-Error "StackTrace: $($_.Exception.StackTrace)"
    Write-Error "LoaderExceptions: $($_.Exception.LoaderExceptions)"
    $dbconnopen = $false;
    exit(2);
}

$DBCmd = $DBConn.CreateCommand();

function Invoke-Sql ($sql) {
    $DBCmd.CommandText = $sql
    try {
        $rtn = $DBCmd.ExecuteNonQuery();
    } catch {
        Write-Error $sql
        Write-Error "Message: $($_.Exception.Message)"
        Write-Error "StackTrace: $($_.Exception.StackTrace)"
        Write-Error "LoaderExceptions: $($_.Exception.LoaderExceptions)"
        exit(1);
    }
}

$load_json = $true
$dropandrecreate_json = $false
$expand_json = $false
$dropandrecreate_expanded_json = $true

if ($dbconnopen) {
    if ($load_json) {
        if ($dropandrecreate_json) {
            Invoke-Sql "DROP TABLE IF EXISTS receiving_dock.json_data;";
            Invoke-Sql "
                CREATE TABLE receiving_dock.json_data(LIKE public.template_for_docking_tables INCLUDING ALL,
                    content_source_id        int8
                ,   source_meta_agg          source_meta_agg_enum
                ,   source_content_class     source_content_class_enum
                ,	json_data_as_json_object JSON
                ,   inputpath                text UNIQUE
                ,   record_added_on          timestamptz default clock_timestamp()	
                );" 
        }

        $c = '.'
        $linct = 0

        Get-ChildItem $inpath -Recurse |
        ForEach-Object {
            $linct++
            $cleanfilepath = $_.FullName.Replace('''', '''''')
            if ($_.Length -eq 0)
            {
                Write-Error "File $cleanfilepath is empty. Skipping."
            }
            else {
                if ($linct % 100 -eq 0) {
                    if ($c -eq '.') {$c = '!'} else {$c = '.'}
#                    Write-Host " $linct " -NoNewline
                    Write-Host -NoNewline  $c
                }
                $cleanfilepath = $cleanfilepath.Replace('''', '''''')
                Invoke-Sql "
                INSERT INTO receiving_dock.json_data(
                    content_source_id, source_meta_agg, source_content_class, inputpath, json_data_as_json_object) 
                SELECT $content_source_id, '$source_meta_agg', '$source_content_class', '$cleanfilepath', pg_read_file('$cleanfilepath')::json
                WHERE NOT EXISTS(SELECT 1 FROM receiving_dock.json_data a WHERE '$cleanfilepath' = a.inputpath)
                ;"
            }
        }
    }

    if ($expand_json) {
        if ($dropandrecreate_expanded_json) {
        Invoke-Sql "DROP TABLE IF EXISTS receiving_dock.json_data_expanded;"
        Invoke-Sql "
        CREATE TABLE receiving_dock.json_data_expanded (
            id                                INT8 NOT NULL GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 CYCLE) PRIMARY KEY,
            source_meta_agg                   source_meta_agg_enum,
            source_content_class              source_content_class_enum,
            inputpath                         TEXT UNIQUE,
            imdb_id_no                        TEXT UNIQUE,                        
            imdb_tt_id                        TEXT,                        
            title                             TEXT,                             
            original_title                    TEXT,                    
            description                       TEXT,                       
            tagline                           TEXT,                           
            genres                            JSON,
            genres_arr                        TEXT[],
            production_companies              JSON,
            production_companies_arr          TEXT[],              
            production_countries              JSON,
            production_countries_arr          TEXT[],
            spoken_languages                  JSON,
            spoken_languages_arr              TEXT[],
            production_status                 TEXT,                 
            released_on                       TEXT,                       
            runtime_in_minutes                TEXT,                
            budget                            TEXT,                            
            revenue                           TEXT,                           
            popularity                        TEXT,
            vote_count                        TEXT,
            vote_average                      TEXT,                      
            homepage                          TEXT,                          
            original_language                 TEXT,                 
            poster_path                       TEXT,                       
            backdrop_path                     TEXT,                     
            belongs_to_collection_id          TEXT,          
            belongs_to_collection_poster_path TEXT, 
            belongs_to_collection_name        TEXT,        
            is_video                          TEXT,                          
            is_adult                          TEXT 
            )
            ;
        "
        }
    Invoke-Sql "
    INSERT INTO receiving_dock.json_data_expanded(
        source_meta_agg, source_content_class, inputpath,
        imdb_id_no, imdb_tt_id, title, original_title, description, tagline, 
        genres, production_companies, production_countries, spoken_languages, 
        production_status, released_on, runtime_in_minutes, 
        budget, revenue, popularity, vote_count, vote_average, homepage, original_language, poster_path, backdrop_path, belongs_to_collection_id, belongs_to_collection_poster_path, belongs_to_collection_name, is_video, is_adult
    )
    SELECT  
        source_meta_agg,
        source_content_class,
        inputpath,
        cast(json_data_as_json_object    ->> 'id' as int8)                                     imdb_id_no,
        json_data_as_json_object         ->> 'imdb_id'                                         imdb_tt_id,
        json_data_as_json_object         ->> 'title'                                           title,
        json_data_as_json_object         ->> 'original_title'                                  original_title,
        json_data_as_json_object         ->> 'overview'                                        description,
        json_data_as_json_object         ->> 'tagline'                                         tagline,
        cast(json_data_as_json_object    ->> 'genres' as json)                                 genres,
        cast(json_data_as_json_object    ->> 'production_companies' as json)                   production_companies,
        cast(json_data_as_json_object    ->> 'production_countries' as json)                   production_countries,
        cast(json_data_as_json_object    ->> 'spoken_languages' as json)                       spoken_languages,
        json_data_as_json_object         ->> 'status'                                          production_status,
        to_date(json_data_as_json_object ->> 'release_date', 'YYYY-MM-DD')                     released_on,
        cast(json_data_as_json_object    ->> 'runtime' as int)                                 runtime_in_minutes,
        cast(json_data_as_json_object    ->> 'budget' as int8)                                 budget,
        cast(json_data_as_json_object    ->> 'revenue' as int8)                                revenue,
        cast(json_data_as_json_object    ->> 'popularity' as decimal(10,3))                    popularity,
        cast(json_data_as_json_object    ->> 'vote_count' as int8)                             vote_count,
        cast(json_data_as_json_object    ->> 'vote_average' as decimal(3,1))                   vote_average,
        json_data_as_json_object         ->> 'homepage'                                        homepage,
        json_data_as_json_object         ->> 'original_language'                               original_language,
        json_data_as_json_object         ->> 'poster_path'                                     poster_path,
        json_data_as_json_object         ->> 'backdrop_path'                                   backdrop_path,
        cast(json_data_as_json_object     -> 'belongs_to_collection' -> 'id' as text)          belongs_to_collection_id,
        cast(json_data_as_json_object     -> 'belongs_to_collection' -> 'poster_path' as text) belongs_to_collection_poster_path,
        cast(json_data_as_json_object     -> 'belongs_to_collection' -> 'name' as text)        belongs_to_collection_name,
        cast(json_data_as_json_object    ->> 'video' as boolean)                               is_video,
        cast(json_data_as_json_object    ->> 'adult' as boolean)                               is_adult
    from receiving_dock.json_data
    where source_meta_agg = '$source_meta_agg' and source_content_class = '$source_content_class'
    ;
    "
    Invoke-Sql "
    UPDATE receiving_dock.json_data_expanded a set genres_arr =   
    (
        SELECT array_agg(aa.name) genres_arr from receiving_dock.json_data_expanded b cross join json_array_elements(a.genres) aa(name) where a.id = b.id  group by b.id
    ) 
    where source_meta_agg = '$source_meta_agg' and source_content_class = '$source_content_class'; 
    "
    }
}
    # 
    # load C:\Users\jeffs\Downloads\series\series into json_data



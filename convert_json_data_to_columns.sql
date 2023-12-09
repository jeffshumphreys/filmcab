DROP TABLE IF EXISTS receiving_dock.tmdb_json_data_expanded;

        CREATE TABLE receiving_dock.tmdb_json_data_expanded(LIKE public.template_for_docking_tables INCLUDING ALL,
        content_source_id                 INT8,
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
        is_adult                          TEXT, 
        record_added_on                   TIMESTAMPTZ DEFAULT CLOCK_TIMESTAMP()	
        );
    

    INSERT INTO receiving_dock.tmdb_json_data_expanded(
        source_meta_agg, source_content_class, inputpath,
        imdb_id_no, imdb_tt_id, title, original_title, description, tagline, 
        genres, production_companies, production_countries, spoken_languages, 
        production_status, released_on, runtime_in_minutes, 
        budget, revenue, popularity, vote_count, vote_average, homepage, original_language, poster_path, backdrop_path, 
        belongs_to_collection_id, belongs_to_collection_poster_path, belongs_to_collection_name, is_video, is_adult
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
    where source_meta_agg = 'tmdb' and source_content_class = 'movies'
    ;
	WITH x AS(
	SELECT id, array_unique(array_agg(trim((aa.v -> 'name')::TEXT, '"'))) genres 
	FROM receiving_dock.tmdb_json_data_expanded a 
	CROSS JOIN json_array_elements(a.genres) aa(v)
	GROUP BY id
	)
	UPDATE receiving_dock.tmdb_json_data_expanded y SET genres_arr = x.genres FROM x WHERE y.id = x.id;

	WITH x AS(
	SELECT id, array_unique(array_agg(trim((aa.v -> 'name')::TEXT, '"'))) production_companies 
	FROM receiving_dock.tmdb_json_data_expanded a 
	CROSS JOIN json_array_elements(a.production_companies) aa(v)
	GROUP BY id
	)
	UPDATE receiving_dock.tmdb_json_data_expanded y SET production_companies_arr = x.production_companies FROM x WHERE y.id = x.id;

	WITH x AS(
	SELECT id, array_unique(array_agg(trim((aa.v -> 'name')::TEXT, '"'))) production_countries 
	FROM receiving_dock.tmdb_json_data_expanded a 
	CROSS JOIN json_array_elements(a.production_countries) aa(v)
	GROUP BY id
	)
	UPDATE receiving_dock.tmdb_json_data_expanded y SET production_countries_arr = x.production_countries FROM x WHERE y.id = x.id;

	WITH x AS(
	SELECT id, array_unique(array_agg(trim((aa.v -> 'name')::TEXT, '"'))) spoken_languages 
	FROM receiving_dock.tmdb_json_data_expanded a 
	CROSS JOIN json_array_elements(a.spoken_languages) aa(v)
	GROUP BY id
	)
	UPDATE receiving_dock.tmdb_json_data_expanded y SET spoken_languages_arr = x.spoken_languages FROM x WHERE y.id = x.id;

create function array_unique(p_input anyarray)
  returns anyarray immutable strict parallel safe 
  language sql
as 
$$
select array_agg(t order by x)
from (
  select distinct on (t) t,x
  from unnest(p_input) with ordinality as p(t,x)
  order by t,x
) t2;
$$

select array_unique(array_append(ARRAY[1,2], 2));
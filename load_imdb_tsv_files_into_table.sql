--/*

DROP TABLE IF EXISTS receiving_dock.imdb_data_name_basics;
CREATE TABLE receiving_dock.imdb_data_name_basics(
	id                                INT8 NOT NULL GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 CYCLE) PRIMARY KEY,
	imdb_nm_id                        TEXT,
	person_name                       TEXT,                             
	birth_year                        TEXT,                      
	death_year                        TEXT,
	primary_profession                TEXT,
	known_for_imdb_tt_ids             TEXT,                 
	record_added_on                   TIMESTAMPTZ DEFAULT CLOCK_TIMESTAMP(),
	deleting_dup                      BOOLEAN DEFAULT FALSE,
	deleted_as_dup_of_id              INT8,
	replaces_deleted_id               INT8
	);

COPY receiving_dock.imdb_data_name_basics(imdb_nm_id, person_name, birth_year, death_year, primary_profession, known_for_imdb_tt_ids)
FROM 'N:\Video AllInOne Metadata\imdb\data.name.basics.tsv' HEADER; -- TEXT=TSV
-- 958,016 rows!!!! includes adults, though.
VACUUM receiving_dock.tmdb_movie_csv_data;
--*/
select count(*) FROM receiving_dock.tmdb_movie_csv_data tmcd where adult = 'False'; -- 869,035
select * from receiving_dock.tmdb_movie_csv_data limit 100;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DISCARD TEMP;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
	tmdb_id,
	min_id,
	max_id,
	             CASE 
	             	WHEN original_title is not null and y.original_title = title1 and title like '!!%' THEN title2  
	             	WHEN original_title is not null and y.original_title = title2 and title like '!!%' THEN title1 
	             	WHEN original_title is not null and y.original_title <> title2 and original_title <> title1 and title like '!!%' THEN title1 
	             	WHEN original_title is null and title LIKE '!!%' AND title1 <> title2 THEN title1
	             ELSE title END AS 
	title,
	             CASE WHEN original_title IS NULL AND title LIKE '!!%' AND title1 <> title2 THEN title2 ELSE original_title END AS 
    original_title,
	title1,
	title2,
	vote_average,
	vote_count,
	             CASE WHEN status = '!!!Released or Post Production' THEN 'Realeased' ELSE status END 
	status,
	release_date,
	revenue,
	runtime,
	adult,
	backdrop_path,
	budget,
	homepage,
	imdb_tt_id,
	original_language,
	overview,
	popularity,
	poster_path,
	tagline,
	genres,
	production_companies,
	production_countries,
	spoken_languages,
	record_added_on
INTO TEMPORARY tmdb_movie_csv_data_dups_by_tmdbid
FROM (
	SELECT  
		tmdb_id                     ,
		min(id) as min_id                         ,
		max(id) as max_id                         ,
		case when max(title                       ) is not distinct from  min(title                ) then max(title                ) else '!!!' || max(title                ) || ' or ' || min(title                ) end as title                ,
		case when max(title                       ) is distinct from      min(title                ) then max(title                ) else null                                                                        end as title1                ,
		case when max(title                       ) is distinct from      min(title                ) then min(title                ) else null                                                                        end as title2                ,
		case when max(x.original_title            ) is not distinct from  min(original_title       ) then max(original_title       ) else '!!!' || max(original_title       ) || ' or ' || min(original_title       ) end as original_title       ,
		case when max(vote_average                ) is not distinct from  min(vote_average         ) then max(vote_average         ) else '!!!' || max(vote_average         ) || ' or ' || min(vote_average         ) end as vote_average         ,
		case when max(vote_count                  ) is not distinct from  min(vote_count           ) then max(vote_count           ) else '!!!' || max(vote_count           ) || ' or ' || min(vote_count           ) end as vote_count           ,
		case when max(status                      ) is not distinct from  min(status               ) then max(status               ) else '!!!' || max(status               ) || ' or ' || min(status               ) end as status               ,
		case when max(release_date                ) is not distinct from  min(release_date         ) then max(release_date         ) else max(release_date         ) end as release_date         ,
		case when max(revenue                     ) is not distinct from  min(revenue              ) then max(revenue              ) else '!!!' || max(revenue              ) || ' or ' || min(revenue              ) end as revenue              ,
		case when max(runtime                     ) is not distinct from  min(runtime              ) then max(runtime              ) else '!!!' || max(runtime              ) || ' or ' || min(runtime              ) end as runtime              ,
		case when max(adult                       ) is not distinct from  min(adult                ) then max(adult                ) else '!!!' || max(adult                ) || ' or ' || min(adult                ) end as adult                ,
		case when max(backdrop_path               ) is not distinct from  min(backdrop_path        ) then max(backdrop_path        ) else '!!!' || max(backdrop_path        ) || ' or ' || min(backdrop_path        ) end as backdrop_path        ,
		case when max(budget                      ) is not distinct from  min(budget               ) then max(budget               ) else max(budget               )  end as budget               , -- Looks like wrong levels: 2436 vs 2, 420000 vs 420.
		case when max(homepage                    ) is not distinct from  min(homepage             ) then max(homepage             ) else '!!!' || max(homepage             ) || ' or ' || min(homepage             ) end as homepage             ,
		case when max(imdb_tt_id                  ) is not distinct from  min(imdb_tt_id           ) then max(imdb_tt_id           ) else '!!!' || max(imdb_tt_id           ) || ' or ' || min(imdb_tt_id           ) end as imdb_tt_id           ,
		case when max(original_language           ) is not distinct from  min(original_language    ) then max(original_language    ) else max(original_language    ) end as original_language    , -- mr or en, no or en, hi or en, etc.
		case when max(overview                    ) is not distinct from  min(overview             ) then max(overview             ) else '!!!' || max(overview             ) || '\n or ' || min(overview             ) end as overview             ,
		case when max(popularity                  ) is not distinct from  min(popularity           ) then max(popularity           ) else max(popularity           )  end as popularity           , -- all are a valid number vs '0.0' so take the non-zero  Popularity of 0.0?
		case when max(poster_path                 ) is not distinct from  min(poster_path          ) then max(poster_path          ) else '!!!' || max(poster_path          ) || ' or ' || min(poster_path          ) end as poster_path          ,
		case when max(tagline                     ) is not distinct from  min(tagline              ) then max(tagline              ) else '!!!' || max(tagline              ) || ' or ' || min(tagline              ) end as tagline              ,
		case when max(genres                      ) is not distinct from  min(genres               ) then max(genres               ) else '!!!' || max(genres               ) || ' or ' || min(genres               ) end as genres               ,
		case when max(production_companies        ) is not distinct from  min(production_companies ) then max(production_companies ) else '!!!' || max(production_companies ) || ' or ' || min(production_companies ) end as production_companies ,
		case when max(production_countries        ) is not distinct from  min(production_countries ) then max(production_countries ) else '!!!' || max(production_countries ) || ' or ' || min(production_countries ) end as production_countries ,
		case when max(spoken_languages            ) is not distinct from  min(spoken_languages     ) then max(spoken_languages     ) else '!!!' || max(spoken_languages     ) || ' or ' || min(spoken_languages     ) end as spoken_languages     ,
		max(record_added_on             ) record_added_on      
	FROM (
		SELECT id, t.tmdb_id, title, 
		    nullif(original_title                   , title)  as original_title, 
			nullif(vote_average                     , '0.0') as vote_average         ,                      
			nullif(vote_count                       , '0') as vote_count             ,
			nullif(status                           , '') as status                  ,                 
			nullif(release_date                     , '') as release_date            ,                       
			nullif(revenue                          , '0') as revenue                 ,                           
			nullif(runtime                          , '0') as runtime                ,                
			nullif(adult                            , '') as adult,
			nullif(backdrop_path                    , '') as backdrop_path           ,                     
			nullif(budget                           , '0') as budget                 ,                            
			nullif(homepage                         , '') as homepage                ,                          
			nullif(imdb_tt_id                       , '') as imdb_tt_id              ,
			nullif(original_language                , '') as original_language       ,                 
			nullif(overview                         , '') as overview                ,                       
			nullif(popularity                       , '') as popularity              ,
			nullif(poster_path                      , '') as poster_path             ,                       
			nullif(tagline                          , '') as tagline                 ,                           
			nullif(genres                           , '') as genres                  ,
			nullif(production_companies             , '') as production_companies    ,
			nullif(production_countries             , '') as production_countries    ,
			nullif(spoken_languages                 , '') as spoken_languages        ,
			record_added_on
		FROM receiving_dock.tmdb_movie_csv_data t JOIN (
			SELECT tmdb_id FROM receiving_dock.tmdb_movie_csv_data tmcd GROUP BY tmdb_id HAVING count(*) > 1
		) dups on t.tmdb_id = dups.tmdb_id
	) x
	GROUP BY x.tmdb_id
) y
ORDER BY tmdb_id;

--SELECT tmdb_id,min_id,max_id,title,original_title,title1,title2,vote_average,vote_count,status,release_date,revenue,runtime,adult,backdrop_path,budget,homepage,imdb_tt_id,original_language,overview,popularity,poster_path,tagline,genres,production_companies,production_countries,spoken_languages,record_added_on FROM tmdb_movie_csv_data_dups_by_tmdbid;

WITH a as (SELECT min_id, max_id FROM tmdb_movie_csv_data_dups_by_tmdbid)
UPDATE receiving_dock.tmdb_movie_csv_data AS x 
SET deleting_dup = true, deleted_as_dup_of_id = a.max_id 
FROM a WHERE a.min_id= x.id;

WITH a as (SELECT * FROM tmdb_movie_csv_data_dups_by_tmdbid)
UPDATE receiving_dock.tmdb_movie_csv_data AS x 
SET 
	original_title                 = a.original_title       ,
	vote_average                   = a.vote_average         ,
	vote_count                     = a.vote_count           ,
	status                         = a.status               ,
	release_date                   = a.release_date         ,
	revenue                        = a.revenue              ,
	runtime                        = a.runtime              ,
	adult                          = a.adult                ,
	backdrop_path                  = a.backdrop_path        ,
	budget                         = a.budget               ,
	homepage                       = a.homepage             ,
	imdb_tt_id                     = a.imdb_tt_id           ,
	original_language              = a.original_language    ,
	overview                       = a.overview             ,
	popularity                     = a.popularity           ,
	poster_path                    = a.poster_path          ,
	tagline                        = a.tagline              ,
	genres                         = a.genres               ,
	production_companies           = a.production_companies ,
	production_countries           = a.production_countries ,
	spoken_languages               = a.spoken_languages     ,
	replaces_deleted_id            = a.min_id 
FROM a WHERE a.max_id = x.id;
-- online: User Score?, Keywords, crew, cast,
--SELECT tmdb_id FROM receiving_dock.tmdb_movie_csv_data WHERE not deleting_dup  GROUP BY tmdb_id HAVING COUNT(*) > 1;
--SELECT * FROM receiving_dock.tmdb_movie_csv_data tmcd limit 100;
--UPDATE receiving_dock.tmdb_movie_csv_data  set original_title = null where title = original_title ;
VACUUM (VERBOSE, ANALYZE) receiving_dock.tmdb_movie_csv_data;

	--SELECT * FROM receiving_dock.tmdb_movie_csv_data tmcd where title <> trim(title);
	--SELECT DISTINCT status FROM receiving_dock.tmdb_movie_csv_data tmcd;
	--SELECT 'https://www.themoviedb.org/movie/' || tmdb_id tmdb_movie_link, * FROM receiving_dock.tmdb_movie_csv_data tmcd where title = '';
DROP TABLE IF EXISTS receiving_dock.tmdb_movie_csv_data_cleaner;
	SELECT
	id                                                                                                                                       as id                    , -- never null
	cast(tmdb_id as int8)                                                                                                                    as tmdb_id               , -- never null, should be de-dupped by now
	'https://www.themoviedb.org/movie/' || tmdb_id                                                                                           as tmdb_movie_link       ,
	nullif(imdb_tt_id, '')                                                                                                                   as imdb_tt_id            ,
	case when imdb_tt_id <> '' then 'https://www.imdb.com/title/' || imdb_tt_id end                                                          as imdb_movie_link       ,
	trim(case when title = '' and original_title is not null then original_title else title end)                                             as title                 ,
	trim(case when (title = '' or title is null or title = original_title) and original_title is not null then original_title end) as original_title        ,
	CAST(nullif(vote_count  , '0')  as INT)                                                                                                  as vote_count            ,
	cast(nullif(vote_average, '0.0') as decimal(3,1))                                                                                        as vote_average          ,
	cast(popularity as decimal(10,3))                                                                                                        as popularity            ,
	case status when 'Realeased' then 'Released' else status end                                                                             as status                , -- Canceled,In Production,Planned,Post Production, Realeased,Released,Rumored        
	to_date(nullif(release_date, ''), 'yyyy-mm-dd')                                                                                          as release_date          ,
	cast(nullif(budget           , '0') as INT8)                                                                                             as budget                ,
	cast(nullif(revenue          , '0') as INT8)                                                                                             as revenue               ,
	cast(nullif(runtime          , '0') as SMALLINT)                                                                                         as runtime               ,
	nullif(trim(homepage                  ), '')                                                                                             as homepage              ,
	nullif(trim(overview                  ), '')                                                                                             as overview              ,
	nullif(trim(tagline                   ), '')                                                                                             as tagline               ,
	nullif(trim(backdrop_path             ), '')                                                                                             as backdrop_path         ,
	nullif(trim(poster_path               ), '')                                                                                             as poster_path           ,
	nullif(trim(original_language         ), '')                                                                                             as original_language     ,
	string_to_array(trim(nullif(genres, '')                    ), ',')                                                                       as genres                ,
	string_to_array(nullif(trim(production_companies      ), ''), ',')                                                                       as production_companies  ,
	string_to_array(nullif(trim(production_countries      ), ''), ',')                                                                       as production_countries  ,
	string_to_array(nullif(trim(spoken_languages          ), ''), ',')                                                                       as spoken_languages      ,
	cast(nullif(trim(adult                     ), '') as BOOLEAN)                                                                            as adult                 ,
	record_added_on           ,
	deleting_dup              ,
	deleted_as_dup_of_id            ,
	replaces_deleted_id
	INTO receiving_dock.tmdb_movie_csv_data_cleaner
    FROM receiving_dock.tmdb_movie_csv_data tmcd 
    WHERE deleting_dup IS FALSE
    --and popularity = '0.000'
    ;
    
   DISCARD TEMP;
   SELECT *, cast(null as boolean) as inextractable_on_tmdb, cast(null as boolean) as tmdb_link_does_not_resolve
   INTO TEMPORARY tmdb_movie_csv_data_no_title
   FROM receiving_dock.tmdb_movie_csv_data_cleaner where title = '';
update tmdb_movie_csv_data_no_title set title = 'Cherry Valentine: Gypsy Queen and Proud', overview = 'At 18, George Ward left the Gypsy community. He had felt rejected having come out as gay. Leaving his Gypsy identity behind, he invented Cherry Valentine, a drag alter-ego. Now he wants to find out if he can be accepted as a queer Gypsy and feel proud.'
where id = 444584;
update tmdb_movie_csv_data_no_title set inextractable_on_tmdb = null, tagline = 'Silent meeting, roaring comedy.', release_date = to_date('2023-07-30', 'yyyy-mm-dd'), overview='Actor Joel McHale interacts with the Detention Kids, and things don''t exactly go as planned.'
, title = 'Detention Kids: Rise of Joel McHale'
where id = 469412;
update tmdb_movie_csv_data_no_title set title = 'Catherine Naps and Eggs', overview = 'An overview of the life of a person named Catherine. The experiences were all documented on film, and takes place during the great war.', release_date = to_date('2008-03-02', 'yyyy-mm-dd')
 , genres = '{Documentary}', production_companies = '{us}', tagline = 'Naps. Eggs. Life.', budget=1000000
where id = 494345;
update tmdb_movie_csv_data_no_title set title = 'Exhibition in Reval' where id = 642814;
update tmdb_movie_csv_data_no_title set title = 'My Body, My Rules, and Them', genres = '{gay}', runtime=3, tagline='an experimental film by Sean Latorre' 
where id = 527913;
update tmdb_movie_csv_data_no_title set title = 'Red Light Green Light', status = 'Released', overview = 'Seven college students are forced to compete in children’s games for survival. With their futures unclear, the secrets of their pasts are revealed.'
, runtime=75, adult = false, genres = '{horror}', tagline = 'PLAY AT YOUR OWN RISK', original_title = 'Quid Games'
where id = 431884;
update tmdb_movie_csv_data_no_title set title = 'NULL', overview='A hitman is tasked to take out ex-mobsters when he suddenly hears a voice that questions his morality.', runtime=10 where id = 528129;
update tmdb_movie_csv_data_no_title set title = 'The Hooligan Factory', overview='Danny wants something more. Expelled from school and living in his grandfathers flat, he longs to live up to the image of his estranged father Danny Senior. Sent to prison for force feeding a judge his own wig Danny Senior was a legend and Danny is looking for a way to emulate his father''s achievements and rise to be \"top boy\". Meanwhile in Wormwood Scrubs prison legendary football hooligan Dex is about to be released. Dex is on a quest of his own, one of vengeance against his nemesis and rival firm leader Yeti. But when Danny and Dex''s paths cross they embark on a journey as old as hooliganism itself. Dex, Danny and The Hooligan Factory travel the length of the country on a mission to re-establish their firm''s glory days. However, the police are closing in and we get a sense that the Hooligan Factory''s best days may be behind them, but with Danny on their side, and Dex finding his old form who knows where this may lead. After all... Its a funny old game.'
, homepage='http://thehooliganfactory.com/', imdb_tt_id = 'tt2360446' where id = 732626;
update tmdb_movie_csv_data_no_title set tmdb_link_does_not_resolve = true, title = 'Cherry Valentine Gypsy Queen and Proud' where id = 444589;
update tmdb_movie_csv_data_no_title set title = 'Samurai Beyond Admiration Record to the World''s Best', original_title= '憧れを超えた侍', imdb_tt_id = 'tt28150441', runtime = 130 where id = 528477;
update tmdb_movie_csv_data_no_title set title = 'Unearthly Getaway', tagline = 'What lies within will make you lose yourself.', production_companies = '{Retro Galaxy Cinema, LateFlix, Stacks Entertainment}'
, imdb_tt_id = 'tt27262526', overview = 'In a house where a suicide took place, Jazmin and Sam spend their weekend intending to clear the house only to find out that there has been something evil living inside.' where id = 483800;
update tmdb_movie_csv_data_no_title set title = 'None' where id = 677236;
update tmdb_movie_csv_data_no_title set title = 'The Man of the Monkey', overview = 'Imagine the fantastic daydreams that a nine-year-old boy must have had after listening to his father tell him the tale of \"Man of the Monkey\": \"There is a scary man living in isolation with a female chimpanzee as his wife, somewhere here on the island where we live.\" This boy wondered, was \"Man of the Monkey\" a monster who would attack anyone that came near him or was he a wild adventurer like Tarzan? As one could imagine, this story remained with the boy throughout his childhood as he was puzzled by many unanswered questions. That young boy is now filmmaker David Romberg. The mystery of this story takes David back to his childhood home in the mountainous rain forest of Ilha Grande, Brazil, in order to search for the Man of the Monkey. On this journey, David, whose family is of Jewish descent, shockingly discovers that many on the island believe \"Man of the Monkey\" is an escaped Nazi. He also comes to find out that the island, which was a refuge for the filmmaker''s father after ...'
, imdb_tt_id = 'tt2323246' where id = 848416;

select * FROM tmdb_movie_csv_data_no_title where (inextractable_on_tmdb is null or inextractable_on_tmdb is false) and (tmdb_link_does_not_resolve is null or tmdb_link_does_not_resolve is false);

WITH a as (SELECT * FROM tmdb_movie_csv_data_no_title)
UPDATE receiving_dock.tmdb_movie_csv_data_cleaner  AS x 
SET 
    title                          = a.title                ,
	original_title                 = a.original_title       ,
	vote_average                   = a.vote_average         ,
	vote_count                     = a.vote_count           ,
	status                         = a.status               ,
	release_date                   = a.release_date         ,
	revenue                        = a.revenue              ,
	runtime                        = a.runtime              ,
	adult                          = a.adult                ,
	backdrop_path                  = a.backdrop_path        ,
	budget                         = a.budget               ,
	homepage                       = a.homepage             ,
	imdb_tt_id                     = a.imdb_tt_id           ,
	original_language              = a.original_language    ,
	overview                       = a.overview             ,
	popularity                     = a.popularity           ,
	poster_path                    = a.poster_path          ,
	tagline                        = a.tagline              ,
	genres                         = a.genres               ,
	production_companies           = a.production_companies ,
	production_countries           = a.production_countries ,
	spoken_languages               = a.spoken_languages     
FROM a WHERE a.id = x.id;
select * FROM receiving_dock.tmdb_movie_csv_data_cleaner where title = '';
select * FROM receiving_dock.tmdb_movie_csv_data_cleaner where release_date is null;
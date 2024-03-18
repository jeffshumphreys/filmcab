select idtb.* from receiving_dock.imdb_data_title_basics idtb left join receiving_dock.imdb_data_title_akas idta on idtb.imdb_tt_id = idta.imdb_tt_id and idta.ordering_no = '1'
where idta.imdb_tt_id is null; -- 600 tvEpisodes. meh.

select count(*) from receiving_dock.imdb_data_title_basics idtb2; -- This has 10,337,922
-- https://www.kaggle.com/datasets/babe8901/imdb-movies-database?select=title_basics.tsv has 9,589,177 rows
select min(imdb_tt_id) from receiving_dock.imdb_data_title_basics idnb ; -- tt0000001
drop table if exists receiving_dock.imdb_flat_data;
select 
	ttl.imdb_tt_id, /* convert to int? */  
	ttl.title_type /* to enum */, 
	                                          ttl.primary_title, 
	nullif(ttl.original_title, ttl.primary_title) original_title
, pttl.primary_title                             parent_primary_title
, nullif(pttl.original_title, pttl.primary_title) parent_original_title
, pttl.title_type                                parent_title_type
, ida01.title aka_title_01--, ida01.region_code  aka_region_code_01, ida01.language_code aka_language_code_01, ida01.types_of_title types_of_title_01, ida01.attributes_of_title attributes_of_title_01, ida01.is_original_title is_original_title_01
, ida02.title aka_title_02--, ida02.region_code  aka_region_code_02, ida02.language_code aka_language_code_02, ida02.types_of_title types_of_title_02, ida02.attributes_of_title attributes_of_title_02, ida02.is_original_title is_original_title_02
, ida03.title aka_title_03--, ida02.region_code  aka_region_code_02, ida02.language_code aka_language_code_02, ida02.types_of_title types_of_title_02, ida02.attributes_of_title attributes_of_title_02, ida02.is_original_title is_original_title_02
, ida04.title aka_title_04--, ida02.region_code  aka_region_code_02, ida02.language_code aka_language_code_02, ida02.types_of_title types_of_title_02, ida02.attributes_of_title attributes_of_title_02, ida02.is_original_title is_original_title_02
, ida05.title aka_title_05--, ida02.region_code  aka_region_code_02, ida02.language_code aka_language_code_02, ida02.types_of_title types_of_title_02, ida02.attributes_of_title attributes_of_title_02, ida02.is_original_title is_original_title_02
, ttl.start_year, ttl.end_year, ttl.runtime_minutes, ttl.genres /*array it */, ttl.is_adult
, idtc.directors_imdb_nm_ids, idtc.writers_imdb_nm_ids
, idtr.average_rating, idtr.num_votes, idte.season_no
, idte.parent_imdb_tt_id , idte.episode_no 
into receiving_dock.imdb_flat_data
from receiving_dock.imdb_data_title_basics ttl 
left join receiving_dock.imdb_data_title_crew idtc on ttl.imdb_tt_id  = idtc.imdb_tt_id 
left join receiving_dock.imdb_data_title_ratings idtr  on ttl.imdb_tt_id = idtr.imdb_tt_id 
left join receiving_dock.imdb_data_title_episode idte on ttl.imdb_tt_id = idte.imdb_tt_id 
left join receiving_dock.imdb_data_title_basics pttl on idte.parent_imdb_tt_id = pttl.imdb_tt_id 
left join receiving_dock.imdb_data_title_akas ida01 on ttl.imdb_tt_id = ida01.imdb_tt_id and ida01.ordering_no = '1' and ida01.title <> ttl.primary_title
left join receiving_dock.imdb_data_title_akas ida02 on ttl.imdb_tt_id = ida02.imdb_tt_id and ida02.ordering_no = '2' and ida02.title <> ttl.primary_title
left join receiving_dock.imdb_data_title_akas ida03 on ttl.imdb_tt_id = ida03.imdb_tt_id and ida03.ordering_no = '3' and ida03.title <> ttl.primary_title
left join receiving_dock.imdb_data_title_akas ida04 on ttl.imdb_tt_id = ida04.imdb_tt_id and ida04.ordering_no = '4' and ida04.title <> ttl.primary_title
left join receiving_dock.imdb_data_title_akas ida05 on ttl.imdb_tt_id = ida05.imdb_tt_id and ida05.ordering_no = '5' and ida05.title <> ttl.primary_title
left join receiving_dock.imdb_data_title_principals idtp01 on ttl.imd_tt_id = idtp01.imdb_tt_id and idtp01.ordering_no = '1'
   -- then join to name_basics ugh.
--
--order by primary_title 
--limit 100
-- > 40 seconds!
;
select max(ordering_no) from receiving_dock.imdb_data_title_akas idta; -- 99!!!!!!!!!!
select * from receiving_dock.imdb_data_title_akas idta;
select distinct types_of_title  from receiving_dock.imdb_data_title_akas idta;
select distinct title_type from receiving_dock.imdb_data_title_basics idtb ;
select count(*) from receiving_dock.imdb_data_title_basics idtb2 where title_type = 'tvEpisode';  -- join to imdb_data_title_episo
-- principals?

select * from receiving_dock.imdb_flat_data ifd where ifd.imdb_tt_id = 'tt0000008';

--with x as (select * from receiving_dock.video_data vd where vd.tmdb_id_not_found_in_api is not null and vd.tmdb_id_not_found_in_api  > timestamp '2023-12-11 12:00:00')
--update receiving_dock.video_data t set tmdb_id_not_found_in_api = null from x where t.id = x.id;
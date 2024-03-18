update receiving_dock.video_data set 
imdb_tt_id = CASE WHEN TRIM(imdb_tt_id) IN('') THEN NULL ELSE TRIM(imdb_tt_id) END, -- There is a movie named "0", as well as "NULL"
title = CASE WHEN TRIM(title) IN('', '0','0.0', '0.00', '0.000') THEN NULL ELSE TRIM(title) END,
original_title = CASE WHEN TRIM(original_title) IN('', '0','0.0', '0.00', '0.000') THEN NULL ELSE TRIM(original_title) END,
vote_average = CASE WHEN TRIM(vote_average) IN('', '0','0.0', '0.00', '0.000') THEN NULL ELSE TRIM(vote_average) END,
vote_count = CASE WHEN TRIM(vote_count) IN('', '0','0.0', '0.00', '0.000') THEN NULL ELSE TRIM(vote_count) END,
popularity = CASE WHEN TRIM(popularity) IN('', '0','0.0', '0.00', '0.000') THEN NULL ELSE TRIM(popularity) END,
status = CASE WHEN TRIM(status) IN('', '0','0.0', '0.00', '0.000') THEN NULL ELSE TRIM(status) END,
release_date = CASE WHEN TRIM(release_date) IN('', '0','0.0', '0.00', '0.000') THEN NULL ELSE TRIM(release_date) END,
budget = CASE WHEN TRIM(budget) IN('', '0','0.0', '0.00', '0.000') THEN NULL ELSE TRIM(budget) END,
revenue = CASE WHEN TRIM(revenue) IN('', '0','0.0', '0.00', '0.000') THEN NULL ELSE TRIM(revenue) END,
runtime = CASE WHEN TRIM(runtime) IN('', '0','0.0', '0.00', '0.000') THEN NULL ELSE TRIM(runtime) END,
homepage = CASE WHEN TRIM(homepage) IN('', '0','0.0', '0.00', '0.000') THEN NULL ELSE TRIM(homepage) END,
overview = CASE WHEN TRIM(overview) IN('', '0','0.0', '0.00', '0.000') THEN NULL ELSE TRIM(overview) END,
tagline = CASE WHEN TRIM(tagline) IN('', '0','0.0', '0.00', '0.000') THEN NULL ELSE TRIM(tagline) END,
backdrop_path = CASE WHEN TRIM(backdrop_path) IN('', '0','0.0', '0.00', '0.000') THEN NULL ELSE TRIM(backdrop_path) END,
poster_path = CASE WHEN TRIM(poster_path) IN('', '0','0.0', '0.00', '0.000') THEN NULL ELSE TRIM(poster_path) END,
genres = CASE WHEN TRIM(genres) IN('', '0','0.0', '0.00', '0.000') THEN NULL ELSE TRIM(genres) END,
original_language = CASE WHEN TRIM(original_language) IN('', '0','0.0', '0.00', '0.000') THEN NULL ELSE TRIM(original_language) END,
production_companies = CASE WHEN TRIM(production_companies) IN('', '0','0.0', '0.00', '0.000') THEN NULL ELSE TRIM(production_companies) END,
production_countries = CASE WHEN TRIM(production_countries) IN('', '0','0.0', '0.00', '0.000') THEN NULL ELSE TRIM(production_countries) END,
spoken_languages = CASE WHEN TRIM(spoken_languages) IN('', '0','0.0', '0.00', '0.000') THEN NULL ELSE TRIM(spoken_languages) END,
adult = CASE WHEN TRIM(adult) IN('', '0','0.0', '0.00', '0.000') THEN NULL ELSE TRIM(adult) end;

update receiving_dock.video_data set original_title = null where title = original_title;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Clean up null titles
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

select * from receiving_dock.video_data where title is null and deleting_dup is false;
update receiving_dock.video_data set title = 'Exhibition in Reval', original_title = null where tmdb_id = '468137' and title is null;
-- Caméra? 0? Rodolphe Bouquerel
select * from receiving_dock.video_data where tmdb_id = '754524';
update receiving_dock.video_data set deleting_dup = true, deleted_as_dup_of_id = 807636 where tmdb_id = '754525';
update receiving_dock.video_data set replaces_deleted_id = 807674 where tmdb_id = '754524';

-- cherry-valentine-gypsy-queen-and-proud
update receiving_dock.video_data set title = 'Cherry Valentine: Gypsy Queen and Proud' where tmdb_id = '931166';

update receiving_dock.video_data set title = '0' where tmdb_id ='758531';
update receiving_dock.video_data set title = '0' where tmdb_id ='858120';

update receiving_dock.video_data set release_date = null where release_date = '0001-01-01 BC'; -- 65,406
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- pull imdb into tmdb on imdb_tt_id
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
update receiving_dock.imdb_flat_data set original_title = null where primary_title = original_title ;

select x.primary_title, y.title, x.original_title , y.original_title tmdb_title2, x.start_year, y.release_date 
from receiving_dock.imdb_flat_data x join receiving_dock.video_data y on x.imdb_tt_id = y.imdb_tt_id limit 100;

select count(*) from receiving_dock.imdb_flat_data x join receiving_dock.video_data y on x.imdb_tt_id = y.imdb_tt_id ;

select 
	x.imdb_tt_id imdb_id, 
	x.primary_title imdb_title1, 
	y.title         tmdb_title1, 
	x.original_title imdb_title2, 
	y.original_title tmdb_title2
	, x.start_year imdb_release_year, 
	y.release_date tmdb_release_date,
	left(y.release_date, 4) tmdb_release_year,
	x.
from receiving_dock.imdb_flat_data x join receiving_dock.video_data y on x.imdb_tt_id = y.imdb_tt_id 
where x.primary_title <> y.title
limit 100;

alter table receiving_dock.imdb_flat_data add constraint ak_imdb_flat_tt_id unique(imdb_tt_id);
select * from receiving_dock.video_data vd where release_date is null and adult = 'False' and status = 'Released' and tmdb_id_not_found_in_api is null;
select * from receiving_dock.imdb_flat_data ifd where ifd.imdb_tt_id = 'tt3585554';
select count(*) from receiving_dock.video_data vd where release_date is null and adult = 'False' and status = 'Released' and tmdb_id_not_found_in_api is null;
-- read off image to get release date
-- pull from imdb_flat_data where ttid matches and start_year is set.

select distinct status from receiving_dock.video_data vd;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
create index ix_video_data_title_year on receiving_dock.video_data(title, release_date);
vacuum receiving_dock.video_data;
select 
COUNT(imdb_tt_id) as imdb_tt_id_ct,
COUNT(title) as title_ct,
COUNT(original_title) as original_title_ct,
COUNT(vote_average) as vote_average_ct,
COUNT(vote_count) as vote_count_ct,
COUNT(popularity) as popularity_ct,
COUNT(status) as status_ct,
COUNT(release_date) as release_date_ct,
COUNT(budget) as budget_ct,
COUNT(revenue) as revenue_ct,
COUNT(runtime) as runtime_ct,
COUNT(homepage) as homepage_ct,
COUNT(overview) as overview_ct,
COUNT(tagline) as tagline_ct,
COUNT(backdrop_path) as backdrop_path_ct,
COUNT(poster_path) as poster_path_ct,
COUNT(genres) as genres_ct,
COUNT(original_language) as original_language_ct,
COUNT(production_companies) as production_companies_ct,
COUNT(production_countries) as production_countries_ct,
COUNT(spoken_languages) as spoken_languages_ct,
COUNT(adult) as adult_ct
from receiving_dock.video_data vd;

select 
COUNT(DISTINCT mdb_tt_id) as imdb_tt_id_ct,
COUNT(DISTINCT itle) as title_ct,
COUNT(DISTINCT riginal_title) as original_title_ct,
COUNT(DISTINCT ote_average) as vote_average_ct,
COUNT(DISTINCT ote_count) as vote_count_ct,
COUNT(DISTINCT opularity) as popularity_ct,
COUNT(DISTINCT tatus) as status_ct,
COUNT(DISTINCT elease_date) as release_date_ct,
COUNT(DISTINCT udget) as budget_ct,
COUNT(DISTINCT evenue) as revenue_ct,
COUNT(DISTINCT untime) as runtime_ct,
COUNT(DISTINCT omepage) as homepage_ct,
COUNT(DISTINCT verview) as overview_ct,
COUNT(DISTINCT agline) as tagline_ct,
COUNT(DISTINCT ackdrop_path) as backdrop_path_ct,
COUNT(DISTINCT oster_path) as poster_path_ct,
COUNT(DISTINCT enres) as genres_ct,
COUNT(DISTINCT riginal_language) as original_language_ct,
COUNT(DISTINCT roduction_companies) as production_companies_ct,
COUNT(DISTINCT roduction_countries) as production_countries_ct,
COUNT(DISTINCT poken_languages) as spoken_languages_ct,
COUNT(DISTINCT dult) as adult_ct
from receiving_dock.video_data vd;

DROP TABLE IF EXISTS receiving_dock.imdb_data_name_basics;
CREATE TABLE receiving_dock.imdb_data_name_basics(
	id                                INT8 NOT NULL GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 CYCLE) PRIMARY KEY,
	imdb_nm_id                        TEXT UNIQUE,
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
-- 13,029,347!!! Actors!!!!!!
-- 1.7G!!!!
SELECT * FROM receiving_dock.imdb_data_name_basics LIMIT 100;
-- Are person_name unique? +birth year
-- fix null birth years?
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS receiving_dock.imdb_data_title_akas;
CREATE TABLE receiving_dock.imdb_data_title_akas(
	id                                INT8 NOT NULL GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 CYCLE) PRIMARY KEY,
	imdb_tt_id                        TEXT,
	ordering_no                       TEXT,                             
	title                             TEXT,                      
	region_code                       TEXT,
	language_code                     TEXT,
	types_of_title                    TEXT,                 
	attributes_of_title               TEXT,
	is_original_title                 TEXT,
	record_added_on                   TIMESTAMPTZ DEFAULT CLOCK_TIMESTAMP(),
	deleting_dup                      BOOLEAN DEFAULT FALSE,
	deleted_as_dup_of_id              INT8,
	replaces_deleted_id               INT8
	);
COPY receiving_dock.imdb_data_title_akas(imdb_tt_id, ordering_no, title, region_code, language_code, types_of_title, attributes_of_title, is_original_title)
FROM 'N:\Video AllInOne Metadata\imdb\data.title.akas.tsv' HEADER; -- TEXT=TSV
-- 37,915,086 alternate titles
SELECT * FROM receiving_dock.imdb_data_title_akas LIMIT 100;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS receiving_dock.imdb_data_title_ratings;
CREATE TABLE receiving_dock.imdb_data_title_ratings(
	id                                INT8 NOT NULL GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 CYCLE) PRIMARY KEY,
	imdb_tt_id                        TEXT,
	average_rating                    TEXT,                             
	num_votes                         TEXT,                      
	record_added_on                   TIMESTAMPTZ DEFAULT CLOCK_TIMESTAMP(),
	deleting_dup                      BOOLEAN DEFAULT FALSE,
	deleted_as_dup_of_id              INT8,
	replaces_deleted_id               INT8
	);
COPY receiving_dock.imdb_data_title_ratings(imdb_tt_id, average_rating, num_votes)
FROM 'N:\Video AllInOne Metadata\imdb\data.title.ratings.tsv' HEADER; -- TEXT=TSV
-- 1,372,837
SELECT * FROM receiving_dock.imdb_data_title_ratings LIMIT 100;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS receiving_dock.imdb_data_title_basics;
CREATE TABLE receiving_dock.imdb_data_title_basics(
	id                                INT8 NOT NULL GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 CYCLE) PRIMARY KEY,
	imdb_tt_id                        TEXT,
	title_type                        TEXT,                             
	primary_title                     TEXT,                      
	original_title                    TEXT,
	is_adult                          TEXT,
	start_year                        TEXT,
	end_year                          TEXT,
	runtime_minutes                   TEXT,
	genres                            TEXT,
	record_added_on                   TIMESTAMPTZ DEFAULT CLOCK_TIMESTAMP(),
	deleting_dup                      BOOLEAN DEFAULT FALSE,
	deleted_as_dup_of_id              INT8,
	replaces_deleted_id               INT8
	);

COPY receiving_dock.imdb_data_title_basics(imdb_tt_id, title_type, primary_title, original_title, is_adult, start_year, end_year, runtime_minutes, genres)
FROM 'N:\Video AllInOne Metadata\imdb\data.title.basics.tsv' HEADER; -- TEXT=TSV
-- 10,337,922 title basics
SELECT * FROM receiving_dock.imdb_data_title_basics LIMIT 100;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS receiving_dock.imdb_data_title_crew;
CREATE TABLE receiving_dock.imdb_data_title_crew(
	id                                INT8 NOT NULL GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 CYCLE) PRIMARY KEY,
	imdb_tt_id                        TEXT,
	directors_imdb_nm_ids             TEXT,
	writers_imdb_nm_ids               TEXT,
	record_added_on                   TIMESTAMPTZ DEFAULT CLOCK_TIMESTAMP(),
	deleting_dup                      BOOLEAN DEFAULT FALSE,
	deleted_as_dup_of_id              INT8,
	replaces_deleted_id               INT8
	);

COPY receiving_dock.imdb_data_title_crew(imdb_tt_id, directors_imdb_nm_ids, writers_imdb_nm_ids)
FROM 'N:\Video AllInOne Metadata\imdb\data.title.crew.tsv' HEADER; -- TEXT=TSV
-- 10,337,922 crew members, directors and writers
SELECT * FROM receiving_dock.imdb_data_title_crew LIMIT 100;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS receiving_dock.imdb_data_title_episode;
CREATE TABLE receiving_dock.imdb_data_title_episode(
	id                                INT8 NOT NULL GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 CYCLE) PRIMARY KEY,
	imdb_tt_id                        TEXT,
	parent_imdb_tt_id                 TEXT,
	season_no                         TEXT,
	episode_no                        TEXT,
	record_added_on                   TIMESTAMPTZ DEFAULT CLOCK_TIMESTAMP(),
	deleting_dup                      BOOLEAN DEFAULT FALSE,
	deleted_as_dup_of_id              INT8,
	replaces_deleted_id               INT8
	);

COPY receiving_dock.imdb_data_title_episode(imdb_tt_id, parent_imdb_tt_id, season_no, episode_no)
FROM 'N:\Video AllInOne Metadata\imdb\data.title.episode.tsv' HEADER; -- TEXT=TSV
-- 10,337,922 episodes
SELECT * FROM receiving_dock.imdb_data_title_episode LIMIT 100;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS receiving_dock.imdb_data_title_principals;
CREATE TABLE receiving_dock.imdb_data_title_principals(
	id                                INT8 NOT NULL GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 CYCLE) PRIMARY KEY,
	imdb_tt_id                        TEXT,
	ordering_no                       TEXT,
	imdb_nm_id                        TEXT,
	category_name                     TEXT,
	job_name                          TEXT,
	characters_played                 TEXT, -- Watch it: Any multiples? ["Miss Geraldine Holbrook (Miss Jerry)"], commas embedded?":"
	record_added_on                   TIMESTAMPTZ DEFAULT CLOCK_TIMESTAMP(),
	deleting_dup                      BOOLEAN DEFAULT FALSE,
	deleted_as_dup_of_id              INT8,
	replaces_deleted_id               INT8
	);
COPY receiving_dock.imdb_data_title_principals(imdb_tt_id, ordering_no, imdb_nm_id, category_name, job_name, characters_played)
FROM 'N:\Video AllInOne Metadata\imdb\data.title.principals.tsv' HEADER; -- TEXT=TSV
-- Heeyuuuuge! 59,205,358 "principals"
SELECT * FROM receiving_dock.imdb_data_title_principals LIMIT 100;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DISCARD TEMP;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

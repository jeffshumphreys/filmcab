-- public.movie_files definition

-- Drop table


create schema if not exists receiving_dock;
create schema if not exists stage_for_master;
create schema if not exists shipping_dock;

set search_path = stage_for_master, "$user", public;

drop table if exists movie_files; -- Probably don't want constraints on this table

create table movie_files (
	id                                           int                         not null generated always as identity, -- local counter, since staging data
	file_id										 int                         not null,
	text                                         varchar(400)                not null, -- proper title, our style? or IMDB style?
	file_name                                    varchar(200)                not null, -- in case the file record is lost, what was the name from?  Definitely helps with the tag cat
	record_version_for_same_name                 int                         not null, -- local versioning
	release_year                                 int                             null check (release_year between 1890 and date_part('year', now())), -- may have to guess, lookup, derive
	type_id                                      int8                            null, -- Unlike Titles table, type does not make it unique. Mainly path.  types are video, film, movie, tv series, subtitles, yada
	source_type_tags_from_file_name              varchar(20)				     null, -- BRrip_, BRRip, BRrip, BDRip, BlueRay, DVDRip, DVDRiP XviD, Xvid, WEBRip, WEB-DL, DVD Rip, (BR), SubRip - MicroDVD
	display_resolution_tags_from_file_name		 varchar(10)                     null, -- 1080p, 720p
	country_release_tags_from_file_name			 char(2)                         null, -- UK
	spoken_language_tags_from_file_name          char(3)                         null, -- eng, french, spanish, ITA, GRE, ENG, POR, SPA, RUS , _swe, HUN, POL, ROM, SWE, TUR, CZE, FIN, GER, russian
	uploader_tags_from_file_name                 varchar(30)                     null, -- GalaxyRG, YIFY, PSYCHD, RedBlade, SiNNERS, HiC, anoXmous, RARBG, SUJAIDR, HiC, ProLover, -psychd, AC3-EVO, RARBG.com, BONE, ShAaNiG, HANDJOB
	encoding_tags_from_file_name                 varchar(10)                     null, -- x264, x265, H264
	genre_tags_from_file_name                    varchar(20)                     null, -- Classics, -Film-Noir, Drama, War Western, War West, (History)
	audio_tags_from_file_name                    varchar(20)                     null, -- 2-ch, , Dolby 5.1 +, REMASTERED, 10bit-, 
	misc_tags_from_file_name                     text[]                          null, -- AAC-, INTERNAL, -cd1, -cd2, HDTV, AC3, MVGroup.org, HDTS, Criterion, DD, v2.5, .CD01., REMASTERED, 999MB, HQ, -[YTS.AM], Part One., Part Two.
	record_created_on_ts_wth_tz                  timestamptz                     null default clock_timestamp(), -- NEVER LET update change
	record_changed_on_ts_wth_tz                  timestamptz                     null, -- set by trigger, NEVER by insert, and NEVER not current timestamp. jeez.
	record_deleted                               bool                            null, -- tricky: what is deleted? the film from history? no such film?
	record_deleted_on_ts_wth_tz                  timestamptz                     null,
	record_deleted_why							 varchar(400)                    null, -- could be a code, too, as in "file no longer present, torrent system moved, duplicate record" Entry in error for non-existent movie?
	text_prev                                    varchar(400)                    null, -- set from update trigger to try and keep some clueage
	text_corrected                               bool                            null,
	text_corrected_on_ts_wth_tz                  timestamptz                     null,
	type_corrected                               bool                            null,
	type_corrected_on_ts_wth_tz                  timestamptz                     null,
	subtitles_file_id						     int                             null, -- just in staging, but for putting it all together for master. Make a foreign key. cannot be same as file_id, probably.
	subtitles_embedded						     bool                            null, -- hopefully english
	plays_in_dsktp_vlc                           bool                            null, -- what version?
	constraint pk_movie_files_id primary key (id),
	constraint ak_movie_files_text_version unique (text, record_version_for_same_name),
	constraint ak_movie_files_text_release_year unique (text, release_year), -- what a mess. different record version, but same release year????
    constraint fk_movie_has_file_info foreign key(file_id) references files(id) on delete set null -- Usually if the file entry in staging is deleted, it is being reloaded and this table will have to be relinked. Don't want file_ids to non-existent records.
);

comment on column movie_files.id                          is 'staging so use an identity. Master has to keep id''s across system. Still, would be nice to keep a few staged sets, all the week, 1 from previous month, year';
comment on column movie_files.text                        is 'aka title. "A film title is a valuable intellectual property that needs protection from infringement and unauthorized use". "text" means the same update algorithm triggers work. is 400 enough? It can be changed - NEVER TRUNCATE! In postgresql it''s UTF8, which SQL Server only recently supports and recommends not using. The collation was the default, English_United States.1252. Maybe a dictionary collate?';
comment on column movie_files.file_id                     is 'This is enforced, so truncate this table before loading the staging table.  This one can be truncated without any downstream ties.';
comment on column movie_files.record_deleted              is 'By keeping "deleted" records of movie_files (hopefully deleted), we lose the ability to use the ON CONFLICT clause since a postgres doesn''t support filtered constraints, only filtered indexes. Not sure if MS SQL was the same. But, this complicates the insert.';
comment on column movie_files.type_id                     is 'Type can be what contextually is, like movie, or what it physically is, like mkv or codec or torrented file.';
comment on column movie_files.text_corrected_on_ts_wth_tz is 'Type was corrected, meaning the original type was "video" and we want to label it more specifically "movie", but hopefully in the same tree. This will require thought. Other possibilities exist that would confuse the typing, like going to a whole new hierarchy, or up the tree. And is it corrected or enhanced?';

create trigger trgupd_movie_files before
update
	on
	movie_files for each row execute function public.trgupd_common_columns();

-- update trigger
-- what happened?

-- How do I store multiple copies of same file, different qualities, bitness, sources, lengths, sub titles? how are things like despecialization of star wars movies stored?

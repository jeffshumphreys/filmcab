    drop table stage_for_master.media_files ;

	CREATE TABLE stage_for_master.media_files (
	id int8 NOT NULL GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 NO CYCLE),
	file_id int8 NOT NULL,
	"text" varchar(200) NOT NULL,
	manually_cleaned_title_do_not_overwrite bool NULL,
	autocleaned_title_from_file_name varchar(200) NULL,
	cleaned_title_with_year varchar(207) NULL GENERATED ALWAYS AS ((((((text::text || ' '::text) || '('::text) || release_year::text) || ')'::text))) STORED,
	file_name varchar(204) NOT NULL,
	record_version_for_same_name int4 NOT NULL,
	type_id int8 not NULL,
	release_year varchar(4) NULL,
	release_year_from_file_name int4 NULL,
	source_type_tags_from_file_name varchar(20) NULL,
	country_release_tags_from_file_name bpchar(2) NULL,
	spoken_language_tags_from_file_name bpchar(3) NULL,
	uploader_tags_from_file_name varchar(30) NULL,
	encoding_tags_from_file_name varchar(10) NULL,
	genre_tags_from_file_name varchar(20) NULL,
	audio_tags_from_file_name varchar(20) NULL,
	misc_tags_from_file_name _text NULL,
	record_created_on_ts_wth_tz timestamptz NULL DEFAULT clock_timestamp(),
	record_changed_on_ts_wth_tz timestamptz NULL,
	record_deleted bool NULL,
	record_deleted_on_ts_wth_tz timestamptz NULL,
	record_deleted_why varchar(400) NULL,
	text_prev varchar(400) NULL,
	text_corrected bool NULL,
	text_corrected_on_ts_wth_tz timestamptz NULL,
	text_corrected_why INT8 NULL,
    type_prev int8 NULL,
	type_corrected bool NULL,
	type_corrected_on_ts_wth_tz timestamptz NULL,
	type_corrected_why int8 NULL,
	studio_id int8 NULL,
	plays_in_dsktp_vlc bool NULL,
	CONSTRAINT ak_media_files_text_release_year UNIQUE (text, release_year),
	CONSTRAINT ak_media_files_text_version UNIQUE (text, record_version_for_same_name),
	CONSTRAINT media_files_release_year_check CHECK ((((release_year)::bigint IS NULL) OR (((release_year)::bigint >= 1890) AND (((release_year)::bigint)::double precision <= date_part('year'::text, now()))))),
	CONSTRAINT pk_media_files_id PRIMARY KEY (id),
	CONSTRAINT fk_movie_has_file_info FOREIGN KEY (file_id) REFERENCES stage_for_master.files(id) ON DELETE SET null,
	CONSTRAINT fk_movie_is_type FOREIGN KEY (type_id) REFERENCES public.types(id)
);

-- Table Triggers

create trigger trgupd_media_files before
update
    on
    stage_for_master.media_files for each row execute function trgupd_common_columns();
    
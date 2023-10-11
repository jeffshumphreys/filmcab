--select * from stage_for_master.files where text  = 'O:/Video AllInOne/_Police State/Network (1976).mkv'
--select '(' || null|| ')'
select count(*) from filmcab.stage_for_master.files f;
select count(*) from filmcab.stage_for_master.files f where "text" like 'D:/%';
select count(*) from filmcab.stage_for_master.files f where "text" like 'O:/%';
select count(*) from filmcab.stage_for_master.files f where "text" like 'G:/%';
select * from types;
alter table types add constraint fk_parent_type_id foreign key(type_id) references public.types(id) on delete restrict;

-- stage_for_master.video_files definition

-- Drop table

-- DROP TABLE stage_for_master.search_paths;

CREATE TABLE stage_for_master.search_paths (
	id int8 NOT NULL, -- just put a number in, ya doink.
	"text" varchar(400) NOT NULL, -- ex: D:\qBittorrent Downloads\Video\Movies except the backslashes to forward slash.
	type_id int8 not NULL,
	record_created_on_ts_wth_tz timestamptz NULL DEFAULT clock_timestamp(),
	record_changed_on_ts_wth_tz timestamptz NULL,
	record_deleted bool NULL,
	record_deleted_on_ts_wth_tz timestamptz NULL,
	record_deleted_why varchar(400) NULL,
	text_prev varchar(400) NULL,
	text_corrected bool NULL,
	text_corrected_on_ts_wth_tz timestamptz NULL,
	text_corrected_why int8 null,
	type_prev int8 null,
	type_corrected bool NULL,
	type_corrected_on_ts_wth_tz timestamptz NULL,
	type_corrected_why int8 NULL,
	CONSTRAINT ak_search_paths_text UNIQUE (text),
	CONSTRAINT ak_search_paths_id PRIMARY KEY (id),
	CONSTRAINT fk_movie_is_type FOREIGN KEY (type_id) REFERENCES public.types(id)
);

-- Table Triggers

create trigger trgupd_search_paths before
update
    on
    stage_for_master.search_paths for each row execute function trgupd_common_columns();
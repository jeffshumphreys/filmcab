set search_path = stage_for_master, "$user", public; 
drop table if exists public.table_template_for_small_reference;
CREATE TABLE public.table_template_for_small_reference (
	id int8 NOT NULL, -- just put a number in, ya doink.
	"text" varchar(400) NOT NULL, -- ex: D:\qBittorrent Downloads\Video\Movies except the backslashes to forward slash.
	type_id int8 not NULL,
	record_created_on_ts_wth_tz timestamptz not NULL DEFAULT clock_timestamp(),
	record_changed_on_ts_wth_tz timestamptz NULL,
	record_deleted bool null default false check (record_deleted is not true),
	record_deleted_on_ts_wth_tz timestamptz NULL,
	record_deleted_why int8 NULL,
	text_prev varchar(400) NULL,
	text_corrected bool NULL,
	text_corrected_on_ts_wth_tz timestamptz NULL,
	text_corrected_why int8 null,
	type_prev int8 null,
	type_corrected bool NULL,
	type_corrected_on_ts_wth_tz timestamptz NULL,
	type_corrected_why int8 NULL,
	PRIMARY KEY (id),
	UNIQUE  nulls not distinct (text, record_deleted),
	FOREIGN KEY (type_id) REFERENCES public.types(id)
);

COMMENT ON COLUMN public.table_template_for_small_reference.id IS 'For small reference tables we set these values manually';
COMMENT ON COLUMN public.table_template_for_small_reference.type_id IS 'Every object is only ever one type at a time.';
COMMENT ON COLUMN public.table_template_for_small_reference.record_deleted IS 'Set to null if deleted and use NULLS NOT DISTINCT in UNIQUE trick to keep deleted files in same table.';

DROP TABLE quotes;
create table quotes (like table_template_for_small_reference including all, media_file_id int8 references media_files(id));


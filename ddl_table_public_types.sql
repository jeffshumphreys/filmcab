-- public."types" definition

-- Drop table

-- DROP TABLE public."types";

CREATE TABLE public."types" (
	id int8 NOT NULL,
	"text" varchar(200) NOT NULL,
	type_id int8 NULL,
	version_id int8 NULL,
	record_created_on_ts_wth_tz timestamptz NULL DEFAULT clock_timestamp(),
	record_changed_on_ts_wth_tz timestamptz NULL,
	record_deleted bool NULL,
	record_hidden bool NULL,
	text_corrected bool NULL,
	type_corrected bool NULL,
	CONSTRAINT types_pkey PRIMARY KEY (id),
	CONSTRAINT u_type_text UNIQUE (text)
);

-- Table Triggers

create trigger trgupd_types before
update
    on
    public.types for each row execute function trgupd_common_columns();
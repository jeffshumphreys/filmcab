/*
 *                   Master rebuild of filmcat system based on templates that I plan to use in other systems.
 * DO NOT run complete. It's meant to be built in pieces.
 * 
 */
SET search_path = stage_for_master, "$user", public;

CREATE TYPE public.processing_state_enum AS ENUM ('started', 'completed');
ALTER TYPE public.processing_state_enum OWNER TO postgres;

CREATE TYPE public.row_op_enum AS ENUM ('inserted', 'updated');
ALTER TYPE public.row_op_enum OWNER TO postgres;

CREATE TYPE public.source_meta_agg_enum AS ENUM ('imdb', 'tmdb', 'anidb', 'omdb', 'thetvdb', 'movielens', 'wikipedia', 'kaggle', 'eachmovie', 'hydra', 'netflix', 'rottentomatoes', 'bcdb', 'citwf', 'imfdb', 'imcdb');
ALTER TYPE public.source_meta_agg_enum OWNER to postgres;

CREATE TYPE public.source_content_class_enum AS ENUM ('movies', 'series');
ALTER TYPE public.source_content_class_enum OWNER to postgres;
ALTER TYPE public.source_content_class_enum RENAME VALUE 'movie' TO 'do_not_use';
CREATE TYPE public.file_flow_state_enum AS ENUM ('unknown', 'leeching', 'downloaded', 'published', 'backedup');
ALTER TYPE public.file_flow_state_enum OWNER TO postgres;

CREATE TYPE public.source_access_type_enum AS ENUM('dump', 'rest');
ALTER TYPE public.source_access_type_enum OWNER to postgres;

-- Should be NO dependencies ON these TEMPLATE TABLES. If INHERITS was used, then there will be a problem. Use LIKE.
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.template_for_docking_tables;

CREATE TABLE public.template_for_docking_tables (
	id                       INT8 NOT NULL GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 CYCLE) PRIMARY KEY,
	record_created_on_ts_wth_tz timestamptz           NOT NULL DEFAULT clock_timestamp()
);
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.template_for_logging_tables;

CREATE TABLE public.template_for_logging_tables (
	id                       INT8 NOT NULL GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 CYCLE) PRIMARY KEY,
	record_created_on_ts_wth_tz timestamptz           NOT NULL DEFAULT clock_timestamp()
);
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.template_for_all_tables;

CREATE TABLE public.template_for_all_tables (
    id                          int8                  NOT NULL PRIMARY KEY,
	txt                         text                  NOT NULL, -- the text
	typ_id                      int8                  NOT NULL,
	record_created_on_ts_wth_tz timestamptz           NOT NULL DEFAULT clock_timestamp(),
	record_changed_on_ts_wth_tz timestamptz               NULL,
	record_deleted              bool                      NULL DEFAULT FALSE CHECK ((record_deleted IS NOT TRUE)),
	record_deleted_on_ts_wth_tz timestamptz               NULL, 
	record_deleted_why          int8                      NULL,
	txt_prev                    varchar(400)              NULL,
	txt_corrected               bool                      NULL,
	txt_corrected_on_ts_wth_tz  timestamptz               NULL,
	txt_corrected_why           int8                      NULL, -- need a why TABLE. why add this?  Nobody will know, just because you know what it is.
	typ_prev                    int8                      NULL, -- insert trigger or update.
	typ_corrected               bool                      NULL,
	typ_corrected_on_ts_wth_tz  timestamptz               NULL,
	typ_corrected_why           int8                      NULL,
	loading_batch_run_id        int8                      NULL, -- need a loading_batch_run table
	row_op                      row_op_enum               NULL,
    row_op_prev                 row_op_enum               NULL,
	UNIQUE NULLS NOT DISTINCT (txt, record_deleted) -- so deleted are marked NULL, allowing for multiples of the same path.
);

ALTER TABLE public.template_for_all_tables ADD FOREIGN KEY (typ_id) REFERENCES public.typs(id) ON DELETE RESTRICT;
ALTER TABLE public.template_for_all_tables ADD UNIQUE NULLS NOT DISTINCT (txt, record_deleted);
ALTER TABLE public.template_for_all_tables ADD CHECK ((record_deleted IS NOT TRUE));
COMMENT ON COLUMN public.template_for_all_tables.typ_id IS 'Every object is only ever one type at a time. That''s a rule I made up to simplify design.';
COMMENT ON COLUMN public.template_for_all_tables.record_deleted IS 'Set to null if deleted and use NULLS NOT UNIQUE trick to keep deleted files in same table. Confusing, yes, but Postgres does not yet support unique constraints with filters, only unique indexes with filters. I''m hoping to use the ON CONFLICT option which only recognizes constraints.';
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.template_for_staging_tables;
CREATE TABLE public.template_for_staging_tables (LIKE public.template_for_all_tables INCLUDING ALL);
ALTER TABLE public.template_for_staging_tables ALTER id SET NOT NULL, ALTER id ADD GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE -9223372036854775808 MAXVALUE 9223372036854775807 START 1 CACHE 1 CYCLE);
COMMENT ON TABLE public.template_for_staging_tables IS 'Staging tables operate differently than master or warehouse tables. They get truncated for one thing.';
COMMENT ON COLUMN public.template_for_staging_tables.id IS 'This needs to keep updating for new until a truncate with restart is run. Stage id'' for now get reset, so joining back from master won''t really work, so we''ll have a think and maybe a separate table the master links back to with perm sequence ids.  It''s just that testing will cause bloat. Note that I don''t see any reason for these to be super keys that are from a master sequence. ';
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.template_for_tracking_tables;
CREATE TABLE public.template_for_tracking_tables (LIKE public.template_for_all_tables INCLUDING ALL);
ALTER TABLE public.template_for_tracking_tables ALTER id SET NOT NULL, ALTER id ADD GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE -9223372036854775808 MAXVALUE 9223372036854775807 START 1 CACHE 1 CYCLE);
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.template_for_small_reference_tables;
CREATE TABLE public.template_for_small_reference_tables (LIKE public.template_for_all_tables INCLUDING ALL);
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.typs; -- Won't work if dependent tables files, media_files_films, tv episodes, etc. ARE still enabled.
CREATE TABLE public.typs (LIKE public.template_for_small_reference_tables INCLUDING CONSTRAINTS);
-- On typ_id, it must support null, since it is a hierarchy and there must be one null at the top.
ALTER TABLE public.typs ALTER typ_id DROP NOT NULL;
ALTER TABLE public.typs ADD PRIMARY KEY (id);
ALTER TABLE public.typs ADD UNIQUE NULLS NOT DISTINCT(txt, record_deleted);
ALTER TABLE public.typs ADD FOREIGN KEY (typ_id) REFERENCES public.typs(id) ON DELETE RESTRICT;

-- Saving and restoring data

--COPY public.types(id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted) TO 'd:\types.csv' WITH HEADER; 
--COPY public.typs(id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted) from 'd:\types.csv' WITH HEADER;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
COPY public.typs(
id                         ,
txt                        ,
typ_id                     ,
record_created_on_ts_wth_tz,
record_changed_on_ts_wth_tz,
record_deleted             ,
record_deleted_on_ts_wth_tz,
record_deleted_why         ,
txt_prev                   ,
txt_corrected              ,
txt_corrected_on_ts_wth_tz ,
txt_corrected_why          ,
typ_prev                   ,
typ_corrected              ,
typ_corrected_on_ts_wth_tz ,
typ_corrected_why          ,
loading_batch_run_id        
) TO 'd:\typs.csv' WITH HEADER;

-- the trigger inherits the schema of its table
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.trgupd_common_columns()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$

BEGIN
    IF (TG_OP = 'INSERT') THEN
        NEW.record_deleted = false;
		--NEW.row_op = 'inserted'
    END IF;

    IF (TG_OP = 'UPDATE') THEN
        NEW.record_changed_on_ts_wth_tz := clock_timestamp();
		--NEW.prev_row_op = OLD.row_op; NEW.row_op = 'updated';
    END IF;
    IF (TG_OP = 'DELETE') THEN
        NEW.record_deleted_on_ts_wth_tz = clock_timestamp();
        NEW.deleted = NULL;
    END IF;
    IF (TG_OP IN('UPDATE')) THEN
        IF (OLD.txt IS DISTINCT FROM NEW.txt) THEN
            NEW.txt_prev = OLD.txt;
            NEW.txt_corrected = true;
            NEW.txt_corrected_on_ts_wth_tz = clock_timestamp();
        END IF;
        IF (OLD.typ_id IS DISTINCT FROM NEW.typ_id) THEN
            NEW.typ_prev = OLD.typ_id;
            NEW.typ_corrected = true;
            NEW.typ_corrected_on_ts_wth_tz = clock_timestamp();
        END IF;

    END IF;
    
    RETURN NEW;
    
END;
$BODY$;

ALTER FUNCTION public.trgupd_common_columns() OWNER TO postgres;

COMMENT ON FUNCTION public.trgupd_common_columns() IS 'Sets the last change date so we can track downstream aggs needing updates, without some replication trick';

CREATE OR REPLACE TRIGGER trgupd_typs_01 BEFORE UPDATE OR DELETE OR INSERT ON public.typs FOR EACH ROW EXECUTE FUNCTION trgupd_common_columns();

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.trgupd_typs()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
-- What a mess!!! These don't work the way intended!!!
DECLARE 
	countOfTypesNewRows integer;
	countOfMastersInNewRows integer;
BEGIN
	raise notice '=operation: % =', TG_OP;
    -- Feeble attempt to prevent broken hierarchies. Works when testing. But how to add a new hierarchy??. Should this be deferred and statement level? Yes?
	SELECT COUNT(*) INTO countOfTypes FROM new_table;
	SELECT COUNT(*) INTO countOfMasters FROM new_table where typ_id IS NULL;

    IF countOfTypes > 0 THEN 
    	IF countOfMasters = 0 THEN
	        RAISE EXCEPTION 'typs:Cannot change public.typs in a way that there is not one null parented typ since this is a type hierarchy.';
    	ELSIF countOfMasters > 1 THEN
	        RAISE EXCEPTION 'typs:Cannot change public.typs in a way that there is more than one null parented typ since this is a type hierarchy.';
	    END IF;
    END IF;
    
   RETURN NULL;
END;
$BODY$;

ALTER FUNCTION public.trgupd_typs() OWNER TO postgres;

CREATE OR REPLACE TRIGGER trgupd_typs_02 
	AFTER UPDATE ON public.typs 
	REFERENCING NEW TABLE as new_table OLD TABLE as old_table 
	FOR EACH STATEMENT 
	EXECUTE PROCEDURE trgupd_typs(); -- Statement level
CREATE OR REPLACE TRIGGER trgupd_typs_03 
	AFTER DELETE ON public.typs -- Not sure this will work if I delete a parent.
	REFERENCING OLD TABLE as old_table 
	FOR EACH STATEMENT 
	EXECUTE PROCEDURE trgupd_typs(); -- Statement level
CREATE OR REPLACE TRIGGER trgupd_typs_04 
	AFTER INSERT ON public.typs 
	REFERENCING NEW TABLE as new_table 
	FOR EACH STATEMENT 
	EXECUTE PROCEDURE trgupd_typs(); -- Statement level

-- Bahhhh!!! This enforcement of a single null needs to occur upon deferral to the commit, not each statement.
ALTER TABLE public.typs DISABLE TRIGGER trgupd_typs_02;
ALTER TABLE public.typs DISABLE TRIGGER trgupd_typs_03;
ALTER TABLE public.typs DISABLE TRIGGER trgupd_typs_04;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

COPY stage_for_master.files(
    id,
    txt,
    base_name,
    final_extension,
    typ_id,
    record_created_on_ts_wth_tz,
    record_changed_on_ts_wth_tz,
    txt_prev,
    txt_corrected,
    txt_corrected_on_ts_wth_tz,
    -- txt_corrected_why,
    -- prev_typ
    -- typ_corrected_why,
    typ_corrected,
    typ_corrected_on_ts_wth_tz,
    file_size,
    file_created_on_ts,
    file_modified_on_ts,
    parent_folder_created_on_ts,
    parent_folder_modified_on_ts,
    file_deleted,
    file_deleted_on_ts_wth_tz,
    file_replaced,
    file_replaced_on_ts_wth_tz,
    file_moved,
    file_moved_where,
    file_moved_on_ts_wth_tz,
    file_lost, 
    file_loss_detected_on_ts_wth_tz,
    last_verified_full_path_present_on_ts_wth_tz,
    file_md5_hash
) TO 'd:\files.csv' WITH HEADER;

ALTER TABLE stage_for_master.files DROP COLUMN id;
ALTER TABLE stage_for_master.files ADD COLUMN id int8 NOT NULL GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 CYCLE) PRIMARY KEY;

DROP TABLE IF EXISTS stage_for_master.fils; -- Won't work if dependent tables files, media_files_films, tv episodes, etc. ARE still enabled.
CREATE TABLE stage_for_master.fils (LIKE public.template_for_staging_tables INCLUDING ALL,
    base_name                                    varchar(200) NOT NULL,
    final_extension                              varchar(5)   NOT NULL,
    file_size                                    int8             NULL,
    file_created_on_ts                           timestamp    NOT NULL,
    file_modified_on_ts                          timestamp    NOT NULL,
    parent_folder_created_on_ts                  timestamp    NOT NULL, -- rename to directory!!!!! consistency hobgoblin!
    parent_folder_modified_on_ts                 timestamp    NOT NULL,
    file_deleted                                 bool         NOT NULL DEFAULT false,
    file_deleted_on_ts_wth_tz                    timestamptz      NULL,
    file_deleted_why                             int8             NULL,
    file_replaced                                bool         NOT NULL DEFAULT false,
    file_replaced_on_ts_wth_tz                   timestamptz      NULL,
    file_moved                                   bool         NOT NULL DEFAULT false,
    file_moved_where                             int8             NULL, -- reference directories
    file_moved_why                               int8             NULL,
    file_moved_on_ts_wth_tz                      timestamptz      NULL,
    file_lost                                    bool         NOT NULL DEFAULT false,
    file_loss_detected_on_ts_wth_tz              timestamptz      NULL,
    last_verified_full_path_present_on_ts_wth_tz timestamptz      NULL,
    file_md5_hash                                bytea        NOT NULL
);
-- On typ_id, it must support null, since it is a hierarchy and there must be one null at the top.
--ALTER TABLE stage_for_master.fils ALTER typ_id DROP NOT NULL;
ALTER TABLE stage_for_master.files ADD FOREIGN KEY (typ_id) REFERENCES public.typs(id) ON DELETE RESTRICT;
ALTER TABLE stage_for_master.files ADD CONSTRAINT files_txt_record_deleted_key UNIQUE NULLS NOT DISTINCT (txt, record_deleted);
ALTER TABLE stage_for_master.files ADD FOREIGN KEY (typ_id) REFERENCES public.typs(id) ON DELETE RESTRICT;
ALTER TABLE stage_for_master.files DROP CONSTRAINT template_for_all_tables_record_deleted_check1;
ALTER TABLE stage_for_master.files ADD CHECK ((record_deleted IS NOT TRUE));
COPY stage_for_master.fils(
    id,
    txt,
    base_name,
    final_extension,
    typ_id,
    record_created_on_ts_wth_tz,
    record_changed_on_ts_wth_tz,
    txt_prev,
    txt_corrected,
    txt_corrected_on_ts_wth_tz,
    -- txt_corrected_why,
    -- prev_typ
    -- typ_corrected_why,
    typ_corrected,
    typ_corrected_on_ts_wth_tz,
    file_size,
    file_created_on_ts,
    file_modified_on_ts,
    parent_folder_created_on_ts,
    parent_folder_modified_on_ts,
    file_deleted,
    file_deleted_on_ts_wth_tz,
    file_replaced,
    file_replaced_on_ts_wth_tz,
    file_moved,
    file_moved_where,
    file_moved_on_ts_wth_tz,
    file_lost, 
    file_loss_detected_on_ts_wth_tz,
    last_verified_full_path_present_on_ts_wth_tz,
    file_md5_hash
) FROM 'd:\files.csv' WITH HEADER;

CREATE OR REPLACE TRIGGER trgupd_fils_01 BEFORE UPDATE OR DELETE OR INSERT ON stage_for_master.fils FOR EACH ROW EXECUTE FUNCTION trgupd_common_columns();
--drop table if exists stage_for_master.files cascade
--alter table stage_for_master.fils rename to files;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS stage_for_master.files_batch_runs_log; -- Won't work if dependent tables files, media_files_films, tv episodes, etc. ARE still enabled.
CREATE TABLE stage_for_master.files_batch_runs_log (
    id                             int8                         NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE -9223372036854775808 MAXVALUE 9223372036854775807 START 1 CACHE 1 CYCLE),
	typ_id                         int8                         NOT NULL,
	processing_state               public.processing_state_enum     NULL, -- ('started', 'completed')
	file_flow_state                public.file_flow_state_enum      NULL, --  ('unknown', 'leeching', 'downloaded', 'published', 'backedup')
	app_name                       varchar(200)                     NULL, -- ex: filmcab.exe. 
	app_path                       varchar(400)                     NULL, -- ex: D:/qt_projects/build-filmcab-Desktop_Qt_6_5_3_MSVC2019_64bit-Debug/debug
	function_declaration           varchar(200)                     NULL, -- ex: void __cdecl ProcessFilesTask::run(void)
	function_name                  varchar(200)                     NULL, -- ex: run
	class_name                     varchar(200)                     NULL, -- ex: ?run@ProcessFilesTask@@QEAAXXZ =>ProcessFilesTask
	source_file_path               varchar(400)                     NULL, -- ex: D:\qt_projects\build-filmcab-Desktop_Qt_6_5_3_MSVC2019_64bit-Debug\debug\../../filmcab/processfilestask.h
	project_path                   varchar(200)                     NULL, -- ex: D:/qt_projects/filmcab/
	code_file_name                 varchar(200)                     NULL, -- ex: want processfiletask.h
	extension_filters			   text[]                           NULL, -- This way we know what was skipped or missed.                         
	search_path                    text                             NULL, -- '{"(408)-589-5842", "(408)-589-58423"}' SELECT ... WHERE '(408)-589-5842' = ANY (phones); how to list?
	source_code_id                 int8                             NULL, -- If I make a source code table. source_codes
	loading_batch_run_id           int8                             NULL,
	source_code_file_hash          bytea                            NULL,
	run_from_exe_hash              bytea                            NULL,
	running_debug_build            bool                             NULL,
	code_file_last_saved           timestamptz                      NULL,
	started_on_ts_wth_tz           timestamptz                      NULL,
	stopped_on_ts_wth_tz           timestamptz                      NULL,   -- null if crashed
	run_duration_in_seconds        int8 GENERATED ALWAYS AS (EXTRACT(SECOND FROM started_on_ts_wth_tz - stopped_on_ts_wth_tz)) STORED,
	processed_at_lst_1_file        bool                             NULL,                            
	processed_at_lst_1_directory   bool                             NULL,                            
	files_added                    int                              NULL,   -- howManyFilesAddedToDatabaseNewly
	files_marked_as_still_there    int                              NULL,   -- howManyFilesDetectedAsBothInDbAndInFS from code.
	files_removed                  int                              NULL,
	directories_created            int                              NULL,
	directories_tested             int                              NULL,
	directories_newly_modified_since_last int                       NULL,
	files_same_name_but_attr_chgnd int                              NULL,
	error_msg                      text                             NULL,
	error_on_line_no               int                              NULL, 
	running_what_debugger          varchar(200)                     NULL -- No idea without a stacktrace, and where the heck can I get a stacktrace??
	-- github check in?
);

--TRUNCATE TABLE stage_for_master.files_batch_runs_log RESTART IDENTITY
ALTER TABLE stage_for_master.files_batch_runs_log ADD FOREIGN KEY (typ_id) REFERENCES public.typs(id) ON DELETE RESTRICT;
	
COMMENT ON COLUMN stage_for_master.files_batch_runs_log.running_what_debugger IS 'No idea without a stacktrace, and where the heck can I get a stacktrace?? So this is null for now. I''ve tried boost, and I cannot generate anything but backtrace_noop libs.';

-- N/A, only the stopped column is updated, and counts. CREATE OR REPLACE TRIGGER trgupd_files_batch_runs_log_01 BEFORE UPDATE OR DELETE OR INSERT ON stage_for_master.files_batch_runs_log FOR EACH ROW EXECUTE FUNCTION trgupd_common_columns();
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS stage_for_master.source_codes; -- Won't work if dependent tables files, media_files_films, tv episodes, etc. ARE still enabled.
CREATE TABLE stage_for_master.files_batch_runs_log (
    id                          int8              NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE -9223372036854775808 MAXVALUE 9223372036854775807 START 1 CACHE 1 CYCLE),
	typ_id                      int8              NOT NULL,

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--TRUNCATE TABLE stage_for_master.directories RESTART IDENTITY;
DROP TABLE IF EXISTS stage_for_master.directories; -- Won't work if dependent tables files, media_files_films, tv episodes, etc. ARE still enabled.
CREATE TABLE stage_for_master.directories (LIKE public.template_for_small_reference_tables INCLUDING ALL,
    prev_directory_created_on_ts_wth_tz             timestamptz        NULL, 
    directory_created_on_ts_wth_tz                  timestamptz    NOT NULL, -- rename to directory!!!!! consistency hobgoblin!
    detected_change_created_dt_on                   timestamptz        NULL,
    prev_directory_modified_on_ts_wth_tz            timestamptz        NULL, 
    directory_modified_on_ts_wth_tz                 timestamptz    NOT NULL, -- tada! helps reduce laborious scanning.
    detected_change_modified_dt_on                  timestamptz        NULL,
    file_names_subject_to_cleanup                   bool,
    file_names_subject_to_refactored_directory      bool,
    file_contents_ever_change                       bool,                    -- not if linked to a torrent.
    directory_explanation                           text,                    -- "These are where qBitTorrent drops the downloaded files when they are complete. Do not modify.", "If you rename it, the video player will lose it's place."
    resides_on_computer_id                          int8
);

ALTER TABLE stage_for_master.directories ADD FOREIGN KEY (typ_id) REFERENCES public.typs(id) ON DELETE RESTRICT;
ALTER TABLE stage_for_master.directories ALTER id SET NOT NULL, ALTER id ADD GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE -9223372036854775808 MAXVALUE 9223372036854775807 START 1 CACHE 1 CYCLE);

COMMENT ON COLUMN stage_for_master.directories.id IS 'TODO: We need to add these into the files table, though I don''t know what value it will have unless I normalize the path out of the txt file path.';
COMMENT ON COLUMN stage_for_master.directories.txt IS 'full path of the directory';
COMMENT ON COLUMN stage_for_master.directories.typ_id IS 'Just directory for now, maybe later spread out into local, remote, OneDrive, network path, url';
COMMENT ON COLUMN stage_for_master.directories.txt_prev IS 'A renamed directory? I doubt it.';
COMMENT ON COLUMN stage_for_master.directories.typ_prev IS 'This will happen when 12 directory shifts down to local drive directory.';
COMMENT ON COLUMN stage_for_master.directories.typ_corrected_why IS 'will equal whys value "shifted down hierarchy"';
COMMENT ON COLUMN stage_for_master.directories.prev_directory_created_on_ts_wth_tz IS 'Could this change??';
COMMENT ON COLUMN stage_for_master.directories.directory_created_on_ts_wth_tz IS 'This is a new directory';
COMMENT ON COLUMN stage_for_master.directories.directory_modified_on_ts_wth_tz IS 'If this increases, then we need to rescan all objects below.';
COMMENT ON COLUMN stage_for_master.directories.file_names_subject_to_cleanup IS 'May not use. This would be set to no for downloaded torrents, yes to the published files, no to backed up files.';
COMMENT ON COLUMN stage_for_master.directories.file_names_subject_to_refactored_directory IS 'Published files get moved around, downloaded files change directory if the category changes.';
COMMENT ON COLUMN stage_for_master.directories.file_contents_ever_change IS 'no for any of these files';
COMMENT ON COLUMN stage_for_master.directories.resides_on_computer_id IS 'Eventually set, and then txt must include in uniqueness.';
COMMENT ON COLUMN stage_for_master.directories.scan_completed_on IS 'If null then it was the scan was interrupted and so when we restart scanning, force this directory to be rescanned.';

-- We had to trunc during design. Not a great idea in prod.TRUNCATE TABLE stage_for_master.directories RESTART IDENTITY;

CREATE OR REPLACE TRIGGER trgupd_directories_01 BEFORE UPDATE OR DELETE OR INSERT ON stage_for_master.directories FOR EACH ROW EXECUTE FUNCTION trgupd_common_columns();
CREATE OR REPLACE TRIGGER trgupd_files_01 BEFORE UPDATE OR DELETE OR INSERT ON stage_for_master.files FOR EACH ROW EXECUTE FUNCTION trgupd_common_columns();
CREATE OR REPLACE TRIGGER trgupd_filebtch_rns_lg_01 BEFORE UPDATE OR DELETE OR INSERT ON stage_for_master.files_batch_runs_log  FOR EACH ROW EXECUTE FUNCTION trgupd_common_columns();
CREATE OR REPLACE TRIGGER trgupd_media_files_01 BEFORE UPDATE OR DELETE OR INSERT ON stage_for_master.media_files  FOR EACH ROW EXECUTE FUNCTION trgupd_common_columns();
CREATE OR REPLACE TRIGGER trgupd_search_paths_01 BEFORE UPDATE OR DELETE OR INSERT ON stage_for_master.search_paths  FOR EACH ROW EXECUTE FUNCTION trgupd_common_columns();
CREATE OR REPLACE TRIGGER trgupd_quotes_01 BEFORE UPDATE OR DELETE OR INSERT ON stage_for_master.quotes FOR EACH ROW EXECUTE FUNCTION trgupd_common_columns();

/*
Video
ID                                       : 1
Format                                   : AVC
Format/Info                              : Advanced Video Codec
Format profile                           : High@L4.1
Format settings                          : CABAC / 4 Ref Frames
Format settings, CABAC                   : Yes
Format settings, Reference frames        : 4 frames
Codec ID                                 : avc1
Codec ID/Info                            : Advanced Video Coding
Duration                                 : 1 h 32 min
Bit rate                                 : 1 150 kb/s
Maximum bit rate                         : 31.2 Mb/s
Width                                    : 1 280 pixels
Height                                   : 534 pixels
Display aspect ratio                     : 2.40:1
Original display aspect ratio            : 2.40:1
Frame rate mode                          : Constant
Frame rate                               : 24.000 FPS
Color space                              : YUV
Chroma subsampling                       : 4:2:0
Bit depth                                : 8 bits
Scan type                                : Progressive
Bits/(Pixel*Frame)                       : 0.070
Stream size                              : 763 MiB (89%)
Writing library                          : x264 core 164 r56 e067ab0
Encoding settings                        : cabac=1 / ref=4 / deblock=1:-1:-1 / analyse=0x3:0x133 / me=umh / subme=9 / psy=1 / psy_rd=1.00:0.15 / mixed_ref=1 / me_range=24 / chroma_me=1 / trellis=2 / 8x8dct=1 / cqm=0 / deadzone=21,11 / fast_pskip=0 / chroma_qp_offset=-3 / threads=17 / lookahead_threads=1 / sliced_threads=0 / nr=0 / decimate=1 / interlaced=0 / bluray_compat=0 / constrained_intra=0 / bframes=3 / b_pyramid=2 / b_adapt=2 / b_bias=0 / direct=3 / weightb=1 / open_gop=0 / weightp=2 / keyint=250 / keyint_min=23 / scenecut=40 / intra_refresh=0 / rc_lookahead=60 / rc=2pass / mbtree=1 / bitrate=1150 / ratetol=1.0 / qcomp=0.60 / qpmin=0 / qpmax=69 / qpstep=4 / cplxblur=20.0 / qblur=0.5 / vbv_maxrate=31250 / vbv_bufsize=31250 / nal_hrd=none / filler=0 / ip_ratio=1.40 / aq=1:1.00
Color range                              : Limited
Color primaries                          : BT.709
Transfer characteristics                 : BT.709
Matrix coefficients                      : BT.709
Codec configuration box                  : avcC

Audio
ID                                       : 2
Format                                   : AAC LC
Format/Info                              : Advanced Audio Codec Low Complexity	
Codec ID                                 : mp4a-40-2
Duration                                 : 1 h 32 min
Source duration                          : 1 h 32 min
Source_Duration_LastFrame                : -11 ms
Bit rate mode                            : Constant
Bit rate                                 : 132 kb/s
Channel(s)                               : 2 channels
Channel layout                           : L R
Sampling rate                            : 48.0 kHz
Frame rate                               : 46.875 FPS (1024 SPF)
Compression mode                         : Lossy
Stream size                              : 86.1 MiB (10%)
Source stream size                       : 86.1 MiB (10%)
Default                                  : Yes
Alternate group                          : 1
*/

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS stage_for_master.media_files CASCADE; 
CREATE TABLE stage_for_master.media_files (LIKE public.template_for_staging_tables INCLUDING COMMENTS INCLUDING DEFAULTS INCLUDING GENERATED ,
	manually_cleaned_txt_do_not_overwrite   bool             NULL,
	autocleaned_txt_from_file_name          varchar(200)     NULL,
	autocleaned_txt_from_filebot            varchar(200)     NULL,
	cleaned_txt_with_year                   varchar(207)     NULL GENERATED ALWAYS AS ((((((txt::text || ' '::text) || '('::text) || release_year::text) || ')'::text))) STORED,
	file_name_no_extension                  varchar(204) NOT NULL,
	tags_extracted_txt                      text[]           NULL,
	parent_folder_name                      varchar(200) NOT NULL,
	tags_extracted_from_parent_folder       text[]           NULL,
	grandparent_folder_name                 varchar(200) NOT NULL,
	tags_extracted_from_gparent_folder      text[]           NULL,
	greatgrandparent_folder_name            varchar(200) NOT NULL,
	tags_extracted_from_ggparent_folder     text[]         NULL, -- Deep enough?
	record_version_for_same_name            int4         NOT NULL,
	release_year                            varchar(4)       NULL,
	release_year_from_file_name             int4             NULL,
	source_type_tags_from_file_name         varchar(20)      NULL,
	country_release_tags_from_file_name     bpchar(2)        NULL,
	spoken_language_tags_from_file_name     bpchar(3)        NULL,
	uploader_tags_from_file_name            varchar(30)      NULL,
	encoding_tags_from_file_name            varchar(10)      NULL,
	genre_tags_from_file_name               varchar(20)      NULL,
	audio_tags_from_file_name               varchar(20)      NULL,
	misc_tags_from_file_name                text[]           NULL,
	base_folder_as_genre                    varchar(50)      NULL,
	language_cd                             CHAR(3)          NULL DEFAULT('eng')
);


ALTER TABLE stage_for_master.media_files ADD FOREIGN KEY (typ_id) REFERENCES public.typs(id) ON DELETE RESTRICT;
ALTER TABLE stage_for_master.media_files ADD PRIMARY KEY (id);
ALTER TABLE stage_for_master.media_files ADD FOREIGN KEY (id) REFERENCES stage_for_master.files(id) ON DELETE RESTRICT;

COMMENT ON COLUMN stage_for_master.media_files.id IS 'This needs to keep updating for new until a truncate with restart is run. Stage id'' for now get reset, so joining back from master won''t really work, so we''ll have a think and maybe a separate table the master links back to with perm sequence ids.  It''s just that testing will cause bloat. Note that I don''t see any reason for these to be super keys that are from a master sequence.';
COMMENT ON COLUMN stage_for_master.media_files.txt IS 'A copy of txt from files, not the title, since we don''t know for sure what that is yet.';
COMMENT ON COLUMN stage_for_master.media_files.typ_id IS 'video, movie, episode, series, season?';
COMMENT ON COLUMN stage_for_master.media_files.cleaned_txt_with_year IS 'Generated, and this should be unique, unless multiple versions editions of the file, director''s cut, etc.';

CREATE OR REPLACE TRIGGER trgupd_media_files_01 BEFORE UPDATE OR DELETE OR INSERT ON stage_for_master.media_files FOR EACH ROW EXECUTE FUNCTION trgupd_common_columns();
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS receiving_dock.works_from_manually_pop_spreadsheets CASCADE; 
CREATE TABLE receiving_dock.works_from_manually_pop_spreadsheets (LIKE public.template_for_staging_tables INCLUDING COMMENTS INCLUDING DEFAULTS INCLUDING GENERATED ,
	content_source_id                       int8 NOT NULL, -- FOREIGN KEY REFERENCES (Keep, Memory, IMDB Watch List, IMDB Ratings? Or is this just yet again type?)
	seen                                    char(1) NOT NULL DEFAULT (' '), -- ?, x, space. x means I saw it.
    imdb_type_of_media                      text NOT NULL, -- Movie, TV Series, TV Mini-Series, TV Movie, Movie about..., Short, Webcast, Video Game, TV Show, Podcast Series, Video, TV Short
    imdb_genres_and_format_and_subject      text[] NULL,
    imdb_id                                 text,
    imdb_list_entry_created_on              date,
    imdb_list_entry_modified_on             date,
    imdb_year_released                      int2,
    imdb_rating                             decimal(3,1),
    imdb_runtime_in_minutes                 int2,
    imdb_votes                              int4,
    imdb_released_on                        date,
    imdb_directors                          text[],
    imdb_my_rating                          int2,
    imdb_date_i_rated                       date,
    imported_from_spreadsheet_on            timestamptz,
    imported_from_spreadsheet_path          text,
    imported_from_spreadsheet_dated         timestamptz
    
    
);


ALTER TABLE receiving_dock.media_files ADD FOREIGN KEY (typ_id) REFERENCES public.typs(id) ON DELETE RESTRICT;
ALTER TABLE receiving_dock.media_files ADD PRIMARY KEY (id);
ALTER TABLE receiving_dock.media_files ADD FOREIGN KEY (id) REFERENCES receiving_dock.files(id) ON DELETE RESTRICT;

COMMENT ON COLUMN receiving_dock.media_files.id IS 'This needs to keep updating for new until a truncate with restart is run. Stage id'' for now get reset, so joining back from master won''t really work, so we''ll have a think and maybe a separate table the master links back to with perm sequence ids.  It''s just that testing will cause bloat. Note that I don''t see any reason for these to be super keys that are from a master sequence.';
COMMENT ON COLUMN receiving_dock.media_files.txt IS 'A copy of txt from files, not the title, since we don''t know for sure what that is yet.';
COMMENT ON COLUMN receiving_dock.media_files.typ_id IS 'video, movie, episode, series, season?';
COMMENT ON COLUMN receiving_dock.media_files.cleaned_txt_with_year IS 'Generated, and this should be unique, unless multiple versions editions of the file, director''s cut, etc.';

CREATE OR REPLACE TRIGGER trgupd_media_files_01 BEFORE UPDATE OR DELETE OR INSERT ON receiving_dock.media_files FOR EACH ROW EXECUTE FUNCTION trgupd_common_columns();

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS receiving_dock.all_my_keep_and_imdb_lists;

CREATE TABLE receiving_dock.all_my_keep_and_imdb_lists (LIKE public.template_for_docking_tables INCLUDING ALL,
    seen                     TEXT,
    have                     TEXT,
	manually_corrected_title TEXT NOT NULL CHECK (trim(manually_corrected_title) = manually_corrected_title),
	genres_csv_list	         TEXT,
	ended_with_right_paren   TEXT,
	type_of_media            TEXT,
	source_of_item           TEXT,
	who_csv_list             TEXT,
	aka_slsh_list            TEXT,
	characters_csv_list      TEXT,
	video_wrapper            TEXT, -- MST3K, RiffTrax, ...
	series_in                TEXT,
	imdb_id                  TEXT,
	imdb_added_to_list_on    TEXT,
	imdb_changed_on_list_on  TEXT,
	release_year             TEXT,
	imdb_rating              TEXT,
	runtime_in_minutes       TEXT,
	votes                    TEXT,
	released_on              TEXT,
	directors_csv_list       TEXT,
	imdb_my_rating           TEXT,
	imdb_my_rating_made_on   TEXT,
	date_watched             TEXT,
	last_save_time           TEXT,
	creation_date            TEXT,
    hash_of_all_columns text GENERATED ALWAYS AS(encode(sha256((
    	COALESCE(seen                     , 'null') ||
    	COALESCE(have                     , 'null') ||
		COALESCE(manually_corrected_title , 'null') ||
		COALESCE(genres_csv_list          , 'null') ||
		COALESCE(ended_with_right_paren   , 'null') ||
		COALESCE(type_of_media            , 'null') ||
		COALESCE(source_of_item           , 'null') ||
		COALESCE(who_csv_list             , 'null') ||
		COALESCE(aka_slsh_list            , 'null') ||
		COALESCE(characters_csv_list      , 'null') ||
		COALESCE(video_wrapper            , 'null') ||
		COALESCE(series_in                , 'null') ||
		COALESCE(imdb_id                  , 'null') ||
		COALESCE(imdb_added_to_list_on    , 'null') ||
		COALESCE(imdb_changed_on_list_on  , 'null') ||
		COALESCE(release_year             , 'null') ||
		COALESCE(imdb_rating              , 'null') ||
		COALESCE(runtime_in_minutes       , 'null') ||
		COALESCE(votes                    , 'null') ||
		COALESCE(released_on              , 'null') ||
		COALESCE(directors_csv_list       , 'null') ||
		COALESCE(imdb_my_rating           , 'null') ||
		COALESCE(imdb_my_rating_made_on   , 'null') ||  
		COALESCE(date_watched             , 'null') || 
		COALESCE(last_save_time           , 'null') ||  
		COALESCE(creation_date            , 'null')   
		)
    	::bytea
    	), 'hex')) STORED
    	, dictionary_sortable_title TEXT
    	, record_added_on  timestamptz default clock_timestamp()
    	, CONSTRAINT ak_hash_of_all_columns UNIQUE(hash_of_all_columns)
    	, CONSTRAINT ak_title_release_year UNIQUE(manually_corrected_title)
    	
    );

/*
# Install-module PSExcel
import-module psexcel
$AssemblyFile = (get-childitem $env:windir\assembly -Recurse Microsoft.Office.Interop.Excel.dll | Select-Object -first 1).FullName
Add-Type -Path $AssemblyFile
$MicrosoftOfficeInteropExcelXlFileFormatxlCSVUTF8 = 62
$inpath = "D:\qt_projects\filmcab\All the Videos.xlsx"
$outpath = "D:\qt_projects\filmcab\All the Videos.UTF8.csv"
$Excel = New-Object -ComObject Excel.Application
$Excel.Visible = $false
$Excel.DisplayAlerts = $false
$wb = $Excel.Workbooks.Open($inpath)
$sheet = $wb.Worksheets[1]
try {
    $sheet.SaveAs($outpath, $MicrosoftOfficeInteropExcelXlFileFormatxlCSVUTF8) # https://learn.microsoft.com/en-us/office/vba/api/excel.xlfileformat
}
catch {
    # Failed make sure and close
}
$wb = $Excel.Workbooks.Close()
$Excel.Quit()

<#
    Issues:
    - Locked files
    - Blocking after creating and trying to replace

#> 
 */   
 ;

 TRUNCATE TABLE receiving_dock.all_my_keep_and_imdb_lists RESTART IDENTITY;
 COPY receiving_dock.all_my_keep_and_imdb_lists(
  seen                    ,
  have                    ,
  manually_corrected_title,
  genres_csv_list         ,
  ended_with_right_paren  ,
  type_of_media           ,
  source_of_item          ,
  who_csv_list            ,
  aka_slsh_list           ,
  characters_csv_list     ,
  video_wrapper           ,
  series_in               ,
  imdb_id                 ,
  imdb_added_to_list_on   ,
  imdb_changed_on_list_on ,
  release_year            ,
  imdb_rating             ,
  runtime_in_minutes      ,
  votes                   ,
  released_on             ,
  directors_csv_list      ,
  imdb_my_rating          ,
  imdb_my_rating_made_on  ,
  date_watched            ,
  last_save_time          ,
  creation_date
  )
 FROM 'D:\qt_projects\filmcab\all_my_keep_and_imdb_lists.UTF8.csv' CSV HEADER; -- 4,621 rows.
-- TODO: add to files table. import maybe since source may well be deleted.
 
/*how many*/SELECT count(*) FROM receiving_dock.all_my_keep_and_imdb_lists;
/* Browse */SELECT * FROM receiving_dock.all_my_keep_and_imdb_lists order by 4;
/* Look for titles that don't follow my uniquifying title+releaseyear */SELECT * FROM receiving_dock.all_my_keep_and_imdb_lists where right(manually_corrected_title, 1) <> ')' and type_of_media <> 'Movie about…';
/* Look for double spaces in title */SELECT 'x' || replace(manually_corrected_title, ' ', '?') || 'x' FROM receiving_dock.all_my_keep_and_imdb_lists where manually_corrected_title like '%  %';
/* Look for untrimmed titles */SELECT * FROM receiving_dock.all_my_keep_and_imdb_lists where trim(manually_corrected_title) <> manually_corrected_title;
SELECT * FROM receiving_dock.all_my_keep_and_imdb_lists as v where manually_corrected_title like '%''%';

SELECT manually_corrected_title, unaccent(manually_corrected_title)  FROM receiving_dock.all_my_keep_and_imdb_lists where manually_corrected_title <> unaccent(manually_corrected_title);
SELECT * FROM receiving_dock.all_my_keep_and_imdb_lists as v where regexp_match(manually_corrected_title, '\((\d\d\d\d)\)') is null and type_of_media <> 'Movie about…' and not regexp_like(manually_corrected_title, '\(pending\)');
SELECT manually_corrected_title, (regexp_match(manually_corrected_title, '\((\d\d\d\d)\)')::numeric[])[1] FROM receiving_dock.all_my_keep_and_imdb_lists as v where regexp_match(manually_corrected_title, '\((\d\d\d\d)\)') is not null and type_of_media <> 'Movie about…' and not regexp_like(manually_corrected_title, '\(pending\)')
and (regexp_match(manually_corrected_title, '\((\d\d\d\d)\)')::numeric[])[1] not between 1900 and 2026;
SELECT manually_corrected_title, (regexp_match(manually_corrected_title, '\((\d\d\d\d)\)')::numeric[])[1] FROM receiving_dock.all_my_keep_and_imdb_lists as v where regexp_count(manually_corrected_title, '\((\d\d\d\d)\)') > 1;
CREATE EXTENSION unaccent;
select pg_client_encoding();
select ascii('’'), ascii('‘'), ascii('‑)') /* odd hyphen */;
select replace('A Mother''s Son (2012)', '''', '’'); -- A Mother’s Son (2012)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS receiving_dock.path_processing_instructions;
CREATE TABLE receiving_dock.path_processing_instructions (LIKE public.template_for_all_tables INCLUDING ALL,
	-- txt = name: 
    address_format enum (file, url, db_table),
	files_renamable  boolean,
	exposed_to_users boolean,
	path_to_process  text,
	extensions_contained text[],
	sequence_in_file_movement int,
	description_of_function text
);
ALTER TABLE receiving_dock.path_processing_instructions ALTER id SET NOT NULL, ALTER id ADD GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE -9223372036854775808 MAXVALUE 9223372036854775807 START 1 CACHE 1 CYCLE);

INSERT INTO receiving_dock.path_processing_instructions(sequence_in_file_movement, txt, typ_id, files_renamable, exposed_to_users, path_to_process, extensions_contained)
VALUES (1, 'incomplete downloading torrent files', 28, false, false, 'D:\qBittorrent Downloads\temp', '{*.!qB, *.parts}' );

INSERT INTO receiving_dock.path_processing_instructions(sequence_in_file_movement, txt, typ_id, files_renamable, exposed_to_users, path_to_process, extensions_contained)
VALUES (2, 'torrents actively downloading', 27, false, false, 'D:\qBittorrent Downloads\_torrent files', '{*.torrent}' );

INSERT INTO receiving_dock.path_processing_instructions(sequence_in_file_movement, txt, typ_id, files_renamable, exposed_to_users, path_to_process, extensions_contained)
VALUES (3, 'torrents finished downloading', 27, false, false, 'D:\qBittorrent Downloads\_finished_download_torrent_files', '{*.torrent}' );

INSERT INTO receiving_dock.path_processing_instructions(sequence_in_file_movement, txt, typ_id, files_renamable, exposed_to_users, path_to_process, extensions_contained)
VALUES (4, 'video torrent packages finished downloading', 7, false, false, 'D:\qBittorrent Downloads\Video', '{*.avi,*.f4v,*.flv,*.idx,*.mkv,*.mov,*.mp4,*.mpg,*.ogv,*.srt,*.sub,*.vob,*.webm,*.wmv}' );

INSERT INTO receiving_dock.path_processing_instructions(sequence_in_file_movement, txt, typ_id, files_renamable, exposed_to_users, path_to_process, extensions_contained)
VALUES (5, 'published video files for watching', 7, true, true, 'O:\Video AllInOne', '{*.avi,*.f4v,*.flv,*.idx,*.mkv,*.mov,*.mp4,*.mpg,*.ogv,*.srt,*.sub,*.vob,*.webm,*.wmv}' );

INSERT INTO receiving_dock.path_processing_instructions(sequence_in_file_movement, txt, typ_id, files_renamable, exposed_to_users, path_to_process, extensions_contained)
VALUES (6, 'backups of published video files for watching', 7, true, false, 'G:\Video AllInOne Backup', '{*.avi,*.f4v,*.flv,*.idx,*.mkv,*.mov,*.mp4,*.mpg,*.ogv,*.srt,*.sub,*.vob,*.webm,*.wmv}' );

select * FROM receiving_dock.path_processing_instructions ppi ;
/*
 *      https://www.kaggle.com/datasets/asaniczka/tmdb-movies-dataset-2023-930k-movies
 *      https://www.kaggle.com/datasets/asaniczka/tmdb-movies-dataset-2023-930k-movies/download?datasetVersionNumber=36
 *      N:\Video AllInOne Metadata\tmdb\archive.Full TMDB Movies Dataset 2023 (930K Movies).zip
 *           TMDB_movie_dataset_v11.csv
 *      N:\Video AllInOne Metadata\tmdb\movies (movie_[n]n.json)
 * 	    filmcab.receiving_dock.json_data
 *      filmcab.receiving_dock.json_data_expanded
 *      filmcab.receiving_dock.raw_works
 *      filmcab.receiving_dock.works
 *      filmcab.receiving_dock.sourced_metadata (keep scoring separate and linked to works, one to many)
 */ 
SELECT * FROM receiving_dock.path_processing_instructions;
ALTER TABLE receiving_dock.path_processing_instructions ADD COLUMN set_stored_typ_to INT8;
ALTER TABLE receiving_dock.path_processing_instructions ADD CONSTRAINT fk_pth_proc_inst_typ FOREIGN KEY(set_stored_typ_to) REFERENCES public.typs(id);
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS receiving_dock.path_processing_flows;
drop table receiving_dock.file_processing_flows;
CREATE TABLE receiving_dock.path_processing_flows(LIKE public.template_for_small_reference_tables INCLUDING ALL,
	description TEXT,
	program_to_process TEXT
);
INSERT INTO receiving_dock.path_processing_flows(id, txt, typ_id, description, program_to_process)
VALUES(1, 'scan folders and pull file details into database', 29 /* process.flow */, 'keeps the files table up-to-date as to what files are downloaded, what are published, which are backedup.', 'filer.exe');
update receiving_dock.path_processing_flows set program_to_process = 'filer.exe';
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS receiving_dock.path_processing_flow_steps;
CREATE TABLE receiving_dock.path_processing_flow_steps(LIKE public.template_for_small_reference_tables INCLUDING ALL,
      path_processing_flow_id int8 NOT NULL REFERENCES receiving_dock.path_processing_flows(id),
      sequence_of_processing_steps int,
      path_processing_instructions_id int8 REFERENCES  receiving_dock.path_processing_instructions(id),
      action_code TEXT -- scan, etc.
);      
INSERT INTO receiving_dock.path_processing_flow_steps(id, txt, typ_id, path_processing_flow_id, sequence_of_processing_steps, path_processing_instructions_id, action_code)
VALUES(1, 'scan in downloaded torrent packages', 30 /*process.flow.step*/, 1, 1, 4, 'scan');
INSERT INTO receiving_dock.path_processing_flow_steps(id, txt, typ_id, path_processing_flow_id, sequence_of_processing_steps, path_processing_instructions_id, action_code)
VALUES(2, 'scan in published and clean name media', 30 /*process.flow.step*/, 1, 2, 5, 'scan');
INSERT INTO receiving_dock.path_processing_flow_steps(id, txt, typ_id, path_processing_flow_id, sequence_of_processing_steps, path_processing_instructions_id, action_code)
VALUES(3, 'scan in backed up media', 30 /*process.flow.step*/, 1, 3, 8, 'scan');

DROP VIEW IF EXISTS receiving_dock.flow_step_work;
CREATE OR REPLACE VIEW receiving_dock.flow_step_work AS
select 
    f.id flow_id,
    s.id step_id,
    ppi.id instruction_id,
	f.txt flow_name, 
	s.txt step_name, 
	s.action_code,
	ppi.path_to_process,
	f.program_to_process,
	ppi.set_stored_typ_to 
from receiving_dock.path_processing_flows f join receiving_dock.path_processing_flow_steps s on f.id = s.path_processing_flow_id  
join receiving_dock.path_processing_instructions ppi on s.path_processing_instructions_id = ppi.id
order by s.sequence_of_processing_steps;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS receiving_dock.content_sources;
CREATE TABLE receiving_dock.content_sources (LIKE public.template_for_all_tables INCLUDING ALL,
	-- txt is url or file path?
	url_downloaded_from             TEXT,                              -- https://www.kaggle.com/datasets/edgartanaka1/tmdb-movies-and-series/download?datasetVersionNumber=1
	sourced_remote                  TEXT,                              -- https://www.themoviedb.org/
	expanded_to_local_folder        TEXT,                              -- N:\Video AllInOne Metadata\tmdb
	expanded_to_local_folder_on     DATE, 
	source_meta_agg                 source_meta_agg_enum,
	source_content_class            source_content_class_enum,
	downloaded_file_name            TEXT,                              -- archive.zip
	unzipped_folder                 TEXT,                              -- movies\movies
	downloaded_file_name_renamed_to TEXT,
    extracted_to_remote_on          DATE,
    how_many_rows_recvd             INT8,
    cleaned_by_remote_creator       BOOLEAN,
    anthology_gathering_site        TEXT, -- Kaggle, etc.
    source_access_type              source_access_type_enum,
    source_gatherer                 TEXT,  -- Edgar Tanaka
    file_name_format                TEXT, -- movie_[n]n.json
    landed_in_table                 TEXT,  -- filmcab.receiving_dock.json_data
    attributes_provided             TEXT[] -- title, imdb_tt_id, original_title, descrption, tagline, genres, production_status, released, runtime, budget, revenue, voting, original_language, posters
);

INSERT INTO receiving_dock.content_sources
(id, txt, typ_id
, url_downloaded_from
, sourced_remote
, expanded_to_local_folder
, expanded_to_local_folder_on
, source_meta_agg
, source_content_class
, downloaded_file_name
, unzipped_folder
, downloaded_file_name_renamed_to
, extracted_to_remote_on
, how_many_rows_recvd
, cleaned_by_remote_creator
, anthology_gathering_site
, source_access_type
, source_gatherer
, file_name_format
, landed_in_table
, attributes_provided
)
VALUES(
  1
, 'tmdb movies (kaggle), Edgar Tanaka, 526611 movies exported from api'                                -- txt
, 23 -- typ_id
, 'https://www.kaggle.com/datasets/edgartanaka1/tmdb-movies-and-series/download?datasetVersionNumber=1' -- url_downloaded_from
, 'https://www.themoviedb.org/'                                                                         -- sourced_remote
, 'N:\Video AllInOne Metadata\tmdb'                                                                     -- expanded_to_local_folder
, to_date('10/30/2023', 'MM/DD/YYYY')                                                                   -- expanded_to_local_folder_on
, 'tmdb'                                                                                                -- source_meta_agg
, 'movies'                                                                                              -- source_content_class 
, 'archive.zip'                                                                                         -- downloaded_file_name
, 'movies\movies'                                                                                       -- unzipped_folder
, 'archive.500000.movies.zip'                                                                           -- downloaded_file_name_renamed_to
, to_date('2020-07-05', 'YYYY-MM-DD')                                                                   -- extracted_to_remote_on
, 526611                                                                                                -- how_many_rows_recvd  
, null                                                                                                  -- cleaned_by_remote_creator
, 'kaggle'                                                                                              -- anthology gathering_site
, 'dump'                                                                                                -- source_access_type
, 'Edgar Tanaka'                                                                                        -- source_gatherer
, 'movie_[n]n.json'                                                                                     -- file_name_format
, 'filmcab.receiving_dock.json_data'                                                                    -- landed_in_table
, '{title, imdb_tt_id, original_title, descrption, tagline, genres, production_status, released, runtime, budget, revenue, voting, original_language, posters}' -- attributes_provided
)
, (
  2
, 'tmdb tv series (kaggle), Edgar Tanaka, 93716 tv series exported from api'                                -- txt
, 23 -- typ_id
, 'https://www.kaggle.com/datasets/edgartanaka1/tmdb-movies-and-series/download?datasetVersionNumber=1' -- url_downloaded_from
, 'https://www.themoviedb.org/'                                                                         -- sourced_remote
, 'N:\Video AllInOne Metadata\tmdb'                                                                     -- expanded_to_local_folder
, to_date('10/30/2023', 'MM/DD/YYYY')                                                                   -- expanded_to_local_folder_on
, 'tmdb'                                                                                                -- source_meta_agg
, 'series'                                                                                              -- source_content_class 
, 'archive.zip'                                                                                         -- downloaded_file_name
, 'series\series'                                                                                       -- unzipped_folder
, 'archive.500000.movies.zip'                                                                           -- downloaded_file_name_renamed_to
, to_date('2020-07-05', 'YYYY-MM-DD')                                                                   -- extracted_to_remote_on
, 93716                                                                                                -- how_many_rows_recvd  
, null                                                                                                  -- cleaned_by_remote_creator
, 'kaggle'                                                                                              -- anthology gathering_site
, 'dump'                                                                                                -- source_access_type
, 'Edgar Tanaka'                                                                                        -- source_gatherer
, 'series_[n]n.json'                                                                                     -- file_name_format
, 'filmcab.receiving_dock.json_data'                                                                    -- landed_in_table
, '{series_name, original_name
    , in_production, next_episode_to_air, first_air_date, last_air_date, last_episode_to_air, number_of_episodes
    , episode_run_time
    , number_of_seasons, languages, origin_country, networks, seasons, series_type, created_by               
}' -- attributes_provided
)
;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE IF EXISTS receiving_dock.json_data;
CREATE TABLE receiving_dock.json_data(LIKE public.template_for_docking_tables INCLUDING ALL,
            source_meta_agg          source_meta_agg_enum
        ,   source_content_class     source_content_class_enum
        ,   content_source_id        int8 NOT NULL
		,	json_data_as_json_object json
		,   inputpath                text unique
		,   record_added_on          timestamptz default clock_timestamp()	
		);
select count(*) FROM receiving_dock.json_data;
select * from receiving_dock.json_data jt limit 10;
select source_meta_agg, source_content_class, count(*) from receiving_dock.json_data jd group by source_meta_agg, source_content_class;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS receiving_dock.json_data_expanded;
CREATE TABLE receiving_dock.json_data_expanded (
    id                                INT8 NOT NULL GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1 CYCLE) PRIMARY KEY,
    source_meta_agg                   source_meta_agg_enum,
    source_content_class              source_content_class_enum,
    content_source_id                 int8 NOT NULL,
	imdb_id_no                        TEXT UNIQUE,                        
	imdb_tt_id                        TEXT,                        
	title                             TEXT,                             
	original_title                    TEXT,                    
	description                       TEXT,                       
	tagline                           TEXT,                           
	genres                            JSON,
	genres_arr                        TEXT[],
	production_companies                JSON,          -- BBC
	production_companies_arr          TEXT[],              
	production_countries                JSON,
	production_countries_arr          TEXT[],
	spoken_languages                    JSON,
	spoken_languages_arr              TEXT[],
	production_status                 TEXT,               -- for series, 'Ended', 'Returning Series'
	released_on                       TEXT,                       
	runtime_in_minutes                TEXT,                
	budget                            TEXT,                            
	revenue                           TEXT,                           
	popularity                        TEXT,
	vote_count                        TEXT,
	vote_average                      TEXT,                      
	homepage                          TEXT,                          
	original_language                 TEXT,               -- en  
	poster_path                       TEXT,                       
	backdrop_path                     TEXT,                     
	belongs_to_collection_id          TEXT,          
	belongs_to_collection_poster_path TEXT, 
	belongs_to_collection_name        TEXT,        
	is_video                          TEXT,                          
	is_adult                          TEXT,
	-- tv
	in_production                     TEXT,  -- true/false           
    next_episode_to_air               TEXT,     
    last_air_date                     TEXT,           
    last_episode_to_air                     JSON, -- Attributes: air_date, episode#, production_code, season_no, show_id, ..........     
    number_of_episodes                TEXT,      
    number_of_seasons                 TEXT,       
    episode_run_time                  TEXT,        
    original_name                     TEXT,           
    languages                               JSON,
    languages_arr                     TEXT[],
    origin_country                    TEXT,          -- GB
    first_air_date                    TEXT,          
    networks                          JSON,
    networks_arr                      TEXT[],
    seasons                                 JSON,
    seasons_arr                       TEXT[],
    series_type                       TEXT,               -- Documentary
    created_by                              JSON,
    created_by_arr                    TEXT[],
    series_name                       TEXT,
    added_on timestamptz default(clock_timestamp())
    )
	;
	INSERT INTO receiving_dock.json_data_expanded(
			source_meta_agg, source_content_class,
			imdb_id_no, imdb_tt_id, title, original_title, description, tagline, 
			genres, production_companies, production_countries, spoken_languages, 
			production_status, released_on, runtime_in_minutes, 
			budget, revenue, popularity, vote_count, vote_average, homepage, original_language, poster_path, backdrop_path, belongs_to_collection_id, belongs_to_collection_poster_path, belongs_to_collection_name, is_video, is_adult
			-- Following are exclusive to tmdb series
			in_production, next_episode_to_air, last_air_date, last_episode_to_air, number_of_episodes, number_of_seasons, episode_run_time, original_name, languages, origin_country, first_air_date, networks, seasons, series_type, created_by, series_name

	)
	SELECT  -- title, imdb_tt_id, original_title, descrption, tagline, genres, production_status, released, runtime, budget, revenue, voting, original_language, posters
	     source_meta_agg,
	     source_content_class,
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
	     cast(json_data_as_json_object    ->> 'adult' as boolean)                               is_adult,
		 json_data_as_json_object         ->> 'in_production'                                   in_production, 
		 json_data_as_json_object         ->> 'next_episode_to_air'                             next_episode_to_air, 
		 json_data_as_json_object         ->> 'last_air_date'                                   last_air_date, 
		 json_data_as_json_object         ->> 'last_episode_to_air'                             last_episode_to_air, 
		 json_data_as_json_object         ->> 'number_of_episodes'                              number_of_episodes, 
		 json_data_as_json_object         ->> 'number_of_seasons'                               number_of_seasons, 
		 json_data_as_json_object         ->> 'episode_run_time'                                episode_run_time, 
		 json_data_as_json_object         ->> 'original_name'                                   original_name, 
		 json_data_as_json_object         ->> 'languages'                                       languages, 
		 json_data_as_json_object         ->> 'origin_country'                                  origin_country, 
		 json_data_as_json_object         ->> 'first_air_date'                                  first_air_date, 
		 json_data_as_json_object         ->> 'networks'                                        networks, 
		 json_data_as_json_object         ->> 'seasons'                                         seasons, 
		 json_data_as_json_object         ->> 'type'                                            series_type, 
		 json_data_as_json_object         ->> 'created_by'                                      created_by, 
		 json_data_as_json_object         ->> 'name'                                            series_name 
		     
    from receiving_dock.json_data
 ;
	
UPDATE receiving_dock.json_data_expanded a  set source_content_class = 'movies';
UPDATE receiving_dock.json_data_expanded a set genres_arr =   
(
	SELECT array_agg(aa.name) genres_arr from receiving_dock.json_data_expanded b cross join json_array_elements(a.genres) aa(name) where a.id = b.id  group by b.id
) ; 

INSERT INTO receiving_dock.json_data(                     source_meta_agg, source_content_class, inputpath, json_data_as_json_object)                  select 'tmdb', 'movie', 'C:\Users\jeffs\Downloads\movies\movies\movie_100.json',
      pg_read_file('C:\Users\jeffs\Downloads\movies\movies\movie_100.json')::json WHERE NOT EXISTS(SELECT 1 FROM receiving_dock.json_data a WHERE 'C:\Users\jeffs\Downloads\movies\movies\movie_100.json' = a.inputpath)      
    ; 
--production_companies
--spoken_languages
--production_countries

SELECT DISTINCT json_object_keys(json_data_as_json_object) from receiving_dock.json_data; 
SELECT COUNT(*) FROM receiving_dock.json_data jd ;
SELECT COUNT(*) FROM receiving_dock.json_data jd  where source_content_class = 'movies';
SELECT COUNT(*) FROM receiving_dock.json_data jd  where source_content_class = 'series';
SELECT DISTINCT json_object_keys(json_data_as_json_object) from receiving_dock.json_data where source_content_class = 'series'; -- first_air_date, networs, seasons, type, origin_country, langages, original_name, last_air_date, next_episode_to_air, number_of_episodes, number_of_seasons, episode_run_time, in_production 
SELECT DISTINCT json_object_keys(json_data_as_json_object) from receiving_dock.json_data where source_content_class = 'series'
EXCEPT 
SELECT DISTINCT json_object_keys(json_data_as_json_object) from receiving_dock.json_data where source_content_class = 'movies';
select * from pg_extension_objects('unaccent');

DROP TABLE IF EXISTS receiving_dock.search_strings;
CREATE TABLE receiving_dock.search_strings(LIKE public.template_for_docking_tables INCLUDING ALL,
	txt TEXT UNIQUE CHECK (txt <> ''),
	typ_id INT8 NOT NULL REFERENCES public.typs(id),
	applied_against_site text
);
INSERT INTO receiving_dock.search_strings(txt, typ_id, applied_against_site) VALUES('https://archive.org/search?query=%28film%29+AND+-title%3A%28JESUS%29+AND+mediatype%3A%28movies%29&page=3', 31, 'archive.org');
DROP TABLE IF EXISTS receiving_dock.pull_attr_frm_src_log;
CREATE TABLE receiving_dock.pull_attr_frm_src_log(LIKE public.template_for_logging_tables INCLUDING ALL,
    source_row_id          INT8,
    source_datapoint       TEXT,
    source_datapoint_val   TEXT,
	source_row_capt_dt     TIMESTAMPTZ,
    target_row_id          INT8,
	target_table           TEXT,
	target_column          TEXT,
	target_column_orig_val TEXT,
	target_row_dt          TIMESTAMPTZ,
	applied                BOOLEAN NOT NULL        -- if the match was found in the source to the target, is the value available?  If not, then set false and block from new fetch searches for a period
	);
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS receiving_dock.new_tmdb_movie_ids;
CREATE TABLE receiving_dock.new_tmdb_movie_ids(LIKE public.template_for_logging_tables INCLUDING ALL,
new_tmdb_movie_id int NOT NULL UNIQUE,
not_found_in_api_on timestamptz,
pulled_down_json_on timestamptz
);
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS receiving_dock.new_tmdb_person_ids;
CREATE TABLE receiving_dock.new_tmdb_person_ids(LIKE public.template_for_logging_tables INCLUDING ALL,
new_tmdb_person_id int NOT NULL UNIQUE,
not_found_in_api_on timestamptz,
pulled_down_json_on timestamptz
);
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS receiving_dock.new_tmdb_tv_series_ids;
CREATE TABLE receiving_dock.new_tmdb_tv_series_ids(LIKE public.template_for_logging_tables INCLUDING ALL,
new_tmdb_tv_series_id int NOT NULL UNIQUE,
not_found_in_api_on timestamptz,
pulled_down_json_on timestamptz
);
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS receiving_dock.new_tmdb_collection_ids;
CREATE TABLE receiving_dock.new_tmdb_collection_ids(LIKE public.template_for_logging_tables INCLUDING ALL,
new_tmdb_collection_id int NOT NULL UNIQUE,
not_found_in_api_on timestamptz,
pulled_down_json_on timestamptz
);
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS receiving_dock.new_tmdb_tv_network_ids;
CREATE TABLE receiving_dock.new_tmdb_tv_network_ids(LIKE public.template_for_logging_tables INCLUDING ALL,
new_tmdb_tv_network_id int NOT NULL UNIQUE,
not_found_in_api_on timestamptz,
pulled_down_json_on timestamptz
);
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS receiving_dock.new_tmdb_keyword_ids;
CREATE TABLE receiving_dock.new_tmdb_keyword_ids(LIKE public.template_for_logging_tables INCLUDING ALL,
new_tmdb_keyword_id int NOT NULL UNIQUE,
not_found_in_api_on timestamptz,
pulled_down_json_on timestamptz
);
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS receiving_dock.new_tmdb_production_company_ids;
CREATE TABLE receiving_dock.new_tmdb_production_company_ids(LIKE public.template_for_logging_tables INCLUDING ALL,
new_tmdb_production_company_id int NOT NULL UNIQUE,
not_found_in_api_on timestamptz,
pulled_down_json_on timestamptz
);
create table receiving_dock.tmdb_person_data(tmdb_person_id int not null unique);
create table receiving_dock.tmdb_tv_series_data(tmdb_tv_series_id int not null unique);
create table receiving_dock.tmdb_collection_data(tmdb_collection_id int not null unique);
create table receiving_dock.tmdb_production_company_data(tmdb_production_company_id int not null unique);    
create table receiving_dock.tmdb_network_data(tmdb_network_id int not null unique);    
 select * from receiving_dock.tmdb_keyword_data tkd;
 select * from receiving_dock.new_tmdb_keyword_ids ntki order by new_tmdb_keyword_id;
  DROP TABLE IF EXISTS receiving_dock.new_tmdb_tv_network_ids;
  DROP TABLE IF EXISTS receiving_dock.tmdb_network_data;
  DROP TABLE IF EXISTS receiving_dock.tmdb_tv_network_data;
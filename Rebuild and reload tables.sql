/*
 *                   Master rebuild of filmcat system based on templates that I plan to use in other systems.
 * 
 */
SET search_path = stage_for_master, "$user", public;

-- Should be NO dependencies ON these TEMPLATE TABLES. If INHERITS was used, then there will be a problem. Use LIKE.

DROP TABLE IF EXISTS public.template_for_all_tables;

CREATE TABLE public.template_for_all_tables (
    id                          int8                  NOT NULL PRIMARY KEY,
	txt                         varchar(400)          NOT NULL, -- the text
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
	UNIQUE NULLS NOT DISTINCT (txt, record_deleted) -- so deleted are marked NULL, allowing for multiples of the same path.
);

COMMENT ON COLUMN public.template_for_all_tables
COMMENT ON COLUMN public.template_for_all_tables.typ_id IS 'Every object is only ever one type at a time. That''s a rule I made up to simplify design.';
COMMENT ON COLUMN public.template_for_all_tables.record_deleted IS 'Set to null if deleted and use NULLS NOT UNIQUE trick to keep deleted files in same table. Confusing, yes, but Postgres does not yet support unique constraints with filters, only unique indexes with filters. I''m hoping to use the ON CONFLICT option which only recognizes constraints.';
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.template_for_staging_tables;
CREATE TABLE public.template_for_staging_tables (LIKE public.template_for_all_tables INCLUDING ALL);
ALTER TABLE public.template_for_staging_tables ALTER id SET NOT NULL, ALTER id ADD GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE -9223372036854775808 MAXVALUE 9223372036854775807 START 1 CACHE 1 CYCLE);
COMMENT ON TABLE public.template_for_staging_tables IS 'Staging tables operate differently than master or warehouse tables. They get truncated for one thing.';
COMMENT ON COLUMN public.template_for_staging_tables.id IS 'This needs to keep updating for new until a truncate with restart is run. Stage id'' for now get reset, so joining back from master won''t really work, so we''ll have a think and maybe a separate table the master links back to with perm sequence ids.  It''s just that testing will cause bloat. Note that I don''t see any reason for these to be super keys that are from a master sequence. ';
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.template_for_small_reference_tables;
CREATE TABLE public.template_for_small_reference_tables (LIKE public.template_for_all_tables INCLUDING ALL;
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
    IF (TG_OP = 'UPDATE') THEN
        NEW.record_changed_on_ts_wth_tz := clock_timestamp();
    END IF;
    IF (TG_OP = 'DELETE') THEN
        NEW.record_deleted_on_ts_wth_tz = clock_timestamp();
        NEW.deleted = NULL;
    END IF;
    IF (TG_OP IN('UPDATE', 'INSERT')) THEN
        IF (OLD.txt IS DISTINCT FROM NEW.txt) THEN
            NEW.txt_prv = OLD.txt;
            NEW.txt_corrected = true;
            NEW.txt_corrected_on_ts_wth_tz = clock_timestamp();
        END IF;
        IF (OLD.typ_id IS DISTINCT FROM NEW.typ_id) THEN
            NEW.typ_prv = OLD.typ_id;
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
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
ALTER TABLE stage_for_master.fils ADD PRIMARY KEY (id);
ALTER TABLE stage_for_master.fils ADD UNIQUE NULLS NOT DISTINCT(txt, record_deleted);
ALTER TABLE stage_for_master.fils ADD FOREIGN KEY (typ_id) REFERENCES public.typs(id) ON DELETE RESTRICT;

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
CREATE TABLE stage_for_master.files_batch_runs_log (LIKE public.template_for_staging_tables INCLUDING ALL,
	app_name                       varchar(200) NULL, -- ex: filmcab.exe. App_path, too. machine name, cpu, etc.
	class_name                     varchar(200) NULL, -- ex: ProcessFilesTask
	function_name                  varchar(200) NULL, -- ex: run()
	completed                      boolean      null,          -- false if errored? or null if crashed. Though it probably would've rolled back.
	search_paths                   text[], -- '{"(408)-589-5842", "(408)-589-58423"}' SELECT ... WHERE '(408)-589-5842' = ANY (phones); how to list?
	source_code_id                 int8         NULL, -- If I make a source code table.
	stopped_on_ts_wth_tz           timestamptz  null,
	files_added                    int null,
	files_removed                  int null,
	files_marked_as_still_there    int null,
	files_same_name_but_attr_chgnd int null,
	error_msg                      text
	-- github check in?
);

ALTER TABLE stage_for_master.files_batch_runs_log ADD PRIMARY KEY (id);
ALTER TABLE stage_for_master.files_batch_runs_log ADD UNIQUE NULLS NOT DISTINCT(txt, record_deleted);
ALTER TABLE stage_for_master.files_batch_runs_log ADD FOREIGN KEY (typ_id) REFERENCES public.typs(id) ON DELETE RESTRICT;
	
CREATE OR REPLACE TRIGGER trgupd_files_batch_runs_log_01 BEFORE UPDATE OR DELETE OR INSERT ON stage_for_master.files_batch_runs_log FOR EACH ROW EXECUTE FUNCTION trgupd_common_columns();
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--TRUNCATE TABLE stage_for_master.directories RESTART IDENTITY;
DROP TABLE IF EXISTS stage_for_master.directories; -- Won't work if dependent tables files, media_files_films, tv episodes, etc. ARE still enabled.
CREATE TABLE stage_for_master.directories (LIKE public.template_for_small_reference_tables INCLUDING ALL,
    prev_directory_created_on_ts_wth_tz             timestamptz        NULL, 
    directory_created_on_ts_wth_tz                  timestamptz    NOT NULL, -- rename to directory!!!!! consistency hobgoblin!
    detected_change_created_dt_on                   timestamptz        NULL,
    prev_directory_modified_on_ts_wth_tz            timestamptz        NULL, 
    directory_modified_on_ts_wth_tz                 timestamptz    NOT NULL, -- tada! helps reduce laborious scanning.
    detected_change_modified_dt_on                timestamptz        NULL,
    file_names_subject_to_cleanup                   bool,
    file_names_subject_to_refactored_directory      bool,
    file_contents_ever_change                       bool,                    -- not if linked to a torrent.
    directory_explanation                           text,                    -- "These are where qBitTorrent drops the downloaded files when they are complete. Do not modify.", "If you rename it, the video player will lose it's place."
    resides_on_computer_id                          int8
);

ALTER TABLE stage_for_master.directories ADD PRIMARY KEY (id);
ALTER TABLE stage_for_master.directories ADD UNIQUE NULLS NOT DISTINCT(txt, record_deleted); -- Maybe unique with computer and domain. oops! Not scaling.
ALTER TABLE stage_for_master.directories ADD FOREIGN KEY (typ_id) REFERENCES public.typs(id) ON DELETE RESTRICT;
ALTER TABLE stage_for_master.directories ALTER id SET NOT NULL, ALTER id ADD GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE -9223372036854775808 MAXVALUE 9223372036854775807 START 1 CACHE 1 CYCLE);
	
CREATE OR REPLACE TRIGGER trgupd_directories_01 BEFORE UPDATE OR DELETE OR INSERT ON stage_for_master.directories FOR EACH ROW EXECUTE FUNCTION trgupd_common_columns();
-- We had to trunc during design. Not a great idea in prod.TRUNCATE TABLE stage_for_master.directories RESTART IDENTITY;

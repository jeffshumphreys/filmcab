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
	record_created_on_ts_wth_tz timestamptz               NULL DEFAULT clock_timestamp(),
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
id                          ,
txt                         ,
typ_id                      ,
record_created_on_ts_wth_tz ,
record_changed_on_ts_wth_tz ,
record_deleted              ,
record_deleted_on_ts_wth_tz ,
record_deleted_why          ,
txt_prev                    ,
txt_corrected               ,
txt_corrected_on_ts_wth_tz  ,
txt_corrected_why           ,
typ_prev                    ,
typ_corrected               ,
typ_corrected_on_ts_wth_tz  ,
typ_corrected_why           ,
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
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    -- Feeble attempt to prevent broken hierarchies. Works when testing.
    IF (TG_OP IN('UPDATE', 'INSERT')) THEN
        IF NEW.typ_id IS NULL THEN
            IF (SELECT COUNT(*) FROM public.typs WHERE typ_id IS NULL) > 0 THEN 
                RAISE EXCEPTION 'typs:Cannot insert another null parented typ if there is already one, since this is a type hiearchy.';
            END IF;
        ELSE
            IF (SELECT COUNT(*) FROM public.typs WHERE typ_id IS NULL) = 0 THEN 
                RAISE EXCEPTION 'typs:Cannot insert a not null parented typ if there isnt a single parent type id of null, since this is a type hiearchy.';
            END IF;
        END IF;
    ELSEIF (TG_OP IN('DELETE') AND OLD.typ_id IS NULL) THEN
        IF (SELECT COUNT(*) FROM public.typs) > 1 THEN
            RAISE EXCEPTION 'typs:Cannot delete the master null parent typ id until all other records are gone. truncate should work fine.';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$BODY$;

ALTER FUNCTION public.trgupd_typs() OWNER TO postgres;

CREATE OR REPLACE TRIGGER trgupd_typs_02 BEFORE UPDATE OR DELETE OR INSERT ON public.typs FOR EACH ROW EXECUTE FUNCTION trgupd_typs();
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

COPY stage_for_master.files(
    id,
    txt,
    base_name,
    final_extension,
    typ_id ,
    record_created_on_ts_wth_tz ,
    record_changed_on_ts_wth_tz ,
    txt_prev ,
    txt_corrected ,
    txt_corrected_on_ts_wth_tz,
    -- txt_corrected_why,
    -- prev_typ
    -- typ_corrected_why,
    typ_corrected ,
    typ_corrected_on_ts_wth_tz ,
    file_size ,
    file_created_on_ts ,
    file_modified_on_ts ,
    parent_folder_created_on_ts ,
    parent_folder_modified_on_ts ,
    file_deleted ,
    file_deleted_on_ts_wth_tz ,
    file_replaced ,
    file_replaced_on_ts_wth_tz ,
    file_moved ,
    file_moved_where ,
    file_moved_on_ts_wth_tz ,
    file_lost , 
    file_loss_detected_on_ts_wth_tz ,
    last_verified_full_path_present_on_ts_wth_tz ,
    file_md5_hash
) TO 'd:\files.csv' WITH HEADER;

DROP TABLE IF EXISTS stage_for_master.fils; -- Won't work if dependent tables files, media_files_films, tv episodes, etc. ARE still enabled.
CREATE TABLE stage_for_master.fils (LIKE public.template_for_staging_tables INCLUDING ALL,
    base_name varchar(200) NOT NULL,
    final_extension varchar(5) NOT NULL,
    file_size int8 NULL,
    file_created_on_ts timestamp NOT NULL,
    file_modified_on_ts timestamp NOT NULL,
    parent_folder_created_on_ts timestamp NOT NULL,
    parent_folder_modified_on_ts timestamp NOT NULL,
    file_deleted bool NOT NULL DEFAULT false,
    file_deleted_on_ts_wth_tz timestamptz NULL,
    file_deleted_why int8 NULL,
    file_replaced bool NOT NULL DEFAULT false,
    file_replaced_on_ts_wth_tz timestamptz NULL,
    file_moved bool NOT NULL DEFAULT false,
    file_moved_where int8 NULL, -- reference directories
    file_moved_why int8 NULL,
    file_moved_on_ts_wth_tz timestamptz NULL,
    file_lost bool NOT NULL DEFAULT false,
    file_loss_detected_on_ts_wth_tz timestamptz NULL,
    last_verified_full_path_present_on_ts_wth_tz timestamptz NULL,
    file_md5_hash bytea NOT NULL
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
    typ_id ,
    record_created_on_ts_wth_tz ,
    record_changed_on_ts_wth_tz ,
    txt_prev ,
    txt_corrected ,
    txt_corrected_on_ts_wth_tz,
    -- txt_corrected_why,
    -- prev_typ
    -- typ_corrected_why,
    typ_corrected ,
    typ_corrected_on_ts_wth_tz ,
    file_size ,
    file_created_on_ts ,
    file_modified_on_ts ,
    parent_folder_created_on_ts ,
    parent_folder_modified_on_ts ,
    file_deleted ,
    file_deleted_on_ts_wth_tz ,
    file_replaced ,
    file_replaced_on_ts_wth_tz ,
    file_moved ,
    file_moved_where ,
    file_moved_on_ts_wth_tz ,
    file_lost , 
    file_loss_detected_on_ts_wth_tz ,
    last_verified_full_path_present_on_ts_wth_tz ,
    file_md5_hash
) FROM 'd:\files.csv' WITH HEADER;

CREATE OR REPLACE TRIGGER trgupd_fils_01 BEFORE UPDATE OR DELETE OR INSERT ON stage_for_master.fils FOR EACH ROW EXECUTE FUNCTION trgupd_common_columns();
--drop table if exists stage_for_master.files cascade
--alter table stage_for_master.fils rename to files;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS stage_for_master.files_batch_runs_log; -- Won't work if dependent tables files, media_files_films, tv episodes, etc. ARE still enabled.
CREATE TABLE stage_for_master.files_batch_runs_log (LIKE public.template_for_staging_tables INCLUDING ALL,
	app_name varchar(200) NULL, -- ex: filmcab.exe
	class_name varchar(200) NULL, -- ex: ProcessFilesTask
	function_name varchar(200) NULL, -- ex: run()
	completed boolean null, 
	search_paths text[], -- '{"(408)-589-5842", "(408)-589-58423"}' SELECT ... WHERE '(408)-589-5842' = ANY (phones); how to list?
	source_code_id int8 NULL,
	stopped_on_ts_wth_tz timestamptz null,
	files_added int null,
	files_removed int null,
	files_marked_as_still_there int null,
	files_same_name_but_attr_chgnd int null,
	error_msg text
	-- github check in?
);

ALTER TABLE stage_for_master.files_batch_runs_log ADD PRIMARY KEY (id);
ALTER TABLE stage_for_master.files_batch_runs_log ADD UNIQUE NULLS NOT DISTINCT(txt, record_deleted);
ALTER TABLE stage_for_master.files_batch_runs_log ADD FOREIGN KEY (typ_id) REFERENCES public.typs(id) ON DELETE RESTRICT;
	
CREATE OR REPLACE TRIGGER trgupd_files_batch_runs_log_01 BEFORE UPDATE OR DELETE OR INSERT ON stage_for_master.files_batch_runs_log FOR EACH ROW EXECUTE FUNCTION trgupd_common_columns();

-- Table: stage_for_master.files

-- DROP TABLE IF EXISTS stage_for_master.files;

CREATE TABLE IF NOT EXISTS stage_for_master.files
(
    txt character varying(400) COLLATE pg_catalog."default" NOT NULL,
    typ_id bigint NOT NULL,
    record_created_on_ts_wth_tz timestamp with time zone NOT NULL DEFAULT clock_timestamp(),
    record_changed_on_ts_wth_tz timestamp with time zone,
    record_deleted boolean,
    record_deleted_on_ts_wth_tz timestamp with time zone,
    record_deleted_why bigint,
    txt_prev character varying(400) COLLATE pg_catalog."default",
    txt_corrected boolean,
    txt_corrected_on_ts_wth_tz timestamp with time zone,
    txt_corrected_why bigint,
    typ_prev bigint,
    typ_corrected boolean,
    typ_corrected_on_ts_wth_tz timestamp with time zone,
    typ_corrected_why bigint,
    loading_batch_run_id bigint,
    base_name character varying(200) COLLATE pg_catalog."default" NOT NULL,
    final_extension character varying COLLATE pg_catalog."default" NOT NULL,
    file_size bigint,
    file_created_on_ts_wth_tz timestamp with time zone NOT NULL,
    file_modified_on_ts_wth_tz timestamp with time zone NOT NULL,
    parent_directory_created_on_ts_wth_tz timestamp with time zone NOT NULL,
    parent_directory_modified_on_ts_wth_tz timestamp with time zone NOT NULL,
    file_deleted boolean NOT NULL DEFAULT false,
    file_deleted_on_ts_wth_tz timestamp with time zone,
    file_deleted_why bigint,
    file_replaced boolean NOT NULL DEFAULT false,
    file_replaced_on_ts_wth_tz timestamp with time zone,
    file_moved boolean NOT NULL DEFAULT false,
    file_moved_where bigint,
    file_moved_why bigint,
    file_moved_on_ts_wth_tz timestamp with time zone,
    file_lost boolean NOT NULL DEFAULT false,
    file_loss_detected_on_ts_wth_tz timestamp with time zone,
    last_verified_full_path_present_on_ts_wth_tz timestamp with time zone,
    file_md5_hash bytea NOT NULL,
    id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ( CYCLE INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    CONSTRAINT files_pkey PRIMARY KEY (id),
    CONSTRAINT files_txt_record_deleted_key UNIQUE NULLS NOT DISTINCT (txt, record_deleted),
    CONSTRAINT files_typ_id_fkey FOREIGN KEY (typ_id)
        REFERENCES public.typs (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT,
    CONSTRAINT files_record_deleted_check CHECK (record_deleted IS NOT TRUE)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS stage_for_master.files
    OWNER to postgres;

COMMENT ON COLUMN stage_for_master.files.txt
    IS 'The full path with all the fixin''s.  Includes the file name with extension.';

COMMENT ON COLUMN stage_for_master.files.typ_id
    IS 'Like is it a torrent file, a published to user file, a backup file';

COMMENT ON COLUMN stage_for_master.files.record_created_on_ts_wth_tz
    IS 'Please block this in the update common trigger from being updated.';

COMMENT ON COLUMN stage_for_master.files.record_changed_on_ts_wth_tz
    IS 'NEVER set in insert trigger';

COMMENT ON COLUMN stage_for_master.files.txt_corrected
    IS 'As in not changed, the thing represented did not mutate, rather we are correcting a misentry.';

COMMENT ON COLUMN stage_for_master.files.typ_prev
    IS 'previous typ_id, actually';

COMMENT ON COLUMN stage_for_master.files.base_name
    IS 'without the extension';

COMMENT ON COLUMN stage_for_master.files.final_extension
    IS 'like, ".torrent", ".txt", ".mkv".  In torrenting, file names often have multiple periods.';

COMMENT ON COLUMN stage_for_master.files.file_modified_on_ts_wth_tz
    IS 'The file timestamps only go out to milliseconds. So we are taking the system tz.';

-- Trigger: trgupd_files_01

-- DROP TRIGGER IF EXISTS trgupd_files_01 ON stage_for_master.files;

CREATE OR REPLACE TRIGGER trgupd_files_01
    BEFORE INSERT OR DELETE OR UPDATE 
    ON stage_for_master.files
    FOR EACH ROW
    EXECUTE FUNCTION public.trgupd_common_columns();
-- Table: stage_for_master.directories

-- DROP TABLE IF EXISTS stage_for_master.directories;

CREATE TABLE IF NOT EXISTS stage_for_master.directories
(
    id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    txt character varying(400) COLLATE pg_catalog."default" NOT NULL,
    typ_id bigint NOT NULL,
    record_created_on_ts_wth_tz timestamp with time zone NOT NULL DEFAULT clock_timestamp(),
    record_changed_on_ts_wth_tz timestamp with time zone,
    record_deleted boolean DEFAULT false,
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
    row_op_prev row_op_enum,
    row_op row_op_enum,
    loading_batch_run_id bigint,
    processing_state processing_state_enum,
    prev_directory_created_on_ts_wth_tz timestamp with time zone,
    directory_created_on_ts_wth_tz timestamp with time zone NOT NULL,
    detected_change_created_dt_on timestamp with time zone,
    prev_directory_modified_on_ts_wth_tz timestamp with time zone,
    directory_modified_on_ts_wth_tz timestamp with time zone NOT NULL,
    detected_change_modified_dt_on timestamp with time zone,
    file_names_subject_to_cleanup boolean,
    file_names_subject_to_refactored_directory boolean,
    file_contents_ever_change boolean,
    directory_explanation text COLLATE pg_catalog."default",
    resides_on_computer_id bigint,
    scan_started_on timestamp with time zone,
    scan_completed_on timestamp with time zone,
    CONSTRAINT directories_pkey PRIMARY KEY (id),
    CONSTRAINT directories_txt_record_deleted_key UNIQUE NULLS NOT DISTINCT (txt, record_deleted),
    CONSTRAINT directories_typ_id_fkey FOREIGN KEY (typ_id)
        REFERENCES public.typs (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT,
    CONSTRAINT template_for_all_tables_record_deleted_check CHECK (record_deleted IS NOT TRUE)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS stage_for_master.directories
    OWNER to postgres;

COMMENT ON COLUMN stage_for_master.directories.id
    IS 'TODO: We need to add these into the files table';

COMMENT ON COLUMN stage_for_master.directories.txt
    IS 'full path of the directory';

COMMENT ON COLUMN stage_for_master.directories.typ_id
    IS 'Just directory for now, maybe later spread out into local, remote, OneDrive, network path, url';

COMMENT ON COLUMN stage_for_master.directories.txt_prev
    IS 'A renamed directory? I doubt it.';

COMMENT ON COLUMN stage_for_master.directories.typ_prev
    IS 'This will happen when 12 directory shifts down to local drive directory.';

COMMENT ON COLUMN stage_for_master.directories.typ_corrected_why
    IS 'will equal whys value "shifted down hierarchy"';

COMMENT ON COLUMN stage_for_master.directories.prev_directory_created_on_ts_wth_tz
    IS 'Could this change??';

COMMENT ON COLUMN stage_for_master.directories.directory_created_on_ts_wth_tz
    IS 'This is a new directory';

COMMENT ON COLUMN stage_for_master.directories.directory_modified_on_ts_wth_tz
    IS 'If this increases, then we need to rescan all objects below.';

COMMENT ON COLUMN stage_for_master.directories.file_names_subject_to_cleanup
    IS 'May not use. This would be set to no for downloaded torrents, yes to the published files, no to backed up files.';

COMMENT ON COLUMN stage_for_master.directories.file_names_subject_to_refactored_directory
    IS 'Published files get moved around, downloaded files change directory if the category changes.';

COMMENT ON COLUMN stage_for_master.directories.file_contents_ever_change
    IS 'no for any of these files';

COMMENT ON COLUMN stage_for_master.directories.resides_on_computer_id
    IS 'Eventually set, and then txt must include in uniqueness.';

COMMENT ON COLUMN stage_for_master.directories.scan_completed_on
    IS 'If null then it was the scan was interrupted and so when we restart scanning, force this directory to be rescanned.';

-- Trigger: trgupd_directories_01

-- DROP TRIGGER IF EXISTS trgupd_directories_01 ON stage_for_master.directories;

CREATE OR REPLACE TRIGGER trgupd_directories_01
    BEFORE INSERT OR DELETE OR UPDATE 
    ON stage_for_master.directories
    FOR EACH ROW
    EXECUTE FUNCTION public.trgupd_common_columns();
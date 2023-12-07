--
-- PostgreSQL database dump
--

-- Dumped from database version 15.4
-- Dumped by pg_dump version 15.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: receiving_dock; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA receiving_dock;


ALTER SCHEMA receiving_dock OWNER TO postgres;

--
-- Name: shipping_dock; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA shipping_dock;


ALTER SCHEMA shipping_dock OWNER TO postgres;

--
-- Name: stage_for_master; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA stage_for_master;


ALTER SCHEMA stage_for_master OWNER TO postgres;

--
-- Name: adminpack; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS adminpack WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION adminpack; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION adminpack IS 'administrative functions for PostgreSQL';


--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: ltree; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS ltree WITH SCHEMA public;


--
-- Name: EXTENSION ltree; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION ltree IS 'data type for hierarchical tree-like structures';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: tablefunc; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS tablefunc WITH SCHEMA public;


--
-- Name: EXTENSION tablefunc; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION tablefunc IS 'functions that manipulate whole tables, including crosstab';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: file_flow_state_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.file_flow_state_enum AS ENUM (
    'unknown',
    'leeching',
    'downloaded',
    'published',
    'backedup'
);


ALTER TYPE public.file_flow_state_enum OWNER TO postgres;

--
-- Name: processing_state_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.processing_state_enum AS ENUM (
    'started',
    'completed'
);


ALTER TYPE public.processing_state_enum OWNER TO postgres;

--
-- Name: row_op_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.row_op_enum AS ENUM (
    'inserted',
    'updated'
);


ALTER TYPE public.row_op_enum OWNER TO postgres;

--
-- Name: source_access_type_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.source_access_type_enum AS ENUM (
    'dump',
    'rest'
);


ALTER TYPE public.source_access_type_enum OWNER TO postgres;

--
-- Name: source_content_class_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.source_content_class_enum AS ENUM (
    'do_not_use',
    'series',
    'movies'
);


ALTER TYPE public.source_content_class_enum OWNER TO postgres;

--
-- Name: source_meta_agg_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.source_meta_agg_enum AS ENUM (
    'imdb',
    'tmdb',
    'anidb',
    'omdb',
    'thetvdb',
    'movielens',
    'wikipedia',
    'kaggle',
    'eachmovie',
    'hydra',
    'netflix',
    'rottentomatoes',
    'bcdb',
    'citwf',
    'imfdb',
    'imcdb'
);


ALTER TYPE public.source_meta_agg_enum OWNER TO postgres;

--
-- Name: trgupd_common_columns(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trgupd_common_columns() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

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
$$;


ALTER FUNCTION public.trgupd_common_columns() OWNER TO postgres;

--
-- Name: FUNCTION trgupd_common_columns(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.trgupd_common_columns() IS 'Sets the last change date so we can track downstream aggs needing updates, without some replication trick';


--
-- Name: trgupd_typs(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trgupd_typs() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE 
	countOfTypes integer;
	countOfMasters integer;
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
$$;


ALTER FUNCTION public.trgupd_typs() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: gen_id; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.gen_id (
    id bigint NOT NULL
);


ALTER TABLE public.gen_id OWNER TO postgres;

--
-- Name: gen_id_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.gen_id ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.gen_id_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
    CYCLE
);


--
-- Name: id_sequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_sequence OWNER TO postgres;

--
-- Name: SEQUENCE id_sequence; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON SEQUENCE public.id_sequence IS 'all project tables will share this id, some may dup, others like 1 will be everywhere, reused to indicate primal nature of record';


--
-- Name: template_for_all_tables; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.template_for_all_tables (
    id bigint NOT NULL,
    txt text NOT NULL,
    typ_id bigint NOT NULL,
    record_created_on_ts_wth_tz timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    record_changed_on_ts_wth_tz timestamp with time zone,
    record_deleted boolean DEFAULT false,
    record_deleted_on_ts_wth_tz timestamp with time zone,
    record_deleted_why bigint,
    txt_prev character varying(400),
    txt_corrected boolean,
    txt_corrected_on_ts_wth_tz timestamp with time zone,
    txt_corrected_why bigint,
    typ_prev bigint,
    typ_corrected boolean,
    typ_corrected_on_ts_wth_tz timestamp with time zone,
    typ_corrected_why bigint,
    loading_batch_run_id bigint,
    row_op public.row_op_enum,
    row_op_prev public.row_op_enum,
    CONSTRAINT template_for_all_tables_record_deleted_check2 CHECK ((record_deleted IS NOT TRUE)),
    CONSTRAINT template_for_all_tables_record_deleted_check3 CHECK ((record_deleted IS NOT TRUE))
);


ALTER TABLE public.template_for_all_tables OWNER TO postgres;

--
-- Name: template_for_docking_tables; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.template_for_docking_tables (
    id bigint NOT NULL,
    record_created_on_ts_wth_tz timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.template_for_docking_tables OWNER TO postgres;

--
-- Name: template_for_docking_tables_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.template_for_docking_tables ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.template_for_docking_tables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
    CYCLE
);


--
-- Name: template_for_small_reference_tables; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.template_for_small_reference_tables (
    id bigint NOT NULL,
    txt character varying(400) NOT NULL,
    typ_id bigint NOT NULL,
    record_created_on_ts_wth_tz timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    record_changed_on_ts_wth_tz timestamp with time zone,
    record_deleted boolean DEFAULT false,
    record_deleted_on_ts_wth_tz timestamp with time zone,
    record_deleted_why bigint,
    txt_prev character varying(400),
    txt_corrected boolean,
    txt_corrected_on_ts_wth_tz timestamp with time zone,
    txt_corrected_why bigint,
    typ_prev bigint,
    typ_corrected boolean,
    typ_corrected_on_ts_wth_tz timestamp with time zone,
    typ_corrected_why bigint,
    loading_batch_run_id bigint,
    CONSTRAINT template_for_all_tables_record_deleted_check CHECK ((record_deleted IS NOT TRUE))
);


ALTER TABLE public.template_for_small_reference_tables OWNER TO postgres;

--
-- Name: template_for_staging_tables; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.template_for_staging_tables (
    id bigint NOT NULL,
    txt character varying(400) NOT NULL,
    typ_id bigint NOT NULL,
    record_created_on_ts_wth_tz timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    record_changed_on_ts_wth_tz timestamp with time zone,
    record_deleted boolean DEFAULT false,
    record_deleted_on_ts_wth_tz timestamp with time zone,
    record_deleted_why bigint,
    txt_prev character varying(400),
    txt_corrected boolean,
    txt_corrected_on_ts_wth_tz timestamp with time zone,
    txt_corrected_why bigint,
    typ_prev bigint,
    typ_corrected boolean,
    typ_corrected_on_ts_wth_tz timestamp with time zone,
    typ_corrected_why bigint,
    loading_batch_run_id bigint,
    CONSTRAINT template_for_all_tables_record_deleted_check CHECK ((record_deleted IS NOT TRUE))
);


ALTER TABLE public.template_for_staging_tables OWNER TO postgres;

--
-- Name: TABLE template_for_staging_tables; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.template_for_staging_tables IS 'Staging tables operate differently than master or warehouse tables. They get truncated for one thing.';


--
-- Name: COLUMN template_for_staging_tables.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.template_for_staging_tables.id IS 'This needs to keep updating for new until a truncate with restart is run. Stage id'' for now get reset, so joining back from master won''t really work, so we''ll have a think and maybe a separate table the master links back to with perm sequence ids.  It''s just that testing will cause bloat. Note that I don''t see any reason for these to be super keys that are from a master sequence. ';


--
-- Name: template_for_staging_tables_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.template_for_staging_tables ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.template_for_staging_tables_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE -9223372036854775808
    NO MAXVALUE
    CACHE 1
    CYCLE
);


--
-- Name: test_date_diff_gen; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.test_date_diff_gen (
    from_tmstmp timestamp with time zone DEFAULT now(),
    to_tmstmp timestamp with time zone,
    sec_diff bigint GENERATED ALWAYS AS (EXTRACT(second FROM (to_tmstmp - from_tmstmp))) STORED
);


ALTER TABLE public.test_date_diff_gen OWNER TO postgres;

--
-- Name: typs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.typs (
    id bigint NOT NULL,
    txt character varying(400) NOT NULL,
    typ_id bigint,
    record_created_on_ts_wth_tz timestamp with time zone DEFAULT clock_timestamp(),
    record_changed_on_ts_wth_tz timestamp with time zone,
    record_deleted boolean,
    record_deleted_on_ts_wth_tz timestamp with time zone,
    record_deleted_why bigint,
    txt_prev character varying(400),
    txt_corrected boolean,
    txt_corrected_on_ts_wth_tz timestamp with time zone,
    txt_corrected_why bigint,
    typ_prev bigint,
    typ_corrected boolean,
    typ_corrected_on_ts_wth_tz timestamp with time zone,
    typ_corrected_why bigint,
    loading_batch_run_id bigint,
    mapped_to_file_extension text,
    CONSTRAINT template_for_all_tables_record_deleted_check1 CHECK ((record_deleted IS NOT TRUE))
);


ALTER TABLE public.typs OWNER TO postgres;

--
-- Name: all_my_keep_and_imdb_lists; Type: TABLE; Schema: receiving_dock; Owner: postgres
--

CREATE TABLE receiving_dock.all_my_keep_and_imdb_lists (
    id bigint NOT NULL,
    record_created_on_ts_wth_tz timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    seen text,
    have text,
    manually_corrected_title text,
    genres_csv_list text,
    ended_with_right_paren text,
    type_of_media text,
    source_of_item text,
    who_csv_list text,
    aka_slsh_list text,
    characters_csv_list text,
    video_wrapper text,
    series_in text,
    imdb_id text,
    imdb_added_to_list_on text,
    imdb_changed_on_list_on text,
    release_year text,
    imdb_rating text,
    runtime_in_minutes text,
    votes text,
    released_on text,
    directors_csv_list text,
    imdb_my_rating text,
    imdb_my_rating_made_on text,
    date_watched text,
    last_save_time text,
    creation_date text,
    hash_of_all_columns text GENERATED ALWAYS AS (encode(sha256(((((((((((((((((((((((((((COALESCE(seen, 'null'::text) || COALESCE(have, 'null'::text)) || COALESCE(manually_corrected_title, 'null'::text)) || COALESCE(genres_csv_list, 'null'::text)) || COALESCE(ended_with_right_paren, 'null'::text)) || COALESCE(type_of_media, 'null'::text)) || COALESCE(source_of_item, 'null'::text)) || COALESCE(who_csv_list, 'null'::text)) || COALESCE(aka_slsh_list, 'null'::text)) || COALESCE(characters_csv_list, 'null'::text)) || COALESCE(video_wrapper, 'null'::text)) || COALESCE(series_in, 'null'::text)) || COALESCE(imdb_id, 'null'::text)) || COALESCE(imdb_added_to_list_on, 'null'::text)) || COALESCE(imdb_changed_on_list_on, 'null'::text)) || COALESCE(release_year, 'null'::text)) || COALESCE(imdb_rating, 'null'::text)) || COALESCE(runtime_in_minutes, 'null'::text)) || COALESCE(votes, 'null'::text)) || COALESCE(released_on, 'null'::text)) || COALESCE(directors_csv_list, 'null'::text)) || COALESCE(imdb_my_rating, 'null'::text)) || COALESCE(imdb_my_rating_made_on, 'null'::text)) || COALESCE(date_watched, 'null'::text)) || COALESCE(last_save_time, 'null'::text)) || COALESCE(creation_date, 'null'::text)))::bytea), 'hex'::text)) STORED,
    dictionary_sortable_title text,
    record_added_on timestamp with time zone DEFAULT clock_timestamp()
);


ALTER TABLE receiving_dock.all_my_keep_and_imdb_lists OWNER TO postgres;

--
-- Name: all_my_keep_and_imdb_lists_id_seq; Type: SEQUENCE; Schema: receiving_dock; Owner: postgres
--

ALTER TABLE receiving_dock.all_my_keep_and_imdb_lists ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME receiving_dock.all_my_keep_and_imdb_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
    CYCLE
);


--
-- Name: content_sources; Type: TABLE; Schema: receiving_dock; Owner: postgres
--

CREATE TABLE receiving_dock.content_sources (
    id bigint NOT NULL,
    txt text NOT NULL,
    typ_id bigint NOT NULL,
    record_created_on_ts_wth_tz timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    record_changed_on_ts_wth_tz timestamp with time zone,
    record_deleted boolean DEFAULT false,
    record_deleted_on_ts_wth_tz timestamp with time zone,
    record_deleted_why bigint,
    txt_prev character varying(400),
    txt_corrected boolean,
    txt_corrected_on_ts_wth_tz timestamp with time zone,
    txt_corrected_why bigint,
    typ_prev bigint,
    typ_corrected boolean,
    typ_corrected_on_ts_wth_tz timestamp with time zone,
    typ_corrected_why bigint,
    loading_batch_run_id bigint,
    row_op public.row_op_enum,
    row_op_prev public.row_op_enum,
    url_downloaded_from text,
    sourced_remote text,
    expanded_to_local_folder text,
    expanded_to_local_folder_on date,
    source_meta_agg public.source_meta_agg_enum,
    source_content_class public.source_content_class_enum,
    downloaded_file_name text,
    unzipped_folder text,
    downloaded_file_name_renamed_to text,
    extracted_to_remote_on date,
    how_many_rows_recvd bigint,
    cleaned_by_remote_creator boolean,
    anthology_gathering_site text,
    source_access_type public.source_access_type_enum,
    source_gatherer text,
    file_name_format text,
    landed_in_table text,
    attributes_provided text[],
    CONSTRAINT template_for_all_tables_record_deleted_check2 CHECK ((record_deleted IS NOT TRUE)),
    CONSTRAINT template_for_all_tables_record_deleted_check3 CHECK ((record_deleted IS NOT TRUE))
);


ALTER TABLE receiving_dock.content_sources OWNER TO postgres;

--
-- Name: json_data; Type: TABLE; Schema: receiving_dock; Owner: postgres
--

CREATE TABLE receiving_dock.json_data (
    id bigint NOT NULL,
    record_created_on_ts_wth_tz timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    source_meta_agg public.source_meta_agg_enum,
    source_content_class public.source_content_class_enum,
    content_source_id bigint NOT NULL,
    json_data_as_json_object json,
    inputpath text,
    record_added_on timestamp with time zone DEFAULT clock_timestamp()
);


ALTER TABLE receiving_dock.json_data OWNER TO postgres;

--
-- Name: json_data_expanded; Type: TABLE; Schema: receiving_dock; Owner: postgres
--

CREATE TABLE receiving_dock.json_data_expanded (
    id bigint NOT NULL,
    source_meta_agg public.source_meta_agg_enum,
    source_content_class public.source_content_class_enum,
    imdb_id_no text,
    imdb_tt_id text,
    title text,
    original_title text,
    description text,
    tagline text,
    genres json,
    genres_arr text[],
    production_companies json,
    production_companies_arr text[],
    production_countries json,
    production_countries_arr text[],
    spoken_languages json,
    spoken_languages_arr text[],
    production_status text,
    released_on text,
    runtime_in_minutes text,
    budget text,
    revenue text,
    popularity text,
    vote_count text,
    vote_average text,
    homepage text,
    original_language text,
    poster_path text,
    backdrop_path text,
    belongs_to_collection_id text,
    belongs_to_collection_poster_path text,
    belongs_to_collection_name text,
    is_video text,
    is_adult text,
    in_production text,
    next_episode_to_air text,
    last_air_date text,
    last_episode_to_air text,
    number_of_episodes text,
    number_of_seasons text,
    episode_run_time text,
    original_name text,
    languages text,
    origin_country text,
    first_air_date text,
    networks text,
    seasons text,
    series_type text,
    created_by text,
    series_name text,
    added_on timestamp with time zone DEFAULT clock_timestamp()
);


ALTER TABLE receiving_dock.json_data_expanded OWNER TO postgres;

--
-- Name: json_data_expanded_id_seq; Type: SEQUENCE; Schema: receiving_dock; Owner: postgres
--

ALTER TABLE receiving_dock.json_data_expanded ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME receiving_dock.json_data_expanded_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
    CYCLE
);


--
-- Name: json_data_id_seq; Type: SEQUENCE; Schema: receiving_dock; Owner: postgres
--

ALTER TABLE receiving_dock.json_data ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME receiving_dock.json_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
    CYCLE
);


--
-- Name: path_processing_instructions; Type: TABLE; Schema: receiving_dock; Owner: postgres
--

CREATE TABLE receiving_dock.path_processing_instructions (
    id bigint NOT NULL,
    txt text NOT NULL,
    typ_id bigint NOT NULL,
    record_created_on_ts_wth_tz timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    record_changed_on_ts_wth_tz timestamp with time zone,
    record_deleted boolean DEFAULT false,
    record_deleted_on_ts_wth_tz timestamp with time zone,
    record_deleted_why bigint,
    txt_prev character varying(400),
    txt_corrected boolean,
    txt_corrected_on_ts_wth_tz timestamp with time zone,
    txt_corrected_why bigint,
    typ_prev bigint,
    typ_corrected boolean,
    typ_corrected_on_ts_wth_tz timestamp with time zone,
    typ_corrected_why bigint,
    loading_batch_run_id bigint,
    row_op public.row_op_enum,
    row_op_prev public.row_op_enum,
    files_renamable boolean,
    exposed_to_users boolean,
    path_to_process text,
    extensions_contained text[],
    sequence_in_file_movement integer,
    description_of_function text,
    CONSTRAINT template_for_all_tables_record_deleted_check2 CHECK ((record_deleted IS NOT TRUE)),
    CONSTRAINT template_for_all_tables_record_deleted_check3 CHECK ((record_deleted IS NOT TRUE))
);


ALTER TABLE receiving_dock.path_processing_instructions OWNER TO postgres;

--
-- Name: path_processing_instructions_id_seq; Type: SEQUENCE; Schema: receiving_dock; Owner: postgres
--

ALTER TABLE receiving_dock.path_processing_instructions ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME receiving_dock.path_processing_instructions_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE -9223372036854775808
    NO MAXVALUE
    CACHE 1
    CYCLE
);


--
-- Name: directories; Type: TABLE; Schema: stage_for_master; Owner: postgres
--

CREATE TABLE stage_for_master.directories (
    id bigint NOT NULL,
    txt character varying(400) NOT NULL,
    typ_id bigint NOT NULL,
    record_created_on_ts_wth_tz timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    record_changed_on_ts_wth_tz timestamp with time zone,
    record_deleted boolean DEFAULT false,
    record_deleted_on_ts_wth_tz timestamp with time zone,
    record_deleted_why bigint,
    txt_prev character varying(400),
    txt_corrected boolean,
    txt_corrected_on_ts_wth_tz timestamp with time zone,
    txt_corrected_why bigint,
    typ_prev bigint,
    typ_corrected boolean,
    typ_corrected_on_ts_wth_tz timestamp with time zone,
    typ_corrected_why bigint,
    row_op_prev public.row_op_enum,
    row_op public.row_op_enum,
    loading_batch_run_id bigint,
    processing_state public.processing_state_enum,
    prev_directory_created_on_ts_wth_tz timestamp with time zone,
    directory_created_on_ts_wth_tz timestamp with time zone NOT NULL,
    detected_change_created_dt_on timestamp with time zone,
    prev_directory_modified_on_ts_wth_tz timestamp with time zone,
    directory_modified_on_ts_wth_tz timestamp with time zone NOT NULL,
    detected_change_modified_dt_on timestamp with time zone,
    file_names_subject_to_cleanup boolean,
    file_names_subject_to_refactored_directory boolean,
    file_contents_ever_change boolean,
    directory_explanation text,
    resides_on_computer_id bigint,
    scan_started_on timestamp with time zone,
    scan_completed_on timestamp with time zone,
    CONSTRAINT template_for_all_tables_record_deleted_check CHECK ((record_deleted IS NOT TRUE))
);


ALTER TABLE stage_for_master.directories OWNER TO postgres;

--
-- Name: COLUMN directories.id; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.directories.id IS 'TODO: We need to add these into the files table, though I don''t know what value it will have unless I normalize the path out of the txt file path.';


--
-- Name: COLUMN directories.txt; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.directories.txt IS 'full path of the directory';


--
-- Name: COLUMN directories.typ_id; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.directories.typ_id IS 'Just directory for now, maybe later spread out into local, remote, OneDrive, network path, url';


--
-- Name: COLUMN directories.txt_prev; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.directories.txt_prev IS 'A renamed directory? I doubt it.';


--
-- Name: COLUMN directories.typ_prev; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.directories.typ_prev IS 'This will happen when 12 directory shifts down to local drive directory.';


--
-- Name: COLUMN directories.typ_corrected_why; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.directories.typ_corrected_why IS 'will equal whys value "shifted down hierarchy"';


--
-- Name: COLUMN directories.prev_directory_created_on_ts_wth_tz; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.directories.prev_directory_created_on_ts_wth_tz IS 'Could this change??';


--
-- Name: COLUMN directories.directory_created_on_ts_wth_tz; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.directories.directory_created_on_ts_wth_tz IS 'This is a new directory';


--
-- Name: COLUMN directories.directory_modified_on_ts_wth_tz; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.directories.directory_modified_on_ts_wth_tz IS 'If this increases, then we need to rescan all objects below.';


--
-- Name: COLUMN directories.file_names_subject_to_cleanup; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.directories.file_names_subject_to_cleanup IS 'May not use. This would be set to no for downloaded torrents, yes to the published files, no to backed up files.';


--
-- Name: COLUMN directories.file_names_subject_to_refactored_directory; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.directories.file_names_subject_to_refactored_directory IS 'Published files get moved around, downloaded files change directory if the category changes.';


--
-- Name: COLUMN directories.file_contents_ever_change; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.directories.file_contents_ever_change IS 'no for any of these files';


--
-- Name: COLUMN directories.resides_on_computer_id; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.directories.resides_on_computer_id IS 'Eventually set, and then txt must include in uniqueness.';


--
-- Name: COLUMN directories.scan_completed_on; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.directories.scan_completed_on IS 'If null then it was the scan was interrupted and so when we restart scanning, force this directory to be rescanned.';


--
-- Name: directories_id_seq; Type: SEQUENCE; Schema: stage_for_master; Owner: postgres
--

ALTER TABLE stage_for_master.directories ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME stage_for_master.directories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: files; Type: TABLE; Schema: stage_for_master; Owner: postgres
--

CREATE TABLE stage_for_master.files (
    txt character varying(400) NOT NULL,
    typ_id bigint NOT NULL,
    record_created_on_ts_wth_tz timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    record_changed_on_ts_wth_tz timestamp with time zone,
    record_deleted boolean,
    record_deleted_on_ts_wth_tz timestamp with time zone,
    record_deleted_why bigint,
    txt_prev character varying(400),
    txt_corrected boolean,
    txt_corrected_on_ts_wth_tz timestamp with time zone,
    txt_corrected_why bigint,
    typ_prev bigint,
    typ_corrected boolean,
    typ_corrected_on_ts_wth_tz timestamp with time zone,
    typ_corrected_why bigint,
    loading_batch_run_id bigint,
    base_name character varying(200) NOT NULL,
    final_extension character varying NOT NULL,
    file_size bigint,
    file_created_on_ts_wth_tz timestamp with time zone NOT NULL,
    file_modified_on_ts_wth_tz timestamp with time zone NOT NULL,
    parent_directory_created_on_ts_wth_tz timestamp with time zone NOT NULL,
    parent_directory_modified_on_ts_wth_tz timestamp with time zone NOT NULL,
    file_deleted boolean DEFAULT false NOT NULL,
    file_deleted_on_ts_wth_tz timestamp with time zone,
    file_deleted_why bigint,
    file_replaced boolean DEFAULT false NOT NULL,
    file_replaced_on_ts_wth_tz timestamp with time zone,
    file_moved boolean DEFAULT false NOT NULL,
    file_moved_where bigint,
    file_moved_why bigint,
    file_moved_on_ts_wth_tz timestamp with time zone,
    file_lost boolean DEFAULT false NOT NULL,
    file_loss_detected_on_ts_wth_tz timestamp with time zone,
    last_verified_full_path_present_on_ts_wth_tz timestamp with time zone,
    file_md5_hash bytea NOT NULL,
    id bigint NOT NULL,
    CONSTRAINT files_record_deleted_check CHECK ((record_deleted IS NOT TRUE))
);


ALTER TABLE stage_for_master.files OWNER TO postgres;

--
-- Name: COLUMN files.txt; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.files.txt IS 'The full path with all the fixin''s.  Includes the file name with extension.';


--
-- Name: COLUMN files.typ_id; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.files.typ_id IS 'Like is it a torrent file, a published to user file, a backup file';


--
-- Name: COLUMN files.record_created_on_ts_wth_tz; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.files.record_created_on_ts_wth_tz IS 'Please block this in the update common trigger from being updated.';


--
-- Name: COLUMN files.record_changed_on_ts_wth_tz; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.files.record_changed_on_ts_wth_tz IS 'NEVER set in insert trigger';


--
-- Name: COLUMN files.txt_corrected; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.files.txt_corrected IS 'As in not changed, the thing represented did not mutate, rather we are correcting a misentry.';


--
-- Name: COLUMN files.typ_prev; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.files.typ_prev IS 'previous typ_id, actually';


--
-- Name: COLUMN files.base_name; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.files.base_name IS 'without the extension';


--
-- Name: COLUMN files.final_extension; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.files.final_extension IS 'like, ".torrent", ".txt", ".mkv".  In torrenting, file names often have multiple periods.';


--
-- Name: COLUMN files.file_modified_on_ts_wth_tz; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.files.file_modified_on_ts_wth_tz IS 'The file timestamps only go out to milliseconds. So we are taking the system tz.';


--
-- Name: files_batch_runs_log; Type: TABLE; Schema: stage_for_master; Owner: postgres
--

CREATE TABLE stage_for_master.files_batch_runs_log (
    id bigint NOT NULL,
    typ_id bigint NOT NULL,
    processing_state public.processing_state_enum,
    file_flow_state public.file_flow_state_enum,
    app_name character varying(200),
    app_path character varying(400),
    function_declaration character varying(200),
    function_name character varying(200),
    class_name character varying(200),
    source_file_path character varying(400),
    project_path character varying(200),
    code_file_name character varying(200),
    extension_filters text[],
    search_path text,
    source_code_id bigint,
    loading_batch_run_id bigint,
    source_code_file_hash bytea,
    run_from_exe_hash bytea,
    running_debug_build boolean,
    code_file_last_saved timestamp with time zone,
    started_on_ts_wth_tz timestamp with time zone,
    stopped_on_ts_wth_tz timestamp with time zone,
    run_duration_in_seconds bigint GENERATED ALWAYS AS (EXTRACT(second FROM (started_on_ts_wth_tz - stopped_on_ts_wth_tz))) STORED,
    processed_at_lst_1_file boolean,
    processed_at_lst_1_directory boolean,
    files_added integer,
    files_marked_as_still_there integer,
    files_removed integer,
    directories_created integer,
    directories_tested integer,
    directories_newly_modified_since_last integer,
    files_same_name_but_attr_chgnd integer,
    error_msg text,
    error_on_line_no integer,
    running_what_debugger character varying(200)
);


ALTER TABLE stage_for_master.files_batch_runs_log OWNER TO postgres;

--
-- Name: COLUMN files_batch_runs_log.running_what_debugger; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.files_batch_runs_log.running_what_debugger IS 'No idea without a stacktrace, and where the heck can I get a stacktrace?? So this is null for now. I''ve tried boost, and I cannot generate anything but backtrace_noop libs.';


--
-- Name: files_batch_runs_log_id_seq; Type: SEQUENCE; Schema: stage_for_master; Owner: postgres
--

ALTER TABLE stage_for_master.files_batch_runs_log ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME stage_for_master.files_batch_runs_log_id_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE -9223372036854775808
    NO MAXVALUE
    CACHE 1
    CYCLE
);


--
-- Name: files_id_seq; Type: SEQUENCE; Schema: stage_for_master; Owner: postgres
--

ALTER TABLE stage_for_master.files ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME stage_for_master.files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
    CYCLE
);


--
-- Name: media_files; Type: TABLE; Schema: stage_for_master; Owner: postgres
--

CREATE TABLE stage_for_master.media_files (
    id bigint NOT NULL,
    txt character varying(400) NOT NULL,
    typ_id bigint NOT NULL,
    record_created_on_ts_wth_tz timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    record_changed_on_ts_wth_tz timestamp with time zone,
    record_deleted boolean DEFAULT false,
    record_deleted_on_ts_wth_tz timestamp with time zone,
    record_deleted_why bigint,
    txt_prev character varying(400),
    txt_corrected boolean,
    txt_corrected_on_ts_wth_tz timestamp with time zone,
    txt_corrected_why bigint,
    typ_prev bigint,
    typ_corrected boolean,
    typ_corrected_on_ts_wth_tz timestamp with time zone,
    typ_corrected_why bigint,
    loading_batch_run_id bigint,
    manually_cleaned_txt_do_not_overwrite boolean,
    autocleaned_txt_from_file_name character varying(200),
    autocleaned_txt_from_filebot character varying(200),
    cleaned_txt_with_year character varying(207) GENERATED ALWAYS AS ((((((txt)::text || ' '::text) || '('::text) || (release_year)::text) || ')'::text)) STORED,
    file_name_no_extension character varying(204) NOT NULL,
    tags_extracted_from_base_name text[],
    parent_folder_name character varying(200) NOT NULL,
    tags_extracted_from_parent_folder text[],
    grandparent_folder_name character varying(200) NOT NULL,
    tags_extracted_from_gparent_folder text[],
    greatgrandparent_folder_name character varying(200) NOT NULL,
    tags_extracted_from_ggparent_folder text[],
    record_version_for_same_name integer NOT NULL,
    release_year character varying(4),
    release_year_from_file_name integer,
    source_type_tags_from_file_name character varying(20),
    country_release_tags_from_file_name character(2),
    spoken_language_tags_from_file_name character(3),
    uploader_tags_from_file_name character varying(30),
    encoding_tags_from_file_name character varying(10),
    genre_tags_from_file_name character varying(20),
    audio_tags_from_file_name character varying(20),
    misc_tags_from_file_name text[],
    base_folder_as_genre character varying(50),
    language_cd character(3) DEFAULT 'eng'::bpchar
);


ALTER TABLE stage_for_master.media_files OWNER TO postgres;

--
-- Name: COLUMN media_files.id; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.media_files.id IS 'This needs to keep updating for new until a truncate with restart is run. Stage id'' for now get reset, so joining back from master won''t really work, so we''ll have a think and maybe a separate table the master links back to with perm sequence ids.  It''s just that testing will cause bloat. Note that I don''t see any reason for these to be super keys that are from a master sequence.';


--
-- Name: COLUMN media_files.txt; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.media_files.txt IS 'A copy of txt from files, not the title, since we don''t know for sure what that is yet.';


--
-- Name: COLUMN media_files.typ_id; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.media_files.typ_id IS 'video, movie, episode, series, season?';


--
-- Name: COLUMN media_files.cleaned_txt_with_year; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.media_files.cleaned_txt_with_year IS 'Generated, and this should be unique, unless multiple versions editions of the file, director''s cut, etc.';


--
-- Name: quotes; Type: TABLE; Schema: stage_for_master; Owner: postgres
--

CREATE TABLE stage_for_master.quotes (
    id bigint NOT NULL,
    text character varying(400) NOT NULL,
    type_id bigint NOT NULL,
    record_created_on_ts_wth_tz timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    record_changed_on_ts_wth_tz timestamp with time zone,
    record_deleted boolean DEFAULT false,
    record_deleted_on_ts_wth_tz timestamp with time zone,
    record_deleted_why bigint,
    text_prev character varying(400),
    text_corrected boolean,
    text_corrected_on_ts_wth_tz timestamp with time zone,
    text_corrected_why bigint,
    type_prev bigint,
    type_corrected boolean,
    type_corrected_on_ts_wth_tz timestamp with time zone,
    type_corrected_why bigint,
    media_file_id bigint,
    CONSTRAINT table_template_for_staging_table_record_deleted_check CHECK ((record_deleted IS NOT TRUE))
);


ALTER TABLE stage_for_master.quotes OWNER TO postgres;

--
-- Name: COLUMN quotes.id; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.quotes.id IS 'For staging tables we set these values using an identity. We can build up slowly or reset on truncate';


--
-- Name: COLUMN quotes.type_id; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.quotes.type_id IS 'Every object is only ever one type at a time.';


--
-- Name: COLUMN quotes.record_deleted; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.quotes.record_deleted IS 'Set to null if deleted and use NULLS NOT DISTINCT in UNIQUE trick to keep deleted files in same table.';


--
-- Name: quotes_id_seq; Type: SEQUENCE; Schema: stage_for_master; Owner: postgres
--

ALTER TABLE stage_for_master.quotes ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME stage_for_master.quotes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: search_paths; Type: TABLE; Schema: stage_for_master; Owner: postgres
--

CREATE TABLE stage_for_master.search_paths (
    id bigint NOT NULL,
    text character varying(400) NOT NULL,
    type_id bigint NOT NULL,
    record_created_on_ts_wth_tz timestamp with time zone DEFAULT clock_timestamp(),
    record_changed_on_ts_wth_tz timestamp with time zone,
    record_deleted boolean,
    record_deleted_on_ts_wth_tz timestamp with time zone,
    record_deleted_why character varying(400),
    text_prev character varying(400),
    text_corrected boolean,
    text_corrected_on_ts_wth_tz timestamp with time zone,
    text_corrected_why bigint,
    type_prev bigint,
    type_corrected boolean,
    type_corrected_on_ts_wth_tz timestamp with time zone,
    type_corrected_why bigint
);


ALTER TABLE stage_for_master.search_paths OWNER TO postgres;

--
-- Name: COLUMN search_paths.id; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.search_paths.id IS 'Not an identity since small tiny list';


--
-- Name: COLUMN search_paths.type_id; Type: COMMENT; Schema: stage_for_master; Owner: postgres
--

COMMENT ON COLUMN stage_for_master.search_paths.type_id IS 'Made this not null. anything without some type is abhorrent.';


--
-- Name: gen_id gen_id_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gen_id
    ADD CONSTRAINT gen_id_pkey PRIMARY KEY (id);


--
-- Name: template_for_all_tables template_for_all_tables_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_for_all_tables
    ADD CONSTRAINT template_for_all_tables_pkey PRIMARY KEY (id);


--
-- Name: template_for_all_tables template_for_all_tables_txt_record_deleted_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_for_all_tables
    ADD CONSTRAINT template_for_all_tables_txt_record_deleted_key UNIQUE NULLS NOT DISTINCT (txt, record_deleted);


--
-- Name: template_for_all_tables template_for_all_tables_txt_record_deleted_key1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_for_all_tables
    ADD CONSTRAINT template_for_all_tables_txt_record_deleted_key1 UNIQUE NULLS NOT DISTINCT (txt, record_deleted);


--
-- Name: template_for_docking_tables template_for_docking_tables_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_for_docking_tables
    ADD CONSTRAINT template_for_docking_tables_pkey PRIMARY KEY (id);


--
-- Name: template_for_small_reference_tables template_for_small_reference_tables_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_for_small_reference_tables
    ADD CONSTRAINT template_for_small_reference_tables_pkey PRIMARY KEY (id);


--
-- Name: template_for_small_reference_tables template_for_small_reference_tables_txt_record_deleted_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_for_small_reference_tables
    ADD CONSTRAINT template_for_small_reference_tables_txt_record_deleted_key UNIQUE NULLS NOT DISTINCT (txt, record_deleted);


--
-- Name: template_for_staging_tables template_for_staging_tables_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_for_staging_tables
    ADD CONSTRAINT template_for_staging_tables_pkey PRIMARY KEY (id);


--
-- Name: template_for_staging_tables template_for_staging_tables_txt_record_deleted_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_for_staging_tables
    ADD CONSTRAINT template_for_staging_tables_txt_record_deleted_key UNIQUE NULLS NOT DISTINCT (txt, record_deleted);


--
-- Name: typs typs_id_excl; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.typs
    ADD CONSTRAINT typs_id_excl EXCLUDE USING btree (id WITH =) WHERE ((typ_id IS NULL));


--
-- Name: typs typs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.typs
    ADD CONSTRAINT typs_pkey PRIMARY KEY (id);


--
-- Name: typs typs_txt_record_deleted_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.typs
    ADD CONSTRAINT typs_txt_record_deleted_key UNIQUE NULLS NOT DISTINCT (txt, record_deleted);


--
-- Name: all_my_keep_and_imdb_lists ak_hash_of_all_columns; Type: CONSTRAINT; Schema: receiving_dock; Owner: postgres
--

ALTER TABLE ONLY receiving_dock.all_my_keep_and_imdb_lists
    ADD CONSTRAINT ak_hash_of_all_columns UNIQUE (hash_of_all_columns);


--
-- Name: all_my_keep_and_imdb_lists ak_title_release_year; Type: CONSTRAINT; Schema: receiving_dock; Owner: postgres
--

ALTER TABLE ONLY receiving_dock.all_my_keep_and_imdb_lists
    ADD CONSTRAINT ak_title_release_year UNIQUE (manually_corrected_title);


--
-- Name: all_my_keep_and_imdb_lists all_my_keep_and_imdb_lists_pkey; Type: CONSTRAINT; Schema: receiving_dock; Owner: postgres
--

ALTER TABLE ONLY receiving_dock.all_my_keep_and_imdb_lists
    ADD CONSTRAINT all_my_keep_and_imdb_lists_pkey PRIMARY KEY (id);


--
-- Name: content_sources content_sources_pkey; Type: CONSTRAINT; Schema: receiving_dock; Owner: postgres
--

ALTER TABLE ONLY receiving_dock.content_sources
    ADD CONSTRAINT content_sources_pkey PRIMARY KEY (id);


--
-- Name: content_sources content_sources_txt_record_deleted_key; Type: CONSTRAINT; Schema: receiving_dock; Owner: postgres
--

ALTER TABLE ONLY receiving_dock.content_sources
    ADD CONSTRAINT content_sources_txt_record_deleted_key UNIQUE NULLS NOT DISTINCT (txt, record_deleted);


--
-- Name: content_sources content_sources_txt_record_deleted_key1; Type: CONSTRAINT; Schema: receiving_dock; Owner: postgres
--

ALTER TABLE ONLY receiving_dock.content_sources
    ADD CONSTRAINT content_sources_txt_record_deleted_key1 UNIQUE NULLS NOT DISTINCT (txt, record_deleted);


--
-- Name: json_data_expanded json_data_expanded_imdb_id_no_key; Type: CONSTRAINT; Schema: receiving_dock; Owner: postgres
--

ALTER TABLE ONLY receiving_dock.json_data_expanded
    ADD CONSTRAINT json_data_expanded_imdb_id_no_key UNIQUE (imdb_id_no);


--
-- Name: json_data_expanded json_data_expanded_pkey; Type: CONSTRAINT; Schema: receiving_dock; Owner: postgres
--

ALTER TABLE ONLY receiving_dock.json_data_expanded
    ADD CONSTRAINT json_data_expanded_pkey PRIMARY KEY (id);


--
-- Name: json_data json_data_inputpath_key; Type: CONSTRAINT; Schema: receiving_dock; Owner: postgres
--

ALTER TABLE ONLY receiving_dock.json_data
    ADD CONSTRAINT json_data_inputpath_key UNIQUE (inputpath);


--
-- Name: json_data json_data_pkey; Type: CONSTRAINT; Schema: receiving_dock; Owner: postgres
--

ALTER TABLE ONLY receiving_dock.json_data
    ADD CONSTRAINT json_data_pkey PRIMARY KEY (id);


--
-- Name: path_processing_instructions path_processing_instructions_pkey; Type: CONSTRAINT; Schema: receiving_dock; Owner: postgres
--

ALTER TABLE ONLY receiving_dock.path_processing_instructions
    ADD CONSTRAINT path_processing_instructions_pkey PRIMARY KEY (id);


--
-- Name: path_processing_instructions path_processing_instructions_txt_record_deleted_key; Type: CONSTRAINT; Schema: receiving_dock; Owner: postgres
--

ALTER TABLE ONLY receiving_dock.path_processing_instructions
    ADD CONSTRAINT path_processing_instructions_txt_record_deleted_key UNIQUE NULLS NOT DISTINCT (txt, record_deleted);


--
-- Name: path_processing_instructions path_processing_instructions_txt_record_deleted_key1; Type: CONSTRAINT; Schema: receiving_dock; Owner: postgres
--

ALTER TABLE ONLY receiving_dock.path_processing_instructions
    ADD CONSTRAINT path_processing_instructions_txt_record_deleted_key1 UNIQUE NULLS NOT DISTINCT (txt, record_deleted);


--
-- Name: search_paths ak_search_paths_id; Type: CONSTRAINT; Schema: stage_for_master; Owner: postgres
--

ALTER TABLE ONLY stage_for_master.search_paths
    ADD CONSTRAINT ak_search_paths_id PRIMARY KEY (id);


--
-- Name: search_paths ak_search_paths_text; Type: CONSTRAINT; Schema: stage_for_master; Owner: postgres
--

ALTER TABLE ONLY stage_for_master.search_paths
    ADD CONSTRAINT ak_search_paths_text UNIQUE (text);


--
-- Name: directories directories_pkey; Type: CONSTRAINT; Schema: stage_for_master; Owner: postgres
--

ALTER TABLE ONLY stage_for_master.directories
    ADD CONSTRAINT directories_pkey PRIMARY KEY (id);


--
-- Name: directories directories_txt_record_deleted_key; Type: CONSTRAINT; Schema: stage_for_master; Owner: postgres
--

ALTER TABLE ONLY stage_for_master.directories
    ADD CONSTRAINT directories_txt_record_deleted_key UNIQUE NULLS NOT DISTINCT (txt, record_deleted);


--
-- Name: files_batch_runs_log files_batch_runs_log_pkey; Type: CONSTRAINT; Schema: stage_for_master; Owner: postgres
--

ALTER TABLE ONLY stage_for_master.files_batch_runs_log
    ADD CONSTRAINT files_batch_runs_log_pkey PRIMARY KEY (id);


--
-- Name: files files_pkey; Type: CONSTRAINT; Schema: stage_for_master; Owner: postgres
--

ALTER TABLE ONLY stage_for_master.files
    ADD CONSTRAINT files_pkey PRIMARY KEY (id);


--
-- Name: files files_txt_record_deleted_key; Type: CONSTRAINT; Schema: stage_for_master; Owner: postgres
--

ALTER TABLE ONLY stage_for_master.files
    ADD CONSTRAINT files_txt_record_deleted_key UNIQUE NULLS NOT DISTINCT (txt, record_deleted);


--
-- Name: media_files media_files_pkey; Type: CONSTRAINT; Schema: stage_for_master; Owner: postgres
--

ALTER TABLE ONLY stage_for_master.media_files
    ADD CONSTRAINT media_files_pkey PRIMARY KEY (id);


--
-- Name: quotes quotes_pkey; Type: CONSTRAINT; Schema: stage_for_master; Owner: postgres
--

ALTER TABLE ONLY stage_for_master.quotes
    ADD CONSTRAINT quotes_pkey PRIMARY KEY (id);


--
-- Name: quotes quotes_text_record_deleted_key; Type: CONSTRAINT; Schema: stage_for_master; Owner: postgres
--

ALTER TABLE ONLY stage_for_master.quotes
    ADD CONSTRAINT quotes_text_record_deleted_key UNIQUE NULLS NOT DISTINCT (text, record_deleted);


--
-- Name: typs trgupd_typs_02; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trgupd_typs_02 AFTER INSERT ON public.typs REFERENCING NEW TABLE AS new_table FOR EACH STATEMENT EXECUTE FUNCTION public.trgupd_typs();

ALTER TABLE public.typs DISABLE TRIGGER trgupd_typs_02;


--
-- Name: typs trgupd_typs_03; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trgupd_typs_03 AFTER DELETE ON public.typs REFERENCING OLD TABLE AS old_table FOR EACH STATEMENT EXECUTE FUNCTION public.trgupd_typs();

ALTER TABLE public.typs DISABLE TRIGGER trgupd_typs_03;


--
-- Name: typs trgupd_typs_04; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trgupd_typs_04 AFTER INSERT ON public.typs REFERENCING NEW TABLE AS new_table FOR EACH STATEMENT EXECUTE FUNCTION public.trgupd_typs();

ALTER TABLE public.typs DISABLE TRIGGER trgupd_typs_04;


--
-- Name: directories trgupd_directories_01; Type: TRIGGER; Schema: stage_for_master; Owner: postgres
--

CREATE TRIGGER trgupd_directories_01 BEFORE INSERT OR DELETE OR UPDATE ON stage_for_master.directories FOR EACH ROW EXECUTE FUNCTION public.trgupd_common_columns();


--
-- Name: files trgupd_files_01; Type: TRIGGER; Schema: stage_for_master; Owner: postgres
--

CREATE TRIGGER trgupd_files_01 BEFORE INSERT OR DELETE OR UPDATE ON stage_for_master.files FOR EACH ROW EXECUTE FUNCTION public.trgupd_common_columns();


--
-- Name: media_files trgupd_media_files_01; Type: TRIGGER; Schema: stage_for_master; Owner: postgres
--

CREATE TRIGGER trgupd_media_files_01 BEFORE INSERT OR DELETE OR UPDATE ON stage_for_master.media_files FOR EACH ROW EXECUTE FUNCTION public.trgupd_common_columns();


--
-- Name: quotes trgupd_quotes_01; Type: TRIGGER; Schema: stage_for_master; Owner: postgres
--

CREATE TRIGGER trgupd_quotes_01 BEFORE INSERT OR DELETE OR UPDATE ON stage_for_master.quotes FOR EACH ROW EXECUTE FUNCTION public.trgupd_common_columns();


--
-- Name: search_paths trgupd_search_paths_01; Type: TRIGGER; Schema: stage_for_master; Owner: postgres
--

CREATE TRIGGER trgupd_search_paths_01 BEFORE INSERT OR DELETE OR UPDATE ON stage_for_master.search_paths FOR EACH ROW EXECUTE FUNCTION public.trgupd_common_columns();


--
-- Name: template_for_all_tables template_for_all_tables_typ_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_for_all_tables
    ADD CONSTRAINT template_for_all_tables_typ_id_fkey FOREIGN KEY (typ_id) REFERENCES public.typs(id) ON DELETE RESTRICT;


--
-- Name: typs typs_typ_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.typs
    ADD CONSTRAINT typs_typ_id_fkey FOREIGN KEY (typ_id) REFERENCES public.typs(id) ON DELETE RESTRICT;


--
-- Name: directories directories_typ_id_fkey; Type: FK CONSTRAINT; Schema: stage_for_master; Owner: postgres
--

ALTER TABLE ONLY stage_for_master.directories
    ADD CONSTRAINT directories_typ_id_fkey FOREIGN KEY (typ_id) REFERENCES public.typs(id) ON DELETE RESTRICT;


--
-- Name: files_batch_runs_log files_batch_runs_log_typ_id_fkey; Type: FK CONSTRAINT; Schema: stage_for_master; Owner: postgres
--

ALTER TABLE ONLY stage_for_master.files_batch_runs_log
    ADD CONSTRAINT files_batch_runs_log_typ_id_fkey FOREIGN KEY (typ_id) REFERENCES public.typs(id) ON DELETE RESTRICT;


--
-- Name: files files_typ_id_fkey; Type: FK CONSTRAINT; Schema: stage_for_master; Owner: postgres
--

ALTER TABLE ONLY stage_for_master.files
    ADD CONSTRAINT files_typ_id_fkey FOREIGN KEY (typ_id) REFERENCES public.typs(id) ON DELETE RESTRICT;


--
-- Name: media_files media_files_id_fkey; Type: FK CONSTRAINT; Schema: stage_for_master; Owner: postgres
--

ALTER TABLE ONLY stage_for_master.media_files
    ADD CONSTRAINT media_files_id_fkey FOREIGN KEY (id) REFERENCES stage_for_master.files(id) ON DELETE RESTRICT;


--
-- Name: media_files media_files_typ_id_fkey; Type: FK CONSTRAINT; Schema: stage_for_master; Owner: postgres
--

ALTER TABLE ONLY stage_for_master.media_files
    ADD CONSTRAINT media_files_typ_id_fkey FOREIGN KEY (typ_id) REFERENCES public.typs(id) ON DELETE RESTRICT;


--
-- Name: media_files media_files_typ_id_fkey1; Type: FK CONSTRAINT; Schema: stage_for_master; Owner: postgres
--

ALTER TABLE ONLY stage_for_master.media_files
    ADD CONSTRAINT media_files_typ_id_fkey1 FOREIGN KEY (typ_id) REFERENCES public.typs(id) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--


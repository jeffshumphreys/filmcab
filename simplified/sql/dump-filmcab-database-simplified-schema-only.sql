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
-- Name: simplified; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA simplified;


ALTER SCHEMA simplified OWNER TO postgres;

--
-- Name: SCHEMA simplified; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA simplified IS 'Absolute reduction of all the many sources that are confluing into videos and movie details.

1) named id columns. It''s prettier (purtyr)
';


--
-- Name: ignore_accent_case; Type: COLLATION; Schema: simplified; Owner: postgres
--

CREATE COLLATION simplified.ignore_accent_case (provider = icu, deterministic = false, locale = 'und-u-ks-level1');


ALTER COLLATION simplified.ignore_accent_case OWNER TO postgres;

--
-- Name: ignore_accents; Type: COLLATION; Schema: simplified; Owner: postgres
--

CREATE COLLATION simplified.ignore_accents (provider = icu, deterministic = false, locale = 'und-u-ks-level1-kc-true');


ALTER COLLATION simplified.ignore_accents OWNER TO postgres;

--
-- Name: ignore_both_accent_and_case; Type: COLLATION; Schema: simplified; Owner: postgres
--

CREATE COLLATION simplified.ignore_both_accent_and_case (provider = icu, deterministic = false, locale = 'und-u-ks-level1');


ALTER COLLATION simplified.ignore_both_accent_and_case OWNER TO postgres;

--
-- Name: level3; Type: COLLATION; Schema: simplified; Owner: postgres
--

CREATE COLLATION simplified.level3 (provider = icu, deterministic = false, locale = 'und-u-ka-shifted-ks-level3');


ALTER COLLATION simplified.level3 OWNER TO postgres;

--
-- Name: ndcoll; Type: COLLATION; Schema: simplified; Owner: postgres
--

CREATE COLLATION simplified.ndcoll (provider = icu, deterministic = false, locale = 'und');


ALTER COLLATION simplified.ndcoll OWNER TO postgres;

--
-- Name: computer_os_type_enum; Type: TYPE; Schema: simplified; Owner: postgres
--

CREATE TYPE simplified.computer_os_type_enum AS ENUM (
    'windows',
    'linux',
    'macos'
);


ALTER TYPE simplified.computer_os_type_enum OWNER TO postgres;

--
-- Name: isp_customer_type_enum; Type: TYPE; Schema: simplified; Owner: postgres
--

CREATE TYPE simplified.isp_customer_type_enum AS ENUM (
    'residential',
    'business'
);


ALTER TYPE simplified.isp_customer_type_enum OWNER TO postgres;

--
-- Name: isp_service_type_enum; Type: TYPE; Schema: simplified; Owner: postgres
--

CREATE TYPE simplified.isp_service_type_enum AS ENUM (
    'internet',
    'phone',
    'tv'
);


ALTER TYPE simplified.isp_service_type_enum OWNER TO postgres;

--
-- Name: move_to_location_enum; Type: TYPE; Schema: simplified; Owner: postgres
--

CREATE TYPE simplified.move_to_location_enum AS ENUM (
    'seen',
    'corrupt'
);


ALTER TYPE simplified.move_to_location_enum OWNER TO postgres;

--
-- Name: TYPE move_to_location_enum; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TYPE simplified.move_to_location_enum IS 'I currently have N drive seens offloaded, and I for the hopefully less numerous corrupted videos.';


--
-- Name: nnulltext; Type: DOMAIN; Schema: simplified; Owner: postgres
--

CREATE DOMAIN simplified.nnulltext AS text
	CONSTRAINT nnulltext_check CHECK ((((TRIM(BOTH FROM VALUE) <> ''::text) AND (VALUE !~ '(\r\n|\r|\n|\t)'::text) AND (VALUE !~~ '%  %'::text) AND (VALUE = TRIM(BOTH FROM VALUE))) OR (VALUE IS NULL)));


ALTER DOMAIN simplified.nnulltext OWNER TO postgres;

--
-- Name: ntext; Type: DOMAIN; Schema: simplified; Owner: postgres
--

CREATE DOMAIN simplified.ntext AS text NOT NULL
	CONSTRAINT ntext_check CHECK (((TRIM(BOTH FROM VALUE) <> ''::text) AND (VALUE !~ '(\r\n|\r|\n|\t)'::text) AND (VALUE !~~ '%  %'::text) AND (VALUE = TRIM(BOTH FROM VALUE))));


ALTER DOMAIN simplified.ntext OWNER TO postgres;

--
-- Name: video_edition_type_enum; Type: TYPE; Schema: simplified; Owner: postgres
--

CREATE TYPE simplified.video_edition_type_enum AS ENUM (
    'theatrical release',
    'director''s cut',
    'restored',
    'censored',
    'mst3k',
    'rifftrax',
    'svengoolie',
    'despecialized'
);


ALTER TYPE simplified.video_edition_type_enum OWNER TO postgres;

--
-- Name: video_file_type_enum; Type: TYPE; Schema: simplified; Owner: postgres
--

CREATE TYPE simplified.video_file_type_enum AS ENUM (
    'vob',
    'mpg',
    'wmv',
    'mkv',
    'mp4',
    'mov',
    'avi'
);


ALTER TYPE simplified.video_file_type_enum OWNER TO postgres;

--
-- Name: video_sub_type_enum; Type: TYPE; Schema: simplified; Owner: postgres
--

CREATE TYPE simplified.video_sub_type_enum AS ENUM (
    'movie',
    'tv movie',
    'short',
    'tv series',
    'tv miniseries',
    'tv season',
    'tv episode'
);


ALTER TYPE simplified.video_sub_type_enum OWNER TO postgres;

--
-- Name: wdecimal14_2; Type: DOMAIN; Schema: simplified; Owner: postgres
--

CREATE DOMAIN simplified.wdecimal14_2 AS numeric(14,2)
	CONSTRAINT wdecimal14_2_check CHECK ((((VALUE)::numeric > 0.00) OR (VALUE IS NULL)));


ALTER DOMAIN simplified.wdecimal14_2 OWNER TO postgres;

--
-- Name: wmoney; Type: DOMAIN; Schema: simplified; Owner: postgres
--

CREATE DOMAIN simplified.wmoney AS money
	CONSTRAINT wmoney_check CHECK ((((VALUE)::numeric > 0.00) OR (VALUE IS NULL)));


ALTER DOMAIN simplified.wmoney OWNER TO postgres;

--
-- Name: wsmallint; Type: DOMAIN; Schema: simplified; Owner: postgres
--

CREATE DOMAIN simplified.wsmallint AS smallint
	CONSTRAINT wsmallint_check CHECK (((VALUE > 0) OR (VALUE IS NULL)));


ALTER DOMAIN simplified.wsmallint OWNER TO postgres;

--
-- Name: analyze_table(text); Type: FUNCTION; Schema: simplified; Owner: postgres
--

CREATE FUNCTION simplified.analyze_table(tb_nm text) RETURNS TABLE(col_nm text, count_of_distinct_values bigint, count_of_non_null_values bigint, count_of_rows bigint, max_value text, min_value text)
    LANGUAGE plpgsql
    AS $_$
    DECLARE SQL_str TEXT;
    DECLARE i INTEGER;
    DECLARE const_sql TEXT;
BEGIN
    SQL_str := $s$
WITH base AS (
        SELECT * FROM (VALUES('general_duration', 'duration_in_ms')) AS t(old_col_nm, new_col_nm)
    )
, x AS       (
            SELECT 
              CASE WHEN ordinal_position = 2 THEN '' ELSE 'UNION ALL ' END || 'SELECT ''' || COALESCE(new_col_nm, column_name) || ''' AS col_nm
            , COUNT(DISTINCT '|| column_name || ')          AS count_of_distinct_values 
            , COUNT(' || column_name || ')                  AS count_of_non_null_values
            , COUNT(*)                                      AS count_of_rows
            , MAX(' || column_name || ')                    AS max_value
            , MIN(' || column_name || ')                    AS min_value
            FROM %I' AS line
        FROM information_schema.columns LEFT JOIN base ON old_col_nm = column_name
        WHERE table_name = '%I'  AND column_name NOT in('file_id'))
--        , ' ')
SELECT STRING_AGG(line, ' ') FROM x
$s$;
    --RAISE NOTICE 's3 %', SQL_str;
    EXECUTE format(SQL_str, tb_nm, tb_nm) INTO const_sql;
    
    raise notice 'Value: %', const_sql;
    RETURN QUERY    
    EXECUTE const_sql; 
END;
$_$;


ALTER FUNCTION simplified.analyze_table(tb_nm text) OWNER TO postgres;

--
-- Name: howmanychar(text, text); Type: FUNCTION; Schema: simplified; Owner: postgres
--

CREATE FUNCTION simplified.howmanychar(what text, has_in text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
begin
    RETURN (CHAR_LENGTH(what) - CHAR_LENGTH(REPLACE(what, has_in, ''))) / CHAR_LENGTH(has_in);
end;
$$;


ALTER FUNCTION simplified.howmanychar(what text, has_in text) OWNER TO postgres;

--
-- Name: insert_update_if_no_record(); Type: FUNCTION; Schema: simplified; Owner: postgres
--

CREATE FUNCTION simplified.insert_update_if_no_record() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN 
    IF (SELECT COUNT(*) FROM simplified.batch_run_session_active_running_values) = 0 THEN
        INSERT INTO simplified.batch_run_session_active_running_values(active_batch_run_session_id) VALUES(NEW.active_batch_run_session_id);
    ELSE
        UPDATE simplified.batch_run_session_active_running_values SET active_batch_run_session_id = NEW.active_batch_run_session_id;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION simplified.insert_update_if_no_record() OWNER TO postgres;

--
-- Name: md5_hash_path(text); Type: FUNCTION; Schema: simplified; Owner: postgres
--

CREATE FUNCTION simplified.md5_hash_path(what text) RETURNS bytea
    LANGUAGE plpgsql
    AS $$
begin
    RETURN md5(REPLACE(array_to_string((string_to_array(what, '/'))[:(howmanychar(what, '/')+1)], '/'), '/', '\'))::bytea;
end;
$$;


ALTER FUNCTION simplified.md5_hash_path(what text) OWNER TO postgres;

--
-- Name: rtrim(text, integer); Type: FUNCTION; Schema: simplified; Owner: postgres
--

CREATE FUNCTION simplified.rtrim(what text, howmanycharacters integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
begin
    RETURN SUBSTRING(what, 1, CHAR_LENGTH(what) - howmanycharacters);
end;
$$;


ALTER FUNCTION simplified.rtrim(what text, howmanycharacters integer) OWNER TO postgres;

--
-- Name: view_delete(); Type: FUNCTION; Schema: simplified; Owner: postgres
--

CREATE FUNCTION simplified.view_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN 
    DELETE FROM simplified.batch_run_session_active_running_values WHERE 1=1;
    RETURN OLD;
END;
$$;


ALTER FUNCTION simplified.view_delete() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: acronyms; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.acronyms (
    acronym_id integer NOT NULL,
    acronym character varying NOT NULL,
    expansion character varying,
    definition character varying
);


ALTER TABLE simplified.acronyms OWNER TO postgres;

--
-- Name: TABLE acronyms; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.acronyms IS 'I lose track of these. What''s AVC, AAC, LC, MPEG? CABAC?';


--
-- Name: COLUMN acronyms.acronym; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.acronyms.acronym IS 'Try a new name: no "_name" suffix!';


--
-- Name: COLUMN acronyms.expansion; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.acronyms.expansion IS 'So en = English';


--
-- Name: acronyms_acronym_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

CREATE SEQUENCE simplified.acronyms_acronym_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE simplified.acronyms_acronym_id_seq OWNER TO postgres;

--
-- Name: acronyms_acronym_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.acronyms_acronym_id_seq OWNED BY simplified.acronyms.acronym_id;


--
-- Name: apps; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.apps (
    app_id smallint NOT NULL,
    app_name simplified.ntext NOT NULL,
    app_notes text,
    primary_function text,
    rating smallint,
    is_open_source boolean,
    runs_on_firetv boolean,
    github_url character varying,
    actively_using boolean,
    website character varying,
    source_code_url character varying,
    exe_name character varying,
    version_no character varying,
    this_version_as_of date
);


ALTER TABLE simplified.apps OWNER TO postgres;

--
-- Name: TABLE apps; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.apps IS 'I need to start (much delayed) understanding of the tools I use unthinkingly. Which ones best? Am I using the best? VLC is great, BUT it doesn''t use the latest codecs!! MX Player on firetv is best! Which ones have open source code I can just stuff in directly?';


--
-- Name: apps_app_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

CREATE SEQUENCE simplified.apps_app_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE simplified.apps_app_id_seq OWNER TO postgres;

--
-- Name: apps_app_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.apps_app_id_seq OWNED BY simplified.apps.app_id;


--
-- Name: batch_run_session_active_running_values; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.batch_run_session_active_running_values (
    active_batch_run_session_id integer NOT NULL,
    set_on timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE simplified.batch_run_session_active_running_values OWNER TO postgres;

--
-- Name: TABLE batch_run_session_active_running_values; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.batch_run_session_active_running_values IS 'My first singleton, one and exactly one and only one row ever.  You must use the view batch_run_session_active_running_values_ext_v to get this behavior.  This is the best I could do with INSTEAD OF rules and triggers.  But the goal was (achieved) to isolate row control logic away from the scripts referencing this, and maintaining persistence over sessions and between scripts.';


--
-- Name: batch_run_session_active_running_values_ext_v; Type: VIEW; Schema: simplified; Owner: postgres
--

CREATE VIEW simplified.batch_run_session_active_running_values_ext_v AS
 SELECT x.active_batch_run_session_id,
    x.set_on
   FROM ( SELECT '-1'::integer AS active_batch_run_session_id,
            now() AS set_on
        UNION ALL
         SELECT batch_run_session_active_running_values.active_batch_run_session_id,
            batch_run_session_active_running_values.set_on
           FROM simplified.batch_run_session_active_running_values) x
  ORDER BY x.set_on
 LIMIT 1;


ALTER TABLE simplified.batch_run_session_active_running_values_ext_v OWNER TO postgres;

--
-- Name: batch_run_session_tasks; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.batch_run_session_tasks (
    batch_run_session_task_id integer NOT NULL,
    batch_run_session_id integer,
    started timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ended timestamp with time zone,
    error_code integer,
    run_duration_in_seconds bigint GENERATED ALWAYS AS (EXTRACT(second FROM (ended - started))) STORED,
    running boolean DEFAULT true,
    caller character varying,
    caller_ending character varying,
    caller_starting character varying,
    marking_ended_after_overrun timestamp with time zone,
    script_name character varying,
    script_changed timestamp with time zone,
    triggered_by_login character varying,
    trigger_type character varying,
    thread_id bigint,
    process_id bigint,
    activity_uuid uuid,
    trigger_id character varying,
    is_testscheduledriventaskdetection boolean,
    real_script_that_generated_this character varying,
    script_we_are_simulating character varying
);


ALTER TABLE simplified.batch_run_session_tasks OWNER TO postgres;

--
-- Name: TABLE batch_run_session_tasks; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.batch_run_session_tasks IS 'Track each task run in a session, to better debug what''s going on.  Also time each task/session run. Over time, things like the files scan should run longer and find more files, for instance.';


--
-- Name: COLUMN batch_run_session_tasks.caller_starting; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_session_tasks.caller_starting IS 'What script started this task run under this session?';


--
-- Name: COLUMN batch_run_session_tasks.marking_ended_after_overrun; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_session_tasks.marking_ended_after_overrun IS 'Either ended or marking_ended should be set.  started to marking_ended isn''t really a proper run duration.';


--
-- Name: COLUMN batch_run_session_tasks.script_name; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_session_tasks.script_name IS 'Capture name; should be same as scheduled task name. But capture it.';


--
-- Name: COLUMN batch_run_session_tasks.script_changed; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_session_tasks.script_changed IS 'So when behavior changes, we can separate new externals from new bugs in new code.';


--
-- Name: COLUMN batch_run_session_tasks.trigger_type; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_session_tasks.trigger_type IS 'Mostly schedule, user, or event.';


--
-- Name: COLUMN batch_run_session_tasks.thread_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_session_tasks.thread_id IS 'Trying to detect real chains of events as tasks vs tasks just started willy-nilly.';


--
-- Name: COLUMN batch_run_session_tasks.process_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_session_tasks.process_id IS 'Another attempt to link these task events';


--
-- Name: COLUMN batch_run_session_tasks.activity_uuid; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_session_tasks.activity_uuid IS 'Can we link all the task runs by this?';


--
-- Name: COLUMN batch_run_session_tasks.trigger_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_session_tasks.trigger_id IS 'I set these; they''re not set and not settable from the GUI.';


--
-- Name: COLUMN batch_run_session_tasks.is_testscheduledriventaskdetection; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_session_tasks.is_testscheduledriventaskdetection IS 'Set of this was generated by a fake task.';


--
-- Name: batch_run_session_tasks_v; Type: VIEW; Schema: simplified; Owner: postgres
--

CREATE VIEW simplified.batch_run_session_tasks_v AS
 SELECT brst.batch_run_session_task_id,
    brst.batch_run_session_id,
    brst.started,
    brst.ended,
    brst.error_code,
    trunc(EXTRACT(epoch FROM (brst.ended - brst.started))) AS run_duration_in_seconds,
    brst.running,
    brst.caller,
    brst.caller_ending,
    brst.caller_starting,
    brst.marking_ended_after_overrun,
    brst.script_name,
    brst.script_changed,
    brst.triggered_by_login,
    brst.trigger_type,
    brst.thread_id,
    brst.process_id,
    brst.activity_uuid,
    brst.trigger_id,
    brst.is_testscheduledriventaskdetection
   FROM simplified.batch_run_session_tasks brst;


ALTER TABLE simplified.batch_run_session_tasks_v OWNER TO postgres;

--
-- Name: batch_run_sessions; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.batch_run_sessions (
    batch_run_session_id integer NOT NULL,
    batch_run_session_uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    started timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    stopped timestamp with time zone,
    run_duration_in_seconds bigint GENERATED ALWAYS AS (EXTRACT(second FROM (stopped - started))) STORED,
    running boolean DEFAULT true,
    last_script_ran text,
    session_killing_script text,
    new_directories integer,
    new_files integer,
    missing_files integer,
    session_starting_script character varying,
    caller_stopping character varying,
    caller_starting character varying,
    marking_stopped_after_overrun timestamp with time zone,
    triggered_by_login text,
    trigger_type character varying,
    thread_id bigint,
    process_id bigint,
    activity_uuid uuid,
    trigger_id character varying,
    is_testscheduledriventaskdetection boolean,
    real_script_that_generated_this character varying,
    script_we_are_simulating character varying
);


ALTER TABLE simplified.batch_run_sessions OWNER TO postgres;

--
-- Name: TABLE batch_run_sessions; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.batch_run_sessions IS 'Try and track over the days. Detect when the batch didn''t complete, so we can investigate.  Cancelled? Rebooted? drive failed? database corrupted? file system?  Did it run over or too quickly? Too quick is often a sign of failure.  Statistics: Is it running longer in a smooth or geometric growth pattern?  Tapering off? High variance? A lot one day then none the next?  Started late?';


--
-- Name: COLUMN batch_run_sessions.batch_run_session_uuid; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_sessions.batch_run_session_uuid IS 'In case id resets/rolls over, this is still unique. Not super useful.';


--
-- Name: COLUMN batch_run_sessions.stopped; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_sessions.stopped IS 'Only set if batch script at end runs. Though I suppose I set it too if _start_new_batch_run_session hits a dangling running session row in the morning.';


--
-- Name: COLUMN batch_run_sessions.running; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_sessions.running IS 'Defaults to running, but constrained to only ever one record marked as running.';


--
-- Name: COLUMN batch_run_sessions.last_script_ran; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_sessions.last_script_ran IS 'Some clue as to how far the batch got';


--
-- Name: COLUMN batch_run_sessions.session_killing_script; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_sessions.session_killing_script IS 'What script kilt the batch? Hopefully zzz_end/stop_batch_run_session.  The future''s not set.';


--
-- Name: COLUMN batch_run_sessions.session_starting_script; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_sessions.session_starting_script IS 'Who started this? May never vary.';


--
-- Name: COLUMN batch_run_sessions.caller_stopping; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_sessions.caller_stopping IS 'What script stopped this session?';


--
-- Name: COLUMN batch_run_sessions.caller_starting; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_sessions.caller_starting IS 'Who called me? VS Code debug session? Windows Task Scheduler? We don''t know because Jeff went and "bought" some job scheduler, or wrote a Quantz.Net app, or what.';


--
-- Name: COLUMN batch_run_sessions.marking_stopped_after_overrun; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_sessions.marking_stopped_after_overrun IS 'Set on next scheduled start if the end date was never set.';


--
-- Name: COLUMN batch_run_sessions.triggered_by_login; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_sessions.triggered_by_login IS 'either some event or time, calendar, etc., or directly by a user.';


--
-- Name: COLUMN batch_run_sessions.trigger_type; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_sessions.trigger_type IS 'user, event, schedule, logon, etc.';


--
-- Name: COLUMN batch_run_sessions.thread_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_sessions.thread_id IS 'Trying to detect real chains of events as tasks vs tasks just started willy-nilly.';


--
-- Name: COLUMN batch_run_sessions.process_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_sessions.process_id IS 'Another attempt to link these task events';


--
-- Name: COLUMN batch_run_sessions.activity_uuid; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_sessions.activity_uuid IS 'This does not sync up across tasks.';


--
-- Name: COLUMN batch_run_sessions.trigger_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_sessions.trigger_id IS 'I set these; they''re not set and not settable from the GUI.';


--
-- Name: COLUMN batch_run_sessions.is_testscheduledriventaskdetection; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_sessions.is_testscheduledriventaskdetection IS 'Set of this was generated by a fake task.';


--
-- Name: batch_run_sessions_batch_run_session_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

ALTER TABLE simplified.batch_run_sessions ALTER COLUMN batch_run_session_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME simplified.batch_run_sessions_batch_run_session_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
    CYCLE
);


--
-- Name: batch_run_sessions_v; Type: VIEW; Schema: simplified; Owner: postgres
--

CREATE VIEW simplified.batch_run_sessions_v AS
 SELECT batch_run_sessions.batch_run_session_id,
    batch_run_sessions.started,
    initcap(to_char(batch_run_sessions.started, 'DAY'::text)) AS started_on_dow,
    batch_run_sessions.stopped AS ended,
    batch_run_sessions.marking_stopped_after_overrun AS marking_ended_after_overrun,
    batch_run_sessions.running,
    trunc(EXTRACT(epoch FROM (batch_run_sessions.stopped - batch_run_sessions.started))) AS run_duration_in_seconds,
    trunc((EXTRACT(epoch FROM (batch_run_sessions.stopped - batch_run_sessions.started)) / (60)::numeric)) AS run_duration_in_minutes,
    trunc(((EXTRACT(epoch FROM (batch_run_sessions.stopped - batch_run_sessions.started)) / (60)::numeric) / (60)::numeric), 2) AS run_duration_in_hours,
    batch_run_sessions.last_script_ran,
    batch_run_sessions.session_starting_script,
    batch_run_sessions.session_killing_script AS session_ending_script,
    batch_run_sessions.caller_starting,
    batch_run_sessions.caller_stopping AS caller_ending,
    batch_run_sessions.trigger_type,
    batch_run_sessions.triggered_by_login,
    batch_run_sessions.thread_id,
    batch_run_sessions.process_id AS activity_uuid,
    batch_run_sessions.trigger_id
   FROM simplified.batch_run_sessions;


ALTER TABLE simplified.batch_run_sessions_v OWNER TO postgres;

--
-- Name: batch_run_sessions_scheduled_and_completed_v; Type: VIEW; Schema: simplified; Owner: postgres
--

CREATE VIEW simplified.batch_run_sessions_scheduled_and_completed_v AS
 SELECT batch_run_sessions_v.batch_run_session_id,
    batch_run_sessions_v.started,
    batch_run_sessions_v.started_on_dow,
    batch_run_sessions_v.ended,
    batch_run_sessions_v.marking_ended_after_overrun,
    batch_run_sessions_v.running,
    batch_run_sessions_v.run_duration_in_seconds,
    batch_run_sessions_v.run_duration_in_minutes,
    batch_run_sessions_v.run_duration_in_hours,
    batch_run_sessions_v.last_script_ran,
    batch_run_sessions_v.session_starting_script,
    batch_run_sessions_v.session_ending_script,
    batch_run_sessions_v.caller_starting,
    batch_run_sessions_v.caller_ending,
    batch_run_sessions_v.trigger_type,
    batch_run_sessions_v.triggered_by_login,
    batch_run_sessions_v.thread_id,
    batch_run_sessions_v.activity_uuid,
    batch_run_sessions_v.trigger_id
   FROM simplified.batch_run_sessions_v
  WHERE ((batch_run_sessions_v.started IS NOT NULL) AND (batch_run_sessions_v.ended IS NOT NULL) AND (batch_run_sessions_v.ended > batch_run_sessions_v.started) AND ((batch_run_sessions_v.session_starting_script)::text = '_start_new_batch_run_session.ps1'::text) AND (batch_run_sessions_v.session_ending_script = 'zzz_end_batch_run_session.ps1'::text) AND ((batch_run_sessions_v.caller_starting)::text = 'Windows Task Scheduler'::text) AND ((batch_run_sessions_v.caller_ending)::text = 'Windows Task Scheduler'::text))
  ORDER BY batch_run_sessions_v.started;


ALTER TABLE simplified.batch_run_sessions_scheduled_and_completed_v OWNER TO postgres;

--
-- Name: batch_run_sessions_tasks_batch_run_session_task_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

ALTER TABLE simplified.batch_run_session_tasks ALTER COLUMN batch_run_session_task_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME simplified.batch_run_sessions_tasks_batch_run_session_task_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
    CYCLE
);


--
-- Name: batch_run_sessions_v_last_10_days_v; Type: VIEW; Schema: simplified; Owner: postgres
--

CREATE VIEW simplified.batch_run_sessions_v_last_10_days_v AS
 SELECT batch_run_sessions_v.batch_run_session_id,
    batch_run_sessions_v.started,
    batch_run_sessions_v.started_on_dow,
    batch_run_sessions_v.ended,
    batch_run_sessions_v.marking_ended_after_overrun,
    batch_run_sessions_v.running,
    batch_run_sessions_v.run_duration_in_seconds,
    batch_run_sessions_v.run_duration_in_minutes,
    batch_run_sessions_v.run_duration_in_hours,
    batch_run_sessions_v.last_script_ran,
    batch_run_sessions_v.session_starting_script,
    batch_run_sessions_v.session_ending_script,
    batch_run_sessions_v.caller_starting,
    batch_run_sessions_v.caller_ending,
    batch_run_sessions_v.trigger_type,
    batch_run_sessions_v.triggered_by_login,
    batch_run_sessions_v.thread_id,
    batch_run_sessions_v.activity_uuid,
    batch_run_sessions_v.trigger_id
   FROM simplified.batch_run_sessions_v
  WHERE (batch_run_sessions_v.started > (CURRENT_DATE - '10 days'::interval))
  ORDER BY batch_run_sessions_v.started;


ALTER TABLE simplified.batch_run_sessions_v_last_10_days_v OWNER TO postgres;

--
-- Name: computers; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.computers (
    computer_id smallint NOT NULL,
    computer_name simplified.ntext,
    computer_os_type simplified.computer_os_type_enum NOT NULL,
    os_version_tag simplified.nnulltext,
    ram_gb simplified.wsmallint,
    device_guid uuid,
    cpu_description simplified.nnulltext,
    network_id integer NOT NULL
);


ALTER TABLE simplified.computers OWNER TO postgres;

--
-- Name: TABLE computers; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.computers IS 'machines! hosts! What these files sit on, so that when inevitably my computer goes boom, and these drives end up somewhere else, spread over networks, in a dust pile.';


--
-- Name: COLUMN computers.network_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.computers.network_id IS 'Technically a computer can be on two networks.';


--
-- Name: computers_computer_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

CREATE SEQUENCE simplified.computers_computer_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE simplified.computers_computer_id_seq OWNER TO postgres;

--
-- Name: computers_computer_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.computers_computer_id_seq OWNED BY simplified.computers.computer_id;


--
-- Name: directories; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.directories (
    directory_hash bytea NOT NULL,
    directory_path text,
    folder text,
    parent_directory_hash bytea,
    parent_folder text,
    grandparent_folder text,
    root_genre text,
    sub_genre text,
    directory_date timestamp with time zone NOT NULL,
    volume_id smallint NOT NULL,
    is_symbolic_link boolean,
    is_junction_link boolean,
    linked_path text,
    link_directory_still_exists boolean,
    scan_directory boolean DEFAULT true,
    deleted boolean,
    search_directory_id integer,
    move_id integer,
    directory_id integer NOT NULL,
    moved_out boolean,
    moved_in boolean,
    moved_to_directory_hash bytea,
    moved_to_volume_id smallint,
    moved_from_directory_hash bytea,
    moved_from_volume_id smallint,
    moved_from_directory_id integer
);


ALTER TABLE simplified.directories OWNER TO postgres;

--
-- Name: TABLE directories; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.directories IS 'Useful to avoid rescanning folders if nothing changed (datestamp managed by file system). Also useful for compressing the files table. If I make this self referential then this table shrinks too. smaller = faster reading, smaller memory, etc. Good for slow-drive systems like mine.';


--
-- Name: COLUMN directories.directory_hash; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.directory_hash IS 'Hash of the full path, including the drive (volume). Why? Because we have directory chained down to the file system. We keep one hash for 3 files, but each directory is unique.';


--
-- Name: COLUMN directories.directory_path; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.directory_path IS 'The path on the drive because we want to generate a hash on the path, not just the current folder. Should we separate the drive letter or mount point out? So as to make it more migratable?';


--
-- Name: COLUMN directories.folder; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.folder IS 'Make our life easier later and not have to parse directory_path. Maybe directory_path will go away if we build a recursive view.';


--
-- Name: COLUMN directories.parent_directory_hash; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.parent_directory_hash IS 'We have to support a null here, since the top of the hierarchy. We could make a non-value, but then a self-FK wouldn''t work.';


--
-- Name: COLUMN directories.parent_folder; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.parent_folder IS 'We want to know things like, "Is this Subs"? Also, parent folders often contain the year in the name where the actual movie file has no such detail.  Subs\Eng_1.srt need a grandparent to know what movie they attach to.';


--
-- Name: COLUMN directories.grandparent_folder; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.grandparent_folder IS 'For subs and episodes.  If parent folder is S01, what show? parent is Subs, what movie does this srt go to?';


--
-- Name: COLUMN directories.root_genre; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.root_genre IS 'Have added code to fill this in from the folders they''re in';


--
-- Name: COLUMN directories.sub_genre; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.sub_genre IS 'Using grand-parent folder as sub genre.';


--
-- Name: COLUMN directories.directory_date; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.directory_date IS '> last scanned date? Then rescan if directory date after this? (Tested: directory dates only updated at the parent, not down to grandparent, etc.';


--
-- Name: COLUMN directories.volume_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.volume_id IS 'Not a hash here, since who knows what a hash for a volume or drive letter would be. Really thinking-over, paralysis analysis, buttt, moving stuff like qbittorrent''s database is nigh impossible to a new computer, so thinking.';


--
-- Name: COLUMN directories.is_symbolic_link; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.is_symbolic_link IS 'Simpler, smaller than a 4-byte enum.';


--
-- Name: COLUMN directories.is_junction_link; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.is_junction_link IS 'For directories on Windows, you only get these types. Though the link dropper has others, there''s no such thing as a hard link in directories.';


--
-- Name: COLUMN directories.linked_path; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.linked_path IS 'For now, in case it''s outside our volume system, we just have the entire path without the drive_letter stripped.';


--
-- Name: COLUMN directories.link_directory_still_exists; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.link_directory_still_exists IS 'We have to check.  These things are going to proliferate and by flagging them we can start to reign it in.';


--
-- Name: COLUMN directories.scan_directory; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.scan_directory IS 'Set to trigger a scan of subdirectories based on date change. Set to false after scan.';


--
-- Name: COLUMN directories.deleted; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.deleted IS 'Used to clean out files that can''t exist if their parents are not found in Get-Item.';


--
-- Name: COLUMN directories.search_directory_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.search_directory_id IS 'What search path was this found under. helpful to identify "root".';


--
-- Name: COLUMN directories.move_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.move_id IS 'This directory was moved as part of this move set, along with files and subdirectories.';


--
-- Name: COLUMN directories.moved_out; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.moved_out IS 'Mark true if this is the source, and so we DO NOT expect files to exist.';


--
-- Name: COLUMN directories.moved_in; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.moved_in IS 'Arrived in offloaded, so we DO expect files to exist.';


--
-- Name: COLUMN directories.moved_to_directory_hash; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.moved_to_directory_hash IS 'So, when it''s time to migrate files, we know which came from where?';


--
-- Name: COLUMN directories.moved_from_directory_hash; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.moved_from_directory_hash IS 'So, when it''s time to migrate files, we know which came from where?';


--
-- Name: COLUMN directories.moved_from_directory_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.moved_from_directory_id IS 'Hash should do it, but dammit, I like ids.';


--
-- Name: directories_directory_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

ALTER TABLE simplified.directories ALTER COLUMN directory_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME simplified.directories_directory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: search_directories; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.search_directories (
    search_directory_id integer NOT NULL,
    search_directory character varying NOT NULL,
    extensions_to_grab character varying[],
    primary_function_of_entry character varying,
    file_names_can_be_changed boolean,
    tag character varying,
    volume_id integer,
    directly_deletable boolean DEFAULT false NOT NULL,
    size_of_drive_in_bytes bigint,
    space_left_on_drive_in_bytes bigint,
    skip_hash_generation boolean DEFAULT false
);


ALTER TABLE simplified.search_directories OWNER TO postgres;

--
-- Name: TABLE search_directories; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.search_directories IS 'paths used in scan_for_new_directories. By adding entries here, you don''t have to edit the strings in the script. Bit of a misnomer as I''m using it for move management. source to target I have to deconstruct paths from one to the other by subtracting out part and injecting another.';


--
-- Name: COLUMN search_directories.search_directory_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.search_directories.search_directory_id IS 'unique identifier; I don''t know if I''ll use it.';


--
-- Name: COLUMN search_directories.search_directory; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.search_directories.search_directory IS 'the url, or file directory, or what have you.  api path?';


--
-- Name: COLUMN search_directories.extensions_to_grab; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.search_directories.extensions_to_grab IS 'for most directories this is a list of video files: mpg, mkv, mpeg, etc. Others are .torrent, and so on.';


--
-- Name: COLUMN search_directories.primary_function_of_entry; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.search_directories.primary_function_of_entry IS 'What is this folder meant to hold for what purpose? Published, and so clean pretty names, or the downloaded torrents, that cannot be altered in name or place.';


--
-- Name: COLUMN search_directories.file_names_can_be_changed; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.search_directories.file_names_can_be_changed IS 'In O, yes you can change names. But NEVER in the torrent seeding space.';


--
-- Name: COLUMN search_directories.tag; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.search_directories.tag IS 'published, backup, payload';


--
-- Name: COLUMN search_directories.volume_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.search_directories.volume_id IS 'Probably search paths apply to a volume.';


--
-- Name: COLUMN search_directories.directly_deletable; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.search_directories.directly_deletable IS 'Avoid physically deleting any torrent linked stuff. Or temp drive stuff.';


--
-- Name: COLUMN search_directories.size_of_drive_in_bytes; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.search_directories.size_of_drive_in_bytes IS 'Trying to get a hold of how much space we have, total, left, and eventually shrinkage rate.  We must be running out soon.';


--
-- Name: COLUMN search_directories.space_left_on_drive_in_bytes; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.search_directories.space_left_on_drive_in_bytes IS 'Eventually we need to track rate of loss, and then buy more drives.';


--
-- Name: COLUMN search_directories.skip_hash_generation; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.search_directories.skip_hash_generation IS 'Set this for the temp drive stuff that constantly is thrashing, and you''ll never compare it to anything.';


--
-- Name: directories_ext_v; Type: VIEW; Schema: simplified; Owner: postgres
--

CREATE VIEW simplified.directories_ext_v AS
 WITH base AS (
         SELECT d.directory_id,
            d.directory_path,
            d.directory_path AS directory,
            replace(d.directory_path, ''''::text, ''''''::text) AS directory_escaped,
            d.directory_hash,
            d.parent_directory_hash,
            d.directory_date,
            "left"(d.directory_path, (length(d.directory_path) - (length(d.folder) + 1))) AS parent_directory,
            sd.search_directory AS search_path,
            sd.search_directory,
            replace((sd.search_directory)::text, ''''::text, ''''''::text) AS escaped_search_path,
            replace((sd.search_directory)::text, ''''::text, ''''''::text) AS search_directory_escaped,
            sd.tag AS search_path_tag,
            sd.tag AS search_directory_tag,
            d.search_directory_id AS search_path_id,
            d.search_directory_id,
            COALESCE(d.deleted, false) AS directory_deleted,
            COALESCE(d.is_symbolic_link, false) AS directory_is_symbolic_link,
            COALESCE(d.is_junction_link, false) AS directory_is_junction_link,
            NULLIF(d.linked_path, ''::text) AS linked_directory,
            d.folder,
            d.parent_folder,
            d.grandparent_folder,
            d.root_genre,
            d.volume_id,
            COALESCE(d.scan_directory, true) AS scan_directory,
            sd.skip_hash_generation,
            d.move_id,
            d.moved_in,
            d.moved_out,
            d.moved_to_directory_hash,
            d.moved_to_volume_id,
            d.moved_from_directory_hash,
            d.moved_from_volume_id,
            d.moved_from_directory_id
           FROM (simplified.directories d
             JOIN simplified.search_directories sd USING (search_directory_id))
          WHERE (d.deleted IS DISTINCT FROM true)
        ), add_layer_1 AS (
         SELECT base.directory_id,
            base.directory_path,
            base.directory,
            base.directory_escaped,
            base.directory_hash,
            base.parent_directory_hash,
            base.directory_date,
            base.parent_directory,
            base.search_path,
            base.search_directory,
            base.escaped_search_path,
            base.search_directory_escaped,
            base.search_path_tag,
            base.search_directory_tag,
            base.search_path_id,
            base.search_directory_id,
            base.directory_deleted,
            base.directory_is_symbolic_link,
            base.directory_is_junction_link,
            base.linked_directory,
            base.folder,
            base.parent_folder,
            base.grandparent_folder,
            base.root_genre,
            base.volume_id,
            base.scan_directory,
            base.skip_hash_generation,
            base.move_id,
            base.moved_in,
            base.moved_out,
            base.moved_to_directory_hash,
            base.moved_to_volume_id,
            base.moved_from_directory_hash,
            base.moved_from_volume_id,
            base.moved_from_directory_id,
                CASE
                    WHEN starts_with(base.directory_path, (base.search_path)::text) THEN true
                    ELSE false
                END AS search_path_contained,
                CASE
                    WHEN starts_with(base.directory_path, (base.search_path)::text) THEN "substring"(base.directory_path, (length((base.search_path)::text) + 2))
                    ELSE ''::text
                END AS useful_part_of_directory_path
           FROM base
        )
 SELECT add_layer_1.directory_id,
    add_layer_1.directory_path,
    add_layer_1.directory,
    add_layer_1.directory_escaped,
    add_layer_1.directory_hash,
    add_layer_1.parent_directory_hash,
    add_layer_1.directory_date,
    add_layer_1.parent_directory,
    add_layer_1.search_path,
    add_layer_1.search_directory,
    add_layer_1.escaped_search_path,
    add_layer_1.search_directory_escaped,
    add_layer_1.search_path_tag,
    add_layer_1.search_directory_tag,
    add_layer_1.search_path_id,
    add_layer_1.search_directory_id,
    add_layer_1.directory_deleted,
    add_layer_1.directory_is_symbolic_link,
    add_layer_1.directory_is_junction_link,
    add_layer_1.linked_directory,
    add_layer_1.folder,
    add_layer_1.parent_folder,
    add_layer_1.grandparent_folder,
    add_layer_1.root_genre,
    add_layer_1.volume_id,
    add_layer_1.scan_directory,
    add_layer_1.skip_hash_generation,
    add_layer_1.move_id,
    add_layer_1.moved_in,
    add_layer_1.moved_out,
    add_layer_1.moved_to_directory_hash,
    add_layer_1.moved_to_volume_id,
    add_layer_1.moved_from_directory_hash,
    add_layer_1.moved_from_volume_id,
    add_layer_1.moved_from_directory_id,
    add_layer_1.search_path_contained,
    add_layer_1.useful_part_of_directory_path,
    add_layer_1.useful_part_of_directory_path AS useful_part_of_directory,
        CASE
            WHEN (add_layer_1.useful_part_of_directory_path = ''::text) THEN 0
            ELSE ((length(add_layer_1.useful_part_of_directory_path) - length(replace(add_layer_1.useful_part_of_directory_path, '\'::text, ''::text))) + 1)
        END AS directory_depth
   FROM add_layer_1;


ALTER TABLE simplified.directories_ext_v OWNER TO postgres;

--
-- Name: VIEW directories_ext_v; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON VIEW simplified.directories_ext_v IS 'Directories combined volume and search path, and some common slices. "_ext" for extended. "directory_v" would just be an updateable straight single table view for rearranging column order.';


--
-- Name: directories_v; Type: VIEW; Schema: simplified; Owner: postgres
--

CREATE VIEW simplified.directories_v AS
 SELECT d.directory_id,
    d.directory_hash,
    d.directory_path AS directory,
    d.folder,
    d.parent_directory_hash,
    d.parent_folder,
    d.grandparent_folder,
    d.root_genre,
    d.sub_genre,
    d.directory_date,
    d.volume_id,
    d.is_symbolic_link AS directory_is_symbolic_link,
    d.is_junction_link AS directory_is_junction_link,
    d.linked_path AS linked_directory,
    d.link_directory_still_exists AS linked_directory_still_exists,
    d.scan_directory,
    d.deleted AS directory_deleted,
    d.search_directory_id,
    d.move_id,
    d.moved_in,
    d.moved_out,
    d.moved_to_directory_hash,
    d.moved_to_volume_id,
    d.moved_from_directory_hash,
    d.moved_from_volume_id,
    d.moved_from_directory_id
   FROM simplified.directories d;


ALTER TABLE simplified.directories_v OWNER TO postgres;

--
-- Name: file_attributes; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.file_attributes (
    file_attribute_id integer NOT NULL,
    column_name text NOT NULL,
    source_attribute_name text NOT NULL,
    source_attribute_population_count integer,
    source_attribute_distinct_count integer,
    files_scanned_count integer,
    data_type text,
    numeric_file_attribute_id integer,
    unitized_file_attribute_id integer,
    expanded_code_file_attribute_id integer,
    function_definition text,
    is_a_stringified_list boolean
);


ALTER TABLE simplified.file_attributes OWNER TO postgres;

--
-- Name: file_attributes_file_attribute_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

CREATE SEQUENCE simplified.file_attributes_file_attribute_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE simplified.file_attributes_file_attribute_id_seq OWNER TO postgres;

--
-- Name: file_attributes_file_attribute_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.file_attributes_file_attribute_id_seq OWNED BY simplified.file_attributes.file_attribute_id;


--
-- Name: file_extensions; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.file_extensions (
    file_extension_id smallint NOT NULL,
    file_extension text NOT NULL,
    file_extension_name text,
    file_extension_notes text,
    file_is_media_content boolean,
    file_is_video_content boolean,
    file_is_audio_content boolean,
    file_is_print_content boolean,
    file_is_subtitles boolean,
    file_is_archive boolean,
    is_lossless boolean,
    is_image_file boolean,
    file_is_structured_text boolean,
    is_game_file boolean,
    is_compiled_code boolean,
    is_script boolean,
    is_code boolean,
    developed_by character varying,
    requires_reader boolean,
    file_supports_media_file boolean,
    is_pointer_to_file boolean,
    file_is_generic boolean,
    file_is_application boolean,
    is_control_file boolean,
    file_is_spreadsheet boolean,
    is_database_file boolean,
    is_encoded_file boolean,
    is_raster_image boolean,
    is_camera_raw_image boolean,
    is_vector_image boolean,
    is_3d_image boolean,
    is_page_layout_file boolean,
    is_web_file boolean,
    is_developer_file boolean,
    is_system_file boolean,
    is_plugin boolean,
    is_font boolean,
    is_backup_file boolean,
    is_support_data_for_app boolean,
    is_gis_file boolean,
    is_cad_file boolean,
    supports_drm boolean,
    requires_own_codec boolean,
    partial_file boolean,
    is_temp_file boolean
);


ALTER TABLE simplified.file_extensions OWNER TO postgres;

--
-- Name: TABLE file_extensions; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.file_extensions IS 'I need to start (much delayed) understanding what these videos are as opposed to just hoping VLC plays them. Now I use MX Player or Windows Media Player, and pretty much everything works, except some audio codecs.';


--
-- Name: COLUMN file_extensions.file_extension; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.file_extensions.file_extension IS 'extensions on all OSs are case-insensitive.';


--
-- Name: COLUMN file_extensions.file_is_archive; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.file_extensions.file_is_archive IS 'zip, rar, xz, etc. So can''t possibly know if it''s media.';


--
-- Name: COLUMN file_extensions.is_lossless; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.file_extensions.is_lossless IS 'Like gifs, for instance.';


--
-- Name: COLUMN file_extensions.is_image_file; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.file_extensions.is_image_file IS 'Is a gif an image? sort of more a video. webp is an image.';


--
-- Name: COLUMN file_extensions.file_is_structured_text; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.file_extensions.file_is_structured_text IS 'yml, config, cfg, yaml, ini, etc.';


--
-- Name: COLUMN file_extensions.is_game_file; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.file_extensions.is_game_file IS 'An NDS for example.';


--
-- Name: COLUMN file_extensions.requires_reader; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.file_extensions.requires_reader IS 'Like mobis for instant. Can''t just open in text viewer.';


--
-- Name: COLUMN file_extensions.is_pointer_to_file; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.file_extensions.is_pointer_to_file IS '.torrent, magnet, lnk, etc.';


--
-- Name: COLUMN file_extensions.file_is_generic; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.file_extensions.file_is_generic IS 'like log, it''s not specific format or owned by anyone.';


--
-- Name: COLUMN file_extensions.file_is_application; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.file_extensions.file_is_application IS 'So not batch scripts? not sure. exe.';


--
-- Name: COLUMN file_extensions.is_control_file; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.file_extensions.is_control_file IS 'cfg, config, editorconfig, ini, etc.';


--
-- Name: COLUMN file_extensions.is_encoded_file; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.file_extensions.is_encoded_file IS 'Something from fileinfo. No idea.';


--
-- Name: file_extensions_file_extension_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

CREATE SEQUENCE simplified.file_extensions_file_extension_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE simplified.file_extensions_file_extension_id_seq OWNER TO postgres;

--
-- Name: file_extensions_file_extension_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.file_extensions_file_extension_id_seq OWNED BY simplified.file_extensions.file_extension_id;


--
-- Name: file_links_across_search_paths; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.file_links_across_search_paths (
    file_links_across_volume_id integer NOT NULL,
    file_hash bytea NOT NULL,
    payload_file_id integer,
    published_file_id integer,
    backup_file_id integer,
    CONSTRAINT at_least_one_hash CHECK ((COALESCE(payload_file_id, published_file_id, backup_file_id) IS NOT NULL))
);


ALTER TABLE simplified.file_links_across_search_paths OWNER TO postgres;

--
-- Name: TABLE file_links_across_search_paths; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.file_links_across_search_paths IS 'relating files across the three stages we support. Data Flow Stages are a thing. So downloaded payloads move to published and then to backups.  Not move, but copy.  Move like a river, in that water doesn''t "move" per se.';


--
-- Name: file_links_across_volumes_file_links_across_volume_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

ALTER TABLE simplified.file_links_across_search_paths ALTER COLUMN file_links_across_volume_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME simplified.file_links_across_volumes_file_links_across_volume_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: files; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.files (
    file_id integer NOT NULL,
    file_hash bytea NOT NULL,
    directory_hash bytea NOT NULL,
    file_name_no_ext text NOT NULL,
    final_extension text NOT NULL COLLATE simplified.ignore_both_accent_and_case,
    file_size bigint NOT NULL,
    file_date timestamp with time zone NOT NULL,
    deleted boolean,
    is_symbolic_link boolean,
    is_hard_link boolean,
    linked_path text,
    broken_link boolean,
    file_ntfs_id bytea,
    scan_for_ntfs_id boolean DEFAULT false,
    move_id integer,
    moved_out boolean,
    moved_in boolean,
    moved_to_directory_hash bytea,
    moved_to_volume_id smallint,
    moved_from_directory_hash bytea,
    moved_from_volume_id smallint,
    moved_from_file_id integer,
    has_no_ads boolean,
    file_name_broken_cant_change_ro boolean
);


ALTER TABLE simplified.files OWNER TO postgres;

--
-- Name: TABLE files; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.files IS 'All the files in our interested directories. Primarily we want the hash value so we can search for duplicates. Also we track the ntfs_id to detect change a little better, say if name changes, is it the same file?';


--
-- Name: COLUMN files.file_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.file_id IS 'Traces down to media_file_id, video_file_id';


--
-- Name: COLUMN files.file_hash; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.file_hash IS 'Fingerprint for file detecting duplicates.';


--
-- Name: COLUMN files.directory_hash; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.directory_hash IS 'Could be null if we lost the file, I suppose. or the underlying drive.';


--
-- Name: COLUMN files.file_name_no_ext; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.file_name_no_ext IS 'This in most cases is the torrent name, a wealth of detail in an attempt by the piraters to avoid collision on the leechers'' drives. A folder works too, though. I haven''t seen any collisions. But by keeping this name we hopefully reduce re-downloads. qbittorrent recognizes these, or the magnet link internally, but if I lose all the qbittorrent metadata, then I have no way to block redownloads.
The extension has no real meaning to the name of the file.';


--
-- Name: COLUMN files.final_extension; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.final_extension IS 'With torrents there are a bazillion periods, so we want the last dot and following string.  We do not use an enum since enums are 4 bytes, strings are 3 characters + a length byte.';


--
-- Name: COLUMN files.file_size; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.file_size IS 'Not space used, but reported size in bytes.';


--
-- Name: COLUMN files.file_date; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.file_date IS 'The modified date on the file, with the local time zone. We don''t keep the created timestamp.  It''s no real use except curiosity or etl analysis, which is not what simplified is for.';


--
-- Name: COLUMN files.deleted; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.deleted IS 'Flag deletion for now rather than deleting.';


--
-- Name: COLUMN files.is_symbolic_link; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.is_symbolic_link IS 'I don''t use these as VLC won''t recognize them.';


--
-- Name: COLUMN files.is_hard_link; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.is_hard_link IS 'Hard links really save space.';


--
-- Name: COLUMN files.linked_path; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.linked_path IS 'Set when you Get-Item from disk. What a link is pointing to. Check if broken_link is set.';


--
-- Name: COLUMN files.broken_link; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.broken_link IS 'Noticed Get-FileHash fails if it''s a broken link, so we set this.';


--
-- Name: COLUMN files.file_ntfs_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.file_ntfs_id IS 'Pulled using fsutil queryfileid <file_path>, comes back as ''0x0000000000000000000400000002e217''. Should be unique on a volume, but.';


--
-- Name: COLUMN files.scan_for_ntfs_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.scan_for_ntfs_id IS 'Set to true from scan_for_file_directories on new or updated file entry.  Will this be enough to detect ntfs_id changes? Will have to test.  Concerns about the directories, too. Will a directory change trigger a recycling of ntfs_ids?';


--
-- Name: COLUMN files.move_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.move_id IS 'This file was moved in a set. See moves table for details on the nature of the move, reason, from to, containing directories, search base folders, and space freed, spindles migrated';


--
-- Name: COLUMN files.moved_out; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.moved_out IS 'Mark true if this is the source, and so we DO NOT expect this file to exist, or else what was the point? No space saved, only lost across volumes!';


--
-- Name: COLUMN files.moved_in; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.moved_in IS 'Arrived in offloaded, so we DO expect files to exist.';


--
-- Name: COLUMN files.moved_to_directory_hash; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.moved_to_directory_hash IS 'So, when it''s time to migrate files, we know which came from where?';


--
-- Name: COLUMN files.moved_from_directory_hash; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.moved_from_directory_hash IS 'So, when it''s time to migrate files, we know which came from where?';


--
-- Name: COLUMN files.has_no_ads; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.has_no_ads IS 'If we do a a scan, and find no alternate data streams, we can skip a rescan.';


--
-- Name: files_alternate_data_streams; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.files_alternate_data_streams (
    file_id integer NOT NULL,
    source_of_metadata text,
    general_count integer,
    general_streamcount integer,
    general_streamkind text,
    general_streamkind_string text,
    general_streamkindid integer,
    general_uniqueid text,
    general_uniqueid_string text,
    general_videocount integer,
    general_audiocount integer,
    general_textcount integer,
    general_video_format_list text,
    general_video_format_withhint_list text,
    general_video_codec_list text,
    general_video_language_list text,
    general_audio_format_list text,
    general_audio_format_withhint_list text,
    general_audio_codec_list text,
    general_audio_language_list text,
    general_audio_channels_total integer,
    general_text_format_list text,
    general_text_format_withhint_list text,
    general_text_codec_list text,
    general_text_language_list text,
    general_format text,
    general_format_string text,
    general_format_url text,
    general_format_extensions text,
    general_format_commercial text,
    general_format_version text,
    general_filesize bigint,
    general_filesize_string text,
    general_filesize_string1 text,
    general_filesize_string2 text,
    general_filesize_string3 text,
    general_filesize_string4 text,
    general_duration numeric(15,6),
    general_duration_string text,
    general_duration_string1 text,
    general_duration_string2 text,
    general_duration_string3 text,
    general_duration_string4 text,
    general_duration_string5 text,
    general_overallbitrate integer,
    general_overallbitrate_string text,
    general_framerate numeric(10,4),
    general_framerate_string text,
    general_framecount integer,
    general_streamsize bigint,
    general_streamsize_string text,
    general_streamsize_string1 text,
    general_streamsize_string2 text,
    general_streamsize_string3 text,
    general_streamsize_string4 text,
    general_streamsize_string5 text,
    general_streamsize_proportion numeric(10,5),
    general_isstreamable text,
    general_title text,
    general_movie text,
    general_encoded_date text,
    general_encoded_application text,
    general_encoded_application_string text,
    general_encoded_library text,
    general_encoded_library_string text,
    video_count integer,
    video_streamcount integer,
    video_streamkind text,
    video_streamkind_string text,
    video_streamkindid integer,
    video_streamorder integer,
    video_id integer,
    video_id_string integer,
    video_uniqueid text,
    video_format text,
    video_format_string text,
    video_format_info text,
    video_format_url text,
    video_format_commercial text,
    video_format_profile text,
    video_format_settings text,
    video_format_settings_cabac text,
    video_format_settings_cabac_string text,
    video_format_settings_refframes integer,
    video_format_settings_refframes_string text,
    video_internetmediatype text,
    video_codecid text,
    video_codecid_url text,
    video_duration numeric(15,6),
    video_duration_string text,
    video_duration_string1 text,
    video_duration_string2 text,
    video_duration_string3 text,
    video_duration_string4 text,
    video_duration_string5 text,
    video_bitrate bigint,
    video_bitrate_string text,
    video_width integer,
    video_width_string text,
    video_height integer,
    video_height_string text,
    video_sampled_width integer,
    video_sampled_height integer,
    video_pixelaspectratio numeric(10,4),
    video_displayaspectratio numeric(10,4),
    video_displayaspectratio_string text,
    video_framerate_mode text,
    video_framerate_mode_string text,
    video_framerate_mode_original text,
    video_framerate numeric(10,4),
    video_framerate_string text,
    video_framecount integer,
    video_colorspace text,
    video_chromasubsampling text,
    video_chromasubsampling_string text,
    video_bitdepth integer,
    video_bitdepth_string text,
    video_scantype text,
    video_scantype_string text,
    "video_bits-(pixel*frame)" numeric(6,4),
    video_delay integer,
    video_delay_string3 text,
    video_delay_string4 text,
    video_delay_string5 text,
    video_delay_source text,
    video_delay_source_string text,
    video_streamsize bigint,
    video_streamsize_string text,
    video_streamsize_string1 text,
    video_streamsize_string2 text,
    video_streamsize_string3 text,
    video_streamsize_string4 text,
    video_streamsize_string5 text,
    video_streamsize_proportion numeric(10,5),
    video_encoded_library text,
    video_encoded_library_string text,
    video_encoded_library_name text,
    video_encoded_library_version text,
    video_encoded_library_settings text,
    video_language text,
    video_language_string text,
    video_language_string1 text,
    video_language_string2 text,
    video_language_string3 text,
    video_language_string4 text,
    video_default text,
    video_default_string text,
    video_forced text,
    video_forced_string text,
    video_colour_description_present text,
    video_colour_description_present_sourc text,
    video_colour_range text,
    video_colour_range_source text,
    video_colour_primaries text,
    video_colour_primaries_source text,
    video_transfer_characteristics text,
    video_transfer_characteristics_source text,
    video_matrix_coefficients text,
    video_matrix_coefficients_source text,
    video_framecount_source text,
    video_duration_source text,
    audio_count integer,
    audio_streamcount integer,
    audio_streamkind text,
    audio_streamkind_string text,
    audio_streamkindid integer,
    audio_streamorder integer,
    audio_id integer,
    audio_id_string integer,
    audio_uniqueid text,
    audio_format text,
    audio_format_string text,
    audio_format_info text,
    audio_format_url text,
    audio_format_commercial text,
    audio_format_commercial_ifany text,
    audio_format_settings_endianness text,
    audio_codecid text,
    audio_duration numeric(15,6),
    audio_duration_string text,
    audio_duration_string1 text,
    audio_duration_string2 text,
    audio_duration_string3 text,
    audio_duration_string5 text,
    audio_bitrate_mode text,
    audio_bitrate_mode_string text,
    audio_bitrate bigint,
    audio_bitrate_string text,
    "audio_channel(s)" integer,
    "audio_channel(s)_string" text,
    audio_channelpositions text,
    audio_channelpositions_string2 text,
    audio_channellayout text,
    audio_samplesperframe integer,
    audio_samplingrate integer,
    audio_samplingrate_string text,
    audio_samplingcount bigint,
    audio_framerate numeric(10,4),
    audio_framerate_string text,
    audio_compression_mode text,
    audio_compression_mode_string text,
    audio_delay integer,
    audio_delay_string3 text,
    audio_delay_string5 text,
    audio_delay_source text,
    audio_delay_source_string text,
    audio_video_delay integer,
    audio_video_delay_string3 text,
    audio_video_delay_string5 text,
    audio_streamsize bigint,
    audio_streamsize_string text,
    audio_streamsize_string1 text,
    audio_streamsize_string2 text,
    audio_streamsize_string3 text,
    audio_streamsize_string4 text,
    audio_streamsize_string5 text,
    audio_streamsize_proportion numeric(10,5),
    audio_language text,
    audio_language_string text,
    audio_language_string1 text,
    audio_language_string2 text,
    audio_language_string3 text,
    audio_language_string4 text,
    audio_servicekind text,
    audio_servicekind_string text,
    audio_default text,
    audio_default_string text,
    audio_forced text,
    audio_forced_string text,
    audio_bsid integer,
    audio_dialnorm text,
    audio_dsurmod integer,
    audio_acmod integer,
    audio_lfeon integer,
    audio_dialnorm_average text,
    audio_dialnorm_minimum text,
    audio_dialnorm_maximum text,
    audio_dialnorm_count text,
    audio_samplingcount_source text,
    audio_duration_source text,
    text_count integer,
    text_streamcount integer,
    text_streamkind text,
    text_streamkind_string text,
    text_streamkindid integer,
    text_streamorder integer,
    text_id integer,
    text_id_string integer,
    text_uniqueid text,
    text_format text,
    text_format_string text,
    text_format_commercial text,
    text_codecid text,
    text_codecid_info text,
    text_language text,
    text_language_string text,
    text_language_string1 text,
    text_language_string2 text,
    text_language_string3 text,
    text_language_string4 text,
    text_default text,
    text_default_string text,
    text_forced text,
    text_forced_string text,
    general_menucount integer,
    video_stored_height integer,
    video_framerate_num integer,
    video_framerate_den integer,
    audio_format_settings text,
    audio_format_settings_sbr text,
    audio_format_settings_sbr_string text,
    audio_format_settings_ps text,
    audio_format_settings_ps_string text,
    audio_format_additionalfeatures text,
    audio_framecount integer,
    audio_delay_string text,
    audio_delay_string1 text,
    audio_delay_string2 text,
    audio_video_delay_string text,
    audio_video_delay_string1 text,
    audio_video_delay_string2 text,
    text_duration numeric(15,6),
    text_duration_string text,
    text_duration_string1 text,
    text_duration_string2 text,
    text_duration_string3 text,
    text_duration_string5 text,
    text_bitrate bigint,
    text_bitrate_string text,
    text_framerate numeric(10,4),
    text_framerate_string text,
    text_framecount integer,
    text_elementcount integer,
    text_streamsize bigint,
    text_streamsize_string text,
    text_streamsize_string1 text,
    text_streamsize_string2 text,
    text_streamsize_string3 text,
    text_streamsize_string4 text,
    text_streamsize_string5 text,
    text_streamsize_proportion numeric(10,5),
    menu_count integer,
    menu_streamcount integer,
    menu_streamkind text,
    menu_streamkind_string text,
    menu_streamkindid integer,
    menu_chapters_pos_begin integer,
    menu_chapters_pos_end integer,
    menu_00 text,
    menu_01 text
);


ALTER TABLE simplified.files_alternate_data_streams OWNER TO postgres;

--
-- Name: files_ext_v; Type: VIEW; Schema: simplified; Owner: postgres
--

CREATE VIEW simplified.files_ext_v AS
 WITH base AS (
         SELECT f.file_id,
            f.file_hash,
            f.file_ntfs_id,
            d.directory_hash,
            d.directory_id,
            f.file_name_no_ext,
            (f.file_name_no_ext ||
                CASE
                    WHEN (f.final_extension <> ''::text) THEN ('.'::text || f.final_extension)
                    ELSE ''::text
                END) AS file_name_with_ext,
            f.final_extension,
            f.file_size,
            d.directory_path,
            d.directory,
            d.directory_escaped,
            (((d.directory_path || '\'::text) || f.file_name_no_ext) ||
                CASE
                    WHEN (f.final_extension <> ''::text) THEN ('.'::text || f.final_extension)
                    ELSE ''::text
                END) AS file_path,
            f.file_date,
            COALESCE(d.directory_deleted, false) AS directory_deleted,
            COALESCE(f.deleted, false) AS file_deleted,
            COALESCE(f.scan_for_ntfs_id, false) AS scan_file_for_ntfs_id,
            d.useful_part_of_directory_path,
            d.useful_part_of_directory,
            d.folder,
            d.parent_folder,
            d.grandparent_folder,
                CASE
                    WHEN (d.folder ~ '(S[0-90-9]|Season|Subs|original unprocessed audio)'::text) THEN d.parent_folder
                    WHEN (d.folder ~ '(S[0-90-9]|Season)'::text) THEN d.folder
                    ELSE d.parent_folder
                END AS folder_season_name,
            d.search_path_tag,
            d.search_directory_tag,
            COALESCE(sd.directly_deletable, false) AS directly_deletable,
            COALESCE(sd.skip_hash_generation, false) AS skip_hash_generation,
            d.root_genre,
            COALESCE(f.is_symbolic_link, false) AS file_is_symbolic_link,
            COALESCE(f.is_hard_link, false) AS file_is_hard_link,
            COALESCE(f.broken_link, false) AS file_is_broken_link,
            NULLIF(f.linked_path, ''::text) AS file_linked_path,
            COALESCE(f.has_no_ads, false) AS file_has_no_ads,
            d.directory_is_symbolic_link,
            d.directory_is_junction_link,
            d.move_id AS directory_move_id,
            COALESCE(d.moved_in, false) AS directory_moved_in,
            COALESCE(d.moved_out, false) AS directory_moved_out,
            f.move_id AS file_move_id,
            COALESCE(f.moved_in, false) AS file_moved_in,
            COALESCE(f.moved_out, false) AS file_moved_out,
            f.moved_from_file_id AS file_moved_from_file_id,
            f.moved_to_directory_hash AS file_moved_to_directory_hash
           FROM ((simplified.files f
             JOIN simplified.directories_ext_v d USING (directory_hash))
             JOIN simplified.search_directories sd USING (search_directory_id))
        ), add_reduced_user_logic AS (
         SELECT base.file_id,
            base.file_hash,
            base.file_ntfs_id,
            base.directory_hash,
            base.directory_id,
            base.file_name_no_ext,
            base.file_name_with_ext,
            base.final_extension,
            base.file_size,
            base.directory_path,
            base.directory,
            base.directory_escaped,
            base.file_path,
            base.file_date,
            base.directory_deleted,
            base.file_deleted,
            base.scan_file_for_ntfs_id,
            base.useful_part_of_directory_path,
            base.useful_part_of_directory,
            base.folder,
            base.parent_folder,
            base.grandparent_folder,
            base.folder_season_name,
            base.search_path_tag,
            base.search_directory_tag,
            base.directly_deletable,
            base.skip_hash_generation,
            base.root_genre,
            base.file_is_symbolic_link,
            base.file_is_hard_link,
            base.file_is_broken_link,
            base.file_linked_path,
            base.file_has_no_ads,
            base.directory_is_symbolic_link,
            base.directory_is_junction_link,
            base.directory_move_id,
            base.directory_moved_in,
            base.directory_moved_out,
            base.file_move_id,
            base.file_moved_in,
            base.file_moved_out,
            base.file_moved_from_file_id,
            base.file_moved_to_directory_hash,
                CASE
                    WHEN ((NOT base.directory_deleted) AND (NOT base.directory_is_symbolic_link) AND (NOT base.directory_is_junction_link) AND (NOT base.file_deleted) AND (NOT base.file_moved_out) AND (NOT base.file_is_symbolic_link) AND (NOT base.file_is_hard_link)) THEN true
                    ELSE false
                END AS is_real_file
           FROM base
        )
 SELECT add_reduced_user_logic.file_id,
    add_reduced_user_logic.file_hash,
    add_reduced_user_logic.file_ntfs_id,
    add_reduced_user_logic.directory_hash,
    add_reduced_user_logic.directory_id,
    add_reduced_user_logic.file_name_no_ext,
    add_reduced_user_logic.file_name_with_ext,
    add_reduced_user_logic.final_extension,
    add_reduced_user_logic.file_size,
    add_reduced_user_logic.directory_path,
    add_reduced_user_logic.directory,
    add_reduced_user_logic.directory_escaped,
    add_reduced_user_logic.file_path,
    add_reduced_user_logic.file_date,
    add_reduced_user_logic.directory_deleted,
    add_reduced_user_logic.file_deleted,
    add_reduced_user_logic.scan_file_for_ntfs_id,
    add_reduced_user_logic.useful_part_of_directory_path,
    add_reduced_user_logic.useful_part_of_directory,
    add_reduced_user_logic.folder,
    add_reduced_user_logic.parent_folder,
    add_reduced_user_logic.grandparent_folder,
    add_reduced_user_logic.folder_season_name,
    add_reduced_user_logic.search_path_tag,
    add_reduced_user_logic.search_directory_tag,
    add_reduced_user_logic.directly_deletable,
    add_reduced_user_logic.skip_hash_generation,
    add_reduced_user_logic.root_genre,
    add_reduced_user_logic.file_is_symbolic_link,
    add_reduced_user_logic.file_is_hard_link,
    add_reduced_user_logic.file_is_broken_link,
    add_reduced_user_logic.file_linked_path,
    add_reduced_user_logic.file_has_no_ads,
    add_reduced_user_logic.directory_is_symbolic_link,
    add_reduced_user_logic.directory_is_junction_link,
    add_reduced_user_logic.directory_move_id,
    add_reduced_user_logic.directory_moved_in,
    add_reduced_user_logic.directory_moved_out,
    add_reduced_user_logic.file_move_id,
    add_reduced_user_logic.file_moved_in,
    add_reduced_user_logic.file_moved_out,
    add_reduced_user_logic.file_moved_from_file_id,
    add_reduced_user_logic.file_moved_to_directory_hash,
    add_reduced_user_logic.is_real_file,
    count(*) OVER () AS how_many_files,
    count(
        CASE
            WHEN add_reduced_user_logic.is_real_file THEN 1
            ELSE NULL::integer
        END) OVER () AS how_many_real_files
   FROM add_reduced_user_logic;


ALTER TABLE simplified.files_ext_v OWNER TO postgres;

--
-- Name: VIEW files_ext_v; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON VIEW simplified.files_ext_v IS 'file info with directory detail. A lot of logic avoided re-doing everytime I want to understand what a video is.';


--
-- Name: files_file_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

CREATE SEQUENCE simplified.files_file_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE simplified.files_file_id_seq OWNER TO postgres;

--
-- Name: files_file_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.files_file_id_seq OWNED BY simplified.files.file_id;


--
-- Name: files_linked_across_search_directories_v; Type: VIEW; Schema: simplified; Owner: postgres
--

CREATE VIEW simplified.files_linked_across_search_directories_v AS
 WITH base AS (
         SELECT files.file_id,
            files.file_hash,
            files.file_name_no_ext,
            files.final_extension,
            files.deleted,
            files.is_symbolic_link,
            files.is_hard_link,
            files.linked_path,
            files.broken_link,
            files.file_size,
            files.file_date,
            search_directories.tag
           FROM ((simplified.files
             JOIN simplified.directories directories(directory_hash, directory_path, folder, parent_directory_hash, parent_folder, grandparent_folder, root_genre, sub_genre, directory_date, volume_id, is_symbolic_link, is_junction_link, linked_path, link_directory_still_exists, scan_directory, deleted, search_path_id, move_id, directory_id, moved_out, moved_in, moved_to_directory_hash, moved_to_volume_id, moved_from_directory_hash, moved_from_volume_id, moved_from_directory_id) USING (directory_hash))
             JOIN simplified.search_directories search_directories(search_path_id, search_directory, extensions_to_grab, primary_function_of_entry, file_names_can_be_changed, tag, volume_id, directly_deletable, size_of_drive_in_bytes, space_left_on_drive_in_bytes, skip_hash_generation) USING (search_path_id))
        ), payload_files AS (
         SELECT base.file_id,
            base.file_hash,
            base.file_name_no_ext,
            base.final_extension,
            base.deleted,
            base.is_symbolic_link,
            base.is_hard_link,
            base.linked_path,
            base.broken_link,
            base.file_size,
            base.file_date,
            base.tag
           FROM base
          WHERE ((base.tag)::text = 'payload'::text)
        ), published_files AS (
         SELECT base.file_id,
            base.file_hash,
            base.file_name_no_ext,
            base.final_extension,
            base.deleted,
            base.is_symbolic_link,
            base.is_hard_link,
            base.linked_path,
            base.broken_link,
            base.file_size,
            base.file_date,
            base.tag
           FROM base
          WHERE ((base.tag)::text = 'published'::text)
        ), backup_files AS (
         SELECT base.file_id,
            base.file_hash,
            base.file_name_no_ext,
            base.final_extension,
            base.deleted,
            base.is_symbolic_link,
            base.is_hard_link,
            base.linked_path,
            base.broken_link,
            base.file_size,
            base.file_date,
            base.tag
           FROM base
          WHERE ((base.tag)::text = 'backup'::text)
        ), payload_to_published AS (
         SELECT COALESCE(payload_files.file_hash, published_files.file_hash) AS file_hash,
            payload_files.file_name_no_ext AS pay_file_name_no_ext,
            published_files.file_name_no_ext AS pub_file_name_no_ext,
            payload_files.final_extension AS pay_final_extension,
            published_files.final_extension AS pub_final_extension,
            payload_files.file_id AS payload_file_id,
            payload_files.deleted AS payload_file_deleted,
            published_files.file_id AS published_file_id,
            published_files.deleted AS published_file_deleted
           FROM (payload_files
             FULL JOIN published_files USING (file_hash))
        ), payload_pub_to_backup AS (
         SELECT COALESCE(a.file_hash, b.file_hash) AS file_hash,
            a.pay_file_name_no_ext,
            a.pub_file_name_no_ext,
            b.file_name_no_ext,
            a.payload_file_id,
            a.published_file_id,
            b.file_id AS backup_file_id,
            a.payload_file_deleted,
            a.published_file_deleted,
            b.deleted AS backup_file_deleted
           FROM (payload_to_published a
             FULL JOIN backup_files b USING (file_hash))
        )
 SELECT payload_pub_to_backup.file_hash,
    payload_pub_to_backup.pay_file_name_no_ext,
    payload_pub_to_backup.pub_file_name_no_ext,
    payload_pub_to_backup.file_name_no_ext,
    payload_pub_to_backup.payload_file_id,
    payload_pub_to_backup.published_file_id,
    payload_pub_to_backup.backup_file_id,
    payload_pub_to_backup.payload_file_deleted,
    payload_pub_to_backup.published_file_deleted,
    payload_pub_to_backup.backup_file_deleted
   FROM payload_pub_to_backup;


ALTER TABLE simplified.files_linked_across_search_directories_v OWNER TO postgres;

--
-- Name: files_media_info; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.files_media_info (
    file_id integer NOT NULL,
    general_video_format_list text,
    general_audio_codec_list text,
    general_text_format_list text,
    general_filenameextension text,
    general_format text,
    general_format_extensions text,
    general_duration text,
    general_duration_string1 text,
    general_overallbitrate_string text,
    general_framerate_string text,
    general_title text,
    general_encoded_date text,
    general_file_created_date text,
    general_encoded_application text,
    general_encoded_library_string text,
    video_format_profile text,
    video_internetmediatype text,
    video_codecid text,
    video_duration_string1 text,
    video_bitrate_string text,
    video_width text,
    video_height text,
    video_displayaspectratio text,
    video_framerate_mode text,
    video_framerate_mode_original text,
    video_encoded_library_string text,
    video_encoded_library_version text,
    video_language text,
    audio_format_commercial text,
    audio_codecid text,
    audio_bitrate_mode_string text,
    audio_channel_s text,
    audio_channelpositions_string2 text,
    audio_channellayout text,
    audio_delay text,
    audio_language text,
    audio_dsurmod text,
    audio_dialnorm_average text,
    text_language text,
    text_default text,
    text_forced text,
    general_format_profile text,
    general_internetmediatype text,
    general_codecid text,
    general_codecid_string text,
    general_codecid_compatible text,
    general_overallbitrate_mode_string text,
    general_tagged_date text,
    video_bitrate_maximum_string text,
    video_encoded_date text,
    video_tagged_date text,
    video_codecconfigurationbox text,
    general_format_info text,
    general_istruncated text,
    video_format_settings_matrix_string text,
    video_codecid_hint text,
    audio_dynrng_average text,
    audio_dynrng_minimum text,
    audio_dynrng_maximum text,
    video_muxingmode text,
    video_stored_height text,
    video_title text,
    text_title text,
    audio_title text,
    audio_encoded_library_string text,
    text_muxingmode text,
    video_stored_width text,
    video_delay_string text,
    audio_format_version text,
    audio_format_profile text,
    audio_format_settings_mode text,
    audio_format_settings_modeextension text,
    audio_internetmediatype text,
    audio_codecid_hint text,
    audio_interleave_preload_string text,
    audio_encoded_library_settings text,
    audio_delay_string text,
    general_album text,
    video_bitrate_mode_string text,
    video_pixelaspectratio_original text,
    video_displayaspectratio_original text,
    video_buffersize text,
    general_collection text,
    general_season text,
    general_part text,
    general_track text,
    general_performer text,
    general_director text,
    general_screenplayby text,
    general_genre text,
    general_contenttype text,
    general_description text,
    general_recorded_date text,
    general_tvnetworkname text,
    general_part_id text,
    general_longdescription text,
    video_standard text,
    video_format_version text,
    video_scanorder_string text,
    video_originalsourcemedium text,
    general_summary text,
    general_productionstudio text,
    general_audio text,
    general_cc text,
    general_chapters text,
    general_encoded_by text,
    general_released_date text,
    general_artist text,
    general_subtitles text,
    general_writing_frontend text,
    audio_channel_s_original_string text,
    general_synopsis text,
    general_wm_mediacredits text,
    general_wm_mediaisdelay text,
    general_wm_mediaisfinale text,
    general_wm_mediaislive text,
    general_wm_mediaismovie text,
    general_wm_mediaispremiere text,
    general_wm_mediaisrepeat text,
    general_wm_mediaissap text,
    general_wm_mediaissport text,
    general_wm_mediaisstereo text,
    general_wm_mediaissubtitled text,
    general_wm_mediaistape text,
    general_wm_medianetworkaffiliation text,
    general_wm_mediaoriginalbroadcastdatetim text,
    general_wm_mediaoriginalchannel text,
    general_wm_mediaoriginalruntime text,
    general_wm_parentalrating text,
    general_wm_provider text,
    general_wm_subtitledescription text,
    general_wm_wmrvseriesuid text,
    general_wm_wmrvwatched text,
    video_source_delay text,
    general_rating text,
    general_overallbitrate_maximum_string text,
    general_copyright text,
    video_codecid_description text,
    video_hdr_format_string text
);


ALTER TABLE simplified.files_media_info OWNER TO postgres;

--
-- Name: files_media_info_ext_v; Type: VIEW; Schema: simplified; Owner: postgres
--

CREATE VIEW simplified.files_media_info_ext_v AS
 SELECT files_media_info.file_id,
    files.final_extension,
    files.file_path,
    files_media_info.general_title,
    files_media_info.audio_title,
    files_media_info.text_title,
    files_media_info.video_title,
    files_media_info.general_filenameextension,
    files_media_info.general_encoded_date,
    files_media_info.general_tagged_date,
    files_media_info.general_file_created_date,
    files_media_info.general_recorded_date,
    files_media_info.video_tagged_date,
    files_media_info.video_encoded_date,
    files_media_info.general_released_date,
    files_media_info.general_duration AS duration_in_ms,
    files_media_info.general_duration_string1 AS duration_long_display,
    files_media_info.video_duration_string1,
    files_media_info.general_longdescription,
    files_media_info.general_synopsis,
    files_media_info.general_summary,
    files_media_info.video_width,
    files_media_info.video_stored_width,
    files_media_info.video_height,
    files_media_info.video_stored_height,
    files_media_info.video_displayaspectratio,
    files_media_info.video_displayaspectratio_original,
    files_media_info.video_pixelaspectratio_original,
    files_media_info.general_format,
    files_media_info.general_video_format_list,
    files_media_info.video_codecid,
    files_media_info.general_codecid,
    files_media_info.general_overallbitrate_mode_string,
    files_media_info.general_codecid_compatible,
    files_media_info.general_codecid_string,
    files_media_info.video_codecconfigurationbox,
    files_media_info.video_format_profile,
    files_media_info.video_internetmediatype,
    files_media_info.general_internetmediatype,
    files_media_info.video_encoded_library_string,
    files_media_info.video_bitrate_string,
    files_media_info.general_overallbitrate_string,
    files_media_info.general_framerate_string,
    files_media_info.video_framerate_mode,
    files_media_info.video_framerate_mode_original,
    files_media_info.general_format_extensions,
    files_media_info.video_buffersize,
    files_media_info.video_standard,
    files_media_info.video_language,
    files_media_info.video_source_delay,
    files_media_info.video_bitrate_maximum_string,
    files_media_info.general_audio_codec_list,
    files_media_info.audio_format_commercial,
    files_media_info.audio_codecid,
    files_media_info.audio_internetmediatype,
    files_media_info.audio_bitrate_mode_string,
    files_media_info.general_audio,
    files_media_info.audio_language,
    files_media_info.audio_channel_s AS audio_channels,
    files_media_info.audio_channelpositions_string2 AS audio_channelpositions,
    files_media_info.audio_channellayout,
    files_media_info.audio_dsurmod,
    files_media_info.audio_format_settings_mode,
    files_media_info.audio_format_settings_modeextension,
    files_media_info.audio_delay_string,
    files_media_info.audio_delay,
    files_media_info.audio_dialnorm_average,
    files_media_info.audio_encoded_library_settings,
    files_media_info.audio_interleave_preload_string,
    files_media_info.audio_codecid_hint,
    files_media_info.audio_format_profile,
    files_media_info.audio_format_version,
    files_media_info.general_text_format_list,
    files_media_info.text_default,
    files_media_info.text_forced,
    files_media_info.text_language,
    files_media_info.general_encoded_application,
    files_media_info.general_encoded_library_string,
    files_media_info.video_encoded_library_version,
    files_media_info.general_part_id,
    files_media_info.general_tvnetworkname,
    files_media_info.general_description,
    files_media_info.general_contenttype,
    files_media_info.general_genre,
    files_media_info.general_screenplayby,
    files_media_info.general_director,
    files_media_info.general_performer,
    files_media_info.general_track,
    files_media_info.general_part,
    files_media_info.general_season,
    files_media_info.general_collection,
    files_media_info.general_album,
    files_media_info.video_bitrate_mode_string,
    files_media_info.video_delay_string,
    files_media_info.text_muxingmode,
    files_media_info.audio_encoded_library_string,
    files_media_info.video_muxingmode,
    files_media_info.audio_dynrng_maximum,
    files_media_info.audio_dynrng_minimum,
    files_media_info.audio_dynrng_average,
    files_media_info.video_codecid_hint,
    files_media_info.video_format_settings_matrix_string,
    files_media_info.general_istruncated,
    files_media_info.general_format_info,
    files_media_info.general_format_profile,
    files_media_info.general_writing_frontend,
    files_media_info.general_artist,
    files_media_info.video_format_version,
    files_media_info.video_scanorder_string,
    files_media_info.video_codecid_description,
    files_media_info.general_copyright,
    files_media_info.general_overallbitrate_maximum_string,
    files_media_info.general_rating,
    files_media_info.video_hdr_format_string,
    files_media_info.general_encoded_by,
    files_media_info.general_cc,
    files_media_info.audio_channel_s_original_string,
    files_media_info.general_chapters,
    files_media_info.general_subtitles,
    files_media_info.general_productionstudio,
    files_media_info.video_originalsourcemedium,
    files_media_info.general_wm_wmrvwatched,
    files_media_info.general_wm_wmrvseriesuid,
    files_media_info.general_wm_subtitledescription,
    files_media_info.general_wm_provider,
    files_media_info.general_wm_parentalrating,
    files_media_info.general_wm_mediaoriginalruntime,
    files_media_info.general_wm_mediaoriginalchannel,
    files_media_info.general_wm_mediaoriginalbroadcastdatetim,
    files_media_info.general_wm_medianetworkaffiliation,
    files_media_info.general_wm_mediaistape,
    files_media_info.general_wm_mediaissubtitled,
    files_media_info.general_wm_mediaisstereo,
    files_media_info.general_wm_mediaissport,
    files_media_info.general_wm_mediaissap,
    files_media_info.general_wm_mediaisrepeat,
    files_media_info.general_wm_mediaispremiere,
    files_media_info.general_wm_mediaismovie,
    files_media_info.general_wm_mediaislive,
    files_media_info.general_wm_mediaisfinale,
    files_media_info.general_wm_mediaisdelay,
    files_media_info.general_wm_mediacredits
   FROM (simplified.files_media_info
     JOIN simplified.files_ext_v files USING (file_id));


ALTER TABLE simplified.files_media_info_ext_v OWNER TO postgres;

--
-- Name: files_media_info_v; Type: VIEW; Schema: simplified; Owner: postgres
--

CREATE VIEW simplified.files_media_info_v AS
 SELECT files_media_info.file_id,
    files_media_info.general_title,
    files_media_info.audio_title,
    files_media_info.text_title,
    files_media_info.video_title,
    files_media_info.general_filenameextension,
    files_media_info.general_encoded_date,
    files_media_info.general_tagged_date,
    files_media_info.general_file_created_date,
    files_media_info.general_recorded_date,
    files_media_info.video_tagged_date,
    files_media_info.video_encoded_date,
    files_media_info.general_released_date,
    files_media_info.general_duration AS duration_in_ms,
    files_media_info.general_duration_string1 AS duration_long_display,
    files_media_info.video_duration_string1,
    files_media_info.general_longdescription,
    files_media_info.general_synopsis,
    files_media_info.general_summary,
    files_media_info.general_wm_subtitledescription,
    files_media_info.video_width,
    files_media_info.video_stored_width,
    files_media_info.video_height,
    files_media_info.video_stored_height,
    files_media_info.video_displayaspectratio,
    files_media_info.video_displayaspectratio_original,
    files_media_info.video_pixelaspectratio_original,
    files_media_info.general_format,
    files_media_info.general_video_format_list,
    files_media_info.video_codecid,
    files_media_info.general_codecid,
    files_media_info.general_overallbitrate_mode_string,
    files_media_info.general_codecid_compatible,
    files_media_info.general_codecid_string,
    files_media_info.video_codecconfigurationbox,
    files_media_info.video_format_profile,
    files_media_info.video_internetmediatype,
    files_media_info.general_internetmediatype,
    files_media_info.video_encoded_library_string,
    files_media_info.video_bitrate_string,
    files_media_info.general_overallbitrate_string,
    files_media_info.general_framerate_string,
    files_media_info.video_framerate_mode,
    files_media_info.video_framerate_mode_original,
    files_media_info.general_format_extensions,
    files_media_info.video_buffersize,
    files_media_info.video_standard,
    files_media_info.video_language,
    files_media_info.video_source_delay,
    files_media_info.video_bitrate_maximum_string,
    files_media_info.general_audio_codec_list,
    files_media_info.audio_format_commercial,
    files_media_info.audio_codecid,
    files_media_info.audio_internetmediatype,
    files_media_info.audio_bitrate_mode_string,
    files_media_info.general_audio,
    files_media_info.audio_language,
    files_media_info.audio_channel_s AS audio_channels,
    files_media_info.audio_channelpositions_string2 AS audio_channelpositions,
    files_media_info.audio_channellayout,
    files_media_info.audio_dsurmod,
    files_media_info.audio_format_settings_mode,
    files_media_info.audio_format_settings_modeextension,
    files_media_info.audio_delay_string,
    files_media_info.audio_delay,
    files_media_info.audio_dialnorm_average,
    files_media_info.audio_encoded_library_settings,
    files_media_info.audio_interleave_preload_string,
    files_media_info.audio_codecid_hint,
    files_media_info.audio_format_profile,
    files_media_info.audio_format_version,
    files_media_info.general_text_format_list,
    files_media_info.text_default,
    files_media_info.text_forced,
    files_media_info.text_language,
    files_media_info.general_encoded_application,
    files_media_info.general_encoded_library_string,
    files_media_info.video_encoded_library_version,
    files_media_info.general_part_id,
    files_media_info.general_tvnetworkname,
    files_media_info.general_description,
    files_media_info.general_contenttype,
    files_media_info.general_genre,
    files_media_info.general_screenplayby,
    files_media_info.general_director,
    files_media_info.general_performer,
    files_media_info.general_track,
    files_media_info.general_part,
    files_media_info.general_season,
    files_media_info.general_collection,
    files_media_info.general_album,
    files_media_info.video_bitrate_mode_string,
    files_media_info.video_delay_string,
    files_media_info.text_muxingmode,
    files_media_info.audio_encoded_library_string,
    files_media_info.video_muxingmode,
    files_media_info.audio_dynrng_maximum,
    files_media_info.audio_dynrng_minimum,
    files_media_info.audio_dynrng_average,
    files_media_info.video_codecid_hint,
    files_media_info.video_format_settings_matrix_string,
    files_media_info.general_istruncated,
    files_media_info.general_format_info,
    files_media_info.general_format_profile,
    files_media_info.general_writing_frontend,
    files_media_info.general_artist,
    files_media_info.video_format_version,
    files_media_info.video_scanorder_string,
    files_media_info.video_codecid_description,
    files_media_info.general_copyright,
    files_media_info.general_overallbitrate_maximum_string,
    files_media_info.general_rating,
    files_media_info.video_hdr_format_string,
    files_media_info.general_encoded_by,
    files_media_info.general_cc,
    files_media_info.audio_channel_s_original_string,
    files_media_info.general_chapters,
    files_media_info.general_subtitles,
    files_media_info.general_productionstudio,
    files_media_info.video_originalsourcemedium,
    files_media_info.general_wm_wmrvwatched,
    files_media_info.general_wm_wmrvseriesuid,
    files_media_info.general_wm_provider,
    files_media_info.general_wm_parentalrating,
    files_media_info.general_wm_mediaoriginalruntime,
    files_media_info.general_wm_mediaoriginalchannel,
    files_media_info.general_wm_mediaoriginalbroadcastdatetim,
    files_media_info.general_wm_medianetworkaffiliation,
    files_media_info.general_wm_mediaistape,
    files_media_info.general_wm_mediaissubtitled,
    files_media_info.general_wm_mediaisstereo,
    files_media_info.general_wm_mediaissport,
    files_media_info.general_wm_mediaissap,
    files_media_info.general_wm_mediaisrepeat,
    files_media_info.general_wm_mediaispremiere,
    files_media_info.general_wm_mediaismovie,
    files_media_info.general_wm_mediaislive,
    files_media_info.general_wm_mediaisfinale,
    files_media_info.general_wm_mediaisdelay,
    files_media_info.general_wm_mediacredits
   FROM simplified.files_media_info;


ALTER TABLE simplified.files_media_info_v OWNER TO postgres;

--
-- Name: files_mysteries; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.files_mysteries (
    file_id integer NOT NULL,
    principal_detective character varying,
    actor_playing_detective character varying,
    based_on_novel character varying,
    novel_author character varying
);


ALTER TABLE simplified.files_mysteries OWNER TO postgres;

--
-- Name: TABLE files_mysteries; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.files_mysteries IS 'Attributes specific to mysteries, one of my weaknesses.  I don''t want to add these to files or video_files.';


--
-- Name: COLUMN files_mysteries.file_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files_mysteries.file_id IS 'Links back to media? or files? or video?  I suppose I want prints, ebooks, too, and audio books.  But all media.';


--
-- Name: COLUMN files_mysteries.principal_detective; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files_mysteries.principal_detective IS 'Investigator, DI, DS, Seargant.  These are quite how I proceed through a set of mysteries, following one episode, movie, after the other.';


--
-- Name: COLUMN files_mysteries.actor_playing_detective; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files_mysteries.actor_playing_detective IS 'These do change.';


--
-- Name: COLUMN files_mysteries.based_on_novel; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files_mysteries.based_on_novel IS 'or short story';


--
-- Name: COLUMN files_mysteries.novel_author; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files_mysteries.novel_author IS 'Conan Doyle, Agatha Christie.';


--
-- Name: files_v; Type: VIEW; Schema: simplified; Owner: postgres
--

CREATE VIEW simplified.files_v AS
 SELECT files.file_id,
    files.file_hash,
    files.directory_hash,
    files.file_name_no_ext,
    files.final_extension,
    files.file_size,
    files.file_date,
    files.deleted AS file_deleted,
    files.is_symbolic_link AS file_is_symbolic_link,
    files.is_hard_link AS file_is_hard_link,
    files.broken_link AS file_is_broken_link,
    files.linked_path,
    files.file_ntfs_id,
    files.scan_for_ntfs_id AS scan_file_for_ntfs_id,
    files.has_no_ads,
    files.move_id,
    files.moved_out,
    files.moved_in,
    files.moved_from_volume_id,
    files.moved_from_file_id,
    files.moved_from_directory_hash,
    files.moved_to_volume_id,
    files.moved_to_directory_hash
   FROM simplified.files;


ALTER TABLE simplified.files_v OWNER TO postgres;

--
-- Name: genres; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.genres (
    genre_id integer NOT NULL,
    genre character varying NOT NULL,
    genre_function text,
    genre_level integer DEFAULT 1,
    directory_example character varying
);


ALTER TABLE simplified.genres OWNER TO postgres;

--
-- Name: TABLE genres; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.genres IS 'genres used in folders to group movies together. Probably all the genres eventually.  I don''t have folders the way standard movie genres go, like a Drama for instance. That''s too generic.';


--
-- Name: genres_genre_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

ALTER TABLE simplified.genres ALTER COLUMN genre_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME simplified.genres_genre_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: internet_service_providers; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.internet_service_providers (
    internet_service_provider_id smallint NOT NULL,
    internet_service_provider_name simplified.ntext,
    service_type simplified.isp_service_type_enum NOT NULL,
    service_area text,
    customer_type simplified.isp_customer_type_enum,
    monthly_service_price money,
    modem_rental_price money,
    download_speed_mbps simplified.wsmallint,
    upload_speed_mbps simplified.wsmallint,
    bundle simplified.nnulltext,
    bill_amount money
);


ALTER TABLE simplified.internet_service_providers OWNER TO postgres;

--
-- Name: TABLE internet_service_providers; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.internet_service_providers IS 'My network is on this ISP. Tada?  You could change ISPs and not be a different thing as far as computers, etc. So not properly a hierarchy.';


--
-- Name: COLUMN internet_service_providers.bill_amount; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.internet_service_providers.bill_amount IS 'What I have on the bill recently. Not some master super helpful, just the cost I paid, so certainly not useful for multi-user.';


--
-- Name: internet_service_providers_internet_service_provider_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

CREATE SEQUENCE simplified.internet_service_providers_internet_service_provider_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE simplified.internet_service_providers_internet_service_provider_id_seq OWNER TO postgres;

--
-- Name: internet_service_providers_internet_service_provider_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.internet_service_providers_internet_service_provider_id_seq OWNED BY simplified.internet_service_providers.internet_service_provider_id;


--
-- Name: local_networks; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.local_networks (
    local_network_id smallint NOT NULL,
    local_network_name simplified.ntext,
    brand_name simplified.nnulltext,
    product_name simplified.nnulltext,
    device_manager_network_name simplified.nnulltext,
    wireless_overridding_network_name simplified.nnulltext,
    router_mac_address macaddr8,
    internet_port_mac_address macaddr8,
    wi_fi_address macaddr8,
    physical_address macaddr8,
    serves_on_ipv4 inet,
    internet_port_ip4 inet,
    ssid simplified.nnulltext,
    internet_service_provider_id smallint NOT NULL
);


ALTER TABLE simplified.local_networks OWNER TO postgres;

--
-- Name: TABLE local_networks; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.local_networks IS 'My NETGEAR router seems to be all my computer sees. But what is the DLINK name on the wireless?? Anybody? The Nighthawk is SSID NETGEAR47, not DLINK';


--
-- Name: local_networks_local_network_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

CREATE SEQUENCE simplified.local_networks_local_network_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE simplified.local_networks_local_network_id_seq OWNER TO postgres;

--
-- Name: local_networks_local_network_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.local_networks_local_network_id_seq OWNED BY simplified.local_networks.local_network_id;


--
-- Name: media_files; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.media_files (
    media_file_id integer NOT NULL,
    original_file_name text NOT NULL,
    cleaned_file_name text,
    cleaned_file_name_with_year text GENERATED ALWAYS AS (((((cleaned_file_name || ' '::text) || '('::text) || (release_year)::text) || ')'::text)) STORED,
    cleaned_file_name_into_title text,
    manually_cleaned_file_name_do_not_overwrite boolean,
    autocleaned_file_name text,
    autoclean_methods_applied text[],
    file_name_no_ext text NOT NULL,
    tags_extracted_from_base_name text[],
    parent_folder_name text NOT NULL,
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


ALTER TABLE simplified.media_files OWNER TO postgres;

--
-- Name: TABLE media_files; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.media_files IS 'Tear apart the "files" entry into parts, things we can derive from the file name.  Not so much internal data; that (for now) is pushed down to video_files, since supposedly I might store other media files. Possibly I could store info from imdb and such here?  No opinion yet.  I do like one table per concern, so probably the metadata from external might not go here.';


--
-- Name: COLUMN media_files.media_file_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.media_files.media_file_id IS 'This needs to keep updating for new until a truncate with restart is run. Stage id'' for now get reset, so joining back from master won''t really work, so we''ll have a think and maybe a separate table the master links back to with perm sequence ids.  It''s just that testing will cause bloat. Note that I don''t see any reason for these to be super keys that are from a master sequence.';


--
-- Name: COLUMN media_files.original_file_name; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.media_files.original_file_name IS 'A copy of txt from files, not the title, since we don''t know for sure what that is yet.';


--
-- Name: COLUMN media_files.cleaned_file_name_with_year; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.media_files.cleaned_file_name_with_year IS 'Generated, and this should be unique, unless multiple versions editions of the file, director''s cut, etc.';


--
-- Name: moves; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.moves (
    move_id integer NOT NULL,
    move_started timestamp with time zone NOT NULL,
    move_ended timestamp with time zone,
    bytes_moved bigint,
    from_directory_or_file text NOT NULL,
    to_directory_or_file text NOT NULL,
    files_moved integer,
    move_reason text NOT NULL,
    from_base_directory character varying,
    from_volume_id smallint,
    from_search_directory_id integer,
    to_base_directory character varying,
    to_volume_id smallint,
    to_search_directory_id integer,
    description_why_reason_applies character varying,
    note text
);


ALTER TABLE simplified.moves OWNER TO postgres;

--
-- Name: TABLE moves; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.moves IS 'Track all the meta about amove of a directory off one volume to another, especially why.  The sum gives me an idea of how much space I''ve recovered for more published unseen stuff.';


--
-- Name: COLUMN moves.move_reason; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.moves.move_reason IS 'Seen, Won''t Watch, Corrupt';


--
-- Name: COLUMN moves.description_why_reason_applies; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.moves.description_why_reason_applies IS 'So for "Won''t Watch", why won''t we watch. Woke? Breaks 4th wall? Fembots?';


--
-- Name: COLUMN moves.note; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.moves.note IS '"This was a great film, but it''s 26 GB!  I can''t keep it in published. Maybe should get the link back to work, but."';


--
-- Name: moves_move_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

CREATE SEQUENCE simplified.moves_move_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE simplified.moves_move_id_seq OWNER TO postgres;

--
-- Name: moves_move_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.moves_move_id_seq OWNED BY simplified.moves.move_id;


--
-- Name: network_adapters; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.network_adapters (
    network_adapter_id smallint NOT NULL,
    network_adapter_name simplified.ntext,
    service_name simplified.nnulltext,
    physical_address macaddr8,
    ipv4 inet,
    pci_bus_no smallint,
    device_no smallint,
    function_no smallint,
    bus_reported_device_desc simplified.nnulltext,
    local_network_id smallint NOT NULL
);


ALTER TABLE simplified.network_adapters OWNER TO postgres;

--
-- Name: TABLE network_adapters; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.network_adapters IS 'Is a network adapter a physical thing or is it the Windows driver?  I can''t tell.';


--
-- Name: network_adapters_network_adapter_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

CREATE SEQUENCE simplified.network_adapters_network_adapter_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE simplified.network_adapters_network_adapter_id_seq OWNER TO postgres;

--
-- Name: network_adapters_network_adapter_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.network_adapters_network_adapter_id_seq OWNED BY simplified.network_adapters.network_adapter_id;


--
-- Name: scheduled_task_run_sets; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.scheduled_task_run_sets (
    scheduled_task_run_set_id integer NOT NULL,
    scheduled_task_run_set_name text NOT NULL,
    run_start_time time without time zone DEFAULT '00:00:00'::time without time zone NOT NULL,
    reason_why text,
    last_generated timestamp with time zone,
    last_run timestamp with time zone,
    log_batch_run_session boolean DEFAULT true NOT NULL
);


ALTER TABLE simplified.scheduled_task_run_sets OWNER TO postgres;

--
-- Name: TABLE scheduled_task_run_sets; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.scheduled_task_run_sets IS 'Use these to generate all the tasks. These are the Windows Task Scheduler folders and the set of tasks that it flows through, from some start time (daily) to the next.';


--
-- Name: COLUMN scheduled_task_run_sets.run_start_time; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.scheduled_task_run_sets.run_start_time IS 'If null, time start defaults to 2047';


--
-- Name: COLUMN scheduled_task_run_sets.log_batch_run_session; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.scheduled_task_run_sets.log_batch_run_session IS 'The looping stuff is blowing up the active run session singleton so we no longer get the file run start and stop.';


--
-- Name: scheduled_task_run_sets_scheduled_task_run_set_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

CREATE SEQUENCE simplified.scheduled_task_run_sets_scheduled_task_run_set_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE simplified.scheduled_task_run_sets_scheduled_task_run_set_id_seq OWNER TO postgres;

--
-- Name: scheduled_task_run_sets_scheduled_task_run_set_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.scheduled_task_run_sets_scheduled_task_run_set_id_seq OWNED BY simplified.scheduled_task_run_sets.scheduled_task_run_set_id;


--
-- Name: scheduled_tasks; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.scheduled_tasks (
    scheduled_task_id integer NOT NULL,
    scheduled_task_root_directory text NOT NULL,
    scheduled_task_name text NOT NULL,
    order_in_set numeric(12,8) NOT NULL,
    scheduled_task_run_set_id integer NOT NULL,
    must_run_after_scheduled_task_name text,
    script_path_to_run text,
    method_name text DEFAULT 'PowerShell'::text,
    append_argument_string text,
    scheduled_task_short_description text,
    execution_time_limit character varying DEFAULT 'PT2H'::character varying,
    repeat boolean,
    repeat_interval character varying,
    repeat_duration character varying,
    stop_when_repeat_duration_reached boolean,
    trigger_execution_limit character varying,
    is_enabled boolean DEFAULT true
);


ALTER TABLE simplified.scheduled_tasks OWNER TO postgres;

--
-- Name: TABLE scheduled_tasks; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.scheduled_tasks IS 'Definitions, limited as they are of the tasks to generate and register to Windows Task Scheduler, and the order they are dependent. NOTE: ran over 2 hours! Setting to 3';


--
-- Name: COLUMN scheduled_tasks.scheduled_task_root_directory; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.scheduled_tasks.scheduled_task_root_directory IS 'The root folder, for now always "FilmCab", generally the project name.';


--
-- Name: COLUMN scheduled_tasks.scheduled_task_name; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.scheduled_tasks.scheduled_task_name IS 'The unique name of the task, must be identical to the script name.';


--
-- Name: COLUMN scheduled_tasks.order_in_set; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.scheduled_tasks.order_in_set IS 'This is what I really use to order the linkage of event triggers between tasks in the generation script.';


--
-- Name: COLUMN scheduled_tasks.scheduled_task_run_set_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.scheduled_tasks.scheduled_task_run_set_id IS 'This is the subfolder under the root_directory in the Task Scheduler.';


--
-- Name: COLUMN scheduled_tasks.must_run_after_scheduled_task_name; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.scheduled_tasks.must_run_after_scheduled_task_name IS 'Documentation for now. Possibly run based on a constructed dependency for order.';


--
-- Name: COLUMN scheduled_tasks.script_path_to_run; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.scheduled_tasks.script_path_to_run IS 'Not sure this is used any more. Should delete.';


--
-- Name: COLUMN scheduled_tasks.method_name; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.scheduled_tasks.method_name IS 'Ignored; always PowerShell';


--
-- Name: COLUMN scheduled_tasks.append_argument_string; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.scheduled_tasks.append_argument_string IS 'Not used.';


--
-- Name: COLUMN scheduled_tasks.scheduled_task_short_description; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.scheduled_tasks.scheduled_task_short_description IS 'Gets put in the Task definition''s Description attribute.';


--
-- Name: COLUMN scheduled_tasks.execution_time_limit; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.scheduled_tasks.execution_time_limit IS 'For Scheduled Task XML in Windows Task Scheduler Format.';


--
-- Name: COLUMN scheduled_tasks.repeat; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.scheduled_tasks.repeat IS 'Repeat this task after started on schedule, every n and until n has passed';


--
-- Name: COLUMN scheduled_tasks.repeat_interval; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.scheduled_tasks.repeat_interval IS '"PT1H", for example, every hour after triggered BY SCHEDULE. note that trigger by user does not start the repetitions.';


--
-- Name: COLUMN scheduled_tasks.repeat_duration; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.scheduled_tasks.repeat_duration IS '"P1D", so stop after a day, so very common.';


--
-- Name: scheduled_tasks_ext_v; Type: VIEW; Schema: simplified; Owner: postgres
--

CREATE VIEW simplified.scheduled_tasks_ext_v AS
 WITH base AS (
         SELECT st.scheduled_task_id,
            strs.scheduled_task_run_set_id,
            strs.scheduled_task_run_set_name,
            st.order_in_set,
            strs.run_start_time,
            st.scheduled_task_root_directory,
            (((('\'::text || st.scheduled_task_root_directory) || '\'::text) || strs.scheduled_task_run_set_name) || '\'::text) AS scheduled_task_directory,
            ((((('\'::text || st.scheduled_task_root_directory) || '\'::text) || strs.scheduled_task_run_set_name) || '\'::text) || st.scheduled_task_name) AS uri,
            ((((('\'::text || st.scheduled_task_root_directory) || '\'::text) || strs.scheduled_task_run_set_name) || '\'::text) || st.scheduled_task_name) AS scheduled_task_path,
            lag(st.scheduled_task_name) OVER (PARTITION BY strs.scheduled_task_run_set_id ORDER BY st.order_in_set) AS previous_task_name,
            lag(((((('\'::text || st.scheduled_task_root_directory) || '\'::text) || strs.scheduled_task_run_set_name) || '\'::text) || st.scheduled_task_name)) OVER (ORDER BY st.scheduled_task_run_set_id, st.order_in_set) AS previous_uri,
            st.scheduled_task_name,
            st.scheduled_task_short_description,
                CASE
                    WHEN (st.script_path_to_run IS NULL) THEN (((((('D:\qt_projects\'::text || st.scheduled_task_root_directory) || '\simplified\tasks\scheduled_tasks\'::text) || strs.scheduled_task_run_set_name) || '\'::text) || st.scheduled_task_name) || '.ps1'::text)
                    ELSE st.script_path_to_run
                END AS script_path_to_run,
                CASE
                    WHEN ((st.script_path_to_run IS NOT NULL) AND (st.script_path_to_run !~~ (('%'::text || st.scheduled_task_name) || '.ps1'::text))) THEN 'WARNING: Name mismatch'::text
                    ELSE ''::text
                END AS warning,
            st.execution_time_limit AS task_execution_time_limit,
            st.trigger_execution_limit AS trigger_execution_time_limit,
            min(st.order_in_set) OVER () AS min_order_in_set,
            max(st.order_in_set) OVER () AS max_order_in_set,
            COALESCE(st.repeat, false) AS repeat,
            st.repeat_interval,
            st.repeat_duration,
            st.stop_when_repeat_duration_reached,
            strs.log_batch_run_session
           FROM (simplified.scheduled_tasks st
             JOIN simplified.scheduled_task_run_sets strs USING (scheduled_task_run_set_id))
        )
 SELECT base.scheduled_task_id,
    base.scheduled_task_run_set_id,
    base.scheduled_task_run_set_name,
    base.order_in_set,
    base.run_start_time,
    base.scheduled_task_root_directory,
    base.scheduled_task_directory,
    base.uri,
    base.scheduled_task_path,
    base.previous_task_name,
    base.previous_uri,
    base.scheduled_task_name,
    base.scheduled_task_short_description,
    base.script_path_to_run,
    base.warning,
    base.task_execution_time_limit,
    base.trigger_execution_time_limit,
    base.min_order_in_set,
    base.max_order_in_set,
    base.repeat,
    base.repeat_interval,
    base.repeat_duration,
    base.stop_when_repeat_duration_reached,
    base.log_batch_run_session,
        CASE
            WHEN (base.min_order_in_set = base.max_order_in_set) THEN 'Starting-Ending'::text
            WHEN (base.order_in_set = base.min_order_in_set) THEN 'Starting'::text
            WHEN (base.order_in_set = base.max_order_in_set) THEN 'Ending'::text
            ELSE 'In-Between'::text
        END AS script_position_in_lineup
   FROM base;


ALTER TABLE simplified.scheduled_tasks_ext_v OWNER TO postgres;

--
-- Name: VIEW scheduled_tasks_ext_v; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON VIEW simplified.scheduled_tasks_ext_v IS 'scheduled tasks with their sets (sub groups, streams) labeled';


--
-- Name: scheduled_tasks_scheduled_task_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

CREATE SEQUENCE simplified.scheduled_tasks_scheduled_task_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE simplified.scheduled_tasks_scheduled_task_id_seq OWNER TO postgres;

--
-- Name: scheduled_tasks_scheduled_task_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.scheduled_tasks_scheduled_task_id_seq OWNED BY simplified.scheduled_tasks.scheduled_task_id;


--
-- Name: volumes; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.volumes (
    volume_id smallint NOT NULL,
    volume_name simplified.ntext,
    drive_letter "char",
    drive_model simplified.nnulltext,
    is_fixed boolean,
    is_ssd boolean,
    is_nvme boolean,
    is_os boolean,
    size_gb simplified.wdecimal14_2,
    volume_serial_no bytea,
    seq1m_q8t1_read simplified.wsmallint,
    computer_id smallint NOT NULL,
    is_log_dump boolean
);


ALTER TABLE simplified.volumes OWNER TO postgres;

--
-- Name: TABLE volumes; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.volumes IS 'Drives on Windows, with letters, mount points on linux. Unless it''s a NAS in which case it is a computer.';


--
-- Name: COLUMN volumes.volume_serial_no; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.volumes.volume_serial_no IS 'In case moved to different computer, letter, label, then maybe this can identify it?';


--
-- Name: COLUMN volumes.seq1m_q8t1_read; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.volumes.seq1m_q8t1_read IS 'Some are pretty slow, the nvme''s are blazing.  K is an external but at 7200 RPM and that helps.';


--
-- Name: COLUMN volumes.is_log_dump; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.volumes.is_log_dump IS 'Only set ONE volume.  Then I can get rid of hard-coded "D" on the Show-Error function when it flushes the volume cache for logging.';


--
-- Name: search_directories_ext_v; Type: VIEW; Schema: simplified; Owner: postgres
--

CREATE VIEW simplified.search_directories_ext_v AS
 SELECT sd.search_directory_id,
    sd.search_directory,
    "left"((sd.search_directory)::text, 1) AS drive_letter,
    sd.extensions_to_grab,
    sd.primary_function_of_entry,
    sd.file_names_can_be_changed,
    sd.tag,
    sd.volume_id,
    sd.directly_deletable,
    sd.size_of_drive_in_bytes,
    sd.space_left_on_drive_in_bytes
   FROM (simplified.search_directories sd
     LEFT JOIN simplified.volumes v USING (volume_id));


ALTER TABLE simplified.search_directories_ext_v OWNER TO postgres;

--
-- Name: search_directories_v; Type: VIEW; Schema: simplified; Owner: postgres
--

CREATE VIEW simplified.search_directories_v AS
 SELECT sd.search_directory_id,
    sd.search_directory,
    sd.extensions_to_grab,
    sd.primary_function_of_entry,
    sd.file_names_can_be_changed,
    sd.tag AS search_directory_tag,
    sd.volume_id,
    sd.directly_deletable,
    sd.size_of_drive_in_bytes,
    sd.space_left_on_drive_in_bytes
   FROM simplified.search_directories sd;


ALTER TABLE simplified.search_directories_v OWNER TO postgres;

--
-- Name: search_paths_search_path_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

ALTER TABLE simplified.search_directories ALTER COLUMN search_directory_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME simplified.search_paths_search_path_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: search_terms; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.search_terms (
    search_term_id integer NOT NULL,
    search_term text NOT NULL,
    search_type text NOT NULL
);


ALTER TABLE simplified.search_terms OWNER TO postgres;

--
-- Name: TABLE search_terms; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.search_terms IS 'This is how I find stuff on pirate bay, etc. archive.com takes some magic strings to find anything.';


--
-- Name: COLUMN search_terms.search_term; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.search_terms.search_term IS 'The string or regex or magic google term to search the type (web, disk, etc.)';


--
-- Name: search_terms_search_term_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

ALTER TABLE simplified.search_terms ALTER COLUMN search_term_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME simplified.search_terms_search_term_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: torrent_attributes_change; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.torrent_attributes_change (
    torrent_id integer NOT NULL,
    from_capture_point timestamp with time zone NOT NULL,
    to_capture_point timestamp with time zone NOT NULL,
    capture_attribute "char" NOT NULL,
    first_capture_point_value real,
    second_capture_point_value real
);


ALTER TABLE simplified.torrent_attributes_change OWNER TO postgres;

--
-- Name: torrents; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.torrents (
    torrent_id integer NOT NULL,
    from_torrent_staged_load_batch_id integer NOT NULL,
    from_torrent_staged_id bigint NOT NULL,
    added_to_this_table timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    load_batch_timestamp timestamp with time zone NOT NULL,
    load_batch_id integer NOT NULL,
    found_missing_on timestamp with time zone,
    addedon timestamp with time zone NOT NULL,
    amountleft bigint,
    amountleft_original bigint,
    autotmm boolean,
    availability double precision,
    availability_original double precision,
    category text,
    completed bigint,
    completionon timestamp with time zone,
    contentpath text,
    dllimit bigint,
    dlspeed bigint,
    downloaded bigint,
    downloaded_original bigint,
    downloadedsession bigint,
    downloadpath text,
    eta bigint,
    eta_original bigint,
    flpieceprio boolean,
    forcestart boolean,
    hash text,
    inactiveseedingtimelimit bigint,
    infohashv1 text,
    infohashv2 text,
    lastactivity timestamp with time zone,
    lastactivity_original timestamp with time zone,
    magneturi text,
    maxinactiveseedingtime bigint,
    maxratio double precision,
    maxseedingtime bigint,
    name text,
    numcomplete bigint,
    numcomplete_original bigint,
    numincomplete bigint,
    numincomplete_original bigint,
    numleechs bigint,
    numleechs_original bigint,
    numseeds bigint,
    numseeds_original bigint,
    priority bigint,
    progress double precision,
    progress_original double precision,
    ratio double precision,
    ratio_original double precision,
    ratiolimit double precision,
    savepath text,
    seedingtime bigint,
    seedingtime_original bigint,
    seedingtimelimit bigint,
    seencomplete timestamp with time zone,
    seencomplete_original timestamp with time zone,
    seqdl boolean,
    size bigint,
    state text,
    state_original text,
    superseeding boolean,
    tags text,
    timeactive bigint,
    timeactive_original bigint,
    totalsize bigint,
    tracker text,
    tracker_original text,
    trackerscount bigint,
    trackerscount_original bigint,
    uplimit bigint,
    uploaded bigint,
    uploaded_original bigint,
    uploadedsession bigint,
    uploadedsession_original bigint,
    upspeed bigint,
    upspeed_original bigint,
    merge_action_taken character varying,
    added_to_feed_table timestamp with time zone NOT NULL,
    from_torrent_staged_load_batch_timestamp timestamp with time zone,
    original_load_batch_id integer,
    original_load_batch_timestamp timestamp with time zone
);


ALTER TABLE simplified.torrents OWNER TO postgres;

--
-- Name: COLUMN torrents.added_to_this_table; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents.added_to_this_table IS 'Not static, changes per row, can be used for ordering both in table and across table loads.';


--
-- Name: COLUMN torrents.load_batch_timestamp; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents.load_batch_timestamp IS 'in code: $loadBatchTimestamp        = Get-SqlTimestamp, which just captures now, not the beginning script time. Maybe should be diff, not sure.  But this is captured before torrents_staged is loaded so should be the same across all torrent tables where a row changed.';


--
-- Name: COLUMN torrents.load_batch_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents.load_batch_id IS 'from code: cannot set here as part of batch load. value from nextval(''torrents_staged_load_batch_id'')';


--
-- Name: COLUMN torrents.found_missing_on; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents.found_missing_on IS 'Set from MERGE of FULL JOIN where there is a target row, but no longer a matching source row. So doesn''t tell you when something in qbittorrent was removed, just that it was removed.';


--
-- Name: COLUMN torrents.addedon; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents.addedon IS 'added to qbittorrent - the internal name is used, I didn''t rename it.  This way the API output matches the column.';


--
-- Name: COLUMN torrents.merge_action_taken; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents.merge_action_taken IS 'MATCHED 1, MATCHED 2, NOT MATCHED';


--
-- Name: COLUMN torrents.added_to_feed_table; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents.added_to_feed_table IS 'Should be not null, but, I don''t want to truncate. feed or staging. If we have more tables (layers), then each has a feed table, not just staging.';


--
-- Name: COLUMN torrents.from_torrent_staged_load_batch_timestamp; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents.from_torrent_staged_load_batch_timestamp IS 'Measure against the original batch timestamp, or last updated batch timestamp.';


--
-- Name: torrent_attributes_change_ext_v; Type: VIEW; Schema: simplified; Owner: postgres
--

CREATE VIEW simplified.torrent_attributes_change_ext_v AS
 WITH base AS (
         SELECT tac.torrent_id,
            t.name AS torrent_name,
            t.addedon AS torrent_added_to_qbittorrent_queue,
            NULLIF(tac.from_capture_point, '1970-01-01 07:00:00-07'::timestamp with time zone) AS from_capture_point,
            tac.to_capture_point,
            t.state AS current_state,
            t.hash,
                CASE (tac.capture_attribute)::integer
                    WHEN 0 THEN 'amountleft'::text
                    WHEN 1 THEN 'availability'::text
                    WHEN 2 THEN 'downloaded'::text
                    WHEN 3 THEN 'eta'::text
                    WHEN 4 THEN 'seeds in swarm'::text
                    WHEN 5 THEN 'leechers in swarm'::text
                    WHEN 6 THEN 'leachers connected'::text
                    WHEN 7 THEN 'seeds connected'::text
                    WHEN 8 THEN 'progress'::text
                    WHEN 9 THEN 'ratio'::text
                    WHEN 10 THEN 'seedingtime'::text
                    WHEN 11 THEN 'trackerscount'::text
                    WHEN 12 THEN 'uploaded'::text
                    WHEN 13 THEN 'uploadedsession'::text
                    WHEN 14 THEN 'upspeed'::text
                    ELSE '??????'::text
                END AS captured_attribute,
            tac.first_capture_point_value AS from_value,
            tac.second_capture_point_value AS to_value
           FROM (simplified.torrent_attributes_change tac
             JOIN simplified.torrents t USING (torrent_id))
        )
 SELECT base.torrent_id,
    base.torrent_name,
    base.torrent_added_to_qbittorrent_queue,
    base.from_capture_point,
    base.to_capture_point,
    base.current_state,
    base.hash,
    base.captured_attribute,
    base.from_value,
    base.to_value,
    (base.to_capture_point - base.from_capture_point) AS capture_period
   FROM base
  ORDER BY base.torrent_name, base.captured_attribute, base.from_capture_point;


ALTER TABLE simplified.torrent_attributes_change_ext_v OWNER TO postgres;

--
-- Name: torrents_staged; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.torrents_staged (
    torrent_staged_id bigint NOT NULL,
    added_to_this_table timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    load_batch_timestamp timestamp with time zone NOT NULL,
    load_batch_id integer NOT NULL,
    addedon timestamp with time zone NOT NULL,
    amountleft bigint,
    autotmm boolean,
    availability double precision,
    category text,
    completed bigint,
    completionon timestamp with time zone,
    contentpath text,
    dllimit bigint,
    dlspeed bigint,
    downloaded bigint,
    downloadedsession bigint,
    downloadpath text,
    eta bigint,
    flpieceprio boolean,
    forcestart boolean,
    hash text,
    inactiveseedingtimelimit bigint,
    infohashv1 text,
    infohashv2 text,
    lastactivity timestamp with time zone,
    magneturi text,
    maxinactiveseedingtime bigint,
    maxratio double precision,
    maxseedingtime bigint,
    name text,
    numcomplete bigint,
    numincomplete bigint,
    numleechs bigint,
    numseeds bigint,
    priority bigint,
    progress double precision,
    ratio double precision,
    ratiolimit double precision,
    savepath text,
    seedingtime bigint,
    seedingtimelimit bigint,
    seencomplete timestamp with time zone,
    seqdl boolean,
    size bigint,
    state text,
    superseeding boolean,
    tags text,
    timeactive bigint,
    totalsize bigint,
    tracker text,
    trackerscount bigint,
    uplimit bigint,
    uploaded bigint,
    uploadedsession bigint,
    upspeed bigint
);


ALTER TABLE simplified.torrents_staged OWNER TO postgres;

--
-- Name: COLUMN torrents_staged.load_batch_timestamp; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged.load_batch_timestamp IS 'set from code and carried through torrents, torrent_attributes_change, and any other updated in the  batch.';


--
-- Name: COLUMN torrents_staged.addedon; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged.addedon IS 'Time (Unix Epoch) when the torrent was added to the client';


--
-- Name: COLUMN torrents_staged.amountleft; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged.amountleft IS 'Amount of data left to download (bytes)';


--
-- Name: COLUMN torrents_staged.autotmm; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged.autotmm IS 'Whether this torrent is managed by Automatic Torrent Management';


--
-- Name: COLUMN torrents_staged.availability; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged.availability IS 'Percentage of file pieces currently available.';


--
-- Name: COLUMN torrents_staged.completed; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged.completed IS 'Amount of transfer data completed (bytes)';


--
-- Name: COLUMN torrents_staged.contentpath; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged.contentpath IS 'Absolute path of torrent content (root path for multifile torrents, absolute file path for singlefile torrents)';


--
-- Name: COLUMN torrents_staged.dllimit; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged.dllimit IS 'Torrent download speed limit (bytes/s). -1 if unlimited.';


--
-- Name: COLUMN torrents_staged.flpieceprio; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged.flpieceprio IS 'True if first last piece are prioritized';


--
-- Name: COLUMN torrents_staged.forcestart; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged.forcestart IS 'Torrent is forced to downloading to ignore queue limit';


--
-- Name: COLUMN torrents_staged.lastactivity; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged.lastactivity IS 'Last time (Unix Epoch) when a chunk was downloaded/uploaded';


--
-- Name: COLUMN torrents_staged.magneturi; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged.magneturi IS 'Magnet URI corresponding to this torrent';


--
-- Name: COLUMN torrents_staged.numcomplete; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged.numcomplete IS 'Number of seeds in the swarm';


--
-- Name: COLUMN torrents_staged.numincomplete; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged.numincomplete IS 'Number of leechers in the swarm';


--
-- Name: COLUMN torrents_staged.numleechs; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged.numleechs IS 'Number of leechers connected to';


--
-- Name: COLUMN torrents_staged.numseeds; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged.numseeds IS 'Number of seeds connected to';


--
-- Name: COLUMN torrents_staged.priority; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged.priority IS 'Torrent priority. Returns -1 if queuing is disabled or torrent is in seed mode';


--
-- Name: COLUMN torrents_staged.ratio; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged.ratio IS 'Torrent share ratio. Max ratio value: 9999.';


--
-- Name: COLUMN torrents_staged.seencomplete; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged.seencomplete IS 'Time (Unix Epoch) when this torrent was last seen complete';


--
-- Name: COLUMN torrents_staged.seqdl; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged.seqdl IS 'True if sequential download is enabled';


--
-- Name: COLUMN torrents_staged.superseeding; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged.superseeding IS 'True if super seeding is enabled';


--
-- Name: COLUMN torrents_staged.timeactive; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged.timeactive IS 'Total active time (seconds)';


--
-- Name: COLUMN torrents_staged.totalsize; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged.totalsize IS 'Total size (bytes) of all file in this torrent (including unselected ones)';


--
-- Name: COLUMN torrents_staged.tracker; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged.tracker IS 'The first tracker with working status. Returns empty string if no tracker is working.';


--
-- Name: COLUMN torrents_staged.upspeed; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged.upspeed IS 'Torrent upload speed (bytes/s)';


--
-- Name: torrents_staged_load_batch_id; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

CREATE SEQUENCE simplified.torrents_staged_load_batch_id
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE simplified.torrents_staged_load_batch_id OWNER TO postgres;

--
-- Name: torrents_staged_snapshot; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.torrents_staged_snapshot (
    torrent_staged_id bigint NOT NULL,
    added_to_this_table timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    load_batch_timestamp timestamp with time zone NOT NULL,
    load_batch_id integer NOT NULL,
    addedon timestamp with time zone NOT NULL,
    amountleft bigint,
    autotmm boolean,
    availability double precision,
    category text,
    completed bigint,
    completionon timestamp with time zone,
    contentpath text,
    dllimit bigint,
    dlspeed bigint,
    downloaded bigint,
    downloadedsession bigint,
    downloadpath text,
    eta bigint,
    flpieceprio boolean,
    forcestart boolean,
    hash text,
    inactiveseedingtimelimit bigint,
    infohashv1 text,
    infohashv2 text,
    lastactivity timestamp with time zone,
    magneturi text,
    maxinactiveseedingtime bigint,
    maxratio double precision,
    maxseedingtime bigint,
    name text,
    numcomplete bigint,
    numincomplete bigint,
    numleechs bigint,
    numseeds bigint,
    priority bigint,
    progress double precision,
    ratio double precision,
    ratiolimit double precision,
    savepath text,
    seedingtime bigint,
    seedingtimelimit bigint,
    seencomplete timestamp with time zone,
    seqdl boolean,
    size bigint,
    state text,
    superseeding boolean,
    tags text,
    timeactive bigint,
    totalsize bigint,
    tracker text,
    trackerscount bigint,
    uplimit bigint,
    uploaded bigint,
    uploadedsession bigint,
    upspeed bigint
);


ALTER TABLE simplified.torrents_staged_snapshot OWNER TO postgres;

--
-- Name: TABLE torrents_staged_snapshot; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.torrents_staged_snapshot IS 'This has to be separate from torrents_staged as that one is loaded on demand, while this one is going to cycle constantly to merge into torrents_snapshots with only columns that make sense over a time flow. We may manage to narrow this tighter if we can fetch only things that change.';


--
-- Name: COLUMN torrents_staged_snapshot.load_batch_timestamp; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot.load_batch_timestamp IS 'set from code and carried through torrents, torrent_attributes_change, and any other updated in the  batch.';


--
-- Name: COLUMN torrents_staged_snapshot.addedon; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot.addedon IS 'Time (Unix Epoch) when the torrent was added to the client';


--
-- Name: COLUMN torrents_staged_snapshot.amountleft; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot.amountleft IS 'Amount of data left to download (bytes)';


--
-- Name: COLUMN torrents_staged_snapshot.autotmm; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot.autotmm IS 'Whether this torrent is managed by Automatic Torrent Management';


--
-- Name: COLUMN torrents_staged_snapshot.availability; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot.availability IS 'Percentage of file pieces currently available.';


--
-- Name: COLUMN torrents_staged_snapshot.completed; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot.completed IS 'Amount of transfer data completed (bytes)';


--
-- Name: COLUMN torrents_staged_snapshot.contentpath; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot.contentpath IS 'Absolute path of torrent content (root path for multifile torrents, absolute file path for singlefile torrents)';


--
-- Name: COLUMN torrents_staged_snapshot.dllimit; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot.dllimit IS 'Torrent download speed limit (bytes/s). -1 if unlimited.';


--
-- Name: COLUMN torrents_staged_snapshot.flpieceprio; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot.flpieceprio IS 'True if first last piece are prioritized';


--
-- Name: COLUMN torrents_staged_snapshot.forcestart; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot.forcestart IS 'Torrent is forced to downloading to ignore queue limit';


--
-- Name: COLUMN torrents_staged_snapshot.lastactivity; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot.lastactivity IS 'Last time (Unix Epoch) when a chunk was downloaded/uploaded';


--
-- Name: COLUMN torrents_staged_snapshot.magneturi; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot.magneturi IS 'Magnet URI corresponding to this torrent';


--
-- Name: COLUMN torrents_staged_snapshot.numcomplete; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot.numcomplete IS 'Number of seeds in the swarm';


--
-- Name: COLUMN torrents_staged_snapshot.numincomplete; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot.numincomplete IS 'Number of leechers in the swarm';


--
-- Name: COLUMN torrents_staged_snapshot.numleechs; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot.numleechs IS 'Number of leechers connected to';


--
-- Name: COLUMN torrents_staged_snapshot.numseeds; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot.numseeds IS 'Number of seeds connected to';


--
-- Name: COLUMN torrents_staged_snapshot.priority; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot.priority IS 'Torrent priority. Returns -1 if queuing is disabled or torrent is in seed mode';


--
-- Name: COLUMN torrents_staged_snapshot.ratio; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot.ratio IS 'Torrent share ratio. Max ratio value: 9999.';


--
-- Name: COLUMN torrents_staged_snapshot.seencomplete; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot.seencomplete IS 'Time (Unix Epoch) when this torrent was last seen complete';


--
-- Name: COLUMN torrents_staged_snapshot.seqdl; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot.seqdl IS 'True if sequential download is enabled';


--
-- Name: COLUMN torrents_staged_snapshot.superseeding; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot.superseeding IS 'True if super seeding is enabled';


--
-- Name: COLUMN torrents_staged_snapshot.timeactive; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot.timeactive IS 'Total active time (seconds)';


--
-- Name: COLUMN torrents_staged_snapshot.totalsize; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot.totalsize IS 'Total size (bytes) of all file in this torrent (including unselected ones)';


--
-- Name: COLUMN torrents_staged_snapshot.tracker; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot.tracker IS 'The first tracker with working status. Returns empty string if no tracker is working.';


--
-- Name: COLUMN torrents_staged_snapshot.upspeed; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot.upspeed IS 'Torrent upload speed (bytes/s)';


--
-- Name: torrents_staged_snapshot_dl; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.torrents_staged_snapshot_dl (
    torrent_staged_id bigint NOT NULL,
    added_to_this_table timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    load_batch_timestamp timestamp with time zone NOT NULL,
    load_batch_id integer NOT NULL,
    addedon timestamp with time zone NOT NULL,
    amountleft bigint,
    autotmm boolean,
    availability double precision,
    category text,
    completed bigint,
    completionon timestamp with time zone,
    contentpath text,
    dllimit bigint,
    dlspeed bigint,
    downloaded bigint,
    downloadedsession bigint,
    downloadpath text,
    eta bigint,
    flpieceprio boolean,
    forcestart boolean,
    hash text,
    inactiveseedingtimelimit bigint,
    infohashv1 text,
    infohashv2 text,
    lastactivity timestamp with time zone,
    magneturi text,
    maxinactiveseedingtime bigint,
    maxratio double precision,
    maxseedingtime bigint,
    name text,
    numcomplete bigint,
    numincomplete bigint,
    numleechs bigint,
    numseeds bigint,
    priority bigint,
    progress double precision,
    ratio double precision,
    ratiolimit double precision,
    savepath text,
    seedingtime bigint,
    seedingtimelimit bigint,
    seencomplete timestamp with time zone,
    seqdl boolean,
    size bigint,
    state text,
    superseeding boolean,
    tags text,
    timeactive bigint,
    totalsize bigint,
    tracker text,
    trackerscount bigint,
    uplimit bigint,
    uploaded bigint,
    uploadedsession bigint,
    upspeed bigint
);


ALTER TABLE simplified.torrents_staged_snapshot_dl OWNER TO postgres;

--
-- Name: TABLE torrents_staged_snapshot_dl; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.torrents_staged_snapshot_dl IS 'Only active downloads. Fast, small, tight.  Mostly what I want to know.';


--
-- Name: COLUMN torrents_staged_snapshot_dl.load_batch_timestamp; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot_dl.load_batch_timestamp IS 'set from code and carried through torrents, torrent_attributes_change, and any other updated in the  batch.';


--
-- Name: COLUMN torrents_staged_snapshot_dl.addedon; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot_dl.addedon IS 'Time (Unix Epoch) when the torrent was added to the client';


--
-- Name: COLUMN torrents_staged_snapshot_dl.amountleft; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot_dl.amountleft IS 'Amount of data left to download (bytes)';


--
-- Name: COLUMN torrents_staged_snapshot_dl.autotmm; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot_dl.autotmm IS 'Whether this torrent is managed by Automatic Torrent Management';


--
-- Name: COLUMN torrents_staged_snapshot_dl.availability; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot_dl.availability IS 'Percentage of file pieces currently available.';


--
-- Name: COLUMN torrents_staged_snapshot_dl.completed; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot_dl.completed IS 'Amount of transfer data completed (bytes)';


--
-- Name: COLUMN torrents_staged_snapshot_dl.contentpath; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot_dl.contentpath IS 'Absolute path of torrent content (root path for multifile torrents, absolute file path for singlefile torrents)';


--
-- Name: COLUMN torrents_staged_snapshot_dl.dllimit; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot_dl.dllimit IS 'Torrent download speed limit (bytes/s). -1 if unlimited.';


--
-- Name: COLUMN torrents_staged_snapshot_dl.flpieceprio; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot_dl.flpieceprio IS 'True if first last piece are prioritized';


--
-- Name: COLUMN torrents_staged_snapshot_dl.forcestart; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot_dl.forcestart IS 'Torrent is forced to downloading to ignore queue limit';


--
-- Name: COLUMN torrents_staged_snapshot_dl.lastactivity; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot_dl.lastactivity IS 'Last time (Unix Epoch) when a chunk was downloaded/uploaded';


--
-- Name: COLUMN torrents_staged_snapshot_dl.magneturi; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot_dl.magneturi IS 'Magnet URI corresponding to this torrent';


--
-- Name: COLUMN torrents_staged_snapshot_dl.numcomplete; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot_dl.numcomplete IS 'Number of seeds in the swarm';


--
-- Name: COLUMN torrents_staged_snapshot_dl.numincomplete; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot_dl.numincomplete IS 'Number of leechers in the swarm';


--
-- Name: COLUMN torrents_staged_snapshot_dl.numleechs; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot_dl.numleechs IS 'Number of leechers connected to';


--
-- Name: COLUMN torrents_staged_snapshot_dl.numseeds; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot_dl.numseeds IS 'Number of seeds connected to';


--
-- Name: COLUMN torrents_staged_snapshot_dl.priority; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot_dl.priority IS 'Torrent priority. Returns -1 if queuing is disabled or torrent is in seed mode';


--
-- Name: COLUMN torrents_staged_snapshot_dl.ratio; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot_dl.ratio IS 'Torrent share ratio. Max ratio value: 9999.';


--
-- Name: COLUMN torrents_staged_snapshot_dl.seencomplete; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot_dl.seencomplete IS 'Time (Unix Epoch) when this torrent was last seen complete';


--
-- Name: COLUMN torrents_staged_snapshot_dl.seqdl; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot_dl.seqdl IS 'True if sequential download is enabled';


--
-- Name: COLUMN torrents_staged_snapshot_dl.superseeding; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot_dl.superseeding IS 'True if super seeding is enabled';


--
-- Name: COLUMN torrents_staged_snapshot_dl.timeactive; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot_dl.timeactive IS 'Total active time (seconds)';


--
-- Name: COLUMN torrents_staged_snapshot_dl.totalsize; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot_dl.totalsize IS 'Total size (bytes) of all file in this torrent (including unselected ones)';


--
-- Name: COLUMN torrents_staged_snapshot_dl.tracker; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot_dl.tracker IS 'The first tracker with working status. Returns empty string if no tracker is working.';


--
-- Name: COLUMN torrents_staged_snapshot_dl.upspeed; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.torrents_staged_snapshot_dl.upspeed IS 'Torrent upload speed (bytes/s)';


--
-- Name: torrents_staged_snapshot_dl_ext_v; Type: VIEW; Schema: simplified; Owner: postgres
--

CREATE VIEW simplified.torrents_staged_snapshot_dl_ext_v AS
 SELECT tss.name AS torrent_name,
    t.torrent_id,
    tss.addedon AS added_to_qbittorrent_on,
    NULLIF(tss.seencomplete, '1970-01-01 07:00:00-07'::timestamp with time zone) AS last_seen_complete_on,
    NULLIF(tss.lastactivity, '1970-01-01 07:00:00-07'::timestamp with time zone) AS last_time_any_activity_on,
    tss.load_batch_timestamp AS captured_status_on,
    tss.amountleft,
    tss.downloaded,
    tss.uploaded,
    tss.ratio,
    tss.availability,
    tss.dlspeed,
    tss.upspeed,
    justify_hours(((NULLIF(tss.eta, 8640000) || ' second'::text))::interval) AS time_to_completion,
    tss.numcomplete AS seeds_in_swarm,
    tss.numincomplete AS leechers_in_swarm,
    tss.numseeds AS connected_seeds,
    tss.numleechs AS connected_leeches,
    tss.progress,
    tss.tracker,
    tss.trackerscount
   FROM (simplified.torrents_staged_snapshot_dl tss
     LEFT JOIN simplified.torrents t USING (name));


ALTER TABLE simplified.torrents_staged_snapshot_dl_ext_v OWNER TO postgres;

--
-- Name: torrents_staged_snapshot_dl_torrent_staged_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

CREATE SEQUENCE simplified.torrents_staged_snapshot_dl_torrent_staged_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE simplified.torrents_staged_snapshot_dl_torrent_staged_id_seq OWNER TO postgres;

--
-- Name: torrents_staged_snapshot_dl_torrent_staged_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.torrents_staged_snapshot_dl_torrent_staged_id_seq OWNED BY simplified.torrents_staged_snapshot_dl.torrent_staged_id;


--
-- Name: torrents_staged_snapshot_ext_v; Type: VIEW; Schema: simplified; Owner: postgres
--

CREATE VIEW simplified.torrents_staged_snapshot_ext_v AS
 SELECT tss.name AS torrent_name,
    tss.downloadpath,
    tss.hash,
    t.torrent_id,
    tss.addedon AS added_to_qbittorrent_on,
    NULLIF(tss.completionon, '1970-01-01 07:00:00-07'::timestamp with time zone) AS completed_download_on,
    NULLIF(tss.seencomplete, '1970-01-01 07:00:00-07'::timestamp with time zone) AS last_seen_complete_on,
    NULLIF(tss.lastactivity, '1970-01-01 07:00:00-07'::timestamp with time zone) AS last_time_any_activity_on,
    tss.load_batch_timestamp AS captured_status_on,
    tss.state,
    tss.amountleft,
    tss.downloaded,
    tss.uploaded,
    tss.ratio,
    tss.availability,
    tss.dlspeed,
    tss.upspeed,
    justify_hours(((NULLIF(tss.eta, 8640000) || ' second'::text))::interval) AS time_to_completion,
    tss.numcomplete AS seeds_in_swarm,
    tss.numincomplete AS leechers_in_swarm,
    tss.numseeds AS connected_seeds,
    tss.numleechs AS connected_leeches,
    tss.progress,
    tss.tracker,
    tss.trackerscount
   FROM (simplified.torrents_staged_snapshot tss
     LEFT JOIN simplified.torrents t USING (name));


ALTER TABLE simplified.torrents_staged_snapshot_ext_v OWNER TO postgres;

--
-- Name: torrents_staged_snapshot_torrent_staged_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

CREATE SEQUENCE simplified.torrents_staged_snapshot_torrent_staged_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE simplified.torrents_staged_snapshot_torrent_staged_id_seq OWNER TO postgres;

--
-- Name: torrents_staged_snapshot_torrent_staged_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.torrents_staged_snapshot_torrent_staged_id_seq OWNED BY simplified.torrents_staged_snapshot.torrent_staged_id;


--
-- Name: torrents_staged_torrent_staged_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

CREATE SEQUENCE simplified.torrents_staged_torrent_staged_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE simplified.torrents_staged_torrent_staged_id_seq OWNER TO postgres;

--
-- Name: torrents_staged_torrent_staged_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.torrents_staged_torrent_staged_id_seq OWNED BY simplified.torrents_staged.torrent_staged_id;


--
-- Name: torrents_torrent_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

CREATE SEQUENCE simplified.torrents_torrent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE simplified.torrents_torrent_id_seq OWNER TO postgres;

--
-- Name: torrents_torrent_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.torrents_torrent_id_seq OWNED BY simplified.torrents.torrent_id;


--
-- Name: tv_episodes; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.tv_episodes (
    tv_episode_id integer NOT NULL,
    tv_serial_id integer,
    tv_season_id integer,
    tv_episode_name character varying,
    tv_episode_no smallint,
    air_date date,
    run_time time without time zone,
    uk_viewers integer,
    uk_audience_appreciation_index smallint,
    wikipedia_plot character varying,
    time_period_set_in character varying
);


ALTER TABLE simplified.tv_episodes OWNER TO postgres;

--
-- Name: TABLE tv_episodes; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.tv_episodes IS 'The meat! of a serial, or I suppose it could be just an episode of a season???  How???';


--
-- Name: COLUMN tv_episodes.tv_serial_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.tv_episodes.tv_serial_id IS 'empty in the later doctor whos, since no story level.';


--
-- Name: COLUMN tv_episodes.uk_audience_appreciation_index; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.tv_episodes.uk_audience_appreciation_index IS '0 to a 100';


--
-- Name: tv_episodes_tv_episode_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

CREATE SEQUENCE simplified.tv_episodes_tv_episode_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE simplified.tv_episodes_tv_episode_id_seq OWNER TO postgres;

--
-- Name: tv_episodes_tv_episode_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.tv_episodes_tv_episode_id_seq OWNED BY simplified.tv_episodes.tv_episode_id;


--
-- Name: tv_seasons; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.tv_seasons (
    tv_season_id integer NOT NULL,
    tv_show_id integer NOT NULL,
    tv_season_no smallint NOT NULL,
    protagonists text[],
    antagonists text[],
    companions text[]
);


ALTER TABLE simplified.tv_seasons OWNER TO postgres;

--
-- Name: COLUMN tv_seasons.tv_season_no; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.tv_seasons.tv_season_no IS 'The number, so not really the id.  Should be consecutive unless they actual number skips in the actual show.';


--
-- Name: COLUMN tv_seasons.protagonists; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.tv_seasons.protagonists IS 'First Doctor, Second?';


--
-- Name: COLUMN tv_seasons.antagonists; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.tv_seasons.antagonists IS 'The first Master, the second?  Actors, not characters. Though I guess "First Doctor" is a quasi-reification of character and actor.';


--
-- Name: tv_seasons_tv_season_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

CREATE SEQUENCE simplified.tv_seasons_tv_season_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE simplified.tv_seasons_tv_season_id_seq OWNER TO postgres;

--
-- Name: tv_seasons_tv_season_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.tv_seasons_tv_season_id_seq OWNED BY simplified.tv_seasons.tv_season_id;


--
-- Name: tv_serials; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.tv_serials (
    tv_serial_id integer NOT NULL,
    tv_serial_name text,
    film_type text,
    air_date date,
    script_edited_by text[],
    directed_by text[],
    produced_by text[],
    program_controller character varying,
    head_of_script_department character varying,
    written_by text[],
    production_code character varying,
    tv_season_id integer,
    wikipedia_plot text
);


ALTER TABLE simplified.tv_serials OWNER TO postgres;

--
-- Name: TABLE tv_serials; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.tv_serials IS 'or "shows". Groups of episodes that are connected. Though sometimes a show trails into the next show.';


--
-- Name: COLUMN tv_serials.tv_serial_name; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.tv_serials.tv_serial_name IS 'It is null sometimes.';


--
-- Name: COLUMN tv_serials.film_type; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.tv_serials.film_type IS 'Just for curiosity''s sake. So 406-line black and white videotape, for instance.';


--
-- Name: COLUMN tv_serials.air_date; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.tv_serials.air_date IS '"original" of course.';


--
-- Name: COLUMN tv_serials.script_edited_by; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.tv_serials.script_edited_by IS 'Could be multiple. same as writer?';


--
-- Name: tv_serials_tv_serial_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

CREATE SEQUENCE simplified.tv_serials_tv_serial_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE simplified.tv_serials_tv_serial_id_seq OWNER TO postgres;

--
-- Name: tv_serials_tv_serial_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.tv_serials_tv_serial_id_seq OWNED BY simplified.tv_serials.tv_serial_id;


--
-- Name: tv_shows; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.tv_shows (
    tv_show_id integer NOT NULL,
    tv_show_name text NOT NULL COLLATE simplified.ignore_both_accent_and_case,
    year_released text
);


ALTER TABLE simplified.tv_shows OWNER TO postgres;

--
-- Name: TABLE tv_shows; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.tv_shows IS 'Started to track my Doctor Who stuff.  Is classic Doctor Who and Nu Who the same show though?  Ugh. Let the contraversy begin.';


--
-- Name: COLUMN tv_shows.year_released; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.tv_shows.year_released IS 'So Doctor Who classic and Doctor Who 2005 can be distinct things.';


--
-- Name: tv_shows_tv_show_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

CREATE SEQUENCE simplified.tv_shows_tv_show_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE simplified.tv_shows_tv_show_id_seq OWNER TO postgres;

--
-- Name: tv_shows_tv_show_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.tv_shows_tv_show_id_seq OWNED BY simplified.tv_shows.tv_show_id;


--
-- Name: user_spreadsheet_interface; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.user_spreadsheet_interface (
    id integer NOT NULL,
    seen text,
    have text,
    title text,
    year_of_season text,
    season text,
    episode text,
    tags text,
    type_of_media text,
    people text,
    characters text,
    akas text,
    series_in text,
    date_watched text,
    set_in_year text,
    last_save_time text,
    file_creation_date text,
    greatest_line text,
    source_of_item text,
    record_created_on_ts_wth_tz timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE simplified.user_spreadsheet_interface OWNER TO postgres;

--
-- Name: COLUMN user_spreadsheet_interface.set_in_year; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.user_spreadsheet_interface.set_in_year IS 'For fun';


--
-- Name: user_spreadsheet_interface_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

ALTER TABLE simplified.user_spreadsheet_interface ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME simplified.user_spreadsheet_interface_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: video_files; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.video_files (
    video_file_id integer NOT NULL,
    title simplified.nnulltext,
    release_year smallint,
    display_resolution text,
    subtitle_file_id integer,
    subtitles_embedded boolean,
    encoding text
);


ALTER TABLE simplified.video_files OWNER TO postgres;

--
-- Name: TABLE video_files; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.video_files IS 'Of the media files I have, these are the video attributes Of Those Files.  Not attributes derived from external meta';


--
-- Name: COLUMN video_files.title; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.video_files.title IS 'Just one. See "titles" table for all the extra titles that nobody can agree on being primary.  Being an englese speaker, I have my own baise.';


--
-- Name: videos; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.videos (
    video_id integer NOT NULL,
    primary_title text NOT NULL,
    release_year smallint,
    is_episodic boolean DEFAULT false NOT NULL,
    title_is_descriptive boolean DEFAULT false,
    video_edition_type simplified.video_edition_type_enum NOT NULL,
    video_sub_type simplified.video_sub_type_enum,
    is_adult boolean,
    runtime smallint,
    imdb_id integer,
    tmdb_id integer,
    tmdb_id_no_longer_available boolean,
    omdb_id integer,
    parent_video_id integer,
    parent_title text,
    parent_imdb_id integer,
    season_no smallint,
    episode_no smallint,
    file_hash bytea
);


ALTER TABLE simplified.videos OWNER TO postgres;

--
-- Name: TABLE videos; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.videos IS 'all my lists: IMDB, TMDB, OMDB, and more eventually. I don''t even have OMDB yet. But I need a my id for these. IMDB, for instance, probably has the most quantity, so there will of course not be matching TMDB IDs, and so on. TMDB may have entries that are not in IMDB for some reason.
This is to be reduced from the complexities arising in receiving_dock, but I don''t want to go too simple. So what is the function? To give me a UNIQUE list of titles, whether movies, tv movies, shorts, tv shows, seasons, or episodes. BUT, since titles are not unique, we need present things that get us closer to a logical unique state. release year is one of the most meaningful additions to titles that gives a meaningful uniqueness - closer at least. The type of title, movie or tv for example, is another meaningful individuator. Why? Because collisions happen often between a tv show and a movie created because of that show, and in the same year.
No triggers, at least not just automatically tracking changes. Speed of analysis is more important.

After these key meaningful uniquifiers, what else needs to be here? Well, I put the external ids here so I can know how these came about, a way to trackback. Not a huge ton of information about what source, what table, what import session; those things bog down a table.

Major goal: Narrow this table for rapid analysis and joining work. Let views expand this out. But integers, for instance, instead of TEXT for things like the IMDB_ID. "tt4390820" as TEXT is more than double and int4. enums use less space than TEXT, so I use enums here. Metadata like record_created_date is left out. Because it has no effect on viewing, only on merges and deep etl analysis. I don''t care when I''m looking for stuff to watch, to not watch, etc. A lot of the metadata captured in stage_for_master is only relevant for making highly efficient ETLs. Here I don''t care. ';


--
-- Name: COLUMN videos.video_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.video_id IS 'A unique id regardless of external id existence. The hook on which all relies.';


--
-- Name: COLUMN videos.primary_title; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.primary_title IS 'What is "primary" about a title? Well, according to IMDB, on https://help.imdb.com/article/contribution/titles/title-formatting/G56U5ERK7YY47CQB?ref_=helpart_nav_3#, they store and capture the ORIGINAL TITLE in its ORIGINAL LANGUAGE as it appears on screen on-the-title-card. This results in the exported watch lists getting garbage titles no one recognizes. REGARDLESS of what is displayed on your IMDB list on your browser, that is merely the localized name. Don''t expect "Godzilla" movies to export in any useful value. A tad annoying.
In TMDB, however, or fortunately, you get the U.S.A. release title. The one normal people recognize. And they have a field called "original_title" aka garbage foreign title. That I save in the "titles" table.
Oh, and FYI: Get Over It.';


--
-- Name: COLUMN videos.release_year; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.release_year IS 'Part of an alternate key, title+year+type. But, for example, "Godzilla" has been re-released a multitude of times, and the year separates them neatly and meaningfully. Meaningful in the sense that "Godzilla (1954)" is not ever "Godzilla (1998)". Ever. Chances are if you are remembering a movie from childhood, you''ll be able to tell which one it was by when it was released.';


--
-- Name: COLUMN videos.is_episodic; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.is_episodic IS 'Force a choice: Is it a movie or tv? Is it one thing or a series of small things that add up to a whole? TV Mini-Series are a weird thing and not like TV Series, based on the original serials, but to effectuate the KISS principal we say: is it one thing or multiple things? Forget trilogies.';


--
-- Name: COLUMN videos.title_is_descriptive; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.title_is_descriptive IS 'Is it a title we got from somewhere, even my head, or is is a description of something I''ve seen. Must capture even if I don''t know the exact name of it. These hopefully are converted to titles, often titles already in the database. But some are probably never to be found.';


--
-- Name: COLUMN videos.video_edition_type; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.video_edition_type IS 'extended, director''s cut, uncut, censored, MST3K, RiffTrax, Svengoolie, despecialized. "Star Wars" is a great example of something needing recutting after George Lucas'' Director''s cut with added CGI goobers. But each of these deserves a separate entry. Why? Because "Zach Snyder''s Justice League" cut makes more sense (to me) than the studio cut, and deserves a different rating. Also, MST3K''s spoof of "This Island Earth" is not a fair treatment of the original movie, which stands on its own as early alien invasion reflection. Plotted poorly, but still canon.';


--
-- Name: COLUMN videos.video_sub_type; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.video_sub_type IS 'Not a required thing since we might not know, and we still want to track it. We HAVE to know if it''s a movie or a tv show, but is it a TV Movie, or is it just a movie I saw on TV? I may not know yet, but I want to still track it. See, I hang watch history off this table, so I need a hook to hang on even if I don''t know exactly where or what I saw. I know, weird.
But a thing I saw in memory is must be a real thing. My knowledge of what it was does not effect its existence as a thing that could be seen.';


--
-- Name: COLUMN videos.is_adult; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.is_adult IS 'A key metric. Why do I store these at all? More of exclusionary than anything, but I have expended hours (shock!) on adult video in my youth. In a measure of what percentage of a life was expended on video, this must be counted. Is any adult video of any value? No, of course not. But it happens. An hours watching "Debbie Does Dallas" is hours not living, or watching redeeming films like Animaniacs.';


--
-- Name: COLUMN videos.runtime; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.runtime IS 'in minutes. When comparing IMDB and TMDB to each other, these often differ by 1 to 10 minutes. 10 minutes for some reason seems to be quite common. Are these differences significant? Perhaps but I don''t want to bloat this table with more minutia. So I''ll just pick one. We can go back to staging tables and the source if we decide these differences mean different footage.';


--
-- Name: COLUMN videos.imdb_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.imdb_id IS 'not always populated, certainly not initially when I just have a TMDB entry. The damn "tt_" prefix is dumped, cute as it is.';


--
-- Name: COLUMN videos.omdb_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.omdb_id IS 'Haven''t grabbed it yet. Not even sure it''s an INTEGER. But I know that OMDB links us to a bazillion other external data, specially wikidata, which is the hub of all links.';


--
-- Name: COLUMN videos.parent_video_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.parent_video_id IS 'So the parent of the rifftrax spook will be the original theatrical movie. The parent for a TV episode will be either the TV Season or the TV Show. Which is dependent on the source ';


--
-- Name: COLUMN videos.parent_title; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.parent_title IS 'This is something I pull from selfjoining back on tmdb_id or imdb_id data, and I want the ACTUAL string here so I can uniquify TV episodes. Many times episodes are not named, and I don''t want to fill in fakes to create logical uniques. I guess episode nos will make the unique key, but it''s not as pretty as unique titles.
Since I''m more a movie buff than tv buff, I put parent_title low on the view order. ';


--
-- Name: COLUMN videos.season_no; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.season_no IS 'Any show have more than 255 seasons? Someday, long after me. But postgres isn''t really tinyint or byte supportive. Also, I''m not sure any of my sources layer show/season/episode, most seem to just have show/episode.';


--
-- Name: COLUMN videos.episode_no; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.episode_no IS 'A reality show could have 360 shows a year, theoretically. So SMALLINT it is.';


--
-- Name: COLUMN videos.file_hash; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.file_hash IS 'Torn: Do we use file content hash (BYTEA[]) or the id into the files table? Either must be unique (ignoring nulls), but one is a shadow property of the real. Also, the hash is generatable from the data, whereas file_id is dependent on the tablelized representation of that data. The file disappears then we''ll still have the record of it, not sure if that''s good or bad. In a practical way, the file disappears and we won''t have anything to watch! So what''s the point of it? Also, the file disappears (drive destroyed, etc.,) then if we redownload it from some other place, the hash can relink. So I''ve reasoned my answer. hash it is. And that will link into the file table, too.
One odd problem though: We would always have a unique serial file id, even if multiple files exist with identical hashes. This happens in copying about and downloading accidentally what I think I don''t have or I think is a better version. So we need a table of files that only points to one, and its uniqueness is by the hash - no nulls allowed. In fact, it wouldn''t need a surrogate? Hmmmmmmm. As to it''s file path, that''s still needed, perhaps two paths, one to the download, one to the published.

You might ask (I did,) why not make file_hash our primary key? Because I don''t have all million movies locally. And upcoming movies, non-extant movies, these won''t have hashes. Grr.';


--
-- Name: videos_to_video_files; Type: TABLE; Schema: simplified; Owner: filmcab_superuser
--

CREATE TABLE simplified.videos_to_video_files (
    video_to_video_file_id integer NOT NULL,
    video_id integer NOT NULL,
    video_file_id integer NOT NULL
);


ALTER TABLE simplified.videos_to_video_files OWNER TO filmcab_superuser;

--
-- Name: TABLE videos_to_video_files; Type: COMMENT; Schema: simplified; Owner: filmcab_superuser
--

COMMENT ON TABLE simplified.videos_to_video_files IS 'Theoretically a video, the name of an actual film or show, could link to several video_files. the nature of that linkage could be samples, 360p or 720p, etc., corrupt, mkv or avi, a rifftrax or Svengoolie version of the same video? Or those would be different videos. So the many linkage is only to variants of the same physical movie. Note that hashs still won''t match across.';


--
-- Name: videos_video_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

CREATE SEQUENCE simplified.videos_video_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE simplified.videos_video_id_seq OWNER TO postgres;

--
-- Name: videos_video_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.videos_video_id_seq OWNED BY simplified.videos.video_id;


--
-- Name: volumes_volume_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

CREATE SEQUENCE simplified.volumes_volume_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE simplified.volumes_volume_id_seq OWNER TO postgres;

--
-- Name: volumes_volume_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.volumes_volume_id_seq OWNED BY simplified.volumes.volume_id;


--
-- Name: acronyms acronym_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.acronyms ALTER COLUMN acronym_id SET DEFAULT nextval('simplified.acronyms_acronym_id_seq'::regclass);


--
-- Name: apps app_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.apps ALTER COLUMN app_id SET DEFAULT nextval('simplified.apps_app_id_seq'::regclass);


--
-- Name: computers computer_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.computers ALTER COLUMN computer_id SET DEFAULT nextval('simplified.computers_computer_id_seq'::regclass);


--
-- Name: file_attributes file_attribute_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.file_attributes ALTER COLUMN file_attribute_id SET DEFAULT nextval('simplified.file_attributes_file_attribute_id_seq'::regclass);


--
-- Name: file_extensions file_extension_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.file_extensions ALTER COLUMN file_extension_id SET DEFAULT nextval('simplified.file_extensions_file_extension_id_seq'::regclass);


--
-- Name: files file_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.files ALTER COLUMN file_id SET DEFAULT nextval('simplified.files_file_id_seq'::regclass);


--
-- Name: internet_service_providers internet_service_provider_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.internet_service_providers ALTER COLUMN internet_service_provider_id SET DEFAULT nextval('simplified.internet_service_providers_internet_service_provider_id_seq'::regclass);


--
-- Name: local_networks local_network_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.local_networks ALTER COLUMN local_network_id SET DEFAULT nextval('simplified.local_networks_local_network_id_seq'::regclass);


--
-- Name: moves move_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.moves ALTER COLUMN move_id SET DEFAULT nextval('simplified.moves_move_id_seq'::regclass);


--
-- Name: network_adapters network_adapter_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.network_adapters ALTER COLUMN network_adapter_id SET DEFAULT nextval('simplified.network_adapters_network_adapter_id_seq'::regclass);


--
-- Name: scheduled_task_run_sets scheduled_task_run_set_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.scheduled_task_run_sets ALTER COLUMN scheduled_task_run_set_id SET DEFAULT nextval('simplified.scheduled_task_run_sets_scheduled_task_run_set_id_seq'::regclass);


--
-- Name: scheduled_tasks scheduled_task_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.scheduled_tasks ALTER COLUMN scheduled_task_id SET DEFAULT nextval('simplified.scheduled_tasks_scheduled_task_id_seq'::regclass);


--
-- Name: torrents torrent_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.torrents ALTER COLUMN torrent_id SET DEFAULT nextval('simplified.torrents_torrent_id_seq'::regclass);


--
-- Name: torrents_staged torrent_staged_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.torrents_staged ALTER COLUMN torrent_staged_id SET DEFAULT nextval('simplified.torrents_staged_torrent_staged_id_seq'::regclass);


--
-- Name: torrents_staged_snapshot torrent_staged_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.torrents_staged_snapshot ALTER COLUMN torrent_staged_id SET DEFAULT nextval('simplified.torrents_staged_snapshot_torrent_staged_id_seq'::regclass);


--
-- Name: torrents_staged_snapshot_dl torrent_staged_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.torrents_staged_snapshot_dl ALTER COLUMN torrent_staged_id SET DEFAULT nextval('simplified.torrents_staged_snapshot_dl_torrent_staged_id_seq'::regclass);


--
-- Name: tv_episodes tv_episode_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.tv_episodes ALTER COLUMN tv_episode_id SET DEFAULT nextval('simplified.tv_episodes_tv_episode_id_seq'::regclass);


--
-- Name: tv_seasons tv_season_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.tv_seasons ALTER COLUMN tv_season_id SET DEFAULT nextval('simplified.tv_seasons_tv_season_id_seq'::regclass);


--
-- Name: tv_serials tv_serial_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.tv_serials ALTER COLUMN tv_serial_id SET DEFAULT nextval('simplified.tv_serials_tv_serial_id_seq'::regclass);


--
-- Name: tv_shows tv_show_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.tv_shows ALTER COLUMN tv_show_id SET DEFAULT nextval('simplified.tv_shows_tv_show_id_seq'::regclass);


--
-- Name: videos video_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.videos ALTER COLUMN video_id SET DEFAULT nextval('simplified.videos_video_id_seq'::regclass);


--
-- Name: volumes volume_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.volumes ALTER COLUMN volume_id SET DEFAULT nextval('simplified.volumes_volume_id_seq'::regclass);


--
-- Name: acronyms acronyms_pk; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.acronyms
    ADD CONSTRAINT acronyms_pk PRIMARY KEY (acronym_id);


--
-- Name: acronyms acronyms_unique; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.acronyms
    ADD CONSTRAINT acronyms_unique UNIQUE (acronym);


--
-- Name: user_spreadsheet_interface ak_title_release_year_media_type_season_episode; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.user_spreadsheet_interface
    ADD CONSTRAINT ak_title_release_year_media_type_season_episode UNIQUE (title, type_of_media, season, episode);


--
-- Name: videos ak_videos_hash; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.videos
    ADD CONSTRAINT ak_videos_hash UNIQUE NULLS NOT DISTINCT (tmdb_id);


--
-- Name: CONSTRAINT ak_videos_hash ON videos; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON CONSTRAINT ak_videos_hash ON simplified.videos IS 'Just link to ONE entry in our new files table. That table can deal with the multiple copies, urls, paths, etc.';


--
-- Name: videos ak_videos_imdb; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.videos
    ADD CONSTRAINT ak_videos_imdb UNIQUE NULLS NOT DISTINCT (imdb_id);


--
-- Name: CONSTRAINT ak_videos_imdb ON videos; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON CONSTRAINT ak_videos_imdb ON simplified.videos IS 'These must self-unique when present. Technically, yes there can be two TMDB films mapped to one IMDB id, or the opposite. The more external ids the more this is likely to occur - but I won''t support that in this table. In precursors yes I do keep that info. How I will reconcile a duality that is m-to-1 between sources, I have no idea. But storing multiple ids from a source as one entry is not acceptable here. It would spawn incredible complexity and generate an inability to trust that an entry is unique in realspace. It breaks the model. Without this we can treat duplicates (due to mispells, mis-entries) are errors, and fixable. Otherwise it puts our sources in doubt.';


--
-- Name: videos ak_videos_logical; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.videos
    ADD CONSTRAINT ak_videos_logical UNIQUE (primary_title, release_year, is_episodic, video_edition_type, parent_title, season_no, episode_no);


--
-- Name: CONSTRAINT ak_videos_logical ON videos; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON CONSTRAINT ak_videos_logical ON simplified.videos IS 'All videos must be definable as unique based on meaningful values. In this case, nulls ARE distinct. no episode_no? Then fill it in. You cannot ignore nulls in a logical key.';


--
-- Name: apps apps_ak; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.apps
    ADD CONSTRAINT apps_ak UNIQUE NULLS NOT DISTINCT (app_name);


--
-- Name: apps apps_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.apps
    ADD CONSTRAINT apps_pkey PRIMARY KEY (app_id);


--
-- Name: batch_run_session_tasks batch_run_session_tasks_pk; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.batch_run_session_tasks
    ADD CONSTRAINT batch_run_session_tasks_pk PRIMARY KEY (batch_run_session_task_id);


--
-- Name: batch_run_sessions batch_run_sessions_pk; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.batch_run_sessions
    ADD CONSTRAINT batch_run_sessions_pk PRIMARY KEY (batch_run_session_id);


--
-- Name: computers computers_computer_name_network_id_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.computers
    ADD CONSTRAINT computers_computer_name_network_id_key UNIQUE (computer_name, network_id);


--
-- Name: computers computers_device_guid_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.computers
    ADD CONSTRAINT computers_device_guid_key UNIQUE NULLS NOT DISTINCT (device_guid);


--
-- Name: computers computers_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.computers
    ADD CONSTRAINT computers_pkey PRIMARY KEY (computer_id);


--
-- Name: directories directories_directory_path_volume_id_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.directories
    ADD CONSTRAINT directories_directory_path_volume_id_key UNIQUE (directory_path, volume_id);


--
-- Name: CONSTRAINT directories_directory_path_volume_id_key ON directories; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON CONSTRAINT directories_directory_path_volume_id_key ON simplified.directories IS 'files can''t exist in the same place more than once.';


--
-- Name: directories directories_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.directories
    ADD CONSTRAINT directories_pkey PRIMARY KEY (directory_hash);


--
-- Name: CONSTRAINT directories_pkey ON directories; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON CONSTRAINT directories_pkey ON simplified.directories IS 'Sure hope the hash is unique.  If not, back to the drawing board.';


--
-- Name: directories directories_unique_directory_id; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.directories
    ADD CONSTRAINT directories_unique_directory_id UNIQUE (directory_id);


--
-- Name: file_extensions file_extensions_ak; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.file_extensions
    ADD CONSTRAINT file_extensions_ak UNIQUE NULLS NOT DISTINCT (file_extension);


--
-- Name: file_extensions file_extensions_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.file_extensions
    ADD CONSTRAINT file_extensions_pkey PRIMARY KEY (file_extension_id);


--
-- Name: file_links_across_search_paths file_links_across_volume_pk; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.file_links_across_search_paths
    ADD CONSTRAINT file_links_across_volume_pk PRIMARY KEY (file_links_across_volume_id);


--
-- Name: file_links_across_search_paths file_links_across_volumes_functions_unique; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.file_links_across_search_paths
    ADD CONSTRAINT file_links_across_volumes_functions_unique UNIQUE (file_hash);


--
-- Name: files_alternate_data_streams files_alternate_data_streams_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.files_alternate_data_streams
    ADD CONSTRAINT files_alternate_data_streams_pkey PRIMARY KEY (file_id);


--
-- Name: file_attributes files_attribute_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.file_attributes
    ADD CONSTRAINT files_attribute_pkey PRIMARY KEY (file_attribute_id);


--
-- Name: files files_file_name_no_ext_final_extension_directory_hash_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.files
    ADD CONSTRAINT files_file_name_no_ext_final_extension_directory_hash_key UNIQUE (file_name_no_ext, final_extension, directory_hash);


--
-- Name: files_media_info files_media_info_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.files_media_info
    ADD CONSTRAINT files_media_info_pkey PRIMARY KEY (file_id);


--
-- Name: files_mysteries files_mysteries_pk; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.files_mysteries
    ADD CONSTRAINT files_mysteries_pk PRIMARY KEY (file_id);


--
-- Name: files files_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.files
    ADD CONSTRAINT files_pkey PRIMARY KEY (file_id);


--
-- Name: genres genre_pk; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.genres
    ADD CONSTRAINT genre_pk PRIMARY KEY (genre_id);


--
-- Name: genres genres_functions_unique; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.genres
    ADD CONSTRAINT genres_functions_unique UNIQUE (genre, genre_function);


--
-- Name: internet_service_providers internet_service_providers_internet_service_provider_name_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.internet_service_providers
    ADD CONSTRAINT internet_service_providers_internet_service_provider_name_key UNIQUE (internet_service_provider_name);


--
-- Name: internet_service_providers internet_service_providers_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.internet_service_providers
    ADD CONSTRAINT internet_service_providers_pkey PRIMARY KEY (internet_service_provider_id);


--
-- Name: local_networks local_networks_internet_port_mac_address_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.local_networks
    ADD CONSTRAINT local_networks_internet_port_mac_address_key UNIQUE NULLS NOT DISTINCT (internet_port_mac_address);


--
-- Name: local_networks local_networks_local_network_name_internet_service_provider_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.local_networks
    ADD CONSTRAINT local_networks_local_network_name_internet_service_provider_key UNIQUE (local_network_name, internet_service_provider_id);


--
-- Name: local_networks local_networks_physical_address_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.local_networks
    ADD CONSTRAINT local_networks_physical_address_key UNIQUE NULLS NOT DISTINCT (physical_address);


--
-- Name: local_networks local_networks_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.local_networks
    ADD CONSTRAINT local_networks_pkey PRIMARY KEY (local_network_id);


--
-- Name: local_networks local_networks_wi_fi_address_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.local_networks
    ADD CONSTRAINT local_networks_wi_fi_address_key UNIQUE NULLS NOT DISTINCT (wi_fi_address);


--
-- Name: media_files media_files_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.media_files
    ADD CONSTRAINT media_files_pkey PRIMARY KEY (media_file_id);


--
-- Name: moves moves_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.moves
    ADD CONSTRAINT moves_pkey PRIMARY KEY (move_id);


--
-- Name: network_adapters network_adapters_network_adapter_name_local_network_id_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.network_adapters
    ADD CONSTRAINT network_adapters_network_adapter_name_local_network_id_key UNIQUE (network_adapter_name, local_network_id);


--
-- Name: network_adapters network_adapters_physical_address_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.network_adapters
    ADD CONSTRAINT network_adapters_physical_address_key UNIQUE NULLS NOT DISTINCT (physical_address);


--
-- Name: network_adapters network_adapters_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.network_adapters
    ADD CONSTRAINT network_adapters_pkey PRIMARY KEY (network_adapter_id);


--
-- Name: videos pk_videos; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.videos
    ADD CONSTRAINT pk_videos PRIMARY KEY (video_id);


--
-- Name: scheduled_tasks scheduled_task_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.scheduled_tasks
    ADD CONSTRAINT scheduled_task_pkey PRIMARY KEY (scheduled_task_id);


--
-- Name: scheduled_task_run_sets scheduled_task_run_sets_pk; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.scheduled_task_run_sets
    ADD CONSTRAINT scheduled_task_run_sets_pk PRIMARY KEY (scheduled_task_run_set_id);


--
-- Name: scheduled_task_run_sets scheduled_task_run_sets_unique; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.scheduled_task_run_sets
    ADD CONSTRAINT scheduled_task_run_sets_unique UNIQUE (scheduled_task_run_set_name);


--
-- Name: scheduled_tasks scheduled_tasks_scheduled_task_name_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.scheduled_tasks
    ADD CONSTRAINT scheduled_tasks_scheduled_task_name_key UNIQUE (scheduled_task_name);


--
-- Name: CONSTRAINT scheduled_tasks_scheduled_task_name_key ON scheduled_tasks; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON CONSTRAINT scheduled_tasks_scheduled_task_name_key ON simplified.scheduled_tasks IS 'I don''t allow there to be more than one name of a script since that''s how I sort them and reference them.';


--
-- Name: search_directories search_directories_unique; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.search_directories
    ADD CONSTRAINT search_directories_unique UNIQUE (search_directory);


--
-- Name: search_directories search_directory_pk; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.search_directories
    ADD CONSTRAINT search_directory_pk PRIMARY KEY (search_directory_id);


--
-- Name: search_terms search_term_pk; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.search_terms
    ADD CONSTRAINT search_term_pk PRIMARY KEY (search_term_id);


--
-- Name: search_terms search_terms_unique; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.search_terms
    ADD CONSTRAINT search_terms_unique UNIQUE (search_term, search_type);


--
-- Name: torrent_attributes_change torrent_attributes_change_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.torrent_attributes_change
    ADD CONSTRAINT torrent_attributes_change_pkey PRIMARY KEY (torrent_id, from_capture_point, to_capture_point, capture_attribute);


--
-- Name: torrents torrents_hash_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.torrents
    ADD CONSTRAINT torrents_hash_key UNIQUE (hash);


--
-- Name: torrents torrents_infohashv1_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.torrents
    ADD CONSTRAINT torrents_infohashv1_key UNIQUE (infohashv1);


--
-- Name: torrents torrents_magneturi_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.torrents
    ADD CONSTRAINT torrents_magneturi_key UNIQUE (magneturi);


--
-- Name: torrents torrents_name_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.torrents
    ADD CONSTRAINT torrents_name_key UNIQUE (name);


--
-- Name: torrents torrents_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.torrents
    ADD CONSTRAINT torrents_pkey PRIMARY KEY (torrent_id);


--
-- Name: torrents_staged torrents_staged_hash_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.torrents_staged
    ADD CONSTRAINT torrents_staged_hash_key UNIQUE (hash);


--
-- Name: torrents_staged_snapshot torrents_staged_hash_key_1; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.torrents_staged_snapshot
    ADD CONSTRAINT torrents_staged_hash_key_1 UNIQUE (hash);


--
-- Name: torrents_staged_snapshot_dl torrents_staged_hash_key_2; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.torrents_staged_snapshot_dl
    ADD CONSTRAINT torrents_staged_hash_key_2 UNIQUE (hash);


--
-- Name: torrents_staged torrents_staged_infohashv1_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.torrents_staged
    ADD CONSTRAINT torrents_staged_infohashv1_key UNIQUE (infohashv1);


--
-- Name: torrents_staged_snapshot torrents_staged_infohashv1_key_1; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.torrents_staged_snapshot
    ADD CONSTRAINT torrents_staged_infohashv1_key_1 UNIQUE (infohashv1);


--
-- Name: torrents_staged_snapshot_dl torrents_staged_infohashv1_key_2; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.torrents_staged_snapshot_dl
    ADD CONSTRAINT torrents_staged_infohashv1_key_2 UNIQUE (infohashv1);


--
-- Name: torrents_staged torrents_staged_magneturi_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.torrents_staged
    ADD CONSTRAINT torrents_staged_magneturi_key UNIQUE (magneturi);


--
-- Name: torrents_staged_snapshot torrents_staged_magneturi_key_1; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.torrents_staged_snapshot
    ADD CONSTRAINT torrents_staged_magneturi_key_1 UNIQUE (magneturi);


--
-- Name: torrents_staged_snapshot_dl torrents_staged_magneturi_key_2; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.torrents_staged_snapshot_dl
    ADD CONSTRAINT torrents_staged_magneturi_key_2 UNIQUE (magneturi);


--
-- Name: torrents_staged torrents_staged_name_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.torrents_staged
    ADD CONSTRAINT torrents_staged_name_key UNIQUE (name);


--
-- Name: torrents_staged_snapshot torrents_staged_name_key_1; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.torrents_staged_snapshot
    ADD CONSTRAINT torrents_staged_name_key_1 UNIQUE (name);


--
-- Name: torrents_staged_snapshot_dl torrents_staged_name_key_2; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.torrents_staged_snapshot_dl
    ADD CONSTRAINT torrents_staged_name_key_2 UNIQUE (name);


--
-- Name: torrents_staged torrents_staged_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.torrents_staged
    ADD CONSTRAINT torrents_staged_pkey PRIMARY KEY (torrent_staged_id);


--
-- Name: torrents_staged_snapshot torrents_staged_pkey_1; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.torrents_staged_snapshot
    ADD CONSTRAINT torrents_staged_pkey_1 PRIMARY KEY (torrent_staged_id);


--
-- Name: torrents_staged_snapshot_dl torrents_staged_pkey_2; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.torrents_staged_snapshot_dl
    ADD CONSTRAINT torrents_staged_pkey_2 PRIMARY KEY (torrent_staged_id);


--
-- Name: tv_episodes tv_episodes_pk; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.tv_episodes
    ADD CONSTRAINT tv_episodes_pk PRIMARY KEY (tv_episode_id);


--
-- Name: tv_seasons tv_season_nos_pk; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.tv_seasons
    ADD CONSTRAINT tv_season_nos_pk UNIQUE (tv_show_id, tv_season_no);


--
-- Name: tv_seasons tv_seasons_pk; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.tv_seasons
    ADD CONSTRAINT tv_seasons_pk PRIMARY KEY (tv_season_id);


--
-- Name: tv_serials tv_serials_pk; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.tv_serials
    ADD CONSTRAINT tv_serials_pk PRIMARY KEY (tv_serial_id);


--
-- Name: tv_shows tv_shows_pk; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.tv_shows
    ADD CONSTRAINT tv_shows_pk PRIMARY KEY (tv_show_id);


--
-- Name: user_spreadsheet_interface user_spreadsheet_interface_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.user_spreadsheet_interface
    ADD CONSTRAINT user_spreadsheet_interface_pkey PRIMARY KEY (id);


--
-- Name: video_files video_files_pk; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.video_files
    ADD CONSTRAINT video_files_pk PRIMARY KEY (video_file_id);


--
-- Name: videos videos_file_hash_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.videos
    ADD CONSTRAINT videos_file_hash_key UNIQUE NULLS NOT DISTINCT (file_hash);


--
-- Name: videos videos_omdb_id_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.videos
    ADD CONSTRAINT videos_omdb_id_key UNIQUE NULLS NOT DISTINCT (omdb_id);


--
-- Name: videos_to_video_files videos_to_video_files_pkey; Type: CONSTRAINT; Schema: simplified; Owner: filmcab_superuser
--

ALTER TABLE ONLY simplified.videos_to_video_files
    ADD CONSTRAINT videos_to_video_files_pkey PRIMARY KEY (video_to_video_file_id);


--
-- Name: volumes volumes_drive_letter_computer_id_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.volumes
    ADD CONSTRAINT volumes_drive_letter_computer_id_key UNIQUE NULLS NOT DISTINCT (drive_letter, computer_id);


--
-- Name: volumes volumes_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.volumes
    ADD CONSTRAINT volumes_pkey PRIMARY KEY (volume_id);


--
-- Name: volumes volumes_volume_name_computer_id_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.volumes
    ADD CONSTRAINT volumes_volume_name_computer_id_key UNIQUE NULLS NOT DISTINCT (volume_name, computer_id);


--
-- Name: batch_run_sessions_one_true; Type: INDEX; Schema: simplified; Owner: postgres
--

CREATE UNIQUE INDEX batch_run_sessions_one_true ON simplified.batch_run_sessions USING btree (running) WHERE (running IS NOT NULL);


--
-- Name: scheduled_tasks_order_in_set_idx; Type: INDEX; Schema: simplified; Owner: postgres
--

CREATE UNIQUE INDEX scheduled_tasks_order_in_set_idx ON simplified.scheduled_tasks USING btree (order_in_set, scheduled_task_run_set_id);


--
-- Name: scheduled_tasks_scheduled_task_name_idx; Type: INDEX; Schema: simplified; Owner: postgres
--

CREATE UNIQUE INDEX scheduled_tasks_scheduled_task_name_idx ON simplified.scheduled_tasks USING btree (scheduled_task_name, scheduled_task_run_set_id);


--
-- Name: batch_run_session_active_running_values block_multi_rows_insert; Type: RULE; Schema: simplified; Owner: postgres
--

CREATE RULE block_multi_rows_insert AS
    ON INSERT TO simplified.batch_run_session_active_running_values
   WHERE (( SELECT count(*) AS count
           FROM simplified.batch_run_session_active_running_values batch_run_session_active_running_values_1) >= 1) DO INSTEAD  UPDATE simplified.batch_run_session_active_running_values SET active_batch_run_session_id = new.active_batch_run_session_id;


--
-- Name: batch_run_session_active_running_values_ext_v on_delete_batch_run_session_active_running_values; Type: TRIGGER; Schema: simplified; Owner: postgres
--

CREATE TRIGGER on_delete_batch_run_session_active_running_values INSTEAD OF DELETE ON simplified.batch_run_session_active_running_values_ext_v FOR EACH ROW EXECUTE FUNCTION simplified.view_delete();


--
-- Name: batch_run_session_active_running_values_ext_v on_update_batch_run_session_active_running_values; Type: TRIGGER; Schema: simplified; Owner: postgres
--

CREATE TRIGGER on_update_batch_run_session_active_running_values INSTEAD OF UPDATE ON simplified.batch_run_session_active_running_values_ext_v FOR EACH ROW EXECUTE FUNCTION simplified.insert_update_if_no_record();


--
-- Name: batch_run_session_tasks batch_run_sessions_tasks_batch_run_session_id_fkey; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.batch_run_session_tasks
    ADD CONSTRAINT batch_run_sessions_tasks_batch_run_session_id_fkey FOREIGN KEY (batch_run_session_id) REFERENCES simplified.batch_run_sessions(batch_run_session_id);


--
-- Name: computers computers_network_id_fkey; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.computers
    ADD CONSTRAINT computers_network_id_fkey FOREIGN KEY (network_id) REFERENCES simplified.network_adapters(network_adapter_id);


--
-- Name: directories directories_move_id_fkey; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.directories
    ADD CONSTRAINT directories_move_id_fkey FOREIGN KEY (move_id) REFERENCES simplified.moves(move_id);


--
-- Name: files_alternate_data_streams files_alternate_data_streams_file_id_fkey; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.files_alternate_data_streams
    ADD CONSTRAINT files_alternate_data_streams_file_id_fkey FOREIGN KEY (file_id) REFERENCES simplified.files(file_id);


--
-- Name: files files_directory_hash_fkey; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.files
    ADD CONSTRAINT files_directory_hash_fkey FOREIGN KEY (directory_hash) REFERENCES simplified.directories(directory_hash);


--
-- Name: files_media_info files_media_info_file_id_fkey; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.files_media_info
    ADD CONSTRAINT files_media_info_file_id_fkey FOREIGN KEY (file_id) REFERENCES simplified.files(file_id);


--
-- Name: files files_move_id_fkey; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.files
    ADD CONSTRAINT files_move_id_fkey FOREIGN KEY (move_id) REFERENCES simplified.moves(move_id);


--
-- Name: directories fk_directories_search_paths; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.directories
    ADD CONSTRAINT fk_directories_search_paths FOREIGN KEY (search_directory_id) REFERENCES simplified.search_directories(search_directory_id);


--
-- Name: directories fk_directories_volume_id; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.directories
    ADD CONSTRAINT fk_directories_volume_id FOREIGN KEY (volume_id) REFERENCES simplified.volumes(volume_id);


--
-- Name: tv_episodes fk_episode_part_of_season; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.tv_episodes
    ADD CONSTRAINT fk_episode_part_of_season FOREIGN KEY (tv_season_id) REFERENCES simplified.tv_seasons(tv_season_id);


--
-- Name: tv_episodes fk_episode_part_of_serial; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.tv_episodes
    ADD CONSTRAINT fk_episode_part_of_serial FOREIGN KEY (tv_serial_id) REFERENCES simplified.tv_serials(tv_serial_id);


--
-- Name: media_files fk_media_file_is_file; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.media_files
    ADD CONSTRAINT fk_media_file_is_file FOREIGN KEY (media_file_id) REFERENCES simplified.files(file_id);


--
-- Name: tv_serials fk_serial_part_of_season; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.tv_serials
    ADD CONSTRAINT fk_serial_part_of_season FOREIGN KEY (tv_season_id) REFERENCES simplified.tv_seasons(tv_season_id);


--
-- Name: video_files fk_video_to_media; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.video_files
    ADD CONSTRAINT fk_video_to_media FOREIGN KEY (video_file_id) REFERENCES simplified.media_files(media_file_id);


--
-- Name: videos_to_video_files fk_videos_to_video_files_video_files_1; Type: FK CONSTRAINT; Schema: simplified; Owner: filmcab_superuser
--

ALTER TABLE ONLY simplified.videos_to_video_files
    ADD CONSTRAINT fk_videos_to_video_files_video_files_1 FOREIGN KEY (video_file_id) REFERENCES simplified.video_files(video_file_id);


--
-- Name: videos_to_video_files fk_videos_to_video_files_videos_1; Type: FK CONSTRAINT; Schema: simplified; Owner: filmcab_superuser
--

ALTER TABLE ONLY simplified.videos_to_video_files
    ADD CONSTRAINT fk_videos_to_video_files_videos_1 FOREIGN KEY (video_id) REFERENCES simplified.videos(video_id);


--
-- Name: local_networks local_networks_internet_service_provider_id_fkey; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.local_networks
    ADD CONSTRAINT local_networks_internet_service_provider_id_fkey FOREIGN KEY (internet_service_provider_id) REFERENCES simplified.internet_service_providers(internet_service_provider_id);


--
-- Name: network_adapters network_adapters_local_network_id_fkey; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.network_adapters
    ADD CONSTRAINT network_adapters_local_network_id_fkey FOREIGN KEY (local_network_id) REFERENCES simplified.local_networks(local_network_id);


--
-- Name: scheduled_tasks scheduled_tasks_scheduled_task_run_sets_fk; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.scheduled_tasks
    ADD CONSTRAINT scheduled_tasks_scheduled_task_run_sets_fk FOREIGN KEY (scheduled_task_run_set_id) REFERENCES simplified.scheduled_task_run_sets(scheduled_task_run_set_id);


--
-- Name: CONSTRAINT scheduled_tasks_scheduled_task_run_sets_fk ON scheduled_tasks; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON CONSTRAINT scheduled_tasks_scheduled_task_run_sets_fk ON simplified.scheduled_tasks IS 'Every task must be part of exactly ONE set.  Don''t want to get into tasks in multiple sets.';


--
-- Name: torrent_attributes_change torrent_attributes_change_torrent_id_fkey; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.torrent_attributes_change
    ADD CONSTRAINT torrent_attributes_change_torrent_id_fkey FOREIGN KEY (torrent_id) REFERENCES simplified.torrents(torrent_id);


--
-- Name: tv_seasons tv_seasons_tv_show_id_fkey; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.tv_seasons
    ADD CONSTRAINT tv_seasons_tv_show_id_fkey FOREIGN KEY (tv_show_id) REFERENCES simplified.tv_shows(tv_show_id);


--
-- Name: volumes volumes_computer_id_fkey; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.volumes
    ADD CONSTRAINT volumes_computer_id_fkey FOREIGN KEY (computer_id) REFERENCES simplified.computers(computer_id);



--
-- PostgreSQL database dump complete
--


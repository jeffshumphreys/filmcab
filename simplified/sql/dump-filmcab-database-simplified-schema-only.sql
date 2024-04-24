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
-- Name: codecs; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.codecs (
    codec_id smallint NOT NULL,
    codec simplified.ntext NOT NULL,
    codec_name text,
    codec_notes text
);


ALTER TABLE simplified.codecs OWNER TO postgres;

--
-- Name: TABLE codecs; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.codecs IS 'These tie heavily to file formats and those implied by extensions. Could be "file_codecs"?';


--
-- Name: codecs_codec_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

CREATE SEQUENCE simplified.codecs_codec_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE simplified.codecs_codec_id_seq OWNER TO postgres;

--
-- Name: codecs_codec_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.codecs_codec_id_seq OWNED BY simplified.codecs.codec_id;


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
-- Name: file_extensions; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.file_extensions (
    file_extension_id smallint NOT NULL,
    file_extension simplified.ntext NOT NULL,
    file_extension_name text,
    file_extension_notes text,
    can_contain_subtitles boolean,
    file_is_media_content boolean,
    file_is_video_content boolean,
    file_is_audio_content boolean,
    file_is_print_content boolean
);


ALTER TABLE simplified.file_extensions OWNER TO postgres;

--
-- Name: TABLE file_extensions; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.file_extensions IS 'I need to start (much delayed) understanding what these videos are as opposed to just hoping VLC plays them. Now I use MX Player or Windows Media Player, and pretty much everything works, except some audio codecs.';


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
    final_extension text NOT NULL,
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
    has_no_ads boolean
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
            f.move_id,
            COALESCE(f.moved_in, false) AS moved_in,
            COALESCE(f.moved_out, false) AS moved_out,
            f.moved_from_file_id,
            f.moved_to_directory_hash
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
            base.move_id,
            base.moved_in,
            base.moved_out,
            base.moved_from_file_id,
            base.moved_to_directory_hash,
                CASE
                    WHEN ((NOT base.directory_deleted) AND (NOT base.directory_is_symbolic_link) AND (NOT base.directory_is_junction_link) AND (NOT base.file_deleted) AND (NOT base.moved_out) AND (NOT base.file_is_symbolic_link) AND (NOT base.file_is_hard_link)) THEN true
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
    add_reduced_user_logic.move_id,
    add_reduced_user_logic.moved_in,
    add_reduced_user_logic.moved_out,
    add_reduced_user_logic.moved_from_file_id,
    add_reduced_user_logic.moved_to_directory_hash,
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
    general_streamkindid integer,
    general_id text,
    general_originalsourcemedium_id text,
    general_uniqueid text,
    general_menuid text,
    general_completename text,
    general_completename_last text,
    general_format text,
    general_format_commercial_ifany text,
    general_format_version text,
    general_format_profile text,
    general_format_level text,
    general_format_compression text,
    general_format_settings text,
    general_format_additionalfeatures text,
    general_internetmediatype text,
    general_codecid text,
    general_codecid_description text,
    general_codecid_version text,
    general_codecid_compatible text,
    general_interleaved text,
    general_filesize text,
    general_duration text,
    general_duration_start text,
    general_duration_end text,
    general_overallbitrate_mode text,
    general_overallbitrate text,
    general_overallbitrate_minimum text,
    general_overallbitrate_nominal text,
    general_overallbitrate_maximum text,
    general_framerate text,
    general_framecount text,
    general_delay text,
    general_delay_settings text,
    general_delay_dropframe text,
    general_delay_source text,
    general_streamsize text,
    general_headersize text,
    general_datasize text,
    general_footersize text,
    general_isstreamable text,
    general_album_replaygain_gain text,
    general_album_replaygain_peak text,
    general_encryption text,
    general_encryption_format text,
    general_encryption_length text,
    general_encryption_method text,
    general_encryption_mode text,
    general_encryption_padding text,
    general_encryption_initializationvector text,
    general_universaladid_registry text,
    general_universaladid_value text,
    general_title text,
    general_title_more text,
    general_domain text,
    general_collection text,
    general_season text,
    general_season_position text,
    general_season_position_total text,
    general_movie text,
    general_movie_more text,
    "general_movie/country" text,
    "general_movie/url" text,
    general_album text,
    general_album_more text,
    "general_album/sort" text,
    "general_album/performer" text,
    "general_album/performer/sort" text,
    "general_album/performer/url" text,
    general_comic text,
    general_comic_more text,
    "general_comic/position_total" text,
    general_part text,
    "general_part/position" text,
    "general_part/position_total" text,
    general_reel text,
    "general_reel/position" text,
    "general_reel/position_total" text,
    general_track text,
    general_track_more text,
    "general_track/url" text,
    "general_track/sort" text,
    "general_track/position" text,
    "general_track/position_total" text,
    general_packagename text,
    general_grouping text,
    general_chapter text,
    general_subtrack text,
    "general_original/album" text,
    "general_original/movie" text,
    "general_original/part" text,
    "general_original/track" text,
    general_compilation text,
    general_performer text,
    "general_performer/sort" text,
    "general_performer/url" text,
    "general_original/performer" text,
    general_accompaniment text,
    general_composer text,
    "general_composer/nationality" text,
    "general_composer/sort" text,
    general_arranger text,
    general_lyricist text,
    "general_original/lyricist" text,
    general_conductor text,
    general_director text,
    general_codirector text,
    general_assistantdirector text,
    general_directorofphotography text,
    general_soundengineer text,
    general_artdirector text,
    general_productiondesigner text,
    general_choreographer text,
    general_costumedesigner text,
    general_actor text,
    general_actor_character text,
    general_writtenby text,
    general_screenplayby text,
    general_editedby text,
    general_commissionedby text,
    general_producer text,
    general_coproducer text,
    general_executiveproducer text,
    general_musicby text,
    general_distributedby text,
    "general_originalsourceform/distributedby" text,
    general_masteredby text,
    general_encodedby text,
    general_remixedby text,
    general_productionstudio text,
    general_thanksto text,
    general_publisher text,
    "general_publisher/url" text,
    general_label text,
    general_genre text,
    general_podcastcategory text,
    general_mood text,
    general_contenttype text,
    general_subject text,
    general_description text,
    general_keywords text,
    general_summary text,
    general_synopsis text,
    general_period text,
    general_lawrating text,
    general_lawrating_reason text,
    general_icra text,
    general_released_date text,
    "general_original/released_date" text,
    general_recorded_date text,
    general_encoded_date text,
    general_tagged_date text,
    general_written_date text,
    general_mastered_date text,
    general_file_created_date text,
    general_file_created_date_local text,
    general_recorded_location text,
    general_written_location text,
    general_archival_location text,
    general_encoded_application text,
    general_encoded_application_companyname text,
    general_encoded_application_name text,
    general_encoded_application_version text,
    general_encoded_application_url text,
    general_encoded_library text,
    general_encoded_library_companyname text,
    general_encoded_library_name text,
    general_encoded_library_version text,
    general_encoded_library_date text,
    general_encoded_library_settings text,
    general_encoded_operatingsystem text,
    general_cropped text,
    general_dimensions text,
    general_dotsperinch text,
    general_lightness text,
    general_originalsourcemedium text,
    general_originalsourceform text,
    "general_originalsourceform/numcolors" text,
    "general_originalsourceform/name" text,
    "general_originalsourceform/cropped" text,
    "general_originalsourceform/sharpness" text,
    general_tagged_application text,
    general_bpm text,
    general_isrc text,
    general_isbn text,
    general_isan text,
    general_barcode text,
    general_lccn text,
    general_umid text,
    general_catalognumber text,
    general_labelcode text,
    general_owner text,
    general_copyright text,
    "general_copyright/url" text,
    general_producer_copyright text,
    general_termsofuse text,
    general_servicename text,
    general_servicechannel text,
    "general_service/url" text,
    general_serviceprovider text,
    "general_serviceprovider/url" text,
    general_servicetype text,
    general_networkname text,
    general_originalnetworkname text,
    general_country text,
    general_timezone text,
    general_cover text,
    general_cover_description text,
    general_cover_type text,
    general_cover_mime text,
    general_cover_data text,
    general_lyrics text,
    general_comment text,
    general_rating text,
    general_added_date text,
    general_played_first_date text,
    general_played_last_date text,
    general_played_count text,
    general_epg_positions_begin text,
    general_epg_positions_end text,
    video_streamorder text,
    video_id text,
    video_originalsourcemedium_id text,
    video_uniqueid text,
    video_menuid text,
    video_format text,
    video_format_commercial_ifany text,
    video_format_version text,
    video_format_profile text,
    video_format_level text,
    video_format_tier text,
    video_format_compression text,
    video_format_additionalfeatures text,
    video_multiview_baseprofile text,
    video_multiview_count text,
    video_multiview_layout text,
    video_hdr_format text,
    video_hdr_format_commercial text,
    video_hdr_format_version text,
    video_hdr_format_profile text,
    video_hdr_format_level text,
    video_hdr_format_settings text,
    video_hdr_format_compatibility text,
    video_format_settings_bvop text,
    video_format_settings_qpel text,
    video_format_settings_gmc text,
    video_format_settings_matrix text,
    video_format_settings_cabac text,
    video_format_settings_refframes text,
    video_format_settings_pulldown text,
    video_format_settings_endianness text,
    video_format_settings_packing text,
    video_format_settings_framemode text,
    video_format_settings_gop text,
    video_format_settings_picturestructure text,
    video_format_settings_wrapping text,
    video_internetmediatype text,
    video_muxingmode text,
    video_codecid text,
    video_codecid_description text,
    video_duration text,
    video_duration_firstframe text,
    video_duration_lastframe text,
    video_source_duration text,
    video_source_duration_firstframe text,
    video_source_duration_lastframe text,
    video_bitrate_mode text,
    video_bitrate text,
    video_bitrate_minimum text,
    video_bitrate_nominal text,
    video_bitrate_maximum text,
    video_bitrate_encoded text,
    video_width text,
    video_width_offset text,
    video_width_cleanaperture text,
    video_height text,
    video_height_offset text,
    video_height_cleanaperture text,
    video_stored_width text,
    video_stored_height text,
    video_sampled_width text,
    video_sampled_height text,
    video_pixelaspectratio text,
    video_pixelaspectratio_cleanaperture text,
    video_displayaspectratio text,
    video_displayaspectratio_cleanaperture text,
    video_activeformatdescription text,
    video_activeformatdescription_muxingmode text,
    video_rotation text,
    video_framerate_mode text,
    video_framerate text,
    video_framerate_minimum text,
    video_framerate_nominal text,
    video_framerate_maximum text,
    video_framerate_real text,
    video_framecount text,
    video_source_framecount text,
    video_standard text,
    video_colorspace text,
    video_chromasubsampling text,
    video_chromasubsampling_position text,
    video_bitdepth text,
    video_scantype text,
    video_scantype_storemethod text,
    video_scantype_storemethod_fieldsperblock text,
    video_scanorder text,
    video_scanorder_stored text,
    video_compression_mode text,
    video_delay text,
    video_timestamp_firstframe text,
    video_timecode_firstframe text,
    video_timecode_lastframe text,
    video_timecode_settings text,
    video_timecode_source text,
    video_gop_openclosed text,
    video_gop_openclosed_firstframe text,
    video_streamsize text,
    video_source_streamsize text,
    video_streamsize_encoded text,
    video_source_streamsize_encoded text,
    video_alignment text,
    video_title text,
    video_encoded_application text,
    video_encoded_application_companyname text,
    video_encoded_application_name text,
    video_encoded_application_version text,
    video_encoded_application_url text,
    video_encoded_library text,
    video_encoded_library_companyname text,
    video_encoded_library_name text,
    video_encoded_library_version text,
    video_encoded_library_date text,
    video_encoded_library_settings text,
    video_encoded_operatingsystem text,
    video_language text,
    video_language_more text,
    video_servicekind text,
    video_disabled text,
    video_default text,
    video_forced text,
    video_alternategroup text,
    video_encoded_date text,
    video_tagged_date text,
    video_encryption text,
    video_buffersize text,
    video_colour_description_present text,
    video_colour_description_present_source text,
    video_colour_range text,
    video_colour_range_source text,
    video_colour_primaries text,
    video_colour_primaries_source text,
    video_transfer_characteristics text,
    video_transfer_characteristics_source text,
    video_matrix_coefficients text,
    video_matrix_coefficients_source text,
    video_masteringdisplay_colorprimaries text,
    video_masteringdisplay_colorprimaries_source text,
    video_masteringdisplay_luminance text,
    video_masteringdisplay_luminance_source text,
    video_maxcll text,
    video_maxcll_source text,
    video_maxfall text,
    video_maxfall_source text,
    audio_streamorder text,
    audio_id text,
    audio_originalsourcemedium_id text,
    audio_uniqueid text,
    audio_menuid text,
    audio_format text,
    audio_format_commercial_ifany text,
    audio_format_version text,
    audio_format_profile text,
    audio_format_level text,
    audio_format_compression text,
    audio_format_settings_sbr text,
    audio_format_settings_ps text,
    audio_format_settings_mode text,
    audio_format_settings_modeextension text,
    audio_format_settings_emphasis text,
    audio_format_settings_floor text,
    audio_format_settings_firm text,
    audio_format_settings_endianness text,
    audio_format_settings_sign text,
    audio_format_settings_law text,
    audio_format_settings_itu text,
    audio_format_settings_wrapping text,
    audio_format_additionalfeatures text,
    audio_matrix_format text,
    audio_internetmediatype text,
    audio_muxingmode text,
    audio_codecid text,
    audio_codecid_description text,
    audio_duration text,
    audio_duration_firstframe text,
    audio_duration_lastframe text,
    audio_source_duration text,
    audio_source_duration_firstframe text,
    audio_source_duration_lastframe text,
    audio_bitrate_mode text,
    audio_bitrate text,
    audio_bitrate_minimum text,
    audio_bitrate_nominal text,
    audio_bitrate_maximum text,
    audio_bitrate_encoded text,
    "audio_channel(s)" text,
    "audio_matrix_channel(s)" text,
    audio_channelpositions text,
    audio_matrix_channelpositions text,
    audio_channellayout text,
    audio_channellayoutid text,
    audio_samplesperframe text,
    audio_samplingrate text,
    audio_samplingcount text,
    audio_source_samplingcount text,
    audio_framerate text,
    audio_framecount text,
    audio_source_framecount text,
    audio_bitdepth text,
    audio_bitdepth_detected text,
    audio_bitdepth_stored text,
    audio_compression_mode text,
    audio_delay text,
    audio_timecode_firstframe text,
    audio_timecode_lastframe text,
    audio_timecode_settings text,
    audio_timecode_source text,
    audio_replaygain_gain text,
    audio_replaygain_peak text,
    audio_streamsize text,
    audio_source_streamsize text,
    audio_streamsize_encoded text,
    audio_source_streamsize_encoded text,
    audio_alignment text,
    audio_interleave_videoframes text,
    audio_interleave_duration text,
    audio_interleave_preload text,
    audio_title text,
    audio_encoded_application text,
    audio_encoded_application_companyname text,
    audio_encoded_application_name text,
    audio_encoded_application_version text,
    audio_encoded_application_url text,
    audio_encoded_library text,
    audio_encoded_library_companyname text,
    audio_encoded_library_name text,
    audio_encoded_library_version text,
    audio_encoded_library_date text,
    audio_encoded_library_settings text,
    audio_encoded_operatingsystem text,
    audio_language text,
    audio_language_more text,
    audio_servicekind text,
    audio_disabled text,
    audio_default text,
    audio_forced text,
    audio_alternategroup text,
    audio_encoded_date text,
    audio_tagged_date text,
    audio_encryption text,
    text_streamorder text,
    text_id text,
    text_originalsourcemedium_id text,
    text_uniqueid text,
    text_menuid text,
    text_format text,
    text_format_commercial_ifany text,
    text_format_version text,
    text_format_profile text,
    text_format_compression text,
    text_format_settings text,
    text_format_settings_wrapping text,
    text_format_additionalfeatures text,
    text_internetmediatype text,
    text_muxingmode text,
    text_muxingmode_moreinfo text,
    text_codecid text,
    text_codecid_description text,
    text_duration text,
    text_duration_start2end text,
    text_duration_start_command text,
    text_duration_start text,
    text_duration_end text,
    text_duration_end_command text,
    text_duration_firstframe text,
    text_duration_lastframe text,
    text_duration_base text,
    text_source_duration text,
    text_source_duration_firstframe text,
    text_source_duration_lastframe text,
    text_bitrate_mode text,
    text_bitrate text,
    text_bitrate_minimum text,
    text_bitrate_nominal text,
    text_bitrate_maximum text,
    text_bitrate_encoded text,
    text_width text,
    text_height text,
    text_displayaspectratio text,
    text_displayaspectratio_original text,
    text_framerate_mode text,
    text_framerate_mode_original text,
    text_framerate text,
    text_framerate_minimum text,
    text_framerate_nominal text,
    text_framerate_maximum text,
    text_framerate_original text,
    text_colorspace text,
    text_chromasubsampling text,
    text_bitdepth text,
    text_compression_mode text,
    text_delay text,
    text_timecode_firstframe text,
    text_timecode_lastframe text,
    text_timecode_settings text,
    text_timecode_source text,
    text_timecode_maxframenumber text,
    text_timecode_maxframenumber_theory text,
    text_streamsize text,
    text_source_streamsize text,
    text_streamsize_encoded text,
    text_source_streamsize_encoded text,
    text_title text,
    text_encoded_application text,
    text_encoded_application_companyname text,
    text_encoded_application_name text,
    text_encoded_application_version text,
    text_encoded_application_url text,
    text_encoded_library text,
    text_encoded_library_companyname text,
    text_encoded_library_name text,
    text_encoded_library_version text,
    text_encoded_library_date text,
    text_encoded_library_settings text,
    text_encoded_operatingsystem text,
    text_language text,
    text_language_more text,
    text_servicekind text,
    text_disabled text,
    text_default text,
    text_forced text,
    text_alternategroup text,
    text_summary text,
    text_encoded_date text,
    text_tagged_date text,
    text_encryption text,
    text_events_minduration text,
    other_streamorder text,
    other_id text,
    other_originalsourcemedium_id text,
    other_uniqueid text,
    other_menuid text,
    other_type text,
    other_format text,
    other_format_commercial_ifany text,
    other_format_additionalfeatures text,
    other_muxingmode text,
    other_codecid text,
    other_codecid_description text,
    other_duration text,
    other_source_duration text,
    other_source_duration_firstframe text,
    other_source_duration_lastframe text,
    other_bitrate_mode text,
    other_bitrate text,
    other_bitrate_minimum text,
    other_bitrate_nominal text,
    other_bitrate_maximum text,
    other_bitrate_encoded text,
    other_framerate text,
    other_delay text,
    other_timestamp_firstframe text,
    other_timecode_firstframe text,
    other_timecode_lastframe text,
    other_timecode_settings text,
    other_timecode_stripped text,
    other_timecode_source text,
    other_streamsize text,
    other_source_streamsize text,
    other_streamsize_encoded text,
    other_source_streamsize_encoded text,
    other_title text,
    other_language text,
    other_language_more text,
    other_servicekind text,
    other_disabled text,
    other_default text,
    other_forced text,
    other_alternategroup text,
    image_streamorder text,
    image_id text,
    image_originalsourcemedium_id text,
    image_uniqueid text,
    image_menuid text,
    image_title text,
    image_format text,
    image_format_commercial_ifany text,
    image_format_settings_endianness text,
    image_format_settings_packing text,
    image_format_compression text,
    image_format_settings_wrapping text,
    image_format_additionalfeatures text,
    image_internetmediatype text,
    image_codecid text,
    image_codecid_description text,
    image_width text,
    image_width_offset text,
    image_width_original text,
    image_height text,
    image_height_offset text,
    image_height_original text,
    image_pixelaspectratio text,
    image_pixelaspectratio_original text,
    image_displayaspectratio text,
    image_displayaspectratio_original text,
    image_colorspace text,
    image_chromasubsampling text,
    image_bitdepth text,
    image_compression_mode text,
    image_streamsize text,
    image_encoded_library text,
    image_encoded_library_name text,
    image_encoded_library_version text,
    image_encoded_library_date text,
    image_encoded_library_settings text,
    image_language text,
    image_language_more text,
    image_servicekind text,
    image_disabled text,
    image_default text,
    image_forced text,
    image_alternategroup text,
    image_summary text,
    image_encoded_date text,
    image_tagged_date text,
    image_encryption text,
    image_colour_description_present text,
    image_colour_primaries text,
    image_transfer_characteristics text,
    image_matrix_coefficients text,
    image_colour_description_present_original text,
    image_colour_primaries_original text,
    image_transfer_characteristics_original text,
    image_matrix_coefficients_original text,
    menu_streamorder text,
    menu_id text,
    menu_originalsourcemedium_id text,
    menu_uniqueid text,
    menu_menuid text,
    menu_format text,
    menu_format_commercial_ifany text,
    menu_format_additionalfeatures text,
    menu_codecid text,
    menu_codecid_description text,
    menu_duration text,
    menu_duration_start text,
    menu_duration_end text,
    menu_delay text,
    menu_framerate_mode text,
    menu_framerate text,
    menu_list_streamkind text,
    menu_list_streampos text,
    menu_list text,
    menu_title text,
    menu_language text,
    menu_language_more text,
    menu_servicekind text,
    menu_servicename text,
    menu_servicechannel text,
    "menu_service/url" text,
    menu_serviceprovider text,
    "menu_serviceprovider/url" text,
    menu_servicetype text,
    menu_networkname text,
    "menu_original/networkname" text,
    menu_countries text,
    menu_timezones text,
    menu_lawrating text,
    menu_lawrating_reason text,
    menu_disabled text,
    menu_default text,
    menu_forced text,
    menu_alternategroup text,
    general_count text,
    general_streamcount text,
    general_streamkind text,
    "general_streamkind/string" text,
    "general_uniqueid/string" text,
    general_videocount text,
    general_audiocount text,
    general_textcount text,
    general_video_format_list text,
    general_video_format_withhint_list text,
    general_video_codec_list text,
    general_video_language_list text,
    general_audio_format_list text,
    general_audio_format_withhint_list text,
    general_audio_codec_list text,
    general_audio_language_list text,
    general_text_format_list text,
    general_text_format_withhint_list text,
    general_text_codec_list text,
    general_text_language_list text,
    general_foldername text,
    general_filenameextension text,
    general_filename text,
    general_fileextension text,
    "general_format/string" text,
    "general_format/url" text,
    "general_format/extensions" text,
    general_format_commercial text,
    "general_filesize/string" text,
    "general_filesize/string1" text,
    "general_filesize/string2" text,
    "general_filesize/string3" text,
    "general_filesize/string4" text,
    "general_duration/string" text,
    "general_duration/string1" text,
    "general_duration/string2" text,
    "general_duration/string3" text,
    "general_duration/string4" text,
    "general_duration/string5" text,
    "general_overallbitrate/string" text,
    "general_framerate/string" text,
    "general_streamsize/string" text,
    "general_streamsize/string1" text,
    "general_streamsize/string2" text,
    "general_streamsize/string3" text,
    "general_streamsize/string4" text,
    "general_streamsize/string5" text,
    general_streamsize_proportion text,
    general_file_modified_date text,
    general_file_modified_date_local text,
    "general_encoded_application/string" text,
    "general_encoded_library/string" text,
    video_count text,
    video_streamcount text,
    video_streamkind text,
    "video_streamkind/string" text,
    video_streamkindid text,
    "video_id/string" text,
    "video_format/string" text,
    "video_format/info" text,
    "video_format/url" text,
    video_format_commercial text,
    video_format_settings text,
    "video_format_settings_cabac/string" text,
    "video_format_settings_refframes/string" text,
    "video_codecid/url" text,
    "video_duration/string" text,
    "video_duration/string1" text,
    "video_duration/string2" text,
    "video_duration/string3" text,
    "video_duration/string4" text,
    "video_duration/string5" text,
    "video_bitrate/string" text,
    "video_width/string" text,
    "video_height/string" text,
    "video_displayaspectratio/string" text,
    "video_framerate_mode/string" text,
    video_framerate_mode_original text,
    "video_framerate/string" text,
    "video_chromasubsampling/string" text,
    "video_bitdepth/string" text,
    "video_scantype/string" text,
    "video_bits-(pixel*frame)" text,
    "video_delay/string3" text,
    video_delay_source text,
    "video_delay_source/string" text,
    "video_streamsize/string" text,
    "video_streamsize/string1" text,
    "video_streamsize/string2" text,
    "video_streamsize/string3" text,
    "video_streamsize/string4" text,
    "video_streamsize/string5" text,
    video_streamsize_proportion text,
    "video_encoded_library/string" text,
    "video_language/string" text,
    "video_language/string1" text,
    "video_language/string2" text,
    "video_language/string3" text,
    "video_language/string4" text,
    "video_default/string" text,
    "video_forced/string" text,
    video_colour_description_present_sourc text,
    video_framecount_source text,
    video_duration_source text,
    audio_count text,
    audio_streamcount text,
    audio_streamkind text,
    "audio_streamkind/string" text,
    audio_streamkindid text,
    "audio_id/string" text,
    "audio_format/string" text,
    "audio_format/info" text,
    "audio_format/url" text,
    audio_format_commercial text,
    "audio_duration/string" text,
    "audio_duration/string1" text,
    "audio_duration/string2" text,
    "audio_duration/string3" text,
    "audio_duration/string5" text,
    "audio_bitrate_mode/string" text,
    "audio_bitrate/string" text,
    "audio_channel(s)/string" text,
    "audio_channelpositions/string2" text,
    "audio_samplingrate/string" text,
    "audio_framerate/string" text,
    "audio_compression_mode/string" text,
    "audio_delay/string3" text,
    audio_delay_source text,
    "audio_delay_source/string" text,
    audio_video_delay text,
    "audio_video_delay/string3" text,
    "audio_streamsize/string" text,
    "audio_streamsize/string1" text,
    "audio_streamsize/string2" text,
    "audio_streamsize/string3" text,
    "audio_streamsize/string4" text,
    "audio_streamsize/string5" text,
    audio_streamsize_proportion text,
    "audio_language/string" text,
    "audio_language/string1" text,
    "audio_language/string2" text,
    "audio_language/string3" text,
    "audio_language/string4" text,
    "audio_servicekind/string" text,
    "audio_default/string" text,
    "audio_forced/string" text,
    audio_bsid text,
    audio_dialnorm text,
    audio_dialnorm_str text,
    audio_dsurmod text,
    audio_acmod text,
    audio_lfeon text,
    audio_dialnorm_average text,
    audio_dialnorm_average_str text,
    audio_dialnorm_minimum text,
    audio_dialnorm_minimum_str text,
    audio_dialnorm_maximum text,
    audio_dialnorm_maximum_str text,
    audio_dialnorm_count text,
    audio_samplingcount_source text,
    audio_duration_source text,
    text_count text,
    text_streamcount text,
    text_streamkind text,
    "text_streamkind/string" text,
    text_streamkindid text,
    "text_id/string" text,
    "text_format/string" text,
    text_format_commercial text,
    "text_codecid/info" text,
    "text_language/string" text,
    "text_language/string1" text,
    "text_language/string2" text,
    "text_language/string3" text,
    "text_language/string4" text,
    "text_default/string" text,
    "text_forced/string" text,
    general_menucount text,
    video_framerate_num text,
    video_framerate_den text,
    audio_format_settings text,
    "audio_format_settings_sbr/string" text,
    "audio_format_settings_ps/string" text,
    "audio_duration/string4" text,
    "audio_delay/string" text,
    "audio_delay/string1" text,
    "audio_delay/string2" text,
    "audio_video_delay/string" text,
    "audio_video_delay/string1" text,
    "audio_video_delay/string2" text,
    "text_duration/string" text,
    "text_duration/string1" text,
    "text_duration/string2" text,
    "text_duration/string3" text,
    "text_duration/string5" text,
    "text_bitrate/string" text,
    "text_framerate/string" text,
    text_framecount text,
    text_elementcount text,
    "text_streamsize/string" text,
    "text_streamsize/string1" text,
    "text_streamsize/string2" text,
    "text_streamsize/string3" text,
    "text_streamsize/string4" text,
    "text_streamsize/string5" text,
    text_streamsize_proportion text,
    menu_count text,
    menu_streamcount text,
    menu_streamkind text,
    "menu_streamkind/string" text,
    menu_streamkindid text,
    menu_chapters_pos_begin text,
    menu_chapters_pos_end text
);


ALTER TABLE simplified.files_media_info OWNER TO postgres;

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
    from_directory text NOT NULL,
    to_directory text NOT NULL,
    files_moved integer,
    move_reason text NOT NULL,
    from_base_directory character varying,
    from_volume_id smallint,
    from_search_directory_id integer,
    to_base_directory character varying,
    to_volume_id smallint,
    to_search_directory_id integer,
    description_why_reason_applies character varying
);


ALTER TABLE simplified.moves OWNER TO postgres;

--
-- Name: TABLE moves; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.moves IS 'Track all the meta about amove of a directory off one volume to another, especially why.';


--
-- Name: COLUMN moves.description_why_reason_applies; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.moves.description_why_reason_applies IS 'So for "Won''t Watch", why won''t we watch. Woke? Breaks 4th wall? Fembots?';


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
    last_run timestamp with time zone
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
    trigger_execution_limit character varying
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
            st.stop_when_repeat_duration_reached
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
-- Name: user_spreadsheet_interface; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.user_spreadsheet_interface (
    id bigint NOT NULL,
    record_created_on_ts_wth_tz timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    seen text,
    have text,
    manually_corrected_title text,
    year_of_season text,
    season text,
    episode text,
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
    hash_of_all_columns text GENERATED ALWAYS AS (encode(sha256(((((((((((((((((((((((((((COALESCE(seen, 'NULL'::text) || COALESCE(have, 'NULL'::text)) || COALESCE(manually_corrected_title, 'NULL'::text)) || COALESCE(genres_csv_list, 'NULL'::text)) || COALESCE(ended_with_right_paren, 'NULL'::text)) || COALESCE(type_of_media, 'NULL'::text)) || COALESCE(source_of_item, 'NULL'::text)) || COALESCE(who_csv_list, 'NULL'::text)) || COALESCE(aka_slsh_list, 'NULL'::text)) || COALESCE(characters_csv_list, 'NULL'::text)) || COALESCE(video_wrapper, 'NULL'::text)) || COALESCE(series_in, 'NULL'::text)) || COALESCE(imdb_id, 'NULL'::text)) || COALESCE(imdb_added_to_list_on, 'NULL'::text)) || COALESCE(imdb_changed_on_list_on, 'NULL'::text)) || COALESCE(release_year, 'NULL'::text)) || COALESCE(imdb_rating, 'NULL'::text)) || COALESCE(runtime_in_minutes, 'NULL'::text)) || COALESCE(votes, 'NULL'::text)) || COALESCE(released_on, 'NULL'::text)) || COALESCE(directors_csv_list, 'NULL'::text)) || COALESCE(imdb_my_rating, 'NULL'::text)) || COALESCE(imdb_my_rating_made_on, 'NULL'::text)) || COALESCE(date_watched, 'NULL'::text)) || COALESCE(last_save_time, 'NULL'::text)) || COALESCE(creation_date, 'NULL'::text)))::bytea), 'hex'::text)) STORED,
    dictionary_sortable_title text,
    record_added_on timestamp with time zone DEFAULT clock_timestamp()
);


ALTER TABLE simplified.user_spreadsheet_interface OWNER TO postgres;

--
-- Name: TABLE user_spreadsheet_interface; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.user_spreadsheet_interface IS 'The ODS gets imported into here. The user can edit in LibreOffice Calc and add entries.  Eventually the script will update the "have"attribute when manually_corrected_title matches something we have in files.';


--
-- Name: user_spreadsheet_interface_anal_v; Type: VIEW; Schema: simplified; Owner: postgres
--

CREATE VIEW simplified.user_spreadsheet_interface_anal_v AS
 WITH how_many_entries AS (
         SELECT count(*) AS how_many_entries_ct
           FROM simplified.user_spreadsheet_interface usi
        ), missing_right_parens AS (
         SELECT count(*) AS missing_right_parens_ct
           FROM simplified.user_spreadsheet_interface usi
          WHERE (("right"(TRIM(BOTH FROM usi.manually_corrected_title), 1) <> ')'::text) AND (usi.type_of_media <> 'Movie about…'::text))
        ), multiple_spaces AS (
         SELECT count(*) AS multiple_spaces_ct
           FROM simplified.user_spreadsheet_interface usi
          WHERE (usi.manually_corrected_title ~~ '%  %'::text)
        ), unseen_and_donthave AS (
         SELECT count(*) AS unseen_and_donthave_ct
           FROM simplified.user_spreadsheet_interface usi
          WHERE (((usi.seen <> ALL (ARRAY['y'::text, 's'::text, '?'::text])) OR (usi.seen IS NULL)) AND ((usi.have <> ALL (ARRAY['n'::text, 'x'::text, 'd'::text, 'na'::text, 'c'::text, 'h'::text, 'y'::text])) OR (usi.have IS NULL)))
        )
 SELECT how_many_entries.how_many_entries_ct,
    missing_right_parens.missing_right_parens_ct,
    multiple_spaces.multiple_spaces_ct,
    unseen_and_donthave.unseen_and_donthave_ct
   FROM how_many_entries,
    missing_right_parens,
    multiple_spaces,
    unseen_and_donthave;


ALTER TABLE simplified.user_spreadsheet_interface_anal_v OWNER TO postgres;

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
    CYCLE
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
-- Name: apps app_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.apps ALTER COLUMN app_id SET DEFAULT nextval('simplified.apps_app_id_seq'::regclass);


--
-- Name: codecs codec_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.codecs ALTER COLUMN codec_id SET DEFAULT nextval('simplified.codecs_codec_id_seq'::regclass);


--
-- Name: computers computer_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.computers ALTER COLUMN computer_id SET DEFAULT nextval('simplified.computers_computer_id_seq'::regclass);


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
-- Name: videos video_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.videos ALTER COLUMN video_id SET DEFAULT nextval('simplified.videos_video_id_seq'::regclass);


--
-- Name: volumes volume_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.volumes ALTER COLUMN volume_id SET DEFAULT nextval('simplified.volumes_volume_id_seq'::regclass);


--
-- Name: user_spreadsheet_interface ak_hash_of_all_columns; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.user_spreadsheet_interface
    ADD CONSTRAINT ak_hash_of_all_columns UNIQUE (hash_of_all_columns);


--
-- Name: user_spreadsheet_interface ak_title_release_year; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.user_spreadsheet_interface
    ADD CONSTRAINT ak_title_release_year UNIQUE (manually_corrected_title);


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
-- Name: codecs codecs_ak; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.codecs
    ADD CONSTRAINT codecs_ak UNIQUE NULLS NOT DISTINCT (codec);


--
-- Name: codecs codecs_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.codecs
    ADD CONSTRAINT codecs_pkey PRIMARY KEY (codec_id);


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
-- Name: media_files fk_media_file_is_file; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.media_files
    ADD CONSTRAINT fk_media_file_is_file FOREIGN KEY (media_file_id) REFERENCES simplified.files(file_id);


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
-- Name: volumes volumes_computer_id_fkey; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.volumes
    ADD CONSTRAINT volumes_computer_id_fkey FOREIGN KEY (computer_id) REFERENCES simplified.computers(computer_id);



--
-- PostgreSQL database dump complete
--


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
-- TOC entry 23 (class 2615 OID 1524810)
-- Name: simplified; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA simplified;


ALTER SCHEMA simplified OWNER TO postgres;

--
-- TOC entry 5173 (class 0 OID 0)
-- Dependencies: 23
-- Name: SCHEMA simplified; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA simplified IS 'Absolute reduction of all the many sources that are confluing into videos and movie details.

1) named id columns. It''s prettier (purtyr)
';


--
-- TOC entry 2140 (class 1247 OID 1524846)
-- Name: computer_os_type_enum; Type: TYPE; Schema: simplified; Owner: postgres
--

CREATE TYPE simplified.computer_os_type_enum AS ENUM (
    'windows',
    'linux',
    'macos'
);


ALTER TYPE simplified.computer_os_type_enum OWNER TO postgres;

--
-- TOC entry 2146 (class 1247 OID 1524862)
-- Name: isp_customer_type_enum; Type: TYPE; Schema: simplified; Owner: postgres
--

CREATE TYPE simplified.isp_customer_type_enum AS ENUM (
    'residential',
    'business'
);


ALTER TYPE simplified.isp_customer_type_enum OWNER TO postgres;

--
-- TOC entry 2143 (class 1247 OID 1524854)
-- Name: isp_service_type_enum; Type: TYPE; Schema: simplified; Owner: postgres
--

CREATE TYPE simplified.isp_service_type_enum AS ENUM (
    'internet',
    'phone',
    'tv'
);


ALTER TYPE simplified.isp_service_type_enum OWNER TO postgres;

--
-- TOC entry 2238 (class 1247 OID 1531939)
-- Name: move_to_location_enum; Type: TYPE; Schema: simplified; Owner: postgres
--

CREATE TYPE simplified.move_to_location_enum AS ENUM (
    'seen',
    'corrupt'
);


ALTER TYPE simplified.move_to_location_enum OWNER TO postgres;

--
-- TOC entry 5174 (class 0 OID 0)
-- Dependencies: 2238
-- Name: TYPE move_to_location_enum; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TYPE simplified.move_to_location_enum IS 'I currently have N drive seens offloaded, and I for the hopefully less numerous corrupted videos.';


--
-- TOC entry 2156 (class 1247 OID 1524887)
-- Name: nnulltext; Type: DOMAIN; Schema: simplified; Owner: postgres
--

CREATE DOMAIN simplified.nnulltext AS text
	CONSTRAINT nnulltext_check CHECK ((((TRIM(BOTH FROM VALUE) <> ''::text) AND (VALUE !~ '(\r\n|\r|\n|\t)'::text) AND (VALUE !~~ '%  %'::text) AND (VALUE = TRIM(BOTH FROM VALUE))) OR (VALUE IS NULL)));


ALTER DOMAIN simplified.nnulltext OWNER TO postgres;

--
-- TOC entry 2152 (class 1247 OID 1524884)
-- Name: ntext; Type: DOMAIN; Schema: simplified; Owner: postgres
--

CREATE DOMAIN simplified.ntext AS text NOT NULL
	CONSTRAINT ntext_check CHECK (((TRIM(BOTH FROM VALUE) <> ''::text) AND (VALUE !~ '(\r\n|\r|\n|\t)'::text) AND (VALUE !~~ '%  %'::text) AND (VALUE = TRIM(BOTH FROM VALUE))));


ALTER DOMAIN simplified.ntext OWNER TO postgres;

--
-- TOC entry 2137 (class 1247 OID 1524828)
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
-- TOC entry 2149 (class 1247 OID 1524868)
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
-- TOC entry 2134 (class 1247 OID 1524812)
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
-- TOC entry 2168 (class 1247 OID 1524896)
-- Name: wdecimal14_2; Type: DOMAIN; Schema: simplified; Owner: postgres
--

CREATE DOMAIN simplified.wdecimal14_2 AS numeric(14,2)
	CONSTRAINT wdecimal14_2_check CHECK ((((VALUE)::numeric > 0.00) OR (VALUE IS NULL)));


ALTER DOMAIN simplified.wdecimal14_2 OWNER TO postgres;

--
-- TOC entry 2164 (class 1247 OID 1524893)
-- Name: wmoney; Type: DOMAIN; Schema: simplified; Owner: postgres
--

CREATE DOMAIN simplified.wmoney AS money
	CONSTRAINT wmoney_check CHECK ((((VALUE)::numeric > 0.00) OR (VALUE IS NULL)));


ALTER DOMAIN simplified.wmoney OWNER TO postgres;

--
-- TOC entry 2160 (class 1247 OID 1524890)
-- Name: wsmallint; Type: DOMAIN; Schema: simplified; Owner: postgres
--

CREATE DOMAIN simplified.wsmallint AS smallint
	CONSTRAINT wsmallint_check CHECK (((VALUE > 0) OR (VALUE IS NULL)));


ALTER DOMAIN simplified.wsmallint OWNER TO postgres;

--
-- TOC entry 1331 (class 1255 OID 1524898)
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
-- TOC entry 361 (class 1255 OID 1531987)
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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 356 (class 1259 OID 1532715)
-- Name: active_batch_run_session_running_values; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.active_batch_run_session_running_values (
    active_batch_run_session_id integer NOT NULL,
    set_on timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE simplified.active_batch_run_session_running_values OWNER TO postgres;

--
-- TOC entry 345 (class 1259 OID 1529161)
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
-- TOC entry 5175 (class 0 OID 0)
-- Dependencies: 345
-- Name: TABLE apps; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.apps IS 'I need to start (much delayed) understanding of the tools I use unthinkingly. Which ones best? Am I using the best? VLC is great, BUT it doesn''t use the latest codecs!! MX Player on firetv is best! Which ones have open source code I can just stuff in directly?';


--
-- TOC entry 344 (class 1259 OID 1529160)
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
-- TOC entry 5176 (class 0 OID 0)
-- Dependencies: 344
-- Name: apps_app_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.apps_app_id_seq OWNED BY simplified.apps.app_id;


--
-- TOC entry 325 (class 1259 OID 1526618)
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
    caller character varying,
    caller_stopping character varying,
    caller_starting character varying,
    marking_stopped_after_overrun timestamp with time zone
);


ALTER TABLE simplified.batch_run_sessions OWNER TO postgres;

--
-- TOC entry 5177 (class 0 OID 0)
-- Dependencies: 325
-- Name: TABLE batch_run_sessions; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.batch_run_sessions IS 'Try and track over the days. Detect when the batch didn''t complete, so we can investigate.  Cancelled? Rebooted? drive failed? database corrupted? file system?  Did it run over or too quickly? Too quick is often a sign of failure.  Statistics: Is it running longer in a smooth or geometric growth pattern?  Tapering off? High variance? A lot one day then none the next?  Started late?';


--
-- TOC entry 5178 (class 0 OID 0)
-- Dependencies: 325
-- Name: COLUMN batch_run_sessions.batch_run_session_uuid; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_sessions.batch_run_session_uuid IS 'In case id resets/rolls over, this is still unique.';


--
-- TOC entry 5179 (class 0 OID 0)
-- Dependencies: 325
-- Name: COLUMN batch_run_sessions.stopped; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_sessions.stopped IS 'Only set if batch script at end runs. Though I suppose I set it too if _start_new_batch_run_session hits a dangling running session row in the morning.';


--
-- TOC entry 5180 (class 0 OID 0)
-- Dependencies: 325
-- Name: COLUMN batch_run_sessions.running; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_sessions.running IS 'Defaults to running, but constrained to only ever one record marked as running.';


--
-- TOC entry 5181 (class 0 OID 0)
-- Dependencies: 325
-- Name: COLUMN batch_run_sessions.last_script_ran; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_sessions.last_script_ran IS 'Some clue as to how far the batch got';


--
-- TOC entry 5182 (class 0 OID 0)
-- Dependencies: 325
-- Name: COLUMN batch_run_sessions.session_killing_script; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_sessions.session_killing_script IS 'What script kilt the batch? Hopefully zzz_end/stop_batch_run_session.  The future''s not set.';


--
-- TOC entry 5183 (class 0 OID 0)
-- Dependencies: 325
-- Name: COLUMN batch_run_sessions.session_starting_script; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_sessions.session_starting_script IS 'Who started this? May never vary.';


--
-- TOC entry 5184 (class 0 OID 0)
-- Dependencies: 325
-- Name: COLUMN batch_run_sessions.caller; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.batch_run_sessions.caller IS 'Who called me? VS Code debug session? Windows Task Scheduler? We don''t know because Jeff went and "bought" some job scheduler, or wrote a Quantz.Net app, or what.';


--
-- TOC entry 324 (class 1259 OID 1526617)
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
-- TOC entry 355 (class 1259 OID 1532638)
-- Name: batch_run_sessions_tasks; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.batch_run_sessions_tasks (
    batch_run_session_task_id integer NOT NULL,
    batch_run_session_id integer,
    started timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    stopped timestamp with time zone,
    error_code integer,
    run_duration_in_seconds bigint GENERATED ALWAYS AS (EXTRACT(second FROM (stopped - started))) STORED,
    running boolean DEFAULT true,
    caller character varying,
    caller_stopping character varying,
    caller_starting character varying,
    marking_stopped_after_overrun timestamp with time zone
);


ALTER TABLE simplified.batch_run_sessions_tasks OWNER TO postgres;

--
-- TOC entry 354 (class 1259 OID 1532637)
-- Name: batch_run_sessions_tasks_batch_run_session_task_id_seq; Type: SEQUENCE; Schema: simplified; Owner: postgres
--

ALTER TABLE simplified.batch_run_sessions_tasks ALTER COLUMN batch_run_session_task_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME simplified.batch_run_sessions_tasks_batch_run_session_task_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
    CYCLE
);


--
-- TOC entry 352 (class 1259 OID 1532608)
-- Name: batch_run_sessions_v; Type: VIEW; Schema: simplified; Owner: postgres
--

CREATE VIEW simplified.batch_run_sessions_v AS
 SELECT brs.batch_run_session_id,
    brs.started,
    brs.stopped,
    brs.marking_stopped_after_overrun,
    brs.running,
    brs.run_duration_in_seconds,
    brs.last_script_ran,
    brs.session_killing_script,
    brs.session_starting_script,
    brs.caller,
    brs.caller_starting,
    brs.caller_stopping,
    brs.batch_run_session_uuid,
    brs.new_directories,
    brs.new_files,
    brs.missing_files
   FROM simplified.batch_run_sessions brs;


ALTER TABLE simplified.batch_run_sessions_v OWNER TO postgres;

--
-- TOC entry 353 (class 1259 OID 1532612)
-- Name: batch_run_sessions_v_last_10_days_v; Type: VIEW; Schema: simplified; Owner: postgres
--

CREATE VIEW simplified.batch_run_sessions_v_last_10_days_v AS
 SELECT batch_run_sessions_v.batch_run_session_id,
    batch_run_sessions_v.started,
    batch_run_sessions_v.stopped,
    batch_run_sessions_v.marking_stopped_after_overrun,
    batch_run_sessions_v.running,
    batch_run_sessions_v.run_duration_in_seconds,
    batch_run_sessions_v.last_script_ran,
    batch_run_sessions_v.session_killing_script,
    batch_run_sessions_v.session_starting_script,
    batch_run_sessions_v.caller,
    batch_run_sessions_v.caller_starting,
    batch_run_sessions_v.caller_stopping,
    batch_run_sessions_v.batch_run_session_uuid,
    batch_run_sessions_v.new_directories,
    batch_run_sessions_v.new_files,
    batch_run_sessions_v.missing_files
   FROM simplified.batch_run_sessions_v
  WHERE (batch_run_sessions_v.started > (CURRENT_DATE - '10 days'::interval))
  ORDER BY batch_run_sessions_v.started;


ALTER TABLE simplified.batch_run_sessions_v_last_10_days_v OWNER TO postgres;

--
-- TOC entry 343 (class 1259 OID 1529143)
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
-- TOC entry 5185 (class 0 OID 0)
-- Dependencies: 343
-- Name: TABLE codecs; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.codecs IS 'These tie heavily to file formats and those implied by extensions. Could be "file_codecs"?';


--
-- TOC entry 342 (class 1259 OID 1529142)
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
-- TOC entry 5186 (class 0 OID 0)
-- Dependencies: 342
-- Name: codecs_codec_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.codecs_codec_id_seq OWNED BY simplified.codecs.codec_id;


--
-- TOC entry 314 (class 1259 OID 1524951)
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
-- TOC entry 5187 (class 0 OID 0)
-- Dependencies: 314
-- Name: TABLE computers; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.computers IS 'machines! hosts! What these files sit on, so that when inevitably my computer goes boom, and these drives end up somewhere else, spread over networks, in a dust pile.';


--
-- TOC entry 313 (class 1259 OID 1524950)
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
-- TOC entry 5188 (class 0 OID 0)
-- Dependencies: 313
-- Name: computers_computer_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.computers_computer_id_seq OWNED BY simplified.computers.computer_id;


--
-- TOC entry 321 (class 1259 OID 1525462)
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
    moved_off_to_seen boolean,
    moved_off_to_corrupt boolean,
    when_move_off_started timestamp with time zone
);


ALTER TABLE simplified.directories OWNER TO postgres;

--
-- TOC entry 5189 (class 0 OID 0)
-- Dependencies: 321
-- Name: TABLE directories; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.directories IS 'Useful to avoid rescanning folders if nothing changed (datestamp managed by file system). Also useful for compressing the files table. If I make this self referential then this table shrinks too. smaller = faster reading, smaller memory, etc. Good for slow-drive systems like mine.';


--
-- TOC entry 5190 (class 0 OID 0)
-- Dependencies: 321
-- Name: COLUMN directories.directory_hash; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.directory_hash IS 'Hash of the full path, including the drive (volume). Why? Because we have directory chained down to the file system. We keep one hash for 3 files, but each directory is unique.';


--
-- TOC entry 5191 (class 0 OID 0)
-- Dependencies: 321
-- Name: COLUMN directories.directory_path; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.directory_path IS 'The path on the drive because we want to generate a hash on the path, not just the current folder. Should we separate the drive letter or mount point out? So as to make it more migratable?';


--
-- TOC entry 5192 (class 0 OID 0)
-- Dependencies: 321
-- Name: COLUMN directories.folder; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.folder IS 'Make our life easier later and not have to parse directory_path. Maybe directory_path will go away if we build a recursive view.';


--
-- TOC entry 5193 (class 0 OID 0)
-- Dependencies: 321
-- Name: COLUMN directories.parent_directory_hash; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.parent_directory_hash IS 'We have to support a null here, since the top of the hierarchy. We could make a non-value, but then a self-FK wouldn''t work.';


--
-- TOC entry 5194 (class 0 OID 0)
-- Dependencies: 321
-- Name: COLUMN directories.parent_folder; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.parent_folder IS 'We want to know things like, "Is this Subs"? Also, parent folders often contain the year in the name where the actual movie file has no such detail.  Subs\Eng_1.srt need a grandparent to know what movie they attach to.';


--
-- TOC entry 5195 (class 0 OID 0)
-- Dependencies: 321
-- Name: COLUMN directories.grandparent_folder; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.grandparent_folder IS 'For subs and episodes.  If parent folder is S01, what show? parent is Subs, what movie does this srt go to?';


--
-- TOC entry 5196 (class 0 OID 0)
-- Dependencies: 321
-- Name: COLUMN directories.root_genre; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.root_genre IS 'Have added code to fill this in from the folders they''re in';


--
-- TOC entry 5197 (class 0 OID 0)
-- Dependencies: 321
-- Name: COLUMN directories.sub_genre; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.sub_genre IS 'Using grand-parent folder as sub genre.';


--
-- TOC entry 5198 (class 0 OID 0)
-- Dependencies: 321
-- Name: COLUMN directories.directory_date; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.directory_date IS '> last scanned date? Then rescan if directory date after this? (Tested: directory dates only updated at the parent, not down to grandparent, etc.';


--
-- TOC entry 5199 (class 0 OID 0)
-- Dependencies: 321
-- Name: COLUMN directories.volume_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.volume_id IS 'Not a hash here, since who knows what a hash for a volume or drive letter would be. Really thinking-over, paralysis analysis, buttt, moving stuff like qbittorrent''s database is nigh impossible to a new computer, so thinking.';


--
-- TOC entry 5200 (class 0 OID 0)
-- Dependencies: 321
-- Name: COLUMN directories.is_symbolic_link; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.is_symbolic_link IS 'Simpler, smaller than a 4-byte enum.';


--
-- TOC entry 5201 (class 0 OID 0)
-- Dependencies: 321
-- Name: COLUMN directories.is_junction_link; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.is_junction_link IS 'For directories on Windows, you only get these types. Though the link dropper has others, there''s no such thing as a hard link in directories.';


--
-- TOC entry 5202 (class 0 OID 0)
-- Dependencies: 321
-- Name: COLUMN directories.linked_path; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.linked_path IS 'For now, in case it''s outside our volume system, we just have the entire path without the drive_letter stripped.';


--
-- TOC entry 5203 (class 0 OID 0)
-- Dependencies: 321
-- Name: COLUMN directories.link_directory_still_exists; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.link_directory_still_exists IS 'We have to check.  These things are going to proliferate and by flagging them we can start to reign it in.';


--
-- TOC entry 5204 (class 0 OID 0)
-- Dependencies: 321
-- Name: COLUMN directories.scan_directory; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.scan_directory IS 'Set to trigger a scan of subdirectories based on date change. Set to false after scan.';


--
-- TOC entry 5205 (class 0 OID 0)
-- Dependencies: 321
-- Name: COLUMN directories.deleted; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.deleted IS 'Used to clean out files that can''t exist if their parents are not found in Get-Item.';


--
-- TOC entry 5206 (class 0 OID 0)
-- Dependencies: 321
-- Name: COLUMN directories.search_directory_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.search_directory_id IS 'What search path was this found under. helpful to identify "root".';


--
-- TOC entry 5207 (class 0 OID 0)
-- Dependencies: 321
-- Name: COLUMN directories.moved_off_to_seen; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.moved_off_to_seen IS 'See the N drive, or check the search_directories table for where "seen" go. This is flagged when the code moves this off. If set, then we probably don''t want to zap the backups for this.';


--
-- TOC entry 5208 (class 0 OID 0)
-- Dependencies: 321
-- Name: COLUMN directories.moved_off_to_corrupt; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.moved_off_to_corrupt IS 'These are tiresome, but for seasons of tv I don''t really want to watch any of it if an episode or season is corrupt.  Mysteries, ya need the whole thing, at least consecutively from the first season.';


--
-- TOC entry 5209 (class 0 OID 0)
-- Dependencies: 321
-- Name: COLUMN directories.when_move_off_started; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.directories.when_move_off_started IS 'When did it finish?';


--
-- TOC entry 323 (class 1259 OID 1526235)
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
-- TOC entry 5210 (class 0 OID 0)
-- Dependencies: 323
-- Name: TABLE search_directories; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.search_directories IS 'paths used in scan_for_new_directories. By adding entries here, you don''t have to edit the strings in the script.';


--
-- TOC entry 5211 (class 0 OID 0)
-- Dependencies: 323
-- Name: COLUMN search_directories.search_directory_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.search_directories.search_directory_id IS 'unique identifier; I don''t know if I''ll use it.';


--
-- TOC entry 5212 (class 0 OID 0)
-- Dependencies: 323
-- Name: COLUMN search_directories.search_directory; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.search_directories.search_directory IS 'the url, or file directory, or what have you.  api path?';


--
-- TOC entry 5213 (class 0 OID 0)
-- Dependencies: 323
-- Name: COLUMN search_directories.extensions_to_grab; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.search_directories.extensions_to_grab IS 'for most directories this is a list of video files: mpg, mkv, mpeg, etc. Others are .torrent, and so on.';


--
-- TOC entry 5214 (class 0 OID 0)
-- Dependencies: 323
-- Name: COLUMN search_directories.primary_function_of_entry; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.search_directories.primary_function_of_entry IS 'What is this folder meant to hold for what purpose? Published, and so clean pretty names, or the downloaded torrents, that cannot be altered in name or place.';


--
-- TOC entry 5215 (class 0 OID 0)
-- Dependencies: 323
-- Name: COLUMN search_directories.file_names_can_be_changed; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.search_directories.file_names_can_be_changed IS 'In O, yes you can change names. But NEVER in the torrent seeding space.';


--
-- TOC entry 5216 (class 0 OID 0)
-- Dependencies: 323
-- Name: COLUMN search_directories.tag; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.search_directories.tag IS 'published, backup, payload';


--
-- TOC entry 5217 (class 0 OID 0)
-- Dependencies: 323
-- Name: COLUMN search_directories.volume_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.search_directories.volume_id IS 'Probably search paths apply to a volume.';


--
-- TOC entry 5218 (class 0 OID 0)
-- Dependencies: 323
-- Name: COLUMN search_directories.directly_deletable; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.search_directories.directly_deletable IS 'Avoid physically deleting any torrent linked stuff. Or temp drive stuff.';


--
-- TOC entry 5219 (class 0 OID 0)
-- Dependencies: 323
-- Name: COLUMN search_directories.size_of_drive_in_bytes; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.search_directories.size_of_drive_in_bytes IS 'Trying to get a hold of how much space we have, total, left, and eventually shrinkage rate.  We must be running out soon.';


--
-- TOC entry 5220 (class 0 OID 0)
-- Dependencies: 323
-- Name: COLUMN search_directories.space_left_on_drive_in_bytes; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.search_directories.space_left_on_drive_in_bytes IS 'Eventually we need to track rate of loss, and then buy more drives.';


--
-- TOC entry 5221 (class 0 OID 0)
-- Dependencies: 323
-- Name: COLUMN search_directories.skip_hash_generation; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.search_directories.skip_hash_generation IS 'Set this for the temp drive stuff that constantly is thrashing, and you''ll never compare it to anything.';


--
-- TOC entry 358 (class 1259 OID 1533031)
-- Name: directories_ext_v; Type: VIEW; Schema: simplified; Owner: postgres
--

CREATE VIEW simplified.directories_ext_v AS
 WITH base AS (
         SELECT d.directory_path,
            d.directory_path AS directory,
            replace(d.directory_path, ''''::text, ''''''::text) AS directory_escaped,
            d.directory_hash,
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
            sd.skip_hash_generation
           FROM (simplified.directories d
             JOIN simplified.search_directories sd USING (search_directory_id))
          WHERE (d.deleted IS DISTINCT FROM true)
        ), add_layer_1 AS (
         SELECT base.directory_path,
            base.directory,
            base.directory_escaped,
            base.directory_hash,
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
                CASE
                    WHEN starts_with(base.directory_path, base.escaped_search_path) THEN true
                    ELSE false
                END AS search_path_contained,
                CASE
                    WHEN starts_with(base.directory_path, base.escaped_search_path) THEN "substring"(base.directory_path, (length((base.search_path)::text) + 2))
                    ELSE ''::text
                END AS useful_part_of_directory_path
           FROM base
        )
 SELECT add_layer_1.directory_path,
    add_layer_1.directory,
    add_layer_1.directory_escaped,
    add_layer_1.directory_hash,
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
-- TOC entry 5222 (class 0 OID 0)
-- Dependencies: 358
-- Name: VIEW directories_ext_v; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON VIEW simplified.directories_ext_v IS 'Directories combined volume and search path, and some common slices. "_ext" for extended. "directory_v" would just be an updateable straight single table view for rearranging column order.';


--
-- TOC entry 357 (class 1259 OID 1533027)
-- Name: directories_v; Type: VIEW; Schema: simplified; Owner: postgres
--

CREATE VIEW simplified.directories_v AS
 SELECT d.directory_hash,
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
    d.search_directory_id
   FROM simplified.directories d;


ALTER TABLE simplified.directories_v OWNER TO postgres;

--
-- TOC entry 341 (class 1259 OID 1529130)
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
-- TOC entry 5223 (class 0 OID 0)
-- Dependencies: 341
-- Name: TABLE file_extensions; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.file_extensions IS 'I need to start (much delayed) understanding what these videos are as opposed to just hoping VLC plays them.';


--
-- TOC entry 340 (class 1259 OID 1529129)
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
-- TOC entry 5224 (class 0 OID 0)
-- Dependencies: 340
-- Name: file_extensions_file_extension_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.file_extensions_file_extension_id_seq OWNED BY simplified.file_extensions.file_extension_id;


--
-- TOC entry 337 (class 1259 OID 1528944)
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
-- TOC entry 5225 (class 0 OID 0)
-- Dependencies: 337
-- Name: TABLE file_links_across_search_paths; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.file_links_across_search_paths IS 'relating files across the three stages we support. Data Flow Stages are a thing. So downloaded payloads move to published and then to backups.  Not move, but copy.  Move like a river, in that water doesn''t "move" per se.';


--
-- TOC entry 336 (class 1259 OID 1528943)
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
-- TOC entry 320 (class 1259 OID 1525174)
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
    scan_for_ntfs_id boolean DEFAULT false
);


ALTER TABLE simplified.files OWNER TO postgres;

--
-- TOC entry 5226 (class 0 OID 0)
-- Dependencies: 320
-- Name: TABLE files; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.files IS 'All the files in our interested directories. Primarily we want the hash value so we can search for duplicates.';


--
-- TOC entry 5227 (class 0 OID 0)
-- Dependencies: 320
-- Name: COLUMN files.file_hash; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.file_hash IS 'Fingerprint for file detecting duplicates.';


--
-- TOC entry 5228 (class 0 OID 0)
-- Dependencies: 320
-- Name: COLUMN files.directory_hash; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.directory_hash IS 'Could be null if we lost the file, I suppose. or the underlying drive.';


--
-- TOC entry 5229 (class 0 OID 0)
-- Dependencies: 320
-- Name: COLUMN files.file_name_no_ext; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.file_name_no_ext IS 'This in most cases is the torrent name, a wealth of detail in an attempt by the piraters to avoid collision on the leechers'' drives. A folder works too, though. I haven''t seen any collisions. But by keeping this name we hopefully reduce re-downloads. qbittorrent recognizes these, or the magnet link internally, but if I lose all the qbittorrent metadata, then I have no way to block redownloads.
The extension has no real meaning to the name of the file.';


--
-- TOC entry 5230 (class 0 OID 0)
-- Dependencies: 320
-- Name: COLUMN files.final_extension; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.final_extension IS 'With torrents there are a bazillion periods, so we want the last dot and following string.  We do not use an enum since enums are 4 bytes, strings are 3 characters + a length byte.';


--
-- TOC entry 5231 (class 0 OID 0)
-- Dependencies: 320
-- Name: COLUMN files.file_size; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.file_size IS 'Not space used, but reported size in bytes.';


--
-- TOC entry 5232 (class 0 OID 0)
-- Dependencies: 320
-- Name: COLUMN files.file_date; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.file_date IS 'The modified date on the file, with the local time zone. We don''t keep the created timestamp.  It''s no real use except curiosity or etl analysis, which is not what simplified is for.';


--
-- TOC entry 5233 (class 0 OID 0)
-- Dependencies: 320
-- Name: COLUMN files.deleted; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.deleted IS 'Flag deletion for now rather than deleting.';


--
-- TOC entry 5234 (class 0 OID 0)
-- Dependencies: 320
-- Name: COLUMN files.is_symbolic_link; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.is_symbolic_link IS 'I don''t use these as VLC won''t recognize them.';


--
-- TOC entry 5235 (class 0 OID 0)
-- Dependencies: 320
-- Name: COLUMN files.is_hard_link; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.is_hard_link IS 'Hard links really save space.';


--
-- TOC entry 5236 (class 0 OID 0)
-- Dependencies: 320
-- Name: COLUMN files.linked_path; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.linked_path IS 'Set when you Get-Item from disk. What a link is pointing to. Check if broken_link is set.';


--
-- TOC entry 5237 (class 0 OID 0)
-- Dependencies: 320
-- Name: COLUMN files.broken_link; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.broken_link IS 'Noticed Get-FileHash fails if it''s a broken link, so we set this.';


--
-- TOC entry 5238 (class 0 OID 0)
-- Dependencies: 320
-- Name: COLUMN files.file_ntfs_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.file_ntfs_id IS 'Pulled using fsutil queryfileid <file_path>, comes back as ''0x0000000000000000000400000002e217''. Should be unique on a volume, but.';


--
-- TOC entry 5239 (class 0 OID 0)
-- Dependencies: 320
-- Name: COLUMN files.scan_for_ntfs_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.files.scan_for_ntfs_id IS 'Set to true from scan_for_file_directories on new or updated file entry.  Will this be enough to detect ntfs_id changes? Will have to test.  Concerns about the directories, too. Will a directory change trigger a recycling of ntfs_ids?';


--
-- TOC entry 359 (class 1259 OID 1533036)
-- Name: files_ext_v; Type: VIEW; Schema: simplified; Owner: postgres
--

CREATE VIEW simplified.files_ext_v AS
 WITH base AS (
         SELECT f.file_id,
            f.file_hash,
            f.file_ntfs_id,
            d.directory_hash,
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
            f.scan_for_ntfs_id AS scan_file_for_ntfs_id,
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
            sd.directly_deletable,
            sd.skip_hash_generation,
            d.root_genre,
            COALESCE(f.is_symbolic_link, false) AS file_is_symbolic_link,
            COALESCE(f.is_hard_link, false) AS file_is_hard_link,
            NULLIF(f.linked_path, ''::text) AS file_linked_path,
            d.directory_is_symbolic_link,
            d.directory_is_junction_link
           FROM ((simplified.files f
             JOIN simplified.directories_ext_v d USING (directory_hash))
             JOIN simplified.search_directories sd USING (search_directory_id))
        ), add_reduced_user_logic AS (
         SELECT base.file_id,
            base.file_hash,
            base.file_ntfs_id,
            base.directory_hash,
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
            base.file_linked_path,
            base.directory_is_symbolic_link,
            base.directory_is_junction_link,
                CASE
                    WHEN ((NOT base.directory_deleted) AND (NOT base.directory_is_symbolic_link) AND (NOT base.directory_is_junction_link) AND (NOT base.file_deleted) AND (NOT base.file_is_symbolic_link) AND (NOT base.file_is_hard_link)) THEN true
                    ELSE false
                END AS is_real_file
           FROM base
        )
 SELECT add_reduced_user_logic.file_id,
    add_reduced_user_logic.file_hash,
    add_reduced_user_logic.file_ntfs_id,
    add_reduced_user_logic.directory_hash,
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
    add_reduced_user_logic.file_linked_path,
    add_reduced_user_logic.directory_is_symbolic_link,
    add_reduced_user_logic.directory_is_junction_link,
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
-- TOC entry 5240 (class 0 OID 0)
-- Dependencies: 359
-- Name: VIEW files_ext_v; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON VIEW simplified.files_ext_v IS 'file info with directory detail. A lot of logic avoided re-doing everytime I want to understand what a video is.';


--
-- TOC entry 319 (class 1259 OID 1525173)
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
-- TOC entry 5241 (class 0 OID 0)
-- Dependencies: 319
-- Name: files_file_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.files_file_id_seq OWNED BY simplified.files.file_id;


--
-- TOC entry 338 (class 1259 OID 1528954)
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
             JOIN simplified.directories directories(directory_hash, directory_path, folder, parent_directory_hash, parent_folder, grandparent_folder, root_genre, sub_genre, directory_date, volume_id, is_symbolic_link, is_junction_link, linked_path, link_directory_still_exists, scan_directory, deleted, search_path_id, moved_off_to_seen, moved_off_to_corrupt, when_move_off_started) USING (directory_hash))
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
-- TOC entry 360 (class 1259 OID 1533041)
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
    files.scan_for_ntfs_id AS scan_file_for_ntfs_id
   FROM simplified.files;


ALTER TABLE simplified.files_v OWNER TO postgres;

--
-- TOC entry 335 (class 1259 OID 1528886)
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
-- TOC entry 5242 (class 0 OID 0)
-- Dependencies: 335
-- Name: TABLE genres; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.genres IS 'genres used in folders to group movies together. Probably all the genres eventually.';


--
-- TOC entry 334 (class 1259 OID 1528885)
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
-- TOC entry 308 (class 1259 OID 1524900)
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
-- TOC entry 5243 (class 0 OID 0)
-- Dependencies: 308
-- Name: TABLE internet_service_providers; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.internet_service_providers IS 'My network is on this ISP. Tada?';


--
-- TOC entry 5244 (class 0 OID 0)
-- Dependencies: 308
-- Name: COLUMN internet_service_providers.bill_amount; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.internet_service_providers.bill_amount IS 'What I have on the bill recently. Not some master super helpful, just the cost I paid, so certainly not useful for multi-user.';


--
-- TOC entry 307 (class 1259 OID 1524899)
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
-- TOC entry 5245 (class 0 OID 0)
-- Dependencies: 307
-- Name: internet_service_providers_internet_service_provider_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.internet_service_providers_internet_service_provider_id_seq OWNED BY simplified.internet_service_providers.internet_service_provider_id;


--
-- TOC entry 310 (class 1259 OID 1524911)
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
-- TOC entry 5246 (class 0 OID 0)
-- Dependencies: 310
-- Name: TABLE local_networks; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.local_networks IS 'My NETGEAR router seems to be all my computer sees. But what is the DLINK name on the wireless?? Anybody? The Nighthawk is SSID NETGEAR47, not DLINK';


--
-- TOC entry 309 (class 1259 OID 1524910)
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
-- TOC entry 5247 (class 0 OID 0)
-- Dependencies: 309
-- Name: local_networks_local_network_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.local_networks_local_network_id_seq OWNED BY simplified.local_networks.local_network_id;


--
-- TOC entry 326 (class 1259 OID 1527032)
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
-- TOC entry 5248 (class 0 OID 0)
-- Dependencies: 326
-- Name: TABLE media_files; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.media_files IS 'Tear apart the "files" entry into parts, things we can derive from the file name.  Not so much internal data; that (for now) is pushed down to video_files, since supposedly I might store other media files. Possibly I could store info from imdb and such here?  No opinion yet.  I do like one table per concern, so probably the metadata from external might not go here.';


--
-- TOC entry 5249 (class 0 OID 0)
-- Dependencies: 326
-- Name: COLUMN media_files.media_file_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.media_files.media_file_id IS 'This needs to keep updating for new until a truncate with restart is run. Stage id'' for now get reset, so joining back from master won''t really work, so we''ll have a think and maybe a separate table the master links back to with perm sequence ids.  It''s just that testing will cause bloat. Note that I don''t see any reason for these to be super keys that are from a master sequence.';


--
-- TOC entry 5250 (class 0 OID 0)
-- Dependencies: 326
-- Name: COLUMN media_files.original_file_name; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.media_files.original_file_name IS 'A copy of txt from files, not the title, since we don''t know for sure what that is yet.';


--
-- TOC entry 5251 (class 0 OID 0)
-- Dependencies: 326
-- Name: COLUMN media_files.cleaned_file_name_with_year; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.media_files.cleaned_file_name_with_year IS 'Generated, and this should be unique, unless multiple versions editions of the file, director''s cut, etc.';


--
-- TOC entry 312 (class 1259 OID 1524933)
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
-- TOC entry 5252 (class 0 OID 0)
-- Dependencies: 312
-- Name: TABLE network_adapters; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.network_adapters IS 'Is a network adapter a physical thing or is it the Windows driver?  I can''t tell.';


--
-- TOC entry 311 (class 1259 OID 1524932)
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
-- TOC entry 5253 (class 0 OID 0)
-- Dependencies: 311
-- Name: network_adapters_network_adapter_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.network_adapters_network_adapter_id_seq OWNED BY simplified.network_adapters.network_adapter_id;


--
-- TOC entry 331 (class 1259 OID 1528778)
-- Name: scheduled_task_run_sets; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.scheduled_task_run_sets (
    scheduled_task_run_set_id integer NOT NULL,
    scheduled_task_run_set_name text NOT NULL,
    run_start_time time without time zone,
    reason_why text,
    last_generated timestamp with time zone,
    last_run timestamp with time zone
);


ALTER TABLE simplified.scheduled_task_run_sets OWNER TO postgres;

--
-- TOC entry 5254 (class 0 OID 0)
-- Dependencies: 331
-- Name: TABLE scheduled_task_run_sets; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.scheduled_task_run_sets IS 'Use these to generate all the tasks. These are the Windows Task Scheduler folders and the set of tasks that it flows through, from some start time (daily) to the next.';


--
-- TOC entry 330 (class 1259 OID 1528777)
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
-- TOC entry 5255 (class 0 OID 0)
-- Dependencies: 330
-- Name: scheduled_task_run_sets_scheduled_task_run_set_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.scheduled_task_run_sets_scheduled_task_run_set_id_seq OWNED BY simplified.scheduled_task_run_sets.scheduled_task_run_set_id;


--
-- TOC entry 329 (class 1259 OID 1528766)
-- Name: scheduled_tasks; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.scheduled_tasks (
    scheduled_task_id integer NOT NULL,
    scheduled_task_directory text NOT NULL,
    scheduled_task_name text NOT NULL,
    order_in_set numeric(12,8),
    scheduled_task_run_set_id integer,
    must_run_after_scheduled_task_name text,
    script_path_to_run text,
    method_name text DEFAULT 'PowerShell'::text,
    append_argument_string text,
    scheduled_task_short_description text,
    execution_time_limit character varying DEFAULT 'PT2H'::character varying
);


ALTER TABLE simplified.scheduled_tasks OWNER TO postgres;

--
-- TOC entry 5256 (class 0 OID 0)
-- Dependencies: 329
-- Name: TABLE scheduled_tasks; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.scheduled_tasks IS 'Definitions, limited as they are of the tasks to generate and register to Windows Task Scheduler, and the order they are dependent. NOTE: ran over 2 hours! Setting to 3';


--
-- TOC entry 5257 (class 0 OID 0)
-- Dependencies: 329
-- Name: COLUMN scheduled_tasks.execution_time_limit; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.scheduled_tasks.execution_time_limit IS 'For Scheduled Task XML';


--
-- TOC entry 346 (class 1259 OID 1530299)
-- Name: scheduled_tasks_ext_v; Type: VIEW; Schema: simplified; Owner: postgres
--

CREATE VIEW simplified.scheduled_tasks_ext_v AS
 SELECT strs.scheduled_task_run_set_id,
    strs.scheduled_task_run_set_name,
    strs.run_start_time,
    st.scheduled_task_id,
    (((('\'::text || st.scheduled_task_directory) || '\'::text) || strs.scheduled_task_run_set_name) || '\'::text) AS scheduled_task_directory,
    ((((('\'::text || st.scheduled_task_directory) || '\'::text) || strs.scheduled_task_run_set_name) || '\'::text) || st.scheduled_task_name) AS uri,
    lag(st.scheduled_task_name) OVER (PARTITION BY strs.scheduled_task_run_set_id ORDER BY st.order_in_set) AS previous_task_name,
    lag(((((('\'::text || st.scheduled_task_directory) || '\'::text) || strs.scheduled_task_run_set_name) || '\'::text) || st.scheduled_task_name)) OVER (ORDER BY st.scheduled_task_run_set_id, st.order_in_set) AS previous_uri,
    st.scheduled_task_name,
    st.scheduled_task_short_description,
        CASE
            WHEN (st.script_path_to_run IS NULL) THEN (((((('D:\qt_projects\'::text || st.scheduled_task_directory) || '\simplified\tasks\scheduled_tasks\'::text) || strs.scheduled_task_run_set_name) || '\'::text) || st.scheduled_task_name) || '.ps1'::text)
            ELSE st.script_path_to_run
        END AS script_path_to_run,
    st.order_in_set,
        CASE
            WHEN ((st.script_path_to_run IS NOT NULL) AND (st.script_path_to_run !~~ (('%'::text || st.scheduled_task_name) || '.ps1'::text))) THEN 'WARNING: Name mismatch'::text
            ELSE ''::text
        END AS warning,
    st.execution_time_limit
   FROM (simplified.scheduled_tasks st
     JOIN simplified.scheduled_task_run_sets strs USING (scheduled_task_run_set_id));


ALTER TABLE simplified.scheduled_tasks_ext_v OWNER TO postgres;

--
-- TOC entry 5258 (class 0 OID 0)
-- Dependencies: 346
-- Name: VIEW scheduled_tasks_ext_v; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON VIEW simplified.scheduled_tasks_ext_v IS 'scheduled tasks with their sets (sub groups, streams) labeled';


--
-- TOC entry 328 (class 1259 OID 1528765)
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
-- TOC entry 5259 (class 0 OID 0)
-- Dependencies: 328
-- Name: scheduled_tasks_scheduled_task_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.scheduled_tasks_scheduled_task_id_seq OWNED BY simplified.scheduled_tasks.scheduled_task_id;


--
-- TOC entry 316 (class 1259 OID 1524969)
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
-- TOC entry 5260 (class 0 OID 0)
-- Dependencies: 316
-- Name: TABLE volumes; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.volumes IS 'Drives on Windows, with letters, mount points on linux. Unless it''s a NAS in which case it is a computer.';


--
-- TOC entry 5261 (class 0 OID 0)
-- Dependencies: 316
-- Name: COLUMN volumes.volume_serial_no; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.volumes.volume_serial_no IS 'In case moved to different computer, letter, label, then maybe this can identify it?';


--
-- TOC entry 5262 (class 0 OID 0)
-- Dependencies: 316
-- Name: COLUMN volumes.seq1m_q8t1_read; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.volumes.seq1m_q8t1_read IS 'Some are pretty slow, the nvme''s are blazing.  K is an external but at 7200 RPM and that helps.';


--
-- TOC entry 5263 (class 0 OID 0)
-- Dependencies: 316
-- Name: COLUMN volumes.is_log_dump; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.volumes.is_log_dump IS 'Only set ONE volume.  Then I can get rid of hard-coded "D" on the Show-Error function when it flushes the volume cache for logging.';


--
-- TOC entry 350 (class 1259 OID 1531648)
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
-- TOC entry 351 (class 1259 OID 1532470)
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
-- TOC entry 322 (class 1259 OID 1526234)
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
-- TOC entry 333 (class 1259 OID 1528787)
-- Name: search_terms; Type: TABLE; Schema: simplified; Owner: postgres
--

CREATE TABLE simplified.search_terms (
    search_term_id integer NOT NULL,
    search_term text NOT NULL,
    search_type text NOT NULL
);


ALTER TABLE simplified.search_terms OWNER TO postgres;

--
-- TOC entry 5264 (class 0 OID 0)
-- Dependencies: 333
-- Name: TABLE search_terms; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.search_terms IS 'This is how I find stuff on pirate bay, etc. archive.com takes some magic strings to find anything.';


--
-- TOC entry 5265 (class 0 OID 0)
-- Dependencies: 333
-- Name: COLUMN search_terms.search_term; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.search_terms.search_term IS 'The string or regex or magic google term to search the type (web, disk, etc.)';


--
-- TOC entry 332 (class 1259 OID 1528786)
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
-- TOC entry 348 (class 1259 OID 1531472)
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
-- TOC entry 349 (class 1259 OID 1531486)
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
-- TOC entry 347 (class 1259 OID 1531471)
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
-- TOC entry 327 (class 1259 OID 1527220)
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
-- TOC entry 5266 (class 0 OID 0)
-- Dependencies: 327
-- Name: TABLE video_files; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.video_files IS 'Of the media files I have, these are the video attributes Of Those Files.  Not attributes derived from external meta';


--
-- TOC entry 5267 (class 0 OID 0)
-- Dependencies: 327
-- Name: COLUMN video_files.title; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.video_files.title IS 'Just one. See "titles" table for all the extra titles that nobody can agree on being primary.  Being an englese speaker, I have my own baise.';


--
-- TOC entry 318 (class 1259 OID 1525028)
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
-- TOC entry 5268 (class 0 OID 0)
-- Dependencies: 318
-- Name: TABLE videos; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON TABLE simplified.videos IS 'all my lists: IMDB, TMDB, OMDB, and more eventually. I don''t even have OMDB yet. But I need a my id for these. IMDB, for instance, probably has the most quantity, so there will of course not be matching TMDB IDs, and so on. TMDB may have entries that are not in IMDB for some reason.
This is to be reduced from the complexities arising in receiving_dock, but I don''t want to go too simple. So what is the function? To give me a UNIQUE list of titles, whether movies, tv movies, shorts, tv shows, seasons, or episodes. BUT, since titles are not unique, we need present things that get us closer to a logical unique state. release year is one of the most meaningful additions to titles that gives a meaningful uniqueness - closer at least. The type of title, movie or tv for example, is another meaningful individuator. Why? Because collisions happen often between a tv show and a movie created because of that show, and in the same year.
No triggers, at least not just automatically tracking changes. Speed of analysis is more important.

After these key meaningful uniquifiers, what else needs to be here? Well, I put the external ids here so I can know how these came about, a way to trackback. Not a huge ton of information about what source, what table, what import session; those things bog down a table.

Major goal: Narrow this table for rapid analysis and joining work. Let views expand this out. But integers, for instance, instead of TEXT for things like the IMDB_ID. "tt4390820" as TEXT is more than double and int4. enums use less space than TEXT, so I use enums here. Metadata like record_created_date is left out. Because it has no effect on viewing, only on merges and deep etl analysis. I don''t care when I''m looking for stuff to watch, to not watch, etc. A lot of the metadata captured in stage_for_master is only relevant for making highly efficient ETLs. Here I don''t care. ';


--
-- TOC entry 5269 (class 0 OID 0)
-- Dependencies: 318
-- Name: COLUMN videos.video_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.video_id IS 'A unique id regardless of external id existence. The hook on which all relies.';


--
-- TOC entry 5270 (class 0 OID 0)
-- Dependencies: 318
-- Name: COLUMN videos.primary_title; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.primary_title IS 'What is "primary" about a title? Well, according to IMDB, on https://help.imdb.com/article/contribution/titles/title-formatting/G56U5ERK7YY47CQB?ref_=helpart_nav_3#, they store and capture the ORIGINAL TITLE in its ORIGINAL LANGUAGE as it appears on screen on-the-title-card. This results in the exported watch lists getting garbage titles no one recognizes. REGARDLESS of what is displayed on your IMDB list on your browser, that is merely the localized name. Don''t expect "Godzilla" movies to export in any useful value. A tad annoying.
In TMDB, however, or fortunately, you get the U.S.A. release title. The one normal people recognize. And they have a field called "original_title" aka garbage foreign title. That I save in the "titles" table.
Oh, and FYI: Get Over It.';


--
-- TOC entry 5271 (class 0 OID 0)
-- Dependencies: 318
-- Name: COLUMN videos.release_year; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.release_year IS 'Part of an alternate key, title+year+type. But, for example, "Godzilla" has been re-released a multitude of times, and the year separates them neatly and meaningfully. Meaningful in the sense that "Godzilla (1954)" is not ever "Godzilla (1998)". Ever. Chances are if you are remembering a movie from childhood, you''ll be able to tell which one it was by when it was released.';


--
-- TOC entry 5272 (class 0 OID 0)
-- Dependencies: 318
-- Name: COLUMN videos.is_episodic; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.is_episodic IS 'Force a choice: Is it a movie or tv? Is it one thing or a series of small things that add up to a whole? TV Mini-Series are a weird thing and not like TV Series, based on the original serials, but to effectuate the KISS principal we say: is it one thing or multiple things? Forget trilogies.';


--
-- TOC entry 5273 (class 0 OID 0)
-- Dependencies: 318
-- Name: COLUMN videos.title_is_descriptive; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.title_is_descriptive IS 'Is it a title we got from somewhere, even my head, or is is a description of something I''ve seen. Must capture even if I don''t know the exact name of it. These hopefully are converted to titles, often titles already in the database. But some are probably never to be found.';


--
-- TOC entry 5274 (class 0 OID 0)
-- Dependencies: 318
-- Name: COLUMN videos.video_edition_type; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.video_edition_type IS 'extended, director''s cut, uncut, censored, MST3K, RiffTrax, Svengoolie, despecialized. "Star Wars" is a great example of something needing recutting after George Lucas'' Director''s cut with added CGI goobers. But each of these deserves a separate entry. Why? Because "Zach Snyder''s Justice League" cut makes more sense (to me) than the studio cut, and deserves a different rating. Also, MST3K''s spoof of "This Island Earth" is not a fair treatment of the original movie, which stands on its own as early alien invasion reflection. Plotted poorly, but still canon.';


--
-- TOC entry 5275 (class 0 OID 0)
-- Dependencies: 318
-- Name: COLUMN videos.video_sub_type; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.video_sub_type IS 'Not a required thing since we might not know, and we still want to track it. We HAVE to know if it''s a movie or a tv show, but is it a TV Movie, or is it just a movie I saw on TV? I may not know yet, but I want to still track it. See, I hang watch history off this table, so I need a hook to hang on even if I don''t know exactly where or what I saw. I know, weird.
But a thing I saw in memory is must be a real thing. My knowledge of what it was does not effect its existence as a thing that could be seen.';


--
-- TOC entry 5276 (class 0 OID 0)
-- Dependencies: 318
-- Name: COLUMN videos.is_adult; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.is_adult IS 'A key metric. Why do I store these at all? More of exclusionary than anything, but I have expended hours (shock!) on adult video in my youth. In a measure of what percentage of a life was expended on video, this must be counted. Is any adult video of any value? No, of course not. But it happens. An hours watching "Debbie Does Dallas" is hours not living, or watching redeeming films like Animaniacs.';


--
-- TOC entry 5277 (class 0 OID 0)
-- Dependencies: 318
-- Name: COLUMN videos.runtime; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.runtime IS 'in minutes. When comparing IMDB and TMDB to each other, these often differ by 1 to 10 minutes. 10 minutes for some reason seems to be quite common. Are these differences significant? Perhaps but I don''t want to bloat this table with more minutia. So I''ll just pick one. We can go back to staging tables and the source if we decide these differences mean different footage.';


--
-- TOC entry 5278 (class 0 OID 0)
-- Dependencies: 318
-- Name: COLUMN videos.imdb_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.imdb_id IS 'not always populated, certainly not initially when I just have a TMDB entry. The damn "tt_" prefix is dumped, cute as it is.';


--
-- TOC entry 5279 (class 0 OID 0)
-- Dependencies: 318
-- Name: COLUMN videos.omdb_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.omdb_id IS 'Haven''t grabbed it yet. Not even sure it''s an INTEGER. But I know that OMDB links us to a bazillion other external data, specially wikidata, which is the hub of all links.';


--
-- TOC entry 5280 (class 0 OID 0)
-- Dependencies: 318
-- Name: COLUMN videos.parent_video_id; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.parent_video_id IS 'So the parent of the rifftrax spook will be the original theatrical movie. The parent for a TV episode will be either the TV Season or the TV Show. Which is dependent on the source ';


--
-- TOC entry 5281 (class 0 OID 0)
-- Dependencies: 318
-- Name: COLUMN videos.parent_title; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.parent_title IS 'This is something I pull from selfjoining back on tmdb_id or imdb_id data, and I want the ACTUAL string here so I can uniquify TV episodes. Many times episodes are not named, and I don''t want to fill in fakes to create logical uniques. I guess episode nos will make the unique key, but it''s not as pretty as unique titles.
Since I''m more a movie buff than tv buff, I put parent_title low on the view order. ';


--
-- TOC entry 5282 (class 0 OID 0)
-- Dependencies: 318
-- Name: COLUMN videos.season_no; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.season_no IS 'Any show have more than 255 seasons? Someday, long after me. But postgres isn''t really tinyint or byte supportive. Also, I''m not sure any of my sources layer show/season/episode, most seem to just have show/episode.';


--
-- TOC entry 5283 (class 0 OID 0)
-- Dependencies: 318
-- Name: COLUMN videos.episode_no; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.episode_no IS 'A reality show could have 360 shows a year, theoretically. So SMALLINT it is.';


--
-- TOC entry 5284 (class 0 OID 0)
-- Dependencies: 318
-- Name: COLUMN videos.file_hash; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON COLUMN simplified.videos.file_hash IS 'Torn: Do we use file content hash (BYTEA[]) or the id into the files table? Either must be unique (ignoring nulls), but one is a shadow property of the real. Also, the hash is generatable from the data, whereas file_id is dependent on the tablelized representation of that data. The file disappears then we''ll still have the record of it, not sure if that''s good or bad. In a practical way, the file disappears and we won''t have anything to watch! So what''s the point of it? Also, the file disappears (drive destroyed, etc.,) then if we redownload it from some other place, the hash can relink. So I''ve reasoned my answer. hash it is. And that will link into the file table, too.
One odd problem though: We would always have a unique serial file id, even if multiple files exist with identical hashes. This happens in copying about and downloading accidentally what I think I don''t have or I think is a better version. So we need a table of files that only points to one, and its uniqueness is by the hash - no nulls allowed. In fact, it wouldn''t need a surrogate? Hmmmmmmm. As to it''s file path, that''s still needed, perhaps two paths, one to the download, one to the published.

You might ask (I did,) why not make file_hash our primary key? Because I don''t have all million movies locally. And upcoming movies, non-extant movies, these won''t have hashes. Grr.';


--
-- TOC entry 339 (class 1259 OID 1528959)
-- Name: videos_to_video_files; Type: TABLE; Schema: simplified; Owner: filmcab_superuser
--

CREATE TABLE simplified.videos_to_video_files (
    video_to_video_file_id integer NOT NULL,
    video_id integer NOT NULL,
    video_file_id integer NOT NULL
);


ALTER TABLE simplified.videos_to_video_files OWNER TO filmcab_superuser;

--
-- TOC entry 5285 (class 0 OID 0)
-- Dependencies: 339
-- Name: TABLE videos_to_video_files; Type: COMMENT; Schema: simplified; Owner: filmcab_superuser
--

COMMENT ON TABLE simplified.videos_to_video_files IS 'Theoretically a video, the name of an actual film or show, could link to several video_files. the nature of that linkage could be samples, 360p or 720p, etc., corrupt, mkv or avi, a rifftrax or Svengoolie version of the same video? Or those would be different videos. So the many linkage is only to variants of the same physical movie. Note that hashs still won''t match across.';


--
-- TOC entry 317 (class 1259 OID 1525027)
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
-- TOC entry 5286 (class 0 OID 0)
-- Dependencies: 317
-- Name: videos_video_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.videos_video_id_seq OWNED BY simplified.videos.video_id;


--
-- TOC entry 315 (class 1259 OID 1524968)
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
-- TOC entry 5287 (class 0 OID 0)
-- Dependencies: 315
-- Name: volumes_volume_id_seq; Type: SEQUENCE OWNED BY; Schema: simplified; Owner: postgres
--

ALTER SEQUENCE simplified.volumes_volume_id_seq OWNED BY simplified.volumes.volume_id;


--
-- TOC entry 4880 (class 2604 OID 1529164)
-- Name: apps app_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.apps ALTER COLUMN app_id SET DEFAULT nextval('simplified.apps_app_id_seq'::regclass);


--
-- TOC entry 4879 (class 2604 OID 1529146)
-- Name: codecs codec_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.codecs ALTER COLUMN codec_id SET DEFAULT nextval('simplified.codecs_codec_id_seq'::regclass);


--
-- TOC entry 4857 (class 2604 OID 1524954)
-- Name: computers computer_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.computers ALTER COLUMN computer_id SET DEFAULT nextval('simplified.computers_computer_id_seq'::regclass);


--
-- TOC entry 4878 (class 2604 OID 1529133)
-- Name: file_extensions file_extension_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.file_extensions ALTER COLUMN file_extension_id SET DEFAULT nextval('simplified.file_extensions_file_extension_id_seq'::regclass);


--
-- TOC entry 4862 (class 2604 OID 1525177)
-- Name: files file_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.files ALTER COLUMN file_id SET DEFAULT nextval('simplified.files_file_id_seq'::regclass);


--
-- TOC entry 4854 (class 2604 OID 1524903)
-- Name: internet_service_providers internet_service_provider_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.internet_service_providers ALTER COLUMN internet_service_provider_id SET DEFAULT nextval('simplified.internet_service_providers_internet_service_provider_id_seq'::regclass);


--
-- TOC entry 4855 (class 2604 OID 1524914)
-- Name: local_networks local_network_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.local_networks ALTER COLUMN local_network_id SET DEFAULT nextval('simplified.local_networks_local_network_id_seq'::regclass);


--
-- TOC entry 4856 (class 2604 OID 1524936)
-- Name: network_adapters network_adapter_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.network_adapters ALTER COLUMN network_adapter_id SET DEFAULT nextval('simplified.network_adapters_network_adapter_id_seq'::regclass);


--
-- TOC entry 4876 (class 2604 OID 1528781)
-- Name: scheduled_task_run_sets scheduled_task_run_set_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.scheduled_task_run_sets ALTER COLUMN scheduled_task_run_set_id SET DEFAULT nextval('simplified.scheduled_task_run_sets_scheduled_task_run_set_id_seq'::regclass);


--
-- TOC entry 4873 (class 2604 OID 1528769)
-- Name: scheduled_tasks scheduled_task_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.scheduled_tasks ALTER COLUMN scheduled_task_id SET DEFAULT nextval('simplified.scheduled_tasks_scheduled_task_id_seq'::regclass);


--
-- TOC entry 4859 (class 2604 OID 1525031)
-- Name: videos video_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.videos ALTER COLUMN video_id SET DEFAULT nextval('simplified.videos_video_id_seq'::regclass);


--
-- TOC entry 4858 (class 2604 OID 1524972)
-- Name: volumes volume_id; Type: DEFAULT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.volumes ALTER COLUMN volume_id SET DEFAULT nextval('simplified.volumes_volume_id_seq'::regclass);


--
-- TOC entry 4995 (class 2606 OID 1532720)
-- Name: active_batch_run_session_running_values active_batch_run_session_running_values_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.active_batch_run_session_running_values
    ADD CONSTRAINT active_batch_run_session_running_values_pkey PRIMARY KEY (active_batch_run_session_id);


--
-- TOC entry 4987 (class 2606 OID 1531483)
-- Name: user_spreadsheet_interface ak_hash_of_all_columns; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.user_spreadsheet_interface
    ADD CONSTRAINT ak_hash_of_all_columns UNIQUE (hash_of_all_columns);


--
-- TOC entry 4989 (class 2606 OID 1531485)
-- Name: user_spreadsheet_interface ak_title_release_year; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.user_spreadsheet_interface
    ADD CONSTRAINT ak_title_release_year UNIQUE (manually_corrected_title);


--
-- TOC entry 4922 (class 2606 OID 1525041)
-- Name: videos ak_videos_hash; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.videos
    ADD CONSTRAINT ak_videos_hash UNIQUE NULLS NOT DISTINCT (tmdb_id);


--
-- TOC entry 5288 (class 0 OID 0)
-- Dependencies: 4922
-- Name: CONSTRAINT ak_videos_hash ON videos; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON CONSTRAINT ak_videos_hash ON simplified.videos IS 'Just link to ONE entry in our new files table. That table can deal with the multiple copies, urls, paths, etc.';


--
-- TOC entry 4924 (class 2606 OID 1525039)
-- Name: videos ak_videos_imdb; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.videos
    ADD CONSTRAINT ak_videos_imdb UNIQUE NULLS NOT DISTINCT (imdb_id);


--
-- TOC entry 5289 (class 0 OID 0)
-- Dependencies: 4924
-- Name: CONSTRAINT ak_videos_imdb ON videos; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON CONSTRAINT ak_videos_imdb ON simplified.videos IS 'These must self-unique when present. Technically, yes there can be two TMDB films mapped to one IMDB id, or the opposite. The more external ids the more this is likely to occur - but I won''t support that in this table. In precursors yes I do keep that info. How I will reconcile a duality that is m-to-1 between sources, I have no idea. But storing multiple ids from a source as one entry is not acceptable here. It would spawn incredible complexity and generate an inability to trust that an entry is unique in realspace. It breaks the model. Without this we can treat duplicates (due to mispells, mis-entries) are errors, and fixable. Otherwise it puts our sources in doubt.';


--
-- TOC entry 4926 (class 2606 OID 1525047)
-- Name: videos ak_videos_logical; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.videos
    ADD CONSTRAINT ak_videos_logical UNIQUE (primary_title, release_year, is_episodic, video_edition_type, parent_title, season_no, episode_no);


--
-- TOC entry 5290 (class 0 OID 0)
-- Dependencies: 4926
-- Name: CONSTRAINT ak_videos_logical ON videos; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON CONSTRAINT ak_videos_logical ON simplified.videos IS 'All videos must be definable as unique based on meaningful values. In this case, nulls ARE distinct. no episode_no? Then fill it in. You cannot ignore nulls in a logical key.';


--
-- TOC entry 4983 (class 2606 OID 1529170)
-- Name: apps apps_ak; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.apps
    ADD CONSTRAINT apps_ak UNIQUE NULLS NOT DISTINCT (app_name);


--
-- TOC entry 4985 (class 2606 OID 1529168)
-- Name: apps apps_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.apps
    ADD CONSTRAINT apps_pkey PRIMARY KEY (app_id);


--
-- TOC entry 4993 (class 2606 OID 1532647)
-- Name: batch_run_sessions_tasks batch_run_session_tasks_pk; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.batch_run_sessions_tasks
    ADD CONSTRAINT batch_run_session_tasks_pk PRIMARY KEY (batch_run_session_task_id);


--
-- TOC entry 4947 (class 2606 OID 1527288)
-- Name: batch_run_sessions batch_run_sessions_pk; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.batch_run_sessions
    ADD CONSTRAINT batch_run_sessions_pk PRIMARY KEY (batch_run_session_id);


--
-- TOC entry 4979 (class 2606 OID 1529152)
-- Name: codecs codecs_ak; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.codecs
    ADD CONSTRAINT codecs_ak UNIQUE NULLS NOT DISTINCT (codec);


--
-- TOC entry 4981 (class 2606 OID 1529150)
-- Name: codecs codecs_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.codecs
    ADD CONSTRAINT codecs_pkey PRIMARY KEY (codec_id);


--
-- TOC entry 4910 (class 2606 OID 1524962)
-- Name: computers computers_computer_name_network_id_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.computers
    ADD CONSTRAINT computers_computer_name_network_id_key UNIQUE (computer_name, network_id);


--
-- TOC entry 4912 (class 2606 OID 1524960)
-- Name: computers computers_device_guid_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.computers
    ADD CONSTRAINT computers_device_guid_key UNIQUE NULLS NOT DISTINCT (device_guid);


--
-- TOC entry 4914 (class 2606 OID 1524958)
-- Name: computers computers_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.computers
    ADD CONSTRAINT computers_pkey PRIMARY KEY (computer_id);


--
-- TOC entry 4938 (class 2606 OID 1525471)
-- Name: directories directories_directory_path_volume_id_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.directories
    ADD CONSTRAINT directories_directory_path_volume_id_key UNIQUE (directory_path, volume_id);


--
-- TOC entry 5291 (class 0 OID 0)
-- Dependencies: 4938
-- Name: CONSTRAINT directories_directory_path_volume_id_key ON directories; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON CONSTRAINT directories_directory_path_volume_id_key ON simplified.directories IS 'files can''t exist in the same place more than once.';


--
-- TOC entry 4940 (class 2606 OID 1525469)
-- Name: directories directories_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.directories
    ADD CONSTRAINT directories_pkey PRIMARY KEY (directory_hash);


--
-- TOC entry 5292 (class 0 OID 0)
-- Dependencies: 4940
-- Name: CONSTRAINT directories_pkey ON directories; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON CONSTRAINT directories_pkey ON simplified.directories IS 'Sure hope the hash is unique.  If not, back to the drawing board.';


--
-- TOC entry 4975 (class 2606 OID 1529139)
-- Name: file_extensions file_extensions_ak; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.file_extensions
    ADD CONSTRAINT file_extensions_ak UNIQUE NULLS NOT DISTINCT (file_extension);


--
-- TOC entry 4977 (class 2606 OID 1529137)
-- Name: file_extensions file_extensions_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.file_extensions
    ADD CONSTRAINT file_extensions_pkey PRIMARY KEY (file_extension_id);


--
-- TOC entry 4969 (class 2606 OID 1528951)
-- Name: file_links_across_search_paths file_links_across_volume_pk; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.file_links_across_search_paths
    ADD CONSTRAINT file_links_across_volume_pk PRIMARY KEY (file_links_across_volume_id);


--
-- TOC entry 4971 (class 2606 OID 1528953)
-- Name: file_links_across_search_paths file_links_across_volumes_functions_unique; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.file_links_across_search_paths
    ADD CONSTRAINT file_links_across_volumes_functions_unique UNIQUE (file_hash);


--
-- TOC entry 4934 (class 2606 OID 1525183)
-- Name: files files_file_name_no_ext_final_extension_directory_hash_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.files
    ADD CONSTRAINT files_file_name_no_ext_final_extension_directory_hash_key UNIQUE (file_name_no_ext, final_extension, directory_hash);


--
-- TOC entry 4936 (class 2606 OID 1525181)
-- Name: files files_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.files
    ADD CONSTRAINT files_pkey PRIMARY KEY (file_id);


--
-- TOC entry 4965 (class 2606 OID 1528893)
-- Name: genres genre_pk; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.genres
    ADD CONSTRAINT genre_pk PRIMARY KEY (genre_id);


--
-- TOC entry 4967 (class 2606 OID 1528895)
-- Name: genres genres_functions_unique; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.genres
    ADD CONSTRAINT genres_functions_unique UNIQUE (genre, genre_function);


--
-- TOC entry 4890 (class 2606 OID 1524909)
-- Name: internet_service_providers internet_service_providers_internet_service_provider_name_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.internet_service_providers
    ADD CONSTRAINT internet_service_providers_internet_service_provider_name_key UNIQUE (internet_service_provider_name);


--
-- TOC entry 4892 (class 2606 OID 1524907)
-- Name: internet_service_providers internet_service_providers_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.internet_service_providers
    ADD CONSTRAINT internet_service_providers_pkey PRIMARY KEY (internet_service_provider_id);


--
-- TOC entry 4894 (class 2606 OID 1524920)
-- Name: local_networks local_networks_internet_port_mac_address_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.local_networks
    ADD CONSTRAINT local_networks_internet_port_mac_address_key UNIQUE NULLS NOT DISTINCT (internet_port_mac_address);


--
-- TOC entry 4896 (class 2606 OID 1524926)
-- Name: local_networks local_networks_local_network_name_internet_service_provider_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.local_networks
    ADD CONSTRAINT local_networks_local_network_name_internet_service_provider_key UNIQUE (local_network_name, internet_service_provider_id);


--
-- TOC entry 4898 (class 2606 OID 1524924)
-- Name: local_networks local_networks_physical_address_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.local_networks
    ADD CONSTRAINT local_networks_physical_address_key UNIQUE NULLS NOT DISTINCT (physical_address);


--
-- TOC entry 4900 (class 2606 OID 1524918)
-- Name: local_networks local_networks_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.local_networks
    ADD CONSTRAINT local_networks_pkey PRIMARY KEY (local_network_id);


--
-- TOC entry 4902 (class 2606 OID 1524922)
-- Name: local_networks local_networks_wi_fi_address_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.local_networks
    ADD CONSTRAINT local_networks_wi_fi_address_key UNIQUE NULLS NOT DISTINCT (wi_fi_address);


--
-- TOC entry 4949 (class 2606 OID 1527040)
-- Name: media_files media_files_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.media_files
    ADD CONSTRAINT media_files_pkey PRIMARY KEY (media_file_id);


--
-- TOC entry 4904 (class 2606 OID 1524944)
-- Name: network_adapters network_adapters_network_adapter_name_local_network_id_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.network_adapters
    ADD CONSTRAINT network_adapters_network_adapter_name_local_network_id_key UNIQUE (network_adapter_name, local_network_id);


--
-- TOC entry 4906 (class 2606 OID 1524942)
-- Name: network_adapters network_adapters_physical_address_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.network_adapters
    ADD CONSTRAINT network_adapters_physical_address_key UNIQUE NULLS NOT DISTINCT (physical_address);


--
-- TOC entry 4908 (class 2606 OID 1524940)
-- Name: network_adapters network_adapters_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.network_adapters
    ADD CONSTRAINT network_adapters_pkey PRIMARY KEY (network_adapter_id);


--
-- TOC entry 4928 (class 2606 OID 1525037)
-- Name: videos pk_videos; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.videos
    ADD CONSTRAINT pk_videos PRIMARY KEY (video_id);


--
-- TOC entry 4953 (class 2606 OID 1528774)
-- Name: scheduled_tasks scheduled_task_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.scheduled_tasks
    ADD CONSTRAINT scheduled_task_pkey PRIMARY KEY (scheduled_task_id);


--
-- TOC entry 4959 (class 2606 OID 1528785)
-- Name: scheduled_task_run_sets scheduled_task_run_sets_pk; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.scheduled_task_run_sets
    ADD CONSTRAINT scheduled_task_run_sets_pk PRIMARY KEY (scheduled_task_run_set_id);


--
-- TOC entry 4957 (class 2606 OID 1528776)
-- Name: scheduled_tasks scheduled_tasks_scheduled_task_name_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.scheduled_tasks
    ADD CONSTRAINT scheduled_tasks_scheduled_task_name_key UNIQUE (scheduled_task_name);


--
-- TOC entry 4942 (class 2606 OID 1526243)
-- Name: search_directories search_directories_unique; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.search_directories
    ADD CONSTRAINT search_directories_unique UNIQUE (search_directory);


--
-- TOC entry 4944 (class 2606 OID 1526239)
-- Name: search_directories search_directory_pk; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.search_directories
    ADD CONSTRAINT search_directory_pk PRIMARY KEY (search_directory_id);


--
-- TOC entry 4961 (class 2606 OID 1528793)
-- Name: search_terms search_term_pk; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.search_terms
    ADD CONSTRAINT search_term_pk PRIMARY KEY (search_term_id);


--
-- TOC entry 4963 (class 2606 OID 1528795)
-- Name: search_terms search_terms_unique; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.search_terms
    ADD CONSTRAINT search_terms_unique UNIQUE (search_term, search_type);


--
-- TOC entry 4991 (class 2606 OID 1531481)
-- Name: user_spreadsheet_interface user_spreadsheet_interface_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.user_spreadsheet_interface
    ADD CONSTRAINT user_spreadsheet_interface_pkey PRIMARY KEY (id);


--
-- TOC entry 4951 (class 2606 OID 1527236)
-- Name: video_files video_files_pk; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.video_files
    ADD CONSTRAINT video_files_pk PRIMARY KEY (video_file_id);


--
-- TOC entry 4930 (class 2606 OID 1525045)
-- Name: videos videos_file_hash_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.videos
    ADD CONSTRAINT videos_file_hash_key UNIQUE NULLS NOT DISTINCT (file_hash);


--
-- TOC entry 4932 (class 2606 OID 1525043)
-- Name: videos videos_omdb_id_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.videos
    ADD CONSTRAINT videos_omdb_id_key UNIQUE NULLS NOT DISTINCT (omdb_id);


--
-- TOC entry 4973 (class 2606 OID 1528963)
-- Name: videos_to_video_files videos_to_video_files_pkey; Type: CONSTRAINT; Schema: simplified; Owner: filmcab_superuser
--

ALTER TABLE ONLY simplified.videos_to_video_files
    ADD CONSTRAINT videos_to_video_files_pkey PRIMARY KEY (video_to_video_file_id);


--
-- TOC entry 4916 (class 2606 OID 1524978)
-- Name: volumes volumes_drive_letter_computer_id_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.volumes
    ADD CONSTRAINT volumes_drive_letter_computer_id_key UNIQUE NULLS NOT DISTINCT (drive_letter, computer_id);


--
-- TOC entry 4918 (class 2606 OID 1524976)
-- Name: volumes volumes_pkey; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.volumes
    ADD CONSTRAINT volumes_pkey PRIMARY KEY (volume_id);


--
-- TOC entry 4920 (class 2606 OID 1524980)
-- Name: volumes volumes_volume_name_computer_id_key; Type: CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.volumes
    ADD CONSTRAINT volumes_volume_name_computer_id_key UNIQUE NULLS NOT DISTINCT (volume_name, computer_id);


--
-- TOC entry 4945 (class 1259 OID 1526629)
-- Name: batch_run_sessions_one_true; Type: INDEX; Schema: simplified; Owner: postgres
--

CREATE UNIQUE INDEX batch_run_sessions_one_true ON simplified.batch_run_sessions USING btree (running) WHERE (running IS NOT NULL);


--
-- TOC entry 4954 (class 1259 OID 1528815)
-- Name: scheduled_tasks_order_in_set_idx; Type: INDEX; Schema: simplified; Owner: postgres
--

CREATE UNIQUE INDEX scheduled_tasks_order_in_set_idx ON simplified.scheduled_tasks USING btree (order_in_set, scheduled_task_run_set_id);


--
-- TOC entry 4955 (class 1259 OID 1528817)
-- Name: scheduled_tasks_scheduled_task_name_idx; Type: INDEX; Schema: simplified; Owner: postgres
--

CREATE UNIQUE INDEX scheduled_tasks_scheduled_task_name_idx ON simplified.scheduled_tasks USING btree (scheduled_task_name, scheduled_task_run_set_id);


--
-- TOC entry 5008 (class 2606 OID 1532648)
-- Name: batch_run_sessions_tasks batch_run_sessions_tasks_batch_run_session_id_fkey; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.batch_run_sessions_tasks
    ADD CONSTRAINT batch_run_sessions_tasks_batch_run_session_id_fkey FOREIGN KEY (batch_run_session_id) REFERENCES simplified.batch_run_sessions(batch_run_session_id);


--
-- TOC entry 4998 (class 2606 OID 1524963)
-- Name: computers computers_network_id_fkey; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.computers
    ADD CONSTRAINT computers_network_id_fkey FOREIGN KEY (network_id) REFERENCES simplified.network_adapters(network_adapter_id);


--
-- TOC entry 5000 (class 2606 OID 1527230)
-- Name: files files_directory_hash_fkey; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.files
    ADD CONSTRAINT files_directory_hash_fkey FOREIGN KEY (directory_hash) REFERENCES simplified.directories(directory_hash);


--
-- TOC entry 5001 (class 2606 OID 1528974)
-- Name: directories fk_directories_search_paths; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.directories
    ADD CONSTRAINT fk_directories_search_paths FOREIGN KEY (search_directory_id) REFERENCES simplified.search_directories(search_directory_id);


--
-- TOC entry 5002 (class 2606 OID 1525472)
-- Name: directories fk_directories_volume_id; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.directories
    ADD CONSTRAINT fk_directories_volume_id FOREIGN KEY (volume_id) REFERENCES simplified.volumes(volume_id);


--
-- TOC entry 5003 (class 2606 OID 1527041)
-- Name: media_files fk_media_file_is_file; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.media_files
    ADD CONSTRAINT fk_media_file_is_file FOREIGN KEY (media_file_id) REFERENCES simplified.files(file_id);


--
-- TOC entry 5004 (class 2606 OID 1527225)
-- Name: video_files fk_video_to_media; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.video_files
    ADD CONSTRAINT fk_video_to_media FOREIGN KEY (video_file_id) REFERENCES simplified.media_files(media_file_id);


--
-- TOC entry 5006 (class 2606 OID 1528964)
-- Name: videos_to_video_files fk_videos_to_video_files_video_files_1; Type: FK CONSTRAINT; Schema: simplified; Owner: filmcab_superuser
--

ALTER TABLE ONLY simplified.videos_to_video_files
    ADD CONSTRAINT fk_videos_to_video_files_video_files_1 FOREIGN KEY (video_file_id) REFERENCES simplified.video_files(video_file_id);


--
-- TOC entry 5007 (class 2606 OID 1528969)
-- Name: videos_to_video_files fk_videos_to_video_files_videos_1; Type: FK CONSTRAINT; Schema: simplified; Owner: filmcab_superuser
--

ALTER TABLE ONLY simplified.videos_to_video_files
    ADD CONSTRAINT fk_videos_to_video_files_videos_1 FOREIGN KEY (video_id) REFERENCES simplified.videos(video_id);


--
-- TOC entry 4996 (class 2606 OID 1524927)
-- Name: local_networks local_networks_internet_service_provider_id_fkey; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.local_networks
    ADD CONSTRAINT local_networks_internet_service_provider_id_fkey FOREIGN KEY (internet_service_provider_id) REFERENCES simplified.internet_service_providers(internet_service_provider_id);


--
-- TOC entry 4997 (class 2606 OID 1524945)
-- Name: network_adapters network_adapters_local_network_id_fkey; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.network_adapters
    ADD CONSTRAINT network_adapters_local_network_id_fkey FOREIGN KEY (local_network_id) REFERENCES simplified.local_networks(local_network_id);


--
-- TOC entry 5005 (class 2606 OID 1528801)
-- Name: scheduled_tasks scheduled_tasks_scheduled_task_run_sets_fk; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.scheduled_tasks
    ADD CONSTRAINT scheduled_tasks_scheduled_task_run_sets_fk FOREIGN KEY (scheduled_task_run_set_id) REFERENCES simplified.scheduled_task_run_sets(scheduled_task_run_set_id);


--
-- TOC entry 5293 (class 0 OID 0)
-- Dependencies: 5005
-- Name: CONSTRAINT scheduled_tasks_scheduled_task_run_sets_fk ON scheduled_tasks; Type: COMMENT; Schema: simplified; Owner: postgres
--

COMMENT ON CONSTRAINT scheduled_tasks_scheduled_task_run_sets_fk ON simplified.scheduled_tasks IS 'Every task must be part of exactly ONE set.  Don''t want to get into tasks in multiple sets.';


--
-- TOC entry 4999 (class 2606 OID 1524981)
-- Name: volumes volumes_computer_id_fkey; Type: FK CONSTRAINT; Schema: simplified; Owner: postgres
--

ALTER TABLE ONLY simplified.volumes
    ADD CONSTRAINT volumes_computer_id_fkey FOREIGN KEY (computer_id) REFERENCES simplified.computers(computer_id);



--
-- PostgreSQL database dump complete
--


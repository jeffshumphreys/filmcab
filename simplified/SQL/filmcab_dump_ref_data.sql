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

SET default_tablespace = '';

SET default_table_access_method = heap;

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
-- Data for Name: typs; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (6, 'TV Movie', 1, '2023-09-06 13:56:00.147114-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (1, 'Movie', 2, '2023-09-06 13:54:40.440867-06', '2023-09-06 13:56:00.156186-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (2, 'Video', 5, '2023-09-06 13:54:40.47824-06', '2023-09-06 13:56:00.157685-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (3, 'TV Series', 2, '2023-09-06 13:54:40.480035-06', '2023-09-06 13:56:00.158517-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (4, 'TV Episode', 3, '2023-09-06 13:54:40.481086-06', '2023-09-23 15:36:42.23829-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (8, 'Downloaded Torrent File', 7, '2023-09-23 15:38:18.514478-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (9, 'Published and name cleaned up from torrent', 8, '2023-09-27 17:38:18.424615-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (10, 'Backed up from published folders', 9, '2023-09-27 17:39:20.59774-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (7, 'File', 11, '2023-09-23 15:31:39.244107-06', '2023-10-12 16:21:24.775142-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, true, '2023-10-12 16:21:24.775148-06', NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (11, 'File System Components', NULL, '2023-10-12 13:40:54.636979-06', '2023-10-12 16:21:40.85895-06', NULL, NULL, NULL, NULL, true, '2023-10-12 13:40:54.637021-06', NULL, 11, true, '2023-10-12 16:21:40.858956-06', NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (12, 'Directory', 11, '2023-10-12 16:49:42.357193-06', NULL, NULL, NULL, NULL, NULL, true, '2023-10-12 16:49:42.357254-06', NULL, NULL, true, '2023-10-12 16:49:42.357259-06', NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (5, 'Media File', 7, '2023-09-06 13:54:40.481991-06', '2023-10-12 16:51:28.375471-06', NULL, NULL, NULL, 'Media', true, '2023-10-12 16:51:28.375477-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (13, 'Process', NULL, '2023-10-20 18:24:59.01795-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (14, 'Batch', 13, '2023-10-20 18:25:35.32907-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (15, 'Loading File Detail into Database', 14, '2023-10-20 18:26:31.801582-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (17, 'Video Support File', 7, '2023-10-29 12:49:14.869442-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (16, 'Subtitles', 17, '2023-10-29 12:48:39.595647-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (18, 'DVD', 7, '2023-10-29 12:52:00.311799-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (19, 'Video Object File', 18, '2023-10-29 12:52:00.313269-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (20, 'DVD Video', 19, '2023-10-29 12:52:00.314258-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (21, 'DVD Subtitles', 19, '2023-10-29 12:52:00.315258-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (22, 'DVD Index', 19, '2023-10-29 12:52:00.315998-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (24, 'Internal File Format', NULL, '2023-11-25 15:35:54.227668-07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (23, 'JSON', 24, '2023-11-25 14:14:23.278385-07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (25, 'Tab-delimited', 24, '2023-11-25 15:36:37.105034-07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (26, 'Comma-delimited', 24, '2023-11-25 15:36:53.419706-07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (27, 'Torrent File', 7, '2023-11-29 14:25:17.130074-07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (28, 'Incomplete Torrent Download', 7, '2023-11-29 14:34:51.275028-07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.typs (id, txt, typ_id, record_created_on_ts_wth_tz, record_changed_on_ts_wth_tz, record_deleted, record_deleted_on_ts_wth_tz, record_deleted_why, txt_prev, txt_corrected, txt_corrected_on_ts_wth_tz, txt_corrected_why, typ_prev, typ_corrected, typ_corrected_on_ts_wth_tz, typ_corrected_why, loading_batch_run_id, mapped_to_file_extension) VALUES (29, 'Flow', NULL, '2023-11-29 15:15:37.782755-07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);


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
-- Name: typs typs_typ_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.typs
    ADD CONSTRAINT typs_typ_id_fkey FOREIGN KEY (typ_id) REFERENCES public.typs(id) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--


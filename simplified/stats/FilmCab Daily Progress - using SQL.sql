SELECT 
  (SELECT count(*) FROM files f JOIN file_extensions fe ON file_extension = f.final_extension AND fe.file_is_video_content) AS "How many video files",
  (SELECT count(*) AS "How many files" FROM files), 
  (SELECT sum(row_count) AS "How many rows" FROM (SELECT table_name, (SELECT n_live_tup FROM pg_stat_user_tables WHERE relname = table_name AND schemaname = 'simplified') AS row_count FROM information_schema. tables WHERE table_schema = 'simplified') AS "How many rows")
;
  select sum(pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)))::bigint 
AS "Db Size" from pg_tables where schemaname = 'simplified';
SELECT COUNT(*) FROM information_schema.COLUMNS WHERE table_schema = 'simplified';
SELECT * FROM information_schema.TABLES WHERE table_schema = 'simplified' AND table_type = 'BASE TABLE';
SELECT * FROM information_schema.TABLES WHERE table_schema = 'simplified' AND table_type = 'VIEW';
SELECT * FROM scheduled_tasks_ext_v stev;
SELECT * FROM batch_run_sessions_scheduled_and_completed_v brssacv ;
SELECT SUM(bytes_moved) FROM moves;
SELECT * FROM file_extensions fe WHERE file_is_media_content IS null;
select pg_database_size('filmcab');
select pg_size_pretty(pg_database_size('filmcab'));
SELECT table_name, (SELECT n_live_tup FROM pg_stat_user_tables WHERE relname = table_name AND schemaname = 'simplified') AS row_count FROM information_schema. tables WHERE table_schema = 'simplified';
SELECT * FROM pg_stat_user_tables ;
SELECT * FROM 
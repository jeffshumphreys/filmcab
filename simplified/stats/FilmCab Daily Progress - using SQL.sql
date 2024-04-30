SELECT 
  (SELECT count(*)          AS "How many video files" FROM files f JOIN file_extensions fe ON file_extension = f.final_extension AND fe.file_is_video_content),
  (SELECT count(*)          AS "How many files" FROM files), 
  (SELECT count(*)          AS "How many videos watched" FROM user_spreadsheet_interface usi WHERE seen = 'y'),
  (SELECT count(*)          AS "have" FROM user_spreadsheet_interface usi WHERE have = 'y'),
  (SELECT sum(row_count)    AS "How many rows" FROM (SELECT table_name, (SELECT n_live_tup FROM pg_stat_user_tables WHERE relname = table_name AND schemaname = 'simplified') AS row_count FROM information_schema. tables WHERE table_schema = 'simplified') AS "How many rows"),
  (SELECT round(SUM(bytes_moved) / 1000/1000/1000, 2) 
                            AS "Move Size (GB)" FROM moves),
  (SELECT sum(pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)))::bigint / 1000.0 / 1000.0 
                            AS "Db Size (MB)" from pg_tables where schemaname = 'simplified'),
  (SELECT COUNT(*)          AS "How many Tables" FROM information_schema.TABLES WHERE table_schema = 'simplified' AND table_type = 'BASE TABLE'),
  (SELECT COUNT(*)          AS "How many Views" FROM information_schema.TABLES WHERE table_schema = 'simplified' AND table_type = 'VIEW'),
  (SELECT COUNT(*)          AS "How many Columns" FROM information_schema.COLUMNS WHERE table_schema = 'simplified'),
  (SELECT COUNT(*)          AS "Active Tasks" FROM scheduled_tasks WHERE is_enabled)
;
SELECT * FROM batch_run_sessions_scheduled_and_completed_v brssacv ;
SELECT * FROM file_extensions fe WHERE file_is_media_content IS null;
select pg_database_size('filmcab');
select pg_size_pretty(pg_database_size('filmcab'));
SELECT table_name, (SELECT n_live_tup FROM pg_stat_user_tables WHERE relname = table_name AND schemaname = 'simplified') AS row_count FROM information_schema. tables WHERE table_schema = 'simplified';
SELECT * FROM pg_stat_user_tables ;
show data_directory;
ALTER TABLE scheduled_tasks ADD COLUMN is_enabled BOOL DEFAULT(True);
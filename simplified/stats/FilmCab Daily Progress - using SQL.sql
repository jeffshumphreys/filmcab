SELECT count(*) AS "How many files" FROM files;
SELECT * FROM information_schema.TABLES WHERE table_schema = 'simplified' AND table_type = 'BASE TABLE';
SELECT * FROM information_schema.TABLES WHERE table_schema = 'simplified' AND table_type = 'VIEW';
SELECT COUNT(*) FROM information_schema.COLUMNS WHERE table_schema = 'simplified';
SELECT * FROM scheduled_tasks_ext_v stev;
SELECT * FROM batch_run_sessions_scheduled_and_completed_v brssacv ;
SELECT SUM(bytes_moved) FROM moves;
SELECT * FROM file_extensions fe WHERE file_is_media_content IS null;
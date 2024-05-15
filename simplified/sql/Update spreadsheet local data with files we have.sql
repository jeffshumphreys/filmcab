SELECT file_name_no_ext FROM files_ext_v WHERE search_directory_tag = 'published';

UPDATE user_spreadsheet_interface SET have = 'y' WHERE manually_corrected_title IN(
    SELECT usi.manually_corrected_title --, directory, file_id, final_extension 
    FROM user_spreadsheet_interface usi JOIN files_ext_v f
    ON usi.manually_corrected_title  = f.file_name_no_ext 
    WHERE f.search_directory_tag = 'published'
    AND directory <> 'O:\Video AllInOne\__Jeff wants to watch'
    AND NOT file_moved_out  AND NOT file_deleted 
    AND final_extension in(SELECT file_extension FROM file_extensions fe WHERE fe.file_is_video_content)
    AND (have IS NULL OR have = 'n' OR have = '')
);

SELECT started, ended , session_starting_script, session_ending_script, run_duration_in_minutes FROM batch_run_sessions_v brsv WHERE session_starting_script = '_start_new_batch_run_session.ps1' ORDER BY started DESC;



SET search_path = simplified, "$user", public;
WITH x AS (SELECT txt file_path, id as file_id from stage_for_master.files 
    WHERE (file_lost IS NULL OR file_lost IS FALSE)
    AND (updated_file_hash IS NULL OR updated_file_hash IS FALSE)
) SELECT count(*) FROM x;
-- Getting ready to pull these over into simplified.video_files.
SELECT txt, file_size, file_md5_hash, updated_file_hash, file_lost  FROM stage_for_master.files WHERE id IN(20240, 18234, 20408);
SELECT file_hash, volume_id, sourced_directory_hash, sourced_file_name_no_ext, final_extension, file_size, file_date, file_still_exists 
FROM video_files vf ;
-- Create simplified.files and store it all.
SELECT
      -- file_id gen int4
      file_md5_hash                                                                                           file_hash
    , (SELECT volume_id FROM volumes WHERE drive_letter = LEFT(txt,1))                                        volume_id
    , md5(array_to_string((string_to_array(SUBSTRING(txt, 4), '/'))[:(howmanychar(txt, '/')-1)], '/'))::bytea sourced_directory_hash
    -- parent, grandparent to detect quickly what "English_1.srt" goes to.
    , base_name                                                                                               sourced_file_name_no_ext 
    , final_extension                                                                                         final_extension 
    , file_size                                                                                               file_size 
    , file_modified_on_ts_wth_tz                                                                              file_date
    , count(*) OVER() 
FROM
    stage_for_master.files f
    WHERE (f.file_lost IS NULL OR f.file_lost IS FALSE) AND f.updated_file_hash IS TRUE
    --AND final_extension IN('mkv', 'mp4', 'vob', 'f4v', 'avi', 'flv', 'mov', 'mpg', 'ogv', 'webm', 'wmv') 
    --AND NOT (lower(base_name) = lower('sample') OR base_name ILIKE '%sample')
 ORDER BY file_size 
 -- delete To Have and Have Not (1944) on volume 5 of size 0
 -- no deletions off vol 2 (downloads)
 DROP TABLE IF EXISTS stage_for_master_files_to_simp_video_files;
WITH x AS(
SELECT 
    file_md5_hash                                                                                           AS file_hash,
    md5(array_to_string((string_to_array(SUBSTRING(txt, 4), '/'))[:(howmanychar(txt, '/')-1)], '/'))::bytea AS sourced_directory_hash, 
    base_name                                                                                               AS sourced_file_name_no_ext,
    final_extension                                                                                         AS final_extension,
    file_size                                                                                               AS file_size,
    file_modified_on_ts_wth_tz                                                                              AS file_date,
    NULL::BOOLEAN                                                                                           AS file_still_exists
    FROM stage_for_master.files f 
    WHERE (record_deleted IS NULL OR record_deleted IS FALSE) AND (file_lost IS NULL OR file_lost IS FALSE)
    AND final_extension in('avi', 'f4v', 'flv', 'mkv', 'mov', 'mp4', 'mpg', 'ogv', 'vob', 'webm', 'wmv')
    AND base_name NOT IN('Sample')
)
SELECT x.* 
INTO TEMPORARY stage_for_master_files_to_simp_video_files -- 17,000 files
FROM x 
;
SELECT COUNT(*), sum(dupct) FROM ( -- 5,364, now up!!!!! TO 7,567?????????
SELECT file_md5_hash, COUNT(*) dupct FROM stage_for_master.files f GROUP BY file_md5_hash HAVING COUNT(*) > 1 ORDER BY dupct DESC
) x;
SELECT file_hash, COUNT(*) FROM stage_for_master_files_to_simp_video_files GROUP BY file_hash;
SELECT file_hash, COUNT(*) dupct, max(sourced_file_name_no_ext) FROM stage_for_master_files_to_simp_video_files GROUP BY file_hash ORDER BY dupct DESC;
SELECT COUNT(*) FROM (SELECT file_hash, COUNT(*) FROM stage_for_master_files_to_simp_video_files GROUP BY file_hash) x; -- 8,140 dups, quads!
SELECT * FROM stage_for_master_files_to_simp_video_files WHERE file_hash = 'd41d8cd98f00b204e9800998ecf8427e';
SELECT txt AS file_path, id AS file_id, file_size, Count(*) over() FROM stage_for_master.files WHERE (file_lost IS NULL OR file_lost IS FALSE) AND (updated_file_hash IS NULL OR updated_file_hash IS FALSE)
ORDER BY file_id;
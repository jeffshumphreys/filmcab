WITH possible_unpublished_backups AS (SELECT file_id, search_directory_tag, file_path, COUNT(*) OVER() AS HowManyEligibleFiles, file_size, file_hash
FROM
    files_ext_v
WHERE
    search_directory_tag = 'backup'
AND 
    NOT file_deleted 
AND
    NOT file_is_symbolic_link
AND
    NOT file_is_hard_link
AND
    NOT moved_out
)
, published_files AS (SELECT file_hash, moved_out, file_deleted FROM files_ext_v WHERE search_directory_tag = 'published' AND NOT file_deleted)
SELECT 'DEL /Q "' || file_path || '"' AS script,
b.*, COUNT(*) OVER() deletable, SUM(b.file_size) OVER() how_much_space_restarable
FROM possible_unpublished_backups b WHERE b.file_hash NOT IN(SELECT file_hash FROM published_files)
ORDER BY b.file_size DESC;
SELECT * FROM files_ext_v WHERE file_name_no_ext = 'Mystery Science Theater 3000 The Movie (1996)';

-- 6F10A17C4CC209ECB58418DEB35F17AA   - 2122068630
-- 62BCAFA580E2E4DEEA5BBB3E27037FFE   - 2859916874
-- C:\Users\jeffs\dwhelper

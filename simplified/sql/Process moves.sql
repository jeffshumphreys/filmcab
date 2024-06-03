WITH RECURSIVE nodes AS (
                SELECT *, 'K:\Video AllInOne Won''t Watch' || '\' || dev.useful_part_of_directory          AS new_directory
                FROM directories_ext_v dev WHERE directory = 'O:\Video AllInOne\_Mystery\Annika (2021-)'
            UNION ALL
                SELECT dev.*, 'K:\Video AllInOne Won''t Watch' || '\' || dev.useful_part_of_directory      AS new_directory
                FROM directories_ext_v dev JOIN nodes ON dev.parent_directory_hash = nodes.directory_hash
            )
            , recalc_folders AS (
                SELECT
                    *
                ,   reverse((string_to_array(reverse(new_directory), '\'))[1])                                 AS new_folder
                ,   reverse((string_to_array(reverse(new_directory), '\'))[2])                                 AS new_parent_folder
                ,   reverse((string_to_array(reverse(new_directory), '\'))[3])                                 AS new_grandparent_folder
                ,   Left(directory, length(directory)-(length(folder)+1))                                      AS new_parent_directory
                ,   md5_hash_path(new_directory)                                                               AS new_directory_hash
                FROM
                    nodes
            )
            --DELETE FROM files_v WHERE directory_hash IN(SELECT new_directory_hash FROM recalc_folders);
            DELETE FROM directories_v WHERE directory_hash IN(SELECT new_directory_hash FROM recalc_folders)
            --SELECT DIRECTORY, directory_hash , new_directory_hash, move_id, moved_out, moved_in, moved_to_directory_hash  FROM RECALC_FOLDERS
--            WHERE new_directory_hash  in(SELECT directory_hash FROM directories_v)
        ;
SELECT * FROM moves;
SELECT * FROM directories_ext_v dev WHERE move_id IS NOT NULL;
SELECT * FROM files_ext_v WHERE move_id IS NOT NULL;

DELETE FROM directories_v WHERE move_id IS NOT NULL AND moved_in;
UPDATE directories_v SET move_id = NULL, moved_in = NULL, moved_out = NULL WHERE move_id IS NOT NULL;
DELETE FROM files_v WHERE move_id IS NOT NULL AND moved_in;
UPDATE files_v SET move_id = NULL, moved_out = NULL WHERE move_id IS NOT NULL;
DELETE FROM moves;
WITH RECURSIVE nodes AS (
                SELECT *, 'K:\Video AllInOne Won''t Watch\' || dev.useful_part_of_directory          AS new_directory
                FROM directories_ext_v dev WHERE directory = 'O:\Video AllInOne\_Mystery\Annika (2021-)'
            UNION ALL
                SELECT dev.*, 'K:\Video AllInOne Won''t Watch\' || dev.useful_part_of_directory      AS new_directory
                FROM directories_ext_v dev JOIN nodes ON dev.parent_directory_hash = nodes.directory_hash
            )
            , newstuff1 AS (
                SELECT *,
                /*     folder                      */ reverse((string_to_array(reverse(new_directory), '\'))[1]) AS new_folder,
                /*     parent_folder               */ reverse((string_to_array(reverse(new_directory), '\'))[2]) AS new_parent_folder,
                /*     grantparent_folder          */ reverse((string_to_array(reverse(new_directory), '\'))[3]) AS new_grandparent_folder
                FROM nodes
            )
            , newstuff2 AS (
                SELECT *,
                    md5_hash_path(new_directory)                            AS new_directory_hash
                ,   Left(directory, length(directory)-(length(folder)+1))   AS new_parent_directory
                FROM newstuff1
            )
           /* INSERT INTO
                directories_v(
                    directory_hash,
                    directory,
                    parent_directory_hash,
                    directory_date,
                    volume_id,
                    search_directory_id,
                    folder,
                    parent_folder,
                    grandparent_folder,
                    directory_deleted,
                    move_id
                ,   moved_in
                )*/
            SELECT
                new_directory_hash                     AS directory_hash,
                new_directory                          AS directory,
                md5_hash_path(new_parent_directory)    AS parent_directory_hash,
                directory_date                         AS directory_date,           /* Should be same? */
                11                        AS volume_id,
                10            AS search_directory_id,
                new_folder                             AS folder,
                new_parent_folder                      AS parent_folder,
                new_grandparent_folder                 AS grandparent_folder,
                directory_deleted                      AS directory_deleted,
                4                               AS move_id,
                True                                   AS moved_in
            FROM
                newstuff2;
SELECT transaction_timestamp();
            WITH RECURSIVE nodes AS (
                SELECT *, 'K:\Video AllInOne Won''t Watch' || '\' || dev.useful_part_of_directory          AS new_directory
                FROM directories_ext_v dev WHERE directory = 'O:\Video AllInOne\_Mystery\Annika (2021-)'
            UNION ALL
                SELECT dev.*, 'K:\Video AllInOne Won''t Watch' || '\' || dev.useful_part_of_directory      AS new_directory
                FROM directories_ext_v dev JOIN nodes ON dev.parent_directory_hash = nodes.directory_hash
            ),
            all_files AS (
                SELECT f.*, nodes.new_directory FROM files_ext_v f JOIN nodes USING(directory_hash)
            )
            UPDATE
                files_v
            SET
                move_id                 = 23
            ,   moved_out               = True
            ,   moved_to_directory_hash = md5_hash_path(y.new_directory)
            FROM
                all_files y
            WHERE
                files_v.file_id = y.file_id;
 WITH RECURSIVE nodes AS (
                SELECT *, 'K:\Video AllInOne Won''t Watch' || '\' || dev.useful_part_of_directory          AS new_directory
                FROM directories_ext_v dev WHERE directory = 'O:\Video AllInOne\_Mystery'
            UNION ALL
                SELECT dev.*, 'K:\Video AllInOne Won''t Watch' || '\' || dev.useful_part_of_directory      AS new_directory
                FROM directories_ext_v dev JOIN nodes ON dev.parent_directory_hash = nodes.directory_hash
            )
            , recalc_folders AS (
                SELECT
                    *
                ,   reverse((string_to_array(reverse(new_directory), '\'))[1])                                 AS new_folder
                ,   reverse((string_to_array(reverse(new_directory), '\'))[2])                                 AS new_parent_folder
                ,   reverse((string_to_array(reverse(new_directory), '\'))[3])                                 AS new_grandparent_folder
                ,   Left(directory, length(directory)-(length(folder)+1))                                      AS new_parent_directory
                ,   md5_hash_path(new_directory)                                                               AS new_directory_hash
                FROM
                    nodes
            )
            --INSERT INTO
            --    directories_v(
            --        directory_hash
            --    ,   directory
            --    ,   parent_directory_hash
            --    ,   directory_date
            --    ,   volume_id
            --    ,   search_directory_id
            --    ,   folder
            --    ,   parent_folder
            --    ,   grandparent_folder
            --    ,   directory_deleted
            --    ,   move_id
            --    ,   moved_in
            --    ,   moved_from_directory_hash
            --    ,   moved_from_volume_id
            --    ,   moved_from_directory_id
            --    )
                SELECT
                    new_directory_hash                     AS directory_hash
                ,   new_directory                          AS directory
                ,   md5_hash_path(new_parent_directory)    AS parent_directory_hash
                ,   directory_date                         AS directory_date           /* Should be same as original? Or when it copied did it change? "Move: You are physically moving the original file to some place else, just like keeping the flower vase 
in next room, which means, you have not created anything new- but just moved it to another place. So only access stamps needs change, created and modified remains same. "*/
                ,   11                        AS volume_id
                ,   10            AS search_directory_id
                ,   new_folder                             AS folder
                ,   new_parent_folder                      AS parent_folder
                ,   new_grandparent_folder                 AS grandparent_folder
                ,   directory_deleted                      AS directory_deleted
                ,   27                               AS move_id
                ,   True                                   AS moved_in
                ,   directory_hash                         AS moved_from_directory_hash
                ,   8                        AS moved_from_volume_id
                ,   directory_id                           AS moved_from_directory_id
                FROM
                    recalc_folders;
/*
 *  UGLY REPAIR
 */                
SELECT * FROM moves WHERE moves.bytes_moved = 0;
SELECT * FROM moves WHERE move_ended IS NULL; /* delete move_id = 184 */
SELECT * FROM moves ORDER BY move_id DESC;
SELECT * FROM directories_ext_v dev WHERE directory LIKE '%Don %' AND moved_in;
SELECT * FROM directories_ext_v dev WHERE directory LIKE '%Don %' AND moved_out; /* set move_id to null, moved_out = false, moved_to_volume_id to null */
SELECT * FROM files_ext_v WHERE directory_hash in(SELECT directory_hash  FROM directories_ext_v dev WHERE directory LIKE '%Don %' AND moved_in) AND file_moved_in ;
SELECT * FROM files_ext_v WHERE directory_hash in(SELECT directory_hash  FROM directories_ext_v dev WHERE directory LIKE '%Don %' AND moved_out); -- AND file_moved_out ;

DELETE FROM files_v WHERE file_id IN(SELECT file_id FROM files_ext_v WHERE directory_id in(SELECT directory_id  FROM directories_ext_v dev WHERE directory LIKE '%Don %' AND moved_in));
UPDATE files_v SET move_id = NULL, moved_to_volume_id = NULL, moved_to_directory_hash = NULL, moved_out = NULL WHERE directory_hash IN (SELECT directory_hash  FROM directories_ext_v dev WHERE directory LIKE '%Don %' AND moved_out);
DELETE FROM directories_v WHERE directory_id in(SELECT directory_id  FROM directories_ext_v dev WHERE directory LIKE '%Don %' AND moved_in);
UPDATE directories_v SET move_id = NULL, moved_to_volume_id = NULL, moved_to_directory_hash = NULL, moved_out = NULL WHERE directory LIKE '%Don %' AND moved_out;
DELETE FROM moves WHERE moves.from_directory_or_file LIKE '%Don %';


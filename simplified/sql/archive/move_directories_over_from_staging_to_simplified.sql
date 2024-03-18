SET search_path = simplified, "$user", public;
TRUNCATE TABLE simplified.directories RESTART IDENTITY CASCADE;
WITH x AS (
SELECT
      md5(REPLACE(array_to_string((string_to_array(txt, '/'))[:(howmanychar(txt, '/')+1)], '/'), '/', '\'))::bytea   AS directory_hash
    , array_to_string((string_to_array(txt, '/'))[:(howmanychar(txt, '/')+1)], '/')                                  AS path_for_hash
    , REPLACE(txt, '/', '\')                                                                                         AS directory_path                  
    , (string_to_array(txt, '/'))[(howmanychar(txt, '/')+1)]                                                         AS folder                       
    , NULL::BOOLEAN                                                                                                  AS directory_still_exists            
    , md5(REPLACE(array_to_string((string_to_array(txt, '/'))[:(howmanychar(txt, '/'))], '/'), '/', '\'))::bytea     AS parent_directory_hash             
    , (string_to_array(txt, '/'))[(howmanychar(txt, '/'))]                                                           AS parent_folder                
    , (string_to_array(txt, '/'))[(howmanychar(txt, '/')-1)]                                                         AS grandparent_folder              
    , (string_to_array(txt, '/'))[3]                                                                                 AS possibly_root_genre               
    , (string_to_array(txt, '/'))[4]                                                                                 AS possibly_sub_genre                       
    , directory_modified_on_ts_wth_tz                                                                                AS directory_date                                
    , (SELECT volume_id FROM simplified.volumes v WHERE v.drive_letter = LEFT(txt, 1))                               AS volume_id                              
    , record_changed_on_ts_wth_tz                                                                                    AS last_scanned_for_new_files 
FROM
    stage_for_master.directories d 
WHERE record_deleted IS DISTINCT FROM TRUE -- We realllly don't care about deleted stuff, NOT IN the simplified. folder.
),
roundup AS (
SELECT 
--count(*) over(), 
directory_hash,            
directory_path,           
directory_still_exists,
folder,    
parent_directory_hash,     
parent_folder          ,   
grandparent_folder      ,  
CASE WHEN LEFT(possibly_root_genre, 1) = '_' AND SUBSTRING(possibly_root_genre,2,1) SIMILAR TO '[A-Z]' THEN possibly_root_genre END root_genre,
CASE WHEN LEFT(possibly_sub_genre, 1) = '_' AND SUBSTRING(possibly_sub_genre,2,1) SIMILAR TO '[A-Z]' THEN possibly_sub_genre END sub_genre,
directory_date            ,
volume_id                 ,
NULL::BOOLEAN is_symbolic_link,
NULL::BOOLEAN is_junction_link,
NULL::TEXT linked_path,
NULL::BOOLEAN link_directory_still_exists,
NULL::TIMESTAMPTZ file_link_deleted_on, -- ???? link OR file linked TO???
NULL::BOOLEAN scan_directory,
last_scanned_for_new_files
FROM x
)
INSERT INTO simplified.directories  
SELECT * FROM roundup ORDER BY directory_hash 
;
SELECT * FROM directories d ;




 INSERT INTO
                        directories(
                            directory_hash,
                            directory_path,
                            parent_directory_hash,
                            directory_date,
                            volume_id,
                            directory_still_exists,
                            scan_directory,
                            is_symbolic_link,
                            is_junction_link,
                            linked_path
                        )
                    VALUES(
                        /*     directory_hash         */    md5(REPLACE(array_to_string((string_to_array('D:\qBittorrent Downloads\Video\TV\season 23 doctor 6 'The Trial of a Time Lord'', '/'))[:(howmanychar('D:\qBittorrent Downloads\Video\TV\season 23 doctor 6 'The Trial of a Time Lord'', '/')+1)], '/'), '/', '\'))::bytea,
                        /*     directory_path         */    REPLACE('D:\qBittorrent Downloads\Video\TV\season 23 doctor 6 'The Trial of a Time Lord'', '/', '\'),
                        /*     parent_directory_hash  */    md5(REPLACE(array_to_string((string_to_array('D:\qBittorrent Downloads\Video\TV\season 23 doctor 6 'The Trial of a Time Lord'', '/'))[:(howmanychar('D:\qBittorrent Downloads\Video\TV\season 23 doctor 6 'The Trial of a Time Lord'', '/'))], '/'), '/', '\'))::bytea,
                        /*     directory_date         */  '2023-06-03 15:33:22.411 -06:00'::TIMESTAMPTZ,
                        /*     volume_id              */   (select volume_id from volumes where drive_letter  = 'D'),
                        /*     directory_still_exists */    True,
                        /*     scan_directory         */   True,
                        /*     is_symbolic_link       */   False,
                        /*     is_junction_link       */   False,
                        /*     linked_path            */    CASE WHEN '' = '' THEN NULL ELSE '' END
                    )
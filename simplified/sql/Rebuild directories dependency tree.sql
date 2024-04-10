-- simplified.directories_ext_v source
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS simplified.directories_v CASCADE;
CREATE OR REPLACE VIEW simplified.directories_v AS 
SELECT 
    d.directory_id,
    d.directory_hash,
    d.directory_path              AS directory,
    d.folder                      AS folder,
    d.parent_directory_hash       AS parent_directory_hash,
    d.parent_folder               AS parent_folder,
    d.grandparent_folder          AS grandparent_folder,
    d.root_genre                  AS root_genre,
    d.sub_genre                   AS sub_genre,
    d.directory_date              AS directory_date,
    d.volume_id                   AS volume_id,
    d.is_symbolic_link            AS directory_is_symbolic_link ,
    d.is_junction_link            AS directory_is_junction_link,
    d.linked_path                 AS linked_directory,
    d.link_directory_still_exists AS linked_directory_still_exists,
    d.scan_directory              AS scan_directory,
    d.deleted                     AS directory_deleted,
    d.search_directory_id         AS search_directory_id,
    d.move_id,
    d.moved_in,
    d.moved_out,
    d.moved_to_directory_hash,
    d.moved_to_volume_id,
    d.moved_from_directory_hash,
    d.moved_from_volume_id,
    d.moved_from_directory_id
    
FROM simplified.directories d 
;
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS simplified.directories_ext_v CASCADE;
CREATE OR REPLACE VIEW simplified.directories_ext_v
AS WITH base AS (
         SELECT 
            d.directory_id,
            d.directory_path                                                        AS directory_path,                                                  /* SUPPORTS_OLD_STYLE */
            d.directory_path                                                        AS directory,
            REPLACE(d.directory_path::TEXT, '''', '''''')                           AS directory_escaped,
            d.directory_hash                                                        AS directory_hash,
            d.parent_directory_hash                                                 AS parent_directory_hash,
            d.directory_date                                                        AS directory_date,
            Left(d.directory_path, length(d.directory_path)-(length(d.folder)+1))   AS parent_directory,
            sd.search_directory                                                     AS search_path,                                                     /* SUPPORTS_OLD_STYLE */
            sd.search_directory                                                     AS search_directory,
            replace(sd.search_directory::TEXT, '''', '''''')                        AS escaped_search_path,                                             /* SUPPORTS_OLD_STYLE */
            replace(sd.search_directory::TEXT, '''', '''''')                        AS search_directory_escaped,
            sd.tag                                                                  AS search_path_tag,                                                 /* SUPPORTS_OLD_STYLE */
            sd.tag                                                                  AS search_directory_tag,
            d.search_directory_id                                                   AS search_path_id,                                                  /* SUPPORTS_OLD_STYLE */
            d.search_directory_id                                                   AS search_directory_id,
            COALESCE(d.deleted, false)                                              AS directory_deleted,
            COALESCE(d.is_symbolic_link, FALSE)                                     AS directory_is_symbolic_link,
            COALESCE(d.is_junction_link, FALSE)                                     AS directory_is_junction_link,
            NULLIF(d.linked_path, '')                                               AS linked_directory,
            d.folder                                                                AS folder,
            d.parent_folder                                                         AS parent_folder,
            d.grandparent_folder                                                    AS grandparent_folder,
            d.root_genre                                                            AS root_genre,
            d.volume_id                                                             AS volume_id,
            COALESCE(d.scan_directory, TRUE)                                        AS scan_directory,
            sd.skip_hash_generation                                                 AS skip_hash_generation,
    d.move_id,
    d.moved_in,
    d.moved_out,
    d.moved_to_directory_hash,
    d.moved_to_volume_id,
    d.moved_from_directory_hash,
    d.moved_from_volume_id,
    d.moved_from_directory_id

        FROM 
            directories d
        JOIN 
            search_directories sd USING (search_directory_id)
        WHERE 
            d.deleted IS DISTINCT FROM TRUE
        )
 , add_layer_1 AS (SELECT base.*,
        CASE WHEN starts_with(base.directory_path, base.search_path) THEN TRUE ELSE FALSE END                                                                    AS search_path_contained,
        CASE WHEN starts_with(base.directory_path, base.search_path) THEN "substring"(base.directory_path, length(base.search_path::text) + 2) ELSE ''::text END AS useful_part_of_directory_path /* SUPPORTS_OLD_STYLE */
   FROM base)
SELECT 
    *, 
    useful_part_of_directory_path                                                                                                                                      AS useful_part_of_directory,
    CASE WHEN useful_part_of_directory_path  = '' THEN 0 ELSE  length(useful_part_of_directory_path) - length(REPLACE(useful_part_of_directory_path, '\', '')) + 1 END AS directory_depth 
FROM 
    add_layer_1 
;
COMMENT ON VIEW simplified.directories_ext_v IS 'Directories combined volume and search path, and some common slices. "_ext" for extended. "directory_v" would just be an updateable straight single table view for rearranging column order.';
           
 -- simplified.files_ext_v source
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE VIEW simplified.files_ext_v
AS WITH base AS (SELECT 
    f.file_id                                                                                                                                                AS file_id,        
    f.file_hash                                                                                                                                              AS file_hash,      
    f.file_ntfs_id                                                                                                                                           AS file_ntfs_id,   
    d.directory_hash                                                                                                                                         AS directory_hash, 
    d.directory_id,
    f.file_name_no_ext                                                                                                                                       AS file_name_no_ext,
    f.file_name_no_ext || CASE WHEN f.final_extension <> ''::text THEN '.'::text || f.final_extension ELSE ''::TEXT END                                      AS file_name_with_ext,
    f.final_extension                                                                                                                                        AS final_extension,   
    f.file_size                                                                                                                                              AS file_size,         
    d.directory_path                                                                                                                                         AS directory_path,    
    d.directory                                                                                                                                              AS directory,         
    d.directory_escaped                                                                                                                                      AS directory_escaped, 
    ((d.directory_path || '\'::text) || f.file_name_no_ext) || CASE WHEN f.final_extension <> ''::text THEN '.'::text || f.final_extension ELSE ''::text END AS file_path,
    f.file_date                                                                                                                                              AS file_date,
    COALESCE(d.directory_deleted, false)                                                                                                                     AS directory_deleted,
    COALESCE(f.deleted, FALSE)                                                                                                                               AS file_deleted,
    f.scan_for_ntfs_id                                                                                                                                       AS scan_file_for_ntfs_id,
    d.useful_part_of_directory_path                                                                                                                          AS useful_part_of_directory_path,  
    d.useful_part_of_directory                                                                                                                               AS useful_part_of_directory,       
    d.folder                                                                                                                                                 AS folder,                         
    d.parent_folder                                                                                                                                          AS parent_folder,                  
    d.grandparent_folder                                                                                                                                     AS grandparent_folder,             
    CASE WHEN d.folder ~ '(S[0-90-9]|Season|Subs|original unprocessed audio)'::text THEN d.parent_folder
    WHEN d.folder ~ '(S[0-90-9]|Season)'::text THEN d.folder ELSE d.parent_folder END                                                                        AS folder_season_name,
    d.search_path_tag                                                                                                                                        AS search_path_tag,        
    d.search_directory_tag                                                                                                                                   AS search_directory_tag,   
    sd.directly_deletable                                                                                                                                    AS directly_deletable,
    sd.skip_hash_generation                                                                                                                                  AS skip_hash_generation,
    d.root_genre                                                                                                                                             AS root_genre,
    COALESCE(f.is_symbolic_link, FALSE)                                                                                                                      AS file_is_symbolic_link,
    COALESCE(f.is_hard_link, FALSE)                                                                                                                          AS file_is_hard_link,
    NULLIF(f.linked_path, '')                                                                                                                                AS file_linked_path,
    d.directory_is_symbolic_link                                                                                                                             AS directory_is_symbolic_link,
    d.directory_is_junction_link                                                                                                                             AS directory_is_junction_link,
    d.move_id                                                                                                                                                AS directory_move_id,
    f.move_id                                                                                                                                                AS move_id,
    f.moved_in,
    f.moved_from_file_id                                                                                                                                     AS moved_from_file_id
   FROM files f
     JOIN directories_ext_v d USING (directory_hash)
     JOIN search_directories sd USING (search_directory_id)
),
add_reduced_user_logic AS (SELECT 
    *,
    /*--------------------------------------------------- Big Helpers for consistent user SQL ---------------------------------------------------*/
    CASE WHEN 
        NOT directory_deleted  
    AND
        NOT directory_is_symbolic_link
    AND
        NOT directory_is_junction_link
    AND                      
        NOT file_deleted
    AND
        NOT file_is_symbolic_link
    AND
        NOT file_is_hard_link
    THEN TRUE ELSE FALSE END                                                                                                                                 AS is_real_file
FROM base
)
SELECT
    *
,   COUNT(*) OVER()                                                                                                                                          AS how_many_files
,   COUNT(CASE WHEN is_real_file THEN 1 END) OVER()                                                                                                          AS how_many_real_files
FROM 
    add_reduced_user_logic
;
COMMENT ON VIEW simplified.files_ext_v IS 'file info with directory detail. A lot of logic avoided re-doing everytime I want to understand what a video is.';
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- simplified.files_v source
DROP VIEW IF EXISTS simplified.files_v;
CREATE OR REPLACE VIEW simplified.files_v
AS SELECT files.file_id,
    files.file_hash,
    files.directory_hash,
    files.file_name_no_ext,
    files.final_extension,
    files.file_size,
    files.file_date,
    files.deleted          AS file_deleted,
    files.is_symbolic_link AS file_is_symbolic_link,
    files.is_hard_link     AS file_is_hard_link,
    files.broken_link      AS file_is_broken_link,
    files.linked_path,
    files.file_ntfs_id,
    files.scan_for_ntfs_id AS scan_file_for_ntfs_id,
    files.move_id,
    files.moved_out,
    files.moved_in,
    files.moved_from_file_id
   FROM files;
   SELECT count(*) FROM simplified.files_ext_v WHERE is_real_file
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
    d.directory_id                                                                                                                                           AS directory_id,
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
    COALESCE(f.scan_for_ntfs_id, FALSE)                                                                                                                      AS scan_file_for_ntfs_id,
    d.useful_part_of_directory_path                                                                                                                          AS useful_part_of_directory_path,  
    d.useful_part_of_directory                                                                                                                               AS useful_part_of_directory,       
    d.folder                                                                                                                                                 AS folder,                         
    d.parent_folder                                                                                                                                          AS parent_folder,                  
    d.grandparent_folder                                                                                                                                     AS grandparent_folder,             
    CASE WHEN d.folder ~ '(S[0-90-9]|Season|Subs|original unprocessed audio)'::text THEN d.parent_folder
    WHEN d.folder ~ '(S[0-90-9]|Season)'::text THEN d.folder ELSE d.parent_folder END                                                                        AS folder_season_name,
    d.search_path_tag                                                                                                                                        AS search_path_tag,        
    d.search_directory_tag                                                                                                                                   AS search_directory_tag,   
    COALESCE(sd.directly_deletable, FALSE)                                                                                                                   AS directly_deletable,
    COALESCE(sd.skip_hash_generation, FALSE)                                                                                                                 AS skip_hash_generation,
    d.root_genre                                                                                                                                             AS root_genre,
    COALESCE(f.is_symbolic_link, FALSE)                                                                                                                      AS file_is_symbolic_link,
    COALESCE(f.is_hard_link, FALSE)                                                                                                                          AS file_is_hard_link,
    COALESCE(f.broken_link, FALSE)                                                                                                                           AS file_is_broken_link,
    NULLIF(f.linked_path, '')                                                                                                                                AS file_linked_path,
    COALESCE(f.has_no_ads, FALSE)                                                                                                                            AS file_has_no_ads,
    d.directory_is_symbolic_link                                                                                                                             AS directory_is_symbolic_link,
    d.directory_is_junction_link                                                                                                                             AS directory_is_junction_link,
    d.move_id                                                                                                                                                AS directory_move_id,
    f.move_id                                                                                                                                                AS move_id,
    COALESCE(f.moved_in, FALSE)                                                                                                                              AS moved_in,
    COALESCE(f.moved_out, FALSE)                                                                                                                             AS moved_out,
    f.moved_from_file_id                                                                                                                                     AS moved_from_file_id,
    f.moved_to_directory_hash                                                                                                                                AS moved_to_directory_hash
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
        NOT moved_out
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
    files.deleted                              AS file_deleted,
    files.is_symbolic_link                     AS file_is_symbolic_link,
    files.is_hard_link                         AS file_is_hard_link,
    files.broken_link                          AS file_is_broken_link,
    files.linked_path,                         
    files.file_ntfs_id,                        
    files.scan_for_ntfs_id                     AS scan_file_for_ntfs_id,
    files.has_no_ads, 
    files.move_id,
    files.moved_out, 
    files.moved_in, 
    files.moved_from_volume_id, 
    files.moved_from_file_id,
    files.moved_from_directory_hash,
    files.moved_to_volume_id,
    files.moved_to_directory_hash
   FROM files;
--   SELECT count(*) FROM simplified.files_ext_v WHERE is_real_file;
--   SELECT count(*) FROM simplified.files_ext_v WHERE NOT file_has_no_ads  ;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS files_media_info_v;
CREATE OR REPLACE VIEW files_media_info_v AS
SELECT
     file_id
   ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   , general_title                                /* シン・ゴジラ　本編DISC */
   , audio_title
   , text_title
   , video_title
   , general_filenameextension
   ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   , general_encoded_date
   , general_tagged_date
   , general_file_created_date
   , general_recorded_date
   , video_tagged_date
   , video_encoded_date
   , general_released_date
   ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   , general_duration                               AS duration_in_ms
   , general_duration_string1                       AS duration_long_display
   , video_duration_string1                        /* Slightly different; no idea why */
   ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   , general_longdescription                      /* A clergyman's daughter calls Tommy and Tuppence in to investigate frightening events at a country house. A poltergeist is suspected, but the Beresfords look for a human agent. */
   , general_synopsis                           /* A germ warfare lab has had an accident and a super virulent strain named The Satan Bug may have been stolen. */
   , general_summary
   , general_wm_subtitledescription                /* When Sally sees the box of candy Linus brought for his teacher, she thinks it's for her and gives him a card; Lucy wants affection from Schroeder; Charlie waits for a card; Charlie tries to invite a girl to a dance but doesn't have her phone number. */
   /******************************************************************************************************************************************************************************************************************
    * 
    *                                                                        Video Details 
    * 
    ******************************************************************************************************************************************************************************************************************/
   , video_width
   , video_stored_width
   , video_height
   , video_stored_height
   , video_displayaspectratio
   , video_displayaspectratio_original
   , video_pixelaspectratio_original
   , general_format
   , general_video_format_list
   , video_codecid
   , general_codecid
   , general_overallbitrate_mode_string
   , general_codecid_compatible
   , general_codecid_string
   , video_codecconfigurationbox                 /* avcC */
   , video_format_profile
   , video_internetmediatype
   , general_internetmediatype
   , video_encoded_library_string
   , video_bitrate_string
   , general_overallbitrate_string
   , general_framerate_string
   , video_framerate_mode
   , video_framerate_mode_original
   , general_format_extensions
   , video_buffersize                                /* 939524096, 78124992, 65536 */
   , video_standard                                                         -- PAL, NTSC
   , video_language
   , video_source_delay
   , video_bitrate_maximum_string
   /******************************************************************************************************************************************************************************************************************
    * 
    *                                                                        Audio Details 
    * 
    ******************************************************************************************************************************************************************************************************************/
   , general_audio_codec_list
   , audio_format_commercial
   , audio_codecid
   , audio_internetmediatype                      /* audio/eac3 */
   , audio_bitrate_mode_string
   , general_audio                                /* [English][Russian], [English] */
   , audio_language
   , audio_channel_s                                AS audio_channels 
   , audio_channelpositions_string2                 AS audio_channelpositions 
   , audio_channellayout
   , audio_dsurmod                                /* 0,1,2 */
   , audio_format_settings_mode                   /* Joint stereo, Dolby Surround */
   , audio_format_settings_modeextension          /* MS Stereo, Intensity Stereo + MS Stereo */
   , audio_delay_string
   , audio_delay                                  /* 0, 9968, 16 */
   , audio_dialnorm_average                       /* -29, -31 */
   , audio_encoded_library_settings
   , audio_interleave_preload_string
   , audio_codecid_hint
   , audio_format_profile
   , audio_format_version
   /******************************************************************************************************************************************************************************************************************
    * 
    *                                                                        Subtitle Details 
    * 
    ******************************************************************************************************************************************************************************************************************/
   , general_text_format_list
   , text_default
   , text_forced
   , text_language
   /******************************************************************************************************************************************************************************************************************
    * 
    *                                                                        Miscellaneous Details 
    * 
    ******************************************************************************************************************************************************************************************************************/
   , general_encoded_application    /* HandBrake 1.4.2 2021100300, VirtualDubMod 1.5.4.1 (build 2178/release) */        
   , general_encoded_library_string /* [= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll */
   , video_encoded_library_version  /* core 163 r3059 b684ebe0 */
   ------------------------------
   , general_part_id
   , general_tvnetworkname
   , general_description
   , general_contenttype
   , general_genre
   , general_screenplayby
   , general_director
   , general_performer
   , general_track
   , general_part
   , general_season
   , general_collection
   , general_album
   , video_bitrate_mode_string
   , video_delay_string
   , text_muxingmode
   , audio_encoded_library_string
   , video_muxingmode
   , audio_dynrng_maximum
   , audio_dynrng_minimum
   , audio_dynrng_average
   , video_codecid_hint                                          /* DivX 3 Low, DivX 4, DivX 5 very low pop */
   , video_format_settings_matrix_string
   , general_istruncated
   , general_format_info
   , general_format_profile
   , general_writing_frontend
   , general_artist
   , video_format_version
   , video_scanorder_string
   , video_codecid_description
   , general_copyright
   , general_overallbitrate_maximum_string
   , general_rating
   , video_hdr_format_string
   , general_encoded_by,general_cc
   , audio_channel_s_original_string,general_chapters
   , general_subtitles
   , general_productionstudio
   , video_originalsourcemedium
   , general_wm_wmrvwatched,general_wm_wmrvseriesuid
   , general_wm_provider,general_wm_parentalrating,general_wm_mediaoriginalruntime,general_wm_mediaoriginalchannel,general_wm_mediaoriginalbroadcastdatetim,general_wm_medianetworkaffiliation,general_wm_mediaistape,general_wm_mediaissubtitled,general_wm_mediaisstereo,general_wm_mediaissport,general_wm_mediaissap,general_wm_mediaisrepeat,general_wm_mediaispremiere,general_wm_mediaismovie,general_wm_mediaislive,general_wm_mediaisfinale,general_wm_mediaisdelay,general_wm_mediacredits
FROM
    files_media_info
;
   
DROP VIEW IF EXISTS files_media_info_ext_v;
CREATE OR REPLACE VIEW files_media_info_ext_v AS
SELECT
     file_id
   , files.final_extension 
   , files.file_path
   ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   , general_title
   , audio_title
   , text_title
   , video_title
   , general_filenameextension
   ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   , general_encoded_date
   , general_tagged_date
   , general_file_created_date
   , general_recorded_date
   , video_tagged_date
   , video_encoded_date
   , general_released_date
   ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   , general_duration                               AS duration_in_ms
   , general_duration_string1                       AS duration_long_display
   , video_duration_string1                        /* Slightly different; no idea why */
   , general_longdescription
   , general_synopsis
   , general_summary
   /******************************************************************************************************************************************************************************************************************
    * 
    *                                                                        Video Details 
    * 
    ******************************************************************************************************************************************************************************************************************/
   , video_width
   , video_stored_width
   , video_height
   , video_stored_height
   , video_displayaspectratio, video_displayaspectratio_original, video_pixelaspectratio_original
   , general_format
   , general_video_format_list
   , video_codecid
   , general_codecid
   , general_overallbitrate_mode_string
   , general_codecid_compatible
   , general_codecid_string
   , video_codecconfigurationbox                 /* avcC */
   , video_format_profile
   , video_internetmediatype
   , general_internetmediatype
   , video_encoded_library_string
   , video_bitrate_string
   , general_overallbitrate_string
   , general_framerate_string
   , video_framerate_mode
   , video_framerate_mode_original
   , general_format_extensions
   , video_buffersize                                /* 939524096, 78124992, 65536 */
   , video_standard                                                         -- PAL, NTSC
   , video_language
   , video_source_delay
   , video_bitrate_maximum_string
   /******************************************************************************************************************************************************************************************************************
    * 
    *                                                                        Audio Details 
    * 
    ******************************************************************************************************************************************************************************************************************/
   , general_audio_codec_list
   , audio_format_commercial
   , audio_codecid
   , audio_internetmediatype                      /* audio/eac3 */
   , audio_bitrate_mode_string
   , general_audio                                /* [English][Russian], [English] */
   , audio_language
   , audio_channel_s                                AS audio_channels 
   , audio_channelpositions_string2                 AS audio_channelpositions 
   , audio_channellayout
   , audio_dsurmod                                /* 0,1,2 */
   , audio_format_settings_mode                   /* Joint stereo, Dolby Surround */
   , audio_format_settings_modeextension          /* MS Stereo, Intensity Stereo + MS Stereo */
   , audio_delay_string
   , audio_delay                                  /* 0, 9968, 16 */
   , audio_dialnorm_average                       /* -29, -31 */
   , audio_encoded_library_settings
   , audio_interleave_preload_string
   , audio_codecid_hint
   , audio_format_profile
   , audio_format_version
   /******************************************************************************************************************************************************************************************************************
    * 
    *                                                                        Subtitle Details 
    * 
    ******************************************************************************************************************************************************************************************************************/
   , general_text_format_list
   , text_default
   , text_forced
   , text_language
   /******************************************************************************************************************************************************************************************************************
    * 
    *                                                                        Miscellaneous Details 
    * 
    ******************************************************************************************************************************************************************************************************************/
   , general_encoded_application    /* HandBrake 1.4.2 2021100300, VirtualDubMod 1.5.4.1 (build 2178/release) */        
   , general_encoded_library_string /* [= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll! =][= DigiArty videodll */
   , video_encoded_library_version  /* core 163 r3059 b684ebe0 */
   ------------------------------
   , general_part_id
   , general_tvnetworkname
   , general_description
   , general_contenttype
   , general_genre
   , general_screenplayby
   , general_director
   , general_performer
   , general_track
   , general_part
   , general_season
   , general_collection
   , general_album
   , video_bitrate_mode_string
   , video_delay_string
   , text_muxingmode
   , audio_encoded_library_string
   , video_muxingmode
   , audio_dynrng_maximum
   , audio_dynrng_minimum
   , audio_dynrng_average
   , video_codecid_hint                                          /* DivX 3 Low, DivX 4, DivX 5 very low pop */
   , video_format_settings_matrix_string
   , general_istruncated
   , general_format_info
   , general_format_profile
   , general_writing_frontend
   , general_artist
   , video_format_version
   , video_scanorder_string
   , video_codecid_description
   , general_copyright
   , general_overallbitrate_maximum_string
   , general_rating
   , video_hdr_format_string
   , general_encoded_by,general_cc
   , audio_channel_s_original_string,general_chapters
   , general_subtitles
   , general_productionstudio
   , video_originalsourcemedium
   , general_wm_wmrvwatched,general_wm_wmrvseriesuid,general_wm_subtitledescription,general_wm_provider,general_wm_parentalrating,general_wm_mediaoriginalruntime,general_wm_mediaoriginalchannel,general_wm_mediaoriginalbroadcastdatetim,general_wm_medianetworkaffiliation,general_wm_mediaistape,general_wm_mediaissubtitled,general_wm_mediaisstereo,general_wm_mediaissport,general_wm_mediaissap,general_wm_mediaisrepeat,general_wm_mediaispremiere,general_wm_mediaismovie,general_wm_mediaislive,general_wm_mediaisfinale,general_wm_mediaisdelay,general_wm_mediacredits
FROM
    files_media_info JOIN files_ext_v files using(file_id)
;
DELETE FROM files_media_info WHERE file_id in(SELECT file_id FROM files_media_info_v WHERE duration_in_ms IS NULL AND general_video_format_list IS NULL AND general_audio_codec_list IS NULL);
DELETE FROM files_media_info WHERE file_id in(SELECT file_id FROM files_media_info_ext_v x JOIN file_extensions r ON final_extension = file_extension WHERE r.file_is_print_content  );
SELECT * FROM files_media_info_ext_v;
SELECT * FROM information_schema.COLUMNS WHERE table_name = 'files_media_info'
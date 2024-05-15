SELECT
    DISTINCT general_audio
FROM
    files_media_info_v fmiv ;

SELECT
    file_id
    , 1.0 * count(*) over() /(SELECT count(*) FROM files_media_info fmi ) * 100.0 AS percent_Pop
    --, final_extension
    --, file_path
    --, general_title
    --, audio_title
    --, text_title
    --, video_title
    , general_filenameextension
    --, general_encoded_date
    --, video_encoded_date
    --, general_tagged_date
    --, video_tagged_date
    --, general_file_created_date                  /* 4.8% populated, often just a year */
    --, general_recorded_date                      /* .33% populated :( */
    --, general_released_date
    --, duration_in_ms
    --, duration_long_display
    --, video_duration_string1
    --, general_longdescription                    /* 1.3% populated */
    --, general_synopsis                           /* 0.31% populated */
    --, general_summary                            /* 0.32% populated */
    --, general_description
    , video_width
    , video_stored_width
    , video_height
    , video_stored_height
    , video_displayaspectratio
    , video_displayaspectratio_original           /* 4.67% populated */
    , video_pixelaspectratio_original
    , general_format
    , general_video_format_list
    , video_codecid
    , video_format_profile
    , video_internetmediatype
    , video_encoded_library_string
    , video_bitrate_string
    , general_overallbitrate_string
    , general_framerate_string
    , video_framerate_mode
    , video_framerate_mode_original
    , general_format_extensions
    , video_standard
    , video_language
    , general_audio_codec_list
    , audio_format_commercial
    , audio_codecid
    , audio_bitrate_mode_string
    , general_audio
    , audio_language
    , audio_channels
    , audio_channelpositions
    , audio_channellayout
    , audio_dsurmod
    , general_text_format_list
    , text_default
    , text_forced
    , text_language
    , general_encoded_application
    , general_encoded_library_string
    , video_encoded_library_version
    , audio_delay
    , audio_dialnorm_average
    , general_part_id                         /* 21, 22, 24, s01e03 */
    , general_tvnetworkname                   /* BBC Four */
    , general_contenttype                     /* TV Show */
    , general_genre                           /* Drama, Factual */
    , general_screenplayby
    , general_director
    , general_performer
    , general_track
    , general_part
    , general_season
    , general_collection
    , general_album
    , video_buffersize
    , video_bitrate_mode_string
    , audio_delay_string
    , audio_encoded_library_settings
    , audio_interleave_preload_string
    , audio_codecid_hint
    , audio_format_settings_modeextension
    , audio_format_profile
    , audio_format_version
    , video_delay_string
    , text_muxingmode
    , audio_encoded_library_string
    , video_muxingmode
    , audio_dynrng_maximum
    , audio_dynrng_minimum
    , audio_dynrng_average
    , video_codecid_hint
    , video_format_settings_matrix_string
    , general_istruncated
    , general_format_info
    , video_codecconfigurationbox
    , video_bitrate_maximum_string
    , general_overallbitrate_mode_string
    , general_codecid_compatible
    , general_codecid_string
    , general_codecid
    , general_internetmediatype
    , general_format_profile
    , video_format_version
    , video_scanorder_string
    , general_writing_frontend
    , general_artist
    , video_codecid_description
    , general_copyright
    , general_overallbitrate_maximum_string
    , general_rating
    , video_source_delay
    , video_hdr_format_string
    , general_encoded_by
    , general_cc
    , audio_channel_s_original_string
    , general_chapters
    , general_subtitles
    , general_productionstudio
    , video_originalsourcemedium
    , general_wm_wmrvwatched
    , general_wm_wmrvseriesuid
    , general_wm_subtitledescription
    , general_wm_provider
    , general_wm_parentalrating
    , general_wm_mediaoriginalruntime
    , general_wm_mediaoriginalchannel
    , general_wm_mediaoriginalbroadcastdatetim
    , general_wm_medianetworkaffiliation
    , general_wm_mediaistape
    , general_wm_mediaissubtitled
    , general_wm_mediaisstereo
    , general_wm_mediaissport
    , general_wm_mediaissap
    , general_wm_mediaisrepeat
    , general_wm_mediaispremiere
    , general_wm_mediaismovie
    , general_wm_mediaislive
    , general_wm_mediaisfinale
    , general_wm_mediaisdelay
    , general_wm_mediacredits
    , video_originalsourcemedium                    /* 0.37% populated: DVD-Video, Blu-ray */
FROM
    files_media_info_ext_v
;
ALTER TABLE files_media_info DROP COLUMN audio_codecid_description;    
SELECT DISTINCT video_codecid, video_codecid_hint  FROM files_media_info fmi ORDER BY 1;
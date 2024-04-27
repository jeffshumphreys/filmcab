DROP VIEW IF EXISTS files_media_info_v;
CREATE VIEW files_media_info_v AS
SELECT
     file_id
   , files.final_extension 
   , general_title
   , general_filenameextension
   , general_encoded_date
   , general_file_created_date
   , general_duration                               AS duration_in_ms
   , general_duration_string1                       AS 
   , video_language
   , audio_language
   , general_audio
   , text_language
   , audio_channel_s                                AS audio_channels
   , audio_channelpositions
   , audio_channelpositions_string2
   , audio_channellayout
   , audio_dsurmod
   /*********************************** Video Details */
   , video_width
   , video_height
   , video_displayaspectratio
   , general_format
   , general_format_string
   , general_video_format_list
   , video_format
   , video_format_string
   , video_format_commercial
   , video_format_info
   , video_codecid
   , video_format_profile
   , video_internetmediatype
   , video_encoded_library_string
   , video_encoded_library_name
   , video_bitrate_string
   , general_overallbitrate_string
   , general_framerate_string
   , video_framerate_string
   , video_framerate_mode
   , video_framerate_mode_original
   , general_format_extensions
    /********************************************** Audio Details */
   , general_audio_codec_list
   , audio_format
   , audio_format_commercial
   , audio_format_string
   , audio_codecid
   , audio_format_info
   , audio_bitrate_mode_string
   /************************************************ Subtitles */
   , general_text_format_list
   , general_text_codec_list
   , text_format
   , text_format_commercial
   , text_codecid_info
   , text_default
   , text_forced
   --, video_duration_string1 
   , general_encoded_application
   , general_encoded_library_string
   , video_encoded_library_version
   , audio_delay
   , audio_dialog_normalization
   , audio_dialog_normalization_str
   , audio_dialnorm_average
FROM
    files_media_info JOIN files using(file_id)
;
SELECT DISTINCT final_extension  FROM files_media_info_v WHERE general_duration IS NULL;
SELECT *  FROM files_media_info_v;
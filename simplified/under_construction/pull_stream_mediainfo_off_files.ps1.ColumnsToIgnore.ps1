$columnsIgnore = @(
    'audio_acmod'                                <# 7 #>
,   'audio_alignment'                            <# Aligned #>
,   'audio_undo'                                 <# -001,-001,N (35448) #>
,   'audio_alignment_string'                     <# Alignment_Aligned #>
,   'audio_alternategroup'                       <# 1 #>
,   'audio_alternategroup_string'                <# 1 #>
,   'audio_bedchannelconfiguration'              <# LFE #>
,   'audio_bedchannelcount'                      <# 1 channel #>
,   'audio_bitdepth_detected'                    <# 16 #>
,   'audio_bitdepth'                             <# 16 #>
,   'audio_bitdepth_string'                      <# 16 bit #>
,   'audio_bitrate_maximum'
,   'audio_bitrate_maximum_string'               <# 160 Kbps #>
,   'audio_bitrate_minimum'
,   'audio_bitrate_minimum_string'               <# 112 Kbps #>
,   'audio_bitrate_mode'                         <# VBR #>
,   'audio_bitrate_nominal'                      <# 128000 #>
,   'audio_bitrate_nominal_string'               <# 128 Kbps #>
,   'audio_bitrate'
,   'audio_bitrate_string'
,   'audio_bsid'                                 <# 8 #>
,   'audio_channel_s_string'
,   'audio_channel_s_original'                   <# 2 #>
,   'audio_codecid_url'                          <# http #>
,   'audio_compr_average'                        <# -0.90 #>
,   'audio_compr_count'                          <# 295 #>
,   'audio_compr_maximum'                        <# 5.74 #>
,   'audio_compr_minimum'                        <# -6.30 #>
,   'audio_compr'                                <# 5.74 #>
,   'audio_compression_mode'                     <# Lossy #>
,   'audio_compression_mode_string'
,   'audio_count'
,   'audio_default'
,   'audio_default_string'
,   'audio_delay_dropframe'                      <# No (4857) #>
,   'audio_delay_source'
,   'audio_delay_source_string'
,   'audio_delay_string1'                        <# 9ms #>
,   'audio_delay_string2'                        <# 9ms #>
,   'audio_delay_string3'
,   'audio_delay_string4'
,   'audio_delay_string5'
,   'audio_dialnorm_maximum'                     <# -27 #>
,   'audio_dialnorm_minimum'                     <# -27 #>
,   'audio_dialnorm'                             <# -27 #>
,   'audio_duration_firstframe'
,   'audio_duration_firstframe_string'           <# -21ms (1661) #>
,   'audio_duration_firstframe_string1'          <# -21ms (1661) #>
,   'audio_duration_firstframe_string2'          <# -21ms (1661) #>
,   'audio_duration_firstframe_string3'          <# 00 #>
,   'audio_duration_firstframe_string4'          <# 00 #>
,   'audio_duration_firstframe_string5'          <# 00 #>
,   'audio_duration_lastframe'                   <# -21 #>
,   'audio_duration_lastframe_string'            <# -21ms #>
,   'audio_duration_lastframe_string1'           <# -21ms #>
,   'audio_duration_lastframe_string2'           <# -21ms #>
,   'audio_duration_lastframe_string3'           <# -21ms #>
,   'audio_duration_lastframe_string4'           <# -21ms #>
,   'audio_duration_lastframe_string5'           <# -21ms #>
,   'audio_duration_source'                      <# General_Duration #>
,   'audio_duration'
,   'audio_duration_string'
,   'audio_duration_string1'
,   'audio_duration_string2'
,   'audio_duration_string3'
,   'audio_duration_string4'
,   'audio_duration_string5'
,   'audio_dynrng_count'                         <# 299 #>
,   'audio_dynrng'
,   'audio_encoded_application'                  <# Lavc59.37.100 (31660) #>
,   'audio_encoded_date'
,   'audio_encoded_library_date'                 <# UTC 2007-09-17 #>
,   'audio_encoded_library'                      <# Lavc58.35.100 aac #>
,   'audio_fallback from'                        <# 3 #>
,   'audio_fallback to'                          <# 2 #>
,   'audio_fallback_from'                        <# 3 (1818) #>
,   'audio_fallback_to'                          <# 2 (1818) #>
,   'audio_firstpacketorder'                     <# 2 (1615) #>
,   'audio_forced'
,   'audio_forced_string'
,   'audio_format_additionalfeatures'
,   'audio_format_commercial_ifany'              <# Dolby Digital #>
,   'audio_format_settings_endianness'           <# Big #>
,   'audio_format_settings_floor'                <# 1 (31660) #>
,   'audio_format_settings_ps'                   <# No (Explicit) #>
,   'audio_format_settings_ps_string'
,   'audio_format_settings_sbr'
,   'audio_format_settings_sbr_string'
,   'audio_format_settings_sign'                 <# Signed (24798) #>
,   'audio_format_settings'                      <# Explicit #>
,   'audio_format_url'                           <# https #>
,   'audio_framecount'
,   'audio_framerate'
,   'audio_framerate_string'
,   'audio_fromstats_bitrate'                    <# 1508999 #>
,   'audio_fromstats_duration'                   <# 01 #>
,   'audio_fromstats_framecount'                 <# 573931 #>
,   'audio_fromstats_streamsize'                 <# 1154749172 #>
,   'audio_id'
,   'audio_id_string'
,   'audio_interleave_duration'                  <# 32 #>
,   'audio_interleave_duration_string'           <# 32 ms (0.77 video frames) #>
,   'audio_interleave_preload'                   <# 512 #>
,   'audio_interleave_videoframes'               <# 0.77 #>
,   'audio_language_string'
,   'audio_language_string1'
,   'audio_language_string2'
,   'audio_language_string3'
,   'audio_language_string4'
,   'audio_lfeon'                                <# 1 #>
,   'audio_mdhd_duration'                        <# 7568661 #>
,   'audio_menuid'                               <# 1 (22688) #>
,   'audio_menuid_string'                        <# 1 (0x1) (22688) #>
,   'audio_menus'                                <# 3 #>
,   'audio_muxingmode'                           <# DVD-Video (1615) #>
,   'audio_numberofdynamicobjects'               <# 15 #>
,   'audio_originalsourcemedium_id'              <# 189-128 #>
,   'audio_originalsourcemedium_id_string'       <# 189 (0xBD)129 (0x81) #>
,   'audio_samplesperframe'
,   'audio_samplingcount_source'                 <# General_Duration #>
,   'audio_samplingcount'
,   'audio_samplingrate'
,   'audio_samplingrate_string'
,   'audio_servicekind'                          <# CM #>
,   'audio_servicekind_string'                   <# Complete Main #>
,   'audio_source_delay_source'                  <# Container #>
,   'audio_source_delay'                         <# -21 #>
,   'audio_source_duration_lastframe'            <# -11 #>
,   'audio_source_duration_lastframe_string'     <# -11ms #>
,   'audio_source_duration'                      <# 7568683 #>
,   'audio_source_duration_string'               <# 2h 6mn #>
,   'audio_source_duration_string1'              <# 2h 6mn 8s 683ms #>
,   'audio_source_duration_string2'              <# 2h 6mn #>
,   'audio_source_duration_string3'              <# 02 #>
,   'audio_source_duration_string4'              <# 02 #>
,   'audio_source_duration_string5'              <# 02 #>
,   'audio_source_framecount'                    <# 354782 #>
,   'audio_source_streamsize_proportion'         <# 0.13555 #>
,   'audio_source_streamsize'                    <# 106266871 #>
,   'audio_source_streamsize_string'             <# 101 MiB (14%) #>
,   'audio_source_streamsize_string1'            <# 101 MiB #>
,   'audio_source_streamsize_string2'            <# 101 MiB #>
,   'audio_source_streamsize_string3'            <# 101 MiB #>
,   'audio_source_streamsize_string4'            <# 101.3 MiB #>
,   'audio_source_streamsize_string5'            <# 101 MiB (14%) #>
,   'audio_statistics_tags_issue'                <# no_variable_data 1970-01-01 00 (1947) #>
,   'audio_streamcount'
,   'audio_streamkind'
,   'audio_streamkind_string'
,   'audio_streamkindid'
,   'audio_streamkindpos'                        <# 2 #>
,   'audio_streamorder'
,   'audio_streamsize_proportion'
,   'audio_streamsize'
,   'audio_streamsize_string'
,   'audio_streamsize_string1'
,   'audio_streamsize_string2'
,   'audio_streamsize_string3'
,   'audio_streamsize_string4'
,   'audio_streamsize_string5'
,   'audio_tagged_date'
,   'audio_uniqueid'
,   'audio_video_delay'
,   'audio_video_delay_string'                   <# 9ms #>
,   'audio_video_delay_string1'                  <# 9ms #>
,   'audio_video_delay_string2'                  <# 9ms #>
,   'audio_video_delay_string3'
,   'audio_video_delay_string4'
,   'audio_video_delay_string5'
,   'general_abit'                               <# 93 (4269) #>
,   'general_applestoreaccount'                  <# holyroses@mac.com (9007) #>
,   'general_applestorecatalogid'                <# 190651 #>
,   'general_attachments'                        <# cover.jpg #>
,   'general_audio_format_list'
,   'general_audio_format_withhint_list'
,   'general_audio_language_list'
,   'general_audiocount'
,   'general_cbyt'                               <# 8749425 (4269) #>
,   'general_codecid_url'
,   'general_coff'                               <# 0.000 (4269) #>
,   'general_com_apple_quicktime_player_movie'   <# (Binary) (1571) #>
,   'general_comment'
,   'general_compilation'                        <# Yes (24395) #>
,   'general_compilation_string'                 <# Yes (24429) #>
,   'general_completename'                       <# O #>
,   'general_count'
,   'general_cover_mime'                         <# image/jpeg (30497) #>
,   'general_cover_type'                         <# Cover (front) (30497) #>
,   'general_cover'                              <# Yes #>
,   'general_covr'                               <# Unknown kind of value! (5290) #>
,   'general_cstt'                               <# 1 (4269) #>
,   'general_datasize'                           <# 783520882 #>
,   'general_delay_string1'                      <# 4h 50mn 43s 261ms (22688) #>
,   'general_delay_string2'                      <# 4h 50mn (22688) #>
,   'general_delay_string3'                      <# 04 (22688) #>
,   'general_delay_string4'                      <# 04 (22688) #>
,   'general_delay_string5'                      <# 04 (22688) #>
,   'general_duration_string'
,   'general_duration_string2'
,   'general_duration_string3'
,   'general_duration_string4'
,   'general_duration_string5'
,   'general_encoded_application_string'
,   'general_encoded_library_name'               <# AVS #>
,   'general_encoded_library'
,   'general_encoding_info'                      <# DVD > MP4 Пользовательский / MPEG2 > X264 VBR-2P 3000kbps HQ / AC3 > COPY Безопасное (27371) #>
,   'general_errordetectiontype'
,   'general_file_created_date_local'
,   'general_file_modified_date_local'
,   'general_file_modified_date'
,   'general_fileextension_invalid'              <# ac3 #>
,   'general_fileextension'
,   'general_filename'
,   'general_filesize'
,   'general_filesize_string'
,   'general_filesize_string1'
,   'general_filesize_string2'
,   'general_filesize_string3'
,   'general_filesize_string4'
,   'general_filesize_string5'
,   'general_foldername'
,   'general_wm_encodingsettings'                <# Lavf52.64.0 (34255) #>
,   'general_footersize'                         <# 55 #>
,   'general_format_commercial_ifany'            <# Dolby Digital #>
,   'general_format_commercial'
,   'general_format_settings'                    <# rec #>
,   'general_format_version'
,   'general_format_url'
,   'general_framecount'                         <# 144311 #>
,   'general_framerate'                          <# 23.976 #>
,   'general_gshh'                               <# r6---sn-jvbxjv-tihz.googlevideo.com #>
,   'general_gssd'                               <# B18E21089HM1439312628009409 #>
,   'general_gsst'                               <# 0 #>
,   'general_gstd'                               <# 2955968 #>
,   'general_hdvideo'                            <# Yes (29232) #>
,   'general_headersize'                         <# 3014087 #>
,   'general_id'                                 <# 13821 (22688) #>
,   'general_id_string'                          <# 13821 (0x35FD) (22688) #>
,   'general_image_codec_list'                   <# JPEG #>
,   'general_image_format_list'                  <# JPEG #>
,   'general_image_format_withhint_list'         <# JPEG #>
,   'general_imagecount'                         <# 1 #>
,   'general_interleaved'                        <# Yes #>
,   'general_isstreamable'                       <# Yes #>
,   'general_isvbr'                              <# 0 (29831) #>
,   'general_itunes_cddb_1'                      <# 4F100718+307927+24+150+15980+27492+42546+55217+68731+81004+95459+108433+122538+135432+145094+154979+165431+178872+194366+210882+219182+230864+237220+249095+262197+281572+295797 (5324) #>
,   'general_itunes_cddb_tracknumber'            <# 1 (5324) #>
,   'general_itunmovi'                           <#                                                           <?xml version="1.0" encoding="UTF-8"?> / <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http (5572) #>
,   'general_itunnorm'                           <# 000002E4 000002E6 0000373C 00003714 000089F5 000089F5 000076AC 000075C2 00001A39 00003F43 (25584) #>
,   'general_itunpgap'                           <# 0 (25569) #>
,   'general_itunsmpb'                           <# 00000000 00000210 0000073D 00000000049E9A33 00000000 0141C4A7 00000000 00000000 00000000 00000000 #>
,   'general_menu_codec_list'                    <# Timed Text #>
,   'general_menu_format_list'                   <# Timed Text #>
,   'general_menu_format_withhint_list'
,   'general_menu_language_list'
,   'general_menucount'
,   'general_movie_more'                         <# This video is about Masque of the Red Death (12140) #>
,   'general_movie'                              <# In.Like.Flint.1967.720p.BluRay.H264.AAC-RARBG #>
,   'general_originalsourceform_name'            <# GARR #>
,   'general_other_format_withhint_list'         <# mp4s-E2 (30418) #>
,   'general_othercount'                         <# 1 (30421) #>
,   'general_overallbitrate_maximum'             <# 233150 (31236) #>
,   'general_overallbitrate_mode'                <# VBR #>
,   'general_overallbitrate'                     <# 2150897 #>
,   'general_part_position_total'                <# 1 (24284) #>
,   'general_pbyt'                               <# 8749240 (4269) #>
,   'general_pdur'                               <# 153.889 (4269) #>
,   'general_service_name'                       <# KODEDT (KODE-DT) #>
,   'general_service_provider'                   <# KODEDT #>
,   'general_streamcount'
,   'general_streamkind'
,   'general_streamkind_string'
,   'general_streamkindid'
,   'general_streamsize_proportion'              <# 0.00383 #>
,   'general_streamsize'                         <# 3014150 #>
,   'general_streamsize_string'                  <# 2.87 MiB (0%) #>
,   'general_streamsize_string1'                 <# 3 MiB #>
,   'general_streamsize_string2'                 <# 2.9 MiB #>
,   'general_streamsize_string3'                 <# 2.87 MiB #>
,   'general_streamsize_string4'                 <# 2.875 MiB #>
,   'general_streamsize_string5'                 <# 2.87 MiB (0%) #>
,   'general_termsofuse'                         <# http (22664) #>
,   'general_text_format_withhint_list'
,   'general_textcount'                          <# 1 #>
,   'general_tim'                                <# 00;00;00;00 (14012) #>
,   'general_track_position'                     <# 05 (30493) #>
,   'general_tsc'                                <# 30000 (14012) #>
,   'general_tsz'                                <# 1001 (14012) #>
,   'general_uniqueid'
,   'general_uniqueid_string'
,   'general_vbit'                               <# 359 (4269) #>
,   'general_video_codec_list'
,   'general_video_format_withhint_list'         <# AVC #>
,   'general_video_language_list'
,   'general_videocount'
,   'general_website'                            <# [http (7524) #>
,   'general_wm_mediaclassprimaryid'             <# db9830bd-3ab3-4fab-8a371a995f7ff74 #>
,   'general_wm_mediaclasssecondaryid'           <# ba7f258a-62f7-47a9-b21f4651c42a000 #>
,   'general_wm_mediaoriginalchannelsubnumber'   <# 1 (1045) #>
,   'general_wm_mediathumbaspectratiox'          <# 16 #>
,   'general_wm_mediathumbaspectratioy'          <# 9 #>
,   'general_wm_mediathumbheight'                <# 198 #>
,   'general_wm_mediathumbratingattributes'      <# 0 #>
,   'general_wm_mediathumbratinglevel'           <# 8 #>
,   'general_wm_mediathumbratingsystem'          <# 9 #>
,   'general_wm_mediathumbret'                   <# 0 #>
,   'general_wm_mediathumbstride'                <# 1056 #>
,   'general_wm_mediathumbtimestamp'             <# 4639817462257599305 #>
,   'general_wm_mediathumbtype'                  <# 3 #>
,   'general_wm_mediathumbwidth'                 <# 352 #>
,   'general_wm_originalreleasetime'             <# 0 (538) #>
,   'general_wm_videoclosedcaptioning'           <# false #>
,   'general_wm_wmrvactualsoftpostpadding'       <# 0 #>
,   'general_wm_wmrvactualsoftprepadding'        <# 296 #>
,   'general_wm_wmrvatsccontent'                 <# true #>
,   'general_wm_wmrvbitrate'                     <# 18.153187 #>
,   'general_wm_wmrvcontentprotected'            <# false #>
,   'general_wm_wmrvcontentprotectedpercent'     <# 0 #>
,   'general_wm_wmrvdtvcontent'                  <# true #>
,   'general_wm_wmrvencodetime'                  <# 2014-02-15 01 #>
,   'general_wm_wmrvendtime'                     <# 2014-02-15 02 #>
,   'general_wm_wmrvexpirationspan'              <# 9223372036854775807 #>
,   'general_wm_wmrvhardpostpadding'             <# 0 #>
,   'general_wm_wmrvhardprepadding'              <# -300 #>
,   'general_wm_wmrvhdcontent'                   <# false #>
,   'general_wm_wmrvinbandratingattributes'      <# 0 #>
,   'general_wm_wmrvinbandratinglevel'           <# 255 #>
,   'general_wm_wmrvinbandratingsystem'          <# 255 #>
,   'general_wm_wmrvkeepuntil'                   <# -1 #>
,   'general_wm_wmrvoriginalsoftpostpadding'     <# 0 #>
,   'general_wm_wmrvoriginalsoftprepadding'      <# 300 #>
,   'general_wm_wmrvprogramid'                   <# !MCProgram!270284573 #>
,   'general_wm_wmrvquality'                     <# 0 #>
,   'general_wm_wmrvrequestid'                   <# 0 #>
,   'general_wm_wmrvscheduleitemid'              <# 0 #>
,   'general_wm_wmrvserviceid'                   <# !MCService!47377915 (538) #>
,   'general_wmfsdkneeded'                       <# 0.0.0.0000 (29831) #>
,   'image_bitdepth'                             <# 8 #>
,   'image_bitdepth_string'                      <# 8 bit #>
,   'image_chromasubsampling'                    <# 4 #>
,   'image_colorspace_icc'                       <# RGB #>
,   'image_colorspace'                           <# YUV #>
,   'image_compression_mode'                     <# Lossy #>
,   'image_compression_mode_string'              <# Lossy #>
,   'image_count'                                <# 124 #>
,   'image_format_commercial'                    <# JPEG #>
,   'image_format_compression'                   <# Deflate #>
,   'image_format_profile'                       <# 89a (25882) #>
,   'image_format'                               <# JPEG #>
,   'image_format_info'                          <# Portable Network Graphic #>
,   'image_format_string'                        <# JPEG #>
,   'image_height'                               <# 150 #>
,   'image_height_string'                        <# 150 pixel #>
,   'image_internetmediatype'                    <# image/jpeg #>
,   'image_streamcount'                          <# 1 #>
,   'image_streamkind'                           <# Image #>
,   'image_streamkind_string'                    <# Image #>
,   'image_streamkindid'                         <# 0 #>
,   'image_streamkindpos'                        <# 1 (3479) #>
,   'image_streamsize_proportion'                <# 1.00000 #>
,   'image_streamsize'                           <# 6482 #>
,   'image_streamsize_string'                    <# 6.33 KiB (100%) #>
,   'image_streamsize_string1'                   <# 6 KiB #>
,   'image_streamsize_string2'                   <# 6.3 KiB #>
,   'image_streamsize_string3'                   <# 6.33 KiB #>
,   'image_streamsize_string4'                   <# 6.330 KiB #>
,   'image_streamsize_string5'                   <# 6.33 KiB (100%) #>
,   'image_width'                                <# 150 #>
,   'image_width_string'                         <# 150 pixel #>
,   'menu_00'
,   'menu_01'
,   'menu_02'
,   'menu_03'                                    <# 01 (27126) #>
,   'menu_04'                                    <# 09 (39452) #>
,   'menu_bitrate_mode'                          <# CBR #>
,   'menu_chapters_pos_begin'
,   'menu_chapters_pos_end'
,   'menu_codecid'                               <# text #>
,   'menu_count'
,   'menu_duration_firstframe'                   <# -102000 (25664) #>
,   'menu_duration_lastframe'                    <# 7840 (25315) #>
,   'menu_duration'                              <# 5781151 #>
,   'menu_duration_string'                       <# 1h 36mn #>
,   'menu_duration_string1'                      <# 1h 36mn 21s 151ms #>
,   'menu_duration_string2'                      <# 1h 36mn #>
,   'menu_duration_string3'                      <# 01 #>
,   'menu_duration_string4'                      <# 01 #>
,   'menu_duration_string5'                      <# 01 #>
,   'menu_encoded_date'                          <# UTC 2036-02-06 06 #>
,   'menu_format_commercial'                     <# Timed Text #>
,   'menu_format'                                <# Timed Text #>
,   'menu_format_string'                         <# Timed Text #>
,   'menu_framecount'                            <# 1 (22683) #>
,   'menu_id'                                    <# 3 #>
,   'menu_id_string'                             <# 3 #>
,   'menu_language'                              <# en #>
,   'menu_language_string'                       <# en #>
,   'text_encoded_library'                       <# Lavc58.134.100 ssa #>
,   'menu_language_string1'                      <# en #>
,   'menu_language_string2'                      <# en #>
,   'menu_language_string3'                      <# eng #>
,   'general_copy_warning'                       <# Help control the pet population. Have your pets spayed or neutered. (9007) #>
,   'menu_language_string4'                      <# en #>
,   'menu_language_string5'                      <# en #>
,   'general_disc'                               <# 8 (8913) #>
,   'general_format_settings_endianness'         <# Little (17516) #>
,   'general_format_settings_mode'               <# 16 (17516) #>
,   'menu_list_audio'                            <# 0 (24275) #>
,   'menu_list_subtitles_4_3'                    <# 0 (24726) #>
,   'general_recorded_location'                  <# https (22664) #>
,   'menu_list_subtitles_letterbox'              <# 0 (24726) #>
,   'menu_list_subtitles_pan&scan'               <# 0 (24726) #>
,   'menu_list_subtitles_wide'                   <# 0 (24726) #>
,   'menu_menu_for'                              <# 1,2 (1633) #>
,   'general_hd_video'                           <# 1 (8913) #>
,   'general_media_type'                         <# 10 (8913) #>
,   'menu_source_duration'                       <# 4714669 (22683) #>
,   'menu_source_framecount'                     <# 1 (22683) #>
,   'menu_source_streamsize'                     <# 23 (22683) #>
,   'menu_streamcount'
,   'menu_streamkind'
,   'menu_streamkind_string'
,   'menu_streamkindid'
,   'menu_streamkindpos'                         <# 2 #>
,   'menu_streamorder'                           <# 2 #>
,   'menu_streamsize'                            <# 23 (22683) #>
,   'menu_tagged_date'                           <# UTC 2036-02-06 06 #>
,   'other_bitrate_mode'                         <# CBR (30418) #>
,   'other_bitrate_mode_string'                  <# CBR (30418) #>
,   'other_codecid'                              <# mp4s-E2 (30421) #>
,   'other_count'                                <# 190 (30418) #>
,   'other_duration_string1'                     <# 3s 895ms (30418) #>
,   'other_duration_string2'                     <# 3s 895ms (30418) #>
,   'other_duration_string3'                     <# 00 (30418) #>
,   'other_duration_string4'                     <# 00 (30418) #>
,   'other_duration_string5'                     <# 00 (30418) #>
,   'other_encoded_date'                         <# UTC 2010-10-07 07 (30418) #>
,   'other_format'                               <# System Core (30274) #>
,   'other_framecount'                           <# 1 (30274) #>
,   'other_id'                                   <# 1 (30418) #>
,   'other_id_string'                            <# 1 (30418) #>
,   'other_streamcount'                          <# 1 (30418) #>
,   'other_streamkind'                           <# Other (30418) #>
,   'other_streamkind_string'                    <# Other (30418) #>
,   'other_streamkindid'                         <# 0 (30418) #>
,   'other_streamkindpos'                        <# 1 (29370) #>
,   'other_streamorder'                          <# 0 (30418) #>
,   'other_tagged_date'                          <# UTC 2010-10-07 08 (30418) #>
,   'other_timecode_striped'                     <# Yes (4857) #>
,   'other_timecode_striped_string'              <# Yes (4857) #>
,   'other_title'                                <# Streaming Extension (30418) #>
,   'text_alternategroup'                        <# 3 #>
,   'text_alternategroup_string'                 <# 3 #>
,   'text_bitdepth'                              <# 2 (24275) #>
,   'text_bitdepth_string'                       <# 2 bit (24275) #>
,   'text_bitrate_encoded'                       <# 120 (4857) #>
,   'text_bitrate_encoded_string'                <# 120 bps (4857) #>
,   'text_bitrate_maximum'                       <# 4288694712 #>
,   'text_bitrate_maximum_string'                <# 4289 Mbps #>
,   'text_bitrate_mode'                          <# VBR #>
,   'text_bitrate_mode_string'                   <# VBR #>
,   'text_bitrate'                               <# 23 #>
,   'text_bitrate_string'                        <# 23 bps #>
,   'text_codecid'                               <# S_TEXT/UTF8 #>
,   'text_codecid_url'                           <# http #>
,   'text_compression_mode'                      <# Lossless #>
,   'text_compression_mode_string'               <# Lossless #>
,   'text_count'                                 <# 238 #>
,   'text_default_string'                        <# No #>
,   'text_delay_dropframe'                       <# No (4857) #>
,   'text_delay_source'                          <# Container (27804) #>
,   'text_delay_source_string'                   <# Container (24585) #>
,   'text_delay_string1'                         <# 20mn 48s 180ms (25815) #>
,   'text_delay_string2'                         <# 19mn 38s (30988) #>
,   'text_delay_string3'                         <# 00 (27806) #>
,   'text_delay_string4'                         <# 00 (27806) #>
,   'text_delay_string5'                         <# 00 (27806) #>
,   'text_duration_firstframe'                   <# 891516 (31514) #>
,   'text_duration_firstframe_string'            <# 14mn 51s (31514) #>
,   'text_duration_firstframe_string1'           <# 14mn 51s 516ms (31514) #>
,   'text_duration_firstframe_string2'           <# 14mn 51s (31514) #>
,   'text_duration_firstframe_string3'           <# 00 (31514) #>
,   'text_duration_firstframe_string4'           <# 00 (31514) #>
,   'text_duration_firstframe_string5'           <# 00 (31514) #>
,   'text_duration'                              <# 4648338.000000 #>
,   'text_duration_string'                       <# 1h 17mn #>
,   'text_duration_string1'                      <# 1h 17mn 28s 338ms #>
,   'text_duration_string2'                      <# 1h 17mn #>
,   'text_duration_string3'                      <# 01 #>
,   'text_duration_string4'                      <# 00 #>
,   'text_duration_string5'                      <# 01 #>
,   'text_elementcount'
,   'text_encoded_date'                          <# UTC 2020-02-13 09 #>
,   'text_firstpacketorder'                      <# 2 (27807) #>
,   'text_forced_string'                         <# No #>
,   'text_format_info'                           <# Run-length encoding (27806) #>
,   'text_format_string'                         <# UTF-8 #>
,   'text_format_url'                            <# http #>
,   'text_framecount'                            <# 101 #>
,   'text_framerate'                             <# 0.122 #>
,   'text_framerate_string'                      <# 0.122 fps #>
,   'text_fromstats_bitrate'                     <# 64 #>
,   'text_fromstats_duration'                    <# 01 #>
,   'text_fromstats_framecount'
,   'text_fromstats_streamsize'
,   'text_height'                                <# 576 (24156) #>
,   'text_height_string'                         <# 576 character (24156) #>
,   'text_id'                                    <# 4 #>
,   'text_id_string'                             <# 4 #>
,   'text_language_string'                       <# en #>
,   'text_language_string1'                      <# en #>
,   'text_language_string2'                      <# en #>
,   'text_language_string3'                      <# eng #>
,   'text_language_string4'                      <# en #>
,   'text_language_string5'                      <# en #>
,   'text_mdhd_duration'                         <# 7025200 #>
,   'text_menus'                                 <# 6 #>
,   'text_muxingmode_moreinfo'                   <# Muxed in Video #1 (9313) #>
,   'text_originalsourcemedium_id'               <# 189-36 #>
,   'text_originalsourcemedium_id_string'        <# 189 (0xBD)36 (0x24) #>
,   'text_source_delay_source'                   <# Container #>
,   'text_source_delay'                          <# 3680 #>
,   'text_source_duration'                       <# 7021520 #>
,   'text_source_duration_string'                <# 1h 57mn #>
,   'text_source_duration_string1'               <# 1h 57mn 1s 520ms #>
,   'text_source_duration_string2'               <# 1h 57mn #>
,   'text_source_duration_string3'               <# 01 #>
,   'text_source_framecount'                     <# 2389 #>
,   'text_source_streamsize_proportion'          <# 0.00675 #>
,   'text_source_streamsize'                     <# 17321716 #>
,   'text_source_streamsize_string'              <# 16.5 MiB (1%) #>
,   'text_source_streamsize_string1'             <# 17 MiB #>
,   'text_source_streamsize_string2'             <# 17 MiB #>
,   'text_source_streamsize_string3'             <# 16.5 MiB #>
,   'text_source_streamsize_string4'             <# 16.52 MiB #>
,   'text_source_streamsize_string5'             <# 16.5 MiB (1%) #>
,   'text_statistics_tags_issue'                 <# no_variable_data 1970-01-01 00 (1947) #>
,   'text_streamcount'                           <# 1 #>
,   'text_streamkind'                            <# Text #>
,   'text_streamkind_string'                     <# Text #>
,   'text_streamkindid'                          <# 0 #>
,   'text_streamorder'                           <# 3 #>
,   'general_part_position'                      <# 1 (5324) #>
,   'general_track_position_total'               <# 24 (5324) #>
,   'other_duration'                             <# 5658958 (4857) #>
,   'other_framerate'                            <# 24.000 (4857) #>
,   'other_framerate_string'                     <# 24.000 fps (4857) #>
,   'other_timecode_firstframe'                  <# 00 (4857) #>
,   'text_streamsize_proportion'                 <# 0.00000 #>
,   'text_streamsize'                            <# 2755 #>
,   'text_streamsize_string'                     <# 2.69 KiB (0%) #>
,   'text_streamsize_string1'                    <# 3 KiB #>
,   'text_streamsize_string2'                    <# 2.7 KiB #>
,   'text_streamsize_string3'                    <# 2.69 KiB #>
,   'text_streamsize_string4'                    <# 2.690 KiB #>
,   'text_streamsize_string5'                    <# 2.69 KiB (0%) #>
,   'text_streamsize_encoded'                    <# 84770 (4857) #>
,   'text_streamsize_encoded_string'             <# 82.8 KiB (0%) (4857) #>
,   'text_streamsize_encoded_string1'            <# 83 KiB (4857) #>
,   'text_streamsize_encoded_string2'            <# 83 KiB (4857) #>
,   'text_streamsize_encoded_string3'            <# 82.8 KiB (4857) #>
,   'text_streamsize_encoded_string4'            <# 82.78 KiB (4857) #>
,   'text_streamsize_encoded_string5'            <# 82.8 KiB (0%) (4857) #>
,   'text_streamsize_encoded_proportion'         <# 0.00000 (4857) #>
,   'text_tagged_date'                           <# UTC 2014-07-03 09 #>
,   'text_uniqueid'                              <# 9670061904096912563 #>
,   'text_video_delay_string'                    <# -560ms (30988) #>
,   'text_video_delay_string1'                   <# -560ms (30988) #>
,   'text_video_delay_string2'                   <# -560ms (30988) #>
,   'text_video_delay_string3'                   <# -00 (30988) #>
,   'text_video_delay_string4'                   <# -00 (30988) #>
,   'text_video_delay_string5'                   <# -00 (30988) #>
,   'text_width'                                 <# 720 (24156) #>
,   'text_width_string'                          <# 720 character (24156) #>
,   'video_activeformatdescription_muxingmo'     <# A/53 (16882) #>
,   'video_activeformatdescription'              <# 14 (16882) #>
,   'video_bitdepth'                             <# 8 #>
,   'video_bitdepth_string'
,   'video_bitrate_maximum'                      <# 5879072 #>
,   'video_bitrate_mode'                         <# CBR #>
,   'video_bitrate_nominal'                      <# 800000 #>
,   'video_bitrate_nominal_string'
,   'video_bitrate'                              <# 950000 #>
,   'video_bits_pixel_frame'
,   'video_chromasubsampling_position'           <# Type 0 #>
,   'video_chromasubsampling'
,   'video_chromasubsampling_string'
,   'video_codecid_url'
,   'video_colorspace'
,   'video_colour_description_present_sourc'     <# Container / Stream #>
,   'video_colour_description_present'           <# Yes #>
,   'video_colour_primaries_original_source'     <# Stream (5290) #>
,   'video_colour_primaries_original'            <# BT.709 (5290) #>
,   'video_colour_primaries_source'              <# Container / Stream #>
,   'video_colour_primaries'                     <# BT.601 PAL #>
,   'video_colour_range_source'                  <# Container / Stream #>
,   'video_colour_range'                         <# Limited #>
,   'video_compression_mode'                     <# Lossy #>
,   'video_compression_mode_string'              <# Lossy #>
,   'video_count'
,   'video_data_partitioned'                     <# No (26363) #>
,   'video_default'
,   'video_default_string'
,   'video_delay_dropframe'                      <# No (31200) #>
,   'video_delay_original_dropframe'             <# No #>
,   'video_delay_original_settings'              <# drop_frame_flag=0 / closed_gop=0 / broken_link=0 #>
,   'video_delay_original_source'                <# Stream #>
,   'video_delay_original'                       <# 3600040 #>
,   'video_delay_original_string'                <# 1h 0mn #>
,   'video_delay_original_string1'               <# 1h 0mn 0s 40ms #>
,   'video_delay_original_string2'               <# 1h 0mn #>
,   'video_delay_original_string3'               <# 01 #>
,   'video_delay_original_string4'               <# 01 #>
,   'video_delay_original_string5'               <# 01 #>
,   'video_delay_settings'                       <# DropFrame=No / 24HourMax=No / IsVisual=No (4857) #>
,   'video_delay_source'
,   'video_delay_source_string'
,   'video_delay'
,   'video_delay_string1'                        <# 44ms #>
,   'video_delay_string2'                        <# 44ms #>
,   'video_delay_string3'
,   'video_displayaspectratio_original_stri'     <# 4 #>
,   'video_displayaspectratio_original_string'   <# 4 #>
,   'video_displayaspectratio_string'
,   'video_duration_firstframe'                  <# 80 #>
,   'video_duration_firstframe_string'           <# 80ms #>
,   'video_duration_firstframe_string1'          <# 80ms #>
,   'video_duration_firstframe_string2'          <# 80ms #>
,   'video_duration_firstframe_string3'          <# 00 #>
,   'video_duration_firstframe_string4'          <# 00 #>
,   'video_duration_firstframe_string5'          <# 00 #>
,   'video_duration_lastframe'                   <# -0 (31653) #>
,   'video_duration_lastframe_string'            <# 33ms (27378) #>
,   'video_duration_lastframe_string1'           <# 33ms (27403) #>
,   'video_duration_lastframe_string2'           <# 33ms (27398) #>
,   'video_duration_lastframe_string3'           <# 00 (31653) #>
,   'audio_dialnorm_average_str'                 <# -27 dB (1613) #>
,   'audio_dialnorm_count'                       <# 300 (1613) #>
,   'audio_dynrng_average_str'                   <# 12.92 dB (1613) #>
,   'audio_dynrng_minimum_str'                   <# -22.36 dB (1613) #>
,   'audio_dynrng_maximum_str'                   <# 23.94 dB (1613) #>
,   'general_text_language_list'                 <# en (1614) #>
,   'video_duration_lastframe_string4'           <# 00 (31653) #>
,   'video_duration_lastframe_string5'           <# 00 (31653) #>
,   'video_duration_source'                      <# General_Duration #>
,   'video_duration'
,   'video_duration_string'
,   'video_duration_string2'
,   'video_duration_string3'
,   'video_duration_string4'
,   'video_duration_string5'
,   'video_encoded_library_date'                 <# UTC 2006-11-01 #>
,   'video_encoded_library_settings'
,   'video_encoded_library'
,   'video_firstpacketorder'                     <# 0 (31200) #>
,   'video_forced'
,   'video_forced_string'
,   'video_format_settings_bvop'                 <# No #>
,   'video_format_settings_bvop_string'          <# No #>
,   'video_format_settings_cabac'
,   'video_format_settings_cabac_string'
,   'video_format_settings_gmc'                  <# 0 #>
,   'video_format_settings_gmc_string'           <# 0 warppoint #>
,   'video_format_settings_gop'                  <# M=3, N=12 #>
,   'video_format_settings_matrix_data'          <# 081010141014171717171B181B181B1E1D1C1C1D1E201F1E1D1E1F2022222323232322222626272727262628282A2A28282C2D2E2D2C323636323B3E3B484854 / 1113131515151717171719191919191B1B1B1B1B1B1D1C1D1E1D1C1D1F1D1E1F1F1E1D1F2120222622202125282E2E28252D363A362D3C48483C4A5A4A64647C #>
,   'video_format_settings_matrix'               <# Default (H.263) #>
,   'video_format_settings_picturestructure'     <# Frame #>
,   'video_format_settings_qpel'                 <# No #>
,   'video_format_settings_qpel_string'          <# No #>
,   'video_format_settings_refframes'
,   'video_format_settings_refframes_string'
,   'video_format_settings'
,   'video_format_url'
,   'video_framecount_source'                    <# General_Duration #>
,   'video_framecount'
,   'video_framerate_den'
,   'video_framerate_maximum'
,   'video_framerate_maximum_string'
,   'video_framerate_minimum'
,   'video_framerate_minimum_string'
,   'video_framerate_mode_string'
,   'video_framerate_num'                        <# 24000 #>
,   'video_framerate_original_den'               <# 1000 #>
,   'video_framerate_original_num'               <# 23976 #>
,   'video_framerate_original'                   <# 23.976 #>
,   'video_framerate_original_string'            <# 23.976 (23976/1000) fps #>
,   'video_framerate'
,   'video_fromstats_bitrate'                    <# 13828542 #>
,   'video_fromstats_duration'                   <# 01 #>
,   'video_fromstats_framecount'                 <# 146779 #>
,   'video_fromstats_streamsize'                 <# 10582133436 #>
,   'video_gop_openclosed_firstframe'            <# Closed (30907) #>
,   'video_gop_openclosed_firstframe_string'     <# Closed (30907) #>
,   'video_gop_openclosed'                       <# Open #>
,   'video_gop_openclosed_string'                <# Open #>
,   'video_hdr_format_commercial'                <# HDR10 (25663) #>
,   'video_hdr_format_compatibility'             <# HDR10 (25663) #>
,   'video_hdr_format'                           <# SMPTE ST 2086 (26679) #>
,   'video_height_original'                      <# 270 (4269) #>
,   'video_height_string'
,   'video_id'
,   'video_id_string'
,   'video_intra_dc_precision'                   <# 9 #>
,   'video_language_string'
,   'video_language_string1'
,   'video_language_string2'
,   'video_language_string3'
,   'video_language_string4'
,   'video_language_string5'
,   'video_masteringdisplay_colorprimaries'      <# Display P3 (4217) #>
,   'video_masteringdisplay_luminance_sourc'     <# Stream (25663) #>
,   'video_masteringdisplay_luminance_source'    <# Stream (25663) #>
,   'video_masteringdisplay_luminance'           <# min (25663) #>
,   'video_matrix_coefficients_original_sou'     <# Stream (5290) #>
,   'video_matrix_coefficients_original_source'  <# Stream (5290) #>
,   'video_matrix_coefficients_original'         <# BT.709 (5290) #>
,   'video_matrix_coefficients_source'           <# Container / Stream #>
,   'video_matrix_coefficients'                  <# BT.601 #>
,   'video_maxcll_original_source'               <# Stream (4887) #>
,   'video_maxcll_original'                      <# 2000 cd/m2 (4887) #>
,   'video_maxcll_source'                        <# Stream (25663) #>
,   'video_maxcll'                               <# 3173 cd/m2 (25663) #>
,   'video_maxfall_original_source'              <# Stream (4887) #>
,   'video_maxfall_original'                     <# 76 cd/m2 (4887) #>
,   'video_maxfall_source'                       <# Stream (25663) #>
,   'video_maxfall'                              <# 484 cd/m2 (25663) #>
,   'video_mdhd_duration'                        <# 6114312 #>
,   'video_menuid'                               <# 1 (22688) #>
,   'video_menuid_string'                        <# 1 (0x1) (22688) #>
,   'video_menus'                                <# 3 #>
,   'video_originalsourcemedium_id'              <# 224 #>
,   'video_originalsourcemedium_id_string'       <# 224 (0xE0) #>
,   'video_pixelaspectratio'
,   'video_rotation'                             <# 0.000 #>
,   'video_sampled_height'
,   'video_sampled_width'
,   'video_scanorder'                            <# TFF #>
,   'video_scantype_storemethod'                 <# InterleavedFields #>
,   'video_scantype_storemethod_string'          <# InterleavedFields #>
,   'video_scantype'
,   'video_scantype_string'
,   'video_source_delay_source'                  <# Container (1209) #>
,   'video_source_duration'
,   'video_source_duration_string'
,   'video_source_duration_string1'
,   'video_source_duration_string2'              <# 1h 32mn #>
,   'video_source_duration_string3'              <# 01 #>
,   'video_source_duration_string4'              <# 01 #>
,   'video_source_duration_string5'              <# 01 #>
,   'video_source_framecount'                    <# 146597 #>
,   'video_source_streamsize_proportion'         <# 0.92428 #>
,   'video_source_streamsize'                    <# 631123196 #>
,   'video_source_streamsize_string'             <# 602 MiB (92%) #>
,   'video_source_streamsize_string1'            <# 602 MiB #>
,   'video_source_streamsize_string2'            <# 602 MiB #>
,   'video_source_streamsize_string3'            <# 602 MiB #>
,   'video_source_streamsize_string4'            <# 601.9 MiB #>
,   'video_source_streamsize_string5'            <# 602 MiB (92%) #>
,   'video_statistics_tags_issue'                <# no_variable_data 1970-01-01 00 #>
,   'video_streamcount'
,   'video_streamkind'
,   'video_streamkind_string'
,   'video_streamkindid'
,   'video_streamkindpos'                        <# 1 (2848) #>
,   'video_streamorder'
,   'video_streamsize_proportion'                <# 0.78674 #>
,   'video_streamsize'
,   'video_streamsize_string'
,   'video_streamsize_string1'
,   'video_streamsize_string2'
,   'video_streamsize_string3'
,   'video_streamsize_string4'
,   'video_streamsize_string5'
,   'video_timecode_firstframe'                  <# 01 #>
,   'video_timecode_source'                      <# Group of pictures header #>
,   'video_transfer_characteristics_source'      <# Container / Stream #>
,   'video_transfer_characteristics'             <# BT.709 #>
,   'video_uniqueid'
,   'video_width_string'
)

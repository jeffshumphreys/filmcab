$columnsOfInterest = @( #>
    'audio_bitrate_mode_string'
,   'audio_channel_s_original_string'            <# 2 channel #>
,   'audio_channel_s'                            <# 6/2 #>
,   'audio_channellayout_original'               <# C #>
,   'audio_channellayout'                        <# C L R Ls Rs LFE/L R #>
,   'audio_channelpositions_original'            <# Front #>
,   'audio_channelpositions'                     <# Front #>
,   'audio_channelpositions_string2'             <# 3/2/0.1 #>
,   'audio_codecid_description'                  <# Windows Media Audio 9.1 -  64 kbps, 44 kHz, stereo 1-pass CBR (31266) #>
,   'audio_codecid'                              <# A+AAC=2/A-AC3/A_AAC-2/Advanced Audio Codec Low Complexity with Spectral Band Replication #>
,   'audio_codecid_hint'                         <# MP3 #>
,   'audio_codecid_info'                         <# Windows Media Audio (31266) #>
,   'audio_complexityindex'                      <# 16 #>
,   'audio_delay'                                <# 9/0/31ms #>
,   'audio_delay_string'                         <# 9ms #>
,   'audio_dialnorm_average'                     <# -31 dB #>
,   'audio_dsurmod'                              <# 0 #>                                       # surround sound mode?
,   'audio_dynrng_average'                       <# 12.92 #>
,   'audio_dynrng_maximum'                       <# 23.94 dB #>
,   'audio_dynrng_minimum'                       <# -22.36 dB #>
,   'audio_encoded_application_string'           <# Lavc59.37.100 (25129) #>
,   'audio_encoded_library_name'                 <# libFLAC #>
,   'audio_encoded_library_settings'             <# -m j -V 4 -q 2 -lowpass 17 --abr 128 #>
,   'audio_encoded_library_version'              <# 1.2.1 #>
,   'audio_encoded_library_string'               <# LAME3.97 #>
,   'audio_format_commercial'                    <# HE-AAC #>
,   'audio_format_identifier'                    <# AC-3 (22688) #>
,   'audio_format_profile'                       <# Layer 3 #>
,   'audio_format_settings_mode'                 <# Joint stereo #>
,   'audio_format_settings_modeextension'        <# MS Stereo #>
,   'audio_format_version'                       <# Version 1 #>
,   'audio_format'                               <# AAC/AC-3 #>
,   'audio_format_info'                          <# Advanced Audio Codec Low Complexity/Advanced Video Codec #>
,   'audio_format_string'                        <# AAC LC SBR #>
,   'audio_interleave_preload_string'            <# 521 ms #>
,   'audio_internetmediatype'                    <# audio/mpeg #>
,   'audio_language'                             <# en/frjo #>
,   'audio_mp3gain_min_max'                      <# 086,191 (24616) #>
,   'audio_originalsourcemedium'                 <# DVD-Video #>
,   'audio_replaygain_gain'                      <# 1.96 (30890) #>
,   'audio_replaygain_gain_string'               <# 0.25 dB (24608) #>
,   'audio_replaygain_peak'                      <# 0.867510 (24608) #>
,   'audio_title'                                <# Hindi - NimitMak SilverRG #>
,   'general_actor'                              <# George Clooney, Natascha McElhone, Viola Davis, Jeremy Davies (31689) #>
,   'general_album_artist'                       <# Murray Gold & BBC National Orchestra of Wales (5572) #>
,   'general_album'                              <# FUNDAMENTALS_OF_MATH_DVD_1 #>
,   'general_album_performer'                    <# Rumpole episodes tunes (30492) #>
,   'general_artist'                             <# BBC One #>
,   'general_originalsourcemedium'               <# AVI file (18596) #>
,   'general_originalsourceform'                 <# Digital Video (18596) #>
,   'general_audio_codec_list'                   <# AAC LC SBR #>
,   'general_episode_sort'                       <# 2 _8913_ #>
,   'general_audio'                              <# English #>
,   'general_author'                             <# Avidemux (25269) #>
,   'general_cc'                                 <# English #>
,   'general_chapters'                           <# 24 #>
,   'general_codecid_compatible'                 <# isom/iso2/avc1/mp41 #>
,   'general_codecid_version'                    <# 2005.03 (1571) #>
,   'general_codecid'                            <# mp42 #>
,   'general_codecid_string'                     <# mp42 (isom/iso2/avc1/mp41) #>
,   'general_codirector'                         <# codirector #>
,   'general_collection'                         <# Hetty Wainthropp Investigates #>
,   'general_com_apple_quicktime_author'         <# Walt Disney (4857) #>
,   'general_com_apple_quicktime_keywords'       <# Disney,Walt Disney,4K,5.1,Surround Sound,VHS,Restoration,SOTS,Uncle Remus,Brer Rabbit,Brer Bear,Brer Fox,Harve Foster,Wilfred Jackson,James Baskett,Oscar Winner,Zip-a-dee-doo-dah,Technicolor,4 (4857) #>
,   'general_com_apple_quicktime_title'          <# Song of the South (4K Remaster) (4857) #>
,   'general_commissionedby'                     <# MIRCrew (25059) #>
,   'general_composer'                           <# BBC iPlayer #>
,   'general_contentrating'                      <# mpaa|Not Rated|0| (28324) #>
,   'general_contenttype'                        <# TV Show #>
,   'general_copyright'                          <# (C) BBC (31266) #>
,   'general_crc_error_pos'                      <# 221 #>
,   'general_date_encoded'                       <# 2016-09-01 (30922) #>
,   'general_date_recorded'                      <# 2002-11-27 (31689) #>
,   'general_date_released'                      <# 1985 (30922) #>
,   'general_publisher'                          <# E_D_ _18380_ #>
,   'general_date'                               <# 2010-10-29T07 (5572) #>
,   'general_delay'                              <# 17443261.011111 (22688) #>
,   'general_delay_string'                       <# 4h 50mn (22688) #>
,   'general_description'                        <# A desperate Hetty takes Geoffrey up and down the streets and sidewalks of town advertising the detective agency. This proves to be a wise method of business, as they pick up a client #>
,   'general_director'                           <# John Glenister #>
,   'general_duration'                           <# 2763350 #>
,   'general_duration_string1'                   <# 46mn 3s 350ms #>
,   'general_encoded_application'                <# mkvmerge v8.1.0 (''Psychedelic Postcard'') 64bit/mkvmerge v20.0.0 ('I Am The Sun') 64-bit #>
,   'general_encoded_by'                         <# Sartre (30922) #>
,   'general_encoded_date'                       <# UTC 2015-08-11 23 #>
,   'general_encoded_library_version'            <# 7.5.5 (1571) #>
,   'general_encoded_library_string'
,   'general_encodedby'                          <# Sartre (28226) #>
,   'general_episode_id'                         <# s08e02 (8913) #>
,   'general_file_created_date'                  <# UTC 2023-10-27 18 #>
,   'general_filenameextension'                  <# Fantastic Four Rise of the Silver Surfer (2007).mkv #>
,   'general_format_profile'                     <# Base Media / Version 2 #>
,   'general_format'                             <# Matroska/MPEG-4 #>
,   'general_format_extensions'                  <# braw mov mp4 m4v m4a m4b m4p m4r 3ga 3gpa 3gpp 3gp 3gpp2 3g2 k3g jpm jpx mqv ismv isma ismt f4a f4b f4v #>
,   'general_format_info'                        <# Audio Video Interleave #>
,   'general_format_string'                      <# Matroska #>
,   'general_framerate_string'                   <# 23.976 fps #>
,   'general_genre'                              <# Drama #>
,   'general_grouping'                           <# Drama,Thriller,Crime (29232) #>
,   'general_imdb'                               <# tt0089283 (30922) #>
,   'general_internetmediatype'                  <# video/vnd.avi #>
,   'general_istruncated'                        <# Yes #>
,   'general_keyword'                            <# Masque of the Red Death (12140) #>
,   'general_language'                           <# English #>
,   'general_languages'                          <# English #>
,   'general_law_rating'                         <# PG-13 (31689) #>
,   'general_lawrating'                          <# Unrated (31425) #>
,   'general_longdescription'                    <# An old friend of Hetty's - her partner in a music-hall routine years ago -- seeks her help in locating her troubled foster daughter, Chrissie. A teenage mother, Chrissie has disappeared just as a series of arson attacks on local homes have occurred --and Chrissie has a history of setting fires! As Hetty and Geoffrey look for Chrissie, a local newspaper photo competition reveals more than the photographer intended, prompting Geoff to dress in drag -- blonde wig, high heels and all -- to confront the arsonist. Hetty picks up a much-needed reward for her work in this case, and at the presentation of the check, proves that the new gumshoe hasn't lost her knack for the ol' soft-shoe! #>
,   'general_lyrics'                             <# Danish drama series set in the world of economic crime in the banks, on the stock exchanges, and in the boardrooms. It is the story of speculators, swindlers, corporate moguls and the crimes they commit in their hunt for wealth. It is the story of ambition that corrupts, and of the way organized criminals launder their ill-gotten gains. A story of our world the economic crisis almost overturned five years ago, and which is still holding its breath as it waits for the next bubble to burst and for the next economic tsunami to strike. And of course, it is the story of us human beings - the rich, the poor, the greedy, the fraudulent, the robbers who'll go to any lengths to build the lives of our dreams. /  / When the body of a man is washed ashore near a wind farm, police detective Mads is called out to investigate. At first, it merely looks like an industrial accident, but the case implicates the upper echelons of Energreen - one of Denmark's most successful and leading energy companies. The CEO of Energreen is the charismatic Sander, and young lawyer Claudia is working hard to advance in the company. Nicky, a former car thief and mechanic, works at his father-in-law's garage. He has put his life of crime behind him for his girlfriend's sake, but his new colleague Bimse tempts Nicky with a chance to make a quick buck. /  / In Danish with English subtitles. /  / EPISODE / http (29232) #>
,   'general_movie_encoder'                      <# Lavf60.5.100 #>
,   'general_named_chapters'                     <# 12 (1603) #>
,   'general_network'                            <# BBC One (8913) #>
,   'general_orig'                               <# proxy-73.dailymotion.com (4269) #>
,   'general_original_media_type'                <# Blu Ray (30922) #>
,   'general_other_codec_list'                   <# mp4s-E2 (30418) #>
,   'general_other_format_list'                  <# QuickTime TC (4857) #>
,   'general_overallbitrate_maximum_string'      <# 233 Kbps (31231) #>
,   'general_overallbitrate_mode_string'         <# VBR #>
,   'general_overallbitrate_precision_max'       <# 2165052 (22688) #>
,   'general_overallbitrate_precision_min'       <# 2164981 (22688) #>
,   'general_overallbitrate_string'              <# 456 Kbps #>
,   'general_part_id'                            <# Safe as Houses #>
,   'general_part'                               <# 5 #>
,   'general_performer'                          <# Dominic Monaghan, Patricia Routledge, Derek Benfield #>
,   'general_performer_sort'                     <# Lewis Milestone (22679) #>
,   'general_producer'                           <# James Cameron, Jon Landau, Rae Sanchini (31689) #>
,   'general_production_studio'                  <# 20th Century Fox (31689) #>
,   'general_productionstudio'                   <# studio #>
,   'general_rating'                             <# PG-13 (31689) #>
,   'general_part_of_a_set'                      <# 1/1 (Part of a set) #>
,   'general_recorded_date'                      <# 1996-01-31 #>
,   'general_released_date'                      <# 2021-02-03T20 #>
,   'general_screenplay_by'                      <# George Axelrod, Edward Anhalt, John Hopkins (30922) #>
,   'general_screenplayby'                       <# David Cook / John Bowen #>
,   'general_season_number'                      <# 8 (8913) #>
,   'general_season'                             <# 1 #>
,   'general_show'                               <# The Repair Shop (8913) #>
,   'general_subject'                            <# Village.of.the.Damned.1960.DVDRip.XviD-SAPHiRE (31716) #>
,   'general_subtitle'                           <# English #>
,   'general_subtitles'                          <# English #>
,   'general_summary'                            <# Dungeons.Dragons.The.Book.of.Vile.Darkness.2012.1080p.BluRay.x265-RARBG #>
,   'general_synopsis'                           <# Jay Blades and the team bring four treasured family heirlooms, and the memories they hold, back to life. /  / First is a poignant story of a very precious keepsake. Rose Werner and her sister Linda have travelled from Essex in the#>
,   'general_tagged_date'                        <# UTC 2036-02-06 06 #>
,   'general_text_codec_list'                    <# PGS / PGS #>
,   'general_text_format_list'                   <# PGS / PGS #>
,   'general_purchasedate'                       <# 2010-01-01T21 (PurchaseDate) #>
,   'general_title'                              <# Fantastic.Planet.1973.720p.BRRip.x0r/Jumanji Welcome to the Jungle.2017.1080p.WEB-DL.6CH.MkvCage.com/English - NimitMak SilverRG #>
,   'general_title_sort'                         <# Arch of Triumph (22679) #>
,   'general_title_more'                         <# This video is about Masque of the Red Death (Title_More) #>
,   'general_tool'                               <# Multi Group Release Encoder v34.9 (24841) #>
,   'general_track'                              <# Hetty Wainthropp Investigates - S01E05 - A High Profile #>
,   'general_track_sort'                         <# Troubled Man (18112) #>
,   'general_tvnetworkname'                      <# BBC One #>
,   'general_video_format_list'                  <# AVC #>
,   'general_wm_mediacredits'                    <# Duncan Watson/Stephen Shea/Melanie Kohn/Greg Felton/Lynn Mortensen/Linda Ercoli/Wesley Singerman/Lauren Schaffel/Corey Padnos/Emily Lalande/Jessica D. Stone/Christopher Ryan Johnson;Phil Roman/Bill Melendez;; #>
,   'general_wm_mediaisdelay'                    <# false #>
,   'general_wm_mediaisfinale'                   <# false #>
,   'general_wm_mediaislive'                     <# false #>
,   'general_wm_mediaismovie'                    <# false #>
,   'general_wm_mediaispremiere'                 <# false #>
,   'general_wm_mediaisrepeat'                   <# false #>
,   'general_wm_mediaissap'                      <# false #>
,   'general_wm_mediaissport'                    <# false #>
,   'general_wm_mediaisstereo'                   <# false #>
,   'general_wm_mediaissubtitled'                <# false #>
,   'general_wm_mediaistape'                     <# false #>
,   'general_wm_medianetworkaffiliation'         <# ABC Affiliate #>
,   'general_wm_mediaoriginalbroadcastdatetim'   <# 0001-01-01T00 (538) #>
,   'general_wm_mediaoriginalchannel'            <# 12 (538) #>
,   'general_wm_mediaoriginalruntime'            <# 35964853827 (538) #>
,   'general_wm_parentalrating'                  <# TV-G #>
,   'general_wm_provider'                        <# MediaCenterDefault #>
,   'general_wm_subtitledescription'             <# When Sally sees the box of candy Linus brought for his teacher, she thinks it's for her and gives him a card; Lucy wants affection from Schroeder; Charlie waits for a card; Charlie tries to invite a girl to a dance but doesn't have her phone number. #>
,   'general_wm_wmrvseriesuid'                   <# !GenericSeries!Be My Valentine, Charlie Brown; A Charlie Brown Valentine #>
,   'general_wm_wmrvwatched'                     <# true (1045) #>
,   'general_wmfsdkversion'                      <# 11.0.6000.6324 (29831) #>
,   'general_writing_frontend'                   <# StaxRip v2.0.2.0 (1867) #>
,   'general_written_by'                         <# Steven Soderbergh (31689) #>
,   'other_duration_string'                      <# 3s 895ms (30421) #>
,   'other_format_commercial'                    <# QuickTime TC (4857) #>
,   'other_format_string'                        <# QuickTime TC (4857) #>
,   'other_type'                                 <# Object description (29370) #>
,   'text_captionservicename'                    <# CC1 (4857) #>
,   'text_codecid_info'                          <# UTF-8 Plain Text #>
,   'text_default'                               <# No #>
,   'text_delay'                                 <# 1178180.388889 (30988) #>
,   'text_delay_string'                          <# 20mn 48s 180ms (25815) #>
,   'text_encoded_library_string'                <# Lavc58.134.100 ssa #>
,   'text_forced'                                <# No #>
,   'text_format_commercial'                     <# PGS #>
,   'text_format'                                <# PGS #>
,   'text_language'                              <# en #>
,   'text_muxingmode'                            <# zlib #>
,   'text_originalsourcemedium'                  <# DVD-Video #>
,   'text_streamkindpos'                         <# 2 #>
,   'text_title'                                 <# Production Notes #>
,   'text_video_delay'                           <# 1200 (27806) #>
,   'video_activeformatdescription_string'       <# Letterbox 16 (16882) #>
,   'video_bitrate_maximum_string'               <# 1621 Kbps #>
,   'video_bitrate_mode_string'                  <# CBR #>
,   'video_bitrate_string'                       <# 1525 Kbps/2050 Kbps #>
,   'video_buffersize'                           <# 2304000 #>
,   'video_codecconfigurationbox'                <# avcC #>
,   'video_codecid_description'                  <# Windows Media Video 9 (31266) #>
,   'video_codecid'                              <# V_MPEG4/ISO/AVC, avc1 #>
,   'video_codecid_hint'                         <# XviD #>
,   'video_codecid_info'                         <# Advanced Video Coding #>
,   'video_delay_string'                         <# 44ms #>
,   'video_displayaspectratio_original'          <# 1.333 #>
,   'video_displayaspectratio'                   <# 2.397/1.778 #>
,   'video_duration_string1'                     <# 1h 31mn 51s 298ms/1h 11mn 48s 0ms #>
,   'video_encoded_date'                         <# UTC 2036-02-06 06 #>
,   'video_encoded_library_name'                 <# x264/XviD #>
,   'video_encoded_library_version'              <# 1.1.2 #>
,   'video_encoded_library_string'               <# x264 core 146 r2538 121396c/x264 core 112/libebml v1.2.3 + libmatroska v1.3.0 #>
,   'video_format_commercial'                    <# AVC #>
,   'video_format_profile'                       <# High@L3.1/High@L4.1/Simple@L3 #>
,   'video_format_settings_matrix_string'        <# Default (H.263) #>
,   'video_format_version'                       <# Version 2 #>
,   'video_format'                               <# MPEG-4 Visual/AVC #>
,   'video_format_info'                          <# Advanced Video Codec #>
,   'video_format_string'                        <# AVC #>
,   'video_framerate_mode_original'              <# VFR #>
,   'video_framerate_mode'                       <# CFR #>
,   'video_framerate_string'                     <# 23.976 (24000/1001) fps/24.000 fps #>
,   'video_hdr_format_string'                    <# SMPTE ST 2086, HDR10 compatible (4217) #>
,   'video_height_original_string'               <# 270 pixel (4269) #>
,   'video_height'                               <# 534/796/1080 #>
,   'video_internetmediatype'                    <# video/H264, video/MP4V-ES #>
,   'video_language'                             <# en #>
,   'video_muxingmode'                           <# Header stripping #>
,   'video_originalsourcemedium'                 <# DVD-Video #>
,   'video_pixelaspectratio_original'            <# 1.000 #>
,   'video_scanorder_string'                     <# TFF #>
,   'video_source_delay'                         <# 192 (1209) #>
,   'video_standard'                             <# NTSC #>
,   'video_stored_height'                        <# 544/800 #>
,   'video_stored_width'                         <# 1920 #>
,   'video_tagged_date'                          <# UTC 2036-02-06 06 #>
,   'video_title'                                <# GalaxyRG - Fast.And.Fierce.Death.Race.2020.720p.WEBRip.800MB.x264-GalaxyRG #>
,   'video_width_original_string'
,   'video_width'                                <# 1280/1920 #>
) #>

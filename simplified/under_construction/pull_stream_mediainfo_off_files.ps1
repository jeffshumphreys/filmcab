<#
 #    FilmCab Daily morning batch run process: Get internal id of files to detect name changes that mean no actual backup.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Concept
 #    ###### Tue Jan 23 18:23:11 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #>

<#

    Container: format, profile, commercial name of the format, duration, overall bit rate, writing application and library, title, author, director, album, track number, date, duration...
    Video: format, codec id, aspect, frame rate, bit rate, color space, chroma subsampling, bit depth, scan type, scan order...
    Audio: format, codec id, sample rate, channels, bit depth, language, bit rate...
    Text: format, codec id, language of subtitle...
    Chapters: count of chapters, list of chapters...


    Container: MPEG-4, QuickTime, Matroska, AVI, MPEG-PS (including unprotected DVD), MPEG-TS (including unprotected Blu-ray), MXF, GXF, LXF, WMV, FLV, Real...
    Tags: Id3v1, Id3v2, Vorbis comments, APE tags...
    Video: MPEG-1/2 Video, H.263, MPEG-4 Visual (including DivX, XviD), H.264/AVC, H.265/HEVC, FFV1...
    Audio: MPEG Audio (including MP3), AC3, DTS, AAC, Dolby E, AES3, FLAC...
    Subtitles: CEA-608, CEA-708, DTVCC, SCTE-20, SCTE-128, ATSC/53, CDP, DVB Subtitle, Teletext, SRT, SSA, ASS, SAMI...

#>
<#
    Sections:
        other, video, general, text, audio, video, menu, image
#>

<#
    - start populating once 0 new not in ignore list and not in of interest list
    - Start populating
    - Convert count and size stuff to int2
    - fails? int4
    - which ones decimal? How many places?
    - file size is always int8
    - convert dates if possible
    - boolean?

    - populate all in interest
    - push ignores to new table: files_media_info_columns_ignored, unique values, count increment when dup values
    - identify the "#" fields into another table: files_media_???  they are what? we really only need a flag saying "en subtitles available" and if it's not "text_default=Yes"

    QUESTION: Do we want clean names or do that in the view?
    QUESTION: Do we need to bring in non labeled values
    Get definitions for these: What is video_buggersize?

    Dup columns:
        is general_tvnetworkname same as general_artist, general_copyright
        audio_format same as general_audio, audio_codecid
        general_date same as general_encoded_date general_date_encoded
        general_language same as general_languages
        general_law_rating same as general_lawrating
        general_subtitle same as general_subtitles

    Misnamed:
        general_lyrics (synompsis)
        general_artist
        general_author
        general_com.apple.quicktime.author

    Availability:
        How many have general_title at all. Do any have movie_title instead?

    Either/Or:

#>
try {
. .\_dot_include_standard_header.ps1

. .\simplified\under_construction\pull_stream_mediainfo_off_files.ps1.ColumnsOfInterest.ps1
. .\simplified\under_construction\pull_stream_mediainfo_off_files.ps1.ColumnsToIgnore.ps1

$columnsOfPossibleUse = @(
####################### Speaker mix for playback #######################

    'audio_channel_s'                            <# 6/2 #>
,   'audio_channellayout'                        <# C L R Ls Rs LFE/L R #>
,   'audio_channelpositions_string2'             <# 3/2/0.1 #>
,   'audio_format_settings_mode'                 <# Joint stereo #>

###################### Audio codec #######################

,   'audio_codecid_description'                  <# Windows Media Audio 9.1 -  64 kbps, 44 kHz, stereo 1-pass CBR (31266) #>
,   'audio_codecid'                              <# A+AAC=2/A-AC3/A_AAC-2/Advanced Audio Codec Low Complexity with Spectral Band Replication #>
,   'audio_codecid_hint'                         <# MP3 #>
,   'audio_format'                               <# AAC/AC-3 #>
,   'audio_format_info'                          <# Advanced Audio Codec Low Complexity/Advanced Video Codec #>
,   'audio_format_string'                        <# AAC LC SBR #>
,   'general_audio_codec_list'                   <# AAC LC SBR #>
,   'audio_format_identifier'                    <# AC-3 (22688) #>
,   'audio_format_profile'                       <# Layer 3 #>
,   'audio_dsurmod'                              <# 0 #>
,   'audio_internetmediatype'                    <# audio/mpeg #>
,   'general_codecid_compatible'                 <# isom/iso2/avc1/mp41 #>

###################### Video codec #######################

,   'video_encoded_library_name'                 <# x264/XviD #>
,   'video_encoded_library_version'              <# 1.1.2 #>
,   'video_format_settings_matrix_string'        <# Default (H.263) #>
,   'video_encoded_library_string'               <# x264 core 146 r2538 121396c/x264 core 112/libebml v1.2.3 + libmatroska v1.3.0 #>
,   'video_format_commercial'                    <# AVC #>
,   'video_format_string'                        <# AVC #>
,   'video_format_info'                          <# Advanced Video Codec #>
,   'video_codecconfigurationbox'                <# avcC #>
,   'video_codecid_description'                  <# Windows Media Video 9 (31266) #>
,   'video_codecid'                              <# V_MPEG4/ISO/AVC, avc1 #>
,   'video_codecid_info'                         <# Advanced Video Coding #>
,   'video_format_profile'                       <# High@L3.1/High@L4.1/Simple@L3 #>
,   'video_format_version'                       <# Version 2 #>
,   'video_format'                               <# MPEG-4 Visual/AVC #>
,   'video_framerate_mode_original'              <# VFR #>
,   'video_framerate_mode'                       <# CFR #>
,   'video_bitrate_mode_string'                  <# CBR #>
,   'video_activeformatdescription_string'       <# Letterbox 16 (16882) #>
,   'video_bitrate_maximum_string'               <# 1621 Kbps #>
,   'video_bitrate_string'                       <# 1525 Kbps/2050 Kbps #>
,   'general_format_profile'                     <# Base Media / Version 2 #>
,   'general_format'                             <# Matroska/MPEG-4 #>
,   'video_codecid_hint'                         <# XviD #>
,   'video_hdr_format_string'                    <# SMPTE ST 2086, HDR10 compatible (4217) #>
,   'video_internetmediatype'                    <# video/H264, video/MP4V-ES #>
,   'video_standard'                             <# NTSC #>

####################### Language #######################

,   'audio_language'                             <# en/frjo #>
,   'text_language'                              <# en #>
,   'video_language'                             <# en #>
,   'general_cc'                                 <# English #>              # Has subtitles?
,   'general_audio'                              <# English #>
,   'general_subtitle'                           <# English #>
,   'general_subtitles'                          <# English #>

####################### Measures #######################

,   'general_duration'                           <# 2763350 #>
,   'general_duration_string1'                   <# 46mn 3s 350ms #>
,   'video_width'                                <# 1280/1920 #>
,   'video_stored_width'                         <# 1920 #>
,   'video_height_original_string'               <# 270 pixel (4269) #>
,   'video_height'                               <# 534/796/1080 #>
,   'video_stored_height'                        <# 544/800 #>
,   'video_displayaspectratio'                   <# 2.397/1.778 #>
,   'video_displayaspectratio_original'          <# 1.333 #>

####################### Content Classification #######################

,   'general_genre'                              <# Drama #>
,   'general_grouping'                           <# Drama,Thriller,Crime (29232) #>
,   'general_released_date'                      <# 2021-02-03T20 #>
,   'general_contenttype'                        <# TV Show #>

####################### Episode Id #######################

,   'general_episode_id'                         <# s08e02 (8913) #>
,   'general_season_number'                      <# 8 (8913) #>
,   'general_season'                             <# 1 #>
,   'general_episode_sort'                       <# 2 (8913) #>
,   'general_part_of_a_set'                      <# 1/1 (Part of a set) #>

####################### Titling #######################

,   'general_filenameextension'                  <# Fantastic Four Rise of the Silver Surfer (2007).mkv #>
,   'general_com_apple_quicktime_title'          <# Song of the South (4K Remaster) (4857) #>
,   'general_title'                              <# Fantastic.Planet.1973.720p.BRRip.x0r/Jumanji Welcome to the Jungle.2017.1080p.WEB-DL.6CH.MkvCage.com/English - NimitMak SilverRG #>
,   'general_title_sort'                         <# Arch of Triumph (22679) #>
,   'general_collection'                         <# Hetty Wainthropp Investigates #>
,   'general_summary'                            <# Dungeons.Dragons.The.Book.of.Vile.Darkness.2012.1080p.BluRay.x265-RARBG #>
,   'general_track'                              <# Hetty Wainthropp Investigates - S01E05 - A High Profile #>
,   'general_track_sort'                         <# Troubled Man (18112) #>
,   'general_show'                               <# The Repair Shop (8913) #>
,   'general_subject'                            <# Village.of.the.Damned.1960.DVDRip.XviD-SAPHiRE (31716) #>
,   'general_wm_wmrvseriesuid'                   <# !GenericSeries!Be My Valentine, Charlie Brown; A Charlie Brown Valentine #>
,   'video_title'                                <# GalaxyRG - Fast.And.Fierce.Death.Race.2020.720p.WEBRip.800MB.x264-GalaxyRG #>
,   'general_part_id'                            <# Safe as Houses #>
,   'general_keyword'                            <# Masque of the Red Death (12140) #>
,   'general_title_more'                         <# This video is about Masque of the Red Death (12140) #>


####################### People #######################

,   'general_director'                           <# John Glenister #>
,   'general_codirector'                         <# codirector #>
,   'general_screenplay_by'                      <# George Axelrod, Edward Anhalt, John Hopkins (30922) #>
,   'general_screenplayby'                       <# David Cook / John Bowen #>
,   'general_written_by'                         <# Steven Soderbergh (31689) #>
,   'general_producer'                           <# James Cameron, Jon Landau, Rae Sanchini (31689) #>
,   'general_wm_mediacredits'                    <# Duncan Watson/Stephen Shea/Melanie Kohn/Greg Felton/Lynn Mortensen/Linda Ercoli/Wesley Singerman/Lauren Schaffel/Corey Padnos/Emily Lalande/Jessica D. Stone/Christopher Ryan Johnson;Phil Roman/Bill Melendez;; #>

,   'general_performer'                          <# Dominic Monaghan, Patricia Routledge, Derek Benfield #>
,   'general_performer_sort'                     <# Lewis Milestone (22679) #>
,   'general_actor'                              <# George Clooney, Natascha McElhone, Viola Davis, Jeremy Davies (31689) #>
,   'general_album_artist'                       <# Murray Gold & BBC National Orchestra of Wales (5572) #>
,   'general_album_performer'                    <# Rumpole episodes tunes (30492) #>

##################### Descriptive ####################

,   'general_description'                        <# A desperate Hetty takes Geoffrey up and down the streets and sidewalks of town advertising the detective agency. This proves to be a wise method of business, as they pick up a client #>
,   'general_longdescription'                    <# An old friend of Hetty's - her partner in a music-hall routine years ago -- seeks her help in locating her troubled foster daughter, Chrissie. A teenage mother, Chrissie has disappeared just as a series of arson attacks on local homes have occurred --and Chrissie has a history of setting fires! As Hetty and Geoffrey look for Chrissie, a local newspaper photo competition reveals more than the photographer intended, prompting Geoff to dress in drag -- blonde wig, high heels and all -- to confront the arsonist. Hetty picks up a much-needed reward for her work in this case, and at the presentation of the check, proves that the new gumshoe hasn't lost her knack for the ol' soft-shoe! #>
,   'general_lyrics'                             <# Danish drama series set in the world of economic crime in the banks, on the stock exchanges, and in the boardrooms. It is the story of speculators, swindlers, corporate moguls and the crimes they commit in their hunt for wealth. It is the story of ambition that corrupts, and of the way organized criminals launder their ill-gotten gains. A story of our world the economic crisis almost overturned five years ago, and which is still holding its breath as it waits for the next bubble to burst and for the next economic tsunami to strike. And of course, it is the story of us human beings - the rich, the poor, the greedy, the fraudulent, the robbers who'll go to any lengths to build the lives of our dreams. /  / When the body of a man is washed ashore near a wind farm, police detective Mads is called out to investigate. At first, it merely looks like an industrial accident, but the case implicates the upper echelons of Energreen - one of Denmark's most successful and leading energy companies. The CEO of Energreen is the charismatic Sander, and young lawyer Claudia is working hard to advance in the company. Nicky, a former car thief and mechanic, works at his father-in-law's garage. He has put his life of crime behind him for his girlfriend's sake, but his new colleague Bimse tempts Nicky with a chance to make a quick buck. /  / In Danish with English subtitles. /  / EPISODE / http (29232) #>
,   'general_wm_subtitledescription'             <# When Sally sees the box of candy Linus brought for his teacher, she thinks it's for her and gives him a card; Lucy wants affection from Schroeder; Charlie waits for a card; Charlie tries to invite a girl to a dance but doesn't have her phone number. #>
,   'general_synopsis'                           <# Jay Blades and the team bring four treasured family heirlooms, and the memories they hold, back to life. /  / First is a poignant story of a very precious keepsake. Rose Werner and her sister Linda have travelled from Essex in the#>
,   'general_com_apple_quicktime_keywords'       <# Disney,Walt Disney,4K,5.1,Surround Sound,VHS,Restoration,SOTS,Uncle Remus,Brer Rabbit,Brer Bear,Brer Fox,Harve Foster,Wilfred Jackson,James Baskett,Oscar Winner,Zip-a-dee-doo-dah,Technicolor,4 (4857) #>

####################### Companies #######################

,   'general_publisher'                          <# E.D. (18380) #>
,   'general_wm_medianetworkaffiliation'         <# ABC Affiliate #>
,   'general_productionstudio'                   <# studio #>
,   'general_production_studio'                  <# 20th Century Fox (31689) #>
,   'general_com_apple_quicktime_author'         <# Walt Disney (4857) #>
,   'general_tvnetworkname'                      <# BBC One #>

,   'general_wm_parentalrating'                  <# TV-G #>
,   'general_law_rating'                         <# PG-13 (31689) #>
,   'general_lawrating'                          <# Unrated (31425) #>
,   'general_rating'                             <# PG-13 (31689) #>
,   'general_contentrating'                      <# mpaa|Not Rated|0| (28324) #>

############### Sourcing ###############

,   'general_originalsourcemedium'               <# AVI file (18596) #>
,   'general_originalsourceform'                 <# Digital Video (18596) #>
,   'general_tool'                               <# Multi Group Release Encoder v34.9 (24841) #>
,   'general_orig'                               <# proxy-73.dailymotion.com (4269) #>
,   'general_original_media_type'                <# Blu Ray (30922) #>
,   'general_encodedby'                          <# Sartre (28226) #>
,   'general_author'                             <# Avidemux (25269) #>
,   'general_commissionedby'                     <# MIRCrew (25059) #>
,   'audio_originalsourcemedium'                 <# DVD-Video #>
)

$columnsOfInterest|where {$_ -in $columnsIgnore}
$columnsIgnore|Where {$_ -in $columnsOfInterest}
$columnsOfPossibleUse|Where {$_ -notin $columnsOfInterest}
$columnsOfInterest|group|where {$_.count -gt 1}
$columnsIgnore|group|where {$_.count -gt 1}
$columnsOfPossibleUse|group|where {$_.count -gt 1}

$newColumnsNotOfInterestOrIgnored = @()

$offsetSoFar = 0 #1612

$walkThruAllFilesReader = WhileReadSql "
    SELECT
        file_id
    ,   file_path
    ,   file_ntfs_id         AS in_db_file_ntfs_id
    ,   final_extension
    FROM
        files_ext_v
    WHERE
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
    --AND
    --    file_path IN(
    --        'G:\Video AllInOne Backup\_Fantasy\Fantastic Planet (1973).mkv'
    --        'O:\Video AllInOne\_Adventure\Jumanji - Welcome to the Jungle (2017).mkv'
    --        --'O:\Video AllInOne\_Super Heroes\Marvel\F4\Fantastic Four Rise of the Silver Surfer (2007).mkv'
    --    )
    AND
        final_extension NOT IN('srt', 'sub', 'idx', 'txt', 'torrent', 'nfo', 'jpg', 'rar', 'ico', 'iso', 'sup', 'cmd', 'JPG', 'epub', 'mobi', 'description', 'par2', 'doc', 'pdf', 'dll', 'IFO', 'jpeg', '', 'sfv', 'htm', 'opf', 'PAR2', 'xml', 'html', 'docx', 'parts', 'exe')
    AND
        file_id NOT IN(SELECT file_id FROM files_media_info)
    --OFFSET $offsetSoFar
"
Import-Module Get-MediaInfo
class Tag {
    [string]$tagName
    [string]$tagType
    [string[]]$tagValues
}

#Invoke-Sql "TRUNCATE TABLE files_media_info RESTART IDENTITY"
While ($null -ne $walkThruAllFilesReader.HasRows -and $walkThruAllFilesReader.Read()) {
    $anyColumnsToPopulate = 0

    # Refresh list of existing columns every loop as we may have added some.

    $existingColumns = @(Out-SqlToDataset "SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'simplified'
    AND table_name   = 'files_media_info'
    ORDER BY 1" -DontOutputToConsole -DontWriteSqlToConsole|
    Select column_name).column_name

    $howManyAddingColumns = 0
    $AddNewColumns        = "ALTER TABLE files_media_info "

    if ((Test-Path -LiteralPath $file_path)) {
        #$file_path
        $insertTagsSqlTop = @"
INSERT INTO files_media_info(
    file_id`n
"@
        $insertTagsSqlBottom = @"
)
VALUES(
    $file_id`n
"@
        #_TICK_Found_Existing_Object
        Unblock-File -LiteralPath $file_path # Remove in dumb shit "Zone.Identifier [ZoneTransfer] ZoneId=3"
        # https://github.com/stax76/MediaInfo.NET
        $mediaFileDetail = $null
        try {
            $mediaFileDetail = Get-MediaInfoSummary -Full -Raw -Path $file_path
        } catch {}
        if ($null -ne $mediaFileDetail) { # Some files, like srt and txt, return null.
            $column_name_prefix = ""
            $alreadyOccurred = @()
            foreach ($line in $mediaFileDetail) { # process and parse each line returned from MediaInfo tool.
                if (-not([string]::IsNullOrWhiteSpace($line))) { # First line is blank
                    $key_value_pair = $line -split ":"
                    $original_tag   = $key_value_pair[0].Trim()
                    $tag            = ($key_value_pair[0].Trim() -replace "[\,\.\*\(\)\\/\- ]", "_" -replace "__", "_").Trim("_")  #
                    if ($key_value_pair.Length -eq 1) {
                        $column_name_prefix = $tag.Trim() # Has a lot of trailing space that will screw up
                    } else {
                        $value        = $key_value_pair[1].Trim()
                        $targetColumn = ("$column_name_prefix`_$tag").ToLower()
                        $type = "TEXT";
                        if ($existingColumns -notcontains $targetColumn -and $targetColumn -notin $columnsIgnore) {
                            # audio_dialnorm_average appears twice, once "-31", then "-31 dB" same for others: audio_dialnorm_average
                            #if ($targetColumn -eq "audio_dialnorm_average") {
                            #    Write-AllPlaces "!";
                            #}
                            if ($targetColumn -in $alreadyOccurred) {
                                if ($targetColumn -like "audio*") {
                                    $targetColumn+= "_str"
                                }
                            }
                            # menu__00 and 01 could be added as arrays?
                            if ($targetColumn -match "menu_[0-9]{2}") { # Seen up to menu_03
                                $type = "TEXT[]"
                            }
                            if ($targetColumn -match "#[0-9]{1,}") {
                                $type = "TEXT[]"
                                $index = [regex]::Matches($targetColumn, '(#[0-9]{1,})') # What to do with this?
                                $targetColumn = $targetColumn -replace '_#[0-9]{1,}', ''
                                #TODO: Where to stuff them in the array? do text[] arrays have indexes?
                                # text, menu, audio are huge sets of foreign crap, but we'll save it.
                            }
                            # TODO: "*count", "size", "duration" can be int4 or int8. or int2
                            if ($type -eq "TEXT[]" <# -and $targetColumn -in $alreadyOccurred#>) {
                                # TODO: Add logic to build string array constant to insert into menu arrays.
                            }
                            else
                            {
                                if ($targetColumn -notin $alreadyOccurred -and $targetColumn -notin $columnsIgnore -and $targetColumn -notin $existingColumns) {
                                    if ($howManyAddingColumns -gt 0) {
                                        $AddNewColumns+= ","
                                    }
                                    $howManyAddingColumns++
                                    $AddNewColumns+= " ADD COLUMN `"$targetColumn`" $type"
                                    $alreadyOccurred+= $targetColumn
                                    #Write-AllPlaces "$targetColumn : $value"
                                }
                            }
                        }
                        # Build insert with array for menu stuff
                        # Build insert

                        if ($targetColumn -in $columnsOfInterest -and $type -eq 'TEXT' -and $targetColumn -notin $alreadyOccurred) {
                            $insertTagsSqlTop+= ",   $targetColumn`n"
                            $insertTagsSqlBottom+= ",   $(PrepForSql $value)`n"
                            $alreadyOccurred+= $targetColumn
                            $anyColumnsToPopulate++
                        }
                        if ($targetColumn -notin $columnsIgnore -and $targetColumn -notin $columnsOfInterest -and $targetColumn -notin $newColumnsNotOfInterestOrIgnored) {
                            $newColumnsNotOfInterestOrIgnored+= $targetColumn
                            Write-AllPlaces ",   $("'$targetColumn'".PadRight(40)) <# $value ($original_tag) #>"
                        }
                    }
                }
            }
            if ( $howManyAddingColumns -gt 0) {
                Invoke-Sql $AddNewColumns|Out-Null
            }
            # Execute Insert
            $insertTagsSqlBottom+= ") ON CONFLICT DO NOTHING`n"
            $insertTagsSql = $insertTagsSqlTop + $insertTagsSqlBottom
            if ($anyColumnsToPopulate -gt 0) {
                $file_id
                Invoke-Sql $insertTagsSql|Out-Null
            }
        }
    }
    $offsetSoFar++
}
}
catch {
    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}
finally {
    #Write-AllPlaces "Finally"
    . .\_dot_include_standard_footer.ps1
}
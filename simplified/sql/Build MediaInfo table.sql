DROP TABLE IF EXISTS simplified.files_media_info CASCADE;
-- https://mediaarea.net/en/MediaInfo/Support/Fields
CREATE TABLE simplified.files_media_info(
  file_id                                                          integer NOT NULL REFERENCES files(file_id) PRIMARY KEY
, "general_streamkindid"                                           INT
, "general_id"                                                     TEXT /* The identification number for this stream in this file */
, "general_originalsourcemedium_id"                                TEXT /* Identification for this stream in the original medium of the material, taken from Tag metadata */
, "general_uniqueid"                                               TEXT /* The unique ID for this stream, should be copied with stream copy */
, "general_menuid"                                                 TEXT /* The menu ID for this stream in this file */
, "general_completename"                                           TEXT /* Full path for this file (Folder+Name+Extension) */
, "general_completename_last"                                      TEXT /* Complete name (Folder+Name+Extension) of the last file (in the case of a sequence of files) */
, "general_format"                                                 TEXT /* Format used */
, "general_format_commercial_ifany"                                TEXT /* Commercial name used by vendor for these settings if there is one */
, "general_format_version"                                         TEXT /* Version for the identified format */
, "general_format_profile"                                         TEXT /* Profile of the Format */
, "general_format_level"                                           TEXT /* Level of the Format */
, "general_format_compression"                                     TEXT /* Compression method used */
, "general_format_settings"                                        TEXT /* Settings used and required by decoder */
, "general_format_additionalfeatures"                              TEXT /* Features required to fully support the file content */
, "general_internetmediatype"                                      TEXT /* Internet Media Type (aka MIME Type, Content-Type) */
, "general_codecid"                                                TEXT /* Codec ID, if defined by the container */
, "general_codecid_description"                                    TEXT /* Codec description, as defined by the container */
, "general_codecid_version"                                        TEXT /* Version of the CodecID */
, "general_codecid_compatible"                                     TEXT /* List of codecs that are compatible with the identified container */
, "general_interleaved"                                            TEXT /* If Audio and video are muxed */
, "general_filesize"                                               TEXT /* File size, in bytes */
, "general_duration"                                               TEXT /* Play time of the content, in s (ms for text output) */
, "general_duration_start"                                         TEXT /* Start time of stream, in UTC */
, "general_duration_end"                                           TEXT /* End time of stream, in UTC */
, "general_overallbitrate_mode"                                    TEXT /* Bit rate mode of all streams (CBR, VBR) */
, "general_overallbitrate"                                         TEXT /* Bit rate of all streams, in bps */
, "general_overallbitrate_minimum"                                 TEXT /* Minimum total bit rate of all streams, in bps */
, "general_overallbitrate_nominal"                                 TEXT /* Nominal bit rate of all streams, in bps */
, "general_overallbitrate_maximum"                                 TEXT /* Maximum bit rate of all streams, in bps */
, "general_framerate"                                              TEXT /* Frames per second */
, "general_framecount"                                             TEXT /* Frame count, if a stream has the same frame rate everywhere */
, "general_delay"                                                  TEXT /* Delay fixed in the stream (relative), is s (ms for text output) */
, "general_delay_settings"                                         TEXT /* Delay settings (in case of timecode, for example) */
, "general_delay_dropframe"                                        TEXT /* Delay drop frame */
, "general_delay_source"                                           TEXT /* Delay source (Container, Stream, or empty) */
, "general_streamsize"                                             TEXT /* Size of this stream, in bytes */
, "general_headersize"                                             TEXT /* Header field size, in bytes */
, "general_datasize"                                               TEXT /* Data field size, in bytes */
, "general_footersize"                                             TEXT /* Footer field size, in bytes */
, "general_isstreamable"                                           TEXT /* Set if this file is streamable or not (Yes, No) */
, "general_album_replaygain_gain"                                  TEXT /* The gain to apply to reach 89dB SPL on playback */
, "general_album_replaygain_peak"                                  TEXT /* The maximum absolute peak value of the item */
, "general_encryption"                                             TEXT /* Encryption */
, "general_encryption_format"                                      TEXT /* Encryption format */
, "general_encryption_length"                                      TEXT /* Encryption length (128, 192 or 256 bits) */
, "general_encryption_method"                                      TEXT /* Encryption method */
, "general_encryption_mode"                                        TEXT /* Encryption mode */
, "general_encryption_padding"                                     TEXT /* Encryption padding */
, "general_encryption_initializationvector"                        TEXT /* Encryption initialization vector */
, "general_universaladid_registry"                                 TEXT /* Universal Ad-ID registry */
, "general_universaladid_value"                                    TEXT /* Universal Ad-ID value */
, "general_title"                                                  TEXT /* Title of file */
, "general_title_more"                                             TEXT /* More title information */
, "general_domain"                                                 TEXT /* Universe that the file's contents belong to (e.g. Star Wars, Stargate, Buffy, Dragonball) */
, "general_collection"                                             TEXT /* Name of the series (e.g. Star Wars movies, Stargate SG-1, Angel) */
, "general_season"                                                 TEXT /* Name of the season (e.g. first Star Wars Trilogy, Season 1) */
, "general_season_position"                                        TEXT /* Number of the Season */
, "general_season_position_total"                                  TEXT /* Total number of seasons */
, "general_movie"                                                  TEXT /* Name of the movie (e.g. Star Wars: A New Hope) */
, "general_movie_more"                                             TEXT /* More information about the Movie */
, "general_movie/country"                                          TEXT /* Country where the movie was produced */
, "general_movie/url"                                              TEXT /* Homepage for the movie */
, "general_album"                                                  TEXT /* Name of the album (e.g. The Joshua Tree) */
, "general_album_more"                                             TEXT /* More information about the Album */
, "general_album/sort"                                             TEXT /* Alternate name of the album, optimized for sorting purposes (e.g. Joshua Tree, The) */
, "general_album/performer"                                        TEXT /* Album performer/artist of this file */
, "general_album/performer/sort"                                   TEXT /* Alternate name for the performer, optimized for sorting purposes (e.g. Beatles, The) */
, "general_album/performer/url"                                    TEXT /* Homepage of the album performer/artist */
, "general_comic"                                                  TEXT /* Name of the comic book series */
, "general_comic_more"                                             TEXT /* More information about the comic book series */
, "general_comic/position_total"                                   TEXT /* Total number of comics */
, "general_part"                                                   TEXT /* Name of the part (e.g. CD1, CD2) */
, "general_part/position"                                          TEXT /* Number of the part */
, "general_part/position_total"                                    TEXT /* Total number of parts */
, "general_reel"                                                   TEXT /* Name of the reel */
, "general_reel/position"                                          TEXT /* Number of the reel */
, "general_reel/position_total"                                    TEXT /* Total number of reel */
, "general_track"                                                  TEXT /* Name of the track (e.g. track 1, track 2) */
, "general_track_more"                                             TEXT /* More information about the Track */
, "general_track/url"                                              TEXT /* Link to a site about this Track */
, "general_track/sort"                                             TEXT /* Alternate name for the track, optimized for sorting purposes */
, "general_track/position"                                         TEXT /* Number of this Track */
, "general_track/position_total"                                   TEXT /* Total number of tracks */
, "general_packagename"                                            TEXT /* MXF package name */
, "general_grouping"                                               TEXT /* iTunes grouping */
, "general_chapter"                                                TEXT /* Name of the Chapter */
, "general_subtrack"                                               TEXT /* Name of the Subtrack */
, "general_original/album"                                         TEXT /* Original name of the Album */
, "general_original/movie"                                         TEXT /* Original name of the Movie */
, "general_original/part"                                          TEXT /* Original name of the Part */
, "general_original/track"                                         TEXT /* Original name of the Track */
, "general_compilation"                                            TEXT /* iTunes compilation */
, "general_performer"                                              TEXT /* Main performer(s)/artist(s) */
, "general_performer/sort"                                         TEXT /* Alternate name for the performer, optimized for sorting purposes (e.g. Beatles, The) */
, "general_performer/url"                                          TEXT /* Homepage of the performer/artist */
, "general_original/performer"                                     TEXT /* Original artist(s)/performer(s) */
, "general_accompaniment"                                          TEXT /* Band/orchestra/accompaniment/musician */
, "general_composer"                                               TEXT /* Name of the original composer */
, "general_composer/nationality"                                   TEXT /* Nationality of the primary composer of the piece */
, "general_composer/sort"                                          TEXT /* Nationality of the primary composer of the piece (e.g. Mozart, Wolfgang Amadeus) */
, "general_arranger"                                               TEXT /* The person who arranged the piece (e.g. Ravel) */
, "general_lyricist"                                               TEXT /* The person who wrote the lyrics for the piece */
, "general_original/lyricist"                                      TEXT /* Original lyricist(s)/text writer(s) */
, "general_conductor"                                              TEXT /* The artist(s) who performed the work. In classical music this would be the conductor, orchestra, soloists, etc */
, "general_director"                                               TEXT /* Name of the director */
, "general_codirector"                                             TEXT /* Name of the codirector */
, "general_assistantdirector"                                      TEXT /* Name of the assistant director */
, "general_directorofphotography"                                  TEXT /* Name of the director of photography, also known as cinematographer */
, "general_soundengineer"                                          TEXT /* Name of the sound engineer or sound recordist */
, "general_artdirector"                                            TEXT /* Name of the person who oversees the artists and craftspeople who build the sets */
, "general_productiondesigner"                                     TEXT /* Name of the person responsible for designing the overall visual appearance of a movie */
, "general_choreographer"                                          TEXT /* Name of the choreographer */
, "general_costumedesigner"                                        TEXT /* Name of the costume designer */
, "general_actor"                                                  TEXT /* Real name of an actor/actress playing a role in the movie */
, "general_actor_character"                                        TEXT /* Name of the character an actor or actress plays in this movie */
, "general_writtenby"                                              TEXT /* Author of the story or script */
, "general_screenplayby"                                           TEXT /* Author of the screenplay or scenario (used for movies and TV shows) */
, "general_editedby"                                               TEXT /* Editors name */
, "general_commissionedby"                                         TEXT /* Name of the person or organization that commissioned the subject of the file */
, "general_producer"                                               TEXT /* Name of the producer of the media */
, "general_coproducer"                                             TEXT /* Name of a co-producer of the media */
, "general_executiveproducer"                                      TEXT /* Name of an executive producer of the media */
, "general_musicby"                                                TEXT /* Main musical artist for the media */
, "general_distributedby"                                          TEXT /* Company responsible for distribution of the content */
, "general_originalsourceform/distributedby"                       TEXT /* Name of the person or organization who supplied the original subject */
, "general_masteredby"                                             TEXT /* The engineer who mastered the content for a physical medium or for digital distribution */
, "general_encodedby"                                              TEXT /* Name of the person/organisation that encoded/ripped the audio file */
, "general_remixedby"                                              TEXT /* Name of the artist(s) that interpreted, remixed, or otherwise modified the content */
, "general_productionstudio"                                       TEXT /* Main production studio of the media */
, "general_thanksto"                                               TEXT /* A very general metadata tag for everyone else that wants to be listed */
, "general_publisher"                                              TEXT /* Name of the organization publishing the media (i.e. the record label) */
, "general_publisher/url"                                          TEXT /* Publisher's official webpage */
, "general_label"                                                  TEXT /* Brand or trademark associated with the marketing of music recordings and music videos */
, "general_genre"                                                  TEXT /* Main genre of the media (e.g. classical, ambient-house, synthpop, sci-fi, drama, etc.) */
, "general_podcastcategory"                                        TEXT /* Podcast category */
, "general_mood"                                                   TEXT /* Intended to reflect the mood of the item with a few keywords (e.g. Romantic, Sad, Uplifting, etc.) */
, "general_contenttype"                                            TEXT /* The type or genre of the content (e.g. Documentary, Feature Film, Cartoon, Music Video, Music, Sound FX, etc.) */
, "general_subject"                                                TEXT /* Describes the topic of the file (e.g. Aerial view of Seattle.) */
, "general_description"                                            TEXT /* A short description of the contents (e.g. Two birds flying.) */
, "general_keywords"                                               TEXT /* Keywords for the content separated by a comma, used for searching */
, "general_summary"                                                TEXT /* Plot outline or a summary of the story */
, "general_synopsis"                                               TEXT /* Description of the story line of the item */
, "general_period"                                                 TEXT /* Describes the period that the piece is from or about (e.g. Renaissance) */
, "general_lawrating"                                              TEXT /* Legal rating of a movie. Format depends on country of origin (e.g. PG, 16) */
, "general_lawrating_reason"                                       TEXT /* Reason for the law rating */
, "general_icra"                                                   TEXT /* The ICRA rating (previously RSACi) */
, "general_released_date"                                          TEXT /* Date/year that the content was released */
, "general_original/released_date"                                 TEXT /* Date/year that the content was originally released */
, "general_recorded_date"                                          TEXT /* Time/date/year that the recording began */
, "general_encoded_date"                                           TEXT /* Time/date/year that the encoding of this content was completed */
, "general_tagged_date"                                            TEXT /* Time/date/year that the tags were added to this content */
, "general_written_date"                                           TEXT /* Time/date/year that the composition of the music/script began */
, "general_mastered_date"                                          TEXT /* Time/date/year that the content was digitally mastered */
, "general_file_created_date"                                      TEXT /* Time that the file was created on the file system */
, "general_file_created_date_local"                                TEXT /* Local time that the file was created on the file system (not to be used in an international database) */
, "general_recorded_location"                                      TEXT /* Location where track was recorded, as Longitude+Latitude */
, "general_written_location"                                       TEXT /* Location that the item was originally designed/written */
, "general_archival_location"                                      TEXT /* Location where an item is archived (e.g. Louvre, Paris, France) */
, "general_encoded_application"                                    TEXT /* Name of the software package used to create the file (e.g. Microsoft WaveEdiTY) */
, "general_encoded_application_companyname"                        TEXT /* Name of the company of the encoding application */
, "general_encoded_application_name"                               TEXT /* Name of the encoding product */
, "general_encoded_application_version"                            TEXT /* Version of the encoding product */
, "general_encoded_application_url"                                TEXT /* URL associated with the encoding software */
, "general_encoded_library"                                        TEXT /* Software used to create the file */
, "general_encoded_library_companyname"                            TEXT /* Name of the encoding software company */
, "general_encoded_library_name"                                   TEXT /* Name of the encoding software */
, "general_encoded_library_version"                                TEXT /* Version of the encoding software */
, "general_encoded_library_date"                                   TEXT /* Release date of the encoding software, in UTC */
, "general_encoded_library_settings"                               TEXT /* Parameters used by the encoding software */
, "general_encoded_operatingsystem"                                TEXT /* Operating System of the encoding software */
, "general_cropped"                                                TEXT /* Describes whether an image has been cropped and, if so, how it was cropped */
, "general_dimensions"                                             TEXT /* Specifies the size of the original subject of the file (e.g. 8.5 in h, 11 in w) */
, "general_dotsperinch"                                            TEXT /* Stores dots per inch setting of the digitization mechanism used to produce the file */
, "general_lightness"                                              TEXT /* Describes the changes in lightness settings on the digitization mechanism made during the production of the file */
, "general_originalsourcemedium"                                   TEXT /* Original medium of the material (e.g. vinyl, Audio-CD, Super8 or BetaMax) */
, "general_originalsourceform"                                     TEXT /* Original form of the material (e.g. slide, paper, map) */
, "general_originalsourceform/numcolors"                           TEXT /* Number of colors requested when digitizing (e.g. 256 for images or 32 bit RGB for video) */
, "general_originalsourceform/name"                                TEXT /* Name of the product the file was originally intended for */
, "general_originalsourceform/cropped"                             TEXT /* Describes whether the original image has been cropped and, if so, how it was cropped (e.g. 16:9 to 4:3, top and bottom) */
, "general_originalsourceform/sharpness"                           TEXT /* Identifies changes in sharpness the digitization mechanism made during the production of the file */
, "general_tagged_application"                                     TEXT /* Software used to tag the file */
, "general_bpm"                                                    TEXT /* Average number of beats per minute */
, "general_isrc"                                                   TEXT /* International Standard Recording Code, excluding the ISRC prefix and including hyphens */
, "general_isbn"                                                   TEXT /* International Standard Book Number */
, "general_isan"                                                   TEXT /* International Standard Audiovisual Number */
, "general_barcode"                                                TEXT /* EAN-13 (13-digit European Article Numbering) or UPC-A (12-digit Universal Product Code) bar code identifier */
, "general_lccn"                                                   TEXT /* Library of Congress Control Number */
, "general_umid"                                                   TEXT /* Universal Media Identifier */
, "general_catalognumber"                                          TEXT /* A label-specific catalogue number used to identify the release (e.g. TIC 01) */
, "general_labelcode"                                              TEXT /* Label code (e.g. 12345, meaning LC-12345) */
, "general_owner"                                                  TEXT /* Owner of the file */
, "general_copyright"                                              TEXT /* Copyright attribution */
, "general_copyright/url"                                          TEXT /* Link to a site with copyright/legal information */
, "general_producer_copyright"                                     TEXT /* Copyright information as per the production copyright holder */
, "general_termsofuse"                                             TEXT /* License information (e.g. All Rights Reserved, Any Use Permitted) */
, "general_servicename"                                            TEXT /* Name of assisted service */
, "general_servicechannel"                                         TEXT /* Channel of assisted service */
, "general_service/url"                                            TEXT /* URL of of assisted service */
, "general_serviceprovider"                                        TEXT /* Provider of assisted service */
, "general_serviceprovider/url"                                    TEXT /* URL of provider of assisted service */
, "general_servicetype"                                            TEXT /* Type of assisted service */
, "general_networkname"                                            TEXT /* Television network name */
, "general_originalnetworkname"                                    TEXT /* Television network name of original broadcast */
, "general_country"                                                TEXT /* Country information of the content */
, "general_timezone"                                               TEXT /* Time zone information of the content */
, "general_cover"                                                  TEXT /* Is there a cover? Result will be Yes if present, empty if not */
, "general_cover_description"                                      TEXT /* Short description of cover image file (e.g. Earth in space) */
, "general_cover_type"                                             TEXT /* Cover type (e.g. Cover (front)) */
, "general_cover_mime"                                             TEXT /* MIME type of cover file (e.g. image/png) */
, "general_cover_data"                                             TEXT /* Cover, in binary format, encoded as Base64 */
, "general_lyrics"                                                 TEXT /* Text of a song */
, "general_comment"                                                TEXT /* Any comment related to the content */
, "general_rating"                                                 TEXT /* A numeric value defining how much a person likes the song/movie, 1 to 5 (e.g. 2, 5.0) */
, "general_added_date"                                             TEXT /* Date/year the item was added to the owners collection */
, "general_played_first_date"                                      TEXT /* Date the owner first played an item */
, "general_played_last_date"                                       TEXT /* Date the owner last played an item */
, "general_played_count"                                           TEXT /* Number of times an item was played */
, "general_epg_positions_begin"                                    TEXT /* Beginning position for Electronic Program Guide */
, "general_epg_positions_end"                                      TEXT /* Ending position for Electronic Program Guide */
, "video_streamorder"                                              TEXT /* Stream order in the file for type of stream. Counting starts at 0 */
, "video_id"                                                       TEXT /* The identification number for this stream in this file */
, "video_originalsourcemedium_id"                                  TEXT /* Identification for this stream in the original medium of the material */
, "video_uniqueid"                                                 TEXT /* The unique ID for this stream, should be copied with stream copy */
, "video_menuid"                                                   TEXT /* The menu ID for this stream in this file */
, "video_format"                                                   TEXT /* Format used */
, "video_format_commercial_ifany"                                  TEXT /* Commercial name used by vendor for these settings, if available */
, "video_format_version"                                           TEXT /* Version for the identified format */
, "video_format_profile"                                           TEXT /* Profile of the Format */
, "video_format_level"                                             TEXT /* Level of the Format */
, "video_format_tier"                                              TEXT /* Tier of the Format */
, "video_format_compression"                                       TEXT /* Compression method used */
, "video_format_additionalfeatures"                                TEXT /* Features from the format that are required to fully support the file content */
, "video_multiview_baseprofile"                                    TEXT /* Profile of the base stream for Multiview Video Coding */
, "video_multiview_count"                                          TEXT /* View count for Multiview Video Coding */
, "video_multiview_layout"                                         TEXT /* How views are muxed in the container for Multiview Video Coding */
, "video_hdr_format"                                               TEXT /* High Dynamic Range Format used */
, "video_hdr_format_commercial"                                    TEXT /* Commercial name used by vendor for these HDR settings or HDR Format field if there is no difference */
, "video_hdr_format_version"                                       TEXT /* Version of HDR Format */
, "video_hdr_format_profile"                                       TEXT /* Profile of HDR Format */
, "video_hdr_format_level"                                         TEXT /* Level of HDR Format */
, "video_hdr_format_settings"                                      TEXT /* HDR Format settings */
, "video_hdr_format_compatibility"                                 TEXT /* HDR Format compatibility with commercial products (e.g. HDR10) */
, "video_format_settings_bvop"                                     TEXT /* Whether BVOP settings are required for decoding MPEG (Yes, No) */
, "video_format_settings_qpel"                                     TEXT /* Whether Quarter-pixel motion settings are required for decoding MPEG (Yes, No) */
, "video_format_settings_gmc"                                      TEXT /* Whether Global Motion Compensation settings are required for decoding MPEG (Yes, No) */
, "video_format_settings_matrix"                                   TEXT /* Whether Matrix settings are required for decoding MPEG (Yes, No) */
, "video_format_settings_cabac"                                    TEXT /* Whether CABAC support is required for decoding MPEG (Yes, No) */
, "video_format_settings_refframes"                                TEXT /* Whether reference frames settings are required for decoding AVC (Yes, No) */
, "video_format_settings_pulldown"                                 TEXT /* Pulldown method (for film transferred to video) */
, "video_format_settings_endianness"                               TEXT /* Order of bytes required for decoding (Big, Little) */
, "video_format_settings_packing"                                  TEXT /* Data packing method used in DPX frames (e.g. Packed, Filled A, Filled B) */
, "video_format_settings_framemode"                                TEXT /* Frame mode for decoding (e.g. Frame doubling, Frame tripling) */
, "video_format_settings_gop"                                      TEXT /* GOP method set for format (e.g. N=1, Variable) */
, "video_format_settings_picturestructure"                         TEXT /* Picture structure method set for format (e.g. Frame, Field) */
, "video_format_settings_wrapping"                                 TEXT /* Wrapping mode set for format (e.g. Frame, Clip) */
, "video_internetmediatype"                                        TEXT /* Internet Media Type a.k.a. MIME Type, Content-Type */
, "video_muxingmode"                                               TEXT /* How this file is muxed in the container (e.g. Muxed in Video #1) */
, "video_codecid"                                                  TEXT /* Codec identifier as indicated by the container */
, "video_codecid_description"                                      TEXT /* Codec description, as defined by the container */
, "video_duration"                                                 TEXT /* Play time of the stream, in s (ms for text output) */
, "video_duration_firstframe"                                      TEXT /* Duration of the first frame (if different than other frames), in ms */
, "video_duration_lastframe"                                       TEXT /* Duration of the last frame (if different than other frames), in ms */
, "video_source_duration"                                          TEXT /* Duration of the file, of content stored in the file, in ms */
, "video_source_duration_firstframe"                               TEXT /* Duration of the first frame, of content stored in the file, in ms */
, "video_source_duration_lastframe"                                TEXT /* Duration of the last frame, of content stored in the file, in ms */
, "video_bitrate_mode"                                             TEXT /* Bit rate mode of this stream (CBR, VBR) */
, "video_bitrate"                                                  TEXT /* Bit rate of this stream, in bps */
, "video_bitrate_minimum"                                          TEXT /* Minimum bit rate of this stream, in bps */
, "video_bitrate_nominal"                                          TEXT /* Nominal bit rate of this stream, in bps */
, "video_bitrate_maximum"                                          TEXT /* Maximum bit rate of this stream, in bps */
, "video_bitrate_encoded"                                          TEXT /* Encoded bit rate (with forced padding), if container padding is present, in bps */
, "video_width"                                                    TEXT /* Width of frame (trimmed to clean aperture size if present) in pixels, as integer (e.g. 1920) */
, "video_width_offset"                                             TEXT /* Offset between original width and displayed width, in pixels */
, "video_width_cleanaperture"                                      TEXT /* Width of frame (trimmed to clean aperture size if present) in pixels, presented as integer (e.g. 1920) */
, "video_height"                                                   TEXT /* Height of frame (including aperture size if present) in pixels, presented as integer (e.g. 1080) */
, "video_height_offset"                                            TEXT /* Offset between original height and displayed height, in pixels */
, "video_height_cleanaperture"                                     TEXT /* Height of frame (trimmed to clean aperture size if present) in pixels, presented as integer (e.g. 1080) */
, "video_stored_width"                                             TEXT /* Width of frame, considering data stored in the codec */
, "video_stored_height"                                            TEXT /* Height of frame, considering data stored in the codec */
, "video_sampled_width"                                            TEXT /* Width of frame, from data derived from video stream */
, "video_sampled_height"                                           TEXT /* Height of frame, from data derived from video stream */
, "video_pixelaspectratio"                                         TEXT /* Width of a pixel as compared to the height (e.g. 1.422) */
, "video_pixelaspectratio_cleanaperture"                           TEXT /* Width of a pixel as compared to the height, considering clean aperture dimensions (e.g. 1.422). This field is only shown if the values are different */
, "video_displayaspectratio"                                       TEXT /* The proportional relationship between the width and height of a frame (e.g. 4:3) */
, "video_displayaspectratio_cleanaperture"                         TEXT /* The proportional relationship between the width and height of a frame, considering clean aperture dimensions (e.g. 4:3) */
, "video_activeformatdescription"                                  TEXT /* Active Format Description, as value code (e.g. 001) */
, "video_activeformatdescription_muxingmode"                       TEXT /* Muxing mode used for Active Format Description (AFD value). Options are A/53 (for Raw) or SMPTE ST 2016-3 (for Ancillary) */
, "video_rotation"                                                 TEXT /* Rotation of video, derived from track header data, in degrees */
, "video_framerate_mode"                                           TEXT /* Frame rate mode, as acronym (e.g. CFR, VFR) */
, "video_framerate"                                                TEXT /* Frames per second, as float (e.g. 29.970) */
, "video_framerate_minimum"                                        TEXT /* Minimum frames per second (e.g. 25.000) */
, "video_framerate_nominal"                                        TEXT /* Frames per second rounded to closest standard (e.g. 24.98) */
, "video_framerate_maximum"                                        TEXT /* Maximum frames per second */
, "video_framerate_real"                                           TEXT /* Real (capture) frames per second */
, "video_framecount"                                               TEXT /* Numer of frames */
, "video_source_framecount"                                        TEXT /* Number of frames according to media header (media/stts atom) data */
, "video_standard"                                                 TEXT /* Either the NTSC or PAL color encoding system, as stored in the content */
, "video_colorspace"                                               TEXT /* Color profile of the image (e.g. YUV) */
, "video_chromasubsampling"                                        TEXT /* Ratio of chroma to luma in encoded image (e.g. 4:2:2) */
, "video_chromasubsampling_position"                               TEXT /* Position type of chroma subsampling */
, "video_bitdepth"                                                 TEXT /* Color information stored in the video frames, as integer (e.g. 10) */
, "video_scantype"                                                 TEXT /* Way in which lines of video are displayed (e.g. Progressive) */
, "video_scantype_storemethod"                                     TEXT /* Whether the video's ScanType is stored with fields separated or interleaved */
, "video_scantype_storemethod_fieldsperblock"                      TEXT /* Count of fields per container block */
, "video_scanorder"                                                TEXT /* Order in which lines are encoded, as acronym (e.g. TFF) */
, "video_scanorder_stored"                                         TEXT /* Stored ScanOrder, displayed when the stored order is not same as the display order */
, "video_compression_mode"                                         TEXT /* Compression mode (Lossy, Lossless) */
, "video_delay"                                                    TEXT /* Delay fixed in the stream (relative), in ms */
, "video_timestamp_firstframe"                                     TEXT /* Timestamp fixed in the stream (relative), in ms */
, "video_timecode_firstframe"                                      TEXT /* Time code for first frame in format HH:MM:SS:FF, with last colon replaced by semicolon for drop frame if available */
, "video_timecode_lastframe"                                       TEXT /* Time code for last frame (excluding the duration of the last frame) in format HH:MM:SS:FF, with last colon replaced by semicolon for drop frame if available */
, "video_timecode_settings"                                        TEXT /* Additional time code settings */
, "video_timecode_source"                                          TEXT /* Time code source (Container, Stream, SystemScheme1, SDTI, ANC, etc.) */
, "video_gop_openclosed"                                           TEXT /* Time code information about Open/Closed GOP */
, "video_gop_openclosed_firstframe"                                TEXT /* Time code information about Open/Closed of first frame if GOP is Open for the other GOPs */
, "video_streamsize"                                               TEXT /* Size of this stream, in bytes */
, "video_source_streamsize"                                        TEXT /* Size of content stored in the file, in bytes */
, "video_streamsize_encoded"                                       TEXT /* Size of this stream when encoded, in bytes */
, "video_source_streamsize_encoded"                                TEXT /* Size of content stored in the file when encoded, in bytes */
, "video_alignment"                                                TEXT /* How this stream is aligned in the container (e.g. Aligned, Split) */
, "video_title"                                                    TEXT /* Title of track */
, "video_encoded_application"                                      TEXT /* Name of the software package used to create the file (e.g. Microsoft WaveEdiTY) */
, "video_encoded_application_companyname"                          TEXT /* Name of the company of the encoding application */
, "video_encoded_application_name"                                 TEXT /* Name of the encoding product */
, "video_encoded_application_version"                              TEXT /* Version of the encoding product */
, "video_encoded_application_url"                                  TEXT /* URL associated with the encoding software */
, "video_encoded_library"                                          TEXT /* Software used to create the file */
, "video_encoded_library_companyname"                              TEXT /* Name of the encoding software company */
, "video_encoded_library_name"                                     TEXT /* Name of the encoding software */
, "video_encoded_library_version"                                  TEXT /* Version of the encoding software */
, "video_encoded_library_date"                                     TEXT /* Release date of the encoding software, in UTC */
, "video_encoded_library_settings"                                 TEXT /* Parameters used by the encoding software */
, "video_encoded_operatingsystem"                                  TEXT /* Operating System of the encoding software */
, "video_language"                                                 TEXT /* Language, formatted as 2-letter ISO 639-1 if exists, else 3-letter ISO 639-2, and with optional ISO 3166-1 country separated by a dash if available (e.g. en, en-US, en-CN) */
, "video_language_more"                                            TEXT /* More information about Language (e.g. Director's Comment) */
, "video_servicekind"                                              TEXT /* Type of assisted service (e.g. visually impaired, commentary, voice over) */
, "video_disabled"                                                 TEXT /* Set if this stream should not be used (Yes, No) */
, "video_default"                                                  TEXT /* Flag set if this stream should be used if no language found matches the user preference (Yes, No) */
, "video_forced"                                                   TEXT /* Flag set if this stream should be used regardless of user preferences, often used for sparse subtitle dialogue in an otherwise unsubtitled movie (Yes, No) */
, "video_alternategroup"                                           TEXT /* Number of a group in order to provide versions of the same track */
, "video_encoded_date"                                             TEXT /* Time that the encoding of this item was completed, in UTC */
, "video_tagged_date"                                              TEXT /* Time that the tags were added to this item, in UTC */
, "video_encryption"                                               TEXT /* Whether this stream is encrypted and, if available, how it is encrypted */
, "video_buffersize"                                               TEXT /* The minimum size of the buffer needed to decode the sequence */
, "video_colour_description_present"                               TEXT /* Presence of color description (Yes, No) */
, "video_colour_description_present_source"                        TEXT /* Presence of colour description (source) */
, "video_colour_range"                                             TEXT /* Color range for YUV color space */
, "video_colour_range_source"                                      TEXT /* Colour range for YUV colour space (source) */
, "video_colour_primaries"                                         TEXT /* Chromaticity coordinates of the source primaries */
, "video_colour_primaries_source"                                  TEXT /* Chromaticity coordinates of the source primaries (source) */
, "video_transfer_characteristics"                                 TEXT /* Opto-electronic transfer characteristic of the source picture */
, "video_transfer_characteristics_source"                          TEXT /* Opto-electronic transfer characteristic of the source picture (source) */
, "video_matrix_coefficients"                                      TEXT /* Matrix coefficients used in deriving luma and chroma signals from the green, blue, and red primaries */
, "video_matrix_coefficients_source"                               TEXT /* Matrix coefficients used in deriving luma and chroma signals from the green, blue, and red primaries (source) */
, "video_masteringdisplay_colorprimaries"                          TEXT /* Chromaticity coordinates of the source primaries of the mastering display */
, "video_masteringdisplay_colorprimaries_source"                   TEXT /* Chromaticity coordinates of the source primaries of the mastering display (source) */
, "video_masteringdisplay_luminance"                               TEXT /* Luminance of the mastering display */
, "video_masteringdisplay_luminance_source"                        TEXT /* Luminance of the mastering display (source) */
, "video_maxcll"                                                   TEXT /* Maximum content light level */
, "video_maxcll_source"                                            TEXT /* Maximum content light level (source) */
, "video_maxfall"                                                  TEXT /* Maximum frame average light level */
, "video_maxfall_source"                                           TEXT /* Maximum frame average light level (source) */
, "audio_streamorder"                                              TEXT /* Stream order in the file for type of stream. Counting starts at 0 */
, "audio_id"                                                       TEXT /* The identification number for this stream in this file */
, "audio_originalsourcemedium_id"                                  TEXT /* Identification for this stream in the original medium of the material */
, "audio_uniqueid"                                                 TEXT /* The unique ID for this stream, should be copied with stream copy */
, "audio_menuid"                                                   TEXT /* The menu ID for this stream in this file */
, "audio_format"                                                   TEXT /* Format used */
, "audio_format_commercial_ifany"                                  TEXT /* Commercial name used by vendor for these settings, if available */
, "audio_format_version"                                           TEXT /* Version for the identified format */
, "audio_format_profile"                                           TEXT /* Profile of the Format */
, "audio_format_level"                                             TEXT /* Level of the Format */
, "audio_format_compression"                                       TEXT /* Compression method used */
, "audio_format_settings_sbr"                                      TEXT /* Whether Spectral band replication settings used in encoding. Options are Yes (NBC)/No (Explicit). Note: NBC stands for Not Backwards Compatable */
, "audio_format_settings_ps"                                       TEXT /* Whether Parametric Stereo settings used in encoding. Options are Yes (NBC)/No (Explicit). Note: NBC stands for Not Backwards Compatable */
, "audio_format_settings_mode"                                     TEXT /* Profile for format settings used in encoding (e.g. Joint Stereo) */
, "audio_format_settings_modeextension"                            TEXT /* Extended format settings profile for Joint Stereo, derived from header data (e.g. Intensity Stereo + MS Stereo) */
, "audio_format_settings_emphasis"                                 TEXT /* Emphasis format settings for MPEG audio, derived from header data (e.g. 50/15ms) */
, "audio_format_settings_floor"                                    TEXT /* Settings for Vorbis spectral floor (a low-resolution representation of the audio spectrum for the given channel in the current frame) vector (e.g. Floor0) */
, "audio_format_settings_firm"                                     TEXT /* Agency or company responsible for format settings used in encoding (e.g. Microsoft) */
, "audio_format_settings_endianness"                               TEXT /* Order of bytes required for decoding. Options are Big/Little */
, "audio_format_settings_sign"                                     TEXT /* How numbers are stored in stream's encoding. Options are Signed/Unsigned */
, "audio_format_settings_law"                                      TEXT /* U-law or A-law */
, "audio_format_settings_itu"                                      TEXT /* ITU Telecommunication Standardization Sector compression standard used in encoding (e.g. G.726) */
, "audio_format_settings_wrapping"                                 TEXT /* Wrapping mode set for format (e.g. Frame, Clip) */
, "audio_format_additionalfeatures"                                TEXT /* Features from the format that are required to fully support the file content */
, "audio_matrix_format"                                            TEXT /* Matrix format used in encoding (e.g. DTS Neural Audio) */
, "audio_internetmediatype"                                        TEXT /* Internet Media Type (aka MIME Type, Content-Type) */
, "audio_muxingmode"                                               TEXT /* How this file is muxed in the container (e.g. Muxed in Video #1) */
, "audio_codecid"                                                  TEXT /* Codec identifier as indicated by the container */
, "audio_codecid_description"                                      TEXT /* Codec description indicated by the container */
, "audio_duration"                                                 TEXT /* Play time of the stream, in s (ms for text output) */
, "audio_duration_firstframe"                                      TEXT /* Duration of the first frame (if different than other frames), in ms */
, "audio_duration_lastframe"                                       TEXT /* Duration of the last frame (if different than other frames), in ms */
, "audio_source_duration"                                          TEXT /* Duration of content stored in the file, in ms */
, "audio_source_duration_firstframe"                               TEXT /* Duration of the first frame of content stored in the file (if different than other frames), in ms */
, "audio_source_duration_lastframe"                                TEXT /* Duration of the last frame of content stored in the file (if different than other frames), in ms */
, "audio_bitrate_mode"                                             TEXT /* Bit rate mode of this stream (CBR, VBR) */
, "audio_bitrate"                                                  TEXT /* Bit rate of this stream, in bps */
, "audio_bitrate_minimum"                                          TEXT /* Minimum bit rate of this stream, in bps */
, "audio_bitrate_nominal"                                          TEXT /* Nominal bit rate of this stream, in bps */
, "audio_bitrate_maximum"                                          TEXT /* Maximum bit rate of this stream, in bps */
, "audio_bitrate_encoded"                                          TEXT /* Encoded bit rate (with forced padding), if container padding is present, in bps */
, "audio_channel(s)"                                               TEXT /* Number of channels (e.g. 2) */
, "audio_matrix_channel(s)"                                        TEXT /* Number of channels after matrix decoding */
, "audio_channelpositions"                                         TEXT /* Position of channels (e.g. Front: L C R, Side: L R, Back: L R, LFE) */
, "audio_matrix_channelpositions"                                  TEXT /* Position of channels after matrix decoding */
, "audio_channellayout"                                            TEXT /* Layout of channels (e.g. L R C LFE Ls Rs Lb Rb) */
, "audio_channellayoutid"                                          TEXT /* ID of layout of channels (e.g. MXF descriptor channel assignment). Warning, sometimes this is not enough for uniquely identifying a layout (e.g. MXF descriptor channel assignment is SMPTE 377-4). For AC-3, the form is x,y with x=acmod and y=lfeon */
, "audio_samplesperframe"                                          TEXT /* Samples per frame (e.g. 1536) */
, "audio_samplingrate"                                             TEXT /* Sampling rate, in Hertz (e.g. 48000) */
, "audio_samplingcount"                                            TEXT /* Sample count (based on sampling rate) */
, "audio_source_samplingcount"                                     TEXT /* Source Sample count (based on sampling rate), with information derived from header metadata */
, "audio_framerate"                                                TEXT /* Frames per second, as float (e.g. 29.970) */
, "audio_framecount"                                               TEXT /* Frame count */
, "audio_source_framecount"                                        TEXT /* Source frame count */
, "audio_bitdepth"                                                 TEXT /* Number of bits in each sample (resolution) of stream (e.g. 16). This field will show the significant bits if the stored bit depth is different */
, "audio_bitdepth_detected"                                        TEXT /* Number of bits in each sample (resolution), as detected during scan of the input by the muxer, in bits (e.g. 24) */
, "audio_bitdepth_stored"                                          TEXT /* Stored number of bits in each sample (resolution), in bits (e.g. 24) */
, "audio_compression_mode"                                         TEXT /* Compression mode (Lossy, Lossless) */
, "audio_delay"                                                    TEXT /* Delay fixed in the stream (relative), in ms */
, "audio_timecode_firstframe"                                      TEXT /* Time code for first frame in format HH:MM:SS:FF, with last colon replaced by semicolon for drop frame if available */
, "audio_timecode_lastframe"                                       TEXT /* Time code for last frame (excluding the duration of the last frame) in format HH:MM:SS:FF, with last colon replaced by semicolon for drop frame if available */
, "audio_timecode_settings"                                        TEXT /* Additional time code settings */
, "audio_timecode_source"                                          TEXT /* Time code source (Container, Stream, SystemScheme1, SDTI, ANC, etc.) */
, "audio_replaygain_gain"                                          TEXT /* The gain to apply to reach 89dB SPL on playback */
, "audio_replaygain_peak"                                          TEXT /* The maximum absolute peak value of the item */
, "audio_streamsize"                                               TEXT /* Size of this stream, in bytes */
, "audio_source_streamsize"                                        TEXT /* Size of content stored in the file, in bytes */
, "audio_streamsize_encoded"                                       TEXT /* Size of this stream when encoded, in bytes */
, "audio_source_streamsize_encoded"                                TEXT /* Size of content stored in the file when encoded, in bytes */
, "audio_alignment"                                                TEXT /* How this stream is aligned in the container (e.g. Aligned, Split) */
, "audio_interleave_videoframes"                                   TEXT /* For interleaved video, between how many video frames this stream is inserted (e.g. 0.51 video frame) */
, "audio_interleave_duration"                                      TEXT /* For interleaved video, between how much time, in ms, this stream is inserted (e.g. 21 ms) */
, "audio_interleave_preload"                                       TEXT /* How much time is buffered before the first video frame, in ms (e.g. 500) */
, "audio_title"                                                    TEXT /* Title of track */
, "audio_encoded_application"                                      TEXT /* Name of the software package used to create the file (e.g. Microsoft WaveEdiTY) */
, "audio_encoded_application_companyname"                          TEXT /* Name of the company of the encoding application */
, "audio_encoded_application_name"                                 TEXT /* Name of the encoding product */
, "audio_encoded_application_version"                              TEXT /* Version of the encoding product */
, "audio_encoded_application_url"                                  TEXT /* URL associated with the encoding software */
, "audio_encoded_library"                                          TEXT /* Software used to create the file */
, "audio_encoded_library_companyname"                              TEXT /* Name of the encoding software company */
, "audio_encoded_library_name"                                     TEXT /* Name of the encoding software */
, "audio_encoded_library_version"                                  TEXT /* Version of the encoding software */
, "audio_encoded_library_date"                                     TEXT /* Release date of the encoding software, in UTC */
, "audio_encoded_library_settings"                                 TEXT /* Parameters used by the encoding software */
, "audio_encoded_operatingsystem"                                  TEXT /* Operating System of the encoding software */
, "audio_language"                                                 TEXT /* Language, formatted as 2-letter ISO 639-1 if exists, else 3-letter ISO 639-2, and with optional ISO 3166-1 country separated by a dash if available (e.g. en, en-US, en-CN) */
, "audio_language_more"                                            TEXT /* More information about Language (e.g. Director's Comment) */
, "audio_servicekind"                                              TEXT /* Type of assisted service (e.g. visually impaired, commentary, voice over) */
, "audio_disabled"                                                 TEXT /* Set if this stream should not be used (Yes, No) */
, "audio_default"                                                  TEXT /* Flag set if this stream should be used if no language found matches the user preference (Yes, No) */
, "audio_forced"                                                   TEXT /* Flag set if this stream should be used regardless of user preferences, often used for sparse subtitle dialogue in an otherwise unsubtitled movie (Yes, No) */
, "audio_alternategroup"                                           TEXT /* Number of a group in order to provide versions of the same track */
, "audio_encoded_date"                                             TEXT /* Time that the encoding of this item was completed, in UTC */
, "audio_tagged_date"                                              TEXT /* Time that the tags were added to this item, in UTC */
, "audio_encryption"                                               TEXT /* Whether this stream is encrypted and, if available, how it is encrypted */
, "text_streamorder"                                               TEXT /* Stream order in the file for type of stream. Counting starts at 0 */
, "text_id"                                                        TEXT /* The identification number for this stream in this file */
, "text_originalsourcemedium_id"                                   TEXT /* Identification for this stream in the original medium of the material */
, "text_uniqueid"                                                  TEXT /* The unique ID for this stream, should be copied with stream copy */
, "text_menuid"                                                    TEXT /* The menu ID for this stream in this file */
, "text_format"                                                    TEXT /* Format used */
, "text_format_commercial_ifany"                                   TEXT /* Commercial name used by vendor for these settings, if available */
, "text_format_version"                                            TEXT /* Version for the identified format */
, "text_format_profile"                                            TEXT /* Profile of the Format */
, "text_format_compression"                                        TEXT /* Compression method used */
, "text_format_settings"                                           TEXT /* Settings used and required by decoder */
, "text_format_settings_wrapping"                                  TEXT /* Wrapping mode set for format (e.g. Frame, Clip) */
, "text_format_additionalfeatures"                                 TEXT /* Features from the format that are required to fully support the file content */
, "text_internetmediatype"                                         TEXT /* Internet Media Type (aka MIME Type, Content-Type) */
, "text_muxingmode"                                                TEXT /* How this file is muxed in the container (e.g. Muxed in Video #1) */
, "text_muxingmode_moreinfo"                                       TEXT /* More information about MuxingMode */
, "text_codecid"                                                   TEXT /* Codec identifier as indicated by the container */
, "text_codecid_description"                                       TEXT /* Codec description, as defined by the container */
, "text_duration"                                                  TEXT /* Play time of the stream, in ms */
, "text_duration_start2end"                                        TEXT /* Play time from first display to last display, in ms */
, "text_duration_start_command"                                    TEXT /* Timestamp of first command, in ms */
, "text_duration_start"                                            TEXT /* Timestamp of first display, in ms */
, "text_duration_end"                                              TEXT /* Play time of the stream, in s (ms for text output) */
, "text_duration_end_command"                                      TEXT /* Play time of the stream, in s (ms for text output) */
, "text_duration_firstframe"                                       TEXT /* Duration of the first frame (if different than other frames), in ms */
, "text_duration_lastframe"                                        TEXT /* Duration of the last frame (if different than other frames), in ms */
, "text_duration_base"                                             TEXT /* Temporal coordinate system used for timestamps */
, "text_source_duration"                                           TEXT /* Duration of content stored in the file (if different than duration), in ms */
, "text_source_duration_firstframe"                                TEXT /* Duration of the first frame of content stored in the file (if different than other frames),in ms */
, "text_source_duration_lastframe"                                 TEXT /* Duration of the last frame of content stored in the file (if different than other frames),in ms */
, "text_bitrate_mode"                                              TEXT /* Bit rate mode of this stream (CBR, VBR) */
, "text_bitrate"                                                   TEXT /* Bit rate of this stream, in bps */
, "text_bitrate_minimum"                                           TEXT /* Minimum bit rate of this stream, in bps */
, "text_bitrate_nominal"                                           TEXT /* Nominal bit rate of this stream, in bps */
, "text_bitrate_maximum"                                           TEXT /* Maximum bit rate of this stream, in bps */
, "text_bitrate_encoded"                                           TEXT /* Encoded bit rate (with forced padding), if container padding is present, in bps */
, "text_width"                                                     TEXT /* Width of frame (trimmed to clean aperture size if present) in characters */
, "text_height"                                                    TEXT /* Height of frame (including aperture size if present) in characters */
, "text_displayaspectratio"                                        TEXT /* The proportional relationship between the width and height of a frame (e.g. 4:3) */
, "text_displayaspectratio_original"                               TEXT /* The proportional relationship between the width and height of a frame (e.g. 4:3) */
, "text_framerate_mode"                                            TEXT /* Frame rate mode, as acronym (e.g. CFR, VFR) */
, "text_framerate_mode_original"                                   TEXT /* Frame rate mode, as acronym (e.g. CFR, VFR) */
, "text_framerate"                                                 TEXT /* Frames per second, as float (e.g. 29.970) */
, "text_framerate_minimum"                                         TEXT /* Minimum frames per second (e.g. 25.000) */
, "text_framerate_nominal"                                         TEXT /* Frames per second rounded to closest standard (e.g. 29.97) */
, "text_framerate_maximum"                                         TEXT /* Maximum frames per second */
, "text_framerate_original"                                        TEXT /* Frames per second */
, "text_colorspace"                                                TEXT /* Color profile of the image (e.g. YUV) */
, "text_chromasubsampling"                                         TEXT /* Ratio of chroma to luma in encoded image (e.g. 4:2:2) */
, "text_bitdepth"                                                  TEXT /* Color information stored in the video frames, as integer (e.g. 10) */
, "text_compression_mode"                                          TEXT /* Compression mode (Lossy, Lossless) */
, "text_delay"                                                     TEXT /* Delay fixed in the stream (relative), in ms */
, "text_timecode_firstframe"                                       TEXT /* Time code for first frame in format HH:MM:SS:FF, with last colon replaced by semicolon for drop frame if available */
, "text_timecode_lastframe"                                        TEXT /* Time code for last frame (excluding the duration of the last frame) in format HH:MM:SS:FF, with last colon replaced by semicolon for drop frame if available */
, "text_timecode_settings"                                         TEXT /* Additional time code settings */
, "text_timecode_source"                                           TEXT /* Time code source (Container, Stream, SystemScheme1, SDTI, ANC, etc.) */
, "text_timecode_maxframenumber"                                   TEXT /* Maximum frame number in time codes */
, "text_timecode_maxframenumber_theory"                            TEXT /* Theoritical maximum frame number in time codes */
, "text_streamsize"                                                TEXT /* Size of this stream, in bytes */
, "text_source_streamsize"                                         TEXT /* Size of content stored in the file, in bytes */
, "text_streamsize_encoded"                                        TEXT /* Size of this stream when encoded, in bytes */
, "text_source_streamsize_encoded"                                 TEXT /* Size of content stored in the file when encoded, in bytes */
, "text_title"                                                     TEXT /* Title of file */
, "text_encoded_application"                                       TEXT /* Name of the software package used to create the file (e.g. Microsoft WaveEdiTY) */
, "text_encoded_application_companyname"                           TEXT /* Name of the company of the encoding application */
, "text_encoded_application_name"                                  TEXT /* Name of the encoding product */
, "text_encoded_application_version"                               TEXT /* Version of the encoding product */
, "text_encoded_application_url"                                   TEXT /* URL associated with the encoding software */
, "text_encoded_library"                                           TEXT /* Software used to create the file */
, "text_encoded_library_companyname"                               TEXT /* Name of the encoding software company */
, "text_encoded_library_name"                                      TEXT /* Name of the encoding software */
, "text_encoded_library_version"                                   TEXT /* Version of the encoding software */
, "text_encoded_library_date"                                      TEXT /* Release date of the encoding software, in UTC */
, "text_encoded_library_settings"                                  TEXT /* Parameters used by the encoding software */
, "text_encoded_operatingsystem"                                   TEXT /* Operating System of the encoding software */
, "text_language"                                                  TEXT /* Language, formatted as 2-letter ISO 639-1 if exists, else 3-letter ISO 639-2, and with optional ISO 3166-1 country separated by a dash if available (e.g. en, en-US, en-CN) */
, "text_language_more"                                             TEXT /* More information about Language (e.g. Director's Comment) */
, "text_servicekind"                                               TEXT /* Type of assisted service (e.g. visually impaired, commentary, voice over) */
, "text_disabled"                                                  TEXT /* Set if this stream should not be used (Yes, No) */
, "text_default"                                                   TEXT /* Flag set if this stream should be used if no language found matches the user preference (Yes, No) */
, "text_forced"                                                    TEXT /* Flag set if this stream should be used regardless of user preferences, often used for sparse subtitle dialogue in an otherwise unsubtitled movie (Yes, No) */
, "text_alternategroup"                                            TEXT /* Number of a group in order to provide versions of the same track */
, "text_summary"                                                   TEXT /* Plot outline or a summary of the story */
, "text_encoded_date"                                              TEXT /* Time/date/year that the encoding of this content was completed */
, "text_tagged_date"                                               TEXT /* Time/date/year that the tags were added to this content */
, "text_encryption"                                                TEXT /* Whether this stream is encrypted and, if available, how it is encrypted */
, "text_events_minduration"                                        TEXT /* Minimum duration per event, in ms */
, "other_streamorder"                                              TEXT /* Stream order in the file, whatever is the kind of stream (base=0) */
, "other_id"                                                       TEXT /* The ID for this stream in this file */
, "other_originalsourcemedium_id"                                  TEXT /* The ID for this stream in the original medium of the material */
, "other_uniqueid"                                                 TEXT /* The unique ID for this stream, should be copied with stream copy */
, "other_menuid"                                                   TEXT /* The menu ID for this stream in this file */
, "other_type"                                                     TEXT /* Type */
, "other_format"                                                   TEXT /* Format used */
, "other_format_commercial_ifany"                                  TEXT /* Commercial name used by vendor for theses setings if there is one */
, "other_format_additionalfeatures"                                TEXT /* Format features needed for fully supporting the content */
, "other_muxingmode"                                               TEXT /* How this file is muxed in the container */
, "other_codecid"                                                  TEXT /* Codec ID (found in some containers) */
, "other_codecid_description"                                      TEXT /* Manual description given by the container */
, "other_duration"                                                 TEXT /* Play time of the stream in ms */
, "other_source_duration"                                          TEXT /* Source Play time of the stream, in ms */
, "other_source_duration_firstframe"                               TEXT /* Source Duration of the first frame if it is longer than others, in ms */
, "other_source_duration_lastframe"                                TEXT /* Source Duration of the last frame if it is longer than others, in ms */
, "other_bitrate_mode"                                             TEXT /* Bit rate mode (VBR, CBR) */
, "other_bitrate"                                                  TEXT /* Bit rate in bps */
, "other_bitrate_minimum"                                          TEXT /* Minimum Bit rate in bps */
, "other_bitrate_nominal"                                          TEXT /* Nominal Bit rate in bps */
, "other_bitrate_maximum"                                          TEXT /* Maximum Bit rate in bps */
, "other_bitrate_encoded"                                          TEXT /* Encoded (with forced padding) bit rate in bps, if some container padding is present */
, "other_framerate"                                                TEXT /* Frames per second */
, "other_delay"                                                    TEXT /* Delay fixed in the stream (relative) IN MS */
, "other_timestamp_firstframe"                                     TEXT /* TimeStamp fixed in the stream (relative) IN MS */
, "other_timecode_firstframe"                                      TEXT /* Time code in HH:MM:SS:FF, last colon replaced by semicolon for drop frame if available format */
, "other_timecode_lastframe"                                       TEXT /* Time code of the last frame (excluding the duration of the last frame) in HH:MM:SS:FF, last colon replaced by semicolon for drop frame if available format */
, "other_timecode_settings"                                        TEXT /* Time code settings */
, "other_timecode_stripped"                                        TEXT /* Time code is Stripped (only 1st time code, no discontinuity) */
, "other_timecode_source"                                          TEXT /* Time code source (Container, Stream, SystemScheme1, SDTI, ANC...) */
, "other_streamsize"                                               TEXT /* Streamsize in bytes */
, "other_source_streamsize"                                        TEXT /* Source Streamsize in bytes */
, "other_streamsize_encoded"                                       TEXT /* Encoded Streamsize in bytes */
, "other_source_streamsize_encoded"                                TEXT /* Source Encoded Streamsize in bytes */
, "other_title"                                                    TEXT /* Name of this menu */
, "other_language"                                                 TEXT /* Language (2-letter ISO 639-1 if exists, else 3-letter ISO 639-2, and with optional ISO 3166-1 country separated by a dash if available, e.g. en, en-us, zh-cn) */
, "other_language_more"                                            TEXT /* More info about Language (e.g. Director's Comment) */
, "other_servicekind"                                              TEXT /* Service kind, e.g. visually impaired, commentary, voice over */
, "other_disabled"                                                 TEXT /* Set if that track should not be used */
, "other_default"                                                  TEXT /* Set if that track should be used if no language found matches the user preference. */
, "other_forced"                                                   TEXT /* Set if that track should be used if no language found matches the user preference. */
, "other_alternategroup"                                           TEXT /* Number of a group in order to provide versions of the same track */
, "image_streamorder"                                              TEXT /* Stream order in the file for type of stream. Counting starts at 0 */
, "image_id"                                                       TEXT /* The identification number for this stream in this file */
, "image_originalsourcemedium_id"                                  TEXT /* Identification for this stream in the original medium of the material */
, "image_uniqueid"                                                 TEXT /* The unique ID for this stream, should be copied with stream copy */
, "image_menuid"                                                   TEXT /* The menu ID for this stream in this file */
, "image_title"                                                    TEXT /* Title of track */
, "image_format"                                                   TEXT /* Format used */
, "image_format_commercial_ifany"                                  TEXT /* Commercial name used by vendor for these settings, if available */
, "image_format_settings_endianness"                               TEXT /* Order of bytes required for decoding. Options are Big/Little */
, "image_format_settings_packing"                                  TEXT /* Data packing method used in DPX frames (e.g. Packed, Filled A, Filled B) */
, "image_format_compression"                                       TEXT /* Compression method used */
, "image_format_settings_wrapping"                                 TEXT /* Wrapping mode set for format (e.g. Frame, Clip) */
, "image_format_additionalfeatures"                                TEXT /* Format features needed for fully supporting the content */
, "image_internetmediatype"                                        TEXT /* Internet Media Type (aka MIME Type, Content-Type) */
, "image_codecid"                                                  TEXT /* Codec identifier as indicated by the container */
, "image_codecid_description"                                      TEXT /* Codec description, as defined by the container */
, "image_width"                                                    TEXT /* Width of frame (trimmed to clean aperture size if present) in pixels, as integer (e.g. 1920) */
, "image_width_offset"                                             TEXT /* Offset between original width and displayed width, in pixels */
, "image_width_original"                                           TEXT /* Width of frame (not including aperture size if present) in pixels, presented as integer (e.g. 1920) */
, "image_height"                                                   TEXT /* Height of frame (including aperture size if present) in pixels, presented as integer (e.g. 1080) */
, "image_height_offset"                                            TEXT /* Offset between original height and displayed height, in pixels */
, "image_height_original"                                          TEXT /* Height of frame (not including aperture size if present) in pixels, presented as integer (e.g. 1080) */
, "image_pixelaspectratio"                                         TEXT /* Pixel Aspect ratio */
, "image_pixelaspectratio_original"                                TEXT /* Original (in the raw stream) Pixel Aspect ratio */
, "image_displayaspectratio"                                       TEXT /* The proportional relationship between the width and height of a frame (e.g. 4:3) */
, "image_displayaspectratio_original"                              TEXT /* The proportional relationship between the width and height of a frame (e.g. 4:3) */
, "image_colorspace"                                               TEXT /* Color profile of the image (e.g. YUV) */
, "image_chromasubsampling"                                        TEXT /* Ratio of chroma to luma in encoded image (e.g. 4:2:2) */
, "image_bitdepth"                                                 TEXT /* Color information stored in the frame, as integer (e.g. 10) */
, "image_compression_mode"                                         TEXT /* Compression mode (Lossy, Lossless) */
, "image_streamsize"                                               TEXT /* Size of this stream, in bytes */
, "image_encoded_library"                                          TEXT /* Software used to create the file */
, "image_encoded_library_name"                                     TEXT /* Name of the encoding software */
, "image_encoded_library_version"                                  TEXT /* Version of the encoding software */
, "image_encoded_library_date"                                     TEXT /* Release date of the encoding software, in UTC */
, "image_encoded_library_settings"                                 TEXT /* Parameters used by the encoding software */
, "image_language"                                                 TEXT /* Language, formatted as 2-letter ISO 639-1 if exists, else 3-letter ISO 639-2, and with optional ISO 3166-1 country separated by a dash if available (e.g. en, en-US, en-CN) */
, "image_language_more"                                            TEXT /* More information about Language (e.g. Director's Comment) */
, "image_servicekind"                                              TEXT /* Type of assisted service (e.g. visually impaired, commentary, voice over) */
, "image_disabled"                                                 TEXT /* Set if this stream should not be used (Yes, No) */
, "image_default"                                                  TEXT /* Flag set if this stream should be used if no language found matches the user preference (Yes, No) */
, "image_forced"                                                   TEXT /* Flag set if this stream should be used regardless of user preferences, often used for sparse subtitle dialogue in an otherwise unsubtitled movie (Yes, No) */
, "image_alternategroup"                                           TEXT /* Number of a group in order to provide versions of the same track */
, "image_summary"                                                  TEXT /* Plot outline or a summary of the story */
, "image_encoded_date"                                             TEXT /* Time that the encoding of this item was completed, in UTC */
, "image_tagged_date"                                              TEXT /* Time that the tags were added to this item, in UTC */
, "image_encryption"                                               TEXT /* Whether this stream is encrypted and, if available, how it is encrypted */
, "image_colour_description_present"                               TEXT /* Presence of color description (Yes, No) */
, "image_colour_primaries"                                         TEXT /* Chromaticity coordinates of the source primaries */
, "image_transfer_characteristics"                                 TEXT /* Opto-electronic transfer characteristic of the source picture */
, "image_matrix_coefficients"                                      TEXT /* Matrix coefficients used in deriving luma and chroma signals from the green, blue, and red primaries */
, "image_colour_description_present_original"                      TEXT /* Presence of colour description (if incoherencies) */
, "image_colour_primaries_original"                                TEXT /* Chromaticity coordinates of the source primaries (if incoherencies) */
, "image_transfer_characteristics_original"                        TEXT /* Opto-electronic transfer characteristic of the source picture (if incoherencies) */
, "image_matrix_coefficients_original"                             TEXT /* Matrix coefficients used in deriving luma and chroma signals from the green, blue, and red primaries (if incoherencies) */
, "menu_streamorder"                                               TEXT /* Stream order in the file for type of stream. Counting starts at 0 */
, "menu_id"                                                        TEXT /* The identification number for this stream in this file */
, "menu_originalsourcemedium_id"                                   TEXT /* Identification for this stream in the original medium of the material */
, "menu_uniqueid"                                                  TEXT /* The unique ID for this stream, should be copied with stream copy */
, "menu_menuid"                                                    TEXT /* The menu ID for this stream in this file */
, "menu_format"                                                    TEXT /* Format used */
, "menu_format_commercial_ifany"                                   TEXT /* Commercial name used by vendor for these settings, if available */
, "menu_format_additionalfeatures"                                 TEXT /* Features from the format that are required to fully support the file content */
, "menu_codecid"                                                   TEXT /* Codec identifier as indicated by the container */
, "menu_codecid_description"                                       TEXT /* Codec description, as defined by the container */
, "menu_duration"                                                  TEXT /* Play time of the stream, in s (ms for text output) */
, "menu_duration_start"                                            TEXT /* Start time of stream, in UTC */
, "menu_duration_end"                                              TEXT /* End time of stream, in UTC */
, "menu_delay"                                                     TEXT /* Delay fixed in the stream (relative), in ms */
, "menu_framerate_mode"                                            TEXT /* Frame rate mode, as acronym (e.g. CFR, VFR) */
, "menu_framerate"                                                 TEXT /* Frames per second, as float (e.g. 29.970) */
, "menu_list_streamkind"                                           TEXT /* List of programs available */
, "menu_list_streampos"                                            TEXT /* List of programs available */
, "menu_list"                                                      TEXT /* List of programs available */
, "menu_title"                                                     TEXT /* Name of this menu */
, "menu_language"                                                  TEXT /* Language, formatted as 2-letter ISO 639-1 if exists, else 3-letter ISO 639-2, and with optional ISO 3166-1 country separated by a dash if available (e.g. en, en-US, en-CN) */
, "menu_language_more"                                             TEXT /* More information about Language (e.g. Director's Comment) */
, "menu_servicekind"                                               TEXT /* Type of assisted service (e.g. visually impaired, commentary, voice over) */
, "menu_servicename"                                               TEXT /* Name of assisted service */
, "menu_servicechannel"                                            TEXT /* Channel of assisted service */
, "menu_service/url"                                               TEXT /* URL of assisted service */
, "menu_serviceprovider"                                           TEXT /* Provider of assisted service */
, "menu_serviceprovider/url"                                       TEXT /* URL of provider of assisted service */
, "menu_servicetype"                                               TEXT /* Type of assisted service */
, "menu_networkname"                                               TEXT /* Television network name */
, "menu_original/networkname"                                      TEXT /* Television network name of original broadcast */
, "menu_countries"                                                 TEXT /* Country information of the content */
, "menu_timezones"                                                 TEXT /* TimeZone information of the content */
, "menu_lawrating"                                                 TEXT /* Legal rating of a movie. Format depends on country of origin (e.g. PG, 16) */
, "menu_lawrating_reason"                                          TEXT /* Reason of the law rating */
, "menu_disabled"                                                  TEXT /* Set if this stream should not be used (Yes, No) */
, "menu_default"                                                   TEXT /* Flag set if this stream should be used if no language found matches the user preference (Yes, No) */
, "menu_forced"                                                    TEXT /* Flag set if this stream should be used regardless of user preferences, often used for sparse subtitle dialogue in an otherwise unsubtitled movie (Yes, No) */
, "menu_alternategroup"                                            TEXT /* Number of a group in order to provide versions of the same track */
)
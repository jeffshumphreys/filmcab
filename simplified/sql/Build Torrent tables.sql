DROP TABLE IF EXISTS torrents_staged CASCADE;
CREATE TABLE torrents_staged(
                torrent_staged_id                 SERIAL8 PRIMARY KEY
            ,   added_to_this_table               TIMESTAMPTZ DEFAULT(clock_timestamp())
            ,   load_batch_timestamp              TIMESTAMPTZ
            ,   load_batch_id                     INT
            ,   AddedOn                           TIMESTAMPTZ
            ,   AmountLeft                        INT8
            ,   AutoTmm                           BOOL
            ,   Availability                      FLOAT
            ,   Original_Availability             FLOAT
            ,   Category                          TEXT
            ,   Completed                         INT8
            ,   CompletionOn                      TIMESTAMPTZ
            ,   ContentPath                       TEXT
            ,   DlLimit                           INT8
            ,   Dlspeed                           INT8
            ,   Downloaded                        INT8
            ,   DownloadedSession                 INT8
            ,   DownloadPath                      TEXT
            ,   Eta                               INT8
            ,   FLPiecePrio                       BOOL
            ,   ForceStart                        BOOL
            ,   Hash                              TEXT UNIQUE
            ,   InactiveSeedingTimeLimit          INT8
            ,   Original_InactiveSeedingTimeLimit INT8
            ,   InfohashV1                        TEXT UNIQUE
            ,   InfohashV2                        TEXT
            ,   LastActivity                      TIMESTAMPTZ
            ,   MagnetUri                         TEXT UNIQUE
            ,   MaxInactiveSeedingTime            INT8
            ,   MaxRatio                          FLOAT
            ,   MaxSeedingTime                    INT8
            ,   Name                              TEXT UNIQUE
            ,   NumComplete                       INT8
            ,   NumIncomplete                     INT8
            ,   NumLeechs                         INT8
            ,   NumSeeds                          INT8
            ,   Priority                          INT8
            ,   Progress                          FLOAT
            ,   Ratio                             FLOAT
            ,   RatioLimit                        FLOAT
            ,   SavePath                          TEXT
            ,   SeedingTime                       INT8
            ,   SeedingTimeLimit                  INT8
            ,   SeenComplete                      TIMESTAMPTZ
            ,   SeqDl                             BOOL
            ,   Size                              INT8
            ,   State                             TEXT
            ,   SuperSeeding                      BOOL
            ,   Tags                              TEXT
            ,   TimeActive                        INT8
            ,   TotalSize                         INT8
            ,   Tracker                           TEXT
            ,   TrackersCount                     INT8
            ,   UpLimit                           INT8
            ,   Uploaded                          INT8
            ,   UploadedSession                   INT8
            ,   Upspeed                           INT8
        );
        
CREATE TABLE torrents(
                torrent_id                        SERIAL8 PRIMARY KEY
            ,   from_torrent_staged_load_batch_id INT
            ,   from_torrent_staged_id            INT8 REFERENCES torrents_staged(torrent_staged_id)
            ,   added_to_this_table         TIMESTAMPTZ DEFAULT(pg_catalog.clock_timestamp())
            ,   load_batch_timestamp        TIMESTAMPTZ
            ,   load_batch_id               INT
            ,   found_missing_on            TIMESTAMPTZ 
            ,   AddedOn                     TIMESTAMPTZ
            ,   AmountLeft                  INT8
            ,   AmountLeft_Original         INT8
            ,   AutoTmm                     bool
            ,   Availability                DOUBLE PRECISION -- Percentage of file pieces currently available
            ,   Availability_Original       DOUBLE PRECISION
            ,   Category                    TEXT
            ,   Completed                   INT8
            ,   CompletionOn                TIMESTAMPTZ
            ,   ContentPath                 TEXT             -- Absolute path of torrent content (root path for multifile torrents, absolute file path for singlefile torrents)
            ,   DlLimit                     INT8
            ,   Dlspeed                     INT8
            ,   Downloaded                  INT8
            ,   Downloaded_Original         INT8
            ,   DownloadedSession           INT8
            ,   DownloadPath                TEXT
            ,   Eta                         INT8
            ,   Eta_Original                INT8
            ,   FLPiecePrio                 bool
            ,   ForceStart                  bool
            ,   Hash                        TEXT UNIQUE
            ,   InactiveSeedingTimeLimit    INT8
            ,   InfohashV1                  TEXT UNIQUE
            ,   InfohashV2                  TEXT
            ,   LastActivity                TIMESTAMPTZ -- Last time (Unix Epoch) when a chunk was downloaded/uploaded
            ,   LastActivity_Original       TIMESTAMPTZ
            ,   MagnetUri                   TEXT UNIQUE
            ,   MaxInactiveSeedingTime      INT8
            ,   MaxRatio                    DOUBLE PRECISION
            ,   MaxSeedingTime              INT8
            ,   Name                        TEXT UNIQUE
            ,   NumComplete                 INT8
            ,   NumComplete_Original        INT8
            ,   NumIncomplete               INT8
            ,   NumIncomplete_Original      INT8
            ,   NumLeechs                   INT8
            ,   NumLeechs_Original          INT8
            ,   NumSeeds                    INT8
            ,   NumSeeds_Original           INT8
            ,   Priority                    INT8
            ,   Progress                    DOUBLE PRECISION
            ,   Progress_Original           DOUBLE PRECISION
            ,   Ratio                       DOUBLE PRECISION
            ,   Ratio_Original              DOUBLE PRECISION
            ,   RatioLimit                  DOUBLE PRECISION
            ,   SavePath                    TEXT
            ,   SeedingTime                 INT8
            ,   SeedingTime_Original        INT8
            ,   SeedingTimeLimit            INT8
            ,   SeenComplete                TIMESTAMPTZ     -- Time (Unix Epoch) when this torrent was last seen complete
            ,   SeenComplete_Original       TIMESTAMPTZ
            ,   SeqDl                       bool            -- True if sequential download is enabled
            ,   Size                        INT8            -- Total size (bytes) of files selected for download
            ,   State                       TEXT
            ,   State_Original              TEXT
            ,   SuperSeeding                bool
            ,   Tags                        TEXT
            ,   TimeActive                  INT8
            ,   TimeActive_Original         INT8
            ,   TotalSize                   INT8            -- Total size (bytes) of all file in this torrent (including unselected ones)
            ,   Tracker                     TEXT            -- The first tracker with working status. Returns empty string if no tracker is working.
            ,   Tracker_Original            TEXT
            ,   TrackersCount               INT8
            ,   TrackersCount_Original      INT8
            ,   UpLimit                     INT8
            ,   Uploaded                    INT8
            ,   Uploaded_Original           INT8
            ,   UploadedSession             INT8
            ,   UploadedSession_Original    INT8
            ,   Upspeed                     INT8
            ,   Upspeed_Original            INT8
            /*
             * peers
             * peers_total
             * pieces_have
             * pieces_num
             * reannounce
             * seeds
             * seeds_total
             * up_speed_avg
             * created_by
             * share_ratio
             * nb_connections
             * seeding_time
             * time_elapsed
             * comment
             * total_wasted
             * last_seen
             * creation_date
             * piece_size
             */
        );

    -- create TABLE TORRENT_TRACKERS
    -- NUM_PEARS
    -- TIER
    -- STATUS
    -- NUM_DOWNLOADED
    -- msg
    
    -- create table web seeds
    -- url
    
    -- create table contents
    -- index, name, size, progress, priority, is_seed, availability
    
    
--    CREATE COLLATION ndcoll (provider = icu, locale = 'und', deterministic = false);
--CREATE COLLATION ignore_accents (provider = icu, locale = 'und-u-ks-level1-kc-true', deterministic = false);
--CREATE COLLATION level3 (provider = icu, deterministic = false, locale = 'und-u-ka-shifted-ks-level3');
--SELECT 'z' = 'Z' COLLATE level3;
--CREATE COLLATION ignore_accent_case (provider = icu, deterministic = false, locale = 'und-u-ks-level1');
--CREATE COLLATION ignore_accent_case (provider = icu, deterministic = false, locale = 'und-u-ks-level1');
--CREATE COLLATION IF NOT EXISTS ignore_both_accent_and_case (provider = icu, deterministic = false, locale = 'und-u-ks-level1');
--SELECT 'd' = 'A' COLLATE ignore_accent_case; 
--
--ALTER TABLE files ALTER COLUMN final_extension SET DATA TYPE TEXT COLLATE "en_US"
    SELECT count(*) FROM torrents_staged ts  ;
    SELECT * FROM torrents_staged ts  ;
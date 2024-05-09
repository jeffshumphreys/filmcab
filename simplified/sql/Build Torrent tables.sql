DROP TABLE IF EXISTS torrents_staged;
CREATE TABLE torrents_staged(
            torrent_staged_id serial8 PRIMARY KEY
            ,   added_to_this_table timestamptz DEFAULT(pg_catalog.clock_timestamp())
            ,   load_batch_timestamp timestamptz
            ,   load_batch_id INT
            ,   AddedOn     TIMESTAMPTZ
            ,   AmountLeft     INT8
            ,   AutoTmm     bool
            ,   Availability     FLOAT
            ,   Category     TEXT
            ,   Completed     INT8
            ,   CompletionOn     TIMESTAMPTZ
            ,   ContentPath     TEXT
            ,   DlLimit     INT8
            ,   Dlspeed     INT8
            ,   Downloaded     INT8
            ,   DownloadedSession     INT8
            ,   DownloadPath     TEXT
            ,   Eta     INT8
            ,   FLPiecePrio     bool
            ,   ForceStart     bool
            ,   Hash     TEXT UNIQUE
            ,   InactiveSeedingTimeLimit     INT8
            ,   InfohashV1     TEXT UNIQUE
            ,   InfohashV2     TEXT
            ,   LastActivity     TIMESTAMPTZ
            ,   MagnetUri     TEXT UNIQUE
            ,   MaxInactiveSeedingTime     INT8
            ,   MaxRatio     FLOAT
            ,   MaxSeedingTime     INT8
            ,   Name     TEXT UNIQUE
            ,   NumComplete     INT8
            ,   NumIncomplete     INT8
            ,   NumLeechs     INT8
            ,   NumSeeds     INT8
            ,   Priority     INT8
            ,   Progress     FLOAT
            ,   Ratio     FLOAT
            ,   RatioLimit     FLOAT
            ,   SavePath     TEXT
            ,   SeedingTime     INT8
            ,   SeedingTimeLimit     INT8
            ,   SeenComplete     TIMESTAMPTZ
            ,   SeqDl     bool
            ,   Size     INT8
            ,   State     TEXT
            ,   SuperSeeding     bool
            ,   Tags     TEXT
            ,   TimeActive     INT8
            ,   TotalSize     INT8
            ,   Tracker     TEXT
            ,   TrackersCount     INT8
            ,   UpLimit     INT8
            ,   Uploaded     INT8
            ,   UploadedSession     INT8
            ,   Upspeed     INT8
        );
        
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
SELECT COUNT(*) FROM torrents;
SELECT COUNT(*) FROM torrents_staged ts ;
TRUNCATE TABLE torrents;
MERGE INTO torrents tgt
USING 
    (SELECT new_src.*
    , CASE WHEN new_src.name IS NULL THEN TRUE ELSE FALSE END AS tgt_now_missing
    , CASE WHEN old_tgt.name IS NULL THEN TRUE ELSE FALSE END AS src_is_new
    FROM torrents_staged new_src FULL JOIN torrents old_tgt ON new_src.name = old_tgt.name) src
    ON (tgt.name = src.name)
WHEN MATCHED AND NOT src.tgt_now_missing AND NOT src.src_is_new THEN -- Confusing, YES. It's NOT really MATCHED, since the "USING" IS bringing IN BOTH sides, past AND NEW.  So we've fake a MATCH USING the FULL JOIN, so we can deal WITH things LIKE deleted torrents IN NEW DATA, AND updating the CURRENT master WITH that status, keeping the history that these were deleted, FOR whatever reason.
    UPDATE SET
        amountleft_original            = tgt.amountleft,
        amountleft                     = src.amountleft,
        availability_original          = tgt.availability,
        availability                   = src.availability,
        downloaded_original            = tgt.downloaded,
        downloaded                     = src.downloaded,
        eta_original                   = tgt.eta,
        eta                            = src.eta,
        lastactivity_original          = tgt.lastactivity,
        lastactivity                   = src.lastactivity,
        numcomplete_original           = tgt.numcomplete,
        numcomplete                    = src.numcomplete,
        numincomplete_original         = tgt.numincomplete,
        numincomplete                  = src.numincomplete,
        numleechs_original             = tgt.numleechs,
        numleechs                      = src.numleechs,
        numseeds_original              = tgt.numseeds,
        numseeds                       = src.numseeds,
        progress_original              = tgt.progress,
        progress                       = src.progress,
        ratio_original                 = tgt.ratio,
        ratio                          = src.ratio,
        seedingtime_original           = tgt.seedingtime,
        seedingtime                    = src.seedingtime,
        seencomplete_original          = tgt.seencomplete,
        seencomplete                   = src.seencomplete,
        state_original                 = tgt.state,
        state                          = src.state,
        timeactive_original            = tgt.timeactive,
        timeactive                     = src.timeactive,
        tracker_original               = tgt.tracker,
        tracker                        = src.tracker,
        trackerscount_original         = tgt.trackerscount,
        trackerscount                  = src.trackerscount,
        uploaded_original              = tgt.uploaded,
        uploaded                       = src.uploaded,
        uploadedsession_original       = tgt.uploadedsession,
        uploadedsession                = src.uploadedsession,
        upspeed_original               = tgt.upspeed,
        upspeed                        = src.upspeed
WHEN MATCHED AND src.tgt_now_missing AND NOT src.src_is_new THEN -- See, these NO longer exist IN the qbittorrent app, so we keep that they were, AND UPDATE NOT WHEN they were removed FROM qbittorrent, but WHEN we detected they were removed.
    UPDATE SET found_missing_on = clock_timestamp() -- TODO: UPDATE WITH batch timestamp AND ALSO SET a batch id
WHEN NOT MATCHED AND src.src_is_new THEN 
    INSERT
    (
          from_torrent_stage_batch_id
        , from_torrent_stage_id
        , load_batch_timestamp                                          /* from script */
        , load_batch_id                                                 /* from script */
        , addedon
        , amountleft
        , autotmm
        , availability
        , category
        , completed
        , completionon
        , contentpath
        , dllimit
        , dlspeed
        , downloaded
        , downloadedsession
        , downloadpath
        , eta
        , flpieceprio
        , forcestart
        , hash
        , inactiveseedingtimelimit
        , infohashv1
        , infohashv2
        , lastactivity
        , magneturi
        , maxinactiveseedingtime
        , maxratio
        , maxseedingtime
        , "name"
        , numcomplete
        , numincomplete
        , numleechs
        , numseeds
        , priority
        , progress
        , ratio
        , ratiolimit
        , savepath
        , seedingtime
        , seedingtimelimit
        , seencomplete
        , seqdl
        , "size"
        , state
        , superseeding
        , tags
        , timeactive
        , totalsize
        , tracker
        , trackerscount
        , uplimit
        , uploaded
        , uploadedsession
        , upspeed
    )
VALUES
    (
              /* from_torrent_stage_batch_id                 */ load_batch_id              /* not sure */
            , /* from_torrent_stage_id                       */ torrent_staged_id
            , /* load_batch_timestamp                        */ clock_timestamp()          /* WRONG! */
            , /* load_batch_id                               */ 0                          /* WRONG! */
            , /* addedon                                     */ addedon
            , /* amountleft                                  */ amountleft
            , /* autotmm                                     */ autotmm
            , /* availability                                */ availability
            , /* category                                    */ category
            , /* completed                                   */ completed
            , /* completionon                                */ completionon
            , /* contentpath                                 */ contentpath
            , /* dllimit                                     */ dllimit
            , /* dlspeed                                     */ dlspeed
            , /* downloaded                                  */ downloaded
            , /* downloadedsession                           */ downloadedsession
            , /* downloadpath                                */ downloadpath
            , /* eta                                         */ eta
            , /* flpieceprio                                 */ flpieceprio
            , /* forcestart                                  */ forcestart
            , /* hash                                        */ hash
            , /* inactiveseedingtimelimit                    */ inactiveseedingtimelimit
            , /* infohashv1                                  */ infohashv1
            , /* infohashv2                                  */ infohashv2
            , /* lastactivity                                */ lastactivity
            , /* magneturi                                   */ magneturi
            , /* maxinactiveseedingtime                      */ maxinactiveseedingtime
            , /* maxratio                                    */ maxratio
            , /* maxseedingtime                              */ maxseedingtime
            , /* "name"                                      */ "name"
            , /* numcomplete                                 */ numcomplete
            , /* numincomplete                               */ numincomplete
            , /* numleechs                                   */ numleechs
            , /* numseeds                                    */ numseeds
            , /* priority                                    */ priority
            , /* progress                                    */ progress
            , /* ratio                                       */ ratio
            , /* ratiolimit                                  */ ratiolimit
            , /* savepath                                    */ savepath
            , /* seedingtime                                 */ seedingtime
            , /* seedingtimelimit                            */ seedingtimelimit
            , /* seencomplete                                */ seencomplete
            , /* seqdl                                       */ seqdl
            , /* "size"                                      */ "size"
            , /* state                                       */ state
            , /* superseeding                                */ superseeding
            , /* tags                                        */ tags
            , /* timeactive                                  */ timeactive
            , /* totalsize                                   */ totalsize
            , /* tracker                                     */ tracker
            , /* trackerscount                               */ trackerscount
            , /* uplimit                                     */ uplimit
            , /* uploaded                                    */ uploaded
            , /* uploadedsession                             */ uploadedsession
            , /* upspeed                                     */ upspeed
    )                                                 
;
CREATE TABLE simplified_testing.torrents_test1 AS SELECT * FROM simplified.torrents;
CREATE TABLE simplified_testing.torrents_staged_test1 AS SELECT * FROM simplified.torrents_staged;
SELECT amountleft_original, amountleft  FROM torrents;
SELECT torrent_id, from_torrent_stage_id, addedon  FROM torrents;
SELECT column_name FROM information_schema.COLUMNS WHERE table_name = 'torrents' AND table_schema = 'simplified' AND column_name LIKE '%original';
WITH base AS (
SELECT RTRIM(column_name, LENGTH('_original')) AS column_name1, column_name AS column_name2, max(ordinal_position) over() AS last_no, ordinal_position FROM information_schema.COLUMNS WHERE table_name = 'torrents' AND table_schema = 'simplified' AND column_name LIKE '%original' ORDER BY ordinal_position
)
    SELECT '        ' || RPAD(column_name2, 30) || ' = tgt.' || column_name1 || ',' || E'\n'
        || '        ' || RPAD(column_name1, 30) || ' = src.' || column_name1 || CASE WHEN ordinal_position = last_no THEN '' ELSE ',' END AS script
FROM base;
SELECT * FROM information_schema.COLUMNS;



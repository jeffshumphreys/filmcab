SELECT COUNT(*) FROM torrents;
SELECT COUNT(*) FROM torrents_staged ts ;
TRUNCATE TABLE torrents;
MERGE INTO torrents tgt
USING 
    (SELECT new_src.*, COALESCE(new_src.name, old_tgt.name) AS src_name -- FOR joining TO deleted stuff
    , CASE WHEN new_src.name IS NULL THEN TRUE ELSE FALSE END AS tgt_now_missing                                 -- DELETED: True
    , CASE WHEN old_tgt.name IS NULL THEN TRUE ELSE FALSE END AS src_is_new                                      -- DELETED: False
    FROM torrents_staged new_src FULL JOIN torrents old_tgt ON new_src.name = old_tgt.name) src
    ON (tgt.name = src.src_name)
WHEN MATCHED AND NOT src.tgt_now_missing AND NOT src.src_is_new THEN -- Confusing, YES. It's NOT really MATCHED, since the "USING" IS bringing IN BOTH sides, past AND NEW.  So we've fake a MATCH USING the FULL JOIN, so we can deal WITH things LIKE deleted torrents IN NEW DATA, AND updating the CURRENT master WITH that status, keeping the history that these were deleted, FOR whatever reason.
    UPDATE SET
        from_torrent_stage_id          = src.torrent_staged_id,
        added_to_feed_table            = src.added_to_this_table,
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
        upspeed                        = src.upspeed,
        merge_action_taken             = 'MATCHED AND NOT src.tgt_now_missing AND NOT src.src_is_new'
WHEN MATCHED AND src.tgt_now_missing AND NOT src.src_is_new THEN -- See, these NO longer exist IN the qbittorrent app, so we keep that they were, AND UPDATE NOT WHEN they were removed FROM qbittorrent, but WHEN we detected they were removed.
    UPDATE SET found_missing_on = clock_timestamp(), -- TODO: UPDATE WITH batch timestamp AND ALSO SET a batch id
        merge_action_taken  = 'MATCHED AND src.tgt_now_missing AND NOT src.src_is_new',
        from_torrent_stage_id          = src.torrent_staged_id,
        added_to_feed_table = src.added_to_this_table
WHEN NOT MATCHED AND src.src_is_new THEN 
    INSERT
    (
          from_torrent_stage_batch_id
        , from_torrent_stage_id
        , added_to_feed_table,
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
        , merge_action_taken
    )
VALUES
    (
              /* from_torrent_stage_batch_id                 */ load_batch_id              /* not sure */
            , /* from_torrent_stage_id                       */ torrent_staged_id
            , /* added_to_feed_table                         */ added_to_this_table
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
            , /* merge_action_taken                          */ 'NOT MATCHED AND src.src_is_new'
    )        
;
CREATE TABLE simplified_testing.torrents_test1 AS SELECT * FROM simplified.torrents;
CREATE TABLE simplified_testing.torrents_staged_test1 AS SELECT * FROM simplified.torrents_staged;
SELECT name, amountleft_original, amountleft, found_missing_on, state_original, state  FROM torrents WHERE name LIKE '%Monster%' ORDER BY state, name;
SELECT merge_action_taken, COUNT(*) FROM torrents GROUP BY merge_action_taken ;
SELECT name, amountleft_original, amountleft, found_missing_on, state  FROM torrents WHERE found_missing_on IS NOT null;
SELECT torrent_id, from_torrent_stage_id, addedon  FROM torrents;
SELECT column_name FROM information_schema.COLUMNS WHERE table_name = 'torrents' AND table_schema = 'simplified' AND column_name LIKE '%original';
--
WITH base AS (
SELECT RTRIM(column_name, LENGTH('_original')) AS column_name1, column_name AS column_name2, max(ordinal_position) over() AS last_no, ordinal_position FROM information_schema.COLUMNS WHERE table_name = 'torrents' AND table_schema = 'simplified' AND column_name LIKE '%original' ORDER BY ordinal_position
)
    SELECT '        ' || RPAD(column_name2, 30) || ' = tgt.' || column_name1 || ',' || E'\n'
        || '        ' || RPAD(column_name1, 30) || ' = src.' || column_name1 || CASE WHEN ordinal_position = last_no THEN '' ELSE ',' END AS script
FROM base;
SELECT * FROM information_schema.COLUMNS;
SELECT * FROM torrents WHERE torrents.amountleft > 0 AND amountleft  <> amountleft_original ;
SELECT max(from_torrent_stage_batch_id) FROM torrents;
SELECT max(load_batch_id) FROM torrents_staged ts ;

WITH base AS (
SELECT RTRIM(column_name, LENGTH('_original')) AS column_name1, column_name AS column_name2, max(ordinal_position) over() AS last_no, ordinal_position FROM information_schema.COLUMNS WHERE table_name = 'torrents' AND table_schema = 'simplified' AND column_name LIKE '%original' 
AND column_name NOT IN ('lastactivity_original', 'seencomplete_original', 'state_original', 'timeactive_original', 'tracker_original')
ORDER BY ordinal_position
)
    SELECT 'SELECT head.*, ''' || column_name2 || ''' AS capture_attribute, t.' || column_name1 || ' AS first_capture_point_value, t.' || column_name2 || ' AS second_capture_point_value, t.' || column_name1 || ' - t.' || column_name2 || ' AS change_in_capture_point_value FROM head JOIN torrents t USING(torrent_id) ' || CASE WHEN ordinal_position = last_no THEN '' ELSE 'UNION ALL' END AS script
FROM base;

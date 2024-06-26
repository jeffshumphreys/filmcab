<#
 #    FilmCab Daily morning batch run process: Fetch what qBittorrents are still active, stalled, or stuck downloading metadata.
 #    Part 2, merge into masters and see where eta is way wrong, stuck in getting meta, stuck in stalled. Back and forth.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Manual out of run set.
 #
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #    https://github.com/andrewmolyneux/qbittorrent-powershell/blob/master/QBittorrent.psm1
 #>

 try {
    . .\_dot_include_standard_header.ps1

    DisplayTimePassed ("Starting program...")
    Add-Type -ReferencedAssemblies ("Microsoft.Powershell.Commands.Utility") -TypeDefinition @"
        using System;
        using Microsoft.PowerShell.Commands;
        public struct QbtSession
        {
            public QbtSession(Uri UriIn)
            {
                Uri = UriIn;
                Session = new WebRequestSession();
            }
            public Uri Uri;
            public WebRequestSession Session;
        }
"@

    Add-Type -TypeDefinition @"
        public enum QbtSort
        {
            Hash,     Name,        Size,      Progress,      Dlspeed,  Upspeed, Priority,
            NumSeeds, NumComplete, NumLeechs, NumIncomplete, Ratio,    Eta,     State,
            SeqDl,    FLPiecePrio, Category,  SuperSeeding,  ForceStart
        }
"@

    Add-Type -TypeDefinition @"
        public enum QbtFilter
        {
            All, Downloading, Completed, Paused, Active, Inactive
        }
"@
    Function Join-Uri(
        [Parameter(Mandatory=$true)][Uri] $Uri,
        [Parameter(Mandatory=$true)][String] $Path)
    {
        $x = New-Object System.Uri ($Uri, $Path)
        $x.AbsoluteUri
    }

    Function Get-UTF8JsonContentFromResponse(
        #[Parameter(Mandatory=$true)][Microsoft.PowerShell.Commands.HtmlWebResponseObject] $Content) { # Doesn't seem to be the exact type, so take advantage of flexible typing.
        [Parameter(Mandatory=$true)] $Content) {
        # qBittorrent returns UTF-8 encoded results, but doesn't specify charset=UTF-8 in the Content-Type response header.
        # Technically, because the Content-Type is application/json the default should be UTF-8 anyway. Apparently Invoke-WebRequest doesn't know this.
        $Buffer = New-Object byte[] $Response.RawContentLength
        $Response.RawContentStream.Read($Buffer, 0, $Response.RawContentLength) | Out-Null
        $Decoded = [System.Text.Encoding]::UTF8.GetString($Buffer)
        $Decoded | ConvertFrom-Json
    }

    Function ConvertTo-QbittorrentName(
        [Parameter(Mandatory=$true)] [String] $PowerShellName) {
        # Remember the first character.
        $FirstCharacter = $PowerShellName[0]
        # Split on capital letters.
        $Chunks = $PowerShellName.Substring(1) -csplit "([A-Z])"
        # Join it all back together with the capital letters prefixed with underscores.
        $Result = $FirstCharacter
        foreach ($Chunk in $Chunks) {
            if ($Chunk.Length -eq 1) {
                $Result += "_$Chunk"
            } else {
                $Result += $Chunk
            }
        }
        $Result.ToLowerInvariant()
    }
    Function ConvertTo-PowerShellName(
        [Parameter(Mandatory=$true)] [String] $QbtName) {
        # Split on underscores.
        $Words = $QbtName -split "_"
        # If the first character of each word is a letter, make it capital.
        $CapitalisedWords = $Words | ForEach-Object { $_.Substring(0,1).ToUpperInvariant() + $_.Substring(1) }
        # Join it all back together without the underscores.
        $CapitalisedWords -join ""
    }

    Function ConvertTo-TorrentObjects(
        [Parameter(Mandatory=$true)][PSObject] $Array) {
        foreach ($Object in $Array) {
            $NewObject = New-Object PSObject
            $NewObject.PSObject.TypeNames.Insert(0, 'Qbt.Torrent')
            $Object.PSObject.Properties | ForEach-Object {
                $Value = $_.Value
                if ($_.Name -in ("added_on","completion_on","last_activity","seen_complete")) { # ratio, num_seeds, num_leeches, state, tags, time_active, total_size, tracker, upspeed, magnet_uri, name, save_path, hash, eta, download_path, content_path
                    $Value = ConvertFrom-Timestamp $Value
                }
                $NewObject | Add-Member -NotePropertyName (ConvertTo-PowerShellName $_.Name) -NotePropertyValue $Value
            }
            Write-Output $NewObject
        }
    }
    Function ConvertTo-TorrentProperties(
        [Parameter(Mandatory=$true)][PSObject] $Array) {
        foreach ($Object in $Array) {
            $NewObject = New-Object PSObject
            $NewObject.PSObject.TypeNames.Insert(0, 'Qbt.TorrentProperties')
            $Object.PSObject.Properties | ForEach-Object {
                $Value = $_.Value
                if ($_.Name -in ("addition_date","completion_date","creation_date","last_seen")) {
                    $Value = ConvertFrom-Timestamp $Value
                }
                $NewObject | Add-Member -NotePropertyName (ConvertTo-PowerShellName $_.Name) -NotePropertyValue $Value
            }
            Write-Output $NewObject
        }
    }

    Function Get-QbtTorrentProperty(
        [Parameter(Mandatory=$true)][QbtSession] $Session,
        [Parameter(Mandatory=$true)][String] $Hash) {
        $Uri = Join-Uri $Session.Uri "query/propertiesGeneral/$Hash"
        $Response = Invoke-WebRequest $Uri -WebSession $Session.Session
        ConvertTo-TorrentProperties (Get-UTF8JsonContentFromResponse $Response)
    }
    Function ConvertFrom-Timestamp(
        [Parameter(Mandatory=$true)][Object] $Timestamp) {
        if ($Timestamp -eq -1 -or $Timestamp -eq [Uint32]::MaxValue) {
            [DateTime]::MinValue
        } else {
            (Get-Date "1970-01-01T00:00:00").AddSeconds($Timestamp)
        }
    }

    Function Get-QbtTorrent(
        [Parameter(Mandatory=$true,Position=1,ParameterSetName="AnyCategory")]
        [Parameter(Mandatory=$true,Position=1,ParameterSetName="NoCategory")]
        [Parameter(Mandatory=$true,Position=1,ParameterSetName="WithCategory")]
        [QbtSession] $Session,
        [QbtFilter] $Filter,
        [Parameter(Mandatory=$true,ParameterSetName="NoCategory")]
        [Switch] $NoCategory,
        [Parameter(Mandatory=$true,ParameterSetName="WithCategory")]
        [String] $Category,
        [QbtSort] $Sort,
        [Switch] $ReverseSort,
        [Int32] $Limit,
        [Int32] $Offset) {
        $Params = @{}
        if ($Filter)      { $Params.Add("filter",   (ConvertTo-QbittorrentName $Filter.ToString())) }
        if ($Sort)        { $Params.Add("sort",     (ConvertTo-QbittorrentName $Sort.ToString())) }
        if ($Limit)       { $Params.Add("limit",    $Limit) }
        if ($Offset)      { $Params.Add("offset",   $Offset) }
        if ($NoCategory)  { $Params.Add("category", "") }
        if ($Category)    { $Params.Add("category", $Category) }
        if ($ReverseSort) { $Params.Add("reverse",  "true") }
        # https://github.com/qbittorrent/qBittorrent/wiki/WebUI-API-(qBittorrent-4.1)#get-torrent-list
        $Response = Invoke-WebRequest (Join-Uri $Session.Uri api/v2/torrents/info) -WebSession $Session.Session -Body $Params
        ConvertTo-TorrentObjects (Get-UTF8JsonContentFromResponse $Response)

    }

    $STAGE_DATA            = $true
    $MERGE_STAGE_TO_MASTER = $true
    $SPLIT_OUT_VALUE_HIST  = $true

    # TODO: RENAME to torrents_load_batch_id since it's across all torrent tables

    $torrentsStagedLoadBatchId = [Int64](Get-SqlValue("SELECT nextval('torrents_staged_load_batch_id')")) # NOTE: once fetched, even in a transaction, can't recover that number unless you reset the sequence to this number.
    # We want all items loaded in this stage and eventually merged into master, we want them all tagged with the same timestamp for traceability.
    # We keep a batch id for each staging run.  So if these gain entry into the master table, they can be said which batch they came in.  Perhaps there was some migration on qbittorrent side that caused a bunch of new names for old torrents.  We could see the bad batch.  Much like tracing back an infected batch in food systems.
    $loadBatchTimestamp        = Get-SqlTimestamp # Formatted for Sql script. Sqlized?

    if ($STAGE_DATA) {
        DisplayTimePassed ("Fetching all torrent details from API into memory...")
        $Uri      = $Script:SUPER_SECRET_SQUIRREL.super_secret_qbittorrent_webui_login_url
        $Username = $Script:SUPER_SECRET_SQUIRREL.super_secret_qbittorrent_webui_login_user
        $Password = $Script:SUPER_SECRET_SQUIRREL.super_secret_qbittorrent_webui_login_password
    
        $connectedAPISession = [QbtSession]::new($Uri)
        # https://github.com/qbittorrent/qBittorrent/wiki/WebUI-API-(qBittorrent-4.1)#login
        $Response = Invoke-WebRequest (Join-Uri $Uri api/v2/auth/login) -WebSession $connectedAPISession.Session -Method Post -Body @{username=$Username;password=$Password} -Headers @{Referer=$Uri}
        if ($Response.Content -ne "Ok." -and $Response.StatusDescription -ne "OK") {
            # <h1>JavaScript Required! You must enable JavaScript for the Web UI to work properly</h1>
            throw "Login failed: $($Response.Content)"
        }

        $torrents = Get-QbtTorrent $connectedAPISession # -Limit 2
        $Response = Invoke-WebRequest (Join-Uri $Uri api/v2/auth/logout) -WebSession $connectedAPISession.Session -Method Post  -Headers @{Referer=$Uri}

        Invoke-Sql "TRUNCATE TABLE torrents_staged"|Out-Null; # This is a staging table into "torrents".  Note that the the primary key is allowed to advance; the truncate command does not reset it to 0.  Some sort of history kept in the master table for now.

        # Build a single insert per torrent.  Better to build multi-values. Tested in the past on MS SQL Server with a 1,000 value rows at a time. Don't know if that would work on pg, but probably would.
        DisplayTimePassed ("Inserting torrent details into staging table...")
        foreach ($torrent in $torrents) {
            $Script:InsertTargetTableScript = "INSERT INTO torrents_staged (
                    load_batch_timestamp
                ,   load_batch_id
                "
            $firstRow = $true

            $torrent|gm|Where MemberType -eq 'NoteProperty'| Sort Name|%{
                $_.Definition -match "(?<typename>.*?)[ ]"|Out-Null
                $typeName = $matches['typename']
                $x = [PSCustomObject]@{
                    ColumnName     = $_.Name
                    ColumnDataType = $typeName
                }
                $prefix = ","

                if ($firstRow) {
                    $prefix   = ","
                    $firstRow = $false
                }

                $Script:InsertTargetTableScript+= "$prefix   $($x.ColumnName)
                "

                #Select @{Name='ColumnName';Expression=$_.Name}|Out-Host
            }

            $Script:insertTargetTableScript+= ")"

            #$Script:insertTargetTableScript

            $Script:InsertTargetTableScriptValues = "VALUES (
                $loadBatchTimestamp
            ,   $torrentsStagedLoadBatchId
            "
            $firstRow = $true

            $torrent.PSObject.Properties| Sort Name|%{
                $outval = $_.Value
                switch ($_.TypeNameOfValue) {
                    'System.String' { $outval = PrepForSql $outval}
                    'System.DateTime' {
                        $outvalasdate = TrimToMicroseconds $outval
                        $outval       = $outvalasdate.ToString($DEFAULT_POWERSHELL_TIMESTAMP_FORMAT)
                        $outval       = "'$outval'::TIMESTAMPTZ"
                    }
                }
                $prefix = ","
                if ($firstRow) {
                    $prefix   = ","
                    $firstRow = $false
                }

                $Script:InsertTargetTableScriptValues+= "$prefix   $outval
                "
            }
            $Script:InsertTargetTableScriptValues+= ") ON CONFLICT DO NOTHING"

            $Script:InsertTargetTableScript = $Script:InsertTargetTableScript + $Script:InsertTargetTableScriptValues
            #$Script:InsertTargetTableScript
            Invoke-Sql $Script:InsertTargetTableScript|Out-Null
            # TODO: Load properties of torrent
            # TODO: Load trackers of torrent
            # TODO: Load webseeders of torrent
        }

        DisplayTimePassed
    } else {
        Write-AllPlaces "Skipped reloading fresh list of torrent data from API into staging" -ForceStartOnNewLine
    }

    if ($MERGE_STAGE_TO_MASTER) {
        DisplayTimePassed ("Merging torrent stage into master torrents...")
        $mergeSQL = @"
        MERGE INTO torrents tgt
        USING
            (SELECT new_src.*, COALESCE(new_src.name, old_tgt.name) AS src_name -- FOR joining TO deleted stuff
            , CASE WHEN new_src.name IS NULL THEN TRUE ELSE FALSE END AS tgt_now_missing                                 -- DELETED: True
            , CASE WHEN old_tgt.name IS NULL THEN TRUE ELSE FALSE END AS src_is_new                                      -- DELETED: False
            FROM torrents_staged new_src FULL JOIN torrents old_tgt ON new_src.name = old_tgt.name) src
            ON (tgt.name = src.src_name)
    /***/
        WHEN MATCHED AND NOT src.tgt_now_missing AND NOT src.src_is_new THEN -- Confusing, yes. It's NOT really MATCHED, since the "USING" IS bringing IN BOTH sides, original AND new.  So we've fake a MATCH USING the FULL JOIN, so we can deal WITH things LIKE deleted torrents IN NEW DATA, AND updating the CURRENT master WITH that status, keeping the history that these were deleted, FOR whatever reason.
            UPDATE SET
                from_torrent_staged_id                   = src.torrent_staged_id,
                from_torrent_staged_load_batch_id        = src.load_batch_id,
                from_torrent_staged_load_batch_timestamp = src.load_batch_timestamp,
                original_load_batch_id                   = tgt.load_batch_id,
                load_batch_id                            = $torrentsStagedLoadBatchId,
                original_load_batch_timestamp            = tgt.load_batch_timestamp,
                load_batch_timestamp                     = $loadBatchTimestamp,
                added_to_feed_table                      = src.added_to_this_table,
                amountleft_original                      = tgt.amountleft,
                amountleft                               = src.amountleft,
                availability_original                    = tgt.availability,
                availability                             = src.availability,
                downloaded_original                      = tgt.downloaded,
                downloaded                               = src.downloaded,
                eta_original                             = tgt.eta,
                eta                                      = src.eta,
                lastactivity_original                    = tgt.lastactivity,
                lastactivity                             = src.lastactivity,
                numcomplete_original                     = tgt.numcomplete,
                numcomplete                              = src.numcomplete,
                numincomplete_original                   = tgt.numincomplete,
                numincomplete                            = src.numincomplete,
                numleechs_original                       = tgt.numleechs,
                numleechs                                = src.numleechs,
                numseeds_original                        = tgt.numseeds,
                numseeds                                 = src.numseeds,
                progress_original                        = tgt.progress,
                progress                                 = src.progress,
                ratio_original                           = tgt.ratio,
                ratio                                    = src.ratio,
                seedingtime_original                     = tgt.seedingtime,
                seedingtime                              = src.seedingtime,
                seencomplete_original                    = tgt.seencomplete,
                seencomplete                             = src.seencomplete,
                state_original                           = tgt.state,
                state                                    = src.state,
                timeactive_original                      = tgt.timeactive,
                timeactive                               = src.timeactive,
                tracker_original                         = tgt.tracker,
                tracker                                  = src.tracker,
                trackerscount_original                   = tgt.trackerscount,
                trackerscount                            = src.trackerscount,
                uploaded_original                        = tgt.uploaded,
                uploaded                                 = src.uploaded,
                uploadedsession_original                 = tgt.uploadedsession,
                uploadedsession                          = src.uploadedsession,
                upspeed_original                         = tgt.upspeed,
                upspeed                                  = src.upspeed,
                merge_action_taken                       = 'MATCHED AND NOT src.tgt_now_missing AND NOT src.src_is_new'
    /**/
        WHEN MATCHED AND src.tgt_now_missing AND NOT src.src_is_new THEN -- See, these no longer exist in the qbittorrent app, so we keep that they were, AND UPDATE NOT WHEN they were removed FROM qbittorrent, but WHEN we detected they were removed.
            UPDATE SET
                found_missing_on                         = clock_timestamp(),
                merge_action_taken                       = 'MATCHED AND src.tgt_now_missing AND NOT src.src_is_new',
                original_load_batch_id                   = tgt.load_batch_id,
                load_batch_id                            = $torrentsStagedLoadBatchId,
                original_load_batch_timestamp            = tgt.load_batch_timestamp,
                load_batch_timestamp                     = $loadBatchTimestamp                                        /* Confusing name, but I don't want an menagerie of created and updated fields. */
            /* There is no src, so don't try to pull anything from there into target */
    /**/
        WHEN NOT MATCHED AND src.src_is_new THEN
            INSERT
            (
                from_torrent_staged_load_batch_id
            ,   from_torrent_staged_load_batch_timestamp
            ,   from_torrent_staged_id
            ,   added_to_feed_table                                           /* The difference between feed and master gives us rate on other difference. How much amountleft shifted per second, etc. */
            ,   original_load_batch_timestamp
            ,   load_batch_timestamp                                          /* from script */
            ,   original_load_batch_id
            ,   load_batch_id                                                 /* from script */
            ,   addedon
            ,   amountleft
            ,   autotmm
            ,   availability
            ,   category
            ,   completed
            ,   completionon
            ,   contentpath
            ,   dllimit
            ,   dlspeed
            ,   downloaded
            ,   downloadedsession
            ,   downloadpath
            ,   eta
            ,   flpieceprio
            ,   forcestart
            ,   hash
            ,   inactiveseedingtimelimit
            ,   infohashv1
            ,   infohashv2
            ,   lastactivity
            ,   magneturi
            ,   maxinactiveseedingtime
            ,   maxratio
            ,   maxseedingtime
            ,   "name"
            ,   numcomplete
            ,   numincomplete
            ,   numleechs
            ,   numseeds
            ,   priority
            ,   progress
            ,   ratio
            ,   ratiolimit
            ,   savepath
            ,   seedingtime
            ,   seedingtimelimit
            ,   seencomplete
            ,   seqdl
            ,   "size"
            ,   state
            ,   superseeding
            ,   tags
            ,   timeactive
            ,   totalsize
            ,   tracker
            ,   trackerscount
            ,   uplimit
            ,   uploaded
            ,   uploadedsession
            ,   upspeed
            ,   merge_action_taken
            )
        VALUES (
            /* from_torrent_staged_load_batch_id           */ load_batch_id
        ,   /* from_torrent_staged_load_batch_timestamp    */ load_batch_timestamp
        ,   /* from_torrent_staged_id                      */ torrent_staged_id
        ,   /* added_to_feed_table                         */ added_to_this_table
        ,   /* original_load_batch_timestamp               */ '1970-01-01 07:00:00.000 -0700'::TIMESTAMPTZ
        ,   /* load_batch_timestamp                        */ $loadBatchTimestamp
        ,   /* original_load_batch_id                      */ NULL
        ,   /* load_batch_id                               */ $torrentsStagedLoadBatchId
        ,   /* addedon                                     */ addedon
        ,   /* amountleft                                  */ amountleft
        ,   /* autotmm                                     */ autotmm
        ,   /* availability                                */ availability
        ,   /* category                                    */ category
        ,   /* completed                                   */ completed
        ,   /* completionon                                */ completionon
        ,   /* contentpath                                 */ contentpath
        ,   /* dllimit                                     */ dllimit
        ,   /* dlspeed                                     */ dlspeed
        ,   /* downloaded                                  */ downloaded
        ,   /* downloadedsession                           */ downloadedsession
        ,   /* downloadpath                                */ downloadpath
        ,   /* eta                                         */ eta
        ,   /* flpieceprio                                 */ flpieceprio
        ,   /* forcestart                                  */ forcestart
        ,   /* hash                                        */ hash
        ,   /* inactiveseedingtimelimit                    */ inactiveseedingtimelimit
        ,   /* infohashv1                                  */ infohashv1
        ,   /* infohashv2                                  */ infohashv2
        ,   /* lastactivity                                */ lastactivity
        ,   /* magneturi                                   */ magneturi
        ,   /* maxinactiveseedingtime                      */ maxinactiveseedingtime
        ,   /* maxratio                                    */ maxratio
        ,   /* maxseedingtime                              */ maxseedingtime
        ,   /* "name"                                      */ "name"
        ,   /* numcomplete                                 */ numcomplete
        ,   /* numincomplete                               */ numincomplete
        ,   /* numleechs                                   */ numleechs
        ,   /* numseeds                                    */ numseeds
        ,   /* priority                                    */ priority
        ,   /* progress                                    */ progress
        ,   /* ratio                                       */ ratio
        ,   /* ratiolimit                                  */ ratiolimit
        ,   /* savepath                                    */ savepath
        ,   /* seedingtime                                 */ seedingtime
        ,   /* seedingtimelimit                            */ seedingtimelimit
        ,   /* seencomplete                                */ seencomplete
        ,   /* seqdl                                       */ seqdl
        ,   /* "size"                                      */ "size"
        ,   /* state                                       */ state
        ,   /* superseeding                                */ superseeding
        ,   /* tags                                        */ tags
        ,   /* timeactive                                  */ timeactive
        ,   /* totalsize                                   */ totalsize
        ,   /* tracker                                     */ tracker
        ,   /* trackerscount                               */ trackerscount
        ,   /* uplimit                                     */ uplimit
        ,   /* uploaded                                    */ uploaded
        ,   /* uploadedsession                             */ uploadedsession
        ,   /* upspeed                                     */ upspeed
        ,   /* merge_action_taken                          */ 'NOT MATCHED AND src.src_is_new'
        )
"@
        Invoke-Sql $mergeSQL|Out-Null
        DisplayTimePassed
    } else {
        Write-AllPlaces "Skipped merge into master from staged" -ForceStartOnNewLine
    }

    if ($SPLIT_OUT_VALUE_HIST) {
        DisplayTimePassed ("Splitting out columns change into value history.")
        $hashmap = @{
        'amountleft'      = 0;
        'availability'    = 1;
        'downloaded'      = 2;
        'eta'             = 3;
        'numcomplete'     = 4;
        'numincomplete'   = 5;
        'numleechs'       = 6;
        'numseeds'        = 7;
        'progress'        = 8;
        'ratio'           = 9;
        'seedingtime'     = 10;
        'trackerscount'   = 11;
        'uploaded'        = 12;
        'uploadedsession' = 13;
        'upspeed'         = 14;
        }

        $splitOutValueHistorySQL = @"
        WITH head AS (
            SELECT
                torrent_id
            ,   original_load_batch_timestamp             AS from_capture_point  -- so the timestamp from torrents batch is FROM (flipperu)
            ,   from_torrent_staged_load_batch_timestamp  AS to_capture_point    -- and the timestamp on the staging is the TO.  confusing.
            FROM torrents t
            )
            , all_attributes AS (
                SELECT head.*, ( 0)::"char" AS capture_attribute, t.amountleft_original      AS from_capture_point_value, t.amountleft      AS to_capture_point_value FROM head JOIN torrents t USING(torrent_id) UNION ALL
                SELECT head.*, ( 1)::"char" AS capture_attribute, t.availability_original    AS from_capture_point_value, t.availability    AS to_capture_point_value FROM head JOIN torrents t USING(torrent_id) UNION ALL
                SELECT head.*, ( 2)::"char" AS capture_attribute, t.downloaded_original      AS from_capture_point_value, t.downloaded      AS to_capture_point_value FROM head JOIN torrents t USING(torrent_id) UNION ALL
                SELECT head.*, ( 3)::"char" AS capture_attribute, t.eta_original             AS from_capture_point_value, t.eta             AS to_capture_point_value FROM head JOIN torrents t USING(torrent_id) UNION ALL
                SELECT head.*, ( 4)::"char" AS capture_attribute, t.numcomplete_original     AS from_capture_point_value, t.numcomplete     AS to_capture_point_value FROM head JOIN torrents t USING(torrent_id) UNION ALL
                SELECT head.*, ( 5)::"char" AS capture_attribute, t.numincomplete_original   AS from_capture_point_value, t.numincomplete   AS to_capture_point_value FROM head JOIN torrents t USING(torrent_id) UNION ALL
                SELECT head.*, ( 6)::"char" AS capture_attribute, t.numleechs_original       AS from_capture_point_value, t.numleechs       AS to_capture_point_value FROM head JOIN torrents t USING(torrent_id) UNION ALL
                SELECT head.*, ( 7)::"char" AS capture_attribute, t.numseeds_original        AS from_capture_point_value, t.numseeds        AS to_capture_point_value FROM head JOIN torrents t USING(torrent_id) UNION ALL
                SELECT head.*, ( 8)::"char" AS capture_attribute, t.progress_original        AS from_capture_point_value, t.progress        AS to_capture_point_value FROM head JOIN torrents t USING(torrent_id) UNION ALL
                SELECT head.*, ( 9)::"char" AS capture_attribute, t.ratio_original           AS from_capture_point_value, t.ratio           AS to_capture_point_value FROM head JOIN torrents t USING(torrent_id) UNION ALL
                SELECT head.*, (10)::"char" AS capture_attribute, t.seedingtime_original     AS from_capture_point_value, t.seedingtime     AS to_capture_point_value FROM head JOIN torrents t USING(torrent_id) UNION ALL
                SELECT head.*, (11)::"char" AS capture_attribute, t.trackerscount_original   AS from_capture_point_value, t.trackerscount   AS to_capture_point_value FROM head JOIN torrents t USING(torrent_id) UNION ALL
                SELECT head.*, (12)::"char" AS capture_attribute, t.uploaded_original        AS from_capture_point_value, t.uploaded        AS to_capture_point_value FROM head JOIN torrents t USING(torrent_id) UNION ALL
                SELECT head.*, (13)::"char" AS capture_attribute, t.uploadedsession_original AS from_capture_point_value, t.uploadedsession AS to_capture_point_value FROM head JOIN torrents t USING(torrent_id) UNION ALL
                SELECT head.*, (14)::"char" AS capture_attribute, t.upspeed_original         AS from_capture_point_value, t.upspeed         AS to_capture_point_value FROM head JOIN torrents t USING(torrent_id)
            )
            INSERT INTO torrent_attributes_change
            SELECT aa.* FROM all_attributes aa LEFT JOIN torrent_attributes_change ac USING(torrent_id, from_capture_point, to_capture_point, capture_attribute)
            WHERE ac.torrent_id IS NULL;
"@

        Invoke-Sql $splitOutValueHistorySQL|Out-Null
        DisplayTimePassed
    } else {
        Write-AllPlaces "Skipped splitting master column changes into value history" -ForceStartOnNewLine
    }

    # Create a flattened table for anything ever in downloading state, with torrent names across.  Then export and view as a graph: any patterns?
    # So, for a few names, run rowa across a1,a2,a3, a4, then a graph?
    # using System.Windows.Forms.DataVisualization.Charting;
    # this.chart1.Palette = ChartColorPalette.SeaGreen;
    # this.chart1.Titles.Add("Pets");
    # for (int i = 0; i < seriesArray.Length; i++)
    # Series series = this.chart1.Series.Add(seriesArray[i]);
    # series.Points.Add(pointsArray[i]);
    # this.chart1.SaveImage("C:\\chart.png", ChartImageFormat.Png);

}
catch {
Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}
finally {
    Write-AllPlaces "Finally" -ForceStartOnNewLine
    . .\_dot_include_standard_footer.ps1
}

SET search_path = simplified, "$user", public;
DROP SCHEMA IF EXISTS simplified CASCADE;
CREATE SCHEMA IF NOT EXISTS simplified AUTHORIZATION postgres;
COMMENT ON SCHEMA simplified IS 'Absolute reduction of all the many sources that are confluing into videos and movie details.

1) named id columns. It''s prettier (purtyr)
';

-- An enum value occupies four bytes on disk.  translations from internal enum values to textual labels are in CATALOG pg_enum

CREATE TYPE video_sub_type_enum AS ENUM ('movie', 'tv movie', 'short', 'tv series', 'tv miniseries', 'tv season', 'tv episode'); 
CREATE TYPE video_edition_type_enum AS ENUM ('theatrical release', 'director''s cut', 'restored', 'censored', 'mst3k', 'rifftrax', 'svengoolie', 'despecialized');
CREATE TYPE computer_os_type_enum AS ENUM ('windows', 'linux', 'macos');
CREATE TYPE isp_service_type_enum AS ENUM ('internet', 'phone', 'tv');
CREATE TYPE isp_customer_type_enum AS ENUM ('residential', 'business');

-- Example of a domain: CREATE DOMAIN student_detail AS VARCHAR NOT NULL CHECK (value !~ '\s');BEGIN;
CREATE DOMAIN NTEXT AS TEXT NOT NULL CHECK (trim(value) != '' AND value !~ '(\r\n|\r|\n|\t)' and value not like '%  %' AND value = trim(value));
CREATE DOMAIN NNULLTEXT AS TEXT NULL CHECK ((trim(value) != '' AND value !~ '(\r\n|\r|\n|\t)' and value not like '%  %' AND value = trim(value)) OR value IS NULL);
CREATE DOMAIN WSMALLINT AS SMALLINT NULL CHECK (value > 0 OR value IS NULL);
CREATE DOMAIN WMONEY AS MONEY NULL CHECK (value::numeric > 0.00 OR value IS NULL);
CREATE DOMAIN WDECIMAL14_2 AS DECIMAL(14,2) NULL CHECK (value::numeric > 0.00 OR value IS NULL);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ROLLBACK;
--BEGIN;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE internet_service_providers(
 internet_service_provider_id   SMALLSERIAL                  NOT NULL PRIMARY KEY,
 internet_service_provider_name NTEXT UNIQUE,
 service_type                   isp_service_type_enum        NOT NULL,
 service_area                   TEXT                             NULL, -- Idaho\Caldwell
 customer_type                  isp_customer_type_enum           NULL, 
 monthly_service_price          MONEY                            NULL,
 modem_rental_price             MONEY                            NULL,
 download_speed_mbps            WSMALLINT                        NULL,
 upload_speed_mbps              WSMALLINT                        NULL,
 bundle                         NNULLTEXT                        NULL,
 bill_amount                    MONEY                            NULL
);

INSERT INTO internet_service_providers(internet_service_provider_name, service_type, service_area, customer_type) VALUES('Sparklight', 'internet', 'Idaho\Caldwell', 'business');

COMMENT ON TABLE internet_service_providers IS 'My network is on this ISP. Tada?';
COMMENT ON COLUMN internet_service_providers.bill_amount IS 'What I have on the bill recently. Not some master super helpful, just the cost I paid, so certainly not useful for multi-user.';

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS local_networks CASCADE;
CREATE TABLE local_networks(
 local_network_id                  SMALLSERIAL NOT NULL PRIMARY KEY,
 local_network_name                NTEXT,
 brand_name                        NNULLTEXT,
 product_name                      NNULLTEXT,
 device_manager_network_name       NNULLTEXT,
 wireless_overridding_network_name NNULLTEXT,
 router_mac_address                MACADDR8,
 internet_port_mac_address         MACADDR8        NULL UNIQUE NULLS NOT DISTINCT,
 wi_fi_address                     MACADDR8        NULL UNIQUE NULLS NOT DISTINCT,
 physical_address                  MACADDR8        NULL UNIQUE NULLS NOT DISTINCT,
 serves_on_ipv4                    INET            NULL, 
 internet_port_ip4                 INET            NULL,
 ssid                              NNULLTEXT       NULL,
 -- add primary_dns = 24.116.0.53
 -- secondary_dns = 24.116.2.50
 internet_service_provider_id      SMALLINT    NOT NULL REFERENCES internet_service_providers(internet_service_provider_id),
 UNIQUE (local_network_name, internet_service_provider_id)
);

INSERT INTO local_networks(
    local_network_name, 
        brand_name,
            product_name,
                device_manager_network_name, 
                    wireless_overridding_network_name,
                        router_mac_address,
                            internet_port_mac_address,
                                wi_fi_address,
                                    serves_on_ipv4, 
                                        internet_port_ip4,
                                            ssid,
                                                internet_service_provider_id) 
 VALUES(
    'NETGEAR RAX45 802.11ax Wireless Router', 
        'Netgear',
            'Nighthawk',
                'RAX45 (Gateway)', 
                    'DLINK', 
                        '28:80:88:29:96:BE',
                            '28:80:88:29:96:BF',
                                '66:A7:F5:72:01:D8',
                                    '10.0.0.1', 
                                        '184.155.21.146',
                                            'NETGEAR47',
                                                1);

COMMENT ON TABLE local_networks IS 'My NETGEAR router seems to be all my computer sees. But what is the DLINK name on the wireless?? Anybody? The Nighthawk is SSID NETGEAR47, not DLINK';
/*
 * Test:
 * INSERT INTO networks(network_name, physical_address, ipv4, internet_service_provider_id) VALUES(E'\n', 'D8-9E-F3-31-AE-3B', '10.0.0.3', 1);
 */

-- local_hub (NETGEAR,Network Infrastructure Device, NETGEAR, Inc., http://10.0.0.1:56688/Public_UPNP_gatedesc.xml, RAX45 (Gateway), Microsoft Wireless Router Module)
-- SWD\DAFUPNPPROVIDER\UUID:F24E6DD6-5D1B-A890-3C23-B07728914101
-- Class Guid: {b6a945de-134c-4279-9a66-61a63c6f0dc5}
-- Association Endpoint address: 10.0.0.1
-- Model Name: NETGEAR RAX45 802.11ax Wireless Router
;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS network_adapters CASCADE;
CREATE TABLE network_adapters(
 network_adapter_id             SMALLSERIAL NOT NULL PRIMARY KEY,
 network_adapter_name           NTEXT,
 service_name                   NNULLTEXT,
 physical_address               MACADDR8        NULL UNIQUE NULLS NOT DISTINCT,
 ipv4                           INET            NULL,
 pci_bus_no                     SMALLINT        NULL,
 device_no                      SMALLINT        NULL,
 function_no                    SMALLINT        NULL,
 bus_reported_device_desc       NNULLTEXT,
 local_network_id               SMALLINT    NOT NULL REFERENCES local_networks(local_network_id),
 UNIQUE (network_adapter_name, local_network_id)
);

INSERT INTO network_adapters(
    network_adapter_name, 
        service_name, 
            physical_address,
                ipv4, 
                    pci_bus_no,
                        device_no,
                            function_no, 
                                bus_reported_device_desc,
                                    local_network_id) 
VALUES(
    'Intel(R) Ethernet Connection (2) I219-LM', 
        'e1dexpress',
            'D8-9E-F3-31-AE-3B',
                '10.0.0.3',
                    0,
                        31,
                            6,
                                'Ethernet Controller',
                                    1);

COMMENT ON TABLE network_adapters IS 'Is a network adapter a physical thing or is it the Windows driver?  I can''t tell.';
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS computers CASCADE;
CREATE TABLE computers(
 computer_id                    SMALLSERIAL             NOT NULL PRIMARY KEY,
 computer_name                  NTEXT,
 computer_os_type               computer_os_type_enum   NOT NULL,
 os_version_tag                 NNULLTEXT,
 ram_gb                         WSMALLINT,
 device_guid                    UUID                    NULL UNIQUE NULLS NOT DISTINCT,
 cpu_description                NNULLTEXT,
 -- bus speed, nvnm drives
 network_id                     INTEGER                 NOT NULL REFERENCES network_adapters(network_adapter_id),
 UNIQUE (computer_name, network_id)
);

INSERT INTO computers(
    computer_name, 
        computer_os_type,
            ram_gb,
                device_guid,
                    cpu_description,
                        network_id) 
VALUES(
    'DSKTP-HOME-JEFF', 
        'windows',
            64,
                '157F9957-5162-4284-8DBD-13C473445104',
                    'Processor Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz, 3600 Mhz, 4 Core(s), 8 Logical Processor(s)',
                        1);                                                                                                

COMMENT ON TABLE computers IS 'machines! hosts! What these files sit on, so that when inevitably my computer goes boom, and these drives end up somewhere else, spread over networks, in a dust pile.';

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS volumes;
CREATE TABLE volumes(
 volume_id                      SMALLSERIAL             NOT NULL PRIMARY KEY,
 volume_name                    NTEXT,
 drive_letter                   "char"                      NULL, -- internal single byte TYPE. NULL IF linux computer.
 drive_model                    NNULLTEXT,
 is_fixed                       BOOLEAN,
 is_ssd                         BOOLEAN,
 is_nvme                        BOOLEAN,
 is_os                          BOOLEAN,
 size_gb                        WDECIMAL14_2,
 volume_serial_no               BYTEA,
 seq1m_q8t1_read                WSMALLINT,
 computer_id                    SMALLINT                NOT NULL REFERENCES computers(computer_id),
 UNIQUE NULLS NOT DISTINCT (drive_letter, computer_id),
 UNIQUE NULLS NOT DISTINCT (volume_name, computer_id)
);

COMMENT ON TABLE volumes IS 'drives on Windows, mount points on linux. Unless it''s a NAS in which case it is a computer.';

INSERT INTO volumes(volume_name, drive_letter, is_fixed, is_ssd, is_nvme, is_os, size_gb, drive_model, computer_id) 
 VALUES('Boot NVMe 1 TB'                  , 'C', TRUE, TRUE,   TRUE,  TRUE,      953.27, 'KXG50ZNV1T02 NVMe TOSHIBA 1024GB', 1),
       ('WD UltraStr 16 TB Int 3.5'       , 'D', TRUE, FALSE,  FALSE, FALSE, 1455000.00, 'WDC WUH721816ALE6L4'             , 1),
       ('Smsng 860 EVO 4 TB Int 2.5'      , 'E', TRUE, FALSE,  TRUE,  FALSE,  364000.00, 'Samsung SSD 860 EVO 4TB'         , 1),
       ('WD Elements 5 TB Ext'            , 'F', FALSE, FALSE, FALSE, FALSE,  455000.00, 'WDC WD50NDZ@-11BCSS0'            , 1),
       ('WD Elements 22 TB Ext'           , 'G', FALSE, FALSE, FALSE, FALSE, 2001000.00, 'WDC WD22EDGZ-11B9PA0'            , 1),
       ('Seagate Bkp+Hub SCSI 5.5 TB Ext' , 'I', FALSE, FALSE, FALSE, FALSE,  546000.00, 'ST6000DM003-2CY186'              , 1),
       ('HD Elements 11 TB Ext'           , 'N', FALSE, FALSE, FALSE, FALSE, 1091000.00, 'WDC WD120EMFZ-11A6JA0'           , 1),
       ('WD easystore 7.5 TB Ext'         , 'O', FALSE, FALSE, FALSE, FALSE,  728000.00, 'WDC WD80EFAX-68LHPN0'            , 1)
       ;                        

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE directories(
 directory_hash               BYTEA                     NOT NULL PRIMARY KEY,
 directory_path               NTEXT,
 parent_directory_hash        BYTEA                         NULL,
 volume_id                    SMALLINT                  NOT NULL REFERENCES volumes(volume_id),
 UNIQUE(directory_path, volume_id)
);

COMMENT ON TABLE  directories IS 'Useful to avoid rescanning folders if nothing changed (datestamp managed by file system). Also useful for compressing the files table. If I make this self referential then this table shrinks too. smaller = faster reading, smaller memory, etc. Good for slow-drive systems like mine.';
COMMENT ON COLUMN directories.directory_hash IS 'Again: Hash or surrogate? If hash then it should include some local drive info? Cause same path on different drive would be a problem?? Or leave drive id or letter off, and then migration to a new drive or system and the hash would remap. Hmmmmmmmmm.';
COMMENT ON COLUMN directories.directory_path IS 'The path on the drive because we want to generate a hash on the path, not just the current folder. Should we separate the drive letter or mount point out? So as to make it more migratable?';
COMMENT ON COLUMN directories.parent_directory_hash IS 'We have to support a null here, since the top of the hierarchy. We could make a non-value, but then a self-FK wouldn''t work.';
COMMENT ON COLUMN directories.volume_id IS 'Not a hash here, since who knows what a hash for a volume or drive letter would be. Really thinking-over, paralysis analysis, buttt, moving stuff like qbittorrent''s database is nigh impossible to a new computer, so thinking.';

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE video_files(
 file_hash                    BYTEA                     NOT NULL PRIMARY KEY,
 sourced_directory_hash       BYTEA                     NOT NULL, -- FK
 sourced_file_name            TEXT                      NOT NULL,
 file_size                    BIGINT                    NOT NULL,
 file_date                    TIMESTAMPTZ               NOT NULL
);

COMMENT ON TABLE  video_files IS 'by hash! Because this is the record of what we have, and therefore we will have a unique hash. Other copies we have, well, that will have to be another table if at all. I only want ever one copy of a thing, and know where it is, and have symbolic links here and there to it. If I delete a file, or lose a drive, tis gone until I can restore it.';
COMMENT ON COLUMN video_files.file_hash IS 'md5 off the files contents. slow, so do it as little as possible.';
COMMENT ON COLUMN video_files.sourced_directory_hash IS 'Could be null if we lost the file, I suppose. or the underlying drive.';
COMMENT ON COLUMN video_files.sourced_file_name IS 'This in most cases is the torrent name, a wealth of detail in an attempt by the piraters to avoid collision on the leechers'' drives. A folder works too, though. I haven''t seen any collisions. But by keeping this name we hopefully reduce re-downloads. qbittorrent recognizes these, or the magnet link internally, but if I lose all the qbittorrent metadata, then I have no way to block redownloads.';

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE videos(
 video_id                       SERIAL                  NOT NULL CONSTRAINT pk_videos PRIMARY KEY,
 primary_title                  TEXT                    NOT NULL,
 release_year                   SMALLINT                    NULL, -- Pweeze try TO fill this IN.
 is_episodic                    BOOLEAN                 NOT NULL DEFAULT false,
 title_is_descriptive           BOOLEAN                     NULL DEFAULT false,
 video_edition_type             VIDEO_EDITION_TYPE_ENUM NOT NULL, 
 video_sub_type                 VIDEO_SUB_TYPE_ENUM         NULL,
 is_adult                       BOOLEAN                     NULL,
 runtime                        SMALLINT                    NULL,
 imdb_id                        INTEGER                     NULL CONSTRAINT ak_videos_imdb UNIQUE NULLS NOT DISTINCT,
 tmdb_id                        INTEGER                     NULL CONSTRAINT ak_videos_hash UNIQUE NULLS NOT DISTINCT,
 tmdb_id_no_longer_available    BOOLEAN                     NULL,
 omdb_id                        INTEGER                     NULL UNIQUE NULLS NOT DISTINCT,
 parent_video_id                INTEGER                     NULL,
 parent_title                   TEXT                        NULL,
 parent_imdb_id                 INTEGER                     NULL,
 season_no                      SMALLINT                    NULL,
 episode_no                     SMALLINT                    NULL,
 file_hash                      BYTEA                       NULL UNIQUE NULLS NOT DISTINCT,
 CONSTRAINT ak_videos_logical UNIQUE (primary_title, release_year, is_episodic, video_edition_type, parent_title, season_no, episode_no)
);

COMMENT ON TABLE videos IS 'all my lists: IMDB, TMDB, OMDB, and more eventually. I don''t even have OMDB yet. But I need a my id for these. IMDB, for instance, probably has the most quantity, so there will of course not be matching TMDB IDs, and so on. TMDB may have entries that are not in IMDB for some reason.
This is to be reduced from the complexities arising in receiving_dock, but I don''t want to go too simple. So what is the function? To give me a UNIQUE list of titles, whether movies, tv movies, shorts, tv shows, seasons, or episodes. BUT, since titles are not unique, we need present things that get us closer to a logical unique state. release year is one of the most meaningful additions to titles that gives a meaningful uniqueness - closer at least. The type of title, movie or tv for example, is another meaningful individuator. Why? Because collisions happen often between a tv show and a movie created because of that show, and in the same year.
No triggers, at least not just automatically tracking changes. Speed of analysis is more important.

After these key meaningful uniquifiers, what else needs to be here? Well, I put the external ids here so I can know how these came about, a way to trackback. Not a huge ton of information about what source, what table, what import session; those things bog down a table.

Major goal: Narrow this table for rapid analysis and joining work. Let views expand this out. But integers, for instance, instead of TEXT for things like the IMDB_ID. "tt4390820" as TEXT is more than double and int4. enums use less space than TEXT, so I use enums here. Metadata like record_created_date is left out. Because it has no effect on viewing, only on merges and deep etl analysis. I don''t care when I''m looking for stuff to watch, to not watch, etc. A lot of the metadata captured in stage_for_master is only relevant for making highly efficient ETLs. Here I don''t care. ';
COMMENT ON COLUMN videos.video_id IS 'A unique id regardless of external id existence. The hook on which all relies.';
COMMENT ON COLUMN videos.primary_title IS 'What is "primary" about a title? Well, according to IMDB, on https://help.imdb.com/article/contribution/titles/title-formatting/G56U5ERK7YY47CQB?ref_=helpart_nav_3#, they store and capture the ORIGINAL TITLE in its ORIGINAL LANGUAGE as it appears on screen on-the-title-card. This results in the exported watch lists getting garbage titles no one recognizes. REGARDLESS of what is displayed on your IMDB list on your browser, that is merely the localized name. Don''t expect "Godzilla" movies to export in any useful value. A tad annoying.
In TMDB, however, or fortunately, you get the U.S.A. release title. The one normal people recognize. And they have a field called "original_title" aka garbage foreign title. That I save in the "titles" table.
Oh, and FYI: Get Over It.';
COMMENT ON COLUMN videos.release_year IS 'Part of an alternate key, title+year+type. But, for example, "Godzilla" has been re-released a multitude of times, and the year separates them neatly and meaningfully. Meaningful in the sense that "Godzilla (1954)" is not ever "Godzilla (1998)". Ever. Chances are if you are remembering a movie from childhood, you''ll be able to tell which one it was by when it was released.';
COMMENT ON COLUMN videos.is_episodic IS 'Force a choice: Is it a movie or tv? Is it one thing or a series of small things that add up to a whole? TV Mini-Series are a weird thing and not like TV Series, based on the original serials, but to effectuate the KISS principal we say: is it one thing or multiple things? Forget trilogies.';
COMMENT ON COLUMN videos.title_is_descriptive IS 'Is it a title we got from somewhere, even my head, or is is a description of something I''ve seen. Must capture even if I don''t know the exact name of it. These hopefully are converted to titles, often titles already in the database. But some are probably never to be found.';
COMMENT ON COLUMN videos.video_edition_type IS 'extended, director''s cut, uncut, censored, MST3K, RiffTrax, Svengoolie, despecialized. "Star Wars" is a great example of something needing recutting after George Lucas'' Director''s cut with added CGI goobers. But each of these deserves a separate entry. Why? Because "Zach Snyder''s Justice League" cut makes more sense (to me) than the studio cut, and deserves a different rating. Also, MST3K''s spoof of "This Island Earth" is not a fair treatment of the original movie, which stands on its own as early alien invasion reflection. Plotted poorly, but still canon.';
COMMENT ON COLUMN videos.video_sub_type IS 'Not a required thing since we might not know, and we still want to track it. We HAVE to know if it''s a movie or a tv show, but is it a TV Movie, or is it just a movie I saw on TV? I may not know yet, but I want to still track it. See, I hang watch history off this table, so I need a hook to hang on even if I don''t know exactly where or what I saw. I know, weird.
But a thing I saw in memory is must be a real thing. My knowledge of what it was does not effect its existence as a thing that could be seen.';
COMMENT ON COLUMN videos.is_adult IS 'A key metric. Why do I store these at all? More of exclusionary than anything, but I have expended hours (shock!) on adult video in my youth. In a measure of what percentage of a life was expended on video, this must be counted. Is any adult video of any value? No, of course not. But it happens. An hours watching "Debbie Does Dallas" is hours not living, or watching redeeming films like Animaniacs.';
COMMENT ON COLUMN videos.runtime IS 'in minutes. When comparing IMDB and TMDB to each other, these often differ by 1 to 10 minutes. 10 minutes for some reason seems to be quite common. Are these differences significant? Perhaps but I don''t want to bloat this table with more minutia. So I''ll just pick one. We can go back to staging tables and the source if we decide these differences mean different footage.';
COMMENT ON COLUMN videos.imdb_id IS 'not always populated, certainly not initially when I just have a TMDB entry. The damn "tt_" prefix is dumped, cute as it is.';
COMMENT ON COLUMN videos.omdb_id IS 'Haven''t grabbed it yet. Not even sure it''s an INTEGER. But I know that OMDB links us to a bazillion other external data, specially wikidata, which is the hub of all links.';
COMMENT ON COLUMN videos.parent_video_id IS 'So the parent of the rifftrax spook will be the original theatrical movie. The parent for a TV episode will be either the TV Season or the TV Show. Which is dependent on the source ';
COMMENT ON COLUMN videos.parent_title IS 'This is something I pull from selfjoining back on tmdb_id or imdb_id data, and I want the ACTUAL string here so I can uniquify TV episodes. Many times episodes are not named, and I don''t want to fill in fakes to create logical uniques. I guess episode nos will make the unique key, but it''s not as pretty as unique titles.
Since I''m more a movie buff than tv buff, I put parent_title low on the view order. ';
COMMENT ON COLUMN videos.season_no IS 'Any show have more than 255 seasons? Someday, long after me. But postgres isn''t really tinyint or byte supportive. Also, I''m not sure any of my sources layer show/season/episode, most seem to just have show/episode.';
COMMENT ON COLUMN videos.episode_no IS 'A reality show could have 360 shows a year, theoretically. So SMALLINT it is.';
COMMENT ON COLUMN videos.file_hash IS 'Torn: Do we use file content hash (BYTEA[]) or the id into the files table? Either must be unique (ignoring nulls), but one is a shadow property of the real. Also, the hash is generatable from the data, whereas file_id is dependent on the tablelized representation of that data. The file disappears then we''ll still have the record of it, not sure if that''s good or bad. In a practical way, the file disappears and we won''t have anything to watch! So what''s the point of it? Also, the file disappears (drive destroyed, etc.,) then if we redownload it from some other place, the hash can relink. So I''ve reasoned my answer. hash it is. And that will link into the file table, too.
One odd problem though: We would always have a unique serial file id, even if multiple files exist with identical hashes. This happens in copying about and downloading accidentally what I think I don''t have or I think is a better version. So we need a table of files that only points to one, and its uniqueness is by the hash - no nulls allowed. In fact, it wouldn''t need a surrogate? Hmmmmmmm. As to it''s file path, that''s still needed, perhaps two paths, one to the download, one to the published.

You might ask (I did,) why not make file_hash our primary key? Because I don''t have all million movies locally. And upcoming movies, non-extant movies, these won''t have hashes. Grr.';
COMMENT ON CONSTRAINT ak_videos_logical ON videos IS 'All videos must be definable as unique based on meaningful values. In this case, nulls ARE distinct. no episode_no? Then fill it in. You cannot ignore nulls in a logical key.';
COMMENT ON CONSTRAINT ak_videos_imdb ON videos IS 'These must self-unique when present. Technically, yes there can be two TMDB films mapped to one IMDB id, or the opposite. The more external ids the more this is likely to occur - but I won''t support that in this table. In precursors yes I do keep that info. How I will reconcile a duality that is m-to-1 between sources, I have no idea. But storing multiple ids from a source as one entry is not acceptable here. It would spawn incredible complexity and generate an inability to trust that an entry is unique in realspace. It breaks the model. Without this we can treat duplicates (due to mispells, mis-entries) are errors, and fixable. Otherwise it puts our sources in doubt.';
COMMENT ON CONSTRAINT ak_videos_hash ON videos IS 'Just link to ONE entry in our new files table. That table can deal with the multiple copies, urls, paths, etc.';

END;

/*
 * Validate
 * SELECT *FROM internet_service_providers
 */
/*
 * INSERT INTO volumes (d, etc)
 * INSERT INTO directories (strip drive entry!)
 * rename files to video_files. maybe another table published_video_files?
 * INSERT INTO video_files ONLY the downloaded movies? UNIQUE hashes, too.
 * review receiving_dock data for column values that conflicted.
 */


SELECT * FROM internet_service_providers;
SELECT * FROM local_networks;
SELECT * FROM network_adapters;
SELECT * FROM computers;
SELECT * FROM volumes;
SELECT * FROM directories;
SELECT * FROM videos LIMIT 10;
SELECT * FROM video_files LIMIT 10;
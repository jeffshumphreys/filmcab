<#
 #    FilmCab Daily morning batch run process: Scan for new or updated directories in various search paths.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Prepping for addition to schedule.
 #    ###### Tue Jan 23 18:23:11 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #>
 <#
    Here's a crap example diagram of this.

    This PC (on Windows)
    - D:\                                                                   Fairly fast(?) spinning rust internal Western Digital 16 TB SATA drive.  It's a 7200 RPM drive, but it's ridiculously slow. E is twice as fast; I don't use for this project.  Ugh.
        - D:\qBittorrent Downloads\                                         Where the qBittorrent drops everything.
            - D:\qBittorrent Downloads\Video\                               "Video" is a Category defined in qBitTorrent, and is my primary focus.  Other parallel Categories are "Audio", "Print", and "Software"
                - D:\qBittorrent Downloads\Video\Movies\                    All torrents for video movies drop here. I think I include TV Movies here, too.  But all my video splits mostly "TV" or "Movies". Others like "Lectures", "Performance", "Play", "Web" aren't really used lately.  I'm not really watching broadway plays, why I downloaded them no idea.  "Web"? I suppose webcasts and webisodes are different, but isn't a webisode a TV Episode? I was hot for "Lectures" at one time. I downloaded a bazillion of these so I could get smarter without going to college - and I watched quite a few.  But that went away.
                    {media}                                                 READ ONLY!  DO NOT RENAME OR THE SEEDING WILL FAIL! Possibly repairable if you know the original name and timestamp.
                    Godzilla.Minus.One.2023.1080p.HDCAM-C1NEM4.mp4
                    Godzilla (1954) Criterion 1080p H264 Ac3 Jap Sub Ita Eng-MIRCrew.mkv
                    10 Rillington Place.avi
                    Flatland_Movie.mov
                    The Great Holocaust Trial (Ernst Zundel, Michael A. Hoffman II).mpg

                    INFO.nfo                                                Odd name likely to collide at any time. No idea what video this came from.
                    .1bd8f67866432c2af70c1180201ec0476043d96b.parts         No idea.
                    Real.Steel.BluRay.1080p.x264.5.1.Judas.srt
                    Torrent downloaded from 1337x.to.txt                    Another collision waiting to happen, and garbage

                    {folders with media}
                    [ www.Torrentday.com ] - 2081.2009.DvdRip.XviD UniversalAbsurdity\      Whaaaaaa?
                    [Classic Sci-Fi ] Atragon (1963)\

                    - D:\qBittorrent Downloads\Video\Movies\Death Race 3 Inferno 2013 UNRATED BrRip 1080p  x264 Dual-Audio [English 5.1-Hindi 5.1] NimitMak SilverRG\                Wow, this is a doozie
                        {files}
                        Cover.jpg, Poster-1.png, Poster-2.png
                        SIlverRG NFO Read it.nfo, STPicz.com Free Image Hosting.txt.txt, Torrent downloaded from SilverTorrent.org.txt, Torrent seeded from Secureboxes.net.txt 
                        Sample.mkv                                                                                                                                                   Please destroy.
                        Death Race 3 Inferno 2013 BrRip 1080p  x264 Dual-Audio [English 5.1-Hindi 5.1] NimitMak SilverRG_s.jpg                                                       Hindi??? Really?  I need this?
                        Death Race 3 Inferno 2013 UNRATED BrRip 1080p  x264 Dual-Audio [English 5.1-Hindi 5.1] NimitMak SilverRG.mkv
                        Death Race 3 Inferno 2013 UNRATED BrRip 1080p  x264 Dual-Audio [English 5.1-Hindi 5.1] NimitMak SilverRG.srt
                    
                    - D:\qBittorrent Downloads\Video\Movies\Cat.People.1942.RESTORED.1080p.BluRay.H264.AAC-RARBG\Subs
                        2_Eng.srt
                        3_Eng.srt
                    - D:\qBittorrent Downloads\Video\Movies\Blast.of.Silence.1961.(Thriller-Film.Noir).720p.x264-Classics\Subs
                        ENG.srt, FRE.srt, GER.srt, GRE.srt, ITA.srt, POR.srt, SPA.srt
                    -D:\qBittorrent Downloads\Video\Movies\Blade.I.II.III.1998-2004.The.Ultimate.Collection.1080p.Bluray.x264.anoXmous\03.Blade.Trinity.2004.1080p.BluRay.x264.anoXmous     Collections of movies

    Example of output where a file is edited and flagged for scan: 🥱 📝👓🥱 🥱 🥱

Disclaimer: I tested all of these myself on Windows 10. I could not find an authoritative source documenting all of these behaviours. It is entirely possible that I made a mistake somewhere.

The folder's last modified time is updated for these actions:

    new file or folder directly in target folder
    renamed file or folder directly in target folder
    deleted file or folder directly in target folder
    hardlink create/delete/rename - same as files
    file/folder symlink create/delete/rename
    directory junction create/delete/rename

It is not updated for these actions:

    modified contents of file directly in target folder
    edit target of symlink or junction contained in target folder
    file's or sub-folder's created/modified date changing
    edit basic attributes (hidden/archive/system) of a direct child
    NTFS compression/encryption change of a direct child
    anything at all happening in a sub-folder - literally anything
    changing attributes of the folder itself
    changing owner/ACL of the folder itself
    owner or ACL of a direct child changing
    if the folder is a directory junction, changing the target
    adding/deleting alt data streams to a direct child file
#>

try {
. .\_dot_include_standard_header.ps1

# Found example on Internet that uses a LIFOstack. Changed it to FIFO Queue would pull current search path first and possibly save a little time.

$all_file_objects = New-Object System.Collections.Queue
                                
# Footer code detects these and prints them out in a formatted way

$howManyNewDirectories           = 0
$howManyUpdatedDirectories       = 0
$howManyDirectoriesFlaggedToScan = 0
$howManyNewSymbolicLinks         = 0
$howManyNewJunctionLinks         = 0
$howManyRowsUpdated              = 0
$howManyRowsInserted             = 0

# Fetch a string array of paths to search.

$searchDirectories = WhileReadSql "SELECT search_directory, search_directory_id FROM search_directories ORDER BY search_directory_id" # All the directories across my volumes that I think have some sort of movie stuff in them.

# Search down each search path for directories that are different or missing from our data store.

While ($searchDirectories.Read()) {
                          
    #Load first level of hierarchy

    if (-not(Test-Path $search_directory)) {
        Write-AllPlaces "search_directory $search_directory not found; skipping scan." -ForceStartOnNewLine
        #TODO: Update search path.
        continue 
    }
    else {
       Write-AllPlaces "Starting search of search_directory $search_directory" -ForceStartOnNewLine
   }

    # Stuff the search root search_directory in the all_file_objects so that we can completely shortcut search search_directory if nothing's changed. Has to be a DirectoryInfo object.
    $BaseDirectoryInfoForSearchPath = Get-Item $search_directory
                      
    if (-not $BaseDirectoryInfoForSearchPath.PSIsContainer) {
        Write-AllPlaces "search_directory $search_directory is not a container; skipping scan." -ForceStartOnNewLine
    }

    $all_file_objects.Enqueue($BaseDirectoryInfoForSearchPath)
    
    Get-ChildItem -Path $search_directory -Directory | ForEach-Object { 
        $all_file_objects.Enqueue($_) 
    }
    
    # Recurse down the file hierarchy

    while($all_file_objects.Count -gt 0 -and ($on_fs_file_object = $all_file_objects.Dequeue())) {
        
        # Only directories aka Containers

        if ($on_fs_file_object.PSIsContainer) {
            $on_fs_directory                      = $on_fs_file_object.FullName
            $on_fs_directory_date                 = TrimToMicroseconds($on_fs_file_object.LastWriteTime) # Postgres cannot store past 6 decimals of milliseconds, so on Windows will always cause a mismatch since its 7.
            $on_fs_directory_is_symbolic_link     = $pretest_assuming_false
            $on_fs_directory_is_junction_link     = $pretest_assuming_false
            $on_fs_linked_directory               = NullIf($on_fs_file_object.LinkTarget)   # Probably should verify,                                             eventually
            $on_fs_driveletter                    = $on_fs_file_object.FullName[0]
            $on_fs_is_real_directory              = $pretest_assuming_false          # as in not a hard link or junction or symbolic link

            if ($on_fs_file_object.LinkType -eq 'Junction') {
                $on_fs_directory_is_junction_link = $true
                $on_fs_linked_directory           = NullIf($on_fs_file_object.LinkTarget)
                $on_fs_directory_is_symbolic_link = $false
                $on_fs_is_real_directory          = $false
            }
            elseif ($on_fs_file_object.LinkType -eq 'SymbolicLink') {
                $on_fs_directory_is_symbolic_link = $true
                $on_fs_linked_directory           = NullIf($on_fs_file_object.LinkTarget) # blanks and $nulls never equal each other.
                $on_fs_directory_is_junction_link = $false
                $on_fs_is_real_directory          = $false
            }                                    
            elseif (-not [String]::IsNullOrWhiteSpace($on_fs_file_object.LinkType)) {
                throw [Exception]"New unrecognized link type for $on_fs_directory type is $($on_fs_file_object.LinkType)"
            }
            # Note: HardLinks are for files only.
            else {       
                $on_fs_directory_is_symbolic_link = $false
                $on_fs_directory_is_junction_link = $false
                $on_fs_linked_directory           = $null
                $on_fs_is_real_directory          = $true # Only traverse real directories
            }

            $on_fs_directory_escaped        = $on_fs_directory.Replace("'", "''")
            $on_fs_parent_directory         = Split-Path -Parent $on_fs_directory
            $on_fs_parent_directory_escaped = $on_fs_parent_directory.Replace("'", "''")

            $reader = WhileReadSql "
                SELECT 
                    directory_date               AS   in_db_directory_date                  /* Feeble attempt to detect downstream changes                                                                       */
                ,   directory_is_symbolic_link   AS   in_db_directory_is_symbolic_link      /* None of these should exist since VLC and other media players don't follow symbolic links. either folders or files */
                ,   directory_is_junction_link   AS   in_db_directory_is_junction_link      /* Verified I have these. and they can help organize for better finding of films in different genre folders          */
                ,   linked_directory             AS   in_db_linked_directory                /* Verify this exists. Haven't tested.                                                                               */
                ,   directory_deleted            AS   in_db_directory_deleted
                FROM 
                    directories_ext_v
                WHERE
                    directory       = '$on_fs_directory_escaped'
                AND 
                    volume_id       = (SELECT volume_id FROM volumes WHERE drive_letter = '$on_fs_driveletter')
            "

            $foundANewDirectory    = $pretest_assuming_false
            $UpdateDirectoryRecord = $pretest_assuming_false
            $scan_directory        = $pretest_assuming_false

            # if ($reader.HasRows) {
              if ($reader.Read()) { #|Out-Null # Must read in the first row.
                $foundANewDirectory        = $false
                $UpdateDirectoryRecord     = $false
                                   
                if ($in_db_directory_deleted                                                    -or # We know the directory exists on the fs
                    $in_db_directory_date                 -ne $on_fs_directory_date             -or
                    $in_db_directory_is_symbolic_link     -ne $on_fs_directory_is_symbolic_link -or
                    $in_db_directory_is_junction_link     -ne $on_fs_directory_is_junction_link -or
                    $in_db_linked_directory               -ne $on_fs_linked_directory
                ) { 
                    $UpdateDirectoryRecord = $true
                }

                # WARNING: postgres can only store to 6 places of milliseconds. File info is stored to 7 places. So they'll never match without trimming file date to 6. Is the 6 place a rounding, though? TEST

                if ($in_db_directory_date                 -ne $on_fs_directory_date) { # if it's lower than the old date, still trigger, though that's probably a buggy touch
                    $scan_directory        = $true 
                }
            } else {
                $foundANewDirectory        = $true
                $scan_directory            = $true
            }
            $reader.Close()
            
            if ($on_fs_directory_is_junction_link) { 
                $scan_directory            = $false # Please do not traverse links. Even if the directory date changed.
            }
    
            if ($scan_directory) {$howManyDirectoriesFlaggedToScan++} # Not necessarily weren't already flagged.
            if ($on_fs_directory_is_symbolic_link -and -not $in_db_directory_is_symbolic_link) {
                $howManyNewSymbolicLinks++
            }
            if ($on_fs_directory_is_junction_link -and -not $in_db_directory_is_junction_link)  {
                $howManyNewJunctionLinks++
            }
                
            $on_fs_directory_date_formatted = $on_fs_directory_date.ToString($DEFAULT_POWERSHELL_TIMESTAMP_FORMAT)
            $on_fs_linked_directory_escaped = PrepForSql $on_fs_linked_directory

            if ($foundANewDirectory) { #even if it's a link, we store it
                $howManyNewDirectories++
                Write-AllPlaces "New Directory found: $on_fs_directory on $on_fs_driveletter drive" 

                $rowsInserted = Invoke-Sql "
                    INSERT INTO 
                        directories_v(
                            directory_hash
                        ,   directory
                        ,   parent_directory_hash
                        ,   directory_date 
                        ,   volume_id 
                        ,   scan_directory 
                        ,   directory_is_symbolic_link 
                        ,   directory_is_junction_link 
                        ,   linked_directory
                        ,   search_directory_id
                        ,   folder
                        ,   parent_folder
                        ,   grandparent_folder
                        ,   directory_deleted
                        )
                    VALUES(
                    /*     directory_hash              */     md5_hash_path('$on_fs_directory_escaped')
                    /*     directory                   */,    REPLACE('$on_fs_directory_escaped', '/', '\')
                    /*     parent_directory_hash       */,    md5_hash_path('$on_fs_parent_directory_escaped')
                    /*     directory_date              */,   '$on_fs_directory_date_formatted'::TIMESTAMPTZ
                    /*     volume_id                   */,   (SELECT volume_id FROM volumes WHERE drive_letter = '$on_fs_driveletter')
                    /*     scan_directory              */,   $scan_directory
                    /*     directory_is_symbolic_link  */,   $on_fs_directory_is_symbolic_link
                    /*     directory_is_junction_link  */,   $on_fs_directory_is_junction_link
                    /*     linked_directory            */,   $on_fs_linked_directory_escaped
                    /*     search_directory_id         */,   $search_directory_id
                    /*     folder                      */,   reverse((string_to_array(reverse('$on_fs_directory_escaped'), '\'))[1])
                    /*     parent_folder               */,   reverse((string_to_array(reverse('$on_fs_directory_escaped'), '\'))[2])
                    /*     grandparent_folder          */,   reverse((string_to_array(reverse('$on_fs_directory_escaped'), '\'))[3])
                    /*     directory_deleted           */,   False
                    )
            "
                _TICK_New_Object_Instantiated
                $howManyRowsInserted+= $rowsInserted # One, hopefully

            } elseif ($UpdateDirectoryRecord) {
                $howManyUpdatedDirectories++

                $rowsUpdated = Invoke-Sql "
                    UPDATE 
                        directories_v
                    SET
                        scan_directory             = $scan_directory
                    ,   directory_date             = '$on_fs_directory_date_formatted'::TIMESTAMPTZ
                    ,   parent_directory_hash      = md5_hash_path('$on_fs_parent_directory_escaped')
                    ,   directory_is_symbolic_link = $on_fs_directory_is_symbolic_link
                    ,   directory_is_junction_link = $on_fs_directory_is_junction_link
                    ,   linked_directory           = $on_fs_linked_directory_escaped
                    ,   volume_id                  = (SELECT volume_id FROM volumes WHERE drive_letter = '$on_fs_driveletter')
                    ,   directory_deleted          = False
                    WHERE           
                        directory_hash             = md5_hash_path('$on_fs_directory_escaped')
                "
                _TICK_Existing_Object_Edited
                if ($scan_directory) { 
                    _TICK_Scan_Objects
                } # Getting a trailing "st"
                $howManyRowsUpdated+= $rowsUpdated
            } else {
                # Not a new directory, not a changed directory date.  Note that there is currently no last_verified_directories_existence timestamp in the table, so no need to check.
                _TICK_Found_Existing_Object_But_No_Change
            }

            # By skipping the walk down the rest of this directory's children, we cut time by what: 10,000%?  Sometimes algorithms do matter.
            # Performance without skip:   2 minutes 
            # Performance with skip and no changes: 720 ms (so 60 times faster for empties)
            # DOESNT WORK !!!!! if ($on_fs_is_real_directory -and $walkdownthefilehierarchy ) { # https://stackoverflow.com/questions/1025187/rules-for-date-modified-of-folders-in-windows-explorer
            if ($on_fs_is_real_directory ) { # No way to avoid it as of Windows 10: Must traverse
                Get-ChildItem -Path $on_fs_file_object.FullName | ForEach-Object { $all_file_objects.Enqueue($_) }
            }
        }
    }
}

Write-Count howManyNewDirectories           Directory
Write-Count howManyUpdatedDirectories       Directory
Write-Count howManyRowsUpdated              Row
Write-Count howManyRowsInserted             Row
Write-Count howManyNewJunctionLinks         Link
Write-Count howManyNewSymbolicLinks         Link
Write-Count howManyDirectoriesFlaggedToScan Directory

}
catch {
    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}                                  
finally {
    Write-AllPlaces "Finally" -ForceStartOnNewLine
    . .\_dot_include_standard_footer.ps1
}
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

#>

<#

+50

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
#TODO: Don't scan directories below a directory that hasn't changed (Performance)
#TODO: Figger out what better prefixes than old and new would be. on_fs_ and in_table_?
#FIXME: It's still detecting need to scan. Not updating?? Should perhaps pull old flag and block if already set.

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()

. D:\qt_projects\filmcab\simplified\shared_code\_dot_include_standard_header.ps1

# Found example on Internet that uses a LIFOstack. Changed it to FIFO Queue would pull current search path first and possibly save a little time.

$FIFOstack = New-Object System.Collections.Queue

# Track some stats. Useful for finding bugs. For instance, kept getting 12 new junction points, the same ones. turns out the test was bad.

$howManyNewDirectories = 0
$howManyUpdatedDirectories = 0
$howManyDirectoriesFlaggedToScan = 0
$howManyNewSymbolicLinks = 0
$howManyNewJunctionLinks= 0
$hoWManyRowsUpdated = 0
$hoWManyRowsInserted = 0
$hoWManyRowsDeleted = 0

# Fetch a string array of paths to search.

$searchPathsHandle = Walk-Sql 'SELECT search_path, search_path_id FROM search_paths ORDER BY search_path_id' # All the directories across my volumes that I think have some sort of movie stuff in them.
$searchPaths = $searchPathsHandle.Value

# Search down each search path for directories that are different or missing from our data store.

while ($searchPaths.Read()) {
                          
    $SearchPath = $searchPaths.GetString(0)
    $SearchPathId = $searchPaths.GetInt32(1)
    #Load first level of hierarchy

    if (-not(Test-Path $SearchPath)) {
        Write-Host "SearchPath $SearchPath not found; skipping scan."
        #TODO: Update search path.
        return # the PS way to continue, whereas PS continue is break
    }

    # Stuff the search root SearchPath in the FIFOstack so that we can completely shortcut search SearchPath if nothing's changed. Has to be a DirectoryInfo object.
    $BaseDirectoryInfoForSearchPath = Get-Item $SearchPath
                      
    if (-not $BaseDirectoryInfoForSearchPath.PSIsContainer) {
        Write-Host "SearchPath $SearchPath is not a container; skipping scan."
    }

    $FIFOstack.Enqueue($BaseDirectoryInfoForSearchPath)
    
    Get-ChildItem -Path $SearchPath -Directory | ForEach-Object { 
        $FIFOstack.Enqueue($_) 
    }
    
    # Recurse down the file hierarchy

    while($FIFOstack.Count -gt 0 -and ($item = $FIFOstack.Dequeue())) {
        if ($item.PSIsContainer) {
            $directory_path        = $item.FullName
            $currentdirectorydate  = TrimToMicroseconds($item.LastWriteTime) # Postgres cannot store past 6 decimals of milliseconds, so on Windows will always cause a mismatch since it's 7.
            $currentsymboliclink   = [bool]$null
            $currentjunctionlink   = [bool]$null
            $currentlinktarget     = NullIf($item.LinkTarget)   # Probably should verify, eventually
            $currentdirstillexists= $true # Cuz it's there?
            $currentdriveletter    = [string]$item.FullName[0]
            $IsARealDirectory      = [bool]$null          # as in not a hard link or junction or symbolic link

            if ($item.LinkType -eq 'Junction') {
                $currentjunctionlink  = $true
                $currentlinktarget    = NullIf($item.LinkTarget)
                $currentsymboliclink  = $false
                $IsARealDirectory     = $false
            }
            elseif ($item.LinkType -eq 'SymbolicLink') {
                $currentsymboliclink  = $true
                $currentlinktarget    = NullIf($item.LinkTarget) # blanks and $nulls never equal each other.
                $currentjunctionlink  = $false
                $IsARealDirectory     = $false
            }                                    
            elseif (-not [String]::IsNullOrWhiteSpace($item.LinkType)) {
                throw [Exception]"New unrecognized link type for $directory_path, type is $($item.LinkType)"
            }
            # Note: HardLinks are for files only.
            else {       
                $currentsymboliclink  = $false
                $currentjunctionlink  = $false
                $currentlinktarget    = $null
                $IsARealDirectory     = $true # Only traverse real directories
            }

            $directory_path_escaped = $directory_path.Replace("'", "''")
            $sql = "
                SELECT 
                     directory_date                      /* Feeble attempt to detect downstream changes */
                   , is_symbolic_link                    /* None of these should exist since VLC and other media players don't follow symbolic links. either folders or files */
                   , is_junction_link                    /* Verified I have these. and they can help organize for better finding of films in different genre folders          */
                   , linked_path                         /* Verify this exists. Haven't tested.                                                                               */
                   , directory_still_exists              /* This is mostly for downstream tasks                                                                               */
                FROM 
                    directories
                WHERE
                    directory_path = '$directory_path_escaped'
                AND 
                    volume_id = (SELECT volume_id FROM volumes WHERE drive_letter = '$currentdriveletter')
            ";
            $readerHandle = (Select-Sql $sql) # Cannot return reader value directly from a function or it blanks, so return it boxed
            $reader = $readerHandle.Value # Now we can unbox!  Ta da!

            $foundANewDirectory             =  [boolean]$null
            $UpdateDirectoryRecord          =     [bool]$null
            $flagScanDirectory          =     [bool]$false
             
            $olddirectorydate               = [datetime]0     # No $nulls for datetime type.
            $oldsymboliclink            =  [boolean]$null
            $oldjunctionlink            =  [boolean]$null
            $oldlinktarget              =   [string]$null
            $olddirstillexists          =  [boolean]$null # Won't know till we query.
            $olddriveletter             =   [string]$null
            # For additional functionality later $olddirhash   [byte[]]$null

            $newdirectorydate = [datetime]0                       
            $newsymboliclink                =     [bool]$null
            $newjunctionlink            =     [bool]$null
            $newlinktarget              =   [string]$null
            $newdirstillexists=     [bool]$null
            $newdriveletter               =   [string]$null

            if ($reader.HasRows) {
                $foundANewDirectory         = $false
                $UpdateDirectoryRecord      = $false
                                   
                $olddirectorydate           = TrimToMicroseconds(Get-SqlFieldValue $readerHandle directory_date) # Just to document what's happening. PostgreSQL 15 only stores up to 6 decimal places. .NET File stamps are to 7 places. Which breaks compare. Tested it.  Cases of .0000004 exist.
                $oldsymboliclink            = Get-SqlFieldValue $readerHandle is_symbolic_link
                $oldjunctionlink            = Get-SqlFieldValue $readerHandle is_junction_link
                $oldlinktarget              = NullIf (Get-SqlFieldValue $readerHandle linked_path)
                $olddirstillexists          = Get-SqlFieldValue $readerHandle directory_still_exists
                $olddriveletter= Left $directory_path 1

                $newdirectorydate           = $currentdirectorydate
                $newsymboliclink            = $currentsymboliclink
                $newjunctionlink            = $currentjunctionlink
                $newlinktarget              = NullIf $currentlinktarget
                $newdirstillexists= $currentdirstillexists # Always true, duh
                $newdriveletter     = $currentdriveletter # Could change?? Probably impossible.

                if ($olddirstillexists    -ne $true                    -or # We know the directory exists
                    $olddirectorydate     -ne $currentdirectorydate    -or
                    $oldsymboliclink      -ne $currentsymboliclink     -or
                    $oldjunctionlink      -ne $currentjunctionlink     -or
                    $oldlinktarget        -ne $currentlinktarget       -or
                    $olddirstillexists    -ne $currentdirstillexists   -or
                    $olddriveletter       -ne $currentdriveletter      
                ) { 
                    $UpdateDirectoryRecord = $true
                }

                # WARNING: postgres can only store to 6 places of milliseconds. File info is stored to 7 places. So they'll never match without trimming file date to 6. Is the 6 place a rounding, though? TEST

                if ($olddirectorydate     -ne $newdirectorydate) { # if it's lower than the old date, still trigger, though that's probably a buggy touch
                    $flagScanDirectory     = $true 
                }
            } else {
                $foundANewDirectory        = $true
                $flagScanDirectory = $true 
            }
            $reader.Close()
            
            if ($newjunctionlink -or $currentjunctionlink) { # Possible bug: junction converted to physical SearchPath: Not scanned.
                $flagScanDirectory = $false # Please do not traverse links. Even if the directory date changed.
            }
    
            if ($flagScanDirectory) {$howManyDirectoriesFlaggedToScan++} # Not necessarily weren't already flagged.
            if ($newsymboliclink -and -not $oldsymboliclink) {
                $howManyNewSymbolicLinks++
            }
            if ($newjunctionlink -and -not $oldjunctionlink)  {
                $howManyNewJunctionLinks++
            }
                
            $formattedcurrentdirectorydate = $currentdirectorydate.ToString($DEFAULT_POWERSHELL_TIMESTAMP_FORMAT)
            $preppednewlinktarget = PrepForSql $newlinktarget

            if ($foundANewDirectory) { #even if it's a link, we store it
                $howManyNewDirectories++
                Write-Host "New Directory found: $directory_path on $currentdriveletter drive" 
                $sql = "
                    INSERT INTO 
                        directories(
                               directory_hash, 
                               directory_path, 
                               parent_directory_hash, 
                               directory_date, 
                               volume_id, 
                               directory_still_exists, 
                               scan_directory, 
                               is_symbolic_link, 
                               is_junction_link, 
                               linked_path,
                               deleted, 
                               search_path_id
                        )
                    VALUES(
                        /*     directory_hash         */  md5(REPLACE(array_to_string((string_to_array('$directory_path_escaped', '/'))[:(howmanychar('$directory_path_escaped', '/')+1)], '/'), '/', '\'))::bytea,
                        /*     directory_path         */  REPLACE('$directory_path_escaped', '/', '\'),
                        /*     parent_directory_hash  */  md5(REPLACE(array_to_string((string_to_array('$directory_path_escaped', '/'))[:(howmanychar('$directory_path_escaped', '/'))], '/'), '/', '\'))::bytea,
                        /*     directory_date         */ '$formattedcurrentdirectorydate'::TIMESTAMPTZ,
                        /*     volume_id              */ (SELECT volume_id FROM volumes WHERE drive_letter = '$currentdriveletter'),
                        /*     directory_still_exists */ $newdirstillexists,
                        /*     scan_directory         */ $flagScanDirectory,
                        /*     is_symbolic_link       */ $currentsymboliclink,
                        /*     is_junction_link       */ $currentjunctionlink,
                        /*     linked_path            */ $preppednewlinktarget,
                        /*     deleted                */  False,
                        /*     search_path_id         */ $SearchPathId
                    )
                "

                $rowsInserted = Invoke-Sql $sql
                Write-Host '⭐' -NoNewline
                $hoWManyRowsInserted+= $rowsInserted

            } elseif ($UpdateDirectoryRecord) {
                $howManyUpdatedDirectories++
                $sql = "
                    UPDATE 
                        directories
                    SET
                        scan_directory         = $flagScanDirectory,
                        directory_date         ='$formattedcurrentdirectorydate'::TIMESTAMPTZ,
                        is_symbolic_link       = $newsymboliclink,
                        is_junction_link       = $newjunctionlink,
                        linked_path  = $preppednewlinktarget,
                        directory_still_exists = $newdirstillexists,
                        volume_id              = (SELECT volume_id FROM volumes WHERE drive_letter = '$newdriveletter'),
                        deleted                =  False
                    WHERE 
                        directory_hash         = md5(REPLACE(array_to_string((string_to_array('$directory_path_escaped', '/'))[:(howmanychar('$directory_path_escaped', '/')+1)], '/'), '/', '\'))::bytea"

                $rowsUpdated = Invoke-Sql $sql
                Write-Host '📝' -NoNewline
                if ($flagScanDirectory) { write-host '👓' -NoNewLine}
                $hoWManyRowsUpdated+= $rowsUpdated
            } else {
                # Not a new directory, not a changed directory date.  Note that there is currently no last_verified_directories_existence timestamp in the table, so no need to check.
                
                #Write-Host "🥱" -NoNewline # Warning: Generates a space after. The other emojis I've tried do not.
                #$walkdownthefilehierarchy = $false (Didn't work on detection of grandparents of changed files)
            }

            # By skipping the walk down the rest of this directory's children, we cut time by what: 10,000%?  Sometimes algorithms do matter.
            # Performance without skip:   2 minutes 
            # Performance with skip and no changes: 720 ms (so 60 times faster for empties)
            # DOESNT WORK !!!!! if ($IsARealDirectory -and $walkdownthefilehierarchy ) { # https://stackoverflow.com/questions/1025187/rules-for-date-modified-of-folders-in-windows-explorer
            if ($IsARealDirectory ) { # No way to avoid it as of Windows 10: Must traverse
                Get-ChildItem -Path $item.FullName | ForEach-Object { $FIFOstack.Enqueue($_) }
            }
        }
    }
}


# Display counts. If nothing is happening in certain areas, investigate.
Write-Host # Get off the last nonewline
Write-Host
Write-Host "How many new directories were found:                      $howManyNewDirectories"           $(Format-Plural 'Directory' $howManyNewDirectories) 
Write-Host "How many old directories were updated:                    $howManyUpdatedDirectories"       $(Format-Plural 'Directory' $howManyUpdatedDirectories) 
Write-Host "How many rows were updated:                               $howManyRowsUpdated"              $(Format-Plural 'Row'       $howManyRowsUpdated) 
Write-Host "How many rows were inserted:                              $hoWManyRowsInserted"             $(Format-Plural 'Row'       $hoWManyRowsInserted) 
Write-Host "How many rows were deleted:                               $hoWManyRowsDeleted"              $(Format-Plural 'Row'       $hoWManyRowsDeleted) 
Write-Host "How many new junction linked directories were found:      $howManyNewJunctionLinks"         $(Format-Plural 'Link'      $howManyNewJunctionLinks) 
Write-Host "How many new symbolically linked directories were found:  $howManyNewSymbolicLinks"         $(Format-Plural 'Link'      $howManyNewSymbolicLinks) 
Write-Host "How many directories were flagged for scanning:           $howManyDirectoriesFlaggedToScan" $(Format-Plural 'Directory' $howManyDirectoriesFlaggedToScan) 
#TODO: Update counts to session table

# Da Fuutar!!!
. D:\qt_projects\filmcab\simplified\shared_code\_dot_include_standard_footer.ps1
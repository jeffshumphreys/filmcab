<#
    FilmCab Daily morning process: Verify SearchPaths on our specific volumes are recorded in the database.
    Status: Beginning

    Traverse every directory I know, to get new directories and capture the change timestamp of directories.  All the filesystems I know update all the way up the heirarchy when a file is deleted, created, or changed.

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



#>

#TODO: Don't scan directories below a directory that hasn't changed (Performance)
#BUG: It's still detecting need to scan. Not updating??

# Full SearchPath necessary for scheduled tasks to work? I'm not using Scheduler's working directory option since I don't know if it works

. D:\qt_projects\filmcab\simplified\_dot_include_standard_header.ps1 # 

$DEFAULT_POWERSHELL_TIMESTAMP_FORMAT = "yyyy-MM-dd HH:mm:ss.ffffff zzz"      # 2024-01-22 05:37:00.450241 -07:00    ONLY to 6 places (microseconds). Windows has 7 places, which won't match with Postgres's 6
$DEFAULT_POSTGRES_TIMESTAMP_FORMAT = "yyyy-mm-dd hh24:mi:ss.us tzh:tzm"    # 2024-01-22 05:36:46.489043 -07:00
# Method from script kidding web example to traverse directories

$stack = New-Object Collections.Stack

# All the directories across my volumes that I think have some sort of movie stuff in them.

$SearchPaths = @(
    "D:\qBittorrent Downloads\Video", 
    "O:\Video AllInOne", 
    "G:\Video AllInOne Backup", 
    "D:\qBittorrent Downloads\_torrent files", 
    "D:\qBittorrent Downloads\_finished_download_torrent_files", 
    "C:\Users\jeffs\Downloads",                                            # There's some not-movie stuff here, duh.
    "D:\qBittorrent Downloads\temp"                                        # Hmmm, what's in here
)

# Track some stats

$howManyNewDirectories = 0
$howManyUpdatedDirectories = 0
$howManyDirectoriesFlaggedToScan = 0
$howManyNewSymbolicLinks = 0
$howManyNewJunctionLinks= 0
$hoWManyRowsUpdated = 0
$hoWManyRowsInserted = 0
$hoWManyRowsDeleted = 0

foreach ($SearchPath in $SearchPaths) {
    #Load first level of hierarchy
    if (-not(Test-Path $SearchPath)) {
        Write-Host "SearchPath $SearchPath not found; skipping scan."
        return # the PS way to continue, whereas PS continue is break
    }

    # Stuff the search root SearchPath in the stack so that we can completely shortcut search SearchPath if nothing's changed. Has to be a DirectoryInfo object.
    $BaseDirectoryInfoForSearchPath = Get-Item $SearchPath
                      
    if (-not $BaseDirectoryInfoForSearchPath.PSIsContainer) {
        Write-Host "SearchPath $SearchPath is not a container; skipping scan."
    }
    $stack.Push($BaseDirectoryInfoForSearchPath)
    
    Get-ChildItem -Path $SearchPath -Directory | ForEach-Object { 
        $stack.Push($_) 
    }
    
    # Recurse down the file hierarchy

    while($stack.Count -gt 0 -and ($item = $stack.Pop())) {
        if ($item.PSIsContainer) {
            $directory_path        = $item.FullName
            $currentdriveletter    = $item.FullName[0]
            $currentsymboliclink   = [bool]$null
            $currentjunctionlink   = [bool]$null
            $currentlinktarget     = NullIf($item.LinkTarget)   # Probably should verify, eventually
            $currentdirectorydate  = TrimToMicroseconds($item.LastWriteTime) # Postgres cannot store past 3 decimals of milliseconds (Is this true, Jeff???), so on Windows will always cause a mismatch
            $isarealdirectory      = [bool]$null          # as in not a hard link or junction or symbolic link

            if ($item.LinkType -eq 'Junction') {
                $currentjunctionlink  = $true
                $currentlinktarget    = NullIf($item.LinkTarget)
                $currentsymboliclink  = $false
                $isarealdirectory     = $false
            }
            elseif ($item.LinkType -eq 'SymbolicLink') {
                $currentsymboliclink  = $true
                $currentlinktarget    = NullIf($item.LinkTarget) # blanks and $nulls never equal each other.
                $currentjunctionlink  = $false
                $isarealdirectory     = $false
            }                                    
            elseif (-not [String]::IsNullOrWhiteSpace($item.LinkType)) {
                throw [Exception]"New link type for $directory_path, type is $($item.LinkType)"
            }
            # Note: HardLinks are for files only.
            else {       
                $currentsymboliclink  = $false
                $currentjunctionlink  = $false
                $currentlinktarget    = $null
                $isarealdirectory     = $true # Only traverse real directories
            }

            $directory_path_escaped = $directory_path.Replace("'", "''")
            $sql = "
                SELECT 
                     directory_hash /* PK */
                   , directory_date
                   , is_symbolic_link
                   , is_junction_link
                   , linked_path
                   , directory_still_exists
                   , directory_path
                FROM 
                    directories
                WHERE
                    directory_path = '$directory_path_escaped'
                AND 
                    volume_id = (SELECT volume_id FROM volumes WHERE drive_letter = '$currentdriveletter')";
            $reader = (Select-Sql $sql).Value # Cannot return reader value directly from a function

            $newdir                     =  [boolean]$null
            $updatedirectoryrecord          =     [bool]$null
             
            $olddirstillexists          =  [boolean]$null # Won't know till we query.
            $oldsymboliclink            =  [boolean]$null
            $oldjunctionlink            =  [boolean]$null
            $oldlinktarget              =   [string]$null
            $olddriveletter             =   [string]$null
            $olddirectorydate               = [datetime]0     # No $nulls for datetime type.
            # For additional functionality later $olddirhash   [byte[]]$null

            $newsymboliclink                = [bool]    $null
            $newjunctionlink            = [bool]    $null
            $newlinktarget              = [string]  $null
            $flagscandirectory          = [bool]    $false

            if ($reader.HasRows) {
                $newdir                     = $false
                $updatedirectoryrecord      = $false
                                   
                try {
                $olddirstillexists          = Get-SqlFieldValue $reader directory_still_exists
                } catch {                                                                     
                    $olddirstillexists          = Get-SqlFieldValue $reader directory_still_exists
                    Write-Host $_.Exception
                }
                #For additional functionality later, $olddirhash $olddirhash = Get-SqlFieldValue $reader directory_hash
                $oldsymboliclink            = Get-SqlFieldValue $reader is_symbolic_link
                $oldjunctionlink            = Get-SqlFieldValue $reader is_junction_link
                $oldlinktarget              = Get-SqlFieldValue $reader linked_path
                $oldlinktarget = NullIf $oldlinktarget
                $olddriveletter= $directory_path.SubString(0,1)
                $olddirectorydate           = TrimToMicroseconds(Get-SqlFieldValue $reader directory_date) # Just to document what's happening. PostgreSQL 15 only stores up to 6 decimal places.

                $newsymboliclink            = $currentsymboliclink
                $newjunctionlink            = $currentjunctionlink
                $newlinktarget              = NullIf $currentlinktarget
                $newdirectorydate           = $currentdirectorydate
                
                if ($olddirstillexists    -ne $true                    -or # We know the directory exists
                    $oldsymboliclink      -ne $currentsymboliclink     -or
                    $oldjunctionlink      -ne $currentjunctionlink     -or
                    $oldlinktarget        -ne $currentlinktarget       -or
                    $olddriveletter       -ne $currentdriveletter      -or
                    $olddirectorydate     -ne $currentdirectorydate
                ) { 
                    $updatedirectoryrecord = $true
                }

                # WARNING: postgres can only store to 3 places of milliseconds. File info is stored to 7 places. So they'll never match.

                if ($olddirectorydate     -ne $currentdirectorydate) { # if it's lower than the old date, still trigger, though that's probably a buggy touch
                    $flagscandirectory     = $true 
                }
            } else {
                $newdir            = $true
                $flagscandirectory = $true 
            }
            $reader.Close()
            
            if ($null -eq $currentlinktarget) {
                $currentlinktarget = '' # Give it something to test in SQL side
            }
            if ($null -eq $newlinktarget) {
                $newlinktarget = ''
            }

            if ($newjunctionlink -or $currentjunctionlink) { # Possible bug: junction converted to physical SearchPath: Not scanned.
                $flagscandirectory = $false # Please do not traverse links. Even if the directory date changed.
            }
    
            # Do insert outside of the reader.
            if ($flagscandirectory) {$howManyDirectoriesFlaggedToScan++} # Not necessarily weren't already flagged.
            if ($newsymboliclink -and -not $oldsymboliclink) {
                $howManyNewSymbolicLinks++
            }
            if ($newjunctionlink -and -not $oldjunctionlink)  {
                $howManyNewJunctionLinks++
            }
    
            if ($newdir) { #even if it's a link, we store it
                $howManyNewDirectories++
                Write-Host "New Directory found: $directory_path on $currentdriveletter drive" 
                $formattedcurrentdirectorydate = $currentdirectorydate.ToString($DEFAULT_POWERSHELL_TIMESTAMP_FORMAT)
                $currentlinktarget = $currentlinktarget.Replace("'", "''") # Pesky apostphrs
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
                               linked_path
                        )
                    VALUES(
                        /*     directory_hash         */    md5(REPLACE(array_to_string((string_to_array('$directory_path_escaped', '/'))[:(howmanychar('$directory_path_escaped', '/')+1)], '/'), '/', '\'))::bytea,
                        /*     directory_path         */    REPLACE('$directory_path_escaped', '/', '\'),
                        /*     parent_directory_hash  */    md5(REPLACE(array_to_string((string_to_array('$directory_path_escaped', '/'))[:(howmanychar('$directory_path_escaped', '/'))], '/'), '/', '\'))::bytea,
                        /*     directory_date         */   '$formattedcurrentdirectorydate'::TIMESTAMPTZ,
                        /*     volume_id              */   (select volume_id from volumes where drive_letter  = '$currentdriveletter'),
                        /*     directory_still_exists */    True,
                        /*     scan_directory         */   $flagscandirectory,
                        /*     is_symbolic_link       */   $currentsymboliclink,
                        /*     is_junction_link       */   $currentjunctionlink,
                        /*     linked_path            */    CASE WHEN '$currentlinktarget' = '' THEN NULL ELSE '$currentlinktarget' END
                    )
                "

                $rowsInserted = Invoke-Sql $sql
                Write-Host '⭐' -NoNewline
                $hoWManyRowsInserted+= $rowsInserted

            } elseif ($updatedirectoryrecord) {
                $howManyUpdatedDirectories++
                $formattedcurrentdirectorydate = $currentdirectorydate.ToString($DEFAULT_POWERSHELL_TIMESTAMP_FORMAT)
                $newlinktarget = $newlinktarget.Replace("'", "''")
                $sql = "
                    UPDATE 
                        directories
                    SET
                        scan_directory         = $flagscandirectory,
                        directory_date         ='$formattedcurrentdirectorydate'::TIMESTAMPTZ,
                        is_symbolic_link       = $newsymboliclink,
                        is_junction_link       = $newjunctionlink,
                        linked_path  =  CASE WHEN '$newlinktarget' = '' THEN NULL ELSE '$newlinktarget' END,
                        directory_still_exists = True
                    WHERE 
                        directory_hash         = md5(REPLACE(array_to_string((string_to_array('$directory_path_escaped', '/'))[:(howmanychar('$directory_path_escaped', '/')+1)], '/'), '/', '\'))::bytea"

                $rowsUpdated = Invoke-Sql $sql
                Write-Host '📝' -NoNewline
                if ($flagscandirectory) { write-host '!' -NoNewLine}
                $hoWManyRowsUpdated+= $rowsUpdated
            } else {
                # Not a new directory, not a changed directory date.  Note that there is currently no last_verified_directories_existence timestamp in the table, so no need to check.
                Write-Host '🥱' -NoNewline
            }

            if ($isarealdirectory <# -and directory changed #>) {
                Get-ChildItem -Path $item.FullName | ForEach-Object { $stack.Push($_) }
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

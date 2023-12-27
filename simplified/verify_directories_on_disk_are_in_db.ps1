<#
    FilmCab Daily morning process: Verify paths on our specific volumes are recorded in the database.
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

. .\simplified\includes\include_filmcab_header.ps1 # local to base directory of base folder for some reason.

$stack = New-Object System.Collections.Stack

# All the directories across my volumes that I think have some sort of movie stuff in them.

$paths = @("D:\qBittorrent Downloads\Video", "O:\Video AllInOne", "G:\Video AllInOne Backup", "D:\qBittorrent Downloads\_torrent files", 
    "D:\qBittorrent Downloads\_finished_download_torrent_files", "C:\Users\jeffs\Downloads", # There's some not-movie stuff here, duh.
    "D:\qBittorrent Downloads\temp")

foreach ($path in $paths) {
    #Load first level
    Get-ChildItem -Path $startpath -Directory| ForEach-Object { $stack.Push($_) }
    #Recurse

    while($stack.Count -gt 0 -and ($item = $stack.Pop())) {
        if ($item.PSIsContainer) {
            $directory_path        = $item.FullName
            $currentdriveletter    = $item.FullName[0]
            $currentsymboliclink   = [bool]$null
            $currentjunctionlink   = [bool]$null
            $currentlinktarget     = $item.LinkTarget   # Probably should verify, eventually
            $currentdirectorydate  = $item.LastWriteTime
            $isarealdirectory      = [bool]$null          # as in, not a hard link, junction, or symbolic link

            if ($item.LinkType -eq 'Junction') {
                $currentjunctionlink  = $true
                $currentlinktarget    = $item.LinkTarget
                $currentsymboliclink  = $false
                $isarealdirectory     = $false
            }
            elseif ($item.LinkType -eq 'SymbolicLink') {
                $currentjunctionlink  = $true
                $currentlinktarget    = $item.LinkTarget
                $currentsymboliclink  = $false
                $isarealdirectory     = $false
            }
            else {
                # Only traverse real directories
                $currentsymboliclink  = $false
                $currentjunctionlink  = $false
                $currentlinktarget    = $null
                $isarealdirectory     = $true
            }

            $directory_path_escaped = $directory_path.Replace("'", "''")
            $sql = "
                SELECT directory_still_exists, is_symbolic_link, is_junction_link, linked_path, directory_date, directory_hash
                FROM simplified.directories
                WHERE directory_path = '$directory_path_escaped'
                AND volume_id = (SELECT volume_id from simplified.volumes where drive_letter = '$currentdriveletter' )";
            $sql
            $DBCmd.CommandText = $sql
            $reader = $DBCmd.ExecuteReader();
            $reader.Read() >> $null

            $newdir                     = [boolean]$null
            $updatedirectoryrecord      = [bool]$null
            
            $olddirstillexists          = [boolean]$null # Won't know till we query.
            $oldsymboliclink            = [boolean]$null
            $oldjunctionlink            = [boolean]$null
            $oldlinktarget              = [string]$null
            $olddirdriveletter          = [string]$null
            $olddirectorydate           = [datetime]0
            $olddirhash                 = [byte[]]$null

            $newsymboliclink            = [bool]$null
            $newjunctionlink            = [bool]$null
            $newlinktarget              = [string]$null
            $newdirectorydate           = [datetime]0
            $flagscandirectory          = [bool]$false

            if ($reader.HasRows) {
                $newdir                     = $false
                $updatedirectoryrecord      = $false
                $olddirstillexists          = Get-SqlValue $reader 0
                $oldsymboliclink            = Get-SqlValue $reader is_symbolic_link
                $oldjunctionlink            = Get-SqlValue $reader 2
                $oldlinktarget              = Get-SqlValue $reader 3
                $olddirectorydate           = Get-SqlValue $reader 4
                $olddirhash                 = Get-SqlValue $reader 5      # We can't exactly fetch the new id, or we don't really need it.

                #$newsymboliclink            = $currentsymboliclink
                $newjunctionlink            = $currentjunctionlink
                $newlinktarget              = $currentlinktarget
                $newdriveletter             = $currentdriveletter
                $newdirectorydate           = $currentdirectorydate
 
                if ($null -eq $olddirstillexists -or $olddirstillexists -eq $false -or # We know the directory exists
                    $oldsymboliclink -ne $currentsymboliclink -or
                    $oldjunctionlink -ne $currentjunctionlink -or
                    $currentdriveletter  -ne $olddirdriveletter -or
                    $currentdirectorydate -ne $olddirectorydate
                ) { 
                    $updatedirectoryrecord = $true
                }
                if ($currentdirectorydate -ne $olddirectorydate) # if it's lower than the old date, still trigger, though that's probably a buggy touch
                {
                    $flagscandirectory     = $true # date changes, set scan flag.
                }

                if ($currentlinktarget -ne $oldlinktarget) {
                    $updatedirectoryrecord = $true
                    if (-not ($newsymboliclink -or $newjunctionlink)) {
                        # There's no link, so if we have something stored as a link, we need to delete it
                        if ($oldlinktarget -ne '') {
                            $newlinktarget         = $null
                        }
                    }
                }
            } else {
                $newdir            = $true
                $flagscandirectory = $true
            }
            $reader.Close()
            
            # Do insert outside of the reader.
            if ($newdir) { #even if it's a link
                Write-Host "New Directory: $directory_path on $newdriveletter" 
                $formattednewdirectorydate = $newdirectorydate.ToString("yyyy-MM-dd HH:mm:ss.fff zzz")
                $sql = "
                    INSERT INTO simplified.directories(directory_hash, directory_path, parent_directory_hash, directory_date, volume_id, directory_still_exists, scan_directory, is_symbolic_link, is_junction_link, linked_directory_path)
                    VALUES(
                        /*directory_hash*/         md5(array_to_string((string_to_array(SUBSTRING('$directory_path', 1), '/'))[:(howmanychar('$directory_path', '/'))], '/'))::bytea,
                        /*directory_path*/         '$directory_path',
                        /*parent_directory_hash*/  md5(array_to_string((string_to_array(SUBSTRING('$directory_path', 1), '/'))[:(howmanychar('$directory_path', '/')-1)], '/'))::bytea,
                        /*directory_date*/         '$formattednewdirectorydate'::TIMESTAMPTZ,
                        /*volume_id*/              (select volume_id from simplified.volumes where currentdriveletter  = '$newdriveletter'),
                        /*directory_still_exists*/ True,
                        /scan_directory*/          True,
                        $newsymboliclink,
                        $newjunctionlink,
                        '$newlinktarget'
                    )
                "
                $sql
                #$DBCmd.CommandText = $sql
                #$DBCmd.ExecuteNonQuery()
            } elseif ($updatedirectoryrecord) {
                if ($newjunctionlink -or $newjunctionlink) {
                    $flagscandirectory = $false # Please do not traverse links.
                }
                $sql = "UPDATE simplified.directories
                    set scan_directory     = $flagscandirectory,
                    is_symbolic_link       = $newsymboliclink,
                    is_junction_link       = $newjunctionlink,
                    linked_directory_path  = '$newlinktarget',
                    directory_still_exists = True
                    WHERE directory_hash   = '$olddirhash'::bytea"
                $sql
                #$DBCmd.CommandText = $sql
                #$rowsupdated = $DBCmd.ExecuteNonQuery()
            }

            if ($isarealdirectory) {
                Get-ChildItem -Path $item.FullName | ForEach-Object { $stack.Push($_) }
            }
        }
    }
}



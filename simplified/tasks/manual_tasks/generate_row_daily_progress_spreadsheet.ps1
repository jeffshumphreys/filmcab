<#
 #    FilmCab Manual (but daily) update daily progress Google Sheet with progress.
 #    Status: Conception
 #    ###### Thu May 2 16:52:13 MDT 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #    D:\qt_projects\filmcab\simplified\tasks\manual_tasks\generate_row_daily_progress_spreadsheet.ps1
 #    https://github.com/AlDanial/cloc?tab=readme-ov-file#recognized-languages-
 #>

try {
. .\_dot_include_standard_header.ps1

$volumesForSearchDirectories = WhileReadSql "
    SELECT
        volume_id
    ,   drive_letter
    ,   max(tag) as tag /* download, torrenting, backup, published, wontwatch, seen */
    FROM
        search_directories_ext_v
    GROUP BY
        volume_id
    ,   drive_letter
    ORDER BY
        1
    " # All the directories across my volumes that I think have some sort of movie stuff in them.

$volumes = Get-Volume|Where DriveLetter -ne $null|
    Select DriveLetter,
        Size,
        SizeRemaining,
        FileSystemLabel,
        AllocationUnitSize,                  <# 4096 or 8192. Should be larger for these massive files? #>
        DriveType,                           <# Shows "Fixed" even for externals. Even SSDs. #>
        FileSystem                           <# FAT32 or NTFS #>

# Search down each search path for directories that are different or missing from our data store.

[Int64]$howMuchDiskSpaceLeft       = 0
[Int64]$smallestRemainingDiskSpace = 0
[Int64]$diskSpaceLeftOnPublished   = 0 # What I can have for a menu selection on MX Player unless I add another relative path?
[Int64]$diskSpaceLeftForTorrents   = 0
[Int64]$diskSpaceLeftForBackups    = 0

while ($volumesForSearchDirectories.Read()) {
    $totalSizeOfDrive      = ($volumes|Where DriveLetter -eq $drive_letter|Select Size).Size
    $spaceRemainingOnDrive = ($volumes|Where DriveLetter -eq $drive_letter|Select SizeRemaining).SizeRemaining
    if ($tag -eq 'published') {$diskSpaceLeftOnPublished+= $spaceRemainingOnDrive}
    if ($tag -eq 'torrenting') {$diskSpaceLeftForTorrents+= $spaceRemainingOnDrive}
    if ($tag -eq 'backup') {$diskSpaceLeftForBackups+= $spaceRemainingOnDrive}

    Invoke-Sql "UPDATE search_directories_v SET size_of_drive_in_bytes = $totalSizeOfDrive, space_left_on_drive_in_bytes = $spaceRemainingOnDrive WHERE volume_id = $volume_id" -OneOrMore |Out-Null # Many paths on same volume
    $howMuchDiskSpaceLeft+= $spaceRemainingOnDrive
    if (0 -eq $smallestRemainingDiskSpace -or $spaceRemainingOnDrive -lt $smallestRemainingDiskSpace) { $smallestRemainingDiskSpace = $spaceRemainingOnDrive}
}

Write-Count howMuchDiskSpaceLeft Byte

Write-AllPlaces "Total Free Disk Space across all drives (GB) $($howMuchDiskSpaceLeft/1000/1000/1000) GB"
Write-AllPlaces "Volume with Least Free Space (GB) $($smallestRemainingDiskSpace/1000/1000/1000) GB"

$JSONFiles                          = (Get-ChildItem -Filter "*.json" -Recurse | Measure-Object -line -word -character).Lines
$JSONLines                          = (Get-ChildItem -Filter "*.json" -Recurse | Get-Content | Measure-Object -line -word -character).Lines

$XMLFiles                           = (Get-ChildItem -Filter "*.xml" -Recurse | Measure-Object -line -word -character).Lines

$PowerShellFiles                          = (Get-ChildItem -Filter "*.ps1" -Recurse | Measure-Object -line -word -character).Lines
$PowerShellLines                          = (Get-ChildItem -Filter "*.ps1" -Recurse | Get-Content | Measure-Object -line -word -character).Lines
$PowerShellLinesNoBlanks                  = (Get-ChildItem -Filter "*.ps1" -Recurse | Get-Content | Measure-Object -line -word -character -IgnoreWhiteSpace).Lines
$PowerShellLinesNoBlanksOrPerfectComments = (Get-ChildItem -Filter "*.ps1" -Recurse | Get-Content |?{ !$_.startswith("#")} | Measure-Object -line -word -character -IgnoreWhiteSpace).Lines
$PowerShellWords                          = (Get-ChildItem -Filter "*.ps1" -Recurse | Get-Content | Measure-Object -line -word -character).Words
$PowerShellCharacters                     = (Get-ChildItem -Filter "*.ps1" -Recurse | Get-Content | Measure-Object -line -word -character).Characters
$PowerShellCharactersNoBlanks             = (Get-ChildItem -Filter "*.ps1" -Recurse | Get-Content | Measure-Object -line -word -character -IgnoreWhiteSpace).Characters
$SqlFiles                                 = (Get-ChildItem -Filter "*.sql" -Recurse | Measure-Object -line -word -character).Lines
$SqlLines                                 = (Get-ChildItem -Filter "*.sql" -Recurse -File| Get-Content | Measure-Object -line -word -character).Lines
$MdFiles                                  = (Get-ChildItem -Filter "*.md" -Recurse -File| Measure-Object -line -word -character).Lines
$MdLines                                  = (Get-ChildItem -Filter "*.md" -Recurse -File| Get-Content | Measure-Object -line -word -character).Lines

$TotalCountOfMeaningfulFiles = $PowerShellFiles + $SqlFiles + $MdFiles
$TotalCountOfCodeFiles       = $PowerShellFiles + $SqlFiles
$TotalCountOfMeaningfulLines = $PowerShellLines + $SqlLines + $MdLines
$TotalCountOfCodeLines       = @(dir -include *.ps1, *.sql, *.xaml -recurse -File |
Select-String "^(\s*)//" -notMatch |
Select-String "^(\s*)#" -notMatch |
Select-String "^(\s*)\-\-" -notMatch |
Select-String "^\s*/\*" -notMatch |
Select-String "^\s*/\#" -notMatch |
Select-String "^\s*\*.*(?:\*/)?\s*$" -notMatch |  <# Only captures multi-comments at top or in javadoc, since they have a leading * #>
Select-String "^\s*\*.*(?:\#/)?\s*$" -notMatch |
Select-String "^(\s*)$" -notMatch).Count

$TotalCountOfBlankLines =  @(dir -include *.ps1, *.sql, *.xaml -recurse -File | Select-String "^(\s*)$" -AllMatch).Count
$TotalCountOfCommentLines    = ($PowerShellLines - $PowerShellLinesNoBlanksOrPerfectComments) + $MdLines

$reader = WhileReadSql "
SELECT
    (SELECT count(*)            AS How_many_video_files    FROM files f JOIN file_extensions fe ON file_extension = f.final_extension AND fe.file_is_video_content)
,   (SELECT count(*)            AS How_many_files          FROM files)
,   (SELECT count(*)            AS How_many_videos_watched FROM user_spreadsheet_interface usi WHERE seen = 'y')
,   (SELECT count(*)            AS How_many_videos_have    FROM user_spreadsheet_interface usi WHERE have = 'y')
,   (SELECT sum(row_count)      AS How_many_rows_in_db     FROM (SELECT table_name, (SELECT n_live_tup FROM pg_stat_user_tables WHERE relname = table_name AND schemaname = 'simplified') AS row_count FROM information_schema. tables WHERE table_schema = 'simplified') as table_row_counts)
,   (SELECT sum(bytes_moved)    AS How_many_bytes_offlined FROM moves)
,   (SELECT sum(pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)))::bigint
                                AS How_many_bytes_in_db    FROM pg_tables where schemaname = 'simplified')
,   (SELECT count(*)            AS How_many_tables         FROM information_schema.TABLES WHERE table_schema = 'simplified' AND table_type = 'BASE TABLE')
,   (SELECT count(*)            AS How_many_views          FROM information_schema.TABLES WHERE table_schema = 'simplified' AND table_type = 'VIEW')
,   (SELECT count(*)            AS How_many_columns        FROM information_schema.COLUMNS WHERE table_schema = 'simplified')
,   (SELECT count(*)            AS How_many_enabled_tasks  FROM scheduled_tasks WHERE is_enabled)
,   (SELECT '00:' || run_duration_in_minutes::text         AS run_duration_in_minutes FROM batch_run_sessions_v brsv WHERE session_ending_script = 'zzz_end_batch_run_session.ps1' ORDER BY started DESC LIMIT 1)
" -prereadfirstrow

# TODO: WakaTime API https://wakatime.com/developers/ get  OAuth2Service or use secret API KEY
<#
Using HTTP Basic Auth pass your API Key base64 encoded in the Authorization header. Don't forget to prepend Basic to your api key after base64 encoding it.
For example, when using HTTP Basic Auth with an api key of 12345 you should add this header to your request:
Authorization: Basic MTIzNDU=
That’s because when you decode the base64 string "MTIzNDU=" you get "12345".
Alternatively, you can pass your api key as a query parameter in your request like ?api_key=XXXX.
#>


# Can cut directly from the popup and paste into Google sheet each day.

if ($true) {
    [PscustomObject] @{
        How_Many_video_files       = ($How_many_video_files).ToString()
        How_Many_files             = ($How_many_files).ToString()
        How_Many_videos_watched    = ($How_many_videos_watched).ToString()
        How_Many_videos_have       = ($How_many_videos_have).ToString()
        How_Many_rows_in_db        = ($How_many_rows_in_db).ToString()
        How_Many_bytes_offlined_GB = ($How_many_bytes_offlined/1000/1000/1000).ToString()
        How_Many_bytes_in_db_MB    = ($How_many_bytes_in_db/1000/1000).ToString()
        How_Many_tables            = ($How_Many_tables).ToString()
        How_Many_views             = ($How_Many_views).ToString()
        How_Many_columns           = ($How_Many_columns).ToString()
        How_Many_enabled_tasks     = ($How_many_enabled_tasks).ToString()
        Total_Free_Space_GB        = ($howMuchDiskSpaceLeft/1000/1000/1000).ToString()
        Smallest_Space_GB          = ($smallestRemainingDiskSpace/1000/1000/1000).ToString()
        Free_Space_in_Published_GB = ($diskSpaceLeftOnPublished/1000/1000/1000).ToString()
        How_Many_Code_Files        = $TotalCountOfCodeFiles
        How_Many_Lines_of_Code     = $TotalCountOfCodeLines
        How_Many_Comment_Lines     = $TotalCountOfCommentLines
        How_Many_Blank_Lines       = $TotalCountOfBlankLines
        run_duration_in_minutes    = $run_duration_in_minutes
    }|Select|Out-GridView
}
}
catch {
    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}
finally {
    Write-AllPlaces "Finally"
    . .\_dot_include_standard_footer.ps1
}

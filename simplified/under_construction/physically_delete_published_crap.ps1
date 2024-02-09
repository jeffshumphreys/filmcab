<#
 #    FilmCab Daily morning batch run process: There is a lot of stuff that gets downloaded with payloads. These messy the linking across batch run stages.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Conception
 #    ###### Sat Feb 3 22:20:01 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #>
 

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()

. D:\qt_projects\filmcab\simplified\shared_code\_dot_include_standard_header.ps1

# Track some stats. Useful for finding bugs. For instance, kept getting 12 new junction points, the same ones. turns out the test was bad.

$howManyPossibleCrapFiles = 0
$howManyFilesWouldHaveBeenDeleted = 0
$howManyDirectoriesFlaggedToScan = 0
$howManyNewSymbolicLinks = 0
$howManyNewJunctionLinks= 0
$hoWManyRowsUpdated = 0
$hoWManyRowsInserted = 0
$hoWManyRowsDeleted = 0

$rename_on_publish_to_parent = @(
    '3_english.srt'
)
$files_to_delete = @(
    'Torrent_downloaded_from_Demonoid.me.txt',
    'Torrent downloaded from demonoid.pw.txt',
    'Torrent downloaded from Demonoid.me.txt',   
    'Torrent downloaded from Demonoid.com.txt',
    'Torrent downloaded from Demonoid.HerrXS.txt',
    'Torrent downloaded from Demonoid - www demonoid pw .txt',
    'Torrent downloaded from Demonoid - www.demonoid.pw .txt',
    'Torrent downloaded from Demonoid - www demonoid pw.txt',
    '[TGx]Downloaded from torrentgalaxy.to .txt',
    '[TGx]Downloaded from torrentgalaxy.org .txt',
    'Torrent downloaded from KATCR.CO.txt',
    'Torrent-Downloaded-From-ExtraTorrent.cc.txt',
    'Torrent downloaded from extratorrent.cc.txt',
    'Torrent Downloaded From Torrenting.com.txt',
    'Torrent downloaded from 1337x.to.txt',
    'Torrent downloaded from AhaShare.com.txt',
    'Torrent downloaded from h33t.to.txt',
    'Torrent downloaded from kickass.to.txt',
    'Torrent downloaded from thepiratebay.se.txt',
    'How to play HEVC (THIS FILE).txt',
    'www.Torrenting.com.txt',
    'WWRG banner.jpg',
    'WWRG Read Me.txt',
    'Come join us @ PublicHD.ORG.txt',
    'www.YTS.MX.jpg',
    'YTSYifyUP... (TOR).txt',
    'WWW.YIFY-TORRENTS.COM.jpg',
    'YIFYStatus.com.txt',
    'NEW upcoming releases by Xclusive.txt',
    'Encoded by rarbg.to .txt',       
    'RARBG.txt',
    'Where I Upload.txt',
    'where I Upload.txt',
    'Encoded by JoyBell.txt',
    '! original unprocessed audio tracks AAC-LC 253Kbps',
    'aac-some-sponsors.gif',
    'DarksideRG.jpg',
    'Video AllInOne - Shortcut.lnk',
    '___xxx'
)
  
<#
    Review:
    
    Read Me.txt
    poster.jpg
    The Adventures of Sherlock Holmes (1984) TV-ep14 BDRIP 720P X264 AAC).sup
    Topper (1937).Synopsis.txt
    Starship Troopers (1997).xml
    poster.jpg
    Mantrap (1926) (no sound).mp4.tar
    4. RESIDENT EVIL - Damnation (2012 BluRay - 1080p DUAL Audio).mkv.!qB
    thehardyboysandnancydrewmysteries_archive.torrent
#>
$files_under_folders = @(
    'Sample'
)
$files_with_this_hash_to_delete = @(
    @{name='READ this before playing the Movie.txt';hash='x';size=605}
)
$files_to_keep = @(
    'spud.txt', 'Read Me.txt', 'Info.txt', '_NO_SUBTITLES.txt', 'Info.txt', 'Movies to Get.txt'
)              

$extensions_to_delete = @('par2', 'IFO', 'BUP')
# Fetch a string array of paths to search.

$rando_download_files_to_ignore = @('cs', 'ps1', 'exe', 'ini', 'htm', 'h', 'idl', 'css')

$always_ignore = @('cs', 'ps1', 'exe', 'h', 'idl')

$possibleCrapFilesHandle = Walk-Sql "
    SELECT
        file_name_with_ext,
        final_extension,
        max(directory_path) over(partition by file_name_with_ext) as example_directory_path,
        search_path_tag
    FROM 
        files_ext_v 
    WHERE 
        final_extension NOT IN('srt', 'sfv', 'mkv', 'avi', 'mp4', 'wmv', 'm4v', 'mov', 'mpeg', 'VOB', 'exe', 'sub', 'idx', 'AVI', 'zip', 'mka', 'ogv', 'flac') 
    AND 
        directly_deletable
    AND
        final_extension NOT IN('nfo')
    AND NOT 
        file_deleted
    " 
# All the directories across my volumes that I think have some sort of movie stuff in them.

$possibleCrapFiles = $possibleCrapFilesHandle.Value

# Search down each search path for directories that are different or missing from our data store.

$unique_file_names_with_ext = @()

while ($possibleCrapFiles.Read()) {
    $howManyPossibleCrapFiles++
    $file_name_with_ext = Get-SqlFieldValue $possibleCrapFilesHandle file_name_with_ext
    $final_extension = Get-SqlFieldValue $possibleCrapFilesHandle final_extension
    $example_directory_path = Get-SqlFieldValue $possibleCrapFilesHandle example_directory_path
    $search_path_tag= Get-SqlFieldValue $possibleCrapFilesHandle search_path_tag

    if ($search_path_tag -eq 'download' -and $final_extension -in $rando_download_files_to_ignore) {
        # Ignore these
    } elseif ($final_extension -in $always_ignore) {
        
    } elseif ($file_name_with_ext -in $files_to_keep) {
        # Ignore
    } elseif ($file_name_with_ext -cin $files_to_delete) {
        #Write-Host "DELETE $file_name_with_ext"
    } elseif ($final_extension -cin $extensions_to_delete) {
        #Write-Host "DELETE $file_name_with_ext"           
    } else {               
        $unique_file_names_with_ext+= $file_name_with_ext + ' (' + $example_directory_path + '?)'
        #@("Keep $file_name_with_ext", $directory_path)|Format-Table
    }
    #Load first level of hierarchy
}

Write-Host # Get off the last nonewline
Write-Host # Get off the last nonewline
Write-Host # Get off the last nonewline
Write-Host # Get off the last nonewline

$unique_file_names_with_ext|Select -Unique

# Display counts. If nothing is happening in certain areas, investigate.
Write-Host # Get off the last nonewline
Write-Host
Write-Host "How many possible crap files were found:                  " $(Format-Plural 'File'      $howManyPossibleCrapFiles -includeCount) 
Write-Host "How many files would have been deleted:                   " $(Format-Plural 'File'      $howManyFilesWouldHaveBeenDeleted -includeCount) 
Write-Host "How many rows were updated:                               " $(Format-Plural 'Row'       $howManyRowsUpdated -includeCount) 
Write-Host "How many rows were inserted:                              " $(Format-Plural 'Row'       $hoWManyRowsInserted -includeCount) 
Write-Host "How many rows were deleted:                               " $(Format-Plural 'Row'       $hoWManyRowsDeleted -includeCount) 
Write-Host "How many new junction linked directories were found:      " $(Format-Plural 'Link'      $howManyNewJunctionLinks -includeCount) 
Write-Host "How many new symbolically linked directories were found:  " $(Format-Plural 'Link'      $howManyNewSymbolicLinks -includeCount) 
Write-Host "How many directories were flagged for scanning:           " $(Format-Plural 'Directory' $howManyDirectoriesFlaggedToScan -includeCount) 
#TODO: Update counts to session table

# Da Fuutar!!!
. D:\qt_projects\filmcab\simplified\shared_code\_dot_include_standard_footer.ps1

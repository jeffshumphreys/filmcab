<#
 #    FilmCab Daily morning batch run process: Get internal id of files to detect name changes that mean no actual backup.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Concept
 #    ###### Tue Jan 23 18:23:11 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
  #>
                             
try {
. .\_dot_include_standard_header.ps1

$howManyUpdatedFiles     = 0

# Let's traverse all the undeleted directories flagged for scan. scan_for_file_directories sets the flag before this daily.

$walkThruAllFilesReader = WhileReadSql "
    SELECT 
        file_id
    ,   file_path
    ,   file_ntfs_id         AS in_db_file_ntfs_id
    FROM 
        files_ext_v
    WHERE
        NOT directory_deleted
    AND
        NOT directory_is_symbolic_link
    AND
        NOT directory_is_junction_link
    AND                      
        NOT file_deleted
    AND
        NOT file_is_symbolic_link
    AND
        NOT file_is_hard_link
"
Import-Module Get-MediaInfo
While ($walkThruAllFilesReader.Read()) {
    if ((Test-Path -LiteralPath $file_path)) {
        _TICK_Found_Existing_Object                              
        Unblock-File -LiteralPath $file_path # Remove in dumb shit "Zone.Identifier [ZoneTransfer] ZoneId=3"
        $file_streams = Get-Item -LiteralPath $file_path -Stream * -Force # 'D:\qBittorrent Downloads\Video\Movies\.14a11a46d30e99f7a47e457a4adbc349ef23f441.parts' required the Force parameter to open.
        if ($file_streams.GetType().Name -ne 'AlternateStreamData') { # Not a single record
            $file_path
            $mediainfoPreParsed = Get-MediaInfo -Path $file_path
            $mediainforParsedIntoLines = ($mediainfoPreParsed -split [System.Environment]::NewLine, [System.StringSplitOptions]"RemoveEmptyEntries")
            
            # Get the count of subtitle streams in a movie. Get-MediaInfoValue '.\The Warriors.mkv' -Kind General -Parameter 'TextCount'
            # Get the language of the second audio stream in a movie. The Index parameter is zero based. Get-MediaInfoValue '.\The Warriors.mkv' -Kind Audio -Index 1 -Parameter 'Language/String'
            #
            # To retrieve specific properties with highest possible performance the .NET class must be used directly:
            # $mi = New-Object MediaInfo -ArgumentList $Path
            #  Get-MediaInfoSummary 'D:\Samples\Downton Abbey.mkv'
            #  -Raw, -Full
        }
        # if ($null -eq $on_fs_file_ntfs_id -or $on_fs_file_ntfs_id -ne $in_db_file_ntfs_id) {
        #     _TICK_Existing_Object_Actually_Changed
        #     Invoke-Sql "UPDATE files SET file_ntfs_id = '$on_fs_file_ntfs_id'::bytea WHERE file_id = $file_id"|Out-Null
        #     $howManyUpdatedFiles++
        # }
            
        # optimizemetadata 	This performs an immediate compaction of the metadata for a given file.
        # queryoptimizemetadata 	Queries the metadata state of a file.
        # fsutil file layout $file_path    
    }
}

Write-Count howManyUpdatedFiles           File

}
catch {
    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}                                  
finally {
    Write-AllPlaces "Finally"
    . .\_dot_include_standard_footer.ps1
}
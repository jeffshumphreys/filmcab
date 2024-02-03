<#
 #    FilmCab Daily morning batch run process: Scan our updated and clean list of directories for new files.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Runs manually; prepping for lineup.
 #    ###### Tue Jan 23 18:23:11 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #
 # TODO: Pull both in as arrays and full outer join; update/insert/delete
 # Question: Should I be filtering these by the filters in search_paths?  Especially since Downloads is fraught with junk.
 #>

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()

. D:\qt_projects\filmcab\simplified\shared_code\_dot_include_standard_header.ps1

# Track some stats. Useful for finding bugs. For instance, kept getting 12 new junction points, the same ones. turns out the test was bad.

$howManyNewFiles = 0
$howManyUpdatedFiles = 0
$howManyNewSymbolicLinks = 0
$howManyNewHardLinks= 0
$hoWManyRowsUpdated = 0
$hoWManyRowsInserted = 0
$hoWManyRowsDeleted = 0

# Let's traverse all the undeleted directories flagged for scan. scan_for_file_directories sets the flag before this daily.

$loop_sql = "
SELECT 
     directory_path                      /* What we are going to search for new files     */
   , directory_hash                      /* Links back to directories table               */
   , is_symbolic_link                    /* Don't go into these?                          */
   , is_junction_link                    /* We'll still want to log things added to these */
FROM 
    directories
WHERE
    deleted is distinct from true
AND 
    scan_directory is true
";

$readerHandle = (Select-Sql $loop_sql) # Cannot return reader value directly from a function or it blanks, so return it boxed
$reader = $readerHandle.Value # Now we can unbox!  Ta da!

# Search down each search path for directories that are different or missing from our data store.

if ($reader.HasRows) {
do {
    $directory_path = $reader.GetString(0)
    $directory_path_escaped = $directory_path.Replace("'", "''")

    if ((Test-Path $directory_path)) {
        Get-ChildItem $directory_path -Force| ForEach-Object { 
            if (!$_.PSIsContainer) {      
                $on_fs_file_date = TrimToMicroseconds $_.LastWriteTime
                $file_date_formatted = $on_fs_file_date.ToString($DEFAULT_POWERSHELL_TIMESTAMP_FORMAT)
                $on_fs_file_size = $_.Length
                $file_path = $_.FullName
                $file_name_no_ext = $_.BaseName
                $file_name_no_ext_escaped = $file_name_no_ext.Replace("'", "''")
                $final_extension = ''
                try {
                    $final_extension  = $_.Extension.Substring(1)
                } catch { 
                    # Example of EXTENSIONLESS file: G:\Video AllInOne Backup\_Comedy\MST3K\S13 - The Gizmoplex\original unprocessed audio\! original unprocessed audio tracks AAC-LC 253Kbps
                    $final_extension = ''
                }
                $final_extension_escaped  = $final_extension.Replace("'", "''")                                      
                # TODO: [bool]($file.Attributes -band [IO.FileAttributes]::ReparsePoint) https://stackoverflow.com/questions/817794/find-out-whether-a-file-is-a-symbolic-link-in-powershell
                $on_fs_file_link_type = $_.LinkType
                $on_fs_file_link_target = NullIf $_.LinkTarget                    # Warning: multiple targets?? Split on `n
                $file_link_target_escaped = PrepForSql $on_fs_file_link_target
                $directory_path   = $_.Directory.FullName                        # Same same?
                $directory_path_escaped = $directory_path.Replace("'", "''")
                
                $on_fs_is_symbolic_link = $false
                $on_fs_is_hard_link = $false
                
                if ($on_fs_file_link_type -eq 'SymbolicLink') {
                    $on_fs_is_symbolic_link = $true
                }
                elseif ($on_fs_file_link_type -eq 'HardLink') {
                    $on_fs_is_hard_link  = $true
                }                                    
                elseif (-not [String]::IsNullOrWhiteSpace($on_fs_file_link_type)) {
                    throw [Exception]"New unrecognized link type for $file_path, type is $($on_fs_file_link_type)"
                }
    
                $test_sql = "
                SELECT                                                                       
                     file_hash
                   , directory_hash
                   , file_date                           /* If changed, we need a new hash        */
                   , file_size                           /* Also if changed, in case date isn't enough to detect. The garuntead way is to generate the hash, which is very slow. */
                   , is_symbolic_link                    /* None of these should exist since VLC and other media players don't follow symbolic links. either folders or files */
                   , is_hard_link                        /* Verified I have these. and they can help organize for better finding of films in different genre folders          */
                   , linked_path                         /* Verify this exists. Haven't tested.                                                                               */
                FROM 
                    files
                WHERE
                    directory_hash = md5(REPLACE(array_to_string((string_to_array('$directory_path_escaped', '/'))[:(howmanychar('$directory_path_escaped', '/')+1)], '/'), '/', '\'))::bytea
                AND
                    file_name_no_ext = '$file_name_no_ext_escaped'
                AND
                    final_extension = '$final_extension_escaped'
                ";

                if (Test-Sql $test_sql) {                    
                    # date changed?
                    # Test small amount for hash?   
                    # link type change? no longer a link?
                    # target changed?
                    # length changed?
                    # Do we need a new file hash? date, length changed?
                    $row = Out-SqlToDataset $test_sql -DontOutputToConsole -DontWriteSqlToConsole
                    $in_db_file_hash = @($row.file_hash|Format-Hex|Select ascii).Ascii -Join ''
                    $in_db_directory_hash = @($row.directory_hash|Format-Hex|Select ascii).Ascii -Join ''
                    $in_db_file_date = $row.file_date
                    $in_db_file_size = $row.file_size
                    $on_fs_broken_link    = $false
                    $new_file_hash = $null
                    
                    if ($in_db_file_date -ne $on_fs_file_date -or $in_db_file_size -ne $on_fs_file_size) {
                        Write-Host '!!' -NoNewLine
                        try {
                            $on_fs_file_hash = (Get-FileHash -LiteralPath $file_path -Algorithm MD5).Hash
                        } catch [System.IO.IOException] {
                            $on_fs_broken_link = $true
                            $on_fs_file_hash = '0'
                        }
                        $new_file_hash = @($on_fs_file_hash|Format-Hex|Select ascii).Ascii -Join ''
                    } else {
                        $new_file_hash = $in_db_file_hash
                    }                                                                               

                    $update_sql = "
                        UPDATE
                            files
                        SET
                            file_hash = '$new_file_hash'::bytea,
                            file_date = '$file_date_formatted'::TIMESTAMPTZ,
                            file_size = $on_fs_file_size,
                            is_symbolic_link  = $on_fs_is_symbolic_link,
                            is_hard_link= $on_fs_is_hard_link,
                            deleted = False,
                            broken_link     = $on_fs_broken_link
                        WHERE
                            file_hash         = '$in_db_file_hash'::bytea
                        AND
                            directory_hash    = '$in_db_directory_hash'::bytea
                        AND
                            file_name_no_ext  = '$file_name_no_ext_escaped' /* Found case where two files same directory had same hash different name */
                        AND
                            final_extension   = '$final_extension_escaped'  /* Many cases with video and subtitles, text, etc. Same name different extension */
                    "
                    $howManyRowsUpdated = Invoke-Sql $update_sql
                    if ($howManyRowsUpdated -ne 1) {
                        throw [Exception]"Update failed to update anything or too many: $howManyRowsUpdated"
                    }                                                                  

                    Write-Host '>' -NoNewline 
                    $howManyUpdatedFiles++
                } else {    
                    $on_fs_broken_link    = $false
                    
                    try {
                        $on_fs_file_hash = (Get-FileHash -LiteralPath $file_path -Algorithm MD5).Hash
                    } catch [System.IO.IOException] {
                        $on_fs_broken_link    = $true
                        $on_fs_file_hash = '0'
                    }

                    $sql = "
                        INSERT INTO files(
                            file_hash,
                            directory_hash,
                            file_name_no_ext,
                            final_extension,
                            file_size,
                            file_date,
                            is_symbolic_link,
                            is_hard_link,
                            linked_path,
                            broken_link,
                            deleted
                        )              
                        VALUES (
                        /*  file_hash              */'$on_fs_file_hash'::bytea,
                        /*  directory_hash         */  md5(REPLACE(array_to_string((string_to_array('$directory_path_escaped', '/'))[:(howmanychar('$directory_path_escaped', '/')+1)], '/'), '/', '\'))::bytea,
                        /*  file_name_no_ext       */'$file_name_no_ext_escaped',
                        /*  final_extension        */'$final_extension_escaped',   
                        /*  file_size              */ $on_fs_file_size,
                        /*  file_date              */'$file_date_formatted'::TIMESTAMPTZ,
                        /*  is_symbolic_link       */ $on_fs_is_symbolic_link,
                        /*  is_hard_link           */ $on_fs_is_hard_link,
                        /*  linked_path            */ $file_link_target_escaped,
                        /*  broken_link            */ $on_fs_broken_link,
                        /*  deleted                */  False
                        )
                    "
                    Invoke-Sql $sql|Out-Null   
                    Write-Host '+' -NoNewline 
                    $howManyNewFiles++
                }
            }
        } # Get-ChildItem
        #TODO: Update as no-scan directory needed (last date scanned??)
        $clear_sql = "
            UPDATE 
                directories
            SET
                scan_directory = False
            WHERE
                directory_path    = '$directory_path_escaped'
            "                                                
        Invoke-Sql $clear_sql|Out-Null # Should be a performance boost not to scan folders no longer marked for scan.
    }
} While ($reader.Read())
}


# Display counts. If nothing is happening in certain areas, investigate.
Write-Host # Get off the last nonewline
Write-Host
Write-Host "How many new files were added:                      $howManyNewFiles"           $(Format-Plural 'Directory' $howManyNewFiles)  #TODO: Convert to the format that shows the number
Write-Host "How many old files were updated:                    $howManyUpdatedFiles"       $(Format-Plural 'Directory' $howManyUpdatedFiles) 
Write-Host "How many rows were updated:                         $howManyRowsUpdated"        $(Format-Plural 'Row'       $howManyRowsUpdated) 
Write-Host "How many rows were inserted:                        $hoWManyRowsInserted"       $(Format-Plural 'Row'       $hoWManyRowsInserted) 
Write-Host "How many rows were deleted:                         $hoWManyRowsDeleted"        $(Format-Plural 'Row'       $hoWManyRowsDeleted) 
Write-Host "How many new hard linked files were found:          $howManyNewHardLinks"       $(Format-Plural 'Link'      $howManyNewHardLinks) 
Write-Host "How many new symbolically linked files were found:  $howManyNewSymbolicLinks"   $(Format-Plural 'Link'      $howManyNewSymbolicLinks) 
#TODO: Update counts to session table

# Da Fuutar!!!
. D:\qt_projects\filmcab\simplified\shared_code\_dot_include_standard_footer.ps1
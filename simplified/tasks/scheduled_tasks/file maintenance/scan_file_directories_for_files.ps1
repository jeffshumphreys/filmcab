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

. .\_dot_include_standard_header.ps1

$howManyNewFiles         = 0
$howManyUpdatedFiles     = 0
$howManyRowsUpdated      = 0

# Let's traverse all the undeleted directories flagged for scan. scan_for_file_directories sets the flag before this daily.

$reader = WhileReadSql "
    SELECT 
        directory                           /* What we are going to search for new files     */
    ,   directory_escaped
    FROM 
        directories_ext_v
    WHERE
        NOT directory_deleted
    AND 
        scan_directory
";

# Search down each search path for directories that are different or missing from our data store.

While ($reader.Read()) {
    if ((Test-Path -LiteralPath $directory)) {
        Get-ChildItem $directory -Force| ForEach-Object { 
            if (!$_.PSIsContainer) {      
                $on_fs_file_date                = TrimToMicroseconds $_.LastWriteTime
                $on_fs_file_date_formatted      = $on_fs_file_date.ToString($DEFAULT_POWERSHELL_TIMESTAMP_FORMAT)
                $on_fs_file_size                = $_.Length
                $on_fs_file_path                = $_.FullName
                $on_fs_file_name_no_ext         = $_.BaseName
                $on_fs_file_name_no_ext_escaped = $on_fs_file_name_no_ext.Replace("'", "''")
                $on_fs_final_extension          = ''
                try {
                    $on_fs_final_extension  = $_.Extension.Substring(1)
                } catch { 
                    # Example of EXTENSIONLESS file: G:\Video AllInOne Backup\_Comedy\MST3K\S13 - The Gizmoplex\original unprocessed audio\! original unprocessed audio tracks AAC-LC 253Kbps
                    $on_fs_final_extension = ''
                }
                $on_fs_final_extension_escaped = $on_fs_final_extension.Replace("'", "''")
                $on_fs_file_link_type          = $_.LinkType
                $on_fs_file_link_path          = NullIf $_.LinkTarget                    # Warning: multiple targets?? Split on \n
                $on_fs_file_link_path_escaped  = PrepForSql $on_fs_file_link_path
                
                $on_fs_is_symbolic_link = $false
                $on_fs_is_hard_link     = $false
                
                if ($on_fs_file_link_type -eq 'SymbolicLink') {
                    $on_fs_is_symbolic_link = $true
                }
                elseif ($on_fs_file_link_type -eq 'HardLink') {
                    $on_fs_is_hard_link  = $true
                }                                    
                elseif (-not [String]::IsNullOrWhiteSpace($on_fs_file_link_type)) {
                    throw [Exception]"New unrecognized link type for $on_fs_file_path, type is $($on_fs_file_link_type)"
                }
    
                $test_sql = "
                    SELECT                                                                       
                        file_hash
                    ,   directory_hash
                    ,   file_date                           /* If changed, we need a new hash                                                                                       */
                    ,   file_size                           /* Also if changed, in case date isn't enough to detect. The garuntead way is to generate the hash, which is very slow. */
                    ,   file_is_symbolic_link               /* None of these should exist since VLC and other media players don't follow symbolic links. either folders or files    */
                    ,   file_is_hard_link                   /* Verified I have these. and they can help organize for better finding of films in different genre folders             */
                    ,   file_linked_path                    /* Verify this exists. Haven't tested.                                                                                  */
                    ,   file_deleted
                    FROM 
                        files_ext_v                
                    WHERE
                        directory_hash   = md5_hash_path('$directory_escaped')                                            
                    AND
                        file_name_no_ext = '$on_fs_file_name_no_ext_escaped'
                    AND
                        final_extension  = '$on_fs_final_extension_escaped'
            "

                if (Test-Sql $test_sql) {                    
                    # date changed?
                    # Test small amount for hash?   
                    # link type change? no longer a link?
                    # target changed?
                    # length changed?
                    # Do we need a new file hash? date, length changed?
                    $row                  = Out-SqlToDataset $test_sql -DontOutputToConsole -DontWriteSqlToConsole
                    $in_db_file_hash      = @($row.file_hash|Format-Hex|Select ascii).Ascii -Join ''
                    $in_db_directory_hash = @($row.directory_hash|Format-Hex|Select ascii).Ascii -Join ''
                    $in_db_file_date      = $row.file_date
                    $in_db_file_size      = $row.file_size
                    $in_db_link_path      = NullIf($row.file_linked_path)
                    $in_db_file_deleted   = $row.file_deleted
                    $on_fs_broken_link    = $false
                    $recalculated_on_fs_file_hash        = $null
                    
                    if (
                            $in_db_file_deleted                   -or
                            $in_db_file_date -ne $on_fs_file_date -or 
                            $in_db_file_size -ne $on_fs_file_size -or
                            $in_db_link_path -ne $on_fs_file_link_path
                        ) {
   
                        # Any non-hash changes, we regenerate the hash.  The hash could still be wrong even if nothing else changed. But how to test for that.
                        
                        try {
                            $on_fs_file_hash = (Get-FileHash -LiteralPath $on_fs_file_path -Algorithm MD5).Hash
                        } catch [System.IO.IOException] {
                            $on_fs_broken_link = $true
                            $on_fs_file_hash   = '0'
                        }
                        $recalculated_on_fs_file_hash = @($on_fs_file_hash|Format-Hex|Select ascii).Ascii -Join '' # May be churn
  
                        $update_sql = "
                                    UPDATE
                                        files_v
                                    SET
                                        file_hash         = '$recalculated_on_fs_file_hash'::bytea,
                                        file_date         = '$on_fs_file_date_formatted'::TIMESTAMPTZ,           
                                        file_size         = $on_fs_file_size,
                                        is_symbolic_link  = $on_fs_is_symbolic_link,
                                        is_hard_link      = $on_fs_is_hard_link,
                                        deleted           = False,
                                        broken_link       = $on_fs_broken_link
                                    WHERE
                                        file_hash         = '$in_db_file_hash'::bytea
                                    AND
                                        directory_hash    = '$in_db_directory_hash'::bytea
                                    AND
                                        file_name_no_ext  = '$on_fs_file_name_no_ext_escaped' /* Found case where two files same directory had same hash different name */
                                    AND
                                        final_extension   = '$on_fs_final_extension_escaped'  /* Many cases with video and subtitles, text, etc. Same name different extension */
                        "
                        $howManyRowsUpdated = Invoke-Sql $update_sql
                        if ($howManyRowsUpdated -ne 1) {
                            throw [Exception]"Update failed to update anything or too many: $howManyRowsUpdated"
                        }                                                                  

                        _TICK_Existing_Object_Edited
                        $howManyUpdatedFiles++
                    }
                } else {    
                    $on_fs_broken_link     = $false
                    
                    try {
                        $on_fs_file_hash   = (Get-FileHash -LiteralPath $on_fs_file_path -Algorithm MD5).Hash
                    } catch [System.IO.IOException] {
                        $on_fs_broken_link = $true
                        $on_fs_file_hash   = '0'
                    }

                    $sql = "
                        INSERT INTO 
                        files(
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
                        /*  file_hash              */'$on_fs_file_hash'::bytea,     /* IDEA: `$(Format-ForSql (variable) returns NULL or 'x' or x::bytea or ::TIMESTAMPTZ or (escaped text)) */
                        /*  directory_hash         */ md5_hash_path('$directory_escaped'),
                        /*  file_name_no_ext       */'$on_fs_file_name_no_ext_escaped',
                        /*  final_extension        */'$on_fs_final_extension_escaped',   
                        /*  file_size              */ $on_fs_file_size,
                        /*  file_date              */'$on_fs_file_date_formatted'::TIMESTAMPTZ,
                        /*  is_symbolic_link       */ $on_fs_is_symbolic_link,
                        /*  is_hard_link           */ $on_fs_is_hard_link,
                        /*  linked_path            */ $on_fs_file_link_path_escaped,
                        /*  broken_link            */ $on_fs_broken_link,
                        /*  deleted                */ False
                        )
                    " # OOOOR, the entire thing. we pass in prefix "_on_fs", target table name, it pulls columns and matches to variables. Wow. Way over the top.
                    Invoke-Sql $sql|Out-Null   
                    _TICK_New_Object_Instantiated
                    $howManyNewFiles++
                }
            }
        } # Get-ChildItem
        #TODO: Update as no-scan directory needed (last date scanned??)
        $clear_sql = "
            UPDATE 
                directories_v
            SET
                scan_directory = False
            WHERE
                directory = '$directory_escaped'
            "                                                
        Invoke-Sql $clear_sql|Out-Null # Should be a performance boost not to scan folders no longer marked for scan.
    }
}


Write-Count howManyNewFiles               File
Write-Count howManyUpdatedFiles           File
Write-Count howManyRowsUpdated            Row
Write-Count howManyRowsInserted           Row
Write-Count howManyRowsDeleted            Row
Write-Count howManyNewHardLinks           Link
Write-Count howManyNewSymbolicLinks       Link
#TODO: Update counts to session table

. .\_dot_include_standard_footer.ps1
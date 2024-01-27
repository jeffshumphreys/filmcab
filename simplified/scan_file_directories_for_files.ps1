<#
 #    FilmCab Daily morning batch run process: Scan our updated and clean list of directories for new files.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Beginning.
 #    ###### Tue Jan 23 18:23:11 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #
 # TODO: Pull both in as arrays and full outer join; update/insert/delete
 # Question: Should I be filtering these by the filters in search_paths?  Especially since Downloads is fraught with junk.
 #>

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()

. D:\qt_projects\filmcab\simplified\_dot_include_standard_header.ps1

$DEFAULT_POWERSHELL_TIMESTAMP_FORMAT = "yyyy-MM-dd HH:mm:ss.ffffff zzz"      # 2024-01-22 05:37:00.450241 -07:00    ONLY to 6 places (microseconds). Windows has 7 places, which won't match with Postgres's 6
# FYI: $DEFAULT_POSTGRES_TIMESTAMP_FORMAT = "yyyy-mm-dd hh24:mi:ss.us tzh:tzm"    # 2024-01-22 05:36:46.489043 -07:00

# Found example on Internet that uses a LIFOstack. Changed it to FIFO Queue would pull current search path first and possibly save a little time.

# Track some stats. Useful for finding bugs. For instance, kept getting 12 new junction points, the same ones. turns out the test was bad.

$howManyNewFiles = 0
$howManyUpdatedFiles = 0
$howManyNewSymbolicLinks = 0
$howManyNewHardLinks= 0
$hoWManyRowsUpdated = 0
$hoWManyRowsInserted = 0
$hoWManyRowsDeleted = 0

$sql = "
SELECT 
     directory_path                      /* What we are going to search for new files     */
   , directory_hash                      /* Links back to directories table               */
   , is_symbolic_link                    /* Don't go into these?                          */
   , is_junction_link                    /* We'll still want to log things added to these */
FROM 
    directories
WHERE
    (deleted IS NULL OR deleted IS FALSE)   
AND
    (directory_still_exists IS NULL OR directory_still_exists IS TRUE)
AND 
    scan_directory IS TRUE
";

$readerHandle = (Select-Sql $sql) # Cannot return reader value directly from a function or it blanks, so return it boxed
$reader = $readerHandle.Value # Now we can unbox!  Ta da!

# Search down each search path for directories that are different or missing from our data store.

Do {
    $directory_path = $reader.GetString(0)

    if ((Test-Path $directory_path)) {
        Get-ChildItem $directory_path -Force| ForEach-Object { 
            if (!$_.PSIsContainer) {      
                $file_date = $_.LastWriteTime
                $file_date_formatted = $file_date.ToString($DEFAULT_POWERSHELL_TIMESTAMP_FORMAT)
                $file_size = $_.Length
                $file_path = $_.FullName
                $file_name_no_ext = $_.BaseName
                $file_name_no_ext_escaped = $file_name_no_ext.Replace("'", "''")
                $final_extension  = $_.Extension.Substring(1)
                $final_extension_escaped  = $final_extension.Replace("'", "''")                                      
                # TODO: [bool]($file.Attributes -band [IO.FileAttributes]::ReparsePoint) https://stackoverflow.com/questions/817794/find-out-whether-a-file-is-a-symbolic-link-in-powershell
                $file_link_type = $_.LinkType
                $file_link_target = NullIf $_.LinkTarget                    # Warning: multiple targets?? Split on `n
                $file_link_target_escaped = PrepForSql $file_link_target
                $directory_path   = $_.Directory.FullName                        
                $directory_path_escaped = $directory_path.Replace("'", "''")
                
                $is_symbolic_link = $false
                $is_hard_link = $false
                
                if ($file_link_type -eq 'SymbolicLink') {
                    $is_symbolic_link = $true
                }
                elseif ($file_link_type -eq 'HardLink') {
                    $is_hard_link  = $true
                }                                    
                elseif (-not [String]::IsNullOrWhiteSpace($file_link_type)) {
                    throw [Exception]"New unrecognized link type for $file_path, type is $($file_link_type)"
                }
    
                $sql = "
                SELECT 
                     file_date                           /* If changed, we need a new hash */
                   , is_symbolic_link                    /* None of these should exist since VLC and other media players don't follow symbolic links. either folders or files */
                   , is_hard_link                        /* Verified I have these. and they can help organize for better finding of films in different genre folders          */
                   , linked_path                         /* Verify this exists. Haven't tested.                                                                               */
                   , file_still_exists                   /* This is mostly for downstream tasks                                                                               */
                FROM 
                    files
                WHERE
                    directory_hash = md5(REPLACE(array_to_string((string_to_array('$directory_path_escaped', '/'))[:(howmanychar('$directory_path_escaped', '/')+1)], '/'), '/', '\'))::bytea
                AND
                    file_name_no_ext = '$file_name_no_ext_escaped'
                AND
                    final_extension = '$final_extension_escaped'
                ";

                if (Test-Sql $sql) {                    #TODO: Write the god damn Test-Sql function!
                    # date changed?
                    # Test small amount for hash?   
                    # link type change? no longer a link?
                    # target changed?
                    # length changed?
                    # Do we need a new file hash? date, length changed?

                    $sql = "
                        UPDATE
                            files
                        SET
                            ?????
                            deleted = FALSE    
                            file_still_exists = TRUE
                        WHERE
                            file_hash = ....
                        AND
                            ??? directory_hash?
                    " #TODO:
                } else {
                    $file_hash = (Get-FileHash $file_path -Algorithm MD5).Hash

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
                            deleted,
                            file_still_exists
                        )              
                        VALUES (
                            /*     file_hash              */'$file_hash'::bytea,
                            /*     directory_hash         */  md5(REPLACE(array_to_string((string_to_array('$directory_path_escaped', '/'))[:(howmanychar('$directory_path_escaped', '/')+1)], '/'), '/', '\'))::bytea,
                            /*     file_name_no_ext       */'$file_name_no_ext_escaped',
                            /*     final_extension        */'$final_extension_escaped',   
                            /*     file_size              */ $file_size,
                            /*     file_date              */ '$file_date_formatted'::TIMESTAMPTZ,
                            /*     is_symbolic_link       */ $is_symbolic_link,
                            /*     is_hard_link           */ $is_hard_link,
                            /*     linked_path            */ $file_link_target_escaped,
                            /*     deleted                */  False,
                            /*     file_still_exists      */  True
                        )
                    "
                    Invoke-Sql $sql|Out-Null   
                    Write-Host '+' -NoNewline 
                    $howManyNewFiles++
                }
            }
        } # Get-ChildItem
        #TODO: Update as no-scan directory needed (last date scanned??)
    }
} While ($reader.Read())



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
. D:\qt_projects\filmcab\simplified\_dot_include_standard_footer.ps1
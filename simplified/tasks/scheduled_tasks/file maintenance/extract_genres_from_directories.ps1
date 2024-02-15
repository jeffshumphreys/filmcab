<#
 #    FilmCab Daily morning batch run process: Extract all the "_" folders and determine what genre to assign the directory.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Prepping for addition to schedule.
 
 #    ###### Tue Jan 23 18:23:11 MST 2024                

 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #    https://github.com/jeffshumphreys/filmcab/issues/41
 #>
 
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()

. D:\qt_projects\filmcab\simplified\shared_code\_dot_include_standard_header.ps1

# Track some stats. Useful for finding bugs. For instance, kept getting 12 new junction points, the same ones. turns out the test was bad.

$howManyGenreFoldersWereFound = 0
$howManySubGenreFoldersWereFound       = 0
$howManyGrandSubGenreFoldersWereFound  = 0
$howManyNewGenreWereFound     = 0

# Fetch a string array of paths to search.

$loop_sql = "
                        SELECT 
                            directory_path                      /* What we are going to search for new files     */
                        ,   useful_part_of_directory_path       /* Start without the base search_directory to confuse us */
                        FROM 
                            directories_ext_v
";

$readerHandle = Walk-Sql $loop_sql
$reader = $readerHandle.Value # Now we can unbox!  Ta da!
              
While ($reader.Read()) {
    $directory_path = Get-SqlFieldValue $readerHandle directory_path
    $useful_part_of_directory_path = Get-SqlFieldValue $readerHandle useful_part_of_directory_path

    # split it into parts

    $directory_folders = $useful_part_of_directory_path -split '\\'
    $genre = $null
    $subgenre = $null
    $grandsubgenre = $null

    if ($directory_folders.Length -ge 1) {
        $genre_candidate = $directory_folders[0] # _Sci Fi, _Comedy, __Julie might want to watch
        if ((Left $genre_candidate 1) -eq '_' -and (Left $genre_candidate 2) -ne '__') {
            $genre = $genre_candidate
        }
    } else {
        $genre = $null
        $subgenre = $null
    }
        
    if ($directory_folders.Length -ge 2) {
        $subgenre_candidate = $directory_folders[1]
        if ((Left $subgenre_candidate 1) -eq '_' -and (Left $subgenre_candidate 2) -ne '__' )
        {
            $subgenre = $subgenre_candidate
        }
    }                                      

    if ($directory_folders.Length -ge 3) {
        $grandsubgenre_candidate = $directory_folders[2]
        if ((Left $grandsubgenre_candidate 1) -eq '_' -and (Left $grandsubgenre_candidate 2) -ne '__' )
        {
            $grandsubgenre = $grandsubgenre_candidate
        }
    }                                      
              
    $wrote = $false
    $escaped_directory_path = $directory_path.Replace("'", "''")
    if ($null -ne $genre -and 
        $genre -notin('_Mystery', '_Comedy', '_Sci Fi'))  # To reduce the dump out to Host, exclude things that are ubiquitous and never going to change.
    {
        Write-Host "Genre: $genre" -NoNewline
        $wrote = $true
        $howManyGenreFoldersWereFound++                             
        $genre = $genre.Substring(1)
        Invoke-Sql "UPDATE directories set root_genre = '$genre' where directory_path = '$escaped_directory_path'"|Out-Null
        $howManyAdded = Invoke-Sql "INSERT INTO genres(genre, genre_function, genre_level, directory_path_example) VALUES('$genre', 'published folders', 1, '$escaped_directory_path') ON CONFLICT(genre, genre_function) DO NOTHING"|Out-Null
        $howManyNewGenreWereFound+= $howManyAdded
    }                             

    if ($null -ne $subgenre) {
        Write-Host "  Sub-genre: $subgenre"  -NoNewline
        $wrote = $true
        $howManySubGenreFoldersWereFound++
        $subgenre = $subgenre.Substring(1)
        Invoke-Sql "UPDATE directories set sub_genre = '$subgenre' where directory_path = '$escaped_directory_path'"|Out-Null
        $howManyAdded = Invoke-Sql "INSERT INTO genres(genre, genre_function, genre_level, directory_path_example) VALUES('$subgenre', 'published folders', 2, '$escaped_directory_path') ON CONFLICT(genre, genre_function) DO NOTHING"|Out-Null
        $howManyNewGenreWereFound+= $howManyAdded
    }

    if ($null -ne $grandsubgenre) {
        Write-Host "    Grand-sub-genre: $grandsubgenre" -NoNewline
        $wrote = $true
        $howManyGrandSubGenreFoldersWereFound++
        $grandsubgenre = $grandsubgenre.Substring(1)
        $howManyAdded = Invoke-Sql "INSERT INTO genres(genre, genre_function, genre_level, directory_path_example) VALUES('$grandsubgenre', 'published folders', 3, '$escaped_directory_path') ON CONFLICT(genre, genre_function) DO NOTHING"|Out-Null
        $howManyNewGenreWereFound+= $howManyAdded
    }   

    if ($wrote) {
        Write-Host
        
    }
    
    break
}


# Display counts. If nothing is happening in certain areas, investigate.
Write-Host # Get off the last nonewline
Write-Host
Write-Count howManyGenreFoldersWereFound           Folder
Write-Count howManySubGenreFoldersWereFound        Folder
Write-Count howManyGrandSubGenreFoldersWereFound   Folder
Write-Count howManyNewGenreWereFound               Genre  
#TODO: Update counts to session table

# Da Fuutar!!!
. D:\qt_projects\filmcab\simplified\shared_code\_dot_include_standard_footer.ps1
<#
 #    FilmCab Daily morning batch run process: Extract all the "_" folders and determine what genre to assign the directory.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Prepping for addition to schedule.
 
 #    ###### Tue Jan 23 18:23:11 MST 2024                

 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #    https://github.com/jeffshumphreys/filmcab/issues/41

 #    Needs refactoring:
      - Traverse EVERY "_" folder, then track back parentage?
      - Add entire tree of genres to directory entry as "genres" array.
      - Capture genres hidden under uh non-genre folders. Hmmmm. Time to have a "hidden" property? 🤨
      Question:Do we count all movies below a genre or just until a subgenre?
      For instance:
      - Does _Dsytopia include the movies in _Dystopia\_Police State?  Rignt now they're excluded I think.
      - Technically, everything below a folder is that genre, but then the counts would be off.

 #>
 
. .\_dot_include_standard_header.ps1

# Track some stats. Useful for finding bugs. For instance, kept getting 12 new junction points, the same ones. turns out the test was bad.

$howManyGenreFoldersWereFound         = 0
$howManySubGenreFoldersWereFound      = 0
$howManyGrandSubGenreFoldersWereFound = 0
$howManyNewGenreWereFound             = 0
     
$genreFileCounts = @{}

$reader = WhileReadSql "
    SELECT 
        directory                      /* What we are going to search for new files     */
    ,   directory_escaped
    ,   useful_part_of_directory       /* Start without the base search_directory to confuse us */
    FROM 
        directories_ext_v           
    WHERE
        NOT directory_deleted
"
              
While ($reader.Read()) {

    # split it into parts

    $directory_folders = $useful_part_of_directory -split '\\'
    $genre         = $null
    $subgenre      = $null
    $grandsubgenre = $null

    if ($directory_folders.Length -ge 1) {
        $genre_candidate = $directory_folders[0] # _Sci Fi, _Comedy, __Julie might want to watch
        if ((Left $genre_candidate 1) -eq '_' -and (Left $genre_candidate 2) -ne '__') {
            $genre = $genre_candidate
        }
    } else {
        $genre    = $null
        $subgenre = $null
    }
         
    if (-not [string]::IsNullOrWhiteSpace($genre)) {
        # count all non genre movies below.
        $ct = 0
    
        Get-ChildItem $directory -Recurse  |
            Foreach { 
                $directorylength = $directory.Length
                $relpath = $_.FullName.Substring($directorylength)
                if ($relpath -notmatch "\\_") {
                    if (!($_.PSIsContainer)) { $ct++}
                }
            }
        $currentCount = $genreFileCounts[$genre]
        if ($null -eq $currentCount) { $currentCount = 0}
        $currentCount++
        $genreFileCounts.Set_Item($genre, $currentCount)

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
              
    $wrote                  = $false
    
    if ($null -ne $genre -and 
        $genre -notin('_Mystery', '_Comedy', '_Sci Fi'))  # To reduce the dump out to Host, exclude things that are ubiquitous and never going to change.
    {
        Write-AllPlaces "Genre: $genre" -NoNewline
        $wrote = $true
        $howManyGenreFoldersWereFound++                             
        $genre = $genre.Substring(1)
        Invoke-Sql "UPDATE directories set root_genre = '$genre' where directory_path = '$directory_escaped'"|Out-Null
        $howManyAdded = Invoke-Sql "INSERT INTO genres(genre, genre_function, genre_level, directory_path_example) VALUES('$genre', 'published folders', 1, '$directory_escaped') ON CONFLICT(genre, genre_function) DO NOTHING"|Out-Null
        $howManyNewGenreWereFound+= $howManyAdded
    }                             

    if ($null -ne $subgenre) {
        Write-AllPlaces "  Sub-genre: $subgenre"  -NoNewline
        $wrote = $true
        $howManySubGenreFoldersWereFound++
        $subgenre = $subgenre.Substring(1)
        Invoke-Sql "UPDATE directories set sub_genre = '$subgenre' where directory_path = '$escaped_directory_path'"|Out-Null
        #TODO: add parent genre id in.
        $howManyAdded = Invoke-Sql "INSERT INTO genres(genre, genre_function, genre_level, directory_path_example) VALUES('$subgenre', 'published folders', 2, '$directory_escaped') ON CONFLICT(genre, genre_function) DO NOTHING"|Out-Null
        $howManyNewGenreWereFound+= $howManyAdded
    }

    if ($null -ne $grandsubgenre) {
        Write-AllPlaces "    Grand-sub-genre: $grandsubgenre" -NoNewline
        $wrote = $true
        $howManyGrandSubGenreFoldersWereFound++
        $grandsubgenre = $grandsubgenre.Substring(1)
        $howManyAdded = Invoke-Sql "INSERT INTO genres(genre, genre_function, genre_level, directory_path_example) VALUES('$grandsubgenre', 'published folders', 3, '$directory_escaped') ON CONFLICT(genre, genre_function) DO NOTHING"|Out-Null
        $howManyNewGenreWereFound+= $howManyAdded
    }   

    if ($wrote) {
        Write-AllPlaces # Move to next line
    }
}

Write-Count howManyGenreFoldersWereFound           Folder
Write-Count howManySubGenreFoldersWereFound        Folder
Write-Count howManyGrandSubGenreFoldersWereFound   Folder
Write-Count howManyNewGenreWereFound               Genre  

$genreFileCounts.GetEnumerator()|Select Key, Value|Sort Key|Out-Host

. .\_dot_include_standard_footer.ps1
<#
 #    FilmCab Daily morning batch run process: Track our nearness to filling up our space
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Conception
 #    ###### Sat Feb 3 22:20:01 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #>

try {
. .\_dot_include_standard_header.ps1

$howMuchSpaceLeft   = [Int64]0

# Fetch a string array of paths to search.
                           
# TODO: Extend O to include I, N, F, and E. Split those to share with D, too, the download drive.
# I: 5.4 TB free
# N: 11 TB free
# F: 4.5 TB free
# E: 3.6 TB free
# O: 1.7 TB free
# D: 3.7 TB free
# K: 10.9 TB free

###### Tue Mar 5 15:47:32 MST 2024 Bought Avolusion HDDGear Pro X 12TB USB 3.0 External Gaming Hard Drive. Reformat as NTFS

$volumesForSearchDirectories = WhileReadSql 'SELECT DISTINCT volume_id, drive_letter from search_directories_ext_v ORDER BY 1' # All the directories across my volumes that I think have some sort of movie stuff in them.
    
$volumes = Get-Volume|Where DriveLetter -ne ''|Select DriveLetter, Size, SizeRemaining

# Search down each search path for directories that are different or missing from our data store.

while ($volumesForSearchDirectories.Read()) {                                                                                 
    $totalSize      = ($volumes|Where DriveLetter -eq $drive_letter|Select Size).Size
    $spaceRemaining = ($volumes|Where DriveLetter -eq $drive_letter|Select SizeRemaining).SizeRemaining
    Write-AllPlaces "$drive_letter`: TotalSize=$(HumanizeCount($totalSize)), Free=$(HumanizeCount($spaceRemaining))"
    
    Invoke-Sql "UPDATE search_directories_v SET size_of_drive_in_bytes = $totalSize, space_left_on_drive_in_bytes = $spaceRemaining WHERE volume_id = $volume_id" -OneOrMore |Out-Null # Many paths on same volume
    $howMuchSpaceLeft+= $spaceRemaining
}

Write-Count howMuchSpaceLeft Files                            

}
catch {
    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}                                  
finally {
    Write-AllPlaces "Finally"
    . .\_dot_include_standard_footer.ps1
}

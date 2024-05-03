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
# C:  0.8 TB free
# D:  3.6 TB free
# E:  3.6 TB free
# F:  4.5 TB free
# G: 14.1 TB free
# H:
# I:  5.4 TB free
# J:
# K: 11.9 TB free
# L:
# M:
# N:  9.9 TB free
# O:  1.5 TB free
# P:
# Q:
# Free letters: 15!  How many USB ports? hmmmmmm.  Any room for internal drives?  Pull lid? Insert high card? May not be enough power supply. Move board to big case?????????????????
# Total space left: 46.5 TB

###### Tue Mar 5 15:47:32 MST 2024 Bought Avolusion HDDGear Pro X 12TB USB 3.0 External Gaming Hard Drive. Reformat as NTFS

$volumesForSearchDirectories = WhileReadSql "
    SELECT
        volume_id
    ,   drive_letter
    ,   max(tag) as tag
    FROM
        search_directories_ext_v
    GROUP BY
        volume_id
    ,   drive_letter
    ORDER BY
        1
    " # All the directories across my volumes that I think have some sort of movie stuff in them.

$volumes = Get-Volume|Where DriveLetter -ne ''|Select DriveLetter, Size, SizeRemaining

# Search down each search path for directories that are different or missing from our data store.

[Int64]$howMuchSpaceLeft       = 0
[Int64]$smallestRemainingSpace = 0
[Int64]$spaceLeftOnPublished   = 0

while ($volumesForSearchDirectories.Read()) {
    $totalSizeOfDrive      = ($volumes|Where DriveLetter -eq $drive_letter|Select Size).Size
    $spaceRemainingOnDrive = ($volumes|Where DriveLetter -eq $drive_letter|Select SizeRemaining).SizeRemaining
    if ($tag -eq 'Published') {
        $spaceLeftOnPublished = $spaceRemainingOnDrive
    }

    Write-AllPlaces "$drive_letter`: TotalSize=$(HumanizeCount($totalSizeOfDrive)), Free=$(HumanizeCount($spaceRemainingOnDrive))"

    Invoke-Sql "UPDATE search_directories_v SET size_of_drive_in_bytes = $totalSizeOfDrive, space_left_on_drive_in_bytes = $spaceRemainingOnDrive WHERE volume_id = $volume_id" -OneOrMore |Out-Null # Many paths on same volume
    $howMuchSpaceLeft+= $spaceRemainingOnDrive
    if (0 -eq $smallestRemainingSpace -or $spaceRemainingOnDrive -lt $smallestRemainingSpace) { $smallestRemainingSpace = $spaceRemainingOnDrive}
}

Write-Count howMuchSpaceLeft Byte

Write-AllPlaces "Free Space (GB) $($howMuchSpaceLeft/1000/1000/1000) GB"
Write-AllPlaces "Least Free Space (GB) $($smallestRemainingSpace/1000/1000/1000) GB"

if ($true) {
    [PscustomObject] @{
        Total_Free_Space_GB = ($howMuchSpaceLeft/1000/1000/1000).ToString()
        Smallest_Space_GB = ($smallestRemainingSpace/1000/1000/1000).ToString()
        Free_Space_in_Published_GB = ($spaceLeftOnPublished/1000/1000/1000).ToString()
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

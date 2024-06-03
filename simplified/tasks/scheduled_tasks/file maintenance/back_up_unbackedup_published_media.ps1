<#
 #   FilmCab Daily morning batch run process: backup published media to alternate spindle.
 #   Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #   Status: Run when run manually from Task Scheduler. The full paths were missing and so the log failed.
 #   Status: Update when runs at 11:52 PM tonight and generates log.
 #   https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #   Notes: I don't just love the verbose log output, but I'm only keeping the one copy.
 #   ###### Tue Jan 16 19:10:55 MST 2024 - Moved to Yet Another Subfolder. Updated actual task. Exported.
 #>

# Bug: Cannot find path 'D:\_dot_include_standard_header.ps1' because it does not exist.

try {
. .\_dot_include_standard_header.ps1

# /E for copying empty subdirectories
# /J for copy using unbuffered I/O (recommended for large files).
# /V :: produce Verbose output, showing skipped files.
# /NOOFFLOAD Copy files without using the Windows Copy Offload mechanism.
# /R:1 retry once instead of default 1 million
# /XJ :: eXclude symbolic links (for both files and directories) and Junction points.  (Not doing this, just FYI)
# Not dating the log; just want the last one for now.
###### Fri Feb 23 10:48:01 MST 2024 The other day, I went and RENAMED all the subfolders under _Mystery in order to
    # 1) Append their other name, either their foreign name, their UK/American Release name, or their rename.
    # 2) Add their first release year
    # 3) Add either their final release year or a "-" if they have not been cancelled yet.
    # 4) Separate where their are large gaps between separate blocks of contiguous years and seasons.
    # This caused a great movement of duplicate files to the backup drive, wasting a massive amount of space.  Also, it surpassed the 2 hour time limit this task was given.
    # This is a defect of the sequence style of batch movement. Or a limitation.  But all downstream tasks are eith delayed or cancelled. Does an overrun generate a tast success event??

    # TODO: When source file has same hash, date and size as a file previously in same directory, and the previous file is gone, and it is not in another directory, rename target on backup to new file name.
Log-Line "Starting Robocopy"
Robocopy.exe "O:\Video AllInOne" "G:\Video AllInOne Backup" /E /J /PURGE /R:1 /V /UNILOG:D:\qt_projects\filmcab\simplified\_log\back_up_unbackedup_published_media.robocopy.log
Get-Content D:\qt_projects\filmcab\simplified\_log\back_up_unbackedup_published_media.robocopy.log
Log-Line "Finished Robocopy"

}
catch {
    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}
finally {
    Write-AllPlaces "Finally" -ForceStartOnNewLine
    . .\_dot_include_standard_footer.ps1
}
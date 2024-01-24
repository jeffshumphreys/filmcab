<#
    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
    Status: Run when run manually from Task Scheduler. The full paths were missing and so the log failed.
    Status: Update when runs at 11:52 PM tonight and generates log.
#   https://github.com/jeffshumphreys/filmcab/tree/master/simplified
    Notes: I don't just love the verbose log output, but I'm only keeping the one copy.
    ###### Tue Jan 16 19:10:55 MST 2024 - Moved to Yet Another Subfolder. Updated actual task. Exported.

#>
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Scope='Function', Target='Log-*')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '', Scope='Function', Target='*')]
param()

. D:\qt_projects\filmcab\simplified\_dot_include_standard_header.ps1 

# /E for copying empty subdirectories
# /J for copy using unbuffered I/O (recommended for large files).
# /V :: produce Verbose output, showing skipped files.
# /NOOFFLOAD Copy files without using the Windows Copy Offload mechanism.        
# /R:1 retry once instead of default 1 million
# /XJ :: eXclude symbolic links (for both files and directories) and Junction points.  (Not doing this, just FYI)

Robocopy.exe "O:\Video AllInOne" "G:\Video AllInOne Backup" /E /J /NOOFFLOAD /R:1 /V /UNILOG:D:\qt_projects\filmcab\simplified\_log\back_up_unbackedup_published_media.robocopy.log

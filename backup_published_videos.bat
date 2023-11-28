REM /E for copying empty subdirectories
REM /J for copy using unbuffered I/O (recommended for large files).
REM /NOOFFLOAD Copy files without using the Windows Copy Offload mechanism.
robocopy "O:\Video AllInOne" "G:\Video AllInOne Backup" /E /J /NOOFFLOAD /R:1
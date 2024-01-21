Get-WmiObject win32_share | where {$_.name -NotLike "*$"} # Is Video AllInOne there, and pointing to O:???
# https://builds.smartmontools.org/
# Try fsutil! Interesting! Installed already in Windows 10.
<#
8dot3name         8dot3name management
behavior          Control file system behavior
dax               Dax volume management
dirty             Manage volume dirty bit
file              File specific commands
fsInfo            File system information
hardlink          Hardlink management
objectID          Object ID management
quota             Quota management
repair            Self healing management
reparsePoint      Reparse point management
storageReserve    Storage Reserve management
resource          Transactional Resource Manager management
sparse            Sparse file control
tiering           Storage tiering property management
transaction       Transaction management
usn               USN management
volume            Volume management
wim               Transparent wim hosting management

D:\qt_projects\filmcab>fsutil 8dot3name
---- 8DOT3NAME Commands Supported ----

query   Query the current setting for the shortname behaviour on the system
scan    Scan for impacted registry entries
set     Change the setting that controls the shortname behavior on the system
strip   Remove the shortnames for all files within a directory

Usage : fsutil behavior query <option>

<option>

allowExtChar
bugcheckOnCorrupt
disable8dot3 [<Volume Path>]
disableCompression
disableCompressionLimit
disableDeleteNotify [NTFS|ReFS]
disableEncryption
disableFileMetadataOptimization
disableLastAccess
disableSpotCorruptionHandling
encryptPagingFile
memoryUsage
mftZone
quotaNotify
symlinkEvaluation
disableWriteAutoTiering [<Volume Path>]
disableTxf [<Volume Path>]
enableReallocateAllDataWrites [<Volume Path>]


#>
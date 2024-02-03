<#
 #    FilmCab Daily morning batch run process: Check things like if we are on Windows, or what version of PowerShell, what's the server, all before connecting to a database.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: No Work Done
 #    ###### Tue Jan 23 18:23:11 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #
 #>

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param($stage = 'before_session_starts')

# DO NOT CONNECT TO DATABASE!!!!

$OS = '?'

$ScriptPath = $MyInvocation.ScriptName
if ([String]::IsNullOrEmpty($ScriptPath)) {                                                                
    # So instead of "ScriptName", we've got "Line", "Statement", "MyCommand" (which is actually the Script Name), and "PositionMessage" which is a bit messy, but could be used to get the caller.
    $ScriptPath = $MyInvocation.Line.Trim("`'. ") # No ScriptName if running this file directly, just Line = . 'D:\qt_projects\filmcab\simplified\_dot_include_standard_header.ps1'  This of course will devolve over PS versions. Why? Because developer constantly finesse stuff and break code.
}                                          

if ($IsWindows) { 
    $OS = 'Windows'
    $Script:OSPropertiesOfInterest = $(Get-CimInstance Win32_OperatingSystem) | Select *
}
elseif ($IsLinux) { $OS = 'Linux'}
elseif ($IsMacOS) { $OS = 'MacOS'}

$ConnectedToTheDNSServer = Test-Connection 'google.com' -Count 1 -Quiet
$ICMPEnabled = ((Get-CIMInstance Win32_PingStatus -Filter "address='google.com'").StatusCode -eq 0)
#$PSVersionTable.Platform # Win32NT
#$PSVersionTable.PSVersion # 7.4.1
$netstat = Get-NetAdapter|Where Name -eq 'Ethernet'|Where Virtual -eq $false|Select * # Ethernet, Status, MacAddress, LinkSpeed
                       
$WakeOnLinkStatus = Get-NetAdapterAdvancedProperty|Where Name -eq 'Ethernet'|Where DisplayName -eq 'Wake on Link Settings'|Select DisplayValue
$WakeOnLinkStatus = Get-NetAdapterAdvancedProperty|Where Name -eq 'Ethernet'|Where DisplayName -eq 'Wake on Magic Packet'|Select DisplayValue
$WakeOnLinkStatus = Get-NetAdapterAdvancedProperty|Where Name -eq 'Ethernet'|Where DisplayName -eq 'Wake on Pattern Match'|Select DisplayValue
$WakeOnLinkStatus = Get-NetAdapterAdvancedProperty|Where Name -eq 'Ethernet'|Where DisplayName -eq 'Jumbo Packet'|Select DisplayValue
$NicUltraLowPowerMode = Get-NetAdapterAdvancedProperty|Where Name -eq 'Ethernet'|Where DisplayName -eq 'Ultra Low Power Mode'|Select DisplayValue

$IPState = Get-NetIPAddress|Where InterfaceAlias -eq 'Ethernet'
$IPCameFromDHCP = ($IPState.PrefixOrigin -eq 'Dhcp')
$DNSAddress = (@(Get-NetIPConfiguration|Select -expand DNSServer|Select *|Where AddressFamily -eq 2|Select ServerAddresses)[0]).ServerAddresses # 10.0.0.1
$GatewayStat = Get-NetIPConfiguration|Select -expand IPv4DefaultGateway|Select *  
$NetworkCategory = (Get-NetConnectionProfile|Select NetworkCategory) # Private, Public, Domain
$AreWeInADomain = (Get-NetConnectionProfile|Select DomainAuthenticationKind) # None

# Put it all together

$SanityCheckStatus = [PSCustomObject]@{
    ComputerName          = $Script:OSPropertiesOfInterest.CSName           # DSKTP-HOME-JEFF
    ComputerDescription = $Script:OSPropertiesOfInterest.Description      # Jeff's Home Dev Client
    Platform= [Environment]::OSVersion.Platform                     # Win32NT
    OS                    = $OS                                                   # Windows, Linux, or MacOS
    OSVersion           = [Environment]::OSVersion.Version.ToString()                      # 10.0.19045 (Really should be 1904.5)
    OSMajorVersionNo    = [Environment]::OSVersion.Version.Major                # 10
    OSMinorVersionNo    = [Environment]::OSVersion.Version.Minor                # 0
    OSBuildNo= [Environment]::OSVersion.Version.Build                # 19045
    OSArchitecture= $Script:OSPropertiesOfInterest.OSArchitecture   # 64-bit
    CurrentUserName    = $env:USERNAME                                # jeffs
    OSInstallDate     = $Script:OSPropertiesOfInterest.InstallDate      # 2023-09-22T21:04:52-06:00
    ComputerLastBooted = $Script:OSPropertiesOfInterest.LastBootUpTime   # 2024-01-25T15:12:49.417615-07:00
    OSSoftwareSerialNo  = $Script:OSPropertiesOfInterest.SerialNumber     # 00330-50141-73696-AAOEM
    AreWeConnectedToDNS  = $ConnectedToTheDNSServer                              # true
    AreWeAbleToPing= $ICMPEnabled                                          # true
    NicName = $netstat.ifName                                       # ethernet_32769
    NicDescription = $netstat.ifDesc                                       # Intel(R) Ethernet Connection (2) I219-LM
    NicStatus = $netstat.ifOperStatus.ToSTring()                      # Up    
    NicConnectionStatus = $netstat.MediaConnectionState.ToString()              # Connected                                      
    NicSpeed= $netstat.LinkSpeed                                    # 1 Gbps
    NicMacAddress= $netstat.MacAddress                                   # 
    NicLUID= $netstat.NetLuid                                      # 1689399632855040
    NicInterfaceGUID= $netstat.InterfaceGuid                                # 
    NicDriverLevel= $netstat.MediaType                                    # 802.3
    IPAddress = $IPState.IPAddress                                    # 
    DNSAddress            = $DNSAddress[0]                                           #
    IPAddressFamily= $IPState.AddressFamily.ToSTring()                     # IPv4
    IPAddressCameFromDHCP = $IPCameFromDHCP                                       # true
    GatewayState= $GatewayStat.State.ToString()                         # Alive
    GatewayIsStatic= $GatewayStat.IsStatic                                 # null
    ScriptPath    = $ScriptPath                                           # D:\\qt_projects\\filmcab\\simplified\\__sanity_check_before_connection.ps1
    CurrentDirectory= [System.Environment]::CurrentDirectory
    NicUltraLowPowerMode = $NicUltraLowPowerMode.DisplayValue                    # Enabled
    AreWeInADomain = $AreWeInADomain.DomainAuthenticationKind.ToString()   # None
    NetworkCategory = $NetworkCategory.NetworkCategory.ToSTring()           # Private
    PowerShellEdition = $PSVersionTable.PSEdition
    PowerShellPlatform =$PSVersionTable.Platform # Win32NT
    UserIsRunningInteractively = [Environment]::UserInteractive
    IsPrivilegedProcess = [Environment]::IsPrivilegedProcess
    # TypeOfRoute
    # Lease Expires
    # NetBIOS over Tcpip enabled?
    # Firewall, VPN, 
}

$SanityCheckStatus|ConvertTo-Json|Out-File "D:\qt_projects\filmcab\simplified\_log\__sanity_checks\__sanity_check_before_connection_$stage.json"

# Open config.json in this directory, not some fucked up sub directory like Boise did.  What the f for?? One fucking file.

# Is Task Scheduler History enabled?

# Is there space on drives?

# Is PostgreSQL installed?

# Is ODBC driver installed?

# Excel stuff?

# Anything that shouldn't be aliased?

# cygwin overriding anything like edit?

# path status? Changed?

# git active? connected to what? github?

# DST just happen? Anything fucked?

#Get-WmiObject win32_share | where {$_.name -NotLike "*$"} # Is Video AllInOne there, and pointing to O:???
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
# Da Fuutar!!!

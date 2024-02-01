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
param()

# DO NOT CONNECT TO DATABASE!!!!

$OS = '?'
$OSDefinition = '?'                                                
$OSVersion = '?'  
$OSBuildNo = '?'
$ComputerName = '?'
    
if ($IsWindows) { 
    $OS = 'Windows'
    $Script:OSPropertiesOfInterest = $(Get-CimInstance Win32_OperatingSystem) | Select `
        Description,                                           # Jeff's Home Dev Client
        CSName,                                                # DSKTP-HOME-JEFF
        RegisteredUser,                                        # jeffshumphreys@outlook.com  
        SerialNumber,                                          # 00330-50141-73696-AAOEM
        Caption,                                               # Microsoft Windows 10 Pro
        Version,                                               # 10.0.19045
        BuildNumber,                                           # 19045
        CurrentTimeZone,                                       # -420
        LocalDateTime,                                         # 1/31/2024 3:33:45 PM
        LastBootUpTime,                                        # 1/25/2024 3:12:48 PM
        InstallDate,
        MaxProcessMemorySize,                                  # 137438953344
        OSArchitecture,                                        # 64-bit
        Manufacturer,                                          # Microsoft Corporation
        SystemDevice,                                          # \Device\HarddiskVolume6
        SystemDrive,                                           # C:\
        BootDevice,                                            # \Device\HarddiskVolume2
        Status,                                                # OK
        CreationClassName                                      # Win32_OperatingSystem
    $ComputerName = $OSPropertiesOfInterest.CSName
    $UserProfile       = $env:USERPROFILE    # C:\Users\jeffs
    $OSUserName = $env:USERNAME   # jeffs    
}
elseif ($IsLinux) { $OS = 'Linux'}
elseif ($IsMacOS) { $OS = 'MacOS'}

$ConnectedToTheDNSServer = Test-Connection 'google.com' -Count 1 -Quiet
$ICMPEnabled = (Get-CIMInstance Win32_PingStatus -Filter "address='google.com'").StatusCode
#$PSVersionTable.PSEdition # Core
#$PSVersionTable.Platform # Win32NT
#$PSVersionTable.PSVersion # 7.4.1
$netstat = Get-NetAdapter|Where Name -eq 'Ethernet'|Where Virtual -eq $false|Select * # Ethernet, Status, MacAddress, LinkSpeed
                       
$WakeOnLinkStatus = Get-NetAdapterAdvancedProperty|Where Name -eq 'Ethernet'|Where DisplayName -eq 'Wake on Link Settings'|Select DisplayValue
$WakeOnLinkStatus = Get-NetAdapterAdvancedProperty|Where Name -eq 'Ethernet'|Where DisplayName -eq 'Ultra Low Power Mode'|Select DisplayValue
$WakeOnLinkStatus = Get-NetAdapterAdvancedProperty|Where Name -eq 'Ethernet'|Where DisplayName -eq 'Wake on Magic Packet'|Select DisplayValue
$WakeOnLinkStatus = Get-NetAdapterAdvancedProperty|Where Name -eq 'Ethernet'|Where DisplayName -eq 'Wake on Pattern Match'|Select DisplayValue
$WakeOnLinkStatus = Get-NetAdapterAdvancedProperty|Where Name -eq 'Ethernet'|Where DisplayName -eq 'Jumbo Packet'|Select DisplayValue

$IPState = Get-NetIPAddress|Where InterfaceAlias -eq 'Ethernet'
$IPCameFromDHCP = ($IPState.PrefixOrigin -eq 'Dhcp')
$DNSAddress = (@(Get-NetIPConfiguration|Select -expand DNSServer|Select *|Where AddressFamily -eq 2|Select ServerAddresses)[0]).ServerAddresses # 10.0.0.1
$GatewayStat = Get-NetIPConfiguration|Select -expand IPv4DefaultGateway|Select *  
$NetworkCategory = (Get-NetConnectionProfile|Select NetworkCategory) # Private, Public, Domain
$AreWeInADomain = (Get-NetConnectionProfile|Select DomainAuthenticationKind) # None

# Put it all together

$SanityCheckStatus = @{
    AsOf = (Get-Date)
    ComputerName = $Script:OSPropertiesOfInterest.CSName
    ComputerDescription = $Script:OSPropertiesOfInterest.Description
    Platform= [Environment]::OSVersion.Platform                     # Win32NT
    OS       = $OS                                                   # Windows, Linux, or MacOS
    OSVersion           = $OSVersion                                            # 10.0.19045 (Really should be 1904.5)
    OSMajorVersionNo    = [Environment]::OSVersion.Version.Major
    OSMinorVersionNo    = [Environment]::OSVersion.Version.Minor
    OSBuildNo= [Environment]::OSVersion.Version.Build
    OSArchitecture= $Script:OSPropertiesOfInterest.OSArchitecture
    CurrentUserName    = $env:USERNAME
    OSInstallDate     = $Script:OSPropertiesOfInterest.InstallDate
    ComputerLastBooted = $Script:OSPropertiesOfInterest.LastBootUpTime
    OSSoftwareSerialNo  = $Script:OSPropertiesOfInterest.SerialNumber
    AreWeConnectedToDNS  = $ConnectedToTheDNSServer
    AreWeAbleToPing= $ICMPEnabled
    NicName = $netstat.ifName # ethernet_32769
    NicDescription = $netstat.ifDesc      # Intel(R) Ethernet Connection (2) I219-LM
    NicStatus = $netstat.ifOperStatus # Up    
    NicConnectionStatus = $netstat.MediaConnectionState # Connected                                      
    NicSpeed= $netstat.LinkSpeed                # 1 Gbps
    NicMacAddress= $netstat.MacAddress    # D8-9E-F3-31-AE-3B
    NicLUID= $netstat.NetLuid       # 1689399632855040
    NicInterfaceGUID= $netstat.InterfaceGuid # {1521566F-0077-4522-97D6-40A70FCDD329}
    NicDriverLevel= $netstat.MediaType # 802.3
    IPAddress = $IPState.IPAddress
    IPAddressFamily= $IPState.AddressFamily # IPv4 (2?)
    IPAddressCameFromDHCP = $IPCameFromDHCP
    GatewayState= $GatewayStat.State # Alive
    GatewayIsStatic= $GatewayStat.IsStatic
    # TypeOfRoute
    # Lease Expires
    # NetBIOS over Tcpip enabled?
}

$SanityCheckStatus|ConvertTo-Json|Out-File 'D:\qt_projects\filmcab\simplified\_data\__sanity_check_before_connection_before_session_starts.json'

# Windows classifies the networks into three different types: public, private and domain

#Get-NetConnectionProfile # NetworkCategory=Private, DomainAuthenticaonKind None, IPv4, IPv6

$ScriptPath = $MyInvocation.ScriptName  # I suppose you could call this a "Name".  It's a file path.

# Has the path changed? drive?

#$PSVersionTable|Select 

# Open config.json in this directory, not some fucked up sub directory like Boise did.  What the f for?? One fucking file.

# Is this Windows, Linux, or Mac?

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

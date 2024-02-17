<#
 #    FilmCab Daily morning batch run process: Check things like if we are on Windows, or what version of PowerShell, what's the server, all before connecting to a database.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: No Work Done
 #    ###### Tue Jan 23 18:23:11 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #
 #>

param(
    $when  = 'without_db_connection',
    $stage = 'before_session_starts')

# DO NOT CONNECT TO DATABASE!!!!  This is to do the tests that should be done outside of structured persistence.

# This is also pre-Start-Log so I can't write to the log.

$OS        = '?'
$IsWindows = $false
$IsLinux   = $false
$IsMacOS   = $false

switch ([System.Environment]::OSVersion.Platform) {
    'Win32NT' { $OS = 'Windows'; $IsWindows = $true}
    'Unix' { $OS = 'Linux'; $IsLinux = $true}
}                                  

$ThisScriptPath = ($MyInvocation.Line.TrimStart('. ').Trim("'") -split ' ')[0]
#$MyCommand     = $MyInvocation.MyCommand
#$MyInvocation|Select *
$ScriptPath = $MyInvocation.ScriptName
if ([String]::IsNullOrEmpty($ScriptPath)) {                                                                
    # So instead of "ScriptName", we've got "Line", "Statement", "MyCommand" (which is actually the Script Name), and "PositionMessage" which is a bit messy, but could be used to get the caller.
    $ScriptPath = $MyInvocation.Line.Trim("`'. ") # No ScriptName if running this file directly, just Line = . 'D:\qt_projects\filmcab\simplified\_dot_include_standard_header.ps1'  This of course will devolve over PS versions. Why? Because developer constantly finesse stuff and break code.
}                                          
       

if ($IsWindows) { 
    $Script:OSPropertiesOfInterest = $(Get-CimInstance Win32_OperatingSystem) | Select *
}

$ConnectedToTheDNSServer = Test-Connection 'google.com' -Count 1 -Quiet
$ICMPEnabled             = ((Get-CIMInstance Win32_PingStatus -Filter "address='google.com'").StatusCode -eq 0)
$netstat                 = Get-NetAdapter|Where Name -eq 'Ethernet'|Where Virtual -eq $false|Select * # Ethernet, Status, MacAddress, LinkSpeed
$WakeOnLinkStatus        = Get-NetAdapterAdvancedProperty|Where Name -eq 'Ethernet'|Where DisplayName -eq 'Wake on Link Settings'|Select DisplayValue
$WakeOnMagicPacket       = Get-NetAdapterAdvancedProperty|Where Name -eq 'Ethernet'|Where DisplayName -eq 'Wake on Magic Packet'|Select DisplayValue
$WakeOnPatternMatch      = Get-NetAdapterAdvancedProperty|Where Name -eq 'Ethernet'|Where DisplayName -eq 'Wake on Pattern Match'|Select DisplayValue
$JumboPacket             = Get-NetAdapterAdvancedProperty|Where Name -eq 'Ethernet'|Where DisplayName -eq 'Jumbo Packet'|Select DisplayValue
$NicUltraLowPowerMode    = Get-NetAdapterAdvancedProperty|Where Name -eq 'Ethernet'|Where DisplayName -eq 'Ultra Low Power Mode'|Select DisplayValue
$IPState                 = Get-NetIPAddress|Where InterfaceAlias -eq 'Ethernet'
$IPCameFromDHCP          = ($IPState.PrefixOrigin -eq 'Dhcp')
$DNSAddress              = (@(Get-NetIPConfiguration|Select -expand DNSServer|Select *|Where AddressFamily -eq 2|Select ServerAddresses)[0]).ServerAddresses # 10.0.0.1
$GatewayStat             = Get-NetIPConfiguration|Select -expand IPv4DefaultGateway|Select *
$NetworkCategory         = (Get-NetConnectionProfile|Select NetworkCategory) # Private, Public, Domain
$AreWeInADomain          = (Get-NetConnectionProfile|Select DomainAuthenticationKind) # None
$ComputerInfo            = Get-ComputerInfo |Select *
$RunningAsAdmin          = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Put it all together

$SanityCheckStatus = [PSCustomObject]@{
    ComputerName               = $Script:OSPropertiesOfInterest.CSName                 # DSKTP-HOME-JEFF
    ComputerDescription        = $Script:OSPropertiesOfInterest.Description            # Jeff's Home Dev Client
    CurrentUserName            = $env:USERNAME                                         # jeffs  
    OSOwner                    = $ComputerInfo.WindowsRegisteredOwner                  # jeffshumphreys@outlook.com
    Platform                   = [System.Environment]::OSVersion.Platform              # Win32NT
    OS                         = $OS                                                   # Windows, Linux, or MacOS
    OSName                     = $ComputerInfo.OsName                                  # Microsoft Windows 10 Pro
    OSType                     = $ComputerInfo.OsType                                  # WINNT
    WindowsEdition             = $ComputerInfo.WindowsEditionId                        # Professional
    ProductType                = $ComputerInfo.OsProductType                           # Workstation
    ComputerRole               = $ComputerInfo.CsDomainRole                            # StandaloneWorkstation
    PowerPlatformRole          = $ComputerInfo.PowerPlatformRole                       # Desktop
    OSVersion                  = [Environment]::OSVersion.Version.ToString()           # 10.0.19045 (Really should be 1904.5)
    OSMajorVersionNo           = [Environment]::OSVersion.Version.Major                # 10
    OSMinorVersionNo           = [Environment]::OSVersion.Version.Minor                # 0
    OSBuildNo                  = [Environment]::OSVersion.Version.Build                # 19045
    OSArchitecture             = $Script:OSPropertiesOfInterest.OSArchitecture         # 64-bit
    OSInstallDate              = $Script:OSPropertiesOfInterest.InstallDate            # 2023-09-22T21:04:52-06:00
    ComputerLastBooted         = $Script:OSPropertiesOfInterest.LastBootUpTime         # 2024-01-25T15:12:49.417615-07:00
    OSSoftwareSerialNo         = $Script:OSPropertiesOfInterest.SerialNumber           # 00330-50141-73696-AAOEM
    HyperVisor                 = $ComputerInfo.HyperVisorPresent                       # False

    <### Local ###>

    KeyboardLayout             = $ComputerInfo.KeyboardLayout                          # en-US
    OSLanguage                 = $ComputerInfo.OsLanguage                              # en-US
    OSCodeSet                  = $ComputerInfo.OsCodeSet                               # 1252
    DSTEnabled                 = $ComputerInfo.CsDaylightInEffect                      # True
    TimeZone                   = $ComputerInfo.TimeZone                                # (UTC-07:00) Mountain Time (US & Canada)
    
    <### Network ###>
    
    AreWeConnectedToDNS        = $ConnectedToTheDNSServer                              # true
    AreWeAbleToPing            = $ICMPEnabled                                          # true
    NicName                    = $netstat.ifName                                       # ethernet_32769
    NicDescription             = $netstat.ifDesc                                       # Intel(R) Ethernet Connection (2) I219-LM
    NicStatus                  = $netstat.ifOperStatus.ToSTring()                      # Up
    NicConnectionStatus        = $netstat.MediaConnectionState.ToString()              # Connected
    NicSpeed                   = $netstat.LinkSpeed                                    # 1 Gbps
    NicMacAddress              = $netstat.MacAddress                                   #
    NicLUID                    = $netstat.NetLuid                                      # 1689399632855040
    NicInterfaceGUID           = $netstat.InterfaceGuid                                #
    NicDriverLevel             = $netstat.MediaType                                    # 802.3
    NicUltraLowPowerMode       = $NicUltraLowPowerMode.DisplayValue                    # Enabled
    IPAddress                  = $IPState.IPAddress                                    #
    DNSAddress                 = $DNSAddress[0]                                        #
    IPAddressFamily            = $IPState.AddressFamily.ToSTring()                     # IPv4
    IPAddressCameFromDHCP      = $IPCameFromDHCP                                       # true
    GatewayState               = $GatewayStat.State.ToString()                         # Alive
    GatewayIsStatic            = $GatewayStat.IsStatic                                 # null
    AreWeInADomain             = $AreWeInADomain.DomainAuthenticationKind.ToString()   # None
    AreWeInAWorkgroup          = $ComputerInfo.CsWorkgroup                             # WORKGROUP
    NetworkCategory            = $NetworkCategory.NetworkCategory.ToSTring()           # Private
        
    ScriptPath                 = $ThisScriptPath                                       # D:\qt_projects\filmcab\simplified\shared_code\__sanity_check_without_db_connection.ps1

    CurrentDirectory           = [System.Environment]::CurrentDirectory                # D:\qt_projects\filmcab
    PowerShellVersion          = $PSVersionTable.PSVersion                             # 7.4.1
    PowerShellEdition          = $PSVersionTable.PSEdition                             # Core
    PowerShellPlatform         = ([System.Environment]::OSVersion.Platform)             # Win32NT

    UserIsRunningInteractively = [Environment]::UserInteractive
    IsPrivilegedProcess        = $RunningAsAdmin
    # TypeOfRoute
    # Lease Expires
    # NetBIOS over Tcpip enabled?
    # Firewall, VPN, 
}
      
# Events:
# - 41 - The device did not restart correctly using a clean shutdown first. This event could be caused if the computer stopped responding, crashed, or lost power unexpectedly.
# - 1074 — This event is triggered when the user initiates a manual shutdown or restart. Or when the system restarts automatically to apply updates, for example. If you were using the shutdown command with a custom message, the information would be recorded in the "Comment" section.
# - 6006 — This event is logged when the Event Log system has been stopped by during a good shutdown. This error usually happens after error 1074.
# - 6005 — This event was logged when the Event Log system started, which can indicate when the computer was started.
# - 6008 — Indicates that the previous system shutdown was unexpected. This error will usually happen after error 41.

<#
Get-WinEvent -FilterHashtable @{ LogName = 'System'; Id = 41, 1074, 6005, 6006, 6605, 6008; } |Sort TimeCreated | Format-Table Id, TimeCreated, Message

PS D:\qt_projects\filmcab> Get-ComputerInfo |Select *

1074 2/6/2024 2:46:41 PM    The process C:\Windows\System32\RuntimeBroker.exe (DSKTP-HOME-JEFF) has initiated the restart of computer DSKTP-HOME-JEFF on behalf of user DSKTP-HOME-JEFF\jeffs for the following reason: Other (Unplanned)…
6006 2/6/2024 2:48:01 PM    The Event log service was stopped.
6005 2/6/2024 2:49:30 PM    The Event log service was started.

1074 10/27/2023 9:17:01 AM  The process C:\WINDOWS\system32\svchost.exe (DSKTP-HOME-JEFF) has initiated the restart of computer DSKTP-HOME-JEFF on behalf of user NT AUTHORITY\SYSTEM for the following reason: Operating System: Service pack (Planned)…       
6006 10/27/2023 9:17:31 AM  The Event log service was stopped.
  41 10/27/2023 9:18:49 AM  Hypervisor launch failed; Either VMX not present or not enabled in BIOS.
6005 10/27/2023 9:19:48 AM  The Event log service was started.

1074 12/22/2023 8:39:23 PM  The process C:\WINDOWS\system32\winlogon.exe (DSKTP-HOME-JEFF) has initiated the restart of computer DSKTP-HOME-JEFF on behalf of user DSKTP-HOME-JEFF\jeffs for the following reason: No title for this reason could be found…     
6006 12/22/2023 8:41:00 PM  The Event log service was stopped.
6005 12/22/2023 8:42:31 PM  The Event log service was started.

1074 11/14/2023 8:52:02 PM  The process C:\WINDOWS\system32\svchost.exe (DSKTP-HOME-JEFF) has initiated the restart of computer DSKTP-HOME-JEFF on behalf of user NT AUTHORITY\SYSTEM for the following reason: Operating System: Service pack (Planned)… 
1074 11/19/2023 6:22:44 PM  The process C:\Windows\System32\RuntimeBroker.exe (DSKTP-HOME-JEFF) has initiated the power off of computer DSKTP-HOME-JEFF on behalf of user DSKTP-HOME-JEFF\jeffs for the following reason: Other (Unplanned)…
1074 11/21/2023 5:29:56 PM  The process C:\Windows\System32\RuntimeBroker.exe (DSKTP-HOME-JEFF) has initiated the restart of computer DSKTP-HOME-JEFF on behalf of user DSKTP-HOME-JEFF\jeffs for the following reason: Other (Unplanned)…
1074 12/22/2023 8:39:23 PM  The process C:\WINDOWS\system32\winlogon.exe (DSKTP-HOME-JEFF) has initiated the restart of computer DSKTP-HOME-JEFF on behalf of user DSKTP-HOME-JEFF\jeffs for the following reason: No title for this reason could be found…   
1074 12/23/2023 3:19:34 PM  The process C:\WINDOWS\system32\ShutDown.exe (DSKTP-HOME-JEFF) has initiated the restart of computer DSKTP-HOME-JEFF on behalf of user NT AUTHORITY\SYSTEM for the following reason: No title for this reason could be found…    
1074 12/24/2023 8:17:09 AM  The process C:\WINDOWS\system32\MusNotificationUx.exe (DSKTP-HOME-JEFF) has initiated the restart of computer DSKTP-HOME-JEFF on behalf of user DSKTP-HOME-JEFF\jeffs for the following reason: Operating System: Service pack (Pl…
1074 1/12/2024 2:35:56 PM  The process C:\WINDOWS\servicing\TrustedInstaller.exe (DSKTP-HOME-JEFF) has initiated the restart of computer DSKTP-HOME-JEFF on behalf of user NT AUTHORITY\SYSTEM for the following reason: Operating System: Upgrade (Planned)… 
1074 1/20/2024 10:42:02 PM  The process C:\ProgramData\Package Cache\{21d8d079-98dc-4a70-bebc-c360bb860ae0}\dotnet-sdk-6.0.321-win-x64.exe (DSKTP-HOME-JEFF) has initiated the restart of computer DSKTP-HOME-JEFF on behalf of user DSKTP-HOME-JEFF\jeffs for… 



WindowsBuildLabEx                                       : 19041.1.amd64fre.vb_release.191206-1406
WindowsCurrentVersion                                   : 6.3
WindowsEditionId                                        : Professional
WindowsInstallationType                                 : Client
WindowsInstallDateFromRegistry                          : 9/23/2023 3:04:52 AM
WindowsProductId                                        : 00330-50141-73696-AAOEM
WindowsProductName                                      : Windows 10 Pro
WindowsRegisteredOrganization                           : 
WindowsRegisteredOwner                                  : jeffshumphreys@outlook.com
WindowsSystemRoot                                       : C:\WINDOWS
WindowsVersion                                          : 2009
WindowsUBR                                              : 3930
BiosCharacteristics                                     : {7, 9, 11, 12…}
BiosBIOSVersion                                         : {DELL   - 1072009, 2.27.0, American Megatrends - 5000B}
BiosBuildNumber                                         : 
BiosCaption                                             : 2.27.0
BiosCodeSet                                             : 
BiosCurrentLanguage                                     : en|US|iso8859-1
BiosDescription                                         : 2.27.0
BiosEmbeddedControllerMajorVersion                      : 255
BiosEmbeddedControllerMinorVersion                      : 255
BiosFirmwareType                                        : Uefi
BiosIdentificationCode                                  : 
BiosInstallableLanguages                                : 2
BiosInstallDate                                         : 
BiosLanguageEdition                                     : 
BiosListOfLanguages                                     : {en|US|iso8859-1, }
BiosManufacturer                                        : Dell Inc.
BiosName                                                : 2.27.0
BiosOtherTargetOS                                       : 
BiosPrimaryBIOS                                         : True
BiosReleaseDate                                         : 9/16/2023 6:00:00 PM
BiosSerialNumber                                        : FQMNXM2
BiosSMBIOSBIOSVersion                                   : 2.27.0
BiosSMBIOSMajorVersion                                  : 3
BiosSMBIOSMinorVersion                                  : 0
BiosSMBIOSPresent                                       : True
BiosSoftwareElementState                                : Running
BiosStatus                                              : OK
BiosSystemBiosMajorVersion                              : 2
BiosSystemBiosMinorVersion                              : 27
BiosTargetOperatingSystem                               : 0
BiosVersion                                             : DELL   - 1072009
CsAdminPasswordStatus                                   : Unknown
CsAutomaticManagedPagefile                              : True
CsAutomaticResetBootOption                              : True
CsAutomaticResetCapability                              : True
CsBootOptionOnLimit                                     : 
CsBootOptionOnWatchDog                                  : 
CsBootROMSupported                                      : True
CsBootStatus                                            : {0, 0, 0, 0…}
CsBootupState                                           : Normal boot
CsCaption                                               : DSKTP-HOME-JEFF
CsChassisBootupState                                    : Safe
CsChassisSKUNumber                                      : Desktop
CsCurrentTimeZone                                       : -420
CsDaylightInEffect                                      : False
CsDescription                                           : AT/AT COMPATIBLE
CsDNSHostName                                           : DSKTP-HOME-JEFF
CsDomain                                                : WORKGROUP
CsDomainRole                                            : StandaloneWorkstation
CsEnableDaylightSavingsTime                             : True
CsFrontPanelResetStatus                                 : Unknown
CsHypervisorPresent                                     : False
CsInfraredSupported                                     : False
CsInitialLoadInfo                                       : 
CsInstallDate                                           : 
CsKeyboardPasswordStatus                                : Unknown
CsLastLoadInfo                                          : 
CsManufacturer                                          : Dell Inc.
CsModel                                                 : Precision Tower 3420
CsName                                                  : DSKTP-HOME-JEFF
CsNetworkAdapters                                       : {Ethernet, vEthernet (Default Switch)}
CsNetworkServerModeEnabled                              : True
CsNumberOfLogicalProcessors                             : 8
CsNumberOfProcessors                                    : 1
CsProcessors                                            : {Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz}
CsOEMStringArray                                        : {Dell System, 1[06C7], 3[1.0], 12[www.dell.com]…}
CsPartOfDomain                                          : False
CsPauseAfterReset                                       : -1
CsPCSystemType                                          : Desktop
CsPCSystemTypeEx                                        : Desktop
CsPowerManagementCapabilities                           : 
CsPowerManagementSupported                              : 
CsPowerOnPasswordStatus                                 : Unknown
CsPowerState                                            : Unknown
CsPowerSupplyState                                      : Safe
CsPrimaryOwnerContact                                   : 
CsPrimaryOwnerName                                      : jeffshumphreys@outlook.com
CsResetCapability                                       : Other
CsResetCount                                            : -1
CsResetLimit                                            : -1
CsRoles                                                 : {LM_Workstation, LM_Server, NT}
CsStatus                                                : OK
CsSupportContactDescription                             : 
CsSystemFamily                                          : Precision
CsSystemSKUNumber                                       : 06C7
CsSystemType                                            : x64-based PC
CsThermalState                                          : Safe
CsTotalPhysicalMemory                                   : 68565356544
CsPhysicallyInstalledMemory                             : 67108864
CsUserName                                              : DSKTP-HOME-JEFF\jeffs
CsWakeUpType                                            : PowerSwitch
CsWorkgroup                                             : WORKGROUP
OsName                                                  : Microsoft Windows 10 Pro
OsType                                                  : WINNT
OsOperatingSystemSKU                                    : 48
OsVersion                                               : 10.0.19045
OsCSDVersion                                            : 
OsBuildNumber                                           : 19045
OsHotFixes                                              : {KB5033918, KB5030841, KB5007401, KB5011048…}
OsBootDevice                                            : \Device\HarddiskVolume2
OsSystemDevice                                          : \Device\HarddiskVolume6
OsSystemDirectory                                       : C:\WINDOWS\system32
OsSystemDrive                                           : C:
OsWindowsDirectory                                      : C:\WINDOWS
OsCountryCode                                           : 1
OsCurrentTimeZone                                       : -420
OsLocaleID                                              : 0409
OsLocale                                                : en-US
OsLocalDateTime                                         : 2/9/2024 3:58:16 PM
OsLastBootUpTime                                        : 2/6/2024 2:49:17 PM
OsUptime                                                : 3.01:08:59.1725268
OsBuildType                                             : Multiprocessor Free
OsCodeSet                                               : 1252
OsDataExecutionPreventionAvailable                      : True
OsDataExecutionPrevention32BitApplications              : True
OsDataExecutionPreventionDrivers                        : True
OsDataExecutionPreventionSupportPolicy                  : OptIn
OsDebug                                                 : False
OsDistributed                                           : False
OsEncryptionLevel                                       : 256
OsForegroundApplicationBoost                            : Maximum
OsTotalVisibleMemorySize                                : 66958356
OsFreePhysicalMemory                                    : 48258888
OsTotalVirtualMemorySize                                : 76919828
OsFreeVirtualMemory                                     : 46592372
OsInUseVirtualMemory                                    : 30327456
OsTotalSwapSpaceSize                                    : 
OsSizeStoredInPagingFiles                               : 9961472
OsFreeSpaceInPagingFiles                                : 9887436
OsPagingFiles                                           : {C:\pagefile.sys}
OsHardwareAbstractionLayer                              : 10.0.19041.3636
OsInstallDate                                           : 9/22/2023 9:04:52 PM
OsManufacturer                                          : Microsoft Corporation
OsMaxNumberOfProcesses                                  : 4294967295
OsMaxProcessMemorySize                                  : 137438953344
OsMuiLanguages                                          : {en-US}
OsNumberOfLicensedUsers                                 : 0
OsNumberOfProcesses                                     : 278
OsNumberOfUsers                                         : 2
OsOrganization                                          : 
OsArchitecture                                          : 64-bit
OsLanguage                                              : en-US
OsProductSuites                                         : {TerminalServicesSingleSession}
OsOtherTypeDescription                                  : 
OsPAEEnabled                                            : 
OsPortableOperatingSystem                               : False
OsPrimary                                               : True
OsProductType                                           : WorkStation
OsRegisteredUser                                        : jeffshumphreys@outlook.com
OsSerialNumber                                          : 00330-50141-73696-AAOEM
OsServicePackMajorVersion                               : 0
OsServicePackMinorVersion                               : 0
OsStatus                                                : OK
OsSuites                                                : {TerminalServices, TerminalServicesSingleSession}
OsServerLevel                                           : 
KeyboardLayout                                          : en-US
TimeZone                                                : (UTC-07:00) Mountain Time (US & Canada)
LogonServer                                             : \\DSKTP-HOME-JEFF
PowerPlatformRole                                       : Desktop
HyperVisorPresent                                       : False
HyperVRequirementDataExecutionPreventionAvailable       : True
HyperVRequirementSecondLevelAddressTranslation          : True
HyperVRequirementVirtualizationFirmwareEnabled          : True
HyperVRequirementVMMonitorModeExtensions                : True
DeviceGuardSmartStatus                                  : Off
DeviceGuardRequiredSecurityProperties                   : 
DeviceGuardAvailableSecurityProperties                  : 
DeviceGuardSecurityServicesConfigured                   : 
DeviceGuardSecurityServicesRunning                      : 
DeviceGuardCodeIntegrityPolicyEnforcementStatus         : 
DeviceGuardUserModeCodeIntegrityPolicyEnforcementStatus : 

#>
$LogDate = (Get-Date).Date.ToString('yyyy-MM-dd')
$OutFilePath = "D:\qt_projects\filmcab\simplified\_log\__sanity_checks\__sanity_check_$when`_$stage.json"
$HistoryFilePath = "D:\qt_projects\filmcab\simplified\_log\__sanity_checks\history\$LogDate`__sanity_check_$when`_$stage.json"

$SanityCheckStatus|ConvertTo-Json|Out-File $OutFilePath

Copy-Item $OutFilePath -Destination $HistoryFilePath

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

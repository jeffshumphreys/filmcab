
Add-Type -name user32 -namespace win32 -memberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
$consoleHandle = (get-process -id $pid).mainWindowHandle
[void][win32.user32]::showWindow($consoleHandle, 0)

############## Environment things FORCED on the user of this dot file.

# Stop on an error, please.  Lazy shits at City of Boise prefer scripts that NEVER error in production - even if there's an issue.
$ErrorActionPreference = 'Stop'            

# This makes the run Stop if attempting to use an unassigned variable. Lazy shits at City of Boise prefer scripts that NEVER error in production - even if there's an issue. How did I ever survive in this crap worthless world of hacks???

Set-StrictMode -Version Latest

Write-Host $fh # Undefined variable referenced

<#
InvalidOperation: D:\qt_projects\filmcab\simplified\test idea\test_bad_syntax_err_bubbles_to_scheduler.ps1:15:12
Line |
  15 |  Write-Host $fh # Undefined variable referenced
     |             ~~~
     | The variable '$fh' cannot be retrieved because it has not been set.
#>
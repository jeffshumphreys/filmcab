
Add-Type -name user32 -namespace win32 -memberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
$consoleHandle = (get-process -id $pid).mainWindowHandle
[void][win32.user32]::showWindow($consoleHandle, 0)

############## Environment things FORCED on the user of this dot file.

# Stop on an error, please.  Lazy shits at City of Boise prefer scripts that NEVER error in production - even if there's an issue.
$ErrorActionPreference = 'Stop'            

# This makes the run Stop if attempting to use an unassigned variable. Lazy shits at City of Boise prefer scripts that NEVER error in production - even if there's an issue. How did I ever survive in this crap worthless world of hacks???

Set-StrictMode -Version Latest
try {
  Write-Host $fh # Undefined variable referenced
}
catch {
  SET LASTEXITCODE = 2
}
<#

#>
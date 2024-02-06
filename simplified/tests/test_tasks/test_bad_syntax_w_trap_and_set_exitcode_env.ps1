
Add-Type -name user32 -namespace win32 -memberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
$consoleHandle = (get-process -id $pid).mainWindowHandle
[void][win32.user32]::showWindow($consoleHandle, 0)

############## Environment things FORCED on the user of this dot file.

# Stop on an error, please.  Lazy shits at City of Boise prefer scripts that NEVER error in production - even if there's an issue.
$ErrorActionPreference = 'Stop'            

# This makes the run Stop if attempting to use an unassigned variable. Lazy shits at City of Boise prefer scripts that NEVER error in production - even if there's an issue. How did I ever survive in this crap worthless world of hacks???

Set-StrictMode -Version Latest
$Exception = $null
    
switch (3) {
  1 {try {Write-Host $IdoNotExist} catch {$Exception = $_.Exception }}# -2146233087
  2 {try {1 / 0} catch {$Exception = $_.Exception } } # -2147352558
  3 {[Int32]$i = [Int32]::MaxValue; try {$i + [Int32]::MaxValue|Out-Null } catch {$Exception = $_.Exception } } 
  # 4: Connect to database
  # 5 Read non-existent file
  default {
    
  }
}
                                                  
$HResult = 0

if ($Exception) {
  if ($Exception.InnerException) {
    $HResult = $Exception.InnerException.HResult # 
  } else {
    $HResult = $Exception.HResult
  }                              
  if ($Exception.ErrorRecord) { Write-Host "Error Record= $($Exception.ErrorRecord)"}
  # ([Int32]"0x80131501") ==> -2146233087 CORRECT! What HResult was.
  # EventData\Data\ResultCode=2148734209 "{0:X}" -f 2148734209 ==> 80131501 CORRECT. Do not use Format-Hex.
}

$HResult
exit $HResult # Populates $LASTEXITCODE
<#
ErrorRecord                 : The variable '$IdoNotExist' cannot be retrieved because it has not been set.
WasThrownFromThrowStatement : False
TargetSite                  : Void CheckActionPreference(System.Management.Automation.Language.FunctionContext, System.Exception)
Message                     : The variable '$IdoNotExist' cannot be retrieved because it has not been set.
Data                        : {[System.Management.Automation.Interpreter.InterpretedFrameInfo, System.Management.Automation.Interpreter.InterpretedFrameInfo[]]}
InnerException              :
HelpLink                    :
Source                      : System.Management.Automation
HResult                     : -2146233087
StackTrace                  :    at System.Management.Automation.ExceptionHandlingOps.CheckActionPreference(FunctionContext funcContext, Exception exception)
                                 at System.Management.Automation.Interpreter.ActionCallInstruction`2.Run(InterpretedFrame frame)
                                 at System.Management.Automation.Interpreter.EnterTryCatchFinallyInstruction.Run(InterpretedFrame frame)
                                 at System.Management.Automation.Interpreter.EnterTryCatchFinallyInstruction.Run(InterpretedFrame frame)
#>
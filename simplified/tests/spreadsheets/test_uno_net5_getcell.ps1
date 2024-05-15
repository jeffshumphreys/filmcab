Start-Process -NoNewWindow soffice -ArgumentList "--accept=pipe,name=foo;urp; --nologo --headless --nofirststartwizard --invisible" >output.msg 2> output.err
Get-Process|Where processname -like 'so*'|Select Name, StartTime, Responding, ProductVersion, HasExited|Format-Table
$emptyproperties = [unoidl.com.sun.star.beans.PropertyValue[]]::new(0)

[System.Reflection.Assembly]::LoadWithPartialName('cli_basetypes')|Out-Null
[System.Reflection.Assembly]::LoadWithPartialName('cli_cppuhelper')|Out-Null
[System.Reflection.Assembly]::LoadWithPartialName('cli_oootypes'  )|Out-Null
[System.Reflection.Assembly]::LoadWithPartialName('cli_ure'       )|Out-Null
[System.Reflection.Assembly]::LoadWithPartialName('cli_uretypes'  )|Out-Null

 $fileInputPath        = "D:\qt_projects\filmcab\simplified\tests\user_spreadsheet_interface_test_copy.ods"
     $fileInput        = "$fileInputPath"
     $fileInput        = "file:///" + $fileInput.Replace("\", "/")

 $fileOutputPath       = "D:\qt_projects\filmcab\simplified\tests\user_spreadsheet_interface_test_copy_output.ods"
     $fileOutput       = "$fileOutputPath"
     $fileOutput       = "file:///" + $fileOutput.Replace("\", "/")

$localContext             = [uno.util.Bootstrap]::Bootstrap()

$multiComponentFactory    = [unoidl.com.sun.star.uno.XComponentContext].      getMethod('getServiceManager').invoke($localContext, @())
$urlResolver              = [unoidl.com.sun.star.lang.XMultiComponentFactory].getMethod('createInstanceWithContext').invoke($multiComponentFactory, @('com.sun.star.bridge.UnoUrlResolver', $localContext))
$remoteContext            = [unoidl.com.sun.star.bridge.XUnoUrlResolver].     getMethod('resolve').Invoke($urlResolver, @('uno:pipe,name=foo;urp;StarOffice.ComponentContext'))
$rmultiComponentFactory   = [unoidl.com.sun.star.uno.XComponentContext].      getMethod('getServiceManager').invoke($remoteContext, @())
$desktop                  = [unoidl.com.sun.star.lang.XMultiComponentFactory].getMethod('createInstanceWithContext').invoke($rmultiComponentFactory, @('com.sun.star.frame.Desktop', $remoteContext))
$emptyproperties          = [unoidl.com.sun.star.beans.PropertyValue[]]::new(0)
$calc                     = [unoidl.com.sun.star.frame.XComponentLoader].getMethod('loadComponentFromURL').invoke($desktop, @($fileInput, '_default', 0, $emptyproperties))
$sheets                   = [unoidl.com.sun.star.sheet.XSpreadsheetDocument]. getMethod('getSheets').invoke($calc, @())
$sheet                    = [unoidl.com.sun.star.container.XIndexAccess].     getMethod('getByIndex').invoke($sheets, @(0))
$cell                     = [unoidl.com.sun.star.table.XCellRange].           getMethod('getCellByPosition').invoke($sheet.Value, @(0,0))
[unoidl.com.sun.star.table.XCell].getMethod('getFormula').Invoke($cell, $emptyproperties)
# seen

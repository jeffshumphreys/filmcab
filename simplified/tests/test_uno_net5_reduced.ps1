
# FOLLOWING MUST BE RUNNING!!!!!!!!!!!!!!!!!!!!!!!!!

#  soffice "--accept=socket,host=localhost,port=2002;urp;"
#  soffice "--accept=pipe,name=foo;urp;"
#  soffice "--accept=pipe,name=foo;urp;" --nologo --headless --nofirststartwizard --invisible


#  /usr/lib/openoffice/program/soffice.bin -accept='pipe,name=foo;urp;StarOffice.ServiceManager'--nologo --headless --nofirststartwizard --invisible

[System.Reflection.Assembly]::LoadWithPartialName('cli_basetypes')
[System.Reflection.Assembly]::LoadWithPartialName('cli_cppuhelper')
[System.Reflection.Assembly]::LoadWithPartialName('cli_oootypes'  )
[System.Reflection.Assembly]::LoadWithPartialName('cli_ure'       )
[System.Reflection.Assembly]::LoadWithPartialName('cli_uretypes'  )

 $mainFilePath     = "D:\qt_projects\filmcab\simplified\tests\user_spreadsheet_interface_test_copy.ods"
     $fileInput        = "$mainFilePath"
     $fileInput        = "file:///" + $fileInput.Replace("\", "/")

#$env:UNO_PATH          = "C:\Program Files\LibreOffice\program"
#$env:URE_BOOTSTRAP     = "C:\Program Files\LibreOffice\program\fundamental.ini"

#$ht = [System.Collections.Hashtable]::new()
#$ht.Add("SYSBINDIR", "file:///C:/Program Files/LibreOffice/program");

# https://wiki.openoffice.org/wiki/Documentation/DevGuide/OfficeDev/Using_the_Desktop

#String[] cmdArray = new String[3];
#cmdArray[0] = "soffice";
#cmdArray[1] = "-headless";
#cmdArray[2] = "-accept=socket,host=localhost,port=" + SOCKET_PORT + ";urp;";
#Process p = Runtime.getRuntime().exec(cmdArray);

#$localContext             = [uno.util.Bootstrap]::defaultBootstrap_InitialComponentContext("file:///C:/Program Files/LibreOffice/program/uno.ini", $ht.GetEnumerator())
$localContext             = [uno.util.Bootstrap]::Bootstrap()
# Bootstrap.bootstrap() sets up a remote component context based on named pipes

$multiComponentFactory    = [unoidl.com.sun.star.uno.XComponentContext].      getMethod('getServiceManager').invoke($localContext, @())
$urlResolver              = [unoidl.com.sun.star.lang.XMultiComponentFactory].getMethod('createInstanceWithContext').invoke($multiComponentFactory, @('com.sun.star.bridge.UnoUrlResolver', $localContext))
if ($null -eq $urlResolver)
{
    throw "Bridge Uno Url Resolver Service not available"
}
#$remoteContext = [unoidl.com.sun.star.bridge.XUnoUrlResolver].getMethod('resolve').Invoke($urlResolver, @('uno:socket,host=localhost,port=2002;urp;StarOffice.ComponentContext'))
$remoteContext = [unoidl.com.sun.star.bridge.XUnoUrlResolver].getMethod('resolve').Invoke($urlResolver, @('uno:pipe,name=foo;urp;StarOffice.ComponentContext'))
$rmultiComponentFactory    = [unoidl.com.sun.star.uno.XComponentContext].      getMethod('getServiceManager').invoke($remoteContext, @())

$desktop              = [unoidl.com.sun.star.lang.XMultiComponentFactory].getMethod('createInstanceWithContext').invoke($rmultiComponentFactory, @('com.sun.star.frame.Desktop', $remoteContext))
$emptyproperties = [unoidl.com.sun.star.beans.PropertyValue[]]::new(0)
$fileInput
# file:///D:/qt_projects/filmcab/simplified/tests/user_spreadsheet_interface_test_copy.ods
# file:///c:/WINDOWS/clock.avi

$calc                     = [unoidl.com.sun.star.frame.XComponentLoader].getMethod('loadComponentFromURL').invoke($desktop, @($fileInput, '_default', 0, $emptyproperties))
#Exception calling "Invoke" with "2" argument(s): "Object does not match target type."
# Error not involved with if file exists.
# soffice is closed so not that.

$sheets                   = [unoidl.com.sun.star.sheet.XSpreadsheetDocument]. getMethod('getSheets').invoke($calc, @())
$sheet                    = [unoidl.com.sun.star.container.XIndexAccess].     getMethod('getByIndex').invoke($sheets, @(0))
$cell                     = [unoidl.com.sun.star.table.XCellRange].           getMethod('getCellByPosition').invoke($sheet.Value, @(0,0))
                            [unoidl.com.sun.star.table.XCell].                getMethod('setFormula').invoke($cell, @('A value in cell A1.'))
                            [unoidl.com.sun.star.frame.XStorable].            getMethod('storeToURL').Invoke($calc, @($fileOutput, [unoidl.com.sun.star.beans.PropertyValue[]]$fileProps))

                            [unoidl.com.sun.star.]
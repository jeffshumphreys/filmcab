# Install-Package Independentsoft.Office.Odf

#Name                           Version          Source           Summary                                                                                                                                                                                                                                         
#----                           -------          ------           -------                                                                                                                                                                                                                                         
#Independentsoft.Office.Odf     2.0.770          nuget.org        Independentsoft.Office.Odf is Open Document Format API for .NET Framework, .NET Core, .NET Standard, Mono, Xamarin.                                                                                                                             

[DocumentFormat.OpenXml.Spreadsheet.SpreadsheetDocument]::Create("x")

$spreadsheet = [Independentsoft.Office.Calc]::new()
[System.Reflection.Assembly]::LoadWithPartialName('cli_basetypes')
[System.Reflection.Assembly]::LoadWithPartialName('cli_cppuhelper')
[System.Reflection.Assembly]::LoadWithPartialName('cli_oootypes'  )
[System.Reflection.Assembly]::LoadWithPartialName('cli_ure'       )
[System.Reflection.Assembly]::LoadWithPartialName('cli_uretypes'  )

 $inputFilePath     = "D:\qt_projects\filmcab\simplified\tests\user_spreadsheet_interface_test_copy.ods"
     $fileInput        = "$inputFilePath"
     $fileInput        = "file:///" + $fileInput.Replace("\", "/")

$env:UNO_PATH          = "C:\Program Files\LibreOffice\program"
$env:URE_BOOTSTRAP     = "C:\Program Files\LibreOffice\program\fundamental.ini"

$ht = [System.Collections.Hashtable]::new()
$ht.Add("SYSBINDIR", "file:///C:/Program Files/LibreOffice/program");

# https://wiki.openoffice.org/wiki/Documentation/DevGuide/OfficeDev/Using_the_Desktop

$localContext             = [uno.util.Bootstrap]::defaultBootstrap_InitialComponentContext("file:///C:/Program Files/LibreOffice/program/uno.ini", $ht.GetEnumerator())

$multiComponentFactory    = [unoidl.com.sun.star.uno.XComponentContext].      getMethod('getServiceManager').invoke($localContext, @())

                            [unoidl.com.sun.star.lang.XMultiComponentFactory].getMethod('getAvailableServiceNames').invoke($multiComponentFactory, @())

$urlResolver              = [unoidl.com.sun.star.lang.XMultiComponentFactory].getMethod('createInstanceWithContext').invoke($multiComponentFactory, @('com.sun.star.bridge.UnoUrlResolver', $localContext))
if ($null -eq $urlResolver)
{
    throw "Bridge Uno Url Resolver Service not available"
}
$x = [UnoRuntime]::queryInterface()

$xUnoUrlResolver = [unoidl.com.sun.star.bridge.XUnoUrlResolver].getMethod('queryInterface').Invoke($urlResolver)

$xUnoUrlResolver = [unoidl.com.sun.star.uno.XUnoUrlResolver].getMethod('queryInterface').Invoke($urlResolver, @('uno:socket,host=localhost,port=2083;urp;StarOffice.ServiceManager'))

$initialObject                  = [unoidl.com.sun.star.Bridge.UnoUrlResolver].getMethod('resolve').invoke($urlResolver, $localContext)

#$desktop                   = [unoidl.com.sun.star.lang.XMultiComponentFactory].getMethod('createInstanceWithContext').invoke($multiComponentFactory, @('com.sun.star.frame.Desktop', $localContext))
 #             Object initialObject = xUnoUrlResolver.resolve( 
 #                 "uno:socket,host=localhost,port=2083;urp;StarOffice.ServiceManager" );
 #             XPropertySet xPropertySet = (XPropertySet)UnoRuntime.queryInterface(
 #                 XPropertySet.class, initialObject);
 #             Object context = xPropertySet.getPropertyValue("DefaultContext");
 #             xRemoteContext = (XComponentContext)UnoRuntime.queryInterface(
 #                 XComponentContext.class, context);
 #             xRemoteServiceManager = xRemoteContext.getServiceManager();
#
    #          // get Desktop instance
    #          Object desktop = xRemoteServiceManager.createInstanceWithContext ("com.sun.star.frame.Desktop", xRemoteContext);
    #          xDesktop = (XDesktop)UnoRuntime.queryInterface(XDesktop.class, desktop);
 #   if ($null -eq $desktop)
 #   {
 #       throw "Service not available"
 #   }
    #$emptyproperties = [unoidl.com.sun.star.beans.PropertyValue[]]::new(0)
    #$calc                     = [unoidl.com.sun.star.frame.XComponentLoader].getMethod('loadComponentFromURL').invoke($desktop, @($fileInput, '_blank', 0, $emptyproperties))
    #$calcCreated              = $true
    #$sheets                   = [unoidl.com.sun.star.sheet.XSpreadsheetDocument]. getMethod('getSheets').invoke($calc, @())
    #$sheet                    = [unoidl.com.sun.star.container.XIndexAccess].     getMethod('getByIndex').invoke($sheets, @(0))
    #$cell                     = [unoidl.com.sun.star.table.XCellRange].           getMethod('getCellByPosition').invoke($sheet.Value, @(0,0))
    #                            [unoidl.com.sun.star.table.XCell].                getMethod('setFormula').invoke($cell, @('A value in cell A1.'))
    #                            [unoidl.com.sun.star.frame.XStorable].            getMethod('storeToURL').Invoke($calc, @($fileOutput, [unoidl.com.sun.star.beans.PropertyValue[]]$fileProps))

#5.1.19041.4291

<#
com.sun.star.io.DataOutputStream
com.sun.star.bridge.BridgeFactory
com.sun.star.io.Pump
com.sun.star.loader.Java
com.sun.star.io.DataInputStream
com.sun.star.io.ObjectOutputStream
com.sun.star.io.MarkableInputStream
com.sun.star.java.JavaVirtualMachine
com.sun.star.io.MarkableOutputStream
com.sun.star.loader.SharedLibrary
com.sun.star.io.ObjectInputStream
com.sun.star.io.Pipe
com.sun.star.connection.Acceptor
com.sun.star.io.TextInputStream
com.sun.star.connection.Connector
com.sun.star.lang.ServiceManager
com.sun.star.io.TextOutputStream
com.sun.star.registry.ImplementationRegistration
com.sun.star.bridge.UnoUrlResolver
com.sun.star.registry.NestedRegistry
com.sun.star.uno.NamingService
com.sun.star.lang.RegistryServiceManager
com.sun.star.registry.SimpleRegistry
com.sun.star.security.Policy
com.sun.star.security.AccessController
com.sun.star.beans.Introspection
com.sun.star.script.InvocationAdapterFactory
com.sun.star.script.Invocation
com.sun.star.reflection.ProxyFactory
com.sun.star.uri.VndSunStarPkgUrlReferenceFactory
com.sun.star.reflection.CoreReflection
com.sun.star.script.Converter
com.sun.star.uri.ExternalUriReferenceTranslator
com.sun.star.uri.UriReferenceFactory
com.sun.star.loader.Java2
com.sun.star.uri.UriSchemeParser_vndDOTsunDOTstarDOTexpand
com.sun.star.uri.UriSchemeParser_vndDOTsunDOTstarDOTscript
#>
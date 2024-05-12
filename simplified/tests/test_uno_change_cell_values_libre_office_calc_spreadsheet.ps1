param([switch]$_restart)
if (-not $_restart) {
  powershell -Version 4 -File $MyInvocation.MyCommand.Definition -_restart
  exit
}

<#
    # https://forum.openoffice.org/en/forum/viewtopic.php?t=14018
    #https://www.openoffice.org/api/docs/common/ref/com/sun/star/frame/XComponentLoader.html
    #https://www.openoffice.org/api/docs/common/ref/com/sun/star/frame/XComponentLoader.html#loadComponentFromURL
    # CreateNew $calc                  = [unoidl.com.sun.star.frame.XComponentLoader].     getMethod('loadComponentFromURL').invoke($desktop, @('private:factory/scalc', '_blank', 0, <#unoidl.com.sun.star.beans.PropertyValue[]# >$null))
    # https://www.openoffice.org/api/docs/common/ref/com/sun/star/frame/XStorable.html#storeToURL
    # unoidl.com.sun.star.frame.XStorable storeToUrl FilterOptions
    # unoidl.com.sun.star.frame.XStorable storeToUrl MediaDescriptor
    https://marketplace.visualstudio.com/items?itemName=unoplatform.vscode
    https://platform.uno/vs-code/get-license/
    Request - Free License for Uno Platform Visual Studio Code plugin
    https://platform.uno/docs/articles/get-started-vscode.html?tabs=windows%2Cubuntu1804
    dotnet tool install -g uno.check    (Very sloooooooow)
    You can invoke the tool using the following command: uno-check
    Tool 'uno.check' (version '1.22.1') was successfully installed.
    https://platform.uno/docs/articles/create-an-app-vscode.html?tabs=Wasm
    .NET 8.0 LTS
    dotnet new unoapp -o FilmCab -preset "recommended" -theme-service  -theme "material" -presentation "mvux" -config  -di  -log "default" -nav "regions" -http  -loc  -tests "none" -toolkit  -dsp  -id "com.companyname.FilmCab" -pub "O=FilmCab"
    After all this weakBase loads.
    https://csharp.hotexamples.com/examples/-/unoidl.com.sun.star.table.CellRangeAddress/-/php-unoidl.com.sun.star.table.cellrangeaddress-class-examples.html
    Exception calling "bootstrap" with "0" argument(s): "Handle is not initialized."
    https://github.com/mlocati/libreoffice-uno-dotnet
    Version: 24.2.2.2 (X86_64) / LibreOffice Community
    Build ID: d56cc158d8a96260b836f100ef4b4ef25d6f1a01
    CPU threads: 8; OS: Windows 10.0 Build 19045; UI render: Skia/Raster; VCL: win
    Locale: en-US (en_US); UI: en-US
    Calc: CL threaded

    https://api.libreoffice.org/docs/install.html

    Duh!!!! get the SDK!!!!! (Oh, and update libre from 24.2.2.2 to 24.2.3 to avoid worrying)
    https://download.documentfoundation.org/libreoffice/stable/24.2.3/win/x86_64/LibreOffice_24.2.3_Win_x86-64_sdk.msi
    System.ArgumentNullException: Value cannot be null.
    em System.Threading.Monitor.Enter(Object obj)
    em cli_uno.Bridge.map_uno2cli(Bridge* , _uno_Interface* pUnoI, _typelib_InterfaceTypeDescription* pTD)
    em Mapping_uno2cli(_uno_Mapping* mapping, Void** ppOut, Void* pIn, _typelib_InterfaceTypeDescription* td)
    em com.sun.star.uno.Mapping.mapInterface(Mapping* , Void** ppOut, Void* pInterface, Type* rType)
    em uno.util.to_cli<class com::sun::star::uno::XComponentContext>(Reference<com::sun::star::uno::XComponentContext>* x)
    em uno.util.Bootstrap.bootstrap()
    dear developers, the solution was very simple: since the error contained System.Threading.Monitor.Enter(Object obj), so I had the idea of ​​putting the new version application in a separate Application Pool on the IIS, and it worked perfectly.
    $localContext = [uno.util.Bootstrap]::bootstrap('C:\Program Files\LibreOffice\program')
    (import ooo.connector.BootstrapSocketConnector;)
    String oooExeFolder = "C:/Program Files (x86)/OpenOffice 4/program/";
    XComponentContext xContext = BootstrapSocketConnector.bootstrap(oooExeFolder);
    C:\Program Files\LibreOffice\sdk
    https://sourceforge.net/projects/gnuwin32/files/make/3.81/make-3.81.exe/download?use_mirror=versaweb&download=
     ******************************************************************
    *
    *  You have to configure your SDK environment first before you can
    *  use it. The configuration has to be done only once.
    *
    ******************************************************************


    *** Configure your SDK environment ***

    NOTE: This script is working only for Windows 2000, Windows XP or newer versions!


    Enter the Office Software Development Kit directory [C:\Program Files\LibreOffice\sdk]:

    Enter the Office base installation directory [C:\Program Files\LibreOffice]:

    Enter GNU make (3.79.1 or higher) tools directory []:

    Error: Could not find directory "". GNU make is required, please specify a GNU make tools directory.

    Enter GNU make (3.79.1 or higher) tools directory []:

    C:\Gnuwin
    c:\libreoffice24.2_sdk
    $Request = Invoke-WebRequest -Uri https://git.libreoffice.org/lode/+/refs/heads/master/bin/install_cygwin.ps1?format=TEXT -UseBasicParsing; [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($Request.Content)) > install_cygwin.ps1; .\install_cygwin.ps1
    https://wiki.documentfoundation.org/Development/lode
    git clone https://gerrit.libreoffice.org/lode\
    jeffs@DSKTP-HOME-JEFF /cygdrive/d/qt_projects/filmcab/lode
    bash
    git clone https://gerrit.libreoffice.org/lode
    cd lode
    XComponentLoader loader = Lo.loadOffice();

    Our team updated an existing WinForm application to .net 6. Since this update we cannot open files with open office anymore. The SDK cannot be initialized anymore. The following code throws an exception:

    unoidl.com.sun.star.uno.XComponentContext m_xContext = uno.util.Bootstrap.bootstrap();
    exception: System.InvalidOperationException: 'Handle is not initialized.'

    With the old version ( 4.8 everything works fine) I already found two articles about it, but without any workaround/solution:

    https://wiki.openoffice.org/wiki/Documentation/DevGuide/ProUNO/CLI/Writing_Client_Programs
    [Environment]::Is64BitProcess = true
    https://bugs.documentfoundation.org/show_bug.cgi?id=148857
    https://github.com/dotnet/Open-XML-SDK/releases/tag/v2.5
    https://wiki.documentfoundation.org/LibreOffice_OOXML
#>

[System.Reflection.Assembly]::LoadWithPartialName('cli_basetypes')
[System.Reflection.Assembly]::LoadWithPartialName('cli_cppuhelper')
[System.Reflection.Assembly]::LoadWithPartialName('cli_oootypes'  )
[System.Reflection.Assembly]::LoadWithPartialName('cli_ure'       )
[System.Reflection.Assembly]::LoadWithPartialName('cli_uretypes'  )


$env:UNO_PATH          = "C:\Program Files\LibreOffice\program"
$env:URE_BOOTSTRAP     = "C:\Program Files\LibreOffice\program\fundamental.ini"

$ht = [System.Collections.Hashtable]::new()
$ht.Add("SYSBINDIR", "file:///C:/Program Files/LibreOffice/program");
#$localContext = [uno.util.Bootstrap]::defaultBootstrap_InitialComponentContext("file:///C:/Program Files/LibreOffice/program/uno.ini", $ht.GetEnumerator())
#  Exception calling "defaultBootstrap_InitialComponentContext" with "2" argument(s): "Handle is not initialized."

#    var unoPath       = @"C:\Program Files (x86)\LibreOffice 5\program" # when running 32-bit LibreOffice on a 64-bit system, the path will be in Program Files (x86)
     $mainFileLockPath = "D:\qt_projects\filmcab\simplified\tests\.~lock.user_spreadsheet_interface_test_copy.ods#" # Presence means calc is either open or there was a crash.
     $mainFilePath     = "D:\qt_projects\filmcab\simplified\tests\user_spreadsheet_interface_test_copy.ods"
     $fileInput        = "$mainFilePath"
     $fileInput        = "file:///" + $fileInput.Replace("\", "/")
     $calcCreated      = $pretest_assuming_false

# link with cli_ure.dll
#$weakBase     = [uno.util.WeakBase]::new()
#$localContext = [uno.util.Bootstrap]::bootstrap()

#$localContext = [uno.util.Bootstrap]::bootstrap('C:\Program Files\LibreOffice\program')
$localContext = [ooo.connector.BootstrapSocketConnector].bootstrap($env:UNO_PATH)
$ctx                      = [unoidl.com.sun.star.Bridge.UnoUrlResolver].getMethod('resolve').invoke($urlResolver, $localContext)
#$mxMSFactory = connect()
#$xSheet      = [unoidl.com.sun.star.sheet.XSpreadsheet] = getSpreadsheet(0);
<#try {
    $multiComponentFactory    = [unoidl.com.sun.star.uno.XComponentContext].      getMethod('getServiceManager').invoke($localContext, @())
    $desktop                  = [unoidl.com.sun.star.lang.XMultiComponentFactory].getMethod('createInstanceWithContext').invoke($multiComponentFactory, @('com.sun.star.frame.Desktop', $localContext))
    $calc                     = [unoidl.com.sun.star.frame.XComponentLoader].     getMethod('loadComponentFromURL').invoke($desktop, @($fileInput, '_blank', 0, <#unoidl.com.sun.star.beans.PropertyValue[]# >$null))
    $calcCreated              = $true
    $sheets                   = [unoidl.com.sun.star.sheet.XSpreadsheetDocument]. getMethod('getSheets').invoke($calc, @())
    $sheet                    = [unoidl.com.sun.star.container.XIndexAccess].     getMethod('getByIndex').invoke($sheets, @(0))
    $cell                     = [unoidl.com.sun.star.table.XCellRange].           getMethod('getCellByPosition').invoke($sheet.Value, @(0,0))
                                [unoidl.com.sun.star.table.XCell].                getMethod('setFormula').invoke($cell, @('A value in cell A1.'))
                                [unoidl.com.sun.star.frame.XStorable].            getMethod('storeToURL').Invoke($calc, @($fileOutput, [unoidl.com.sun.star.beans.PropertyValue[]]$fileProps))
}
catch {
    $_
}
#>
if ($calcCreated) {
    # WARNING: Doesn't always close the desktop app, just the document

     [unoidl.com.sun.star.util.XCloseable].            getMethod('close').Invoke($calc, $false)    
    }
<#
https://wiki.documentfoundation.org/Documentation/DevGuide/Writing_UNO_Components
#>
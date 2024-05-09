<#
    # https://forum.openoffice.org/en/forum/viewtopic.php?t=14018
    #https://www.openoffice.org/api/docs/common/ref/com/sun/star/frame/XComponentLoader.html
    #https://www.openoffice.org/api/docs/common/ref/com/sun/star/frame/XComponentLoader.html#loadComponentFromURL
    # CreateNew $calc                  = [unoidl.com.sun.star.frame.XComponentLoader].     getMethod('loadComponentFromURL').invoke($desktop, @('private:factory/scalc', '_blank', 0, <#unoidl.com.sun.star.beans.PropertyValue[]#>$null))
    # https://www.openoffice.org/api/docs/common/ref/com/sun/star/frame/XStorable.html#storeToURL
    # unoidl.com.sun.star.frame.XStorable storeToUrl FilterOptions
    # unoidl.com.sun.star.frame.XStorable storeToUrl MediaDescriptor
#>
. .\_dot_include_standard_header.ps1

[System.Reflection.Assembly]::LoadWithPartialName('cli_basetypes' )|Out-Null
[System.Reflection.Assembly]::LoadWithPartialName('cli_cppuhelper')|Out-Null
[System.Reflection.Assembly]::LoadWithPartialName('cli_oootypes'  )|Out-Null
[System.Reflection.Assembly]::LoadWithPartialName('cli_ure'       )|Out-Null
[System.Reflection.Assembly]::LoadWithPartialName('cli_uretypes'  )|Out-Null

#    var unoPath       = @"C:\Program Files (x86)\LibreOffice 5\program" # when running 32-bit LibreOffice on a 64-bit system, the path will be in Program Files (x86)
$env:UNO_PATH          = "C:\Program Files\LibreOffice\program"
     $mainFileLockPath = "D:\qt_projects\filmcab\simplified\tests\.~lock.user_spreadsheet_interface_test_copy.ods#" # Presence means calc is either open or there was a crash.
     $mainFilePath     = "D:\qt_projects\filmcab\simplified\tests\user_spreadsheet_interface_test_copy.ods"
     $fileInput        = "$mainFilePath"
     $fileInput        = "file:///" + $fileInput.Replace("\", "/")
     $calcCreated      = $pretest_assuming_false

try {
    $localContext             = [uno.util.Bootstrap]::bootstrap()
    $multiComponentFactory    = [unoidl.com.sun.star.uno.XComponentContext].      getMethod('getServiceManager').invoke($localContext, @())
    $desktop                  = [unoidl.com.sun.star.lang.XMultiComponentFactory].getMethod('createInstanceWithContext').invoke($multiComponentFactory, @('com.sun.star.frame.Desktop', $localContext))
    $calc                     = [unoidl.com.sun.star.frame.XComponentLoader].     getMethod('loadComponentFromURL').invoke($desktop, @($fileInput, '_blank', 0, <#unoidl.com.sun.star.beans.PropertyValue[]#>$null))
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

if ($calcCreated) {
    # WARNING: Doesn't always close the desktop app, just the document

     [unoidl.com.sun.star.util.XCloseable].            getMethod('close').Invoke($calc, $false)    
    }
<#
https://wiki.documentfoundation.org/Documentation/DevGuide/Writing_UNO_Components
#>
[System.Reflection.Assembly]::LoadWithPartialName('cli_basetypes')
[System.Reflection.Assembly]::LoadWithPartialName('cli_cppuhelper')
[System.Reflection.Assembly]::LoadWithPartialName('cli_oootypes')
[System.Reflection.Assembly]::LoadWithPartialName('cli_ure')
[System.Reflection.Assembly]::LoadWithPartialName('cli_uretypes')
                                                 
$env:UNO_PATH = "C:\Program Files\LibreOffice\program"

# when running 32-bit LibreOffice on a 64-bit system, the path will be in Program Files (x86)
# var unoPath = @"C:\Program Files (x86)\LibreOffice 5\program"

$localContext          = [uno.util.Bootstrap]::bootstrap()
$multiComponentFactory = [unoidl.com.sun.star.uno.XComponentContext].      getMethod('getServiceManager').invoke($localContext, @())
$desktop               = [unoidl.com.sun.star.lang.XMultiComponentFactory].getMethod('createInstanceWithContext').invoke($multiComponentFactory, @('com.sun.star.frame.Desktop', $localContext))
$calc                  = [unoidl.com.sun.star.frame.XComponentLoader].     getMethod('loadComponentFromURL').invoke($desktop, @('private:factory/scalc', '_blank', 0, <#unoidl.com.sun.star.beans.PropertyValue[]#>$null))
$sheets                = [unoidl.com.sun.star.sheet.XSpreadsheetDocument]. getMethod('getSheets').invoke($calc, @())
$sheet                 = [unoidl.com.sun.star.container.XIndexAccess].     getMethod('getByIndex').invoke($sheets, @(0))
$cell                  = [unoidl.com.sun.star.table.XCellRange].           getMethod('getCellByPosition').invoke($sheet.Value, @(0,0))
                         [unoidl.com.sun.star.table.XCell].                getMethod('setFormula').invoke($cell, @('A value in cell A1.'))

<#
https://wiki.documentfoundation.org/Documentation/DevGuide/Writing_UNO_Components
#>
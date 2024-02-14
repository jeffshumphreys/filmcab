[System.Reflection.Assembly]::LoadWithPartialName('cli_basetypes') |Out-Null
[System.Reflection.Assembly]::LoadWithPartialName('cli_cppuhelper')|Out-Null
[System.Reflection.Assembly]::LoadWithPartialName('cli_oootypes')|Out-Null
[System.Reflection.Assembly]::LoadWithPartialName('cli_ure')|Out-Null
[System.Reflection.Assembly]::LoadWithPartialName('cli_uretypes')    |Out-Null
                                                 
$env:UNO_PATH = "C:\Program Files\LibreOffice\program"
          
$mainFilePath = "D:\qt_projects\filmcab\simplified\tests\Test_Data_For_UNO_Convert_To_CSV"
$inputExtension = 'ods'
$fileInput = "$mainFilePath.$inputExtension"
$fileInput = "file:///" + $fileInput.Replace("\", "/")
$outputExtension = 'csv'
$fileOutput = "$mainFilePath.$outputExtension"
$fileOutput = "file:///" + $fileOutput.Replace("\", "/")

# when running 32-bit LibreOffice on a 64-bit system, the path will be in Program Files (x86)
# var unoPath = @"C:\Program Files (x86)\LibreOffice 5\program"
$calcCreated = $false

try {
    # https://wiki.openoffice.org/wiki/API/Tutorials/PDF_export
    $fileProps = [unoidl.com.sun.star.beans.PropertyValue[]]::new(3) # How many properties
    $exportToCSVProperty = [unoidl.com.sun.star.beans.PropertyValue]::new()
    $exportToCSVProperty.Name = 'FilterName'
    $exportToCSVProperty.Value = 'Text - txt - csv (StarCalc)' # WORKS!!!!!!!! ###### Wed Feb 14 13:14:02 MST 2024 Not UTF8
    $fileProps[0] = $exportToCSVProperty
    #https://forum.openoffice.org/en/forum/viewtopic.php?t=103969
    $OverwriteTrue = [unoidl.com.sun.star.beans.PropertyValue]::new()
    $OverwriteTrue.Name = 'Overwrite'
    $OverwriteTrue.Value = $False       # Works!!!! Tested, get popup
    $OverwriteTrue.Value = $true
    $fileProps[1] = $OverwriteTrue

    $exportToUTF8Property = [unoidl.com.sun.star.beans.PropertyValue]::new()
    # https://wiki.openoffice.org/wiki/Documentation/DevGuide/Spreadsheets/Filter_Options#Filter_Options_for_the_CSV_Filter
    # https://forum.openoffice.org/en/forum/viewtopic.php?t=14018
    $exportToUTF8Property.Name = 'FilterOptions'             
    #$exportToUTF8Property.Name = 'FilterFlags'             
    #$exportToUTF8Property.Name = 'FilterData'             
    $exportToUTF8Property.Value = "59" # Trying semicolons. Did something, I don't see a semicolon, but it did wipe out the comma, which means FilterOptions is getting read.
    $exportToUTF8Property.Value = "44,34" # Verifying it reads the comma.
    $exportToUTF8Property.Value = "44,34,76,1,1/2/2/2" # 76 is either ignored or coming out Cyrillic OEM 855, which is 26 DOS/OS2-855 (Cyrillic) 
    $exportToUTF8Property.Value = "44,34,76,1" # 76 is either ignored or coming out Cyrillic OEM 855, which is 26 DOS/OS2-855 (Cyrillic) 
    $exportToUTF8Property.Value = "44,34,7,1" # 
    $exportToUTF8Property.Value = "44,34,75,1" 
    $exportToUTF8Property.Value = "44,34,0,1" # Instead of € I got ђ. Emoji a "?"
    $exportToUTF8Property.Value = "44,59,76,1"     # Ah! Now we get the semicolon                              
    $exportToUTF8Property.Value = "44,34,1,1" # Instead of € I got ђ. Emoji a "?"
    $exportToUTF8Property.Value = "44,34,10,1" # Instead of € I got ђ. Emoji a "?"
    $exportToUTF8Property.Value = "44,34,ANSI,1" #
    $exportToUTF8Property.Value = "44,34,UTF-8,1,0,false,true,true" #
    $exportToUTF8Property.Value = "44,34,Unicode,1,0,false,true,true" #


    #  44 =          Field separator : comma.
    #  34 =     Text field delimiter : quote character ".
    #  76 =                 Encoding : Unicode (UTF-8).
    #   1 = First line to be treated : line 1.
    # 1/2 =            Column format : column 1 is formating in TEXT (2).
    # 2/4 =            Column format : column 2 is formating in DATE (4) JJ/MM/AA (french disposition) ; the import of TIME what is spewed by PHP is still...
    # 3/2 =            Column format : column 3 is formating in TEXT (2).
    $fileProps[2] = $exportToUTF8Property

    $localContext          = [uno.util.Bootstrap]::bootstrap()
    $multiComponentFactory = [unoidl.com.sun.star.uno.XComponentContext].      getMethod('getServiceManager').invoke($localContext, @())
    $desktop               = [unoidl.com.sun.star.lang.XMultiComponentFactory].getMethod('createInstanceWithContext').invoke($multiComponentFactory, @('com.sun.star.frame.Desktop', $localContext))
    #https://www.openoffice.org/api/docs/common/ref/com/sun/star/frame/XComponentLoader.html
    #https://www.openoffice.org/api/docs/common/ref/com/sun/star/frame/XComponentLoader.html#loadComponentFromURL
    # CreateNew $calc                  = [unoidl.com.sun.star.frame.XComponentLoader].     getMethod('loadComponentFromURL').invoke($desktop, @('private:factory/scalc', '_blank', 0, <#unoidl.com.sun.star.beans.PropertyValue[]#>$null))
    $calc                  = [unoidl.com.sun.star.frame.XComponentLoader].     getMethod('loadComponentFromURL').invoke($desktop, @($fileInput, '_blank', 0, <#unoidl.com.sun.star.beans.PropertyValue[]#>$null))
    $calcCreated = $true
    $sheets                = [unoidl.com.sun.star.sheet.XSpreadsheetDocument]. getMethod('getSheets').invoke($calc, @())
    $sheet                 = [unoidl.com.sun.star.container.XIndexAccess].     getMethod('getByIndex').invoke($sheets, @(0))
    $cell                  = [unoidl.com.sun.star.table.XCellRange].           getMethod('getCellByPosition').invoke($sheet.Value, @(0,0))
                            [unoidl.com.sun.star.table.XCell].                 getMethod('setFormula').invoke($cell, @('A value in cell A1.'))
                            # https://www.openoffice.org/api/docs/common/ref/com/sun/star/frame/XStorable.html#storeToURL
                            # unoidl.com.sun.star.frame.XStorable storeToUrl FilterOptions
                            # unoidl.com.sun.star.frame.XStorable storeToUrl MediaDescriptor
                            [unoidl.com.sun.star.frame.XStorable].             getMethod('storeToURL').Invoke($calc, @($fileOutput, [unoidl.com.sun.star.beans.PropertyValue[]]$fileProps))
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
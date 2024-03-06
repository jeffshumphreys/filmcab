<#
 #    FilmCab Daily morning batch run process: Fills up published so hard to fine stuff I haven't watched.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Conception
 #    ###### Tue Mar 5 16:23:46 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #>

#. .\_dot_include_standard_header.ps1

Function Get-FileName($initialDirectory)
{  
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = "“"All files (*.*)| *.*"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} #end function Get-FileName
                                        
#$SearchPathToLookForOffloadables = WhileReadSql "SELECT search_directory FROM search_directories_ext_v WHERE tag = 'published'"
             
#$SearchPathToLookForOffloadables.Read()

$text = Get-FileName -initialDirectory "O:\"
      

#. .\_dot_include_standard_footer.ps1

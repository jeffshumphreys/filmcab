<#
 #    Testing and fixing crashing Start-Log
 #    Status: Conception
 #    ###### Sat Feb 3 22:20:01 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #>
 
 [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
 [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
 param()
  
. D:\qt_projects\filmcab\simplified\shared_code\_dot_include_standard_header.ps1
 
Start-Log

$reader = WhileReadSql "SELECT 1 AS t" 

While ($reader.Read()) {
    $t
}

Log-ScriptCompleted
 
. D:\qt_projects\filmcab\simplified\shared_code\_dot_include_standard_footer.ps1
<#
 #    Testing and fixing crashing Start-Log
 #    Status: Conception
 #    ###### Sat Feb 3 22:20:01 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #>
  
. .\_dot_include_standard_header.ps1
 
$reader = WhileReadSql "SELECT 1 AS t" 

While ($reader.Read()) {
    $t
}
 
. .\_dot_include_standard_footer.ps1
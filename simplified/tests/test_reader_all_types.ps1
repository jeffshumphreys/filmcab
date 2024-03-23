. .\_dot_include_standard_header.ps1 # 

Invoke-Sql 'SET search_path = simplified, "$user", public'

$reader = (WhileReadSql 'SELECT * FROM t').Value # Cannot return value directly
Get-SqlColDefinitions $reader

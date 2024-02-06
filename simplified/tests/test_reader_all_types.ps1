. D:\qt_projects\filmcab\simplified\_dot_include_standard_header.ps1 # 

Invoke-Sql 'SET search_path = simplified, "$user", public'

$reader = (Select-Sql 'SELECT * FROM t').Value # Cannot return value directly
Get-SqlColDefinitions $reader

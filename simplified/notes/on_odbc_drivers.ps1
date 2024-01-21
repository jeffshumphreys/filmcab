$ODBCDriver = Get-OdbcDriver -Name $MyOdbcDatabaseDriver
    [Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '')]
    $ODBCDriverDllPath = $ODBCDriver|Select -ExpandProperty Attribute|Select Driver      # Just if you're having problems, need to update the driver.

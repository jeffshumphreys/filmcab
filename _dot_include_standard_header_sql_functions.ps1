$Script:ActiveTransaction = $null

<#
 #    FilmCab Daily morning batch run process: Second do inclusion from _dot_include_standard_header
 #    Included from from _dot_include_standard_header
 #    Status: In Production, but not all functions implemented.
 #    ###### Fri Mar 22 16:16:30 MDT 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #
 #    All writing to relational SQL databases.
 #>                                                                                                
   
 <#
 .SYNOPSIS
 Prep PowerShell object for embedding in postgresql string
 
 .DESCRIPTION
 Lots to do, convert dates, bytes, ints, deal with nulls, format datetime, date, escape strings
 
 .PARAMETER val
 typed value (or null)
 
 .PARAMETER KeepEmpties
 Parameter description
 
 .EXAMPLE
 $script_name_prepped_for_sql = PrepForSql $script_name # Not sure an ideal example.
 $script_name = PrepForSql $script_name      # Hmm, still bad. Now I've messed the original. So after the INSERT, now I have a fragile value.
 $Script:batch_run_session_task_id = Get-SqlValue("
            INSERT INTO 
                batch_run_sessions_tasks(
                    batch_run_session_id,
                    script_changed,
                    script_name
                )
                VALUES(
                    $batch_run_session_id,
                    '$FileTimeStampForParentScriptFormatted'::TIMESTAMPTZ,
                    $script_name_prepped_for_sql     /* This at least is really clear why I don't have apostrophes wrapping this variable */
                )

Another way I'm  considering but I'm not excited about:

           INSERT INTO 
                batch_run_sessions_tasks(
                    batch_run_session_id,
                    script_changed,
                    script_name
                )
                VALUES(
                    $batch_run_session_id,
                    '$FileTimeStampForParentScriptFormatted'::TIMESTAMPTZ,
                    $(PrepForSql $script_name)
                )
 
 .NOTES
 General notes
 #>
 Function PrepForSql {
    param (
        $val,
        [Switch]$KeepEmpties
    )
    if ($null -eq$val) { return 'NULL'}      
                 
    if ($val.Trim() -eq '' -and -not $KeepEmpties) { return 'NULL'}
    return "'" + $val.Replace("'", "''") + "'"
}

<#
.SYNOPSIS
Execute SQL commands.

.DESCRIPTION                                                                                                          
Also captures as much error detail as it can. Forces a stoppage even if ErrorAction is not Stop.  That's probably bad.
Mostly just to reduce caller bloat.  There's no $DatabaseCommand.ExecuteNonQuery("Select 1") like there is in C#. And I don't think Powershell supports extended functions.
Doesn't capture return values.

.PARAMETER sql
Script to execute. 

.EXAMPLE
Invoke-Sql 'SET search_path = simplified, "$user", public'
Invoke-Sql "UPDATE search_directories_v SET size_of_drive_in_bytes = $totalSize, space_left_on_drive_in_bytes = $spaceRemaining WHERE volume_id = $volume_id" -OneOrMore |Out-Null
$HowManyFoldersPopulated = Invoke-Sql "UPDATE directories SET folder = reverse((string_to_array(reverse(replace(directory_path::text, '\'::text, '\\'::text)), '\'))[1]) WHERE folder IS NULL"
$howManyAdded              = Invoke-Sql "INSERT INTO genres(genre, genre_function, genre_level, directory_example) VALUES('$subgenre', 'published folders', 2, '$directory_escaped') ON CONFLICT(genre, genre_function) DO NOTHING"|Out-Null

.NOTES
Also good way to enforce some sort of error response. Damn! Even displays the sql executed!!!!!!! Hell has broken out on the face of the Earth!
#>
Function Invoke-Sql {
    [CmdletBinding()]
    param(           
        [Parameter(Position=0,Mandatory=$true)][ValidateScript({Assert-MeaningfulString $_ 'sql'})]        [string] $sql,
        [Switch]$OneAndOnlyOne,
        [Switch]$OneOrNone,
        [Switch]$OneOrMore,
        [Switch]$SameOrMoreAsLastRun,
        [Switch]$LogSqlToHost
    )
    try {
        $Script:DatabaseCommand = [System.Data.Odbc.OdbcCommand]$DatabaseConnection.CreateCommand() # Must be visible to including script.
        if ($null -ne $Script:ActiveTransaction) {
            $Script:DatabaseCommand.Transaction = $Script:ActiveTransaction
        }
        $Script:DatabaseCommand.CommandTimeout = 0
        $Script:DatabaseCommand.CommandText = $sql                # Worry: is dbcmd set? Set in main. Below.
        if ($LogSqlToHost) {
            Log-Line $sql
        }
        # Hypothetically, you could determine if the sql was a select or an update/insert, and run the right function?

        [Int32] $howManyRowsAffected = $Script:DatabaseCommand.ExecuteNonQuery();
        if ($OneAndOnlyOne -and $howManyRowsAffected -ne 1) { throw [Exception]"Failed one and only one requirement: $howManyRowsAffected"}
        elseif ($OneOrMore -and $howManyRowsAffected -lt 1) { throw [Exception]"Failed one or more requirement: $howManyRowsAffected"}
        return $howManyRowsAffected
    } catch {   
        Show-Error $sql -exitcode 1 # Try (not too hard) to have some unique DatabaseColumnValue returned. meh.
    }
}
                                                                                                          

# https://gist.github.com/Jaykul/dfc355598e0f233c8c7f288295f7bb56
# https://gist.github.com/Jaykul/dfc355598e0f233c8c7f288295f7bb56#file-you-need-to-implement-non-generic-md

<#
.SYNOPSIS
Simple read

.DESCRIPTION
Any columns or aliases, these are forced into Script scope variables typed matching their column data type.

.PARAMETER sql
The sql that should return a row

.EXAMPLE
$reader = WhileReadSql "SELECT 1 t FROM x" -prereadfirstrow
Write-ToAllPlaces $t
 
$volumesForSearchDirectories = WhileReadSql 'SELECT DISTINCT drive_letter from search_directories_ext_v ORDER BY 1'
while ($volumesForSearchDirectories.Read()) {
    $TestPath = "$drive_letter`:\"
    Flush-Volume $drive_letter                             
}

.NOTES
General notes
#>
Function WhileReadSql {
    param(
        $sql, [switch]$prereadfirstrow
    )
    if ($prereadfirstrow) {
        $r = [ForEachRowInQuery]::new($sql)
        $r.Read()
        return $r
    } else {
        return ([ForEachRowInQuery]::new($sql))
    }
}

class ForEachRowInQuery {
    [string]$sql
    [System.Data.Odbc.OdbcCommand]$DatabaseCommand
    $readerObject
    [int]$Actual = 0
    $ResultSetColumnDefinitions
    
    ForEachRowInQuery() {
        throw [Exception] "Please provide a sql"
    }

    ForEachRowInQuery([string]$sql) {
        $this.sql                         = $sql
        $this.DatabaseCommand             = $Script:DatabaseConnection.CreateCommand()
        $this.DatabaseCommand.CommandText = $sql
        try {
            $this.readerObject                = [REF]$this.DatabaseCommand.ExecuteReader(); # Blows up here if bad syntax
        } catch {
            Show-Error -scriptWhichProducedError $sql
        }
    }

    # [object]get_Current() {
    #     return $this
    # }

    # [bool] MoveNext() {
    #     $local_reader = $this.readerObject.Value                             
    #     $anyMoreRecordsToRead = $local_reader.Read()
    #     if ($anyMoreRecordsToRead) {
    #         $this.ResultSetColumnDefinitions       = $local_reader.GetSchemaTable()
    #         foreach ($ResultSetColumnDefinition in $this.ResultSetColumnDefinitions) {             
    #             $DatabaseColumnName = $ResultSetColumnDefinition.ColumnName
    #             $DatabaseColumnValue  = Get-SqlFieldValue $this.readerObject $DatabaseColumnName
    #             New-Variable -Name $DatabaseColumnName -Scope Script -Option AllScope -Value $DatabaseColumnValue -Force -Visibility Public
    #         }                           
    #     }
    #     return $anyMoreRecordsToRead
    # }

    [bool] Read() {
        $local_reader = $this.readerObject.Value                             
        $anyMoreRecordsToRead = $local_reader.Read()
        if ($anyMoreRecordsToRead) {
            $this.ResultSetColumnDefinitions       = $local_reader.GetSchemaTable()
            foreach ($ResultSetColumnDefinition in $this.ResultSetColumnDefinitions) {             
                $DatabaseColumnName = $ResultSetColumnDefinition.ColumnName
                $DatabaseColumnValue  = Get-SqlFieldValue $this.readerObject $DatabaseColumnName
                New-Variable -Name $DatabaseColumnName -Scope Script -Option AllScope -Value $DatabaseColumnValue -Force -Visibility Public
            }                           
        }
        return $anyMoreRecordsToRead
    }

    hidden $_HasRows = $($this | Add-Member ScriptProperty 'HasRows' `
        {
            # get
            "getter $($this.readerObject.Value.HasRows)"
        }#`
        #{
        #    # set
        #    param ( $arg )
        #    $this._p = "setter $arg"
        #}
    )
    
    # [void] Reset() {
    #     $this.Actual = 0
    # }
                                               
    [void] Close() {
        $this.readerObject.Value.Close()
    }
    # [void] Dispose() {
    #     # Close reader
    # }
}


<#
.SYNOPSIS
Select a query but don't read the first row so the caller can use a While

.DESCRIPTION
Long description

.EXAMPLE
$readerHandle = Walk-Sql $sql
$reader = $readerHandle.Value 
While ($reader.Read()) {
} 

$reader.Close() # Optional

.NOTES
General notes
#>
# Function Walk-Sql {
#     [CmdletBinding()]
#     param(           
#         [Parameter(Position=0,Mandatory=$true)][ValidateScript({Assert-MeaningfulString $_ 'sql'})]        [string] $sql
#     )
#     Select-Sql $sql -skipInitialRead
# }                                   


<#
.SYNOPSIS
Execute a SELECT statement and return a traversable cursor.

.DESCRIPTION
Tired of rekeying this code over and over. I usually (always) only need one reader ever open in on thread. So this works.

.PARAMETER sql
SQL script that I guess could execute a function (stored proc) that returned a result set, but I use it for selects. Not for batches, though.

.EXAMPLE
$readerHandle = (Select-Sql $sql) # Cannot return reader value directly from a function or it blanks, so return it boxed
$reader = $readerHandle.Value # Now we can unbox!  Ta da!                                                                                                    
Do { # Buggy problem: My "Select-Sql" does an initial read.  If it came back with no rows, this would crash. Ugh. Maybe a "Walk-Sql" that does not do a read.
} While ($reader.Read())

$reader.Close()

.NOTES
There is no way to return a LOCALLY INSTANTIATED ODBCDataReader object as a DatabaseColumnValue. It will always ALWAYS resolve to null for the caller. I wish the example would be "$reader = Select-Sql 'select 1'" but I can't get it to work. hmmmmmmm
Better name for a command that runs a query and returns a cursor?  Invoke is more like it does something and leaves it.
"Read-Sql"? GetHandleToSQLInvokationOutput?  Maybe it's a Get-Sql. Traverse-Sql? Browse? Walk? ForEach-Sql?  That's what happens when you return the reader. Return an enumerator perhaps.  Even While-Sql
#>
# Function Select-Sql {
#     [CmdletBinding()]
#     param(           
#         [Parameter(Position=0,Mandatory=$true)][ValidateScript({Assert-MeaningfulString $_ 'sql'})]        [string] $sql,
#         [Switch]$skipInitialRead
#     )
#     try { 
#         $DatabaseCommand = $DatabaseConnection.CreateCommand()
#         $DatabaseCommand.CommandText = $sql
#         $reader = [REF]$DatabaseCommand.ExecuteReader(); # Too many refs?
#         $reader = $reader.Value 
#         if (-not $skipInitialRead) {        $reader.Read() >> $null   }
#         return [REF]$reader                      # Forces caller to deref!!!!! But only way to get it to work.
#     } catch {
#         Show-Error $sql -exitcode 2
#     }   
# }

<#
.SYNOPSIS
Convert select output to a string array (no hashtable!).

.DESCRIPTION
Long description

.PARAMETER sql
Parameter description

.EXAMPLE
$sql = "
SELECT 
    directory_path                         /* Deleted or not, we want to validate it. Probably more efficient filter is possible. Skip ones I just added, for instance. Don't descend deleted trees. */
FROM 
    directories
"
$readerHandle = (Select-Sql $sql) # Cannot return reader value directly from a function or it blanks, so return it boxed
$reader = $readerHandle.Value # Now we can unbox!  Ta da!
$olddirstillexists          = Get-SqlFieldValue $readerHandle directory_still_exists
$val = $reader.GetValue(0)

.NOTES
I don't like the verb "Show".  But this function just to blow a select output on the screen is sorely lacking for the lazy developer.
"Out-Sql" isn't great. I want the output. Select-Sql returns a reader. I suppose "Select-Sql" would behave more like a Select both PS and SQL.
"Out-Sql" might be more of a block or copy command to a database.  Treating the server as a device.
#>
# Function Out-SqlToList {
#     [CmdletBinding()]
#     param(           
#         [Parameter(Position=0,Mandatory=$true)][ValidateScript({Assert-MeaningfulString $_ 'sql'})]        [string] $sql,
#         [Switch]$DontOutputToConsole,
#         [Switch]$DontWriteSqlToConsole
#     )
#     try {
#         $DatabaseCommand = $DatabaseConnection.CreateCommand()
#         $DatabaseCommand.CommandText = $sql
#         $adapter = New-Object System.Data.Odbc.OdbcDataAdapter $DatabaseCommand 
#         $dataset = New-Object System.Data.DataSet
#         $adapter.Fill($dataSet) | out-null
#         if (-not $DontWriteSqlToConsole) {
#             Write-AllPlaces $sql
#         }
#         if (-not $DontOutputToConsole) {
            
#             $dataset.Tables[0].Rows|Select * -ExcludeProperty RowError, RowState, Table, ItemArray, HasErrors|Out-Host # Make it a little concise.
#         }      
        
#         $stringlist = @()
#         foreach ($s in $dataset.Tables[0].Rows)
#         {
#             $v = $s[0].ToString()
#             $stringlist+= $v
#         }
#         return $stringlist
#     } catch {
#         Show-Error $sql -exitcode 3
#     }   
# }
                               
<#
.SYNOPSIS
Return true/false from a sql based on row count

.DESCRIPTION
Long description

.PARAMETER sql
Parameter description

.PARAMETER DontOutputToConsole
Parameter description

.PARAMETER DontWriteSqlToConsole
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>#
# Function Test-Sql {
#     [CmdletBinding()]
#     param(           
#         [Parameter(Position=0,Mandatory=$true)][ValidateScript({Assert-MeaningfulString $_ 'sql'})]        [string] $sql,
#         [Switch]$DontOutputToConsole,
#         [Switch]$DontWriteSqlToConsole
#     )
#     try {
#         $DatabaseCommand = $DatabaseConnection.CreateCommand()
#         $DatabaseCommand.CommandText = $sql
#         $reader = $DatabaseCommand.ExecuteReader()
#         if (-not $reader.HasRows) { return $false}
#         # Error if more than one row returned??
#         return $true
#     } catch {
#         Show-Error $sql -exitcode 6
#     }   
# }

<#
.SYNOPSIS
Returns a dataset that I can "." reference properties from.

.DESCRIPTION
Long description

.PARAMETER sql
SQL script that returns a result set, probably a small set?

.PARAMETER DontOutputToConsole
Parameter description

.PARAMETER DontWriteSqlToConsole
Parameter description

.EXAMPLE
$state_of_session = Out-SqlToDataset "SELECT batch_run_session_id, started FROM batch_run_sessions WHERE running"
if ($null -ne $state_of_session) {
if ($state_of_session.batch_run_session_id -lt 100000) {...}

.NOTES
General notes
#>
Function Out-SqlToDataset {
    [CmdletBinding()]
    param(           
        [Parameter(Position=0,Mandatory=$true)][ValidateScript({Assert-MeaningfulString $_ 'sql'})]        [string] $sql,
        [Switch]$DontOutputToConsole,
        [Switch]$DontWriteSqlToConsole
    )
    try {
        $DatabaseCommand = $DatabaseConnection.CreateCommand()
        $DatabaseCommand.CommandText = $sql
        $adapter = New-Object System.Data.Odbc.OdbcDataAdapter $DatabaseCommand 
        $dataset = New-Object System.Data.DataSet
        $adapter.Fill($dataSet) | out-null
        if (-not $DontWriteSqlToConsole) {
            # Looks like Write-Output gets returned as a row?????
            Write-AllPlaces $sql
            $dataset.Tables[0].Rows|Select * -ExcludeProperty RowError, RowState, Table, ItemArray, HasErrors|Out-Host # Make it a little concise.
        }                 
        
        # INCREDIBLY HARD TO GET A SINGLE ROW RETURNED AS AN ARRAY!!!!!!!!!!
        if ($dataset.Tables[0].Rows.Count -eq 1) {
            [array]$arr = $dataset.Tables[0].Rows
            return [array]$arr # This appears to be the key.  the "[array]" typing of the array-type arr variable when returning. Sigh.
        }
        return $dataset.Tables[0].Rows
        
    } catch {
        Show-Error $sql -exitcode 4
    }   
}
  
Function Get-SqlValue {
    param (
        [Parameter(Position=0,Mandatory=$true)][ValidateScript({Assert-MeaningfulString $_ 'sql'})]        [string] $sql,
        [Switch]$LogSqlToHost
    )
    try {
        $DatabaseCommand = $DatabaseConnection.CreateCommand()
        if ($null -ne $Script:ActiveTransaction) {
            $DatabaseCommand.Transaction = $Script:ActiveTransaction
        }                                                           
        $DatabaseCommand.CommandText = $sql
        if ($LogSqlToHost) {
            Write-Host $sql
        }
        $value = $DatabaseCommand.ExecuteScalar()
        return $value
    } catch {
        Show-Error $sql -exitcode 44
    }
}
<#
.SYNOPSIS
Fetch a typed DatabaseColumnValue from a reader by either ordinal or name.

.DESCRIPTION
Not as easy as it looks. The various and sorded ways information is gotten are mixed between what PostgreSQL returns, what ODBC driver interprets, and finally what the .Net driver interprets as the right return type.

.PARAMETER reader
Must be open, or it will crash. I use DbDataReader because it's abstract.

.PARAMETER ordinalNoOrColumnName
Allows you pass in the ordinal number, usually the position of the field, or the name of the field.  I prefer passing in names rather than ordinals, and if I change the sql order, oops. 😬

.EXAMPLE
 $DatabaseColumnValue          = Get-SqlFieldValue $reader $DatabaseColumnName
 $DatabaseColumnValue          = Get-SqlFieldValue $reader 1
 $olddirstillexists          = Get-SqlFieldValue $reader directory_still_exists  # comes back [bool] if set, [object] if not set (Was DbNull internally somewhere)

.NOTES
Far from perfect. Only solution I can find is to do my own pg_types query and get the postgres column type, and if it's an array. Maybe if I type the columns in the SQL?
#>
function Get-SqlFieldValue {
    param (
        [Parameter(Position=0,Mandatory=$true)][Object] $readerOb, # Child types are DataTableReader, Odbc.OdbcDataReader, OleDb.OleDbDataReader, SqlClient.SqlDataReader
        [Parameter(Position=1,Mandatory=$true)][Object] $ordinalNoOrColumnName
    )
             
    $reader = $null

    if ($readerOb -is [System.Data.Common.DbDataReader])
    {
        $reader = $readerOb
    }                      
    else {
        $reader = $readerOb.Value # readers have to be wrapped or they go blank.
    }
    
    [Int32]$ordinal      = $null
    [object]$columnValue = $null

    $columnODBCMetadata = $null

    if ($ordinalNoOrColumnName -is [Int32]) {
        $columnODBCMetadata = $reader.GetSchemaTable() | Select-Object *|Where-Object ColumnOrdinal -eq $ordinalNoOrColumnName
    } else {
        $columnODBCMetadata = $reader.GetSchemaTable() | Select-Object *|Where-Object ColumnName -eq $ordinalNoOrColumnName
    }

    if ($null -eq $columnODBCMetadata) {
        throw [System.Exception] "GetSchemaTable returned nothing for $ordinalNoOrColumnName"
    }        

    $ordinal = $columnODBCMetadata.ColumnOrdinal

    if ($ordinal -eq -1) { # Not sure this happens.
        throw [System.Exception] "ordinal not set or found for $ordinalNoOrColumnName"
    }
                                             
    ##### Nows to the typing of our DatabaseColumnValue, which we want to maintain in the script. Only tested for Postgres 15
    
    $columnValue = $reader.GetValue($ordinal)
    $columnValueIsNull = $reader.IsDBNull($ordinal) # We need delicate treatment. Unlike C#, PS cannot hold a null in a string. or an int or a date.
    if ($columnValue -is [System.DBNull] -or $columnValueIsNull) {
        $columnValue = $null # NULL IS UNTYPED! IF YOU TRY AND TYPE IT, it changes to empty string, 0, etc.
    }
    
    $columnDataType = $columnODBCMetadata.DataType
    $columnPostgresTypeId = $columnODBCMetadata.ProviderType # Only way to distinguish
    $columnPostgresType = [type][String] # Default type

    switch ($columnPostgresTypeId)
    {
         9 {$columnPostgresType = [type][byte[]]}
        11 {$columnPostgresType = [type][datetime]}                                               # timestamp in database
        23 {$columnPostgresType = [type][datetime]}                                               # date in database
        24 {$columnPostgresType = [type][timespan]}                                               # time in database
         3 {
            $columnPostgresType = [type][bool]
            if (-not $columnValueIsNull) {$columnValue = [bool]$columnValue}
        }
        22 {
            $columnPostgresType = [type][bool]
            if (-not $columnValueIsNull) {
                $columnValue = [Int32]$columnValue # The string "0" -as System.Boolean = $True !!! So unfortunate
                $columnValue = [bool]$columnValue
            }
        }
        12 {$columnPostgresType = [type][string]}                                                 # varchar in database
         1 {                                    
            if ($columnDataType -eq 'Int64') {    # May alter the connection string to force int8 returns
                $columnPostgresType = [type][Int64]
            } else {
                $columnPostgresType = [type][string]
            }
        }                                                 # char in database
        13 {$columnPostgresType = [type][string]}                                                 # name in database
         4 {$columnPostgresType = [type][Int32]}                                                  
        10 {$columnPostgresType = [type][Int32]}                                                  # int4 in database
         5 {
            if ($columnDataType.Name -eq 'DateTime') { # More bugs!!!!
                $columnPostgresType = [type][datetime]
            } else {
                $columnPostgresType = [type][Int16]
            }
        }                                                  
        17 {$columnPostgresType = [type][Int16]}                                                  # int2 in database
        14 {$columnPostgresType = [type][single]}                                                 # float4 in database
         8 {$columnPostgresType = [type][double]}                                                 # float8 in database
         7 {$columnPostgresType = [type][decimal]}                                                # numeric in database
        15 {$columnPostgresType = [type][guid]}                                                   # uuid in database
        
        default { 
            throw [System.Exception] "Unimplemented type $columnPostgresTypeId for data type $columnDataType and column $ordinalNoOrColumnName"
        }
    }

    if (-not $columnValueIsNull) {$columnValue = $columnValue -as $columnPostgresType}
    
    # Warning: Nulls will NOT return as typed. No can do.
    return $columnValue
}

<#
.SYNOPSIS
Get better data typing on a query's columns.

.DESCRIPTION
Needs work. Right now it just displays them.  

.PARAMETER reader
Data reader object.  These can be passed in if created at the callers level.

.EXAMPLE
$reader = (Select-Sql 'SELECT * FROM t').Value # Cannot return DatabaseColumnValue directly
Get-SqlColDefinitions $reader

.NOTES
Dependent on Get-SqlFieldValue so that's why it's up above.
#>
Function Get-SqlColDefinitions {
    param(
        [Parameter(Position=0,Mandatory=$true)] [Data.Common.DbDataReader] $reader 
    )
    
    $ResultSetColumnDefinitions = $reader.GetSchemaTable()

    foreach ($ResultSetColumnDefinition in $ResultSetColumnDefinitions) {             
        $DatabaseColumnName = $ResultSetColumnDefinition.ColumnName
        $DatabaseColumnType = $ResultSetColumnDefinition.DataType
        $DatabaseDriverTypeNo = $ResultSetColumnDefinition.ProviderType
        $DatabaseColumnValue          = Get-SqlFieldValue $reader $DatabaseColumnName

        if ($null -eq $DatabaseColumnValue) {
            "column {0} is column type {1}, and value of null, provider type #{3}" -f 
            $DatabaseColumnName, $DatabaseColumnType, $DatabaseColumnValue, $DatabaseDriverTypeNo
        } else {
            $DatabaseColumnValueType = $DatabaseColumnValue.GetType().Name
            "column {0} is column type {1} and a value of {2}, provider type #{3}, and a value type of {4}" -f 
            $DatabaseColumnName, $DatabaseColumnType, $DatabaseColumnValue, $DatabaseDriverTypeNo, $DatabaseColumnValueType
        }
    }
}
 
# When a script fails in the includes, this should help know how far it got.
Write-Host "Exiting standard_header (sql functions)"

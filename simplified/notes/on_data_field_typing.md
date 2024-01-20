    # Postgres DataTypes vs ProviderTypes
    # - System.Byte[]          : 9
    # - System.DateTime: 5       (Convert data null values to 0)
    # - System.String: 22      (Boolean)
    # - System.String: 12      (String!)
    
    # Not getting
    # - bool                   : -7?

    # DISCARD $columnDataType = $columnODBCMetadata.DataType

See https://www.npgsql.org/doc/api/Npgsql.NpgsqlDataReader.html for a better reader (?)
bool, int2, int4, int8, float4, float8, date, time, abstime, datetime, timestamp, char, varchar, and text
partial support for all other data types. Examples of these: point, circle, box and arrays. String support only is provided for these non-standard types. In other words, they are returned as SQL_VARCHAR
SQL

SQL_BIGINT
SQL_BINARY
SQL_BIT
SQL_CHAR
SQL_DATE
SQL_DECIMAL
SQL_DOUBLE
SQL_FLOAT
SQL_GUID
SQL_INTEGER
SQL_INTERVAL_DAY
SQL_INTERVAL_DAY_TO_HOUR

SQL_INTERVAL_DAY_TO_MINUTE
SQL_INTERVAL_DAY_TO_SECOND
SQL_INTERVAL_HOUR
SQL_INTERVAL_HOUR_TO_MINUTE
SQL_INTERVAL_HOUR_TO_SECOND
SQL_INTERVAL_MINUTE
SQL_INTERVAL_MINUTE_TO_SECOND
SQL_INTERVAL_MONTH
SQL_INTERVAL_SECOND
SQL_INTERVAL_YEAR
SQL_INTERVAL_YEAR_TO_MONTH
SQL_LONGVARBINARY

SQL_LONGVARCHAR
SQL_NUMERIC
SQL_REAL
SQL_SMALLINT
SQL_TIME
SQL_TIMESTAMP
SQL_TINYINT
SQL_VARBINARY
SQL_VARCHAR
SQL_WCHAR
SQL_WLONGVARCHAR
SQL_WVARCHAR

typedef enum
{
SQL_IS_YEAR = 1,
SQL_IS_MONTH = 2,
SQL_IS_DAY = 3,
SQL_IS_HOUR = 4,
SQL_IS_MINUTE = 5,
SQL_IS_SECOND = 6,
SQL_IS_YEAR_TO_MONTH = 7,
SQL_IS_DAY_TO_HOUR = 8,
SQL_IS_DAY_TO_MINUTE = 9,
SQL_IS_DAY_TO_SECOND = 10,
SQL_IS_HOUR_TO_MINUTE = 11,
SQL_IS_HOUR_TO_SECOND = 12,
SQL_IS_MINUTE_TO_SECOND = 13
} SQLINTERVAL; 
https://learn.microsoft.com/en-us/power-query/odbc-parameters
SQLGetTypeInfo = #table(
    { "TYPE_NAME",      "DATA_TYPE", "COLUMN_SIZE", "LITERAL_PREF", "LITERAL_SUFFIX", "CREATE_PARAS",           "NULLABLE", "CASE_SENSITIVE", "SEARCHABLE", "UNSIGNED_ATTRIBUTE", "FIXED_PREC_SCALE", "AUTO_UNIQUE_VALUE", "LOCAL_TYPE_NAME", "MINIMUM_SCALE", "MAXIMUM_SCALE", "SQL_DATA_TYPE", "SQL_DATETIME_SUB", "NUM_PREC_RADIX", "INTERNAL_PRECISION", "USER_DATA_TYPE" }, {

    { "char",           1,          65535,          "'",            "'",              "max. length",            1,          1,                3,            null,                 0,                  null,                "char",            null,            null,            -8,              null,               null,             0,                    0                }, 
    { "int8",           -5,         19,             "'",            "'",              null,                     1,          0,                2,            0,                    10,                 0,                   "int8",            0,               0,               -5,              null,               2,                0,                    0                },
    { "bit",            -7,         1,              "'",            "'",              null,                     1,          1,                3,            null,                 0,                  null,                "bit",             null,            null,            -7,              null,               null,             0,                    0                },
    { "bool",           -7,         1,              "'",            "'",              null,                     1,          1,                3,            null,                 0,                  null,                "bit",             null,            null,            -7,              null,               null,             0,                    0                },
    { "date",           9,          10,             "'",            "'",              null,                     1,          0,                2,            null,                 0,                  null,                "date",            null,            null,            9,               1,                  null,             0,                    0                }, 
    { "numeric",        3,          28,             null,           null,             null,                     1,          0,                2,            0,                    0,                   0,                  "numeric",         0,               0,               2,               null,               10,               0,                    0                },
    { "float8",         8,          15,             null,           null,             null,                     1,          0,                2,            0,                    0,                   0,                  "float8",          null,            null,            6,               null,               2,                0,                    0                },
    { "float8",         6,          17,             null,           null,             null,                     1,          0,                2,            0,                    0,                   0,                  "float8",          null,            null,            6,               null,               2,                0,                    0                },
    { "uuid",           -11,        37,             null,           null,             null,                     1,          0,                2,            null,                 0,                  null,                "uuid",            null,            null,            -11,             null,               null,             0,                    0                },
    { "int4",           4,          10,             null,           null,             null,                     1,          0,                2,            0,                    0,                   0,                  "int4",            0,               0,               4,               null,               2,                0,                    0                },
    { "text",           -1,         65535,          "'",            "'",              null,                     1,          1,                3,            null,                 0,                  null,                "text",            null,            null,            -10,             null,               null,             0,                    0                },
    { "lo",             -4,         255,            "'",            "'",              null,                     1,          0,                2,            null,                 0,                  null,                "lo",              null,            null,            -4,              null,               null,             0,                    0                }, 
    { "numeric",        2,          28,             null,           null,             "precision, scale",       1,          0,                2,            0,                    10,                 0,                   "numeric",         0,               6,               2,               null,               10,               0,                    0                },
    { "float4",         7,          9,              null,           null,             null,                     1,          0,                2,            0,                    10,                 0,                   "float4",          null,            null,            7,               null,               2,                0,                    0                }, 
    { "int2",           5,          19,             null,           null,             null,                     1,          0,                2,            0,                    10,                 0,                   "int2",            0,               0,               5,               null,               2,                0,                    0                }, 
    { "int2",           -6,         5,              null,           null,             null,                     1,          0,                2,            0,                    10,                 0,                   "int2",            0,               0,               5,               null,               2,                0,                    0                }, 
    { "timestamp",      11,         26,             "'",            "'",              null,                     1,          0,                2,            null,                 0,                  null,                "timestamp",       0,               38,              9,               3,                  null,             0,                    0                }, 
    { "date",           91,         10,             "'",            "'",              null,                     1,          0,                2,            null,                 0,                  null,                "date",            null,            null,            9,               1,                  null,             0,                    0                }, 
    { "timestamp",      93,         26,             "'",            "'",              null,                     1,          0,                2,            null,                 0,                  null,                "timestamp",       0,               38,              9,               3,                  null,             0,                    0                }, 
    { "bytea",          -3,         255,            "'",            "'",              null,                     1,          0,                2,            null,                 0,                  null,                "bytea",           null,            null,            -3,              null,               null,             0,                    0                }, 
    { "varchar",        12,         65535,          "'",            "'",              "max. length",            1,          0,                2,            null,                 0,                  null,                "varchar",         null,            null,           -9,               null,               null,             0,                    0                }, 
    { "char",           -8,         65535,          "'",            "'",              "max. length",            1,          1,                3,            null,                 0,                  null,                "char",            null,            null,           -8,               null,               null,             0,                    0                }, 
    { "text",           -10,        65535,          "'",            "'",              "max. length",            1,          1,                3,            null,                 0,                  null,                "text",            null,            null,           -10,              null,               null,             0,                    0                }, 
    { "varchar",        -9,         65535,          "'",            "'",              "max. length",            1,          1,                3,            null,                 0,                  null,                "varchar",         null,            null,           -9,               null,               null,             0,                    0                },
    { "bpchar",         -8,         65535,           "'",            "'",              "max. length",            1,          1,                3,            null,                 0,                  null,                "bpchar",          null,            null,            -9,               null,               null,            0,                    0                } }
);


#    if ($columnValue -is [System.DBNull]) {
#        return $null
#    }
#    $columnValue = [System.Management.Automation.LanguagePrimitives]::ConvertTo($columnValue, $columnPostgresType)


# FAILED to be usable: Add-Type -Path ".\Npgsql.dll"
#Path 'C:\Users\jeffs\.vscode\extensions\ms-vscode.powershell-2024.1.0\modules\PowerShellEditorServices\bin\Common\Microsoft.Extensions.Logging.Abstractions.dll'
    
#$Assert.NullOrEmpty($TargetObject, 'Name')

# ###### Thu Jan 18 11:52:19 MST 2024 The following code failed bigly. No amount of manipulation (v2, v3, requiredversions, skipdependencies) changed the failure. Not loving the nuget approach for VS Code. It was a bit weird too in Visual Studio, but it made more sense.

# install-package npgsql -source http://www.nuget.org/api/v2 -ProviderName NuGet -Force -SkipDependencies
# install-package Microsoft.Extensions.Logging.Abstractions -source http://www.nuget.org/api/v2 -ProviderName NuGet -Force -SkipDependencies
# install-package System.Diagnostics.DiagnosticSource -source http://www.nuget.org/api/v2 -ProviderName NuGet -Force -SkipDependencies
# install-package System.Runtime.CompilerServices.Unsafe -source http://www.nuget.org/api/v2 -ProviderName NuGet -Force -SkipDependencies
# install-package System.Text.Json -source http://www.nuget.org/api/v2 -ProviderName NuGet -Force -SkipDependencies
# install-package Microsoft.Extensions.Http -source http://www.nuget.org/api/v2 -ProviderName NuGet -Force -SkipDependencies -RequiredVersion 3.1.10
# .................... And so that experiment failed. The purpose was to get a better data typing of query columns.  The ODBC connection lacks clear typing from 

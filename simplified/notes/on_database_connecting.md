 # Driver= PostgreSQL Unicode(x64) 15.00.00.00 PSQLODBC35W.DLL 6/23/2023 
    <#  
        https://odbc.postgresql.org/docs/config.html
        https://odbc.postgresql.org/docs/config-opt.html
        Default settings from using the GUI ODBC admin
            Use Declare/Fetch: If true, the driver automatically uses declare cursor/fetch to handle SELECT statements and keeps 100 rows in a cache. This is mostly a great advantage, especially if you are only interested in reading and not updating. It results in the driver not sucking down lots of memory to buffer the entire result set. If set to false, cursors will not be used and the driver will retrieve the entire result set. For very large tables, this is very inefficient and may use up all the Windows memory/resources. However, it may handle updates better since the tables are not kept open, as they are when using cursors. This was the style of the old podbc32 driver. However, the behavior of the memory allocation is much improved so even when not using cursors, performance should at least be better than the old podbc32.
            Parse Statements: Tell the driver how to gather the information about result columns of queries, if the application requests that information before executing the query. See also ServerSide Prepare options.
                The driver checks this option first. If disabled then it checks the Server Side Prepare option.
                If this option is enabled, the driver will parse an SQL query statement to identify the columns and tables and gather statistics about them such as precision, nullability, aliases, etc. It then reports this information in SQLDescribeCol, SQLColAttributes, and SQLNumResultCols.
                When this option is disabled (the default), the query is sent to the server to be parsed and described. If the parser can not deal with a column (because it is a function or expression, etc.), it will fall back to describing the statement in the server. The parser is fairly sophisticated and can handle many things such as column and table aliases, quoted identifiers, literals, joins, cross-products, etc. It can correctly identify a function or expression column, regardless of the complexity, but it does not attempt to determine the data type or precision of these columns.
            Text as LongVarChar, max len = 8190 (previous default was 4095) You can even specify (-4) for this size, which is the odbc SQL_NO_TOTAL value.
            Bools reported as Char
            Max Varchar is 255 (Seems low)
            Unknown sized are treated as Maximum  Unknowns as LongVarChar Unknown types (arrays, etc) are mapped to SQLLongVarChar, otherwise SQLVarchar
            MyLog (C:\mylog_xxxx.log) Not enabled
            Int8 as default (becomes string), Extra Opts=0x0 (?)
                0x1: Force the output of short-length formatted connection string. Check this bit when you use MFC CDatabase class.
                0x2: Fake MS SQL Server so that MS Access recognizes PostgreSQL's serial type as AutoNumber type.
                0x4: Reply ANSI (not Unicode) char types for the inquiries from applications. Try to check this bit when your applications don't seem to be good at handling Unicode data.
            bytea as LO? (Enabled)         Allow the use of bytea columns for Large Objects. 
            LF -> CR/LF conversion (?) (Enabled)  Convert Unix style line endings to DOS style.
            Row Versioning (not enabled)  Allows applications to detect whether data has been modified by other users while you are attempting to update a row. It also speeds the update process since every single column does not need to be specified in the where clause to update a row. The driver uses the "xmin" system field of PostgreSQL to allow for row versioning. Microsoft products seem to use this option well. See the faq for details on what you need to do to your database to allow for the row versioning feature to be used.
            Display Optional Error Message (not enabled) Display optional(detail, hint, statement position etc) error messages.
            True is -1 (not enabled)
            Updatable Cursors: Checked
            Server side prepare is checked     If set, the driver uses server-side prepared statements. See also Parse Statement option. Note that if a query needs to be described before execution, e.g. because the application calls SQLDescribeCol() or SQLNumResultCols() before SQLExecute(), the driver will send a Parse request to the server even if this option is disabled. In that case, the query that is sent to the server for parsing will have the parameter markers replaced with the actual parameter values, or NULL literals if the values are not known yet. 
            Fetch result from each refcursor    
            Numeric(without precision) As: Default (I get Decimal) Specify the map from numeric items without precision to SQL data types. numeric(default), varchar, double or memo(SQL_LONGVARCHAR) can be specified.
            Level of rollback on errors (Not set. Options are Nop, Transaction, Statement)
            OID not shown
            "pg_" are always treated as system tables, even without this option
            Connect Settings
            Batch Size (default=100):Chunk size when executing batches with arrays of parameters. Setting 1 to this option forces one by one execution (the behavior before). 
            TCP KEEPALIVE (not disabled?)
            Distributed Transaction related settings
                Allow connections unrecoverable by MSDTC?
                    yes (set) options are also rejects sslmode verify-[ca\full], no(confirm the connectivity from MSDTC first)    reject ssl connections with verify-ca or verify-full mode because in those cases msdtc could hardly establish the connection.
            libpq parameters:(I) (empty string) Specify libpq connection parameters with conninfo style strings e.g. sslrootcert=c:\\myfolder\\myroot sslcert=C:\\myfolder\\mycert sslkey=C:\\myfolder\\mykey.
                    Though host, port, dbname, user, password, sslmode, keepalives_idle or keepalive_interval parameters can be set using this(pqopt) option, the use is not recommended because they are ordinarily set by other options. When some settings for those parameters conflict with other ordinary options, connections are rejected.
    #>
    # FAILED BAD $connString = "Server=$MyServer;Port=$MyPort;Database=$MyDB;user id=$MyUid;password=$MyPass;";
    # FAILED BAD #$DBConn = New-Object Npgsql.NpgsqlConnection($connString) #  Exception calling ".ctor" with "1" argument(s): "Could not load file or assembly 'Microsoft.Extensions.Logging.Abstractions, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60'. Format of the executable (.exe) or library (.dll) is invalid."
    
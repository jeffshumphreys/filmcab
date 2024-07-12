<#
    Trying to make a generic API detail puller.
    This first test is for TMDB which you fetch the latest id, and then fetch starting after you latest id.
    This probably won't work on other systems, though, like IMDB, OMDB, etc., But....
    Issues:
    - "tmdb" is embedded in the uri_base and the token name.
    - Some APIs may not use a token, rather login/password and/or secret
    - the "id" column for now matches the column in the json.
    - Some ids may not be int4
    - IMDB ids are "tt" prefixed, which should be stripped.
    - IMDB ids may not expand consecutively.
    - endpoint "latest" is probably only TMDB.
#>
. .\_dot_include_standard_header.ps1

$target_schema         = 'receiving_dock'
$target_table          = "$($source_provider)_$($source_data_set)_data"
$target_source_id_base = "$($source_provider)_$($source_data_set)_id"
$target_schemad_table  = "$target_schema.$target_table"
$source_provider       = "tmdb"
$source_data_set       = "movie" # movie, tv_series, person, collection, tv_network, keyword, production_company
$source_uri_base       = $Script:SUPER_SECRET_SQUIRREL.super_secret_tmdb_rest_endpoint_titles_url
$source_uri            = "$source_uri_base$source_data_set/latest"
$bearer_token          = $Script:SUPER_SECRET_SQUIRREL.super_secret_tmdb_rest_endpoint_titles_key
$headers               = @{'Authorization' = $bearer_token}
$web_response_as_json  = (Invoke-WebRequest $source_uri -Headers $headers|ConvertFrom-Json)
$latest_id_in_source   = $web_response_as_json.id
$latest_id_in_local    = Get-SqlValue "SELECT COALESCE(MAX($target_source_id_base::int), 0) FROM $target_schemad_table"
$columnDefs            = $DatabaseConnection.GetSchema("Columns", @('', $target_schema, $target_table))|Select column_Name, type_name, nullable, ordinal_position, auto_increment, column_def, @{Name='is_pk';Expression={$false}}|
                        Where auto_increment -eq 0| # Exclude surrogate keys from inserting.
                        Where column_def -is [DBNull]| # Exclude computed columns; these cannot be updated or inserted. Also excludes anything with a default expression.
                        Where column_name -NotIn "$target_source_id_base`_as_integer", "$target_source_id_base`_not_found_in_api", "$target_source_id_base`_last_found_in_api", 'record_updated_on',
                        'pulled_down_new_json_on', 'captured_json'
$columnDefs|Format-Table
$indexesOnTable        = $DatabaseConnection.GetSchema("Indexes", @('', $target_schema, $target_table))|Select index_qualifier, index_name, type, ordinal_position, column_name, non_unique

$possibleKeyIndexesOnTable = $indexesOnTable|group index_name|select name, count

$insert_header = "
INSERT INTO $target_schemad_table(
    $target_source_id_base
,   $target_source_id_base`_last_found_in_api
,   captured_json
,   pulled_down_new_json_on
"
$insert_middle = "
)
VALUES(
    ?::TEXT
,   clock_timestamp()
,   to_json('?'::TEXT)
,   clock_timestamp()
"

$insert_header_columns = ""
$insert_middle_columns = ""

$insert_footer = "
    )
    ON CONFLICT UPDATE $target_source_id_base`_last_found_in_api = clock_timestamp()
"
$prepsqlfirstpass = $true

$preparedInsertCommand = $DatabaseConnection.CreateCommand()

for ($for_id = $latest_id_in_local+1; $for_id -le $latest_id_in_source; $for_id++ )
{
    $uri = "$source_uri_base$source_data_set/$for_id"
    try {
        $detailjsonpacket = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers

        [string]$escaped_detailjsonpacket = ($detailjsonpacket.Replace("'", "''"))
        foreach ($json_attribute in $detailjsonpacket.possible.properties)
        {
            $data_type   = $json_attribute.TypeNameOfValue
            $sql_data_type = switch ($data_type) {
                'int' { [System.Data.Odbc.OdbcType]::Int}
                default: {[System.Data.Odbc.OdbcType]::NText}
            }
            $column_name = $json_attribute.Name
            $column_value = $json_attribute.Value

            if ($prepsqlfirstpass) {
                if ($columnDefs.column_name -notcontains $column_name) {
                    $addcolumntotable = "ALTER TABLE $target_schemad_table ADD $column_name"
                }
                $insert_header_columns+= ", $column_name
                "
                $insert_middle_columns+= ", ?
                "
                # https://learn.microsoft.com/en-us/dotnet/api/system.data.odbc.odbctype?view=net-8.0
                $preparedInsertCommand.Parameters.Add('1', [System.Data.Odbc.OdbcType]::VarChar, -1)
            } else {
                # TODO: bind values to parameters
            }
        }

        if ($prepsqlfirstpass) {
            $sql =
                $insert_header
            +   $insert_header_columns
            +   $insert_middle
            +   $insert_middle_columns
            +   $insert_footer
            $
            # TODO: Prepare sql
        }
        $prepsqlfirstpass = $false

        # TODO: Execute prepared sql
        $howmanyRowsInserted = $preparedInsertCommand.ExecuteNonQuery()
    }
    catch {
        $status_code = "-1"
        if ( [bool]($_.Exception.PSobject.Properties.name -match "Response"))
        {
            $status_code     = $_.Exception.Response.StatusCode.value__ # Not the 32 you see in the error, hmmm. rather, 404
        }
        if ($status_code -eq '404') {
            Invoke-Sql "
                INSERT INTO $target_schemad_table(
                    $target_source_id_base
                ,    $target_source_id_base`_not_found_in_api
                )
                VALUES(
                    $for_id::TEXT
                ,   clock_timestamp()
                )
                ON CONFLICT($target_source_id_base)
                DO UPDATE
                    SET $target_source_id_base`_not_found_in_api = clock_timestamp()
                    WHERE EXCLUDED.$target_source_id_base`_not_found_in_api IS NULL      /* Don't overwrite earlier timestamps if present. */
                    "
            # Add a pause because it's so fast, I'll get 50 in a second if 50 don't come back found, which is the per second limit.
            Start-Sleep -Milliseconds 333  # 3 max per second
        }
        # 429: "too many requests" is known to happen for some users.
        elseif ($status_code -eq '429') {
            Write-Host '429'
            Start-Sleep -Milliseconds 1000
        }
        elseif ($status_code -eq '504') {
            Get-Date
            Start-Sleep 60
            exit
        }
        else {
            Write-Error "Error not handled: $status_code"
            Start-Sleep -Milliseconds 250
        }
    }
}

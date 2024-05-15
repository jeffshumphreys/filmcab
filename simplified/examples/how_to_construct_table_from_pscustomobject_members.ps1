    # Builds the stage for loading everything
    if ($true) {
        $Script:createTargetTableScript = "
            CREATE TABLE torrents_staged (
                torrent_staged_id SERIAL8 PRIMARY KEY
            ,   added_to_this_table           TIMESTAMPTZ  DEFAULT(pg_catalog.clock_timestamp())
            ,   load_batch_timestamp          TIMESTAMPTZ
            ,   load_batch_id                 INT8
            "
        $firstRow = $true

        $torrents[0]|gm|Where MemberType -eq 'NoteProperty'|
        % {
            $_.Definition -match "(?<typename>.*?)[ ]"|Out-Null
            $typeName = $matches['typename']
            $typeName = switch ($typeName) {
                'long' { "INT8"}
                'string' { "TEXT"}
                'datetime' { "TIMESTAMPTZ"}
                'double' { "DOUBLE PRECISION"}
                default {
                    $typeName.ToUpper()
                }
            }

            $x = [PSCustomObject]@{
                ColumnName = $_.Name
                ColumnDataType = $typeName
            }
            $prefix = ","

            if ($firstRow) {
                $prefix = " "
                $firstRow = $false
            }

            # the following columns are expected (not proven) to be unique, and so a generically named unique index is applied to each of them.

            $tail = ""
            if ($_.Name -in ('MagnetUri', 'Name', 'Hash', 'InfohashV1', 'ContentPath')) {
                $tail = " UNIQUE"
            }

            # Build out line in "CREATE TABLE .... (" column list
            $Script:createTargetTableScript+= "$prefix   $($x.ColumnName)     $($x.ColumnDataType)$tail
            "
        }

        # Close constructed list of columns in new table.

        $Script:createTargetTableScript+= ")"

        #$Script:createTargetTableScript
    }

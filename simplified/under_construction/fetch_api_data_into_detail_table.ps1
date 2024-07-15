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
    - id not mapped to pk column tmdb_movie_id. Hmmmm.
    - Should we add a comment to each column we added, when and from where? what id it was pulled from so we can examine the json that triggered this?
#>
. .\_dot_include_standard_header.ps1

$most_recent_date_url_formatted = Get-Date -format "MM_dd_yyyy"
$target_schema                  = 'receiving_dock'
$source_provider                = "tmdb"
$source_data_set                = "movie" # movie,                                                  tv_series,           person, collection, tv_network, keyword, production_company
$source_id_column               = 'id'
$target_id_column               = "$($source_provider)_$($source_data_set)_id"
$target_table                   = "$($source_provider)_$($source_data_set)_data" # tmdb_movie_data, tmdb_tv_series_data, imdb_...
$target_schemad_table           = "$target_schema.$target_table"

$Script:working_id_list = @()

enum SourceMethodForIDs {
    FullCurrentIDList # Slowest
    PullOnlyNew
    GetListOfChangedRecordsSinceLastFullLoad
    SpecificListOfIDs
}

$SelectedSourceMethodForIDs = [SourceMethodForIDs]::FullCurrentIDList
$SelectedSourceMethodForIDs = [SourceMethodForIDs]::PullOnlyNew
$SelectedSourceMethodForIDs = [SourceMethodForIDs]::SpecificListOfIDs

$columns_only = @()
$columns_only = @('original_language')

# Choose process for identifying what ids to fetch and update.

switch ($SelectedSourceMethodForIDs) {
    FullCurrentIDList {
        $source_uri_for_full_id_list           = "http://files.tmdb.org/p/exports/$source_data_set`_ids_$most_recent_date_url_formatted.json.gz"
        $target_folder_for_full_id_list        = "N:\Video AllInOne Metadata\$source_provider\files.tmdb.org-p-exports"
        $target_path_for_full_id_list_zipped   = "$target_folder_for_full_id_list\$source_data_set`_ids.json.gz"
        Invoke-WebRequest $source_uri_for_full_id_list -OutFile $target_path_for_full_id_list_zipped

        $target_folder_for_full_id_list_unzipped = "$target_path_for_full_id_list_zipped.json"
        $target_path_for_full_id_list_unzipped   = "$target_folder_for_full_id_list_unzipped\$source_data_set`_ids_$most_recent_date_url_formatted.json"
        #$target_path_for_full_id_list_unzipped  = "$target_folder_for_full_id_list_u\$source_data_set`_ids_$most_recent_date_url_formatted.json"
        Remove-Item $target_folder_for_full_id_list_unzipped -Force -ErrorAction Ignore -Recurse
        & "C:\Program Files\7-Zip\7z.exe" e "$target_path_for_full_id_list_zipped" -o"$target_folder_for_full_id_list_unzipped" -y
        # WOW! Slow!! 96 MB???????? 949,854 movies. No adult included. videos included
        $Script:working_id_list = (Get-Content "$target_path_for_full_id_list_unzipped" | ConvertFrom-Json)
    }
    PullOnlyNew {
                $source_uri_base       = $Script:SUPER_SECRET_SQUIRREL.super_secret_tmdb_rest_endpoint_url
                $source_uri            = "$source_uri_base$source_data_set/latest"
                $bearer_token          = $Script:SUPER_SECRET_SQUIRREL.super_secret_tmdb_rest_read_token
                $headers               = @{'Authorization' = $bearer_token; 'acccept' = 'application/json'}
                $web_response_as_json  = (Invoke-WebRequest $source_uri -Headers $headers|ConvertFrom-Json)
                $latest_id_in_source   = $web_response_as_json.$source_id_column
                $latest_id_in_local    = Get-SqlValue "SELECT COALESCE(MAX($target_id_column), '0') FROM $target_schemad_table"
                $latest_id_in_local   += 1
        $Script:working_id_list        = ($latest_id_in_loca1)..$latest_id_in_source
    }
    GetListOfChangedRecordsSinceLastFullLoad {
        throw "GetListOfChangedRecordsSinceLastFullLoad not implemented"
    }
    SpecificListOfIDs {
        $Script:working_id_list = @(
            974262 # Massive: Tons of crew 8 videos, 59 backdrops, 48 posters, part of collection, keywords, ow streaming, has trailer, teaser, clips, behinde the scenes, featurettes
            # tagline, 4 production companies, 6 keywords, 4 genres, IMDB ID, Wikidata ID
        )
    }
}

# Gather metadata on our target table and columns

$current_target_table_column_defs = $DatabaseConnection.GetSchema("Columns", @('', $target_schema, $target_table))|
    Select-Object column_Name, type_name, nullable, ordinal_position, auto_increment, column_def, @{Name='is_unique_by_itself';Expression={$false}}|
    Where-Object auto_increment -eq 0|
    Where-Object column_def -is [DBNull]|
    Where-Object column_name -NotIn "$target_id_column`_as_integer", "$target_id_column`_not_found_in_api", "$target_id_column`_last_found_in_api", 'record_updated_on', 'pulled_down_new_json_on', 'captured_json'
$current_target_table_column_defs|Format-Table

# Identify single column, unique indexes. These can be used to match to downloaded metadata, detecting if we have it already or it's new. There should be only one surrogate key.

$indexes_on_target_table              = $DatabaseConnection.GetSchema("Indexes", @('', $target_schema, $target_table))|
    Select-Object index_qualifier, index_name, type, ordinal_position, column_name, non_unique

$possible_key_indexes_on_target_table = $indexes_on_target_table|
    Group-Object index_name|
    Select-Object name, count|
    Where-Object count -eq 1

foreach ($current_target_table_column_def in $current_target_table_column_defs) {
    if ($indexes_on_target_table.COLUMN_NAME -contains $current_target_table_column_def.column_name) {
        $indexName = ($indexes_on_target_table|
            Where-Object ORDINAL_POSITION -eq 1|
            Where-Object NON_UNIQUE -eq 0|
            Where-Object COLUMN_NAME -eq ($current_target_table_column_def.column_name)|
            Select-Object * -First 1).index_name
        if ($possible_key_indexes_on_target_table.name -contains $indexName) {
            $current_target_table_column_def.is_unique_by_itself = $true
        }
    }
}

# Build our prepared reusable parameterized sql insert/update script.

$insert_header = "
INSERT INTO $target_schemad_table(
    $target_id_column
,   $target_id_column`_last_found_in_api
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
# http://files.tmdb.org/p/exports/movie_ids_05_15_2024.json.gz

$insert_header_columns = ""
$insert_middle_columns = ""

$insert_footer = "
    )
    ON CONFLICT($target_id_column) DO UPDATE
    SET
        $target_id_column`_last_found_in_api = clock_timestamp()
"

$insert_footer_columns = ""

$collect_and_parameterize_prepared_sql = $true

$preparedInsertCommand = $DatabaseConnection.CreateCommand()

# Traverse each id in our working set, pull detail from the api, and either insert or update what we have locally.

foreach ($for_id in $working_id_list) {
    $uri = "$source_uri_base$source_data_set/$for_id`?append_to_response=videos,images,credits,reviews,external_ids,alternative_titles,account_states,keywords,release_dates,changes&end_date=2024-07-06&start_date=2024-07-04"

    # The api returns an error if no such object id exists, which is normal.

    try {
        $detailjsonpacket = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers

        # Pull all attributes out of our downloaded JSON object, and determine how to alter our target table to store them
        foreach ($json_attribute in $detailjsonpacket.psobject.members|where membertype -eq 'NoteProperty') {
            $data_type = $json_attribute.TypeNameOfValue

            $odbc_data_type = switch ($data_type) {
                'System.Int64'    {[System.Data.Odbc.OdbcType]::BigInt}
                'System.Double'   {[System.Data.Odbc.OdbcType]::Double}
                'System.Boolean'  {[System.Data.Odbc.OdbcType]::Bit}
                'System.String'   {[System.Data.Odbc.OdbcType]::NText}
                'System.Object[]' {[System.Data.Odbc.OdbcType]::NText}
                'System.Object'   {[System.Data.Odbc.OdbcType]::NText}
                default {[System.Data.Odbc.OdbcType]::NText}
            }
            $sql_data_type = switch ($data_type) {
                'System.Int64'                                { 'int8'   }
                'System.Double'                               { 'float8' }
                'System.Boolean'                              { 'bool'   }
                'System.String'                               { 'text'   }
                'System.Object[]'                             { '_text'  }
                'System.Management.Automation.PSCustomObject' { '_hstore'}
                'System.Object'                               { 'text'   }
                default                                       { 'text'   }
            }

            $column_name  = $json_attribute.Name
            if ($columns_only.Count -ge 1) {
                if ($columns_only -notcontains $column_name) {
                    continue
                }
            }

            $column_value = $json_attribute.Value

            if ($sql_data_type -eq 'text' -and $null -ne $column_value) {
                $column_value = $column_value.ToString().Replace("'", "''")
            }

            if ($collect_and_parameterize_prepared_sql) {
                $sql_add_columns = @()

                # string original_language = en
                # string release_date      = 2024-07-11                           column_name release_date: date
                # long id                  = 974262
                # long runtime             = 94
                # long revenue             = 0
                # long budget              = 0
                # long vote_count          = 91
                # double popularity        = 465.44
                # double vote_average      = 7.313
                # bool video               = False
                # bool adult               = False

                # Object[] production_companies = System.Object[]                  array hstores {@{id=670; logo_path=/rRGi5UkwvdOPSfr5Xf42RZUsYgd.png; name=Walt Disney Television; origin_country=US}, @{id=91921; logo_path=; name=Suzanne Todd Productions; origin_country=US}, @{id=233782; logo_path=; name=Potato Monkey Productions; origin_country=US}, @{id=146807; logo_path=; name=GWave Productions; origin_country=US}}
                # Object[] production_countries = System.Object[]                  array hstores {@{iso_3166_1=US; name=United States of America}}
                # Object[] spoken_languages     = System.Object[]                  array hstores {@{english_name=English; iso_639_1=en; name=English}}
                # Object[] genres               = System.Object[]                  array hstores {@{id=14; name=Fantasy}, @{id=12; name=Adventure}, @{id=10751; name=Family}, @{id=35; name=Comedy}}
                # Object[] origin_country       = System.Object[]                  array text    {US}

                # System.Management.Automation.PSCustomObject keywords              = @{keywords=System.Object[]} hasharray with one element: array hstores column_name keywords {@{id=4198; name=descendant}, @{id=4379; name=time travel}, @{id=4344; name=musical}, @{id=15285; name=spin off}…}
                # System.Management.Automation.PSCustomObject alternative_titles    = @{titles=System.Object[]}   hasharray with one element: array hstores column_name titles {@{iso_3166_1=US; title=The Pocketwatch; type=working title}, @{iso_3166_1=US; title=The Pocketwatch - Descendants Sequel; type=}, @{iso_3166_1=BR; title=Descendentes 4; type=franchise order}, @{iso_3166_1=US; title=Descendants 4; type=franchise order}…}
                # System.Management.Automation.PSCustomObject changes               = @{changes=System.Object[]}                                                   column_name changes {@{key=videos; items=System.Object[]}, @{key=release_dates; items=System.Object[]}}

                ##### $detailjsonpacket.changes.changes[0]
                # key    items
                # ---    -----
                # videos {@{id=6687213093b23a25d76d00d3; action=updated; time=2024-07-04 22:24:48 UTC; iso_639_1=tr; iso_3166_1=TR; value=; original_value=}}
                ##### $detailjsonpacket.changes.changes[0].items
                # id                       action  time                    iso_639_1 iso_3166_1 value                                                                                                                  original_value
                # --                       ------  ----                    --------- ---------- -----                                                                                                                  --------------
                # 6687213093b23a25d76d00d3 updated 2024-07-04 22:24:48 UTC tr        TR         @{id=668155dbadea1df5acfea9f8; name=Resmi Fragman [Altyazılı]; key=x0NSjb0R7IY; size=1080; site=YouTube; type=Trailer} @{id=668155dbadea1df5acfea9f8; name=Türkçe Altyazılı Resmi Fragman; key=x0…
                ##### $detailjsonpacket.changes.changes[0].items[0].value
                # id                       name                      key         size site    type
                # --                       ----                      ---         ---- ----    ----
                # 668155dbadea1df5acfea9f8 Resmi Fragman [Altyazılı] x0NSjb0R7IY 1080 YouTube Trailer

                # System.Management.Automation.PSCustomObject videos                = @{results=System.Object[]}                                                   column_name videos

                ##### $detailjsonpacket.videos.results[0]
                # iso_639_1 iso_3166_1 name                         key         site    size type       official published_at         id
                # --------- ---------- ----                         ---         ----    ---- ----       -------- ------------         --
                # en        US         Character & Story Featurette ZULn2vZYQMc YouTube 1080 Featurette     True 6/28/2024 6:29:54 PM 66809ce4049d8786075a5133

                # System.Management.Automation.PSCustomObject release_dates         = @{results=System.Object[]}                                                   column_name release_dates

                # System.Management.Automation.PSCustomObject reviews               = @{page=1; results=System.Object[]; total_pages=0; total_results=0}           column_name reviews (dump page, total_pages, total_results)
                # System.Management.Automation.PSCustomObject credits               = @{cast=System.Object[]; crew=System.Object[]}                                column_names cast, crew
                # System.Management.Automation.PSCustomObject images                = @{backdrops=System.Object[]; logos=System.Object[]; posters=System.Object[]} column_names backdrops, logos, posters
                # System.Management.Automation.PSCustomObject belongs_to_collection = @{id=466463; name=Descendants Collection; poster_path=/dw02BxDYnmqW4h0t0qA0T3hd5MZ.jpg; backdrop_path=/bPLL28xj5MqCBYiaixG4yMYKkpe.jpg}
                # System.Management.Automation.PSCustomObject external_ids          = @{imdb_id=tt20202136; wikidata_id=Q115941750; facebook_id=; instagram_id=; twitter_id=}

                if ($sql_data_type -eq '_hstore') {
                    foreach ($hstore_element in $column_value) {
                        if ($hstore_element -is [System.String]) {
                            $sql_add_columns+= @{column_name = $column_name; column_type = '_text'}  # ex: origin_country
                        }
                        elseif ($hstore_element -is [System.Object[]]) {
                            $column_name      = "$column_name`_results????"
                            $sql_data_type    = 'text'
                            $sql_add_columns += @{column_name = $column_name; column_type = $sql_data_type}
                        }
                    }
                }
                else {
                    $sql_add_columns += @{column_name = $column_name; column_type = $sql_data_type}
                }

                foreach ($column_to_add in $sql_add_columns) {
                    if ($current_target_table_column_defs.column_name -notcontains $column_name) {
                        $addcolumntotable = "ALTER TABLE $target_schemad_table ADD $column_name $sql_data_type"
                        Invoke-Sql $addcolumntotable
                    }
                    $insert_header_columns+= ", $column_name
                    "
                    $insert_middle_columns+= ", @$column_name
                    "
                    $insert_footer_columns+= ", $column_name = CASE WHEN EXCLUDED.$column_name IS NOT NULL THEN EXCLUDED.$column_name ELSE $target_table.$column_name END
                    "
                    # JSON attributes sometimes are object arrays of hasharrays, after being converted to PSCustomObjects

                    if ($sql_data_type -eq '_hstore') {
                        foreach ($o in $column_value) {
                            $hstore_item = "{"
                            $prefix_comma = $false

                            foreach ($row in $o.psobject.Members|where membertype -eq 'NoteProperty') {
                                $hstore_column_name = $row.Name
                                $hstore_column_value = $row.Value
                                if ($prefix_comma) {$hstore_item+= ', '}
                                $prefix_comma = $true
                                $hstore_item+= '"'
                                $hstore_item+= "$hstore_column_name=>$hstore_column_value"
                                $hstore_item+= '"'

                            }
                            $hstore_item+= "}"
                            $column_value = $hstore_item
                        }

                    }

                    if ($sql_data_type -eq '_text') {
                        # @{id=466463; name=Descendants Collection; poster_path=/dw02BxDYnmqW4h0t0qA0T3hd5MZ.jpg; backdrop_path=/bPLL28xj5MqCBYiaixG4yMYKkpe.jpg}
                        # @{results=System.Object[]}
                        # @{cast=System.Object[]; crew=System.Object[]}
                        # {US}
                        # {@{id=14; name=Fantasy}, @{id=12; name=Adventure}, @{id=10751; name=Family}, @{id=35; name=Comedy}}
                        $new_array = "{"
                        $prefix_comma = $false
                        foreach ($o in $column_value) {

                            if ($prefix_comma) { $new_array+= ', '}
                            $prefix_comma = $true
                            $new_array+= $o.ToString().Replace("'", "''") # if there's ti
                        }
                        $new_array+= "}"
                        $column_value = $new_array
                    }
                    if ($null -eq $column_value) {
                        $column_value = [System.DBNull]
                    }
                    if ($odbc_data_type -eq 'NText') {
                        $preparedInsertCommand.Parameters.Add("@$column_name", $odbc_data_type, -1, $column_value)
                    } else {
                        $preparedInsertCommand.Parameters.Add("@$column_name", $odbc_data_type, $column_value)
                    }
                } else {

                    if ($null -eq $column_value) {
                        $column_value = [System.DBNull]
                    }

                    $preparedInsertCommand.Parameters["@$column_name"] = $column_value
                }
            }

            if ($collect_and_parameterize_prepared_sql) {
                $sql =
                    $insert_header
                +   $insert_header_columns
                +   $insert_middle
                +   $insert_middle_columns
                +   $insert_footer
                +   $insert_footer_columns

                $preparedInsertCommand.CommandText = $sql
                $preparedInsertCommand.Prepare()
            }
            $collect_and_parameterize_prepared_sql = $false

            $howmanyRowsInserted = $preparedInsertCommand.ExecuteNonQuery()
        }
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
                    $target_id_column
                ,   $target_id_column`_not_found_in_api
                )
                VALUES(
                    $for_id::TEXT
                ,   clock_timestamp()
                )
                ON CONFLICT($target_id_column)
                DO UPDATE
                    SET $target_id_column`_not_found_in_api = clock_timestamp()
                    WHERE EXCLUDED.$target_id_column`_not_found_in_api IS NULL      /* Don't overwrite earlier timestamps if present. */
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


# /html/head/meta[3] = <meta name="description" content="Thor is the rare superhero movie that raises important questions. Namely, the important question “If Thor was considered the good superhero movie of 2011, just exactly how wretched must Green Lantern have been?” Yes, Thor, for all its critical acclaim, features not one, not two, but three distinct scenes of our hero being rendered unconscious for comedic effect all within five">
# <meta name="generator" content="Drupal 7 (http://drupal.org)">
# <meta property="og:type" content="video.movie">
# <meta property="og:title" content="Thor"> /html/head/meta[14]
# <meta property="og:image" content="https://www.rifftrax.com/sites/default/files/images/previews/Thor-thumbnail.jpg">
# <video class="jw-video jw-reset" tabindex="-1" disableremoteplayback="" webkit-playsinline="" playsinline="" src="blob:https://www.rifftrax.com/81ad3a7b-d400-4bff-b003-dadf4b299b97"></video>
# /html/body/div[3]/div/section/div[2]/section[1]/div/div/div[2]/div/div[3]/h3' <h3 class="pane-title">RiffMeter rating    </h3>
# div.star:nth-child(1)
#   span:nth-child(1) html#rtinit.js.RTInitAjax-processed.bsrtAjaxCart-processed.bsrtAddToCart-processed body.html.not-front.not-logged-in.one-sidebar.sidebar-first.page-node.page-node-.page-node-3340126.node-type-riff.disqus-processed.owned-processed div.main-container.container-fluid div.row section.col-sm-9.col-sm-push-3.content-column div.region.region-content section#block-system-main.block.block-system.clearfix div.panelizer-view-mode.node.node-full.node-riff.node-3340126 div.two-66-33.at-panel.panel-display.clearfix div.region.region-two-66-33-second div.region-inner.clearfix div.panel-pane.pane-entity-field.pane-node-field-riffmeter div.pane-content div.clearfix.fivestar-average-stars.fivestar-smart-stars.fivestar-average-text div.fivestar-static-item div.form-item.form-type-item.form-group div.fivestar-riffstars div.fivestar-widget-static.fivestar-widget-static-vote.fivestar-widget-static-10.clearfix div.star.star-1.star-odd.star-first span.on
#   /html/body/div[3]/div/section/div[2]/section[1]/div/div/div[2]/div/div[3]/div/div/div/div/div[1]/div/div[1]/span
#     <span class="on">8.58824</span>
# <iframe src="https://widget.justwatch.com/inline_widget?iframe_key=0&amp;language=en&amp;api_key=79dAuEcrnNtJ2SagQMR4Lcf72DESRljY&amp;object_type=movie&amp;id=&amp;id_type=imdb&amp;webpage=https%3A%2F%2Fwww.rifftrax.com%2Fthor" class="jw-widget-iframe" width="100%" height="32px" style="border-radius: 4px;" frameborder="0"></iframe>
# html#rtinit.js.RTInitAjax-processed.bsrtAjaxCart-processed.bsrtAddToCart-processed body.html.not-front.not-logged-in.one-sidebar.sidebar-first.page-node.page-node-.page-node-3340126.node-type-riff.disqus-processed.owned-processed div.main-container.container-fluid div.row section.col-sm-9.col-sm-push-3.content-column div.region.region-content section#block-system-main.block.block-system.clearfix div.panelizer-view-mode.node.node-full.node-riff.node-3340126 div.two-66-33.at-panel.panel-display.clearfix div.region.region-two-66-33-second div.region-inner.clearfix div.panel-pane.pane-entity-field.pane-node-field-collection div.pane-content div.field-collection
#  <a href="https://www.rifftrax.com/collection/marvel-comics">Marvel Comics</a>
# html#rtinit.js.RTInitAjax-processed.bsrtAjaxCart-processed.bsrtAddToCart-processed body.html.not-front.not-logged-in.one-sidebar.sidebar-first.page-node.page-node-.page-node-3340126.node-type-riff.disqus-processed.owned-processed div.main-container.container-fluid div.row section.col-sm-9.col-sm-push-3.content-column div.region.region-content section#block-system-main.block.block-system.clearfix div.panelizer-view-mode.node.node-full.node-riff.node-3340126 div.two-66-33.at-panel.panel-display.clearfix div.region.region-two-66-33-second div.region-inner.clearfix div.panel-pane.pane-entity-field.pane-node-field-genre
#  <a href="https://www.rifftrax.com/catalog/genre/action">Action</a>
# html#rtinit.js.RTInitAjax-processed.bsrtAjaxCart-processed.bsrtAddToCart-processed body.html.not-front.not-logged-in.one-sidebar.sidebar-first.page-node.page-node-.page-node-3340126.node-type-riff.disqus-processed.owned-processed div.main-container.container-fluid div.row section.col-sm-9.col-sm-push-3.content-column div.region.region-content section#block-system-main.block.block-system.clearfix div.panelizer-view-mode.node.node-full.node-riff.node-3340126 div.two-66-33.at-panel.panel-display.clearfix div.region.region-two-66-33-second div.region-inner.clearfix div.panel-pane.pane-entity-field.pane-node-field-decade-released
#  <a href="https://www.rifftrax.com/catalog/era/2010">2010s</a>
# html#rtinit.js.RTInitAjax-processed.bsrtAjaxCart-processed.bsrtAddToCart-processed body.html.not-front.not-logged-in.one-sidebar.sidebar-first.page-node.page-node-.page-node-3340126.node-type-riff.disqus-processed.owned-processed div.main-container.container-fluid div.row section.col-sm-9.col-sm-push-3.content-column div.region.region-content section#block-system-main.block.block-system.clearfix div.panelizer-view-mode.node.node-full.node-riff.node-3340126 div.two-66-33.at-panel.panel-display.clearfix div.region.region-two-66-33-second div.region-inner.clearfix div.panel-pane.pane-entity-field.pane-node-field-date-released
# div.panel-pane:nth-child(21)
# /html/body/div[3]/div/section/div[2]/section[1]/div/div/div[2]/div/div[21]
#  <span class="date-display-single">September 27, 2011</span><span class="date-display-single">September 27, 2011</span>
# <a href="https://www.rifftrax.com/sites/default/files/thorweb.jpg"><img data-nid="3340126" class="img-responsive" src="https://www.rifftrax.com/sites/default/files/styles/poster_medium/public/thorweb.jpg" width="450" height="600" alt="Poster art by Jason Martian"></a>
# /html/body/div[3]/div/section/div[2]/section[1]/div/div/div[2]/div/div[19]/h2
# html#rtinit.js.RTInitAjax-processed.bsrtAjaxCart-processed.bsrtAddToCart-processed body.html.not-front.not-logged-in.one-sidebar.sidebar-first.page-node.page-node-.page-node-3340126.node-type-riff.disqus-processed.owned-processed div.main-container.container-fluid div.row section.col-sm-9.col-sm-push-3.content-column div.region.region-content section#block-system-main.block.block-system.clearfix div.panelizer-view-mode.node.node-full.node-riff.node-3340126 div.two-66-33.at-panel.panel-display.clearfix div.region.region-two-66-33-second div.region-inner.clearfix div.panel-pane.pane-views.pane-riffers h2.pane-title
#  <h2 class="pane-title">Riffed By    </h2>
# /html/body/div[3]/div/section/div[2]/section[1]/div/div/div[2]/div/div[19]/div/div/div/div[1]/span/div/a
# html#rtinit.js.RTInitAjax-processed.bsrtAjaxCart-processed.bsrtAddToCart-processed body.html.not-front.not-logged-in.one-sidebar.sidebar-first.page-node.page-node-.page-node-3340126.node-type-riff.disqus-processed.owned-processed div.main-container.container-fluid div.row section.col-sm-9.col-sm-push-3.content-column div.region.region-content section#block-system-main.block.block-system.clearfix div.panelizer-view-mode.node.node-full.node-riff.node-3340126 div.two-66-33.at-panel.panel-display.clearfix div.region.region-two-66-33-second div.region-inner.clearfix div.panel-pane.pane-views.pane-riffers div.pane-content div.view.view-riffers.view-id-riffers.view-display-id-block.view-dom-id-ba6b4e30a08ad82d998c0bdd8b2374ba div.view-content div span.views-field.views-field-title div.field-content a
#  <a href="/riffer/bill-corbett">Bill Corbett</a>
#  <a href="/riffer/kevin-murphy">Kevin Murphy</a>
#  <a href="/riffer/mike-nelson">Mike Nelson</a>
# html#rtinit.js.RTInitAjax-processed.bsrtAjaxCart-processed.bsrtAddToCart-processed body.html.not-front.not-logged-in.one-sidebar.sidebar-first.page-node.page-node-.page-node-3340126.node-type-riff.disqus-processed.owned-processed div.main-container.container-fluid div.row section.col-sm-9.col-sm-push-3.content-column div.region.region-content section#block-system-main.block.block-system.clearfix div.panelizer-view-mode.node.node-full.node-riff.node-3340126 div.two-66-33.at-panel.panel-display.clearfix div.region.region-two-66-33-second div.region-inner.clearfix div.panel-pane.pane-entity-field.pane-node-field-riffmeter div.pane-content div.clearfix.fivestar-average-stars.fivestar-smart-stars.fivestar-average-text div.fivestar-static-item div.form-item.form-type-item.form-group div.help-block div.fivestar-summary.fivestar-summary-average-count
#  <span>8.6</span>
# html#rtinit.js.RTInitAjax-processed.bsrtAjaxCart-processed.bsrtAddToCart-processed body.html.not-front.not-logged-in.one-sidebar.sidebar-first.page-node.page-node-.page-node-3340126.node-type-riff.disqus-processed.owned-processed div.main-container.container-fluid div.row section.col-sm-9.col-sm-push-3.content-column div.region.region-content section#block-system-main.block.block-system.clearfix div.panelizer-view-mode.node.node-full.node-riff.node-3340126 div.two-66-33.at-panel.panel-display.clearfix div.region.region-two-66-33-second div.region-inner.clearfix div.panel-pane.pane-entity-field.pane-node-field-riffmeter div.pane-content div.clearfix.fivestar-average-stars.fivestar-smart-stars.fivestar-average-text div.fivestar-static-item div.form-item.form-type-item.form-group div.help-block div.fivestar-summary.fivestar-summary-average-count span.total-votes
#  <span>204</span>
# Something you should know: <p>Contains excessive amounts of chest-bursting.</p>
# Digital Video (SD) or "Just the Jokes)"
# Get this MST3K Episode!  Episode: 607

# Content Rating: TV-MA-LV (Profanity, Violence)
# <div class="panel-pane pane-entity-field pane-node-field-runtime-minutes">
#  <div class="pane-content">  84 minutes  </div>
# <h2 class="pane-title"> Runtime <a href="https://bit.ly/3YqtXv3" target="_blank"><small><span class="glyphicon glyphicon-question-sign"></span></small></a>    </h2> <div class="pane-content"> 84 minutes  </div> </div>

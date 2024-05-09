<#
 #    FilmCab Daily morning batch run process: Fetch what qBittorrents are still active, stalled, or stuck downloading metadata.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Conception
 #
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #    https://github.com/andrewmolyneux/qbittorrent-powershell/blob/master/QBittorrent.psm1
 #>

 try {
    $Script:__DISABLE_DETECTING_SCHEDULED_TASK = $true # Speed for testing.

    . .\_dot_include_standard_header.ps1
    DisplayTimePassed ("Starting program...")
    Add-Type -ReferencedAssemblies ("Microsoft.Powershell.Commands.Utility") -TypeDefinition @"
        using System;
        using Microsoft.PowerShell.Commands;
        public struct QbtSession
        {
            public QbtSession(Uri UriIn)
            {
                Uri = UriIn;
                Session = new WebRequestSession();
            }
            public Uri Uri;
            public WebRequestSession Session;
        }
"@

Add-Type -TypeDefinition @"
    public enum QbtSort
    {
        Hash,     Name,        Size,      Progress,      Dlspeed,  Upspeed, Priority,
        NumSeeds, NumComplete, NumLeechs, NumIncomplete, Ratio,    Eta,     State,
        SeqDl,    FLPiecePrio, Category,  SuperSeeding,  ForceStart
    }
"@

Add-Type -TypeDefinition @"
    public enum QbtFilter
    {
        All, Downloading, Completed, Paused, Active, Inactive
    }
"@
    Function Join-Uri(
        [Parameter(Mandatory=$true)][Uri] $Uri,
        [Parameter(Mandatory=$true)][String] $Path) {
        $x = New-Object System.Uri ($Uri, $Path)
        $x.AbsoluteUri
    }

    Function Get-UTF8JsonContentFromResponse(
        #[Parameter(Mandatory=$true)][Microsoft.PowerShell.Commands.HtmlWebResponseObject] $Content) {
        [Parameter(Mandatory=$true)] $Content) {
        # qBittorrent returns UTF-8 encoded results, but doesn't specify
        # charset=UTF-8 in the Content-Type response header. Technically,
        # because the Content-Type is application/json the default should
        # be UTF-8 anyway. Apparently Invoke-WebRequest doesn't know this.
        $Buffer = New-Object byte[] $Response.RawContentLength
        $Response.RawContentStream.Read($Buffer, 0, $Response.RawContentLength) | Out-Null
        $Decoded = [System.Text.Encoding]::UTF8.GetString($Buffer)
        $Decoded | ConvertFrom-Json
    }

    Function ConvertTo-QbittorrentName(
    [Parameter(Mandatory=$true)] [String] $PowerShellName) {
    # Remember the first character.
    $FirstCharacter = $PowerShellName[0]
    # Split on capital letters.
    $Chunks = $PowerShellName.Substring(1) -csplit "([A-Z])"
    # Join it all back together with the capital letters prefixed with underscores.
    $Result = $FirstCharacter
    foreach ($Chunk in $Chunks) {
        if ($Chunk.Length -eq 1) {
            $Result += "_$Chunk"
        } else {
            $Result += $Chunk
        }
    }
    $Result.ToLowerInvariant()
}
    Function ConvertTo-PowerShellName(
        [Parameter(Mandatory=$true)] [String] $QbtName) {
        # Split on underscores.
        $Words = $QbtName -split "_"
        # If the first character of each word is a letter, make it capital.
        $CapitalisedWords = $Words | ForEach-Object { $_.Substring(0,1).ToUpperInvariant() + $_.Substring(1) }
        # Join it all back together without the underscores.
        $CapitalisedWords -join ""
    }

    Function ConvertTo-TorrentObjects(
        [Parameter(Mandatory=$true)][PSObject] $Array) {
        foreach ($Object in $Array) {
            $NewObject = New-Object PSObject
            $NewObject.PSObject.TypeNames.Insert(0, 'Qbt.Torrent')
            $Object.PSObject.Properties | ForEach-Object {
                $Value = $_.Value
                if ($_.Name -in ("added_on","completion_on","last_activity","seen_complete")) { # ratio, num_seeds, num_leeches, state, tags, time_active, total_size, tracker, upspeed, magnet_uri, name, save_path, hash, eta, download_path, content_path
                    $Value = ConvertFrom-Timestamp $Value
                }
                $NewObject | Add-Member -NotePropertyName (ConvertTo-PowerShellName $_.Name) -NotePropertyValue $Value
            }
            Write-Output $NewObject
        }
    }
    Function ConvertTo-TorrentProperties(
        [Parameter(Mandatory=$true)][PSObject] $Array) {
        foreach ($Object in $Array) {
            $NewObject = New-Object PSObject
            $NewObject.PSObject.TypeNames.Insert(0, 'Qbt.TorrentProperties')
            $Object.PSObject.Properties | ForEach-Object {
                $Value = $_.Value
                if ($_.Name -in ("addition_date","completion_date","creation_date","last_seen")) {
                    $Value = ConvertFrom-Timestamp $Value
                }
                $NewObject | Add-Member -NotePropertyName (ConvertTo-PowerShellName $_.Name) -NotePropertyValue $Value
            }
            Write-Output $NewObject
        }
    }

    Function Get-QbtTorrentProperty(
    [Parameter(Mandatory=$true)][QbtSession] $Session,
    [Parameter(Mandatory=$true)][String] $Hash) {
    $Uri = Join-Uri $Session.Uri "query/propertiesGeneral/$Hash"
    $Response = Invoke-WebRequest $Uri -WebSession $Session.Session
    ConvertTo-TorrentProperties (Get-UTF8JsonContentFromResponse $Response)
}
    Function ConvertFrom-Timestamp(
        [Parameter(Mandatory=$true)][Object] $Timestamp) {
        if ($Timestamp -eq -1 -or $Timestamp -eq [Uint32]::MaxValue) {
            [DateTime]::MinValue
        } else {
            (Get-Date "1970-01-01T00:00:00").AddSeconds($Timestamp)
        }
    }

    Function Get-QbtTorrent(
        [Parameter(Mandatory=$true,Position=1,ParameterSetName="AnyCategory")]
        [Parameter(Mandatory=$true,Position=1,ParameterSetName="NoCategory")]
        [Parameter(Mandatory=$true,Position=1,ParameterSetName="WithCategory")]
        [QbtSession] $Session,
        [QbtFilter] $Filter,
        [Parameter(Mandatory=$true,ParameterSetName="NoCategory")]
        [Switch] $NoCategory,
        [Parameter(Mandatory=$true,ParameterSetName="WithCategory")]
        [String] $Category,
        [QbtSort] $Sort,
        [Switch] $ReverseSort,
        [Int32] $Limit,
        [Int32] $Offset) {
        $Params = @{}
        if ($Filter)      { $Params.Add("filter",   (ConvertTo-QbittorrentName $Filter.ToString())) }
        if ($Sort)        { $Params.Add("sort",     (ConvertTo-QbittorrentName $Sort.ToString())) }
        if ($Limit)       { $Params.Add("limit",    $Limit) }
        if ($Offset)      { $Params.Add("offset",   $Offset) }
        if ($NoCategory)  { $Params.Add("category", "") }
        if ($Category)    { $Params.Add("category", $Category) }
        if ($ReverseSort) { $Params.Add("reverse",  "true") }
        # https://github.com/qbittorrent/qBittorrent/wiki/WebUI-API-(qBittorrent-4.1)#get-torrent-list
        $Response = Invoke-WebRequest (Join-Uri $Session.Uri api/v2/torrents/info) -WebSession $Session.Session -Body $Params
        ConvertTo-TorrentObjects (Get-UTF8JsonContentFromResponse $Response)

    }

    $Uri      = $Script:SUPER_SECRET_SQUIRREL.super_secret_qbittorrent_webui_login_url
    $Username = $Script:SUPER_SECRET_SQUIRREL.super_secret_qbittorrent_webui_login_user
    $Password = $Script:SUPER_SECRET_SQUIRREL.super_secret_qbittorrent_webui_login_password

    $connectedAPISession = [QbtSession]::new($Uri)
    # https://github.com/qbittorrent/qBittorrent/wiki/WebUI-API-(qBittorrent-4.1)#login
    $Response = Invoke-WebRequest (Join-Uri $Uri api/v2/auth/login) -WebSession $connectedAPISession.Session -Method Post -Body @{username=$Username;password=$Password} -Headers @{Referer=$Uri}
    DisplayTimePassed ("Logging in...")
    if ($Response.Content -ne "Ok." -and $Response.StatusDescription -ne "OK") {
        # <h1>JavaScript Required! You must enable JavaScript for the Web UI to work properly</h1>
        throw "Login failed: $($Response.Content)"
    }

    DisplayTimePassed ("Fetching all torrent details...")
    $torrents = Get-QbtTorrent $connectedAPISession # -Limit 2
    DisplayTimePassed ("Completed fetching all torrent details.")

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
            #$typename = $matches['typename']
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
            #$typeName
            $x = [PSCustomObject]@{
                ColumnName = $_.Name
                ColumnDataType = $typeName
            }
            $prefix = ","

            if ($firstRow) {
                $prefix = " "
                $firstRow = $false
            }

            $tail = ""
            if ($_.Name -in ('MagnetUri', 'Name', 'Hash', 'InfohashV1', 'ContentPath')) {
                $tail = " UNIQUE"
            }
            $Script:createTargetTableScript+= "$prefix   $($x.ColumnName)     $($x.ColumnDataType)$tail
            "
        }

        $Script:createTargetTableScript+= ")"

        #$Script:createTargetTableScript
    }

    Invoke-Sql "TRUNCATE TABLE torrents_staged"

    $torrentsStagedLoadBatchId = [Int64](Get-SqlValue("SELECT nextval('torrents_staged_load_batch_id')"))
    $loadBatchTimestamp = Get-Date
    $loadBatchTimestamp = TrimToMicroseconds $loadBatchTimestamp
    $loadBatchTimestamp = $loadBatchTimestamp.ToString($DEFAULT_POWERSHELL_TIMESTAMP_FORMAT)
    $loadBatchTimestamp = "'$loadBatchTimestamp'::TIMESTAMPTZ"

    foreach ($torrent in $torrents) {
        $Script:InsertTargetTableScript = "INSERT INTO torrents_staged (
                load_batch_timestamp
            ,   load_batch_id
            "
        $firstRow = $true

        $torrent|gm|Where MemberType -eq 'NoteProperty'| Sort Name|%{
            $_.Definition -match "(?<typename>.*?)[ ]"|Out-Null
            #$typename = $matches['typename']
            $typeName = $matches['typename']
            #$typeName
            $x = [PSCustomObject]@{
                ColumnName = $_.Name
                ColumnDataType = $typeName
            }
            $prefix = ","

            if ($firstRow) {
                $prefix = ","
                $firstRow = $false
            }

            $Script:InsertTargetTableScript+= "$prefix   $($x.ColumnName)
            "

            #Select @{Name='ColumnName';Expression=$_.Name}|Out-Host
        }

        $Script:insertTargetTableScript+= ")"

        #$Script:insertTargetTableScript

        $Script:InsertTargetTableScriptValues = "VALUES (
            $loadBatchTimestamp
        ,   $torrentsStagedLoadBatchId
        "
        $firstRow = $true

        $torrent.PSObject.Properties| Sort Name|%{
            $outval = $_.Value
            switch ($_.TypeNameOfValue) {
                'System.String' { $outval = PrepForSql $outval}
                'System.DateTime' {
                    $outvalasdate = TrimToMicroseconds $outval
                    $outval = $outvalasdate.ToString($DEFAULT_POWERSHELL_TIMESTAMP_FORMAT)
                    $outval = "'$outval'::TIMESTAMPTZ"
                }
            }
            $prefix = ","
            if ($firstRow) {
                $prefix = ","
                $firstRow = $false
            }

            $Script:InsertTargetTableScriptValues+= "$prefix   $outval
            "
        }
        $Script:InsertTargetTableScriptValues+= ") ON CONFLICT DO NOTHING"

        $Script:InsertTargetTableScript = $Script:InsertTargetTableScript + $Script:InsertTargetTableScriptValues
        #$Script:InsertTargetTableScript
        Invoke-Sql $Script:InsertTargetTableScript|Out-Null
        # TODO: Load properties of torrent
        # TODO: Load trackers of torrent
        # TODO: Load webseeders of torrent
    }

    # TODO: Merge into torrents (only keeps newest status, keeps deleted torrent)
    # TODO: Add to torrents_history so we can try and figger out where things stall.
    $Response = Invoke-WebRequest (Join-Uri $Uri api/v2/auth/logout) -WebSession $connectedAPISession.Session -Method Post  -Headers @{Referer=$Uri}
}
catch {
Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}
finally {
Write-AllPlaces "Finally"
. .\_dot_include_standard_footer.ps1
}

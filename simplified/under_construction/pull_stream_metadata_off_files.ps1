<#
 #    FilmCab Daily morning batch run process: Get internal id of files to detect name changes that mean no actual backup.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Concept
 #    ###### Tue Jan 23 18:23:11 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #>

try {
. .\_dot_include_standard_header.ps1

$howManyUpdatedFiles     = 0

# Let's traverse all the undeleted directories flagged for scan. scan_for_file_directories sets the flag before this daily.

$walkThruAllFilesReader = WhileReadSql "
    SELECT
        file_id
    ,   file_path
    ,   file_ntfs_id         AS in_db_file_ntfs_id
    ,   final_extension
    FROM
        files_ext_v
    WHERE
        NOT directory_deleted
    AND
        NOT directory_is_symbolic_link
    AND
        NOT directory_is_junction_link
    AND
        NOT file_deleted
    AND
        NOT moved_out
    AND
        NOT file_is_symbolic_link
    AND
        NOT file_is_hard_link
    --AND
    --    NOT file_has_no_ads
    --AND
    --    file_path IN('G:\Video AllInOne Backup\_Fantasy\Fantastic Planet (1973).mkv', 'O:\Video AllInOne\_Adventure\Jumanji - Welcome to the Jungle (2017).mkv', 'O:\Video AllInOne\_Super Heroes\Marvel\F4\Fantastic Four Rise of the Silver Surfer (2007).mkv')
"
Import-Module Get-MediaInfo
class Tag {
    [string]$tagName
    [string]$tagType
    [string[]]$tagValues
}
$tags = @()

$howManyFilesWithADS = 0

# TODO: Try on pdf, txt, mp3, doc, docx

While ($walkThruAllFilesReader.Read()) {
    if ((Test-Path -LiteralPath $file_path)) {
        $insertTagsSqlTop = @"
            INSERT INTO simplified.files_alternate_data_streams(
                file_id
"@
        $insertTagsSqlBottom = @"
            )
            VALUES(
                $file_id
"@
        #_TICK_Found_Existing_Object
        Unblock-File -LiteralPath $file_path # Remove in dumb shit "Zone.Identifier [ZoneTransfer] ZoneId=3"
        [object[]]$file_streams = $null
        try {
            $file_streams = Get-Item -LiteralPath $file_path -Stream * -Force # 'D:\qBittorrent Downloads\Video\Movies\.14a11a46d30e99f7a47e457a4adbc349ef23f441.parts' required the Force parameter to open.

            $hasMeaningfulStream = $Script:pretest_assuming_false

            foreach ($file_stream in $file_streams) {
                if ($file_stream.Stream -notin ":`$DATA") {
                    $file_stream_content = Get-Item -LiteralPath $file_path -Stream $file_stream.Stream |Get-Content
                    $currentSection      = ""
                    $hasMeaningfulStream = $true
                    foreach ($line in $file_stream_content) {
                        $linecolumns = $line -split "`t"

                        $line = $line.Replace("`t", '{\t}')
                        if ($linecolumns.Count -eq 1) {
                            $currentSection = $linecolumns[0]
                        }
                        if ($linecolumns.Count -gt 2) {
                            Write-AllPlaces "<$line>!!!"
                        }
                        if ($linecolumns.Count -eq 2) {
                            $tagName              = ("$currentSection`_$($linecolumns[0] -replace '/', '_')").ToLower()
                            $tagValue             = $linecolumns[1]
                            $tagInList            = $tags.Where({$_.tagName -eq $tagName})
                            if (-not $tagInList) {
                                $insertTagsSqlTop    += ", `"$tagName`" "
                                $insertTagsSqlBottom += ", $(PrepForSql $tagValue) "
                                $tag = [Tag]::new()
                                $tag.tagName = $tagName
                                [array]$tag.tagValues= [array]@($tagValue)
                                $tag.tagType = 'text'
                                if ($tagValue -as [Int32] -is [Int32]) {
                                    $tag.tagType = "integer"
                                }
                                if ($linecolumns[0] -eq 'Duration') {$tag.tagType = 'decimal(15,6)'}
                                if ($linecolumns[0] -eq 'FrameRate') {$tag.tagType = 'decimal(10,4)'}
                                if ($linecolumns[0] -eq 'PixelAspectRatio') {$tag.tagType = 'decimal(10,4)'}
                                if ($linecolumns[0] -eq 'DisplayAspectRatio') {$tag.tagType = 'decimal(10,4)'}
                                if ($linecolumns[0] -eq 'FileSize') {$tag.tagType = 'int8'}
                                if ($linecolumns[0] -eq 'StreamSize') {$tag.tagType = 'int8'}
                                if ($linecolumns[0] -eq 'UniqueID') {$tag.tagType = 'text'}
                                if ($linecolumns[0] -eq 'BitRate') {$tag.tagType = 'int8'}
                                if ($linecolumns[0] -eq 'SamplingCount') {$tag.tagType = 'int8'}
                                if ($linecolumns[0] -eq 'StreamSize_Proportion') {$tag.tagType = 'decimal(10,5)'}
                                if ($linecolumns[0] -ieq 'video_bits-(pixel*frame)') {$tag.tagType = 'decimal(6,4)'}
                                if ($linecolumns[0] -ilike 'dialnorm*') {
                                    $tag.tagType = 'text'
                                    $tagName
                                }


                                $tags+= $tag
                            } else {
                                if ($tagInList[0].tagValues -notcontains $tagValue) {
                                    if (-not ($tagInList[0].tagValues -is [array])) {
                                        $tagInList[0].tagValues = @($tagInList[0].tagValues, $tagValue)
                                    } else {
                                        [array]$tagInList[0].tagValues+= $tagValue
                                    }
                                }
                                # Add new value to subset if unique  $tagInList/tagValues contains....
                                # TODO: Convert encoded_date 2011-03-19 14:45:45 UTC to actual timestamp.
                            }
                        }
                    }
                }
            }
            if ($hasMeaningfulStream) {
                $file_path
                $howManyFilesWithADS++
                $insertTagsSqlBottom+= ") ON CONFLICT DO NOTHING"
                $insertTagsSql = ReplaceAll ($insertTagsSqlTop + $insertTagsSqlBottom) -what "`n`n" -with "`n"  # blank lines break Postgres sql
                $insertTagsSql = ReplaceAll $insertTagsSql -what "`r`n`r`n" -with "`r`n"
                Invoke-Sql ($insertTagsSql.Trim())|Out-Null
            } else {
                Invoke-Sql "UPDATE files_v SET has_no_ads = TRUE WHERE file_id = $file_id"|Out-Null
                # https://github.com/stax76/MediaInfo.NET
                $mediaInfo = Get-MediaInfo -Path $file_path
                if ($null -ne $mediaInfo) {
                    $mediaInfo
                    $mediaFileDetail = Get-MediaInfoSummary -Full -Raw -Path $file_path
                    $mediaFileDetail
                }
            }

        }
        catch {
            if ($_.Exception.Message -ne 'The system cannot find the path specified.') {
                $_.Exception
            } else {
                Invoke-Sql "UPDATE files_v SET has_no_ads = TRUE WHERE file_id = $file_id"|Out-Null
                if ($final_extension -notin 'txt', 'idx', 'sub') {
                    Write-AllPlaces $file_path
                }
            }
        }
    }
}

foreach ($tag in $tags)
{
    $tagName = "`"$($tag.tagname)`"".PadRight(64) # Max name length in Postgres is 63
    $tagValuesList = ellipseString($tag.tagValues -join ", ") -cutoff 200
    Write-Host ", $tagname $($tag.tagType.PadRight(15)) /* $tagValuesList */"
}
#$tags

Write-Count howManyFilesWithADS           File

}
catch {
    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}
finally {
    #Write-AllPlaces "Finally"
    . .\_dot_include_standard_footer.ps1
}
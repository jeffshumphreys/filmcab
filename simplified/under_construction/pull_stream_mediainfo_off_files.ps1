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
    AND
        file_path IN(
            --'G:\Video AllInOne Backup\_Fantasy\Fantastic Planet (1973).mkv'
            --, 'O:\Video AllInOne\_Adventure\Jumanji - Welcome to the Jungle (2017).mkv',
            'O:\Video AllInOne\_Super Heroes\Marvel\F4\Fantastic Four Rise of the Silver Surfer (2007).mkv'
        )
"
Import-Module Get-MediaInfo
class Tag {
    [string]$tagName
    [string]$tagType
    [string[]]$tagValues
}
$tags = @()


# TODO: Try on pdf, txt, mp3, doc, docx

While ($walkThruAllFilesReader.Read()) {
    $existingColumns = @(Out-SqlToDataset "SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'simplified'
    AND table_name   = 'files_media_info'
    ORDER BY 1"|Select column_name).column_name
    $howManyAddingColumns = 0
    $AddNewColumns = "ALTER TABLE simplified.files_media_info "

    if ((Test-Path -LiteralPath $file_path)) {
        $file_path
        $insertTagsSqlTop = @"
            INSERT INTO simplified.files_media_info(
                file_id
"@
        $insertTagsSqlBottom = @"
            )
            VALUES(
                $file_id
"@
        #_TICK_Found_Existing_Object
        Unblock-File -LiteralPath $file_path # Remove in dumb shit "Zone.Identifier [ZoneTransfer] ZoneId=3"
        # https://github.com/stax76/MediaInfo.NET
        $mediaFileDetail = Get-MediaInfoSummary -Full -Raw -Path $file_path
        if ($null -ne $mediaFileDetail) { # Some files, like srt and txt, return null.
            $column_name_prefix = ""
            $alreadyOccurred = @()
            foreach ($line in $mediaFileDetail) { # process and parse each line returned from MediaInfo tool.
                if (-not([string]::IsNullOrWhiteSpace($line))) { # First line is blank
                    $key_value_pair = $line -split ":"
                    $tag = $key_value_pair[0].Trim()
                    if ($key_value_pair.Length -eq 1) {
                        $column_name_prefix = $tag.Trim() # Has a lot of trailing space that will screw up
                    } else {
                        $value = $key_value_pair[1].Trim()
                        $targetColumn = ("$column_name_prefix`_$tag").ToLower()
                        if ($existingColumns -notcontains $targetColumn) {
                            # audio_dialnorm_average appears twice, once "-31", then "-31 dB" same for others: audio_dialnorm_average
                            #if ($targetColumn -eq "audio_dialnorm_average") {
                            #    Write-AllPlaces "!";
                            #}
                            $type = "TEXT";
                            if ($targetColumn -in $alreadyOccurred) {
                                if ($targetColumn -like "audio_dialnorm*") {
                                    $targetColumn+= "_str"
                                }
                            }
                            # menu__00 and 01 could be added as arrays?

                            if ($targetColumn -match "menu_\n\n") {
                                $type = "TEXT[]"
                            }

                            if ($type -eq "TEXT[]" -and $targetColumn -in $alreadyOccurred) {
                                # TODO: Add logic to build string array constant to insert into menu arrays.
                            } else {
                                if ($howManyAddingColumns -gt 0) {
                                    $AddNewColumns+= ","
                                }
                                $howManyAddingColumns++
                                $AddNewColumns+= " ADD COLUMN `"$targetColumn`" $type"
                            }
                            $alreadyOccurred+= $targetColumn
                            Write-AllPlaces "$targetColumn : $value"
                            # Build insert with array for menu stuff
                        }

                        # Build insert
                    }
                }
            }
            if ( $howManyAddingColumns -gt 0) {
                Invoke-Sql $AddNewColumns
            }
        }
    }
}
}
catch {
    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}
finally {
    #Write-AllPlaces "Finally"
    . .\_dot_include_standard_footer.ps1
}
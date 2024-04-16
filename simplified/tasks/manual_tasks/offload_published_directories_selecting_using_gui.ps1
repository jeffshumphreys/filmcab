<#
#    FilmCab Daily morning batch run process: Fills up published so hard to fine stuff I haven't watched.
#    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
#    Status: Conception
#    ###### Tue Mar 5 16:23:46 MST 2024
#    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
#>

<#
#    FilmCab Daily morning batch run process: Track our nearness to filling up our space
#    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
#    Status: Conception
#    ###### Sat Feb 3 22:20:01 MST 2024
#    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
#    https://devblogs.microsoft.com/scripting/hey-scripting-guy-how-can-i-use-the-windows-forms-treeview-control/
#>

try {
. .\_dot_include_standard_header.ps1

. .\_dot_include_gui_tools.ps1

Import-Module BitsTransfer

$form                                    = New-Object System.Windows.Forms.Form
$form.Text                               = "Select a directory to offload"
$form.StartPosition                      = "CenterScreen"
$form.WindowState                        = 'Maximized'
$form.Height                             = $ScreenHeight
$form.Width                              = $ScreenWidth
$BUTTON_WIDTH                            = 75
$BUTTON_HEIGHT                           = 23
$HORIZONTAL_SPACER                       = 5
$VERTICAL_SPACER                         = 2

$sequenceControlIgnoreNext_afterSelectTreeview = $false

# <#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($OKButton)<#~~~~~~~~~~~~~~~~~~~~#>

########################################################################################################################################################################################################
$CancelButton                            = New-Object System.Windows.Forms.Button
#$CancelButton.Location                   = New-Object System.Drawing.Point(($ScreenWidth - $BUTTON_WIDTH),($ScreenHeight - $BUTTON_HEIGHT))
#$CancelButton.Size                       = New-Object System.Drawing.Size($BUTTON_WIDTH, $BUTTON_HEIGHT)
#$CancelButton.Text                       = "Cancel"
$CancelButton.DialogResult               = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton                       = $CancelButton

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($CancelButton)<#~~~~~~~~~~~~~~~~~~~~#>
$CancelButton.Hide() # Has to be present so "X" closes.

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Column 1
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
$columnWidth1                            = 344
$treeViewWidth                           = $columnWidth1

########################################################################################################################################################################################################
$treeViewOfPublishedDirectories          = New-Object System.Windows.Forms.TreeView
$treeViewOfPublishedDirectories.Location = New-Object System.Drawing.Point(0,0)
$treeViewOfPublishedDirectories.Size     = New-Object System.Drawing.Size($treeViewWidth, $ScreenHeight)
$treeViewOfPublishedDirectories.TabIndex = 0

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($treeViewOfPublishedDirectories)<#~~~~~~~~~~~~~~~~~~~~#>

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Column 2
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
$maxObjectWidth2                         = 280
$columnWidth2                            = $maxObjectWidth2 + ($HORIZONTAL_SPACER*2)

########################################################################################################################################################################################################
$selectedMoveReasonLabel                 = New-Object System.Windows.Forms.Label
$selectedMoveReasonLabel.Location        = New-Object System.Drawing.Point(($treeViewWidth + $HORIZONTAL_SPACER), ($BUTTON_HEIGHT * 2))
$selectedMoveReasonLabel.Size            = New-Object System.Drawing.Size(($columnWidth2), $BUTTON_HEIGHT)
$selectedMoveReasonLabel.Text            = "Move Reason"

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($selectedMoveReasonLabel)<#~~~~~~~~~~~~~~~~~~~~#>

########################################################################################################################################################################################################
$selectedmoveReasonComboBox              = New-Object System.Windows.Forms.ComboBox
$selectedmoveReasonComboBox.Location     = New-Object System.Drawing.Point(($treeViewWidth+$HORIZONTAL_SPACER), ($BUTTON_HEIGHT * 3))
$selectedmoveReasonComboBox.Size         = New-Object System.Drawing.Size($maxObjectWidth2, $BUTTON_HEIGHT)
$selectedmoveReasonComboBox.Items.AddRange("Seen", "Won't Watch", "Won't Finish", "No Subtitles", "Corrupt", "Poor Quality", 'Copyright Audio')|Out-Null

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($selectedmoveReasonComboBox)<#~~~~~~~~~~~~~~~~~~~~#>

########################################################################################################################################################################################################
$whyThisMoveReasonText                   = New-Object System.Windows.Forms.TextBox
$whyThisMoveReasonText.AutoSize          = $false
$whyThisMoveReasonText.Location          = New-Object System.Drawing.Point(($treeViewWidth + $HORIZONTAL_SPACER), ($BUTTON_HEIGHT * 4))
$whyThisMoveReasonText.Size              = New-Object System.Drawing.Size(($columnWidth2), ($BUTTON_HEIGHT*3))
$whyThisMoveReasonText.PlaceholderText   = "Explain why this move reason"
$whyThisMoveReasonText.Multiline         = $true
$whyThisMoveReasonText.WordWrap          = $true

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($whyThisMoveReasonText)<#~~~~~~~~~~~~~~~~~~~~#>

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Column 3
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
$maxObjectWidth3                         = 680
$columnWidth3                            = $maxObjectWidth3 + ($HORIZONTAL_SPACER*2)
$maxObjectWidth3b                        = 100
$columnWidth3b                           = $maxObjectWidth3b + ($HORIZONTAL_SPACER)

########################################################################################################################################################################################################

# $activityAnimation                       = New-Object System.Windows.Forms.PictureBox
# $activityAnimation.Location              = New-Object System.Drawing.Point(($treeViewWidth + $HORIZONTAL_SPACER + $columnWidth2), ($BUTTON_HEIGHT * 4))
# $activityAnimation.Size                  = New-Object System.Drawing.Size(($columnWidth2), ($BUTTON_HEIGHT*3))
# $activityAnimation.SizeMode              = 'StretchImage'

# <#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($activityAnimation)<#~~~~~~~~~~~~~~~~~~~~#>

########################################################################################################################################################################################################
$RunningActivityLog                      = New-Object System.Windows.Forms.RichTextBox
$RunningActivityLog.Location             = New-Object System.Drawing.Point(($treeViewWidth + $HORIZONTAL_SPACER), ($BUTTON_HEIGHT * 7 + $VERTICAL_SPACER))
$RunningActivityLog.Size                 = New-Object System.Drawing.Size(($columnWidth2+$columnWidth3), ($BUTTON_HEIGHT*10))
$RunningActivityLog.ReadOnly             = $true
$RunningActivityLog.AutoScrollOffset     = 100
$RunningActivityLog.Text                 = ""

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($RunningActivityLog)<#~~~~~~~~~~~~~~~~~~~~#>

########################################################################################################################################################################################################
$MoveFilesButton                         = New-Object System.Windows.Forms.Button
$MoveFilesButton.Location                = New-Object System.Drawing.Point(($treeViewWidth + $columnWidth2),0)
$MoveFilesButton.Size                    = New-Object System.Drawing.Size($BUTTON_WIDTH, $BUTTON_HEIGHT)
$MoveFilesButton.Text                    = "Move Files -->"
$MoveFilesButton.Enabled                 = $false

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($MoveFilesButton)<#~~~~~~~~~~~~~~~~~~~~#>

########################################################################################################################################################################################################
$currentActivity                         = New-Object System.Windows.Forms.Label
$currentActivity.Location                = New-Object System.Drawing.Point(($treeViewWidth + $HORIZONTAL_SPACER + $columnWidth2), $BUTTON_HEIGHT)
$currentActivity.Size                    = New-Object System.Drawing.Size(($columnWidth3), $BUTTON_HEIGHT)
$currentActivity.Text                    = "...."

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($currentActivity)<#~~~~~~~~~~~~~~~~~~~~#>

########################################################################################################################################################################################################
$sourceFromLabel                         = New-Object System.Windows.Forms.Label
$sourceFromLabel.Location                = New-Object System.Drawing.Point(($treeViewWidth + $HORIZONTAL_SPACER + $columnWidth2), ($BUTTON_HEIGHT * 2 + $VERTICAL_SPACER))
$sourceFromLabel.Size                    = New-Object System.Drawing.Size($columnWidth3b, $BUTTON_HEIGHT)
$sourceFromLabel.Text                    = "move from"
$sourceFromLabel.BorderStyle             = 'Fixed3D'
$sourceFromLabel.BackColor               = $Yellow
$sourceFromLabel.Font                    = $ItalicFont
$sourceFromLabel.TextAlign               = [System.Drawing.ContentAlignment]::MiddleRight

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($sourceFromLabel)<#~~~~~~~~~~~~~~~~~~~~#>

########################################################################################################################################################################################################
$targetToLabel                           = New-Object System.Windows.Forms.Label
$targetToLabel.Location                  = New-Object System.Drawing.Point(($treeViewWidth + $HORIZONTAL_SPACER + $columnWidth2), ($BUTTON_HEIGHT * 3 + $VERTICAL_SPACER))
$targetToLabel.Size                      = New-Object System.Drawing.Size($columnWidth3b, $BUTTON_HEIGHT)
$targetToLabel.Text                      = "move to"
$targetToLabel.BorderStyle               = 'Fixed3D'
$targetToLabel.BackColor                 = $Yellow
$targetToLabel.Font                      = $ItalicFont
$targetToLabel.TextAlign                 = [System.Drawing.ContentAlignment]::MiddleRight

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($targetToLabel)<#~~~~~~~~~~~~~~~~~~~~#>

########################################################################################################################################################################################################
$sourceDirectoryToMoveFrom                 = New-Object System.Windows.Forms.TextBox
$sourceDirectoryToMoveFrom.Location        = New-Object System.Drawing.Point(($treeViewWidth + $HORIZONTAL_SPACER + $columnWidth2 + $HORIZONTAL_SPACER + $columnWidth3b), ($BUTTON_HEIGHT * 2 + $VERTICAL_SPACER))
$sourceDirectoryToMoveFrom.Size            = New-Object System.Drawing.Size($maxObjectWidth3, $BUTTON_HEIGHT)
$sourceDirectoryToMoveFrom.ReadOnly        = $true
$sourceDirectoryToMoveFrom.PlaceholderText = "selected source directory goes here"

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($sourceDirectoryToMoveFrom)<#~~~~~~~~~~~~~~~~~~~~#>

########################################################################################################################################################################################################
$targetDirectoryToMoveTo                 = New-Object System.Windows.Forms.TextBox
$targetDirectoryToMoveTo.Location        = New-Object System.Drawing.Point(($treeViewWidth + $HORIZONTAL_SPACER + $columnWidth2 + $HORIZONTAL_SPACER + $columnWidth3b), ($BUTTON_HEIGHT * 3 + $VERTICAL_SPACER))
$targetDirectoryToMoveTo.Size            = New-Object System.Drawing.Size($maxObjectWidth3, $BUTTON_HEIGHT)
$targetDirectoryToMoveTo.ReadOnly        = $true
$targetDirectoryToMoveTo.PlaceholderText = "selected target directory goes here"

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($targetDirectoryToMoveTo)<#~~~~~~~~~~~~~~~~~~~~#>

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Column 4
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
$maxObjectWidth4                         = 100
$columnWidth4                            = $maxObjectWidth4 + ($HORIZONTAL_SPACER*2)

#######################################################################################################################################################################################################
$sourceDirectorySize                     = New-Object System.Windows.Forms.Label
$sourceDirectorySize.Location            = New-Object System.Drawing.Point(($treeViewWidth + $HORIZONTAL_SPACER + $columnWidth2+ $columnWidth3b+$columnWidth3), ($BUTTON_HEIGHT * 2 + $VERTICAL_SPACER))
$sourceDirectorySize.Size                = New-Object System.Drawing.Size($columnWidth4, $BUTTON_HEIGHT)
$sourceDirectorySize.TextAlign           = [System.Drawing.ContentAlignment]::MiddleLeft

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($sourceDirectorySize)<#~~~~~~~~~~~~~~~~~~~~#>

Function EnableMoveFileButton() {
    if (-not($treeViewOfPublishedDirectories.SelectedNode.Text.StartsWith('_') -or $treeViewOfPublishedDirectories.SelectedNode.Level -eq 0 -or
    [string]::IsNullOrWhiteSpace($selectedmoveReasonComboBox.Text) -or
    $selectedmoveReasonComboBox.Text -notin $selectedmoveReasonComboBox.Items
    )) {
        # TODO: code this magic.
        if ($selectedmoveReasonComboBox.Text -ne "Seen") {
            $Script:targetBaseDirectory = "K:\Video AllInOne $($selectedmoveReasonComboBox.Text)"
        } else {
            $Script:targetBaseDirectory = "N:\Video AllInOne Seen"
        }
        $targetDirectoryToMoveTo.Text = $Script:targetBaseDirectory

        $targetBaseDirectory_prepped_for_sql = PrepForSql $Script:targetBaseDirectory
        # Verify all target data set
        Invoke-Sql "INSERT INTO search_directories_v(search_directory) VALUES($targetBaseDirectory_prepped_for_sql) ON CONFLICT DO NOTHING"
        return $true
    }
    return $false
}

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($targetDirectoryToMoveTo)<#~~~~~~~~~~~~~~~~~~~~#>

#################################################################################################################################################################################################
# Action taken When the user or bootstrap sets what reason for moving, which then determines the volume and target directory.
#################################################################################################################################################################################################
$selectedmoveReasonComboBox.add_SelectedIndexChanged({
    $moveReason = $this.Text
    if (-not [string]::IsNullOrWhiteSpace($moveReason)) {
    }
    else {
        $targetDirectoryToMoveTo.Text = ""
    }
    $MoveFilesButton.Enabled            = EnableMoveFileButton
})
#################################################################################################################################################################################################
# Action taken When the user selects a node in the tree, we capture the detail for displaying for the move action
#################################################################################################################################################################################################
$treeViewOfPublishedDirectories.add_AfterSelect({
    if ($sequenceControlIgnoreNext_afterSelectTreeview) {
        # happens automatically (not from user) when a tree item is deleted
        # We don't want the data on the screen to point to some new directory while the label says "MOVE COMPLETED"
        # We don't want to flush the label because we still are notifying the user of what just happened.
        Write-Host "Skipping populate columns after deleting an item from tree triggered a fake select"
        $sequenceControlIgnoreNext_afterSelectTreeview = $false
    } else {
        $currentActivity.Text               = ""
        $Script:directory_path              = $this.SelectedNode.Name
        $sourceDirectoryToMoveFrom.Text     = $Script:directory_path
        $Script:parent_directory_path       = $this.TopNode.Name
        try {
            $Script:prev_directory_path     = $this.SelectedNode.PrevNode.Name
        } catch {
            $Script:prev_directory_path     = $null
        }
        try {
            $Script:next_directory_path     = $this.SelectedNode.NextNode.Name
        } catch {
            $Script:next_directory_path     = $null
        }
        $MoveFilesButton.Enabled            = EnableMoveFileButton
    }
})

$selectedmoveReasonComboBox.add_TextChanged({
    $MoveFilesButton.Enabled            = EnableMoveFileButton
})

[DateTime]$LastLogTime = 0

###########################################################################################################################################################################################
Function LogMoveActivityLine($msg, [System.Drawing.Color]$textColor) {
    [DateTime]$logdate = (Get-Date)
    $logtimestr = $logdate.ToString('hh:mm:ss tt')

    if ($null -eq $textColor) {
        $textColor = $Black
    }
    $RunningActivityLog.SelectionStart  = $RunningActivityLog.TextLength
    $RunningActivityLog.SelectionLength = 0
    $RunningActivityLog.SelectionColor  = $textColor
    $RunningActivityLog.SelectionFont   = $BoldFont
    $RunningActivityLog.AppendText("$logtimestr`:$msg$([System.Environment]::NewLine)")
    $RunningActivityLog.ScrollToCaret()
    $RunningActivityLog.Refresh()
}
###########################################################################################################################################################################################
# Action taken when we click the move button
###########################################################################################################################################################################################
$Move_Directory = {
    $form.Cursor                         = [System.Windows.Forms.Cursors]::WaitCursor
    $currentActivity.ForeColor           = $Black
    $currentActivity.Font                = $NormalFont
    $currentActivity.Text                ="moving directory..."
    $currentActivity.Refresh()
    $sourceDirectory                     = $treeViewOfPublishedDirectories.SelectedNode.Name
    $sourceBaseDirectory                 = $Script:sourceBaseDirectory
    $sourceBaseDirectory_prepped_for_sql = PrepForSql $sourceBaseDirectory
    $sourceDirectory_prepped_for_sql     = PrepForSql $sourceDirectory
    $sizeOfSourceDirectory               = 0
    try {
        $sizeOfSourceDirectory           = ((gci –force -LiteralPath $sourceDirectory –Recurse -ErrorAction SilentlyContinue | Where-Object { $_.LinkType -notmatch "HardLink" }| measure Length -sum).sum)
    } catch {}
    $sourceDirectorySize.Text            = HumanizeCount $sizeOfSourceDirectory
    $sourceDirectorySize.Refresh()
    $sourcePartOfPath                    = $treeViewOfPublishedDirectories.SelectedNode.Tag
    $moveReason                          = $selectedmoveReasonComboBox.Text
    $moveReason_prepped_for_sql          = PrepForSql $moveReason
    $whyMove                             = $whyThisMoveReasonText.Text
    $whyMove_prepped_for_sql             = PrepForSql $whyMove
    $targetDirectory                     = "$Script:targetBaseDirectory\$sourcePartOfPath"
    if ($sizeOfSourceDirectory -eq 0) {
        $sizeOfSourceDirectory           = ((gci –force -LiteralPath $targetDirectory –Recurse -ErrorAction SilentlyContinue | Where-Object { $_.LinkType -notmatch "HardLink" }| measure Length -sum).sum)
    }
    $currentActivity.Text                = "Moving Files to $targetDirectory"
    $currentActivity.Refresh()
    $targetBaseDirectory_prepped_for_sql = PrepForSql $targetBaseDirectory
    New-Item -ItemType Directory -Force -Path $targetDirectory
    $targetDirectory                     = (Get-Item $targetDirectory).Parent.FullName
    $targetDirectory_prepped_for_sql     = PrepForSql $targetDirectory
    LogMoveActivityLine "Moving $sourceDirectory to $targetDirectory..." -textColor $StartingColor
    # ERROR: Can't run during single large -MoveItem and even between moves. No update. $activityAnimation.Load("D:\qt_projects\filmcab\simplified\images\animations\running.homer.silly.gif")

    # So much table change, we need to transact it. Else it leaves stuff during partial testing
    # NOTE: move_id is a sequence. rollbacks do not restore used ids. SQL Standard.

    try {
        $Script:ActiveTransaction        = $DatabaseConnection.BeginTransaction([System.Data.IsolationLevel]::ReadCommitted) #PostgreSQL's Read Uncommitted mode behaves like Read Committed

        $source_driveletter              = Left $sourceDirectory
        $sourceVolumeId                  = Get-SqlValue "SELECT volume_id from volumes WHERE drive_letter = '$source_driveletter'"
        $source_search_directory_id      = Get-SqlValue "SELECT search_directory_id FROM search_directories where search_directory = $sourceBaseDirectory_prepped_for_sql"

        $target_driveletter              = Left $targetDirectory
        $targetVolumeId                  = Get-SqlValue "SELECT volume_id from volumes WHERE drive_letter = '$target_driveletter'"
        $target_search_directory_id      = Get-SqlValue "SELECT search_directory_id FROM search_directories where search_directory = $targetBaseDirectory_prepped_for_sql"

        $currentActivity.Text = "(1) Creating a move transaction that keeps details..."
        $currentActivity.Refresh()

        $move_id = Get-SqlValue "
            INSERT INTO
                moves(
                    move_started
                ,   bytes_moved
                ,   from_directory
                ,   from_base_directory
                ,   from_volume_id
                ,   from_search_directory_id
                ,   to_directory
                ,   to_base_directory
                ,   to_volume_id
                ,   to_search_directory_id
                ,   move_reason
                ,   description_why_reason_applies
                )
                VALUES(
                    TRANSACTION_TIMESTAMP()                                       /* Transaction start time above) */
                ,   $sizeOfSourceDirectory                                        /* How much space we're freeing up */
                ,   $sourceDirectory_prepped_for_sql
                ,   $sourceBaseDirectory_prepped_for_sql
                ,   $sourceVolumeId
                ,   $source_search_directory_id
                ,   $targetDirectory_prepped_for_sql
                ,   $targetBaseDirectory_prepped_for_sql
                ,   $targetVolumeId
                ,   $target_search_directory_id
                ,   $moveReason_prepped_for_sql
                ,   $whyMove_prepped_for_sql
                )
                RETURNING move_id"


        $currentActivity.Text = "(2) Marking all sub directories as having been moved..."
        $currentActivity.Refresh()

        Invoke-Sql "
            WITH RECURSIVE nodes AS (
                SELECT *, $targetBaseDirectory_prepped_for_sql || '\' || dev.useful_part_of_directory          AS new_directory
                FROM directories_ext_v dev WHERE directory = $sourceDirectory_prepped_for_sql
            UNION ALL
                SELECT dev.*, $targetBaseDirectory_prepped_for_sql || '\' || dev.useful_part_of_directory      AS new_directory
                FROM directories_ext_v dev JOIN nodes ON dev.parent_directory_hash = nodes.directory_hash
            )
            UPDATE
                directories_v x
            SET
                move_id                 = $move_id
            ,   moved_out               = True
            ,   moved_to_directory_hash = md5_hash_path(y.new_directory)
            ,   moved_to_volume_id      = $targetVolumeId
            FROM
                nodes y
            WHERE
                x.directory_hash = y.directory_hash
        " |Out-Null

        $currentActivity.Text = "(3) Migrate the directory records over, altering them according to the new base directory."
        $currentActivity.Refresh()

        Invoke-Sql "
            WITH RECURSIVE nodes AS (
                SELECT *, $targetBaseDirectory_prepped_for_sql || '\' || dev.useful_part_of_directory          AS new_directory
                FROM directories_ext_v dev WHERE directory = $sourceDirectory_prepped_for_sql
            UNION ALL
                SELECT dev.*, $targetBaseDirectory_prepped_for_sql || '\' || dev.useful_part_of_directory      AS new_directory
                FROM directories_ext_v dev JOIN nodes ON dev.parent_directory_hash = nodes.directory_hash
            )
            , recalc_folders AS (
                SELECT
                    *
                ,   reverse((string_to_array(reverse(new_directory), '\'))[1])                                 AS new_folder
                ,   reverse((string_to_array(reverse(new_directory), '\'))[2])                                 AS new_parent_folder
                ,   reverse((string_to_array(reverse(new_directory), '\'))[3])                                 AS new_grandparent_folder
                ,   Left(directory, length(directory)-(length(folder)+1))                                      AS new_parent_directory
                ,   md5_hash_path(new_directory)                                                               AS new_directory_hash
                FROM
                    nodes
            )
            INSERT INTO
                directories_v(
                    directory_hash
                ,   directory
                ,   parent_directory_hash
                ,   directory_date
                ,   volume_id
                ,   search_directory_id
                ,   folder
                ,   parent_folder
                ,   grandparent_folder
                ,   directory_deleted
                ,   move_id
                ,   moved_in
                ,   moved_from_directory_hash
                ,   moved_from_volume_id
                ,   moved_from_directory_id
                )
                SELECT
                    new_directory_hash                     AS directory_hash
                ,   new_directory                          AS directory
                ,   md5_hash_path(new_parent_directory)    AS parent_directory_hash
                ,   directory_date                         AS directory_date           /* Should be same as original? Or when it copied did it change? `"Move: You are physically moving the original file to some place else, just like keeping the flower vase in next room, which means, you have not created anything new- but just moved it to another place. So only access stamps needs change, created and modified remains same. `"*/
                ,   $targetVolumeId                        AS volume_id
                ,   $target_search_directory_id            AS search_directory_id
                ,   new_folder                             AS folder
                ,   new_parent_folder                      AS parent_folder
                ,   new_grandparent_folder                 AS grandparent_folder
                ,   directory_deleted                      AS directory_deleted
                ,   $move_id                               AS move_id
                ,   True                                   AS moved_in
                ,   directory_hash                         AS moved_from_directory_hash
                ,   $sourceVolumeId                        AS moved_from_volume_id
                ,   directory_id                           AS moved_from_directory_id
                FROM
                    recalc_folders
        "

        $currentActivity.Text = "(4) Marking all the moved files as moved and to where."
        $currentActivity.Refresh()

        Invoke-Sql "
            WITH RECURSIVE nodes AS (
                SELECT *, $targetBaseDirectory_prepped_for_sql || '\' || dev.useful_part_of_directory          AS new_directory
                FROM directories_ext_v dev WHERE directory = $sourceDirectory_prepped_for_sql
            UNION ALL
                SELECT dev.*, $targetBaseDirectory_prepped_for_sql || '\' || dev.useful_part_of_directory      AS new_directory
                FROM directories_ext_v dev JOIN nodes ON dev.parent_directory_hash = nodes.directory_hash
            ),
            all_files AS (
                SELECT f.*, nodes.new_directory FROM files_ext_v f JOIN nodes USING(directory_hash)
            )
            UPDATE
                files_v
            SET
                move_id                 = $move_id
            ,   moved_out               = $true
            ,   moved_to_directory_hash = md5_hash_path(y.new_directory)
            FROM
                all_files y
            WHERE
                files_v.file_id = y.file_id
        "

        $currentActivity.Text = "(5) Copying the file records over, altering paths and hashes as needed."
        $currentActivity.Refresh()

        Invoke-Sql "
            WITH RECURSIVE nodes AS (
                SELECT *, $targetBaseDirectory_prepped_for_sql || '\' || dev.useful_part_of_directory          AS new_directory
                FROM directories_ext_v dev WHERE directory = $sourceDirectory_prepped_for_sql
            UNION ALL
                SELECT dev.*, $targetBaseDirectory_prepped_for_sql || '\' || dev.useful_part_of_directory      AS new_directory
                FROM directories_ext_v dev JOIN nodes ON dev.parent_directory_hash = nodes.directory_hash
            ),
            all_files AS (
                SELECT f.*, nodes.new_directory FROM files_ext_v f JOIN nodes USING(directory_hash)
            )
            INSERT INTO
                files_v(
                    file_hash
                ,   directory_hash
                ,   file_name_no_ext
                ,   final_extension
                ,   file_size
                ,   file_date
                ,   file_deleted
                ,   file_is_symbolic_link
                ,   file_is_hard_link
                ,   file_is_broken_link
                ,   linked_path
                ,   file_ntfs_id
                ,   scan_file_for_ntfs_id
                ,   move_id
                ,   moved_in
                ,   moved_from_file_id
                )
                SELECT
                    file_hash
                ,   md5_hash_path(new_directory)   AS directory_hash
                ,   file_name_no_ext
                ,   final_extension
                ,   file_size
                ,   file_date
                ,   file_deleted
                ,   file_is_symbolic_link
                ,   file_is_hard_link
                ,   file_is_broken_link
                ,   file_linked_path                                                      /* No way this is valid. Probably should update */
                ,   NULL                           AS file_ntfs_id
                ,   $true                          AS scan_file_for_ntfs_id
                ,   $move_id                       AS move_id
                ,   True                           AS moved_in
                ,   file_id                        AS moved_from_file_id
                FROM
                    all_files
        "

        $currentActivity.Text = "(6) Starting Move-Item..."
        $currentActivity.Refresh()

        ###############################################################################################################################################################################################################################################################
        ###############################################################################################################################################################################################################################################################
        $movedFilesYet = $false
        try {

            #$arguments = @("$sourceDirectory","$targetDirectory") #(Pass scriptblock up update gui progress)
            # When job finishes, need to lock move button
            #$job = Start-Job -ScriptBlock $ScriptBlockAsyncMoveFilesAndDirectories -ArgumentList $arguments
            #$jobEvent = Register-ObjectEvent $job StateChanged -Action {
            #    Write-Host ('Job #{0} ({1}) complete.' -f $sender.Id, $sender.Name)
            #    $jobEvent | Unregister-Event
                #Start-BitsTransfer -Source $Source -Destination $Destination -Description "Backup" -DisplayName "Backup"
                # When job finishes, need to unlock move button
            Move-Item -LiteralPath $sourceDirectory -Destination $targetDirectory -Force
            #}
        } catch {}
        $movedFilesYet = $true

        $currentActivity.Text = "(6) Move-Item Complete."
        $currentActivity.Refresh()
        ###############################################################################################################################################################################################################################################################
        ###############################################################################################################################################################################################################################################################

        $currentActivity.Text = "(7) Updating moves # $move_id with move_ended timestamp."
        $currentActivity.Refresh()

        Invoke-Sql "
            UPDATE
                moves
            SET
                move_ended = CLOCK_TIMESTAMP() /* Time on wall clock, so we can time the copy file commands */
            WHERE
                move_id = $move_id" -OneAndOnlyOne|Out-Null

        # Complete. Silently remove item from tree.

        $sequenceControlIgnoreNext_afterSelectTreeview = $true
        $treeViewOfPublishedDirectories.SelectedNode.Remove()
        [Console]::Beep(500,300);[Console]::Beep(500,300)

    }
    catch {
        # Warning: Any crashes here will auto-commit!!!!!!
        if ((Test-Path variable:ActiveTransaction) -and $null -ne $ActiveTransaction -and $null -ne $ActiveTransaction.Connection) {
            $Script:ActiveTransaction.Rollback()
            $Script:ActiveTransaction.Dispose()
            $currentActivity.Text                = "Move CANCELLED"
            $currentActivity.ForeColor           = $Red
            $currentActivity.Font                = $BoldFont
            LogMoveActivityLine "Failed to move $sourceDirectory to $targetDirectory" -textColor $FailColor
        }
    }
    finally {
        if ((Test-Path variable:ActiveTransaction) -and $null -ne $ActiveTransaction -and $null -ne $ActiveTransaction.Connection) {
            $Script:ActiveTransaction.Commit()
            $Script:ActiveTransaction.Dispose()
            $Script:ActiveTransaction            = $null

            # Following will only be set IF it didn't have a catch, which rolled back the data, and so never gets past above if.

            $currentActivity.Text                = "MOVE COMPLETED SUCCESSFULLY"
            $currentActivity.ForeColor           = $Green
            $currentActivity.Font                = $BoldFont
            LogMoveActivityLine "Successfully moved $sourceDirectory to $targetDirectory" -textColor $SuccessColor
        }
    }
    $form.Cursor                                 = [System.Windows.Forms.Cursors]::Default
    $selectedmoveReasonComboBox.Text             = ""
    $whyThisMoveReasonText.Text                  = ""
    $sourceDirectorySize.Text                    = ""
}

$MoveFilesButton.add_click($Move_Directory)

#################################################################################################################################################################################################
# Load all published directories into nodes and add them to tree view
#################################################################################################################################################################################################

WhileReadSql "
    SELECT
        search_directory_id
    ,   search_directory
    FROM
        search_directories_ext_v
    WHERE
        tag = 'published'
    " -prereadfirstrow |Out-Null

$searchDirectoryId          = $search_directory_id
$Script:sourceBaseDirectory = $search_directory

$treeViewOfPublishedDirectories.Nodes.Clear()
$treeViewOfPublishedDirectories.BeginUpdate()
$parentDirectories = New-Object 'system.collections.generic.dictionary[String, System.Windows.Forms.TreeNode]'

$rootNode = New-Object System.Windows.Forms.TreeNode
$parentDirectories.Add($search_directory, $rootNode)
$rootNode.Text = "$search_directory"
$treeViewOfPublishedDirectories.Nodes.Add($rootNode)|Out-Null

$AddFoldersToSeenOffline = WhileReadSql "
    SELECT
        directory
    ,   useful_part_of_directory
    ,   parent_directory
    ,   folder
    FROM
        directories_ext_v dev
    WHERE
        search_directory_id = $searchDirectoryId
    AND
        directory_depth >= 1
    AND
        move_id IS NULL /* Not already moven */
    /*********************************************************************************************************************************
    AND (
            directory = 'O:\Video AllInOne\_Mystery\Annika (2021-)'
        OR
            directory = 'O:\Video AllInOne\_Mystery'
        OR
            directory = 'O:\Video AllInOne'
        )
     ********************************************************************************************************************************/
    AND directory like 'O:\Video AllInOne\`$_Mystery%' ESCAPE '`$' /* Reduce workspace temporarily */
    ORDER BY
        directory_depth
    ,   directory
    "
# Load all the subfolders into the tree view

while ($AddFoldersToSeenOffline.Read()) {
    $parentBranch = $parentDirectories[$parent_directory]
    $branchNode   = New-Object System.Windows.Forms.TreeNode
    $parentDirectories.Add($directory, $branchNode)
    $branchNode.Text = "$folder"
    $branchNode.Name = "$directory"
    $branchNode.Tag  = "$useful_part_of_directory"
    $parentBranch.Nodes.Add($branchNode)|Out-Null
}

$rootNode.Expand()

$treeViewOfPublishedDirectories.EndUpdate()

# Set our place in the tree where we were last, or very near there.

if ((Test-Path variable:Script:directory_path) -and -not [string]::IsNullOrWhiteSpace($Script:directory_path)) {
[array]$treeNodesForThatDirectory = $treeViewOfPublishedDirectories.Nodes.Find($Script:directory_path, $true)
# if not found, we need to have saved the higher folder, and then the next alphabetic subfolder.
if ($treeNodesForThatDirectory.Count -ge 1) {
    $treeViewOfPublishedDirectories.SelectedNode = ($treeNodesForThatDirectory[0])
    $treeViewOfPublishedDirectories.Focus()
    # Get nodes before and after for when this node is removed.
}
} elseif ((Test-Path variable:Script:prev_directory_path) -and -not [string]::IsNullOrWhiteSpace($Script:prev_directory_path)) {
[array]$treeNodesForThatDirectory = $treeViewOfPublishedDirectories.Nodes.Find($Script:prev_directory_path, $true)
# if not found, we need to have saved the higher folder, and then the next alphabetic subfolder.
if ($treeNodesForThatDirectory.Count -ge 1) {
    $treeViewOfPublishedDirectories.SelectedNode = ($treeNodesForThatDirectory[0])
    # Get nodes before and after for when this node is removed.
}
} elseif ((Test-Path variable:Script:next_directory_path) -and -not [string]::IsNullOrWhiteSpace($Script:next_directory_path)) {
[array]$treeNodesForThatDirectory = $treeViewOfPublishedDirectories.Nodes.Find($Script:next_directory_path, $true)
# if not found, we need to have saved the higher folder, and then the next alphabetic subfolder.
if ($treeNodesForThatDirectory.Count -ge 1) {
    $treeViewOfPublishedDirectories.SelectedNode = ($treeNodesForThatDirectory[0])
    # Get nodes before and after for when this node is removed.
}
}

$selectedmoveReasonComboBox.SelectedItem = ""

$form.Topmost = $True

$form.BringToFront() # Required to get it on top, not just "TopMost"
$treeViewOfPublishedDirectories.Focus()
$form.TabIndex = 0
$form.ShowDialog()

}
catch {
Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}
finally {
Write-AllPlaces "Finally"
. .\_dot_include_standard_footer.ps1
}

<#

https://www.systanddeploy.com/2019/11/powershell-and-wpf-how-to-use-animated.html

https://github.com/XamlAnimatedGif/WpfAnimatedGif
A simple library to display animated GIF images in WPF, usable in XAML or in code.
var image = new BitmapImage();
image.BeginInit();
image.UriSource = new Uri(fileName);
image.EndInit();
ImageBehavior.SetAnimatedSource(img, image);
https://www.nuget.org/packages/WpfAnimatedGif

#>

<#


https://stackoverflow.com/questions/165735/how-do-you-show-animated-gifs-on-a-windows-form-c
  private void button1_Click(object sender, EventArgs e)
  {
   ThreadStart myThreadStart = new ThreadStart(Show);
   Thread myThread = new Thread(myThreadStart);
   myThread.Start();
  }

Show activity on this post.

Note that in Windows, you traditionally don't use animated Gifs, but little AVI animations: there is a Windows native control just to display them. There are even tools to convert animated Gifs to AVI (and vice-versa).

https://learn.microsoft.com/en-us/windows/win32/controls/animation-control-overview


https://learn.microsoft.com/en-us/dotnet/api/system.windows.media.animation.animatable?view=windowsdesktop-8.0

Animatable Class
System.Windows.Media.Animation
public abstract class Animatable : System.Windows.Freezable, System.Windows.Media.Animation.IAnimatable

CAnimateCtrl m_avi;this is placed in your .h file.
https://www.codeproject.com/Articles/159/CAnimateCtrl-Example

Function ShowProgressGifDelegate {
    $animatedGif.Visible = $true
}
Function ShowAnimation()
{
 $this.Invoke(ShowProgressGifDelegate);
 #//your long running process
 #System.Threading.Thread.Sleep(5000);
 #this.Invoke(this.HideProgressGifDelegate);
}
#>
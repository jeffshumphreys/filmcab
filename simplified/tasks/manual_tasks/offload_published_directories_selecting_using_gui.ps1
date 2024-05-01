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

. .\simplified\tasks\manual_tasks\offload_published_directories_selecting_using_gui.formdef.ps1

Function EnableMoveFileButton() {
    if (
        -not($treeViewOfPublishedDirectories.SelectedNode.Text.StartsWith('_') -or $treeViewOfPublishedDirectories.SelectedNode.Level -eq 0 -or
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
        Invoke-Sql "INSERT INTO search_directories_v(search_directory) VALUES($targetBaseDirectory_prepped_for_sql) ON CONFLICT DO NOTHING"|Out-Null
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
    $MoveFilesButton.Refresh()

})

#################################################################################################################################################################################################
# Action taken When the user double-clicks on a node.
#################################################################################################################################################################################################
$treeViewOfPublishedDirectories.add_NodeMouseDoubleClick({
    # if a directory, flush any below, and repop with files in directory, coloring links or italicizing
    # SelectedNode.Name = full path
    # NOTE: First expands.

    $fileOrFolderPath = $this.SelectedNode.Name
    $fileOrFolderPath_prepped_for_sql = PrepForSql $fileOrFolderPath
    if (Test-Path -LiteralPath $fileOrFolderPath -PathType Container) {
        # Fetch files

        $filereader = WhileReadSql "
            SELECT
                file_name_with_ext
            ,   useful_part_of_directory
            ,   file_path
            ,   CASE WHEN file_is_symbolic_link OR file_is_hard_link THEN TRUE ELSE FALSE END AS is_link
            ,   CASE WHEN moved_out OR file_deleted THEN TRUE ELSE FALSE END AS nothing_here
            FROM
                files_ext_v
            WHERE
                directory = $fileOrFolderPath_prepped_for_sql
            AND
                NOT file_deleted
            "

        while ($filereader.Read()) {
            $branchNode           = New-Object System.Windows.Forms.TreeNode
            $branchNode.Name      = $file_path
            $branchNode.Text      = $file_name_with_ext
            $branchNode.Tag       = $useful_part_of_directory
            if ($is_link) {
                $branchNode.ForeColor = '#bdb9b9' # even lighter
                $branchNode.NodeFont.Italic = $true
            } else {
                $branchNode.ForeColor = '#969494' # grey, light to distinguish from folders
            }
            $this.SelectedNode.Nodes.Add($branchNode)|Out-Null
        }

        $this.SelectedNode.Expand()
    }
    #$statusBarMessage.Text = "treeViewOfPublishedDirectories.add_NodeMouseDoubleClick"
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
    $Script:sourcePathToDirectoryOrFile  = $treeViewOfPublishedDirectories.SelectedNode.Name
    $Script:sourceDirectory              = $Script:sourcePathToDirectoryOrFile
    $isMovingADirectory                  = (Test-Path -LiteralPath $Script:sourcePathToDirectoryOrFile -PathType Container)
    if (-not $isMovingADirectory) {
        $Script:sourceDirectory = (Split-Path $Script:sourcePathToDirectoryOrFile -Parent)
    }
    $currentActivity.ForeColor           = $Black
    $currentActivity.Font                = $NormalFont

    if ($isMovingADirectory) {
        $currentActivity.Text                ="moving directory..."
    } else {
        $currentActivity.Text                ="moving file..."
    }

    $currentActivity.Refresh()
    $sourceBaseDirectory_prepped_for_sql = PrepForSql $Script:sourceBaseDirectory
    $sourceDirectory_prepped_for_sql     = PrepForSql $Script:sourcePathToDirectoryOrFile
    $sizeOfSourceDirectory               = 0
    try {
        $sizeOfSourceDirectory           = ((Get-ChildItem –Force -LiteralPath $Script:sourcePathToDirectoryOrFile –Recurse -ErrorAction SilentlyContinue | Where-Object { $_.LinkType -notmatch "HardLink" }| measure Length -sum).sum)
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
    LogMoveActivityLine "Moving $sourcePathToDirectoryOrFile to $targetDirectory..." -textColor $StartingColor
    # ERROR: Can't run during single large -MoveItem and even between moves. No update. $activityAnimation.Load("D:\qt_projects\filmcab\simplified\images\animations\running.homer.silly.gif")

    # So much table change, we need to transact it. Else it leaves stuff during partial testing
    # NOTE: move_id is a sequence. rollbacks do not restore used ids. SQL Standard.

    try {
        $Script:ActiveTransaction        = $DatabaseConnection.BeginTransaction([System.Data.IsolationLevel]::ReadCommitted) #PostgreSQL's Read Uncommitted mode behaves like Read Committed

        $source_driveletter              = Left $sourcePathToDirectoryOrFile
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
        "|Out-Null

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
        "|Out-Null

        $currentActivity.Text = "(6) Starting Move-Item..."
        $currentActivity.Refresh()|Out-Null

        ###############################################################################################################################################################################################################################################################
        ###############################################################################################################################################################################################################################################################
        $movedFilesYet = $false
        try {

            #$arguments = @("$sourcePathToDirectoryOrFile","$targetDirectory") #(Pass scriptblock up update gui progress)
            # When job finishes, need to lock move button
            #$job = Start-Job -ScriptBlock $ScriptBlockAsyncMoveFilesAndDirectories -ArgumentList $arguments
            #$jobEvent = Register-ObjectEvent $job StateChanged -Action {
            #    Write-Host ('Job #{0} ({1}) complete.' -f $sender.Id, $sender.Name)
            #    $jobEvent | Unregister-Event
                #Start-BitsTransfer -Source $Source -Destination $Destination -Description "Backup" -DisplayName "Backup"
                # When job finishes, need to unlock move button
            Move-Item -LiteralPath $sourcePathToDirectoryOrFile -Destination $targetDirectory -Force
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
            LogMoveActivityLine "Failed to move $sourcePathToDirectoryOrFile to $targetDirectory" -textColor $FailColor
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
            LogMoveActivityLine "Successfully moved $sourcePathToDirectoryOrFile to $targetDirectory" -textColor $SuccessColor
        }
    }
    $form.Cursor                                 = [System.Windows.Forms.Cursors]::Default
    $selectedmoveReasonComboBox.Text             = ""
    $whyThisMoveReasonText.Text                  = ""
    $sourceDirectorySize.Text                    = ""
}

$MoveFilesButton.add_click($Move_Directory)|Out-Null

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
    $parentBranch    = $parentDirectories[$parent_directory]
    $branchNode      = New-Object System.Windows.Forms.TreeNode
    $branchNode.Text = "$folder"
    $branchNode.Name = "$directory"
    $branchNode.Tag  = "$useful_part_of_directory"
    $parentDirectories.Add($directory, $branchNode)|Out-Null
    $parentBranch.Nodes.Add($branchNode)|Out-Null
}

$rootNode.Expand()|Out-Null

$treeViewOfPublishedDirectories.EndUpdate()|Out-Null

###################################################################################################################################################################################################################################################################
# Set our place in the tree where we were last, or very near there. Labor-reducing.
###################################################################################################################################################################################################################################################################

if ((Test-Path variable:Script:directory_path) -and -not [string]::IsNullOrWhiteSpace($Script:directory_path)) {
    if (Test-Path $Script:directory_path -PathType Leaf) {
        $Script:file_path = $Script:directory_path
        $Script:directory_path = (Split-Path $Script:directory_path -Parent)
    }
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

$form.BringToFront()|Out-Null # Required to get it on top, not just "TopMost"
$treeViewOfPublishedDirectories.Focus()|Out-Null
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

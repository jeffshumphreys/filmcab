<#
#   FilmCab manual on-demand  run process: Selectively move published videos that for some reason don't need to be in directory.
#   Purposes:
            Published drive (spindle) is filling up.
            Unfun to wade through a folder of stuff in alphabetical order and I watched it in alphabetic order, and I tire and stop looking, and many of the later movies don't get looked at.
            Annoying to see something that's dead, like "Beforeigners" which is dead and will never have a conclusion just sitting there every time I go in the Sci Fi folder.

    Warning: Symbolic file links do not present in MX Player on FireTV.  So the option to leave a link for files will not work without more work.

    Missing Features:
            Doesn't show progress of file movement.
            Doesn't show file sizes before you click "Move Files"
            Doesn't show total space freed.
            No way to queue a set of folders/files to move.

#    Called from VS Code (F5)
#    Status: Working
#    ###### Tue Mar 5 16:23:46 MST 2024
#    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
#>

try {
. .\_dot_include_standard_header.ps1

. .\_dot_include_gui_tools.ps1

#Import-Module BitsTransfer

. .\simplified\tasks\manual_tasks\offload_published_directories_selecting_using_gui.formdef.ps1

Function EnableMoveFileButton() {
    if ($Script:ActivelyMovingFiles) {return $false}
    if (
        # Always require a reason selected
        -not([string]::IsNullOrWhiteSpace($selectedmoveReasonComboBox.Text) <# -or $selectedmoveReasonComboBox.Text -notin $selectedmoveReasonComboBox.Items #>) -and
        ( -not
            # If we selected a genre folder like "_Mystery", block the move.
            ($null -ne $treeViewOfPublishedDirectories.selectedNode -and ($treeViewOfPublishedDirectories.SelectedNode.Text.StartsWith('_') -or $treeViewOfPublishedDirectories.SelectedNode.Level -eq 0)) -or
            # Are we on a root or genre folder? We don't want to try and move those
                    # But if I checked some items, even in "_Mystery" for instance, we want to enable moving those
            ($Script:checkedNodes.Count -gt 0)
        )
    )
        {
        # TODO: code this magic.
        if ($selectedmoveReasonComboBox.Text -ne "Seen") {
            $Script:targetBaseDirectory = "K:\Video AllInOne $($selectedmoveReasonComboBox.Text)"
        } else {
            $Script:targetBaseDirectory = "N:\Video AllInOne Seen"
        }

        $driveLetter = Left $Script:targetBaseDirectory 1

        $targetDirectoryToMoveTo.Text = $Script:targetBaseDirectory

        $targetVolumeId = Get-SqlValue "SELECT MAX(volume_id) FROM volumes WHERE drive_letter = '$driveLetter'"
        $targetBaseDirectory_prepped_for_sql = PrepForSql $Script:targetBaseDirectory
        # Verify all target data set
        Invoke-Sql "INSERT INTO search_directories_v(search_directory, volume_id) VALUES($targetBaseDirectory_prepped_for_sql, $targetVolumeId) ON CONFLICT DO NOTHING"|Out-Null
        return $true
    }
    return $false
}

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($targetDirectoryToMoveTo)<#~~~~~~~~~~~~~~~~~~~~#>

#################################################################################################################################################################################################
# Action taken When the user or bootstrap sets what reason for moving, which then determines the volume and target directory.
#################################################################################################################################################################################################
$treeFilterToDirectoryComboBox.add_SelectedIndexChanged({
    $filterForMovies = $this.Text
    $prevFilterForMovies = ""
    if (-not [string]::IsNullOrWhiteSpace($filterForMovies)) {
        if ((Test-Path variable:Script:directory_view_filter) -and -not [string]::IsNullOrWhiteSpace($Script:directory_view_filter)) {
            $prevFilterForMovies = $Script:directory_view_filter
        }
        if ($filterForMovies -ne $prevFilterForMovies -or $treeViewOfPublishedDirectories.Nodes.Count -eq 0) {
            $Script:directory_view_filter = $filterForMovies
            LoadSubsetOfDirectoriesIntoTree($filterForMovies)
        }
    }
})

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
# Action taken When the user double-clicks on a node. Or presses Enter.
#################################################################################################################################################################################################
$ExpandDirectoryNodeListOfFiles = {
    # if a directory, flush any below, and repop with files in directory, coloring links or italicizing
    # SelectedNode.Name = full path
    # NOTE: First expands.

    $fileOrFolderPath = $this.SelectedNode.Name
    $fileOrFolderPath_prepped_for_sql = PrepForSql $fileOrFolderPath
    if (Test-Path -LiteralPath $fileOrFolderPath -PathType Container) {
        # Fetch files

        $filereader = WhileReadSql "
            SELECT
                file_name_with_ext                                                            AS file_name_with_ext
            ,   useful_part_of_directory                                                      AS useful_part_of_directory
            ,   file_path                                                                     AS file_path
            ,   CASE WHEN file_is_symbolic_link OR file_is_hard_link THEN TRUE ELSE FALSE END AS is_link
            ,   CASE WHEN file_moved_out OR file_deleted THEN TRUE ELSE FALSE END             AS nothing_here
            FROM
                files_ext_v
            WHERE
                directory = $fileOrFolderPath_prepped_for_sql
            AND
                NOT file_deleted
            AND
                NOT file_moved_out
            ORDER BY
                1
            "

        while ($filereader.Read()) {
            $branchNode           = New-Object System.Windows.Forms.TreeNode
            $branchNode.Name      = $Script:file_path # Since we're in an expression block called from a separate thread (WinForms), queries won't create any variables in this scope, so reference by Script.
            $branchNode.Text      = $Script:file_name_with_ext
            $branchNode.Tag       = $Script:useful_part_of_directory

            if ($Script:is_link) {
                $branchNode.ForeColor = '#bdb9b9' # even lighter
                $branchNode.NodeFont  = $ItalicFont8
            } else {
                $branchNode.ForeColor = '#969494' # grey, light to distinguish from folders
            }
            $this.SelectedNode.Nodes.Add($branchNode)|Out-Null
        }

        $this.SelectedNode.Expand()
    }
    #$statusBarMessage.Text = "treeViewOfPublishedDirectories.add_NodeMouseDoubleClick"
    $MoveFilesButton.Enabled            = EnableMoveFileButton
    ForceGUIObjectToRefresh $MoveFilesButton
}

$enterkey = [System.Windows.Input.Key]::Enter

$treeViewOfPublishedDirectories.add_KeyPress( {
    $isEnterKeyPressed = [System.Windows.Input.Keyboard]::IsKeyDown($enterkey)
    if ($isEnterKeyPressed) {
        & $ExpandDirectoryNodeListOfFiles
    }
})

$treeViewOfPublishedDirectories.add_NodeMouseDoubleClick($ExpandDirectoryNodeListOfFiles)

$Script:checkedNodes          = [System.Collections.ArrayList]::new()
$Script:checkedDirectoryNodes = [System.Collections.ArrayList]::new()
$Script:checkedFileNodes      = [System.Collections.ArrayList]::new()

#################################################################################################################################################################################################
# Action taken When the user checks a box on a file or directory.
#################################################################################################################################################################################################
$treeViewOfPublishedDirectories.add_AfterCheck({
    param(
        [System.Windows.Forms.TreeView] $v,
        [System.Windows.Forms.TreeViewEventArgs] $value
    )
    $checkedNode     = $value.Node
    $checkedNodePath = $value.Node.Name
    $isDirectory     = (Test-Path -LiteralPath $checkedNodePath -PathType Container)

    $treeViewOfPublishedDirectories.SelectedNode = $null # Unfortunately, the selectednode cannot be null, so it just takes the node of the parent, which is NOT something we want to move
    # TODO: Set a flag that says "There are no active selections; ignore selected node!"

    if ($checkedNode.Checked) {
        $Script:checkedNodes.Add($checkedNode)
        if ($isDirectory) {
            $Script:checkedDirectoryNodes.Add($checkedNode)
        } else {
            $Script:checkedFileNodes.Add($checkedNode)
        }
    } else {
        $Script:checkedNodes.Remove($checkedNode)
        if ($isDirectory) {
            $Script:checkedDirectoryNodes.Remove($checkedNode)
        } else {
            $Script:checkedFileNodes.Remove($checkedNode)
        }
    }
    $MoveFilesButton.Enabled            = EnableMoveFileButton
    ForceGUIObjectToRefresh $MoveFilesButton
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
    ForceGUIObjectToRefresh $RunningActivityLog
}

$Script:ActivelyMovingFiles = $false # Prevent re-enabling of Move button during move loop

###########################################################################################################################################################################################
# Action taken when we click the move button
###########################################################################################################################################################################################
$Move_DirectoryOrFiles = {
    $Script:ActivelyMovingFiles      = $true
            $form.Cursor             = [System.Windows.Forms.Cursors]::WaitCursor
            $currentActivity.Text    = ""; $currentActivity.Refresh()
            $loopThroughNodes        = [System.Collections.ArrayList]::new()
            $MoveFilesButton.Enabled = $false
    ForceGUIObjectToRefresh $MoveFilesButton

    if ($Script:checkedNodes.Count -gt 0) {
        $loopThroughNodes.AddRange($Script:checkedNodes)
    }
    else {
        if (-not $loopThroughNodes -contains $treeViewOfPublishedDirectories.SelectedNode) {
            $loopThroughNodes.Add($treeViewOfPublishedDirectories.SelectedNode)
        }
    }

    $MovingMultipleFiles = $pretest_assuming_false
    if ($Script:checkedNodes.Count -gt 1) {
        $MovingMultipleFiles = $true
    }

    foreach($movingNode in $loopThroughNodes) {
        $form.Cursor             = [System.Windows.Forms.Cursors]::WaitCursor
        $MoveFilesButton.Enabled = $false
        ForceGUIObjectToRefresh $MoveFilesButton
        $treeViewOfPublishedDirectories.SelectedNode = $movingNode
        # Avoid accidentally trying to move the root or any genre folders "_"
        # BUG: If we selected something randomly, then checked off a bunch, we should ignore the random right?
        if ($movingNode.Text.StartsWith('_') -or $movingNode.Level -eq 0) {
            continue
        }

        $Script:sourcePathToDirectoryOrFile     = $treeViewOfPublishedDirectories.SelectedNode.Name
                $sourceDirectoryToMoveFrom.Text = $Script:sourcePathToDirectoryOrFile
        $Script:sourceDirectory                 = $Script:sourcePathToDirectoryOrFile
                $isMovingADirectory             = (Test-Path -LiteralPath $Script:sourcePathToDirectoryOrFile -PathType Container)
        if (-not $isMovingADirectory) {
            $Script:sourceDirectory = (Split-Path $Script:sourcePathToDirectoryOrFile -Parent)
        }

        $currentActivity.ForeColor           = $Black
        $currentActivity.Font                = $NormalFont

        if ($isMovingADirectory) {
            $currentActivity.Text            ="moving selected directory..."
        } elseif ($MovingMultipleFiles) {
            $currentActivity.Text            ="moving checked files..."
        } else {
            $currentActivity.Text            ="moving selected file..."
        }

        ForceGUIObjectToRefresh $currentActivity
        $sourceBaseDirectory_prepped_for_sql   = PrepForSql $Script:sourceBaseDirectory
        $sourceDirectoryOrFile_prepped_for_sql = PrepForSql $Script:sourcePathToDirectoryOrFile
        $sizeOfSourceDirectoryOrFile           = 0
        try { # In case folder missing? then we'll get the target.
            $sizeOfSourceDirectoryOrFile     = ((Get-ChildItem –Force -LiteralPath $Script:sourcePathToDirectoryOrFile –Recurse -ErrorAction SilentlyContinue | measure Length -sum).sum)
        } catch {}
        $sourceDirectorySize.Text            = HumanizeCount $sizeOfSourceDirectoryOrFile
        $sourceDirectorySize.Refresh()
        $sourcePartOfPath                    = $treeViewOfPublishedDirectories.SelectedNode.Tag
        $moveReason                          = $selectedmoveReasonComboBox.Text
        $moveReason_prepped_for_sql          = PrepForSql $moveReason
        $whyMove                             = $whyThisMoveReasonText.Text
        $whyMove_prepped_for_sql             = PrepForSql $whyMove
        $noteOnMove                          = $MoveComments.Text
        $noteOnMove_prepped_for_sql          = PrepForSql $noteOnMove
        $targetDirectoryOrFile               = "$Script:targetBaseDirectory\$sourcePartOfPath"
        $fullTargetDirectoryOrFile           = $targetDirectoryOrFile

        if ($sizeOfSourceDirectoryOrFile -eq 0) {
            $sizeOfSourceDirectoryOrFile     = ((gci –force -LiteralPath $targetDirectoryOrFile –Recurse -ErrorAction SilentlyContinue | measure Length -sum).sum)
        }
        $currentActivity.Text                = "Moving Files to $targetDirectoryOrFile"
        ForceGUIObjectToRefresh $currentActivity
        $targetBaseDirectory_prepped_for_sql = PrepForSql $targetBaseDirectory
        New-Item -ItemType Directory -Force -Path $targetDirectoryOrFile
        if ($isMovingADirectory) {
            $targetDirectoryOrFile                     = (Get-Item $targetDirectoryOrFile).Parent.FullName
        } else {
            $sourceFileName         = (Split-Path $Script:sourcePathToDirectoryOrFile -Leaf)
            $targetDirectoryOrFile += "\$sourceFileName"
        }

        $targetDirectory                       = (Split-Path $targetDirectoryOrFile -Parent)
        $targetDirectory_prepped_for_sql       = PrepForSql $targetDirectory
        $targetDirectoryOrFile_prepped_for_sql = PrepForSql $targetDirectoryOrFile
        LogMoveActivityLine "Moving $sourcePathToDirectoryOrFile to $targetDirectoryOrFile..." -textColor $StartingColor
        # ERROR: Can't run during single large -MoveItem and even between moves. No update. $activityAnimation.Load("D:\qt_projects\filmcab\simplified\images\animations\running.homer.silly.gif")

        # So much table change, we need to transact it. Else it leaves stuff during partial testing
        # NOTE: move_id is a sequence. rollbacks do not restore used ids. SQL Standard.

        try {
            $Script:ActiveTransaction        = $DatabaseConnection.BeginTransaction([System.Data.IsolationLevel]::ReadCommitted) #PostgreSQL's Read Uncommitted mode behaves like Read Committed. Only solution is to capture any sql errors and rollback, else partial data will be committed.

            $source_driveletter              = Left $sourcePathToDirectoryOrFile
            $sourceVolumeId                  = Get-SqlValue "SELECT volume_id from volumes WHERE drive_letter = '$source_driveletter'"
            $source_search_directory_id      = Get-SqlValue "SELECT search_directory_id FROM search_directories where search_directory = $sourceBaseDirectory_prepped_for_sql"

            $target_driveletter              = Left $targetDirectoryOrFile
            $targetVolumeId                  = Get-SqlValue "SELECT volume_id from volumes WHERE drive_letter = '$target_driveletter'"
            $target_search_directory_id      = Get-SqlValue "SELECT search_directory_id FROM search_directories where search_directory = $targetBaseDirectory_prepped_for_sql"

            $currentActivity.Text            = "(1) Creating a move transaction that keeps details..."
            ForceGUIObjectToRefresh $currentActivity

            $move_id = Get-SqlValue "
                INSERT INTO
                    moves(
                        move_started
                    ,   bytes_moved
                    ,   from_directory_or_file
                    ,   from_base_directory
                    ,   from_volume_id
                    ,   from_search_directory_id
                    ,   to_directory_or_file
                    ,   to_base_directory
                    ,   to_volume_id
                    ,   to_search_directory_id
                    ,   move_reason
                    ,   description_why_reason_applies
                    ,   note
                    )
                    VALUES(
                        /*  move_started                    */ TRANSACTION_TIMESTAMP()                                       /* Transaction start time above) */
                    ,   /*  bytes_moved                     */ $sizeOfSourceDirectoryOrFile                                  /* How much space we're freeing up */
                    ,   /*  from_directory_or_file          */ $sourceDirectoryOrFile_prepped_for_sql
                    ,   /*  from_base_directory             */ $sourceBaseDirectory_prepped_for_sql
                    ,   /*  from_volume_id                  */ $sourceVolumeId
                    ,   /*  from_search_directory_id        */ $source_search_directory_id
                    ,   /*  to_directory_or_file            */ $targetDirectoryOrFile_prepped_for_sql
                    ,   /*  to_base_directory               */ $targetBaseDirectory_prepped_for_sql
                    ,   /*  to_volume_id                    */ $targetVolumeId
                    ,   /*  to_search_directory_id          */ $target_search_directory_id
                    ,   /*  move_reason                     */ $moveReason_prepped_for_sql
                    ,   /*  description_why_reason_applies  */ $whyMove_prepped_for_sql
                    ,   /*  note                            */ $noteOnMove_prepped_for_sql
                    )
                    RETURNING move_id" -ThrowOnError

            $moveIdLabel.Text = $move_id
            $currentActivity.Text = "(2) Marking all sub directories as having been moved..."
            ForceGUIObjectToRefresh $currentActivity

            if ($isMovingADirectory) {

            Invoke-Sql "
                WITH RECURSIVE nodes AS (
                    SELECT *, $targetBaseDirectory_prepped_for_sql || '\' || dev.useful_part_of_directory          AS new_directory
                    FROM directories_ext_v dev WHERE directory = $sourceDirectoryOrFile_prepped_for_sql
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
            " -ThrowOnError |Out-Null

            $currentActivity.Text = "(3) Migrate the directory records over, altering them according to the new base directory."
            ForceGUIObjectToRefresh $currentActivity

            Invoke-Sql "
                WITH RECURSIVE nodes AS (
                    SELECT *, $targetBaseDirectory_prepped_for_sql || '\' || dev.useful_part_of_directory          AS new_directory
                    FROM directories_ext_v dev WHERE directory = $sourceDirectoryOrFile_prepped_for_sql
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
                    ON CONFLICT DO NOTHING
                " -ThrowOnError

            $currentActivity.Text = "(4) Marking all the moved files as moved and to where."
            ForceGUIObjectToRefresh $currentActivity

            Invoke-Sql "
                WITH RECURSIVE nodes AS (
                    SELECT *, $targetBaseDirectory_prepped_for_sql || '\' || dev.useful_part_of_directory          AS new_directory
                    FROM directories_ext_v dev WHERE directory = $sourceDirectoryOrFile_prepped_for_sql
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
            " -ThrowOnError|Out-Null

            $currentActivity.Text = "(5) Copying the file records over, altering paths and hashes as needed."
            ForceGUIObjectToRefresh $currentActivity

            Invoke-Sql "
                WITH RECURSIVE nodes AS (
                    SELECT *, $targetBaseDirectory_prepped_for_sql || '\' || dev.useful_part_of_directory          AS new_directory
                    FROM directories_ext_v dev WHERE directory = $sourceDirectoryOrFile_prepped_for_sql
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
                    ON CONFLICT DO NOTHING
            " -ThrowOnError|Out-Null
            }
            else {
                Invoke-Sql "
                    UPDATE
                        files_v
                    SET
                        move_id                 = $move_id
                    ,   moved_out               = $true
                    ,   moved_to_directory_hash = md5_hash_path($targetDirectory_prepped_for_sql)
                    FROM
                        files_ext_v y
                    WHERE
                        y.file_path = $sourceDirectoryOrFile_prepped_for_sql
                    AND
                        y.file_id = files_v.file_id
                    " -ThrowOnError
                Invoke-Sql "
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
                        ,   md5_hash_path($targetDirectory_prepped_for_sql)   AS directory_hash
                        ,   file_name_no_ext
                        ,   final_extension
                        ,   file_size
                        ,   file_date
                        ,   file_deleted
                        ,   file_is_symbolic_link
                        ,   False AS file_is_hard_link
                        ,   file_is_broken_link
                        ,   file_linked_path                                                      /* No way this is valid. Probably should update or null. */
                        ,   NULL                           AS file_ntfs_id
                        ,   $true                          AS scan_file_for_ntfs_id
                        ,   $move_id                       AS move_id
                        ,   True                           AS moved_in
                        ,   file_id                        AS moved_from_file_id
                        FROM
                            files_ext_v
                        WHERE
                            file_path = $targetDirectoryOrFile_prepped_for_sql
                        ON CONFLICT DO NOTHING
                " -ThrowOnError
            }
            $currentActivity.Text = "(6) Starting Move-Item..."
            ForceGUIObjectToRefresh $currentActivity

            ###############################################################################################################################################################################################################################################################
            ###############################################################################################################################################################################################################################################################
            try {

                #$arguments = @("$sourcePathToDirectoryOrFile","$targetDirectoryOrFile") #(Pass scriptblock up update gui progress)
                # When job finishes, need to lock move button
                #$job = Start-Job -ScriptBlock $ScriptBlockAsyncMoveFilesAndDirectories -ArgumentList $arguments
                #$jobEvent = Register-ObjectEvent $job StateChanged -Action {
                #    Write-Host ('Job #{0} ({1}) complete.' -f $sender.Id, $sender.Name)
                #    $jobEvent | Unregister-Event
                    #Start-BitsTransfer -Source $Source -Destination $Destination -Description "Backup" -DisplayName "Backup"
                    # When job finishes, need to unlock move button
                Move-Item -LiteralPath $sourcePathToDirectoryOrFile -Destination $targetDirectoryOrFile -Force
                #}
            } catch {}

            $currentActivity.Text = "(6) Move-Item Complete."
            ForceGUIObjectToRefresh $currentActivity
            ###############################################################################################################################################################################################################################################################
            ###############################################################################################################################################################################################################################################################

            $currentActivity.Text = "(7) Updating moves # $move_id with move_ended timestamp."
            ForceGUIObjectToRefresh $currentActivity

            Invoke-Sql "
                UPDATE
                    moves
                SET
                    move_ended = CLOCK_TIMESTAMP() /* Time on wall clock, so we can time the copy file commands */
                WHERE
                    move_id = $move_id" -OneAndOnlyOne -ThrowOnError|Out-Null

            # Complete. Silently remove item from tree.

            $Script:sequenceControlIgnoreNext_afterSelectTreeview = $true
            $treeViewOfPublishedDirectories.SelectedNode.Remove()
            if ($sizeOfSourceDirectoryOrFile -gt 300000 ) {
                # Assume it's a biggy
                [Console]::Beep(600,400);
            } else {
                [Console]::Beep(610,100);
            }
        }
        catch {
            Write-Host "Caught-Error"
            # Warning: Any crashes here will auto-commit!!!!!!
            if ((Test-Path variable:ActiveTransaction) -and $null -ne $ActiveTransaction -and $null -ne $ActiveTransaction.Connection) {
                Write-Host "Rolling back"
                $Script:ActiveTransaction.Rollback()
                $Script:ActiveTransaction.Dispose()
                $currentActivity.Text                = "Move CANCELLED"
                $currentActivity.ForeColor           = $Red
                $currentActivity.Font                = $BoldFont
                ForceGUIObjectToRefresh $currentActivity
                LogMoveActivityLine "Failed to move $sourcePathToDirectoryOrFile to $targetDirectoryOrFile" -textColor $FailColor
            } else {
                Write-Host "Caught-Error: No transaction found"
            }
        }
        finally {
            Write-Host "Hit Finally"
            if ((Test-Path variable:ActiveTransaction) -and $null -ne $ActiveTransaction -and $null -ne $ActiveTransaction.Connection) {
                $Script:ActiveTransaction.Commit()
                $Script:ActiveTransaction.Dispose()
                $Script:ActiveTransaction            = $null

                # Following will only be set IF it didn't have a catch, which rolled back the data, and so never gets past above if.

                $currentActivity.Text                = "MOVE COMPLETED SUCCESSFULLY"
                $currentActivity.ForeColor           = $Green
                $currentActivity.Font                = $BoldFont
                ForceGUIObjectToRefresh $currentActivity
                LogMoveActivityLine "Successfully moved $sourcePathToDirectoryOrFile to $targetDirectoryOrFile" -textColor $SuccessColor
            } else {
                Write-Host "Hit Finally: No transaction found"
            }
        }

        if ($leaveLinkInPlaceCheckBox.Checked) {
            if ($isMovingADirectory) {
                # Junction link
                New-Item -Path $sourcePathToDirectoryOrFile -ItemType Junction -Value $fullTargetDirectoryOrFile
            } else {
                # Symbolic Link
                New-Item -Path $sourcePathToDirectoryOrFile -ItemType SymbolicLink -Value $targetDirectoryOrFile
            }
        }
    }

    $Script:ActivelyMovingFiles = $false
    [Console]::Beep(500,300);[Console]::Beep(500,300)
    $form.Cursor                                 = [System.Windows.Forms.Cursors]::Default
    $selectedmoveReasonComboBox.Text             = ""
    $whyThisMoveReasonText.Text                  = ""
    $sourceDirectorySize.Text                    = ""
    $Script:checkedNodes.Clear()
}

$MoveFilesButton.add_click($Move_DirectoryOrFiles)|Out-Null

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

#################################################################################################################################################################################################
# Load all published directories into nodes and add them to tree view
#################################################################################################################################################################################################

Function LoadSubsetOfDirectoriesIntoTree($DirectoryLikeString) {

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
    AND
        directory like 'O:\Video AllInOne\`$_$($Script:directory_view_filter)%' ESCAPE '`$' /* Reduce workspace temporarily */
    ORDER BY
        directory_depth
    ,   directory
    "
# Load all the subfolders into the tree view

while ($AddFoldersToSeenOffline.Read()) {
    $parentBranch    = $parentDirectories[$Script:parent_directory]
    $branchNode      = New-Object System.Windows.Forms.TreeNode
    $branchNode.Text = "$Script:folder"
    $branchNode.Name = "$Script:directory"
    $branchNode.Tag  = "$Script:useful_part_of_directory"
    $parentDirectories.Add($Script:directory, $branchNode)|Out-Null
    $parentBranch.Nodes.Add($branchNode)|Out-Null
}

$rootNode.Expand()|Out-Null

$treeViewOfPublishedDirectories.EndUpdate()|Out-Null
}

###################################################################################################################################################################################################################################################################
# Set our place in the tree where we were last, or very near there. Labor-reducing.
###################################################################################################################################################################################################################################################################
if ((Test-Path variable:Script:directory_view_filter) -and -not [string]::IsNullOrWhiteSpace($Script:directory_view_filter)) {
    $treeFilterToDirectoryComboBox.Text = $Script:directory_view_filter # Should trigger a tree load
}

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

$form.BringToFront()|Out-Null # Required to get it on top, not just "TopMost"
$treeViewOfPublishedDirectories.Focus()|Out-Null
$form.TabIndex = 0
$form.ShowDialog()

}
catch {
    if ((Test-Path variable:ActiveTransaction) -and $null -ne $ActiveTransaction -and $null -ne $ActiveTransaction.Connection) {
        $Script:ActiveTransaction.Rollback()
        $Script:ActiveTransaction.Dispose()
    }

    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}
finally {
Write-AllPlaces "Finally"
. .\_dot_include_standard_footer.ps1
}

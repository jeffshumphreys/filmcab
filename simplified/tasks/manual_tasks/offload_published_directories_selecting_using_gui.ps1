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

# <#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($OKButton)<#~~~~~~~~~~~~~~~~~~~~#>

########################################################################################################################################################################################################
$CancelButton                            = New-Object System.Windows.Forms.Button
$CancelButton.Location                   = New-Object System.Drawing.Point(($ScreenWidth - $BUTTON_WIDTH),($ScreenHeight - $BUTTON_HEIGHT))
$CancelButton.Size                       = New-Object System.Drawing.Size($BUTTON_WIDTH, $BUTTON_HEIGHT)
$CancelButton.Text                       = "Cancel"
$CancelButton.DialogResult               = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton                       = $CancelButton

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($CancelButton)<#~~~~~~~~~~~~~~~~~~~~#>
$CancelButton.Hide() # Has to be present so "X" closes.

########################################################################################################################################################################################################
$treeViewOfPublishedDirectories          = New-Object System.Windows.Forms.TreeView
$columnWidth1                            = 344
$treeViewWidth                           = $columnWidth1
$System_Drawing_Size                     = New-Object System.Drawing.Size
$System_Drawing_Size.Width               = $treeViewWidth
$System_Drawing_Size.Height              = $ScreenHeight
$treeViewOfPublishedDirectories.Size     = $System_Drawing_Size
$treeViewOfPublishedDirectories.Name     = "treeViewOfPublishedDirectories"
$System_Drawing_Point                    = New-Object System.Drawing.Point
$System_Drawing_Point.X                  = 0
$System_Drawing_Point.Y                  = 0
$treeViewOfPublishedDirectories.Location = $System_Drawing_Point
$treeViewOfPublishedDirectories.TabIndex = 0

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($treeViewOfPublishedDirectories)<#~~~~~~~~~~~~~~~~~~~~#>

$selectedMoveReasonLabel                 = New-Object System.Windows.Forms.Label
$selectedMoveReasonLabel.Location        = New-Object System.Drawing.Point(($treeViewWidth + $HORIZONTAL_SPACER), ($BUTTON_HEIGHT * 2))
$selectedMoveReasonLabel.Size            = New-Object System.Drawing.Size(($columnWidth2), $BUTTON_HEIGHT)
$selectedMoveReasonLabel.Text            = "Move Reason"

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($selectedMoveReasonLabel)<#~~~~~~~~~~~~~~~~~~~~#>

########################################################################################################################################################################################################
$selectedmoveReasonComboBox              = New-Object System.Windows.Forms.ComboBox
$selectedmoveReasonComboBox.Location     = New-Object System.Drawing.Point(($treeViewWidth+$HORIZONTAL_SPACER), ($BUTTON_HEIGHT * 3))
$selectedmoveReasonComboBox.Size         = New-Object System.Drawing.Size($maxObjectWidth2, $BUTTON_HEIGHT)
$selectedmoveReasonComboBox.Items.AddRange("Seen", "Won't Watch", "Corrupt", "Poor Quality", 'Copyright Audio')|Out-Null

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($selectedmoveReasonComboBox)<#~~~~~~~~~~~~~~~~~~~~#>

$whyThisMoveReasonText                         = New-Object System.Windows.Forms.TextBox
$whyThisMoveReasonText.Location                = New-Object System.Drawing.Point(($treeViewWidth + $HORIZONTAL_SPACER), ($BUTTON_HEIGHT * 4))
$whyThisMoveReasonText.Size                    = New-Object System.Drawing.Size(($columnWidth2), $BUTTON_HEIGHT)
$whyThisMoveReasonText.PlaceholderText         = "Explain why this move reason"

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($whyThisMoveReasonText)<#~~~~~~~~~~~~~~~~~~~~#>

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Column 2
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
$maxObjectWidth2                         = 280
$columnWidth2                            = $maxObjectWidth2 + ($HORIZONTAL_SPACER*2)

########################################################################################################################################################################################################
$MoveFilesButton                         = New-Object System.Windows.Forms.Button
$MoveFilesButton.Location                = New-Object System.Drawing.Point(($treeViewWidth + $columnWidth2),0)                                                 
$MoveFilesButton.Size                    = New-Object System.Drawing.Size($BUTTON_WIDTH, $BUTTON_HEIGHT)
$MoveFilesButton.Text                    = "Move Files -->"                        
$MoveFilesButton.Enabled                 = $false

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($MoveFilesButton)<#~~~~~~~~~~~~~~~~~~~~#>

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Column 3
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
$maxObjectWidth3                         = 680
$columnWidth3                            = $maxObjectWidth3 + ($HORIZONTAL_SPACER*2)

########################################################################################################################################################################################################
$currentActivity                         = New-Object System.Windows.Forms.Label
$currentActivity.Location                = New-Object System.Drawing.Point(($treeViewWidth + $HORIZONTAL_SPACER + $columnWidth2), $BUTTON_HEIGHT)
$currentActivity.Size                    = New-Object System.Drawing.Size(($columnWidth3 + 200), $BUTTON_HEIGHT)
$currentActivity.Text                    = "...."

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($currentActivity)<#~~~~~~~~~~~~~~~~~~~~#>

########################################################################################################################################################################################################
$sourceFromLabel                         = New-Object System.Windows.Forms.Label
$maxObjectWidth3b                        = 100
$columnWidth3b                           = $maxObjectWidth3b + ($HORIZONTAL_SPACER)
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
$maxObjectWidth3b                        = 100
$columnWidth3b                           = $maxObjectWidth3b + ($HORIZONTAL_SPACER)
$targetToLabel.Location                  = New-Object System.Drawing.Point(($treeViewWidth + $HORIZONTAL_SPACER + $columnWidth2), ($BUTTON_HEIGHT * 3 + $VERTICAL_SPACER))
$targetToLabel.Size                      = New-Object System.Drawing.Size($columnWidth3b, $BUTTON_HEIGHT)
$targetToLabel.Text                      = "move to"
$targetToLabel.BorderStyle               = 'Fixed3D'
$targetToLabel.BackColor                 = $Yellow
$targetToLabel.Font                      = $ItalicFont
$targetToLabel.TextAlign                 = [System.Drawing.ContentAlignment]::MiddleRight

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($targetToLabel)<#~~~~~~~~~~~~~~~~~~~~#>

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Column 4
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
$maxObjectWidth3                         = 680
$columnWidth3                            = $maxObjectWidth3 + ($HORIZONTAL_SPACER*2)

########################################################################################################################################################################################################
$sourceDirectoryToMoveFrom                 = New-Object System.Windows.Forms.TextBox
$sourceDirectoryToMoveFrom.ReadOnly        = $true
$sourceDirectoryToMoveFrom.PlaceholderText = "selected source directory goes here"
$sourceDirectoryToMoveFrom.Location        = New-Object System.Drawing.Point(($treeViewWidth + $HORIZONTAL_SPACER + $columnWidth2 + $HORIZONTAL_SPACER + $columnWidth3b), ($BUTTON_HEIGHT * 2 + $VERTICAL_SPACER))
$sourceDirectoryToMoveFrom.Size            = New-Object System.Drawing.Size($maxObjectWidth3, $BUTTON_WIDTH)

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($selectedSourceDirectoryToMove)<#~~~~~~~~~~~~~~~~~~~~#>

########################################################################################################################################################################################################
$targetDirectoryToMoveTo                 = New-Object System.Windows.Forms.TextBox
$targetDirectoryToMoveTo.ReadOnly        = $true
$targetDirectoryToMoveTo.PlaceholderText = "selected target directory goes here"
$targetDirectoryToMoveTo.Location        = New-Object System.Drawing.Point(($treeViewWidth + $HORIZONTAL_SPACER + $columnWidth2 + $HORIZONTAL_SPACER + $columnWidth3b), ($BUTTON_HEIGHT * 3 + $VERTICAL_SPACER))
$targetDirectoryToMoveTo.Size            = New-Object System.Drawing.Size($maxObjectWidth3, $BUTTON_WIDTH)

Function EnableMoveFileButton() {
    return -not($treeViewOfPublishedDirectories.SelectedNode.Text.StartsWith('_') -or $treeViewOfPublishedDirectories.SelectedNode.Level -eq 0 -or 
    [string]::IsNullOrWhiteSpace($selectedmoveReasonComboBox.Text) -or
    $selectedmoveReasonComboBox.Text -notin $selectedmoveReasonComboBox.Items
    )
}

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($targetDirectoryToMoveTo)<#~~~~~~~~~~~~~~~~~~~~#>

#################################################################################################################################################################################################
# Action taken When the user or bootstrap sets what reason for moving, which then determines the volume and target directory.
#################################################################################################################################################################################################
$selectedmoveReasonComboBox.add_SelectedIndexChanged({
    $moveReason = $this.Text
    if (-not [string]::IsNullOrWhiteSpace($moveReason)) {
        if ($moveReason -ne "Seen") {
            $Script:targetBaseDirectory = "K:\Video AllInOne $moveReason"
        } else {
            $Script:targetBaseDirectory = "N:\Video AllInOne Seen"
        }
        $targetDirectoryToMoveTo.Text = $Script:targetBaseDirectory
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
    $Script:directory_path              = $this.SelectedNode.Name
    $selectedSourceDirectoryToMove.Text = $Script:directory_path
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
   
})

$selectedmoveReasonComboBox.add_TextChanged({
    $MoveFilesButton.Enabled            = EnableMoveFileButton
})
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
    $sourcePartOfPath                    = $treeViewOfPublishedDirectories.SelectedNode.Tag
    $moveReason                          = $selectedmoveReasonComboBox.Text
    $moveReason_prepped_for_sql          = PrepForSql $moveReason
    $whyMove                             = $whyThisMoveReasonText.Text
    $whyMove_prepped_for_sql             = PrepForSql $whyMove
    $targetBaseDirectory                 = "N:\Video AllInOne Seen"
    
    if ($moveReason -ne "Seen") {
        $targetBaseDirectory = "K:\Video AllInOne $moveReason"
    }                       
    
    $targetDirectory                     = "$targetBaseDirectory\$sourcePartOfPath"
    $currentActivity.Text                = "Moving Files to $targetDirectory"
    $currentActivity.Refresh()
    $targetBaseDirectory_prepped_for_sql = PrepForSql $targetBaseDirectory
    New-Item -ItemType Directory -Force -Path $targetDirectory
    $targetDirectory                     = (Get-Item $targetDirectory).Parent.FullName
    $targetDirectory_prepped_for_sql     = PrepForSql $targetDirectory


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

        # Step (1) Get a move transaction record and it's id
        
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

        $currentActivity.Text = "Move Id # $move_id"
        $currentActivity.Refresh()
        
        # Step (2) Move the files over. This can't get rolled back

        $currentActivity.Text = "Starting Move-Item"
        $currentActivity.Refresh()

        ###############################################################################################################################################################################################################################################################
        ###############################################################################################################################################################################################################################################################
        $movedFilesYet = $false
        try {
            Move-Item -LiteralPath $sourceDirectory -Destination $targetDirectory -Force
        } catch {}
        $movedFilesYet = $true                                                                                                                                                                                                                                         

        $currentActivity.Text = "Move-Item complete"
        $currentActivity.Refresh()
        ###############################################################################################################################################################################################################################################################
        ###############################################################################################################################################################################################################################################################
        ###############################################################################################################################################################################################################################################################

        # Step (3) Stamp the duration of the move, and which direction the data was moving, into the table/folder, or out of the table and folders.
        $currentActivity.Text = "Updating moves # $move_id with move_ended timestamp."
        $currentActivity.Refresh()
        
        Invoke-Sql "
            UPDATE 
                moves 
            SET 
                move_ended = CLOCK_TIMESTAMP() /* Time on wall clock, so we can time the copy file commands */
            WHERE 
                move_id = $move_id" -OneAndOnlyOne|Out-Null
        
        # Step (4) Mark all sub directories as having been moved.
        
        $currentActivity.Text = "Marking all sub directories as having been moved..."
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
        
        # Step (5) Migrate the directory records over, altering them according to the new base directory.

        $currentActivity.Text = "Migrate the directory records over, altering them according to the new base directory."
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

        # Step (6) Mark all the moved files as moved and to where.

        $currentActivity.Text = "Marking all the moved files as moved and to where."
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
       
        # Step (7) Copy the file records over, altering as needed.

        $currentActivity.Text = "Copying the file records over, altering paths and hashes as needed."
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

        $treeViewOfPublishedDirectories.SelectedNode.Remove()               
    }                        
    catch {
        # Warning: Any crashes here will auto-commit!!!!!!
        if ((Test-Path variable:ActiveTransaction) -and $null -ne $ActiveTransaction -and $null -ne $ActiveTransaction.Connection) {
            $Script:ActiveTransaction.Rollback()
            $Script:ActiveTransaction.Dispose()
            $currentActivity.Text ="Move CANCELLED"
            $currentActivity.ForeColor = $Red
            $currentActivity.Font = $BoldFont
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
            }

    }
    $form.Cursor                                 = [System.Windows.Forms.Cursors]::Default    
    $selectedmoveReasonComboBox.SelectedItem     = ""
    $whyThisMoveReasonText.Text                  = ""

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
    AND directory like 'O:\Video AllInOne\`$_Mystery%' ESCAPE '`$'
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

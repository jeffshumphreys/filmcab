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

$form                  = New-Object System.Windows.Forms.Form
$form.Text             = "Select a directory to offload"
$form.StartPosition    = "CenterScreen"
$form.WindowState      = 'Maximized'
$form.Height           = $ScreenHeight
$form.Width            = $ScreenWidth
$BUTTON_WIDTH          = 75
$BUTTON_HEIGHT         = 23
$HORIZONTAL_SPACER     = 5

########################################################################################################################################################################################################
$OKButton              = New-Object System.Windows.Forms.Button
$OKButton.Location     = New-Object System.Drawing.Point(($ScreenWidth -  $BUTTON_WIDTH - $HORIZONTAL_SPACER - $BUTTON_WIDTH),($ScreenHeight - $BUTTON_HEIGHT))
$OKButton.Size         = New-Object System.Drawing.Size($BUTTON_WIDTH, $BUTTON_HEIGHT)
$OKButton.Text         = "OK"
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton     = $OKButton

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($OKButton)<#~~~~~~~~~~~~~~~~~~~~#>

########################################################################################################################################################################################################
$CancelButton              = New-Object System.Windows.Forms.Button
$CancelButton.Location     = New-Object System.Drawing.Point(($ScreenWidth - $BUTTON_WIDTH),($ScreenHeight - $BUTTON_HEIGHT))
$CancelButton.Size         = New-Object System.Drawing.Size($BUTTON_WIDTH, $BUTTON_HEIGHT)
$CancelButton.Text         = "Cancel"
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton         = $CancelButton

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($CancelButton)<#~~~~~~~~~~~~~~~~~~~~#>

########################################################################################################################################################################################################
$columnWidth1                                                            = 344
$treeViewWidth                                                           = $columnWidth1
$treeViewOfPublishedDirectories                                          = New-Object System.Windows.Forms.TreeView
$System_Drawing_Size                                                     = New-Object System.Drawing.Size
$System_Drawing_Size.Width                                               = $treeViewWidth
$System_Drawing_Size.Height                                              = $ScreenHeight
$treeViewOfPublishedDirectories.Size                                     = $System_Drawing_Size
$treeViewOfPublishedDirectories.Name                                     = "treeViewOfPublishedDirectories"
$System_Drawing_Point                                                    = New-Object System.Drawing.Point
$System_Drawing_Point.X                                                  = 0
$System_Drawing_Point.Y                                                  = 0
$treeViewOfPublishedDirectories.Location                                 = $System_Drawing_Point
$treeViewOfPublishedDirectories.DataBindings.DefaultDataSourceUpdateMode = 0
$treeViewOfPublishedDirectories.TabIndex                                 = 0

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($treeViewOfPublishedDirectories)<#~~~~~~~~~~~~~~~~~~~~#>

########################################################################################################################################################################################################
$maxObjectWidth2                               = 280
$columnWidth2                                  = $maxObjectWidth2 + ($HORIZONTAL_SPACER*2)
$selectedSourceDirectoryToMove                 = New-Object System.Windows.Forms.TextBox
$selectedSourceDirectoryToMove.ReadOnly        = $true
$selectedSourceDirectoryToMove.PlaceholderText = "selected directory goes here"
$selectedSourceDirectoryToMove.Location        = New-Object System.Drawing.Point(($treeViewWidth + $HORIZONTAL_SPACER), $BUTTON_HEIGHT)
$selectedSourceDirectoryToMove.Size            = New-Object System.Drawing.Size($maxObjectWidth2, $BUTTON_WIDTH)

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($selectedSourceDirectoryToMove)<#~~~~~~~~~~~~~~~~~~~~#>

########################################################################################################################################################################################################
$maxObjectWidth3          = 680
$columnWidth3             = $maxObjectWidth3 + ($HORIZONTAL_SPACER*2)
$currentActivity          = New-Object System.Windows.Forms.Label
$currentActivity.Location = New-Object System.Drawing.Point(($treeViewWidth + $HORIZONTAL_SPACER + $columnWidth2), $BUTTON_HEIGHT)
$currentActivity.Size     = New-Object System.Drawing.Size($columnWidth3, $BUTTON_WIDTH)
$currentActivity.Text     = "...."

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($currentActivity)<#~~~~~~~~~~~~~~~~~~~~#>

########################################################################################################################################################################################################
$selectedmoveReasonComboBox          = New-Object System.Windows.Forms.ComboBox
$selectedmoveReasonComboBox.Location = New-Object System.Drawing.Point(($treeViewWidth+$HORIZONTAL_SPACER), 0)
$selectedmoveReasonComboBox.Size     = New-Object System.Drawing.Size($maxObjectWidth2, $BUTTON_WIDTH)
$selectedmoveReasonComboBox.Items.Add("Seen")                    | Out-Null
$selectedmoveReasonComboBox.Items.Add("Won't Watch")             | Out-Null
$selectedmoveReasonComboBox.Items.Add("Corrupt")                 | Out-Null
$selectedmoveReasonComboBox.Items.Add("Poor Quality")            | Out-Null
$selectedmoveReasonComboBox.Items.Add("Copyright Audio")         | Out-Null 
$selectedmoveReasonComboBox.SelectedItem = "Won't Watch"

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($selectedmoveReasonComboBox)<#~~~~~~~~~~~~~~~~~~~~#>

# TODO: Let user add new target directories, and make sure it's in the volume table so we can save the volume_id

########################################################################################################################################################################################################
$MoveFilesButton              = New-Object System.Windows.Forms.Button
$MoveFilesButton.Location     = New-Object System.Drawing.Point(($treeViewWidth + $columnWidth2),0)                                                 
$MoveFilesButton.Size         = New-Object System.Drawing.Size($BUTTON_WIDTH, $BUTTON_HEIGHT)
$MoveFilesButton.Text         = "Move Files -->"                        
$MoveFilesButton.Enabled      = $false

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($MoveFilesButton)<#~~~~~~~~~~~~~~~~~~~~#>

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
    $MoveFilesButton.Enabled            = $true
})

###########################################################################################################################################################################################
# Action taken when we click the move button
###########################################################################################################################################################################################
$Move_Directory = {
    $currentActivity.Text                ="moving ..."
    $sourceDirectory                     = $treeViewOfPublishedDirectories.SelectedNode.Name
    $sourceBaseDirectory                 = $Script:sourceBaseDirectory
    $sourceBaseDirectory_prepped_for_sql = PrepForSql $sourceBaseDirectory
    $sourceDirectory_prepped_for_sql     = PrepForSql $sourceDirectory
    $sizeOfSourceDirectory               = ((gci –force -LiteralPath $sourceDirectory –Recurse -ErrorAction SilentlyContinue | Where-Object { $_.LinkType -notmatch "HardLink" }| measure Length -sum).sum)
    $sourcePartOfPath                    = $treeViewOfPublishedDirectories.SelectedNode.Tag
    $moveReason                          = $selectedmoveReasonComboBox.Text
    $moveReason_prepped_for_sql          = PrepForSql $moveReason
    $targetBaseDirectory                 = "N\Video AllInOne Seen"
    
    if ($moveReason -ne "Seen") {
        $targetBaseDirectory = "K:\Video AllInOne $moveReason"
    }                       
    
    $targetDirectory                     = "$targetBaseDirectory\$sourcePartOfPath"
    $currentActivity.Text                = "Moving Files to $targetDirectory"
    $targetBaseDirectory_prepped_for_sql = PrepForSql $targetBaseDirectory
    New-Item -ItemType Directory -Force -Path $targetDirectory
    $targetDirectory                     = (Get-Item $targetDirectory).Parent.FullName
    $targetDirectory_prepped_for_sql     = PrepForSql $targetDirectory


    # So much table change, we need to transact it. Else it leaves stuff during partial testing
    # NOTE: move_id is a sequence. rollbacks do not restore used ids. SQL Standard.

    try {
        $Script:ActiveTransaction   = $DatabaseConnection.BeginTransaction([System.Data.IsolationLevel]::ReadUncommitted)
       
        $source_driveletter         = Left $sourceDirectory
        $sourceVolumeId             = Get-SqlValue "SELECT volume_id from volumes WHERE drive_letter = '$source_driveletter'"
        $source_search_directory_id = Get-SqlValue "SELECT search_directory_id FROM search_directories where search_directory = $sourceBaseDirectory_prepped_for_sql"
       
        $target_driveletter         = Left $targetDirectory
        $targetVolumeId             = Get-SqlValue "SELECT volume_id from volumes WHERE drive_letter = '$target_driveletter'"
        $target_search_directory_id = Get-SqlValue "SELECT search_directory_id FROM search_directories where search_directory = $targetBaseDirectory_prepped_for_sql"

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
                ) 
                RETURNING move_id"
        
        # Step (2) Move the files over. This can't get rolled back

        #Copy-Item -LiteralPath $sourceDirectory -Destination $targetDirectory -Force -Recurse
        #Move-Item -LiteralPath $sourceDirectory -Destination $targetDirectory -Force -Recurse

        # Step (3) Stamp the duration of the move, and which direction the data was moving, into the table/folder, or out of the table and folders.
        
        Invoke-Sql "
            UPDATE 
                moves 
            SET 
                move_ended = CLOCK_TIMESTAMP() /* Time on wall clock, so we can time the copy file commands */
            WHERE 
                move_id = $move_id" -OneAndOnlyOne|Out-Null
        
        # Step (4) Mark all sub directories as having been moved.
        
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
        
        # Step (5) Migrate the directory records over, altering as needed.

        Invoke-Sql "
            WITH RECURSIVE nodes AS (
                SELECT *, $targetBaseDirectory_prepped_for_sql || '\' || dev.useful_part_of_directory          AS new_directory 
                FROM directories_ext_v dev WHERE directory = $sourceDirectory_prepped_for_sql
            UNION ALL 
                SELECT dev.*, $targetBaseDirectory_prepped_for_sql || '\' || dev.useful_part_of_directory      AS new_directory 
                FROM directories_ext_v dev JOIN nodes ON dev.parent_directory_hash = nodes.directory_hash
            )
            , newstuff1 AS (
                SELECT *,  
                /*     folder                      */ reverse((string_to_array(reverse(new_directory), '\'))[1]) AS new_folder,
                /*     parent_folder               */ reverse((string_to_array(reverse(new_directory), '\'))[2]) AS new_parent_folder,
                /*     grantparent_folder          */ reverse((string_to_array(reverse(new_directory), '\'))[3]) AS new_grandparent_folder
                FROM nodes
            )
            , newstuff2 AS (  
                SELECT *,
                    md5_hash_path(new_directory)                            AS new_directory_hash
                ,   Left(directory, length(directory)-(length(folder)+1))   AS new_parent_directory
                FROM newstuff1
            )
            INSERT INTO 
                directories_v(
                    directory_hash, 
                    directory,
                    parent_directory_hash, 
                    directory_date, 
                    volume_id, 
                    search_directory_id,
                    folder,
                    parent_folder,
                    grandparent_folder,
                    directory_deleted,
                    move_id
                ,   moved_in
                ,   moved_from_directory_hash
                ,   moved_from_volume_id
                )
            SELECT 
                new_directory_hash                     AS directory_hash, 
                new_directory                          AS directory,
                md5_hash_path(new_parent_directory)    AS parent_directory_hash, 
                directory_date                         AS directory_date,           /* Should be same? */
                $targetVolumeId                        AS volume_id, 
                $target_search_directory_id            AS search_directory_id,
                new_folder                             AS folder,
                new_parent_folder                      AS parent_folder,
                new_grandparent_folder                 AS grandparent_folder,
                directory_deleted                      AS directory_deleted,
                $move_id                               AS move_id,
                True                                   AS moved_in,
                directory_hash                         AS moved_from_directory_hash,
                $sourceVolumeId                        AS moved_from_volume_id
            FROM 
                newstuff2
        "                                                                                                                             

        # Step (6) Mark all the moved files as moved and to where.

        Invoke-Sql "
            WITH RECURSIVE nodes AS (
                SELECT *, $targetBaseDirectory_prepped_for_sql || '\' || dev.useful_part_of_directory          AS new_directory  
                FROM directories_ext_v dev WHERE directory = $sourceDirectory_prepped_for_sql
            UNION ALL 
                SELECT dev.*, $targetBaseDirectory_prepped_for_sql || '\' || dev.useful_part_of_directory      AS new_directory  
                FROM directories_ext_v dev JOIN nodes ON dev.parent_directory_hash = nodes.directory_hash
            ),
            all_files AS (
                SELECT f.* FROM files_ext_v f JOIN nodes USING(directory_hash)
            ),
            UPDATE
                files_v x
            SET
                x.move_id = $move_id
            ,   x.moved_out = $true  
            ,   x.moved_to_directory_hash = md5_from_path(y.new_directory)
            )
            FROM 
                all_files y
            WHERE
                x.file_id = y.file_id
            
        "                                                                                                                             
       
        # Step (7) Copy the file records over, altering as needed.

        Invoke-Sql "
            WITH RECURSIVE nodes AS (
                SELECT *, $targetBaseDirectory_prepped_for_sql || '\' || dev.useful_part_of_directory          AS new_directory  
                FROM directories_ext_v dev WHERE directory = $sourceDirectory_prepped_for_sql
            UNION ALL 
                SELECT dev.*, $targetBaseDirectory_prepped_for_sql || '\' || dev.useful_part_of_directory      AS new_directory  
                FROM directories_ext_v dev JOIN nodes ON dev.parent_directory_hash = nodes.directory_hash
            ),
            all_files AS (
                SELECT f.* FROM files_ext_v f JOIN nodes USING(directory_hash)
            ),
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
                ,   file_ntfs_id /* probably wrong */
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
            ,   linked_path
            ,   $null                          AS file_ntfs_id
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
        if ((Test-Path variable:ActiveTransaction) -and $null -ne $ActiveTransaction -and $null -ne $ActiveTransaction.Connection) {
            $Script:ActiveTransaction.Rollback()
            $Script:ActiveTransaction.Dispose()
        }                                             
    }
    finally {
        if ((Test-Path variable:ActiveTransaction) -and $null -ne $ActiveTransaction -and $null -ne $ActiveTransaction.Connection) {
            $Script:ActiveTransaction.Commit()
            $Script:ActiveTransaction.Dispose($true)
            $Script:ActiveTransaction = $null
            $currentActivity.Text                = ""
        }

    }
}

$MoveFilesButton.add_click($Move_Directory)

#################################################################################################################################################################################################
# Load all published directories into nodes and add them to tree view
#################################################################################################################################################################################################
                                                                     
$SearchPathToLookForOffloadables = WhileReadSql "
    SELECT 
        search_directory_id
    ,   search_directory 
    FROM 
        search_directories_ext_v 
    WHERE 
        tag = 'published'
    "
                    
$SearchPathToLookForOffloadables.Read()|Out-Null
$searchDirectoryId = $search_directory_id
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
    AND (
            directory = 'O:\Video AllInOne\_Mystery\Annika (2021-)'
        OR
            directory = 'O:\Video AllInOne\_Mystery'
        OR
            directory = 'O:\Video AllInOne'
        )
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

if (Test-Path variable:Script:directory_path) {
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

$form.Topmost = $True

$form.BringToFront() # Required to get it on top, not just "TopMost"

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $x = $listBox.SelectedItem
    $x
}

}
catch {
Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}                                  
finally {
Write-AllPlaces "Finally"
. .\_dot_include_standard_footer.ps1
}

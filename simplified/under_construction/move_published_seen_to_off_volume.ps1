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
 $OKButton.Location     = New-Object System.Drawing.Point(($ScreenWidth -  $BUTTON_WIDTH - $HORIZONTAL_SPACER -  $BUTTON_WIDTH),($ScreenHeight - $BUTTON_HEIGHT))
 $OKButton.Size         = New-Object System.Drawing.Size($BUTTON_WIDTH, $BUTTON_HEIGHT)
 $OKButton.Text         = "OK"
 $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
 $form.AcceptButton     = $OKButton
 $form.Controls.Add($OKButton)
 
 ########################################################################################################################################################################################################
 $CancelButton              = New-Object System.Windows.Forms.Button
 $CancelButton.Location     = New-Object System.Drawing.Point(($ScreenWidth - $BUTTON_WIDTH),($ScreenHeight - $BUTTON_WIDTH))
 $CancelButton.Size         = New-Object System.Drawing.Size($BUTTON_WIDTH, $BUTTON_HEIGHT)
 $CancelButton.Text         = "Cancel"
 $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
 $form.CancelButton         = $CancelButton
 $form.Controls.Add($CancelButton)
 
 ########################################################################################################################################################################################################
 $columnWidth1 = 344
 $treeViewWidth = $columnWidth1
 $treeView                                          = New-Object System.Windows.Forms.TreeView
 $System_Drawing_Size                               = New-Object System.Drawing.Size
 $System_Drawing_Size.Width                         = $treeViewWidth
 $System_Drawing_Size.Height                        = $ScreenHeight
 $treeView.Size                                     = $System_Drawing_Size
 $treeView.Name                                     = "treeView"
 $System_Drawing_Point                              = New-Object System.Drawing.Point
 $System_Drawing_Point.X                            = 0
 $System_Drawing_Point.Y                            = 0
 $treeView.Location                                 = $System_Drawing_Point
 $treeView.DataBindings.DefaultDataSourceUpdateMode = 0
 $treeView.TabIndex                                 = 0
 $form.Controls.Add($treeView)

 $maxObjectWidth2 = 280
 $columnWidth2 = $maxObjectWidth2 + ($HORIZONTAL_SPACER*2)
 $selectedDirectoryInput            = New-Object System.Windows.Forms.TextBox
 $selectedDirectoryInput.ReadOnly   = $true
 $selectedDirectoryInput.Location   = New-Object System.Drawing.Point(($treeViewWidth+$HORIZONTAL_SPACER), $BUTTON_HEIGHT)
 $selectedDirectoryInput.Size       = New-Object System.Drawing.Size($maxObjectWidth2,$BUTTON_WIDTH)
 $form.Controls.Add($selectedDirectoryInput)

 $selectedTargetComboBox            = New-Object System.Windows.Forms.ComboBox
 $selectedTargetComboBox.Location   = New-Object System.Drawing.Point(($treeViewWidth+$HORIZONTAL_SPACER), 0)
 $selectedTargetComboBox.Size       = New-Object System.Drawing.Size($maxObjectWidth2, $BUTTON_WIDTH)
 $i = $selectedTargetComboBox.Items.Add("Seen")                    | Out-Null
      $selectedTargetComboBox.Items.Add("Won't Watch") | Out-Null
      $selectedTargetComboBox.Items.Add("Corrupt") | Out-Null
      $selectedTargetComboBox.Items.Add("Poor Quality") | Out-Null
      $selectedTargetComboBox.Items.Add("Copyright Audio") | Out-Null
 $selectedTargetComboBox.SelectedIndex = $i
 $form.Controls.Add($selectedTargetComboBox)

 $MoveButton              = New-Object System.Windows.Forms.Button
 $MoveButton.Location     = New-Object System.Drawing.Point(($treeViewWidth + $columnWidth2),0)                                                 
 $MoveButton.Size         = New-Object System.Drawing.Size($BUTTON_WIDTH, $BUTTON_HEIGHT)
 $MoveButton.Text         = "Move -->"                        
 
 $form.Controls.Add($MoveButton)
 
 ###########################################################################################################################################################################################
 # Action taken when we click the move button
 ###########################################################################################################################################################################################
 $Move_Directory = {
     $sourceDirectory                 = $treeView.SelectedNode.Name
     $sourceDirectory_prepped_for_sql = PrepForSql $sourceDirectory
     $sizeOfSourceDirectory           = ((gci –force -LiteralPath $sourceDirectory –Recurse -ErrorAction SilentlyContinue | Where-Object { $_.LinkType -notmatch "HardLink" }| measure Length -sum).sum)
     $partOfPath                      = $treeView.SelectedNode.Tag
     $targetType                      = $selectedTargetComboBox.Text
     $targetType_prepped_for_sql      = PrepForSql $targetType
     $targetDirectory                 = "N:\Video AllInOne Seen\$partOfPath"
     
     if ($targetType -ne "Seen") {
        $targetDirectory = "K:\Video AllInOne $targetType\$partOfPath"
     } else {
        $targetDirectory = "N:\Video AllInOne Seen\$partOfPath"
     }                       

     $targetDirectory = (Get-Item $targetDirectory).Parent.FullName
     $targetDirectory_prepped_for_sql = PrepForSql $targetDirectory
     New-Item -ItemType Directory -Force -Path $targetDirectory
     $move_id = Get-SqlValue "
        INSERT INTO 
            moves(
                    move_started
                ,   bytes_moved
                ,   from_directory
                ,   to_directory
                ,   move_reason
                ) 
                VALUES(
                    CURRENT_TIMESTAMP
                ,   $sizeOfSourceDirectory
                ,   $sourceDirectory_prepped_for_sql
                ,   $targetDirectory_prepped_for_sql
                ,   $targetType_prepped_for_sql
                ) 
                RETURNING move_id"

     #Copy-Item -LiteralPath $sourceDirectory -Destination $targetDirectory -Force -Recurse
     Invoke-Sql "UPDATE moves SET move_ended = CURRENT_TIMESTAMP WHERE move_id = $move_id"
     $directory_hash = Get-SqlValue "UPDATE directories_v SET move_id = $move_id, moved_out = True WHERE directory = $sourceDirectory_prepped_for_sql RETURNING directory_hash"     
     $directory_hash = @($directory_hash|Format-Hex|Select ascii).Ascii -Join ''
     Invoke-Sql "
        WITH RECURSIVE nodes AS (SELECT * FROM directories_ext_v dev  WHERE directory = 'O:\Video AllInOne\_Mystery\Annika (2021-)'
        UNION ALL 
        SELECT dev.* FROM directories_ext_v dev JOIN nodes  ON dev.parent_directory_hash = nodes.directory_hash
        )
        UPDATE directories_v x SET move_id = $move_id, moved_out = TRUE WHERE directory_hash IN(SELECT directory_hash FROM nodes)
     "                                                                                                                             
     # Now with all the files                
     # Get 
     $target_driveletter = Left $targetDirectory
     
     Invoke-Sql "
        WITH RECURSIVE nodes AS (SELECT * FROM directories_ext_v dev  WHERE directory = 'O:\Video AllInOne\_Mystery\Annika (2021-)'
        UNION ALL 
        SELECT dev.* FROM directories_ext_v dev JOIN nodes  ON dev.parent_directory_hash = nodes.directory_hash
        )
        INSERT 
            directories_v(
                directory_hash, 
                directory,
                parent_directory_hash, 
                directory_date, 
                volume_id, 
                scan_directory, 
                directory_is_symbolic_link, 
                directory_is_junction_link, 
                linked_directory,
                search_directory_id,
                folder,
                parent_folder,
                grandparent_folder,
                directory_deleted,
                move_id
            ,   moved_in                         
            )
        SELECT 
            (recalc)                                      AS directory_hash, 
            (adjusted from to base)                       AS directory,
            (recalc)                                      AS parent_directory_hash, 
            (need)                                        AS directory_date, 
            (SELECT volume_id FROM volumes WHERE drive_letter = '$on_fs_driveletter') AS volume_id, 
            false                                         AS scan_directory, 
            directory_is_symbolic_link                    AS directory_is_symbolic_link, 
            directory_is_junction_link,                   AS directory_is_junction_link, 
            linked_directory                              AS linked_directory,
            (?????)                                       AS search_directory_id,
            (recalc)                                      AS folder,
            (recalc)                                      AS parent_folder,
            (recalc)                                      AS grandparent_folder,
            directory_deleted                             AS directory_deleted,
            $move_id                                      AS move_id,
            True                                          AS moved_in                                    
        FROM nodes 
     "                                                                                                                             

     # Now create directories dupping the ones from source
     # Now copy file detail, especially hashes over
     $treeView.SelectedNode.Remove()                                       
 }
 
 $MoveButton.add_click($Move_Directory)
 
 #################################################################################################################################################################################################
 # When the user selects a node in the tree, we capture the detail for displaying for the move action
 #################################################################################################################################################################################################
 $treeView.add_AfterSelect({
     $Script:directory_path = $this.SelectedNode.Name
     $selectedDirectoryInput.Text = $Script:directory_path
     $Script:parent_directory_path = $this.TopNode.Name
     $Script:prev_directory_path = $this.SelectedNode.PrevNode.Name
     $Script:next_directory_path = $this.SelectedNode.NextNode.Name
     
     # Get nodes before and after for when this node is removed.

 
 })
 
 $SearchPathToLookForOffloadables = WhileReadSql "SELECT search_directory_id, search_directory FROM search_directories_ext_v WHERE tag = 'published'"
                        
 $SearchPathToLookForOffloadables.Read()|Out-Null
 $searchDirectoryId = $search_directory_id
 
 $treeView.Nodes.Clear()
 $treeView.BeginUpdate()
 $parentDirectories = New-Object 'system.collections.generic.dictionary[String, System.Windows.Forms.TreeNode]'
 
 $rootNode = New-Object System.Windows.Forms.TreeNode      
 $parentDirectories.Add($search_directory, $rootNode)
 $rootNode.Text = "$search_directory"
 $treeView.Nodes.Add($rootNode)|Out-Null
 
 $AddFoldersToSeenOffline = WhileReadSql "
    SELECT 
        directory, 
        useful_part_of_directory, 
        parent_directory, 
        folder 
    FROM 
        directories_ext_v dev 
    WHERE 
        search_directory_id = $searchDirectoryId 
    AND 
        directory_depth >= 1                       
    AND
        move_id IS NULL /* Not already moven */
    ORDER BY 
        directory_depth, 
        directory
    "
 # Load all the subfolders
 
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
                        
 $treeView.EndUpdate()

 # Set our place in the tree where we were last, or very near there.
 
 if (Test-Path variable:Script:directory_path) {
    [array]$treeNodesForThatDirectory = $treeView.Nodes.Find($Script:directory_path, $true)
    # if not found, we need to have saved the higher folder, and then the next alphabetic subfolder.
    if ($treeNodesForThatDirectory.Count -ge 1) {
        $treeView.SelectedNode = ($treeNodesForThatDirectory[0])
        $treeView.Focus()
        # Get nodes before and after for when this node is removed.
    }
 } elseif ((Test-Path variable:Script:prev_directory_path) -and -not [string]::IsNullOrWhiteSpace($Script:prev_directory_path)) {
    [array]$treeNodesForThatDirectory = $treeView.Nodes.Find($Script:prev_directory_path, $true)
    # if not found, we need to have saved the higher folder, and then the next alphabetic subfolder.
    if ($treeNodesForThatDirectory.Count -ge 1) {
        $treeView.SelectedNode = ($treeNodesForThatDirectory[0])
        # Get nodes before and after for when this node is removed.
    }
 } elseif ((Test-Path variable:Script:next_directory_path) -and -not [string]::IsNullOrWhiteSpace($Script:next_directory_path)) {
    [array]$treeNodesForThatDirectory = $treeView.Nodes.Find($Script:next_directory_path, $true)
    # if not found, we need to have saved the higher folder, and then the next alphabetic subfolder.
    if ($treeNodesForThatDirectory.Count -ge 1) {
        $treeView.SelectedNode = ($treeNodesForThatDirectory[0])
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

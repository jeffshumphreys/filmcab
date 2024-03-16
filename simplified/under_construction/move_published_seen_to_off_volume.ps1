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

 . .\_dot_include_standard_header.ps1

 . .\_dot_include_gui_tools.ps1
 
 Import-Module BitsTransfer
 
 $form               = New-Object System.Windows.Forms.Form
 $form.Text          = "Select a directory to offload"
 $form.StartPosition = "CenterScreen"
 $form.WindowState   = 'Maximized'
 $form.Height        = $ScreenHeight
 $form.Width         = $ScreenWidth
 
 $OKButton              = New-Object System.Windows.Forms.Button
 $OKButton.Location     = New-Object System.Drawing.Point(($ScreenWidth - 75 - 5 - 75),($ScreenHeight - 23))
 $OKButton.Size         = New-Object System.Drawing.Size(75,23)
 $OKButton.Text         = "OK"
 $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
 $form.AcceptButton     = $OKButton
 $form.Controls.Add($OKButton)
 
 $CancelButton              = New-Object System.Windows.Forms.Button
 $CancelButton.Location     = New-Object System.Drawing.Point(($ScreenWidth - 75),($ScreenHeight - 23))                                                 
 $CancelButton.Size         = New-Object System.Drawing.Size(75,23)
 $CancelButton.Text         = "Cancel"
 $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
 $form.CancelButton         = $CancelButton
 $form.Controls.Add($CancelButton)
                                                      
 $treeViewWidth = 344
 
 $selectedDirectoryInput            = New-Object System.Windows.Forms.TextBox
 $selectedDirectoryInput.ReadOnly   = $true
 $selectedDirectoryInput.Location   = New-Object System.Drawing.Point(($treeViewWidth+10),20)
 $selectedDirectoryInput.Size       = New-Object System.Drawing.Size(280,20)
 $form.Controls.Add($selectedDirectoryInput)
 
 $MoveButton              = New-Object System.Windows.Forms.Button
 $MoveButton.Location     = New-Object System.Drawing.Point(($treeViewWidth + 280+5),20)                                                 
 $MoveButton.Size         = New-Object System.Drawing.Size(75,23)
 $MoveButton.Text         = "Move -->"                        
 
 $form.Controls.Add($MoveButton)
 
 $Move_Directory = {
     $sourcePath = $treeView.SelectedNode.Name
     $partOfPath = $treeView.SelectedNode.Tag
     $targetPath = "N:\Video AllInOne Seen\$partOfPath)"
     New-Item -ItemType Directory -Force -Path $targetPath
     Copy-Item -LiteralPath $sourcePath -Destination $targetPath -Force -Recurse
     #$treeView.SelectedNode.Remove(
     #TODO: Update record in directories, and files. Add a moved and where flag, (seen or corrupt) Set reasons in the directories table, like seen, won't finish, etc.
     # Set deleted and moved_to
 }
 
 $MoveButton.add_click($Move_Directory)
 
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
 
 $treeView.add_AfterSelect({
     $directory_path = $this.SelectedNode.Tag
     $selectedDirectoryInput.Text = $directory_path
 
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
 
 $AddFoldersToSeenOffline = WhileReadSql "SELECT directory, useful_part_of_directory, parent_directory, folder FROM directories_ext_v dev WHERE search_directory_id = $searchDirectoryId AND directory_depth >= 1 ORDER BY directory_depth, directory"
 # Load all the subfolders
 
 while ($AddFoldersToSeenOffline.Read()) {                                                                                 
     $parentBranch = $parentDirectories[$parent_directory]
     $branchNode = New-Object System.Windows.Forms.TreeNode      
     $parentDirectories.Add($directory, $branchNode)
     $branchNode.Text = "$folder"
     $branchNode.Name = "$directory"
     $branchNode.Tag =  "$useful_part_of_directory"
     $parentBranch.Nodes.Add($branchNode)|Out-Null
 }
 
 $rootNode.Expand()
                        
 $treeView.EndUpdate()
 $form.Topmost = $True
 
 $form.BringToFront() # Required to get it on top, not just "TopMost"
 
 $result = $form.ShowDialog()
 
 if ($result -eq [System.Windows.Forms.DialogResult]::OK)
 {
     $x = $listBox.SelectedItem
     $x
 }
 
 . .\_dot_include_standard_footer.ps1

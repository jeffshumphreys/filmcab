<#
 #    FilmCab Daily morning batch run process: Track our nearness to filling up our space
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Conception
 #    ###### Sat Feb 3 22:20:01 MST 2024
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #>

 . .\_dot_include_standard_header.ps1
 
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form 
$form.Text = "Select a Computer"
$form.Size = New-Object System.Drawing.Size(900,400) 
$form.StartPosition = "CenterScreen"

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(75,120)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(150,120)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20) 
$label.Size = New-Object System.Drawing.Size(280,20) 
$label.Text = "Please select a computer:"
$form.Controls.Add($label) 

$listBox = New-Object System.Windows.Forms.ListBox 
$listBox.Location = New-Object System.Drawing.Point(10,40) 
$listBox.Size = New-Object System.Drawing.Size(260,20) 
$listBox.Height = 80

[void] $listBox.Items.Add("atl-dc-001")
[void] $listBox.Items.Add("atl-dc-002")
[void] $listBox.Items.Add("atl-dc-003")
[void] $listBox.Items.Add("atl-dc-004")
[void] $listBox.Items.Add("atl-dc-005")
[void] $listBox.Items.Add("atl-dc-006")
[void] $listBox.Items.Add("atl-dc-007")

$form.Controls.Add($listBox) 
                                                   
$treeView = New-Object System.Windows.Forms.TreeView
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 244
$System_Drawing_Size.Height = 300
$treeView.Size = $System_Drawing_Size
$treeView.Name = “treeView”
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 334
$System_Drawing_Point.Y = 37
$treeView.Location = $System_Drawing_Point
$treeView.DataBindings.DefaultDataSourceUpdateMode = 0
$treeView.TabIndex = 0
$form.Controls.Add($treeView)


$SearchPathToLookForOffloadables = WhileReadSql "SELECT search_directory_id, search_directory FROM search_directories_ext_v WHERE tag = 'published'"
                       
$SearchPathToLookForOffloadables.Read()|Out-Null
$searchDirectoryId = $search_directory_id

$treeView.Nodes.Clear()

$parentDirectories = New-Object 'system.collections.generic.dictionary[String, System.Windows.Forms.TreeNode]'

$rootNode = New-Object System.Windows.Forms.TreeNode      
$parentDirectories.Add($search_directory, $rootNode)
$rootNode.Text = "root"
$rootNode.Name = "$search_directory"
$rootNode.Tag =  "root"
$treeView.Nodes.Add($rootNode)

$AddFoldersToSeenOffline = WhileReadSql "SELECT directory_path, useful_part_of_directory_path, parent_directory FROM directories_ext_v dev WHERE search_path_id = $searchDirectoryId AND directory_depth >= 1 ORDER BY directory_depth"
# Load all the subfolders

while ($AddFoldersToSeenOffline.Read()) {                                                                                 
    $parentBranch = $parentDirectories[$parent_directory]
    $branchNode = New-Object System.Windows.Forms.TreeNode      
    $parentDirectories.Add($directory_path, $branchNode)
    $branchNode.Text = "$directory_path"
    $branchNode.Name = "$directory_path"
    $branchNode.Tag =  "useful_part_of_directory_path"
    $parentBranch.Nodes.Add($branchNode)
}

$form.Topmost = $True

$form.BringToFront() # Required to get it on top, not just "TopMost"
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $x = $listBox.SelectedItem
    $x
}





. .\_dot_include_standard_footer.ps1
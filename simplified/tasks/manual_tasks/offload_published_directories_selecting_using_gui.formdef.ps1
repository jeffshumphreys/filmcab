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
$CancelButton.Hide()|Out-Null # Has to be present so "X" closes.

########################################################################################################################################################################################################
$nodeContextMenu                         = New-Object System.Windows.Forms.ContextMenuStrip
$nodeContextMenuItem                     = New-Object System.Windows.Forms.ToolStripMenuItem("Exit")
$nodeContextMenuItem.Name                = "Edit File Record..."

<#~~~~~~~~~~~~~~~~~~~~#>$nodeContextMenu.Items.Add($nodeContextMenuItem)|Out-Null

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Column 1
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
$columnWidth1                            = 364
$treeViewWidth                           = $columnWidth1

########################################################################################################################################################################################################
$treeFilterToDirectoryComboBox           = New-Object System.Windows.Forms.ComboBox
$treeFilterToDirectoryComboBox.Location  = New-Object System.Drawing.Point(0, ($BUTTON_HEIGHT * 0))
$treeFilterToDirectoryComboBox.Size      = New-Object System.Drawing.Size($treeViewWidth, $BUTTON_HEIGHT)
$listOfFolders                           = Get-SqlArray "SELECT SUBSTRING(folder,2) tag FROM directories_ext_v WHERE directory_depth = 1 AND search_directory_tag = 'published' AND folder LIKE '\_%' AND folder NOT LIKE '\_\_%' ORDER BY 1"
$treeFilterToDirectoryComboBox.Items.AddRange($listOfFolders)|Out-Null

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($treeFilterToDirectoryComboBox)<#~~~~~~~~~~~~~~~~~~~~#>

########################################################################################################################################################################################################
$treeViewOfPublishedDirectories                  = New-Object System.Windows.Forms.TreeView
$treeViewOfPublishedDirectories.Location         = New-Object System.Drawing.Point(0,($BUTTON_HEIGHT * 1))
$treeViewOfPublishedDirectories.Size             = New-Object System.Drawing.Size($treeViewWidth, ($ScreenHeight - 17 - $BUTTON_HEIGHT))
$treeViewOfPublishedDirectories.CheckBoxes       = $true
$treeViewOfPublishedDirectories.TabIndex         = 0
$treeViewOfPublishedDirectories.ContextMenuStrip = $nodeContextMenu

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($treeViewOfPublishedDirectories)<#~~~~~~~~~~~~~~~~~~~~#>

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Column 2
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
$maxObjectWidth2                         = 400
$columnWidth2                            = $maxObjectWidth2 + ($HORIZONTAL_SPACER*2)

########################################################################################################################################################################################################
$leaveLinkInPlaceCheckBox                = New-Object System.Windows.Forms.CheckBox
$leaveLinkInPlaceCheckBox.Location       = New-Object System.Drawing.Point(($treeViewWidth + $HORIZONTAL_SPACER), ($BUTTON_HEIGHT * 1))
$leaveLinkInPlaceCheckBox.Size           = New-Object System.Drawing.Size(($columnWidth2), $BUTTON_HEIGHT)
$leaveLinkInPlaceCheckBox.CheckAlign     = 'MiddleRight'
$leaveLinkInPlaceCheckBox.TextAlign      = 'MiddleRight'
$leaveLinkInPlaceCheckBox.Text           = "Leave link in place"

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($leaveLinkInPlaceCheckBox)<#~~~~~~~~~~~~~~~~~~~~#>

########################################################################################################################################################################################################
$selectedMoveReasonLabel                 = New-Object System.Windows.Forms.Label
$selectedMoveReasonLabel.Location        = New-Object System.Drawing.Point(($treeViewWidth + $HORIZONTAL_SPACER), ($BUTTON_HEIGHT * 2))
$selectedMoveReasonLabel.Size            = New-Object System.Drawing.Size(($columnWidth2), $BUTTON_HEIGHT)
$selectedMoveReasonLabel.Text            = "Move Reason"

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($selectedMoveReasonLabel)<#~~~~~~~~~~~~~~~~~~~~#>

########################################################################################################################################################################################################
$selectedmoveReasonComboBox              = New-Object System.Windows.Forms.ComboBox
$selectedmoveReasonComboBox.Location     = New-Object System.Drawing.Point(($treeViewWidth + $HORIZONTAL_SPACER), ($BUTTON_HEIGHT * 3))
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
$maxObjectWidth4                         = 100
$columnWidth4                            = $maxObjectWidth4 + ($HORIZONTAL_SPACER*2)

########################################################################################################################################################################################################

# $activityAnimation                       = New-Object System.Windows.Forms.PictureBox
# $activityAnimation.Location              = New-Object System.Drawing.Point(($treeViewWidth + $HORIZONTAL_SPACER + $columnWidth2), ($BUTTON_HEIGHT * 4))
# $activityAnimation.Size                  = New-Object System.Drawing.Size(($columnWidth2), ($BUTTON_HEIGHT*3))
# $activityAnimation.SizeMode              = 'StretchImage'

# <#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($activityAnimation)<#~~~~~~~~~~~~~~~~~~~~#>

########################################################################################################################################################################################################
$RunningActivityLog                      = New-Object System.Windows.Forms.RichTextBox
$RunningActivityLog.Location             = New-Object System.Drawing.Point(($treeViewWidth + $HORIZONTAL_SPACER), ($BUTTON_HEIGHT * 7 + $VERTICAL_SPACER))
$RunningActivityLog.Size                 = New-Object System.Drawing.Size(($columnWidth2+$columnWidth3+$columnWidth4), ($BUTTON_HEIGHT*10))
$RunningActivityLog.ReadOnly             = $true
$RunningActivityLog.AutoScrollOffset     = 100
$RunningActivityLog.Text                 = ""

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($RunningActivityLog)<#~~~~~~~~~~~~~~~~~~~~#>

########################################################################################################################################################################################################
$MoveComments                            = New-Object System.Windows.Forms.RichTextBox
$MoveComments.Location                   = New-Object System.Drawing.Point(($treeViewWidth + $HORIZONTAL_SPACER), ($BUTTON_HEIGHT * 17 + $VERTICAL_SPACER))
$MoveComments.Size                       = New-Object System.Drawing.Size(($columnWidth2+$columnWidth3+$columnWidth4), ($BUTTON_HEIGHT*10))
$MoveComments.ReadOnly                   = $false
$MoveComments.AutoScrollOffset           = 100
$MoveComments.Text                       = ""

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($MoveComments)<#~~~~~~~~~~~~~~~~~~~~#>

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

#######################################################################################################################################################################################################
$sourceDirectorySize                     = New-Object System.Windows.Forms.Label
$sourceDirectorySize.Location            = New-Object System.Drawing.Point(($treeViewWidth + $HORIZONTAL_SPACER + $columnWidth2+ $columnWidth3b+$columnWidth3), ($BUTTON_HEIGHT * 2 + $VERTICAL_SPACER))
$sourceDirectorySize.Size                = New-Object System.Drawing.Size($columnWidth4, $BUTTON_HEIGHT)
$sourceDirectorySize.TextAlign           = [System.Drawing.ContentAlignment]::MiddleLeft

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($sourceDirectorySize)<#~~~~~~~~~~~~~~~~~~~~#>

#######################################################################################################################################################################################################
$moveIdLabel                     = New-Object System.Windows.Forms.Label
$moveIdLabel.Location            = New-Object System.Drawing.Point(($treeViewWidth + $HORIZONTAL_SPACER + $columnWidth2+ $columnWidth3b+$columnWidth3), ($BUTTON_HEIGHT * 3 + $VERTICAL_SPACER))
$moveIdLabel.Size                = New-Object System.Drawing.Size($columnWidth4, $BUTTON_HEIGHT)
$moveIdLabel.TextAlign           = [System.Drawing.ContentAlignment]::MiddleLeft

<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($moveIdLabel)<#~~~~~~~~~~~~~~~~~~~~#>

#######################################################################################################################################################################################################
$statusBarMessage                        = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusBarMessage.Size                   = New-Object System.Drawing.Size(107, 17)
$statusBarMessage.Text                   = "Testing........."

#######################################################################################################################################################################################################
$statusBar                               = New-Object System.Windows.Forms.StatusStrip
$statusBar.Dock                          = [System.Windows.Forms.DockStyle]::Bottom
$statusBar.ShowItemToolTips              = $true
$statusBar.Text                          = "<Doesn't show anywhere>"
$statusBar.Stretch                       = $true
$statusBar.SizingGrip                    = $false
$statusBar.LayoutStyle                   = [System.Windows.Forms.ToolStripLayoutStyle]::HorizontalStackWithOverflow

<#~~~~~~~~~~~~~~~~~~~~#>$statusBar.Items.Add($statusBarMessage)|Out-Null
<#~~~~~~~~~~~~~~~~~~~~#>$form.Controls.Add($statusBar)<#~~~~~~~~~~~~~~~~~~~~#>

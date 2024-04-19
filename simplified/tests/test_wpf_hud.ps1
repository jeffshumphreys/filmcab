<#
    Heads-Up Display (HUD) for scheduled tasks
#>
#$job = Start-Job -ErrorAction Ignore -ScriptBlock {

try {

    . .\_dot_include_standard_header.ps1

    . .\_dot_include_gui_tools.ps1


    #$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
    #$AssemblyLocation = Join-Path -Path $ScriptPath -ChildPath .
    #foreach ($Assembly in (Dir $AssemblyLocation -Filter *.dll)) {
        #    Write-Host "Assembly $($Assembly.Name)"
        #    [System.Reflection.Assembly]::LoadFrom($Assembly.fullName) | out-null
        #}
  
#Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing
Add-Type -AssemblyName PresentationFramework
                                                               
#$mainWindowXAMLText = BuildBaseXAML $STANDARD_MAH_WINDOW_BASE  "Scheduled Tasks Active, Recent, or Next Up"
$mainWindowXAMLText = BuildBaseXAML $STANDARD_WPF_WINDOW_BASE  "Scheduled Tasks Active, Recent, or Next Up"
#$mainWindowXAMLText

# https://learn.microsoft.com/en-us/dotnet/desktop/wpf/controls/how-to-display-data-by-using-gridviewrowpresenter?view=netframeworkdesktop-4.8

$mainWindowXAMLText = $mainWindowXAMLText.Replace('%%PRESENTATION_XAML%%', @"
    <ListView Name="listView" HorizontalAlignment="Stretch" VerticalAlignment="Top">
        <ListView.View>                          
            <GridView AllowsColumnReorder="true">
                <GridViewColumn>                 
                    <GridViewColumn.CellTemplate><DataTemplate><TextBlock Text="{Binding TaskName}" Foreground="Black"/></DataTemplate>
                    </GridViewColumn.CellTemplate>
                        <GridViewColumnHeader ToolTip="Wha">Task Name
                            <GridViewColumnHeader.ContextMenu>
                                <ContextMenu Name="LastNameContextMenu">
                                    <MenuItem Header="Ascending" />
                                    <MenuItem Header="Descending" />
                                </ContextMenu>
                            </GridViewColumnHeader.ContextMenu>
                        </GridViewColumnHeader>
                </GridViewColumn>
                <GridViewColumn Header="Status">        <GridViewColumn.CellTemplate><DataTemplate><TextBlock Text="{Binding Status}"      Foreground="Black"/></DataTemplate></GridViewColumn.CellTemplate></GridViewColumn>
                <GridViewColumn Header="Last Ran">      <GridViewColumn.CellTemplate><DataTemplate><TextBlock Text="{Binding LastRan}"     Foreground="Black"/></DataTemplate></GridViewColumn.CellTemplate></GridViewColumn>
                <GridViewColumn Header="Last Run Time"> <GridViewColumn.CellTemplate><DataTemplate><TextBlock Text="{Binding LastRunTime}" Foreground="Black"/></DataTemplate></GridViewColumn.CellTemplate></GridViewColumn>
                <GridViewColumn Header="Last Result">   <GridViewColumn.CellTemplate><DataTemplate><TextBlock Text="{Binding LastResult}"  Foreground="Black"/></DataTemplate></GridViewColumn.CellTemplate></GridViewColumn>
                <GridViewColumn Header="Next Run">      <GridViewColumn.CellTemplate><DataTemplate><TextBlock Text="{Binding NextRun}"     Foreground="Black"/></DataTemplate></GridViewColumn.CellTemplate></GridViewColumn>
                <GridViewColumn Header="How Many">      <GridViewColumn.CellTemplate><DataTemplate><TextBlock Text="{Binding HowManyRuns}" Foreground="Black"/></DataTemplate></GridViewColumn.CellTemplate></GridViewColumn>
            </GridView>
        </ListView.View>
    </ListView>
"@)

#$mainWindowXAMLText = $mainWindowXAMLText -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window' # Within the XAML the naming of variables can either be x:Name or Name, same with some of the Window elements. So Later on when we do the $xaml.SelectNodes() we are looking only for Name and then make a Powershell variable out of it. Also helps parse the XAML for the System.Xml.XmlNodeReader to then load the Xaml content. some of these items might also be needed for the C# compiler, but not Powershell
#$mainWindowXAMLText
[xml]$mainWindowXAML = $mainWindowXAMLText
$mainWindowXAMLreader = (New-Object System.Xml.XmlNodeReader $mainWindowXAML)
$mainWindow = [Windows.Markup.XamlReader]::Load($mainWindowXAMLreader)

$mainWindowXAML.SelectNodes("//*[@Name]") | ForEach-Object {
    #"trying item $($_.Name)";
    try {
        Set-Variable -Name "var_$($_.Name)" -Value $mainWindow.FindName($_.Name) -ErrorAction Stop
    } catch {
        throw
    }
}

#Get-Variable var_*

$ScheduledTaskDefsInSetOrder = WhileReadSql "
    SELECT
        scheduled_task_name
    ,   scheduled_task_path
    FROM
        scheduled_tasks_ext_v
    WHERE
        NOT repeat         
    ORDER BY               
        scheduled_task_run_set_id
    ,   order_in_set       
"                          

While ($ScheduledTaskDefsInSetOrder.Read()) {
    $taskRunDetail  = Get-ScheduledTaskInfo -TaskName "$scheduled_task_path"
    $lastRunTime    = $taskRunDetail.LastRunTime
    $lastTaskResult = $taskRunDetail.LastTaskResult
    $nextRunTime    = $taskRunDetail.NextRunTime

    $lastTaskResultMessage = "Success"
    if ($lastTaskResult -ne 0) {
        $lastTaskResultMessage = "Failed"
        # Set xaml line to red?
    }

    $lastRunTimeMessage = "?"

    # TODO: Scheduled to run time, event or calendar

    if ($lastRunTime -ge $Script:SnapshotMasterRunDate.Date) {
        $lastRunTimeMessage = "This Morning"
    } elseif ($lastRunTime -ge $Script:SnapshotMasterRunDate.Date.AddHours(-3) -and $lastRunTime -le $Script:SnapshotMasterRunDate.Date) {
        $lastRunTimeMessage = "Last Night"
    }
    
    [array]$lastTaskEvents = Get-LastEventsForTask "$scheduled_task_path" -howManyEvents 100 -LastRunOnly

    $var_listView.items.Add([pscustomobject]@{'TaskName'="$scheduled_task_name";Status="Pending";LastRan="$lastRunTimeMessage"; LastResult="$lastTaskResultMessage";NextRun="Tomorrow"})|Out-Null
}
    
$Null = $mainWindow.ShowDialog()

}
catch {
    Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}
finally {
    Write-AllPlaces "Finally"
    . .\_dot_include_standard_footer.ps1
}

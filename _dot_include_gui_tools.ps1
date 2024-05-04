<#
    FilmCab GUI library. .NET WinForms
    - Easiest for me to use
    - Would have to use Visual Studio for anything else. MAUI is cross-platform and ridiculously huge.
#>
#Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing
Add-Type -AssemblyName System.Windows.Forms

# https://learn.microsoft.com/en-us/dotnet/api/system.drawing.color?view=net-8.0

$slateBlue  = [System.Drawing.Color]::FromName("SlateBlue")
$Red        = [System.Drawing.Color]::FromName("Red")
$Green      = [System.Drawing.Color]::FromName("Green")
$Yellow     = [System.Drawing.Color]::FromName("Yellow")
$DarkYellow = [System.Drawing.Color]::FromName("DarkGoldenrod")
$Black      = [System.Drawing.Color]::FromName("Black")

$BoldFont   = [System.Drawing.Font]::new("Microsoft Sans Serif", 10, [System.Drawing.FontStyle]::Bold)
$ItalicFont = [System.Drawing.Font]::new("Microsoft Sans Serif", 10, [System.Drawing.FontStyle]::Italic)
$ItalicFont8 = [System.Drawing.Font]::new("Microsoft Sans Serif", 8, [System.Drawing.FontStyle]::Italic)
$NormalFont = [System.Drawing.Font]::new("Microsoft Sans Serif", 10)

$StartingColor = $DarkYellow
$SuccessColor = $Green
$FailColor = $Red

Function Get-TaskBarDimensions {
    param (
        [System.Windows.Forms.Screen]$Screen = [System.Windows.Forms.Screen]::PrimaryScreen
    )

    $device = ($Screen.DeviceName -split '\\')[-1]
    if ($Screen.Primary) { $device += ' (Primary Screen)' }

    if ($Screen.Bounds.Equals($Screen.WorkingArea)) {
        Write-Warning "Taskbar is hidden on device $device or moved to another screen."
        return
    }


    # calculate heights and widths for the possible positions (left, top, right and bottom)
    $ScreenRect  = $Screen.Bounds
    $workingArea = $Screen.WorkingArea
    $left        = [Math]::Abs([Math]::Abs($ScreenRect.Left) - [Math]::Abs($WorkingArea.Left))
    $top         = [Math]::Abs([Math]::Abs($ScreenRect.Top) - [Math]::Abs($workingArea.Top))
    $right       = ($ScreenRect.Width - $left) - $workingArea.Width
    $bottom      = ($ScreenRect.Height - $top) - $workingArea.Height

    if ($bottom -gt 0) {
        # TaskBar is docked to the bottom
        return [PsCustomObject]@{
            X        = $workingArea.Left
            Y        = $workingArea.Bottom
            Width    = $workingArea.Width
            Height   = $bottom
            Position = 'Bottom'
            Device   = $device
        }
    }
    if ($left -gt 0) {
        # TaskBar is docked to the left
        return [PsCustomObject]@{
            X        = $ScreenRect.Left
            Y        = $ScreenRect.Top
            Width    = $left
            Height   = $ScreenRect.Height
            Position = 'Left'
            Device   = $device
        }
    }
    if ($top -gt 0) {
        # TaskBar is docked to the top
        return [PsCustomObject]@{
            X        = $workingArea.Left
            Y        = $ScreenRect.Top
            Width    = $workingArea.Width
            Height   = $top
            Position = 'Top'
            Device   = $device
        }
    }
    if ($right -gt 0) {
        # TaskBar is docked to the right
        return [PsCustomObject]@{
            X        = $workingArea.Right
            Y        = $ScreenRect.Top
            Width    = $right
            Height   = $ScreenRect.Height
            Position = 'Right'
            Device   = $device
        }
    }
}

$ScreenWidth           = ([System.Windows.Forms.Screen]::PrimaryScreen|select -expand bounds|Select Width).Width;
$TaskBarHeight         = (Get-TaskBarDimensions).Height
$ScreenHeight          = ([System.Windows.Forms.Screen]::PrimaryScreen|select -expand bounds|Select Height).Height - $TaskBarHeight - 23;

Function BuildBaseXAML ($template, $title = "{title}") {
    return $template.Replace("%%TITLE%%", $title)
}

$STANDARD_WPF_WINDOW_BASE = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
    xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
    Title="%%TITLE%%"
    Height="800"
    Width="800"
    WindowStartupLocation="CenterScreen"
    ResizeMode="CanResizeWithGrip"
    >
    <Grid>
        %%PRESENTATION_XAML%%
        <StatusBar    x:Name="statusBar"                             HorizontalAlignment="Stretch"  VerticalAlignment="Bottom">
            <StatusBarItem Content="Item 1" Width="75"/>
            <StatusBarItem Content="Item 2" Width="112" />
            <StatusBarItem HorizontalAlignment="Right">
                <StackPanel Orientation="Horizontal">
                    <StatusBarItem  Content="Item 3" Width="92"/>
                    <StatusBarItem Content="Item 4" Width="114"/>
                    <ProgressBar Height="14" Width="210" IsIndeterminate="True" Margin="5,0"/>
                </StackPanel>
            </StatusBarItem>
        </StatusBar>
    </Grid>
</Window>
"@

$STANDARD_MAH_WINDOW_BASE = @"
<mah:MetroWindow
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
    xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
    xmlns:mah="http://metro.mahapps.com/winfx/xaml/controls"
    xmlns:iconPacks="http://metro.mahapps.com/winfx/xaml/iconpacks"
    mc:Ignorable="d"
    Title="%%TITLE%%"
    Height="800"
    Width="800"
    WindowStartupLocation="CenterScreen"
    GlowBrush="{DynamicResource MahApps.Brushes.Accent}"
    ResizeMode="CanResizeWithGrip"
>

    <Window.Resources>
        <ResourceDictionary>
            <ResourceDictionary.MergedDictionaries>
                <!-- MahApps.Metro resource dictionaries. Make sure that all file names are Case Sensitive! -->
                <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Controls.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Fonts.xaml" />
                <ResourceDictionary Source="D:\qt_projects\filmcab\simplified\tests\BureauBlack.xaml"/>
                <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Themes/Light.Blue.xaml" />
            </ResourceDictionary.MergedDictionaries>

            <Style TargetType="{x:Type CheckBox}">
                <Setter Property="Foreground" Value="Black"/>
            </Style>
        </ResourceDictionary>
    </Window.Resources>

    <Grid>
        %%PRESENTATION_XAML%%
        <StatusBar    x:Name="statusBar"                             HorizontalAlignment="Stretch"  VerticalAlignment="Bottom">
            <StatusBarItem Content="Item 1" Width="75"/>
            <StatusBarItem Content="Item 2" Width="112" />
            <StatusBarItem HorizontalAlignment="Right">
                <StackPanel Orientation="Horizontal">
                    <StatusBarItem  Content="Item 3" Width="92"/>
                    <StatusBarItem Content="Item 4" Width="114"/>
                    <ProgressBar Height="14" Width="210" IsIndeterminate="True" Margin="5,0"/>
                </StackPanel>
            </StatusBarItem>
        </StatusBar>
    </Grid>
</mah:MetroWindow>
"@
<#
    FilmCab GUI library. .NET WinForms
    - Easiest for me to use
    - Would have to use Visual Studio for anything else. MAUI is cross-platform and ridiculously huge.
#>
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Get-TaskBarDimensions {
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

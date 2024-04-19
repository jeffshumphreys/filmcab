#v Install-PackageProvider ChocolateyGet -Force
# https://github.com/jianyunt/ChocolateyGet
## ChocolateyGet is a Package Management (OneGet) provider that facilitates installing Chocolatey packages from any NuGet repository.

# http://vcloud-lab.com/entries/powershell/part-3-powershell-wpf-mahapps-metro-theme-step-by-step
<#

    WindowsPowerShell Compatibility Core PSModule PSEdition_Core
        D:\OneDrive\Documents\PowerShell\Modules\WindowsCompatibility\1.0.0
    PSRule
        D:\OneDrive\Documents\PowerShell\Modules\PSRule\2.9.0
    PSLogging
        D:\OneDrive\Documents\PowerShell\Modules\PSLogging\2.5.2
    PSExcel
        D:\OneDrive\Documents\PowerShell\Modules\PSExcel\1.0.2
    ImportExcel
        D:\OneDrive\Documents\PowerShell\Modules\ImportExcel\7.8.6
    PowerShellGet
        D:\OneDrive\Documents\PowerShell\Modules\PowerShellGet\2.2.5
    Pester
        D:\OneDrive\Documents\PowerShell\Modules\Pester\5.5.0
    Get-MediaInfo
        D:\OneDrive\Documents\PowerShell\Modules\Get-MediaInfo\3.7
    Foil
        D:\OneDrive\Documents\PowerShell\Modules\Foil\0.3.1
    ChocolateyGet
        D:\OneDrive\Documents\PowerShell\Modules\ChocolateyGet\4.1.0
    WpfAnimatedGif
    Wpf.Themes

    ControlzEx.dll
        C:\Program Files\PackageManagement\NuGet\Packages\ControlzEx.5.0.2\lib\netcoreapp3.1

    https://www.nuget.org/packages/MahApps.Metro

    https://mahapps.com/
    Could not load file or assembly 'Microsoft.Xaml.Behaviors, Version=1.1.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a'. The system cannot find the file specified.
#>


Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing

$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$AssemblyLocation = Join-Path -Path $ScriptPath -ChildPath .
foreach ($Assembly in (Dir $AssemblyLocation -Filter *.dll)) {
    Write-Host "Assembly $($Assembly.Name)"
    [System.Reflection.Assembly]::LoadFrom($Assembly.fullName) | out-null
}
$xamlFile = "D:\qt_projects\filmcab\simplified\tests\test_wpf_mahwindow.xaml"

$inputXML = Get-Content $xamlFile -Raw
$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window' # Within the XAML the naming of variables can either be x:Name or Name, same with some of the Window elements. So Later on when we do the $xaml.SelectNodes() we are looking only for Name and then make a Powershell variable out of it. Also helps parse the XAML for the System.Xml.XmlNodeReader to then load the Xaml content. some of these items might also be needed for the C# compiler, but not Powershell
[xml]$XAML = $inputXML
#Read XAML

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try {
            $window = [Windows.Markup.XamlReader]::Load( $reader )
}
catch {
    Write-Warning $_.Exception
    throw
}

# https://wpf-tutorial.com/list-controls/combobox-control/

$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    #"trying item $($_.Name)";
    try {
        $_.Name
        Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop
    } catch {
        throw
    }
}

Get-Variable var_*

#$var_label.Content = "Hi There!"
#$var_label.Foreground = "red"
#$var_textBox.BorderBrush = "red"
#$var_comboBox.AddText("Test")
$var_comboBox.Text = 'Red'

$Null = $window.ShowDialog()

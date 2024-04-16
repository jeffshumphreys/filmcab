# https://www.systanddeploy.com/2019/05/powershell-wpf-build-prerequisites-gui.html

# https://github.com/MahApps/MahApps.Metro
# https://github.com/MahApps/MahApps.Metro/wiki/Quick-Start

# http://vcloud-lab.com/entries/powershell/powershell-wpf-themes-guide-step-by-step

Add-Type -AssemblyName PresentationFramework

$xamlFile = "D:\qt_projects\filmcab\simplified\tests\test_wpf.xaml"

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

$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    #"trying item $($_.Name)";
    try {
        Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop
    } catch {
        throw
   }
}
    
Get-Variable var_*

$var_label.Content = "Hi There!"
$var_label.Foreground = "red"
$var_textBox.BorderBrush = "red"
$var_comboBox.AddText("Test")
$var_comboBox.AddText("Item 2")

$Null = $window.ShowDialog()


# https://www.systanddeploy.com/2019/11/powershell-and-wpf-how-to-use-animated.html
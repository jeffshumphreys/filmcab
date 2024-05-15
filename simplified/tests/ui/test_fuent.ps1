$source = @"
public class ConstructXAML
{
    public ConstructXAML() {
        constructedXAML = "";
    }

    public string constructedXAML = "";
    public ConstructXAML VerticalPanel()
    {
        constructedXAML = "<StackPanel Orientation=\"Vertical\">" + constructedXAML + "</StackPanel>";
        return this; 
    }
    public override string ToString() {
        return constructedXAML;
    }
}
"@

Add-Type -TypeDefinition $source -Language CSharp
$xaml = [ConstructXAML]::New()
$xaml.VerticalPanel()
$xaml.VerticalPanel()
$xaml.constructedXAML


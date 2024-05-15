$job = Start-Job -ScriptBlock {
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

    public ConstructXAML Border(int height = 40) {
        constructedXAML = `$"<Border BorderBrush={height}\" Margin=\"1,1,1,1\" VerticalAlignment=\"Top\" Width=\"132\">" + constructedXAML + "</Border>";
        return this; 
        
    }

    public override string ToString() {
        return constructedXAML;
    }
}
"@


Add-Type -TypeDefinition $source -Language CSharp
$xaml = [ConstructXAML]::New()
$xaml.VerticalPanel().Border(1)
}

Receive-Job $job -Wait


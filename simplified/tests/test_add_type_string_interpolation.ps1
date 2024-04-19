$job = Start-Job -ScriptBlock {
    $source = @"
    public class ConstructXAML
    {
        public ConstructXAML() {
            constructedXAML = "";
        }

        public string constructedXAML = "<!--xxx-->";

        public ConstructXAML VerticalPanel()
        {
            constructedXAML = "<StackPanel Orientation=\"Vertical\"><!--xxx--></StackPanel>";
            return this;
        }

        public ConstructXAML Border(int height = 40) {
            constructedXAML = constructedXAML.Replace("<!--xxx-->", `$"<Border BorderBrush={height}\" Margin=\"1,1,1,1\" VerticalAlignment=\"Top\" Width=\"132\"><!--xxx--></Border>");
            return this;

        }

        public ConstructXAML Label(string text) {
            constructedXAML = constructedXAML.Replace("<!--xxx-->", `$"<Label Content=\"{text}\"><!--xxx--></Label>");
            return this;

        }
        public override string ToString() {
            return constructedXAML;
        }
    }
"@


    Add-Type -TypeDefinition $source -Language CSharp
    $xaml = [ConstructXAML]::New()
    $xaml.VerticalPanel().Border(43).Label("Test")
    }

    Wait-Job $job
    Receive-Job $job


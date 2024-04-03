class TestThingy {
    [string]$test 
    TestThingy() {
        $this.test = 'ttttttt'
    }
    [bool] Read() {
        Write-Host "READ"
        
        return $true
    }
}

$x = [TestThingy]::new()

$x
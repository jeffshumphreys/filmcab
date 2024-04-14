#$scriptblock = {                                                                                                                  
Function load (
    $SourcePath
    ,$TargetPath                 
    ,$SourceBasePath
    ,$TargetBasePath
    ,[Switch]$dropSourceLastFolder

) {
    #$SourceFilesAndDirectories = Get-ChildItem -File -Recurse -Path "$($SourcePath)\$($Filename)" -ErrorAction SilentlyContinue
    Write-Host "`$SourcePath = $SourcePath"
    Write-Host "`$TargetPath = $TargetPath"
    $SourceFilesAndDirectories = Get-ChildItem -Recurse -LiteralPath "$SourcePath" -ErrorAction SilentlyContinue
                                  
    foreach ($fileOrDirectory in $SourceFilesAndDirectories)
    {                             
        $MeaningfulPartOfSourcePath = ($fileOrDirectory.FullName.Substring($SourceBasePath.Length).Trim("\"))
        Write-Host "`$MeaningfulPartOfSourcePath = $MeaningfulPartOfSourcePath"
        $NewlyConstructedTargetPath = "$($TargetBasePath)\$($MeaningfulPartOfSourcePath)"
        if ((Test-Path -LiteralPath $fileOrDirectory.FullName -PathType Container))
        {                         
            # For cases where directories are empty, we still want to move them over.
            Write-Host "Creating directory: $NewlyConstructedTargetPath"
            New-Item -Path $NewlyConstructedTargetPath -ItemType Directory -Force|Out-Null
        } else {                  
            Write-Host "Moving file to: $NewlyConstructedTargetPath"
            # Update richtextbox with appendtext(Color)
            # We want to use Move-Item because of space concerns when moving to the same spindle.  Huge moves of many files and directories could run out of space with Copy-Item
            Move-Item -LiteralPath $fileOrDirectory.FullName -Destination $NewlyConstructedTargetPath -Force|Out-Null
        }                         
    }                             
    Write-Host "`$SourcePath = $SourcePath"
                                  
    # This deletes the source     
    Remove-Item -LiteralPath $SourcePath -Force -Recurse -ErrorAction SilentlyContinue|Out-Null
}                                 
                                  
cls                               
$arguments = @("C:\Video AllInOne Testing\Move Types\ScriptBlock V1\from","C:\Video AllInOne Testing\Move Types\ScriptBlock V1\to", "C:\Video AllInOne Testing\Move Types\ScriptBlock V1\from", "C:\Video AllInOne Testing\Move Types\ScriptBlock V1")
$arguments = @("O:\Video AllInOne\_Mystery\Those Who Kill (Den som dræber) (2011,2014,2019-)","N:\Video AllInOne Seen\_Mystery", "O:\Video AllInOne", "N:\Video AllInOne Seen")
                                
#start-job -scriptblock $scriptblock -ArgumentList $arguments
load $arguments
#Get-Job | Receive-Job -Wait
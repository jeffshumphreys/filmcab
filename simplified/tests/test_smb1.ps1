Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
Get-SmbServerConfiguration
Set-SmbServerConfiguration -EnableSMB2Protocol $false
Set-SmbServerConfiguration -AnnounceServer $true

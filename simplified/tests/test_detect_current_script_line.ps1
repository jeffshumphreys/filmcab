[CmdletBinding()]
param()
Set-PSDebug -Trace 2
Write-Host
Write-Host 'test'
$MyInvocation|Select *
#$MyInvocation.MyCommand|Select *
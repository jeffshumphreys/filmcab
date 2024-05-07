<#
 #    FilmCab Daily morning batch run process: Fetch what qBittorrents are still active, stalled, or stuck downloading metadata.
 #    Called from Windows Task Scheduler, Task is in \FilmCab, Task name is same as file
 #    Status: Conception
 #
 #    https://github.com/jeffshumphreys/filmcab/tree/master/simplified
 #    https://github.com/andrewmolyneux/qbittorrent-powershell/blob/master/QBittorrent.psm1
 #>

 try {
    . .\_dot_include_standard_header.ps1

    Add-Type -ReferencedAssemblies ("Microsoft.Powershell.Commands.Utility") -TypeDefinition @"
        using System;
        using Microsoft.PowerShell.Commands;
        public struct QbtSession
        {
            public QbtSession(Uri UriIn)
            {
                Uri = UriIn;
                Session = new WebRequestSession();
            }
            public Uri Uri;
            public WebRequestSession Session;
        }
"@

    Function Join-Uri(
        [Parameter(Mandatory=$true)][Uri] $Uri,
        [Parameter(Mandatory=$true)][String] $Path) {
        $x = New-Object System.Uri ($Uri, $Path)
        $x.AbsoluteUri
    }

    Function Open-QbtSession {
        [CmdletBinding()]
        param(
            [Uri] $Uri = "http://localhost:8080",
            [String] $Username = "admin",
            [String] $Password = "adminadmin")

        $connectedAPISession = [QbtSession]::new($Uri)
        $Response = Invoke-WebRequest (Join-Uri $Uri login) -WebSession $connectedAPISession.Session -Method Post -Body @{username=$Username;password=$Password} -Headers @{Referer=$Uri}
        if ($Response.Content -ne "Ok.") {
            throw "Login failed: $($Response.Content)"
        }
        $connectedAPISession
    }

    $Uri      = $Script:SUPER_SECRET_SQUIRREL.super_secret_qbittorrent_webui_url
    $Username = $Script:SUPER_SECRET_SQUIRREL.super_secret_qbittorrent_webui_user
    $Password = $Script:SUPER_SECRET_SQUIRREL.super_secret_qbittorrent_webui_password

    $connectedAPISession = [QbtSession]::new($Uri)
    $Response = Invoke-WebRequest (Join-Uri $Uri login) -WebSession $connectedAPISession.Session -Method Post -Body @{username=$Username;password=$Password} -Headers @{Referer=$Uri}
    if ($Response.Content -ne "Ok.") {
        throw "Login failed: $($Response.Content)"
    }
    $connectedAPISession

}
catch {
Show-Error "Untrapped exception" -exitcode $_EXITCODE_UNTRAPPED_EXCEPTION
}
finally {
Write-AllPlaces "Finally"
. .\_dot_include_standard_footer.ps1
}

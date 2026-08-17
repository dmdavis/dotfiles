# net.ps1

function get {
    <#
    .SYNOPSIS
        Resumable download keeping the remote filename and timestamp.
    .DESCRIPTION
        curl.exe is called explicitly, never `curl`. Windows PowerShell 5.1
        aliased curl to Invoke-WebRequest, which takes entirely different
        arguments and returns an object rather than writing a file — the
        muscle memory is actively dangerous. PowerShell 7 dropped the alias,
        but being explicit costs nothing and survives a 5.1 session.
    #>
    curl.exe --continue-at - --location --progress-bar --remote-name --remote-time @args
}

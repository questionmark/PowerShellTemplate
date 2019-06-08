function Write-HelloWorld {
    <#
        .Synopsis
            A wrapper for various Write-* commands

        .Description
            This function facilitates writing Hello World! to a variety of streams
        
        .Example
            Write-HelloWorld -Stream Output
            Hello World!
    #>
    [CmdletBinding()]
    param(
        # The stream(s) to output the message to
        [ValidateSet('Output', 'Host', 'Information', 'Verbose', 'Warning', 'Error')]
        [Parameter(Mandatory)]
        [string[]]$Stream
    )
    process {
        foreach ($OutStream in $Stream) {
            & Write-$OutStream "Hello World!"
        }
    }
}
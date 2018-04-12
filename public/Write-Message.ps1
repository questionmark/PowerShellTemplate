function Write-Message {
    <#
        .Synopsis
            A wrapper for various Write-* commands

        .Description
            This function facilitates Hello World in a variety of streams
        
        .Example
            Write-Message -Stream Output
            Hello World!
    #>
    [CmdletBinding()]
    param(
        # The message to output
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Message = 'Hello World!',

        # The stream(s) to output the message to
        [ValidateSet('Output', 'Host', 'Information', 'Verbose', 'Warning', 'Error')]
        [Parameter(Mandatory)]
        [string[]]$Stream
    )
    process {
        foreach ($String in $Message) {
            foreach ($OutStream in $Stream) {
                & Write-$OutStream $String
            }
        }
    }
}
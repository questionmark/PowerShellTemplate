function InvokeDotnetNew {
    <#
        .Synopsis
            Calls dotnet new with any arguments provided to it

        .Example
            InvokeDotnetNew --install $Path

        .Example
            InvokeDotnetNew PowerShellModule --OutputPath $Path
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        $Arguments
    )
    process {
        dotnet new $Arguments
    }
}
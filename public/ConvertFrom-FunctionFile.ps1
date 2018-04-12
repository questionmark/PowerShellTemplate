function ConvertFrom-FunctionFile {
    <#
        .Synopsis
            Exports all functions from a PS*1 file and stores them in separate function files
        
        .Description
            Using AST, extracts all function definitions from specified files, and create
            a file per function within the module directory provided. This does not currently
            rewrite the specified file to import the module, nor remove the existing functions.

        .Link
            GetScriptFunctions

        .Example
            ConvertFrom-FunctionFile -Path .\functions.ps1 -OutputPath C:\Git\NewModule\ -Verbose
            VERBOSE: Created Public Function 'Test-PublicFunction'
            VERBOSE: Created Private Function 'TestPrivateFunction'
            WARNING: Could not overwrite existing file 'Private\GetScriptFunctions.ps1'. Please run with -Force to overwrite existing content.
    #>
    [CmdletBinding()]
    param(
        # Path to the file to convert
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript( {Test-Path -Path $_ -Filter '*.ps*1'} )]
        [string[]]$Path,

        # Path of the module to export functions to
        [Parameter(Mandatory)]
        [string]$ModulePath,

        # Any function -like this string will be created as a Public function
        [string]$PublicFilter = '*-*',

        # Forces overwriting of current files
        [switch]$Force
    )
    process {
        foreach ($Function in GetScriptFunctions -ScriptPath $Path) {
            $FunctionType = ('Private', 'Public')[$($Function.Name -like $PublicFilter)]
            try {
                $null = New-Item -Path "$ModulePath\$FunctionType" -Name "$($Function.Name).ps1" -Value $Function.Extent -Force:$Force -ErrorAction Stop
                Write-Verbose "Created Public Function '$($Function.Name)'"
            } catch {
                if ($_.Exception -like 'New-Item : Could not find a part of the path*') {
                    Write-Error "'$FunctionType' folder does not appear to exist. Run with -Force or create folder first."
                } else {
                    Write-Warning "Could not overwrite existing file '$($FunctionType)\$($Function.Name).ps1'. Please run with -Force to overwrite existing content."
                }
            }
        }
    }
}
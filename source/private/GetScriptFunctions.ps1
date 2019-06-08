function GetScriptFunctions {
    <#
        .Synopsis
            Outputs all functions within a Script or ScriptBlock.

        .Description
            Uses AST to retrieve all functions from a valid script file, 
            then outputs them all. Useful for dot-sourcing functions from 
            a file that also contains running code.

        .Example
            GetScriptFunctions -Export -ScriptPath .\testscript.ps1 | iex

        .Example
            (GetScriptFunctions -ScriptPath .\testscript.ps1).Count
            7

        .Example
            Get-ChildItem -Recurse -Filter *.ps1 | GetScriptFunctions | Set-Content 'functions.psm1'
    #>
    [OutputType([System.Management.Automation.Language.Ast[]])]
    param(
        # FilePath for script to analyse
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline, Position = 0)]
        [ValidateScript({Test-Path $_})]
        [Alias('PSPath')]
        [string[]]$ScriptPath,

        # To export the function(s) extent alone, or with full AST data
        [switch]$Export
    )
    process {
        foreach ($Item in Convert-Path $ScriptPath) {
            try {
                Write-Verbose "Analysing [$Item]"
                $Tokens, $Errors = @()

                $Script = [System.Management.Automation.Language.Parser]::ParseFile($Item, [ref]$Tokens, [ref]$Errors)

                $Errors | ForEach-Object {
                    Write-Error -Message $_ -ErrorAction Stop
                }
            } catch {
                Write-Error "Failed to parse File '$($Item)'.`n$_"
            }

            try {
                $functions = $Script.FindAll( {$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}, $true)
                Write-Verbose "Found $($functions.count) functions."
            } catch {
                Write-Error "Failed to find any functions in File '$($Item)'.`n$_"
            }
 
            if ($Export) {
                $functions.Extent
            } else {
                $functions
            }
        }
    }
}

function GetScriptFunctions {
    <#
        .SYNOPSIS
            Outputs all functions within a Script or ScriptBlock.

        .DESCRIPTION
            Uses AST to retrieve all functions from a valid script file, 
            then outputs them all. Useful for dot-sourcing functions from 
            a file that also contains running code.

        .EXAMPLE
            GetScriptFunctions -Export -ScriptPath .\testscript.ps1 | iex

        .EXAMPLE
            (GetScriptFunctions -ScriptPath .\testscript.ps1).Count
            7

        .EXAMPLE
            Get-ChildItem -Recurse -Filter *.ps1 | GetScriptFunctions | Set-Content 'functions.psm1'
    #>
    [OutputType([System.Management.Automation.Language.ScriptBlockAst[]])]
    [OutputType([System.Management.Automation.Language.FunctionDefinitionAst[]])]
    param(
        # FilePath for script to analyse
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline, Position = 0)]
        [ValidateScript( {Test-Path $_})]
        [Alias('FullName')]
        [IO.FileInfo[]]$ScriptPath,

        # To export the function(s) extent alone, or with full AST data
        [Switch]$Export
    )
    process {
        foreach ($Item in $ScriptPath) {
            try {
                Write-Verbose "Analysing [$Item]"
                $Script = [System.Management.Automation.Language.Parser]::ParseFile($Item, [ref]$null, [ref]$null)
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

InModuleScope -ModuleName "PowerShellTemplate" {
    # This file contains two (2) valid functions
    $script:FunctionTestFile = (Resolve-Path "$PSScriptRoot\..\data\FunctionTesting.ps1").Path
}

Describe "GetScriptFunctions" {
    Context "Parameter Validation" {
        $Parameters = InModuleScope -ModuleName PowerShellTemplate {(Get-Command GetScriptFunctions).Parameters}
        It "Requires ScriptPath as a Mandatory Parameter" {
            $Parameters['ScriptPath'].Attributes.Mandatory | Should Be $true
        }

        It "Allows Paths to be piped in as ScriptPath or FullName" {
            $Parameters['ScriptPath'].Attributes.ValueFromPipelineByPropertyName | Should Be $true
            $Parameters['ScriptPath'].Attributes.AliasNames | Should Be 'FullName'
        }
    }

    Context "Analysing Files" {
        InModuleScope -ModuleName "PowerShellTemplate" {
            $File = $script:FunctionTestFile

            It "Returns all functions in the file" {
                $Result = GetScriptFunctions -ScriptPath $File
                $Result.Count | Should Be 2
            }

            It "Doesn't return invalid functions" {
                (GetScriptFunctions -ScriptPath $File).Name -notcontains 'NotFunction' | Should Be $true
            }

            It "Correctly evaluates multiple Files" {
                $Result = GetScriptFunctions -ScriptPath @($File, $File)
                $Result.Count | Should Be 4
            }

            It "Accepts FullNames from the Pipeline" {
                $Result = $File | GetScriptFunctions
                $Result.Count | Should Be 2
            }
        }
    }

    Context "Function Output" {
        InModuleScope PowerShellTemplate {
            It "Outputs Full AST objects by default" {
                $Result = InModuleScope PowerShellTemplate {GetScriptFunctions -ScriptPath $script:FunctionTestFile}
                $Result | Should BeOfType [System.Management.Automation.Language.FunctionDefinitionAst]
            }
        }
    }
}
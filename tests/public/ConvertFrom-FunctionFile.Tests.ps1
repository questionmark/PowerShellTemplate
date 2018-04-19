# This file contains two (2) valid functions called TestFunction and Invoke-TestFunction
$script:FunctionTestFile =  "$PSScriptRoot\..\data\FunctionTesting.ps1"

Describe "ConvertFrom-FunctionFile" {
    Context "Parameter Validation" {
        $Parameters = (Get-Command ConvertFrom-FunctionFile).Parameters

        It "Requires Path as a Mandatory Parameter" {
            $Parameters['Path'].Attributes.Mandatory | Should Be $true
        }

        It "Requires ModulePath as a Mandatory Parameter" {
            $Parameters['ModulePath'].Attributes.Mandatory | Should Be $true
        }
    }

    Context "Converting a File into Functions" {
        # When running Pester tests, a temporary drive is made available - $TestDrive (or TestDrive:\)
        # We can use this to create temporary files, test against them, and they are then automatically removed at the end of testing.
        
        BeforeEach {
            $ModulePath = mkdir "$TestDrive\TestModule\$(New-Guid)"
            $null = mkdir "$ModulePath\public"
            $null = mkdir "$ModulePath\private"
        }

        It "Splits Functions with the Filter '*-*' by default" {
            ConvertFrom-FunctionFile -Path $script:FunctionTestFile -ModulePath $ModulePath

            (Get-ChildItem $ModulePath\Public).BaseName | Should Be 'Invoke-TestFunction'
            (Get-ChildItem $ModulePath\Private).BaseName | Should Be 'TestFunction'
        }

        It "Places both functions in public with the filter '*'" {
            ConvertFrom-FunctionFile -Path $script:FunctionTestFile -ModulePath $ModulePath -PublicFilter '*'

            (Get-ChildItem $ModulePath\Public).Count | Should Be 2
            (Get-ChildItem $ModulePath\Private).Count | Should Be 0
        }

        It "Places both functions in private with the filter '*-QM*'" {
            ConvertFrom-FunctionFile -Path $script:FunctionTestFile -ModulePath $ModulePath -PublicFilter '*-QM*'

            (Get-ChildItem $ModulePath\Public).Count | Should Be 0
            (Get-ChildItem $ModulePath\Private).Count | Should Be 2
        }

        It "Doesn't overwrite functions without -Force being applied" {
            ConvertFrom-FunctionFile -Path $script:FunctionTestFile -ModulePath $ModulePath -WarningAction SilentlyContinue
            ConvertFrom-FunctionFile -Path $script:FunctionTestFile -ModulePath $ModulePath -WarningAction SilentlyContinue -WarningVariable Warning

            $Warning | Should BeLike "Could not overwrite existing file*"
        }

        It "Overwrites functions when -Force is specified" {
            ConvertFrom-FunctionFile -Path $script:FunctionTestFile -ModulePath $ModulePath
            ConvertFrom-FunctionFile -Path $script:FunctionTestFile -ModulePath $ModulePath -Force -WarningVariable Warning

            $Warning | Should Be $null
        }
    }
}
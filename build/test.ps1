#requires -Modules Pester, PSScriptAnalyzer
[CmdletBinding()]
param(
    # Path(s) to add to PSModulePath before testing, to allow for dependencies and the built module
    [string[]]$ModulePathPrefix,

    # Folder to output TEST and COVERAGE report files to
    [string]$OutputDirectory = $(
        if ($env:System_TestsDirectory) {
            $env:System_TestsDirectory
        } else {
            (mkdir (Join-Path $env:TEMP "$(New-Guid)")).FullName
        }
    ),

    # Unique identifier for this test run. Used by output files.
    [string]$TestID = $(
        -join @(
            if ($env:Build_BuildName) {
                # check this shouldn't be DefinitionName
                $env:Build_BuildName
            } else {
                ([IO.FileInfo](Split-Path $PSScriptRoot)).BaseName
            }
            "-"
            if ($env:Build_BuildNumber) {
                $env:Build_BuildNumber
            } else {
                "$(New-Guid)"
            }
        )
    ),

    # Code Coverage Directory
    [string]$CodeCoverageDirectory = $(
        Split-Path $PSScriptRoot -Parent
    ),

    # If used, skips generating COVERAGE files
    [switch]$SkipCodeCoverage
)

if ($ModulePathPrefix) {
    $PreviousPSModulePath = $env:PSModulePath
    $env:PSModulePath = @(
        , $ModulePathPrefix
        $env:PSModulePath.Split([IO.Path]::PathSeparator).Where{ $_ -notin $ModulePathPrefix }
    ) -join [IO.Path]::PathSeparator
}

$TestArguments = @{
    Script     = Resolve-Path $PSScriptRoot\..\tests
    OutputFile = Join-Path $OutputDirectory "TEST-$($TestID).xml"
}

if (-not $SkipCodeCoverage -and $CodeCoverageDirectory) {
    $TestArguments += @{
        CodeCoverage           = (Get-ChildItem -Path $CodeCoverageDirectory -Recurse -Filter *.psm1).FullName
        CodeCoverageOutputFile = Join-Path $OutputDirectory "COVERAGE-$($TestID).xml"
    }
}

Invoke-Pester @TestArguments

Write-Verbose "Test Result Files have been output to '$($OutputDirectory)'"

if ($PreviousPSModulePath) {
    $env:PSModulePath = $PreviousPSModulePath
}
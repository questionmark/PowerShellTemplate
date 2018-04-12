[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
param()

$global:ModuleUnderTest = Split-Path (Split-Path $PSScriptRoot -Parent) -Leaf

if (!(Get-Module $global:ModuleUnderTest -ErrorAction SilentlyContinue)) {
    Import-Module $global:ModuleUnderTest -Scope Global
}

if ($QMBuild = Get-Module QMBuild -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1) {
    Write-Verbose "Running Script Analyzer common tests for $($global:ModuleUnderTest)"
    $CommonTests = Join-Path $QMBuild.ModuleBase CommonTests\Module.Tests.ps1
    if (Test-Path $CommonTests) {
        . $CommonTests
    }
}

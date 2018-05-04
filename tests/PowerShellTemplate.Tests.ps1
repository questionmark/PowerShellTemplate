$ModuleUnderTest = ([IO.FileInfo]$MyInvocation.InvocationName).BaseName.Remove('.Tests')

if (!(Get-Module $ModuleUnderTest -ErrorAction SilentlyContinue)) {
    Import-Module $ModuleUnderTest -Scope Global
}

if ($QMBuild = Get-Module QMBuild -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1) {
    Write-Verbose "Running Script Analyzer common tests for $($ModuleUnderTest)"
    $CommonTests = Join-Path $QMBuild.ModuleBase CommonTests\Module.Tests.ps1
    if (Test-Path $CommonTests) {
        . $CommonTests -ModuleUnderTest $ModuleUnderTest
    }
}

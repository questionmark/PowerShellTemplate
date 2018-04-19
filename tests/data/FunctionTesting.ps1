# This code contains two valid functions
function TestFunction {
    Write-Verbose 'This is a test function'
}

function Invoke-TestFunction {
    TestFunction
}

Write-Verbose 'This is a call that is not within a function'
Invoke-TestFunction  # It should not be output anywhere

<#
    function NotFunction {
        This is in a comment, and is not a function to export
    }
#>
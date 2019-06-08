# PowerShellTemplate

Description of PowerShellTemplate's purpose

## Requirements

PowerShellTemplate requires the following modules to be available:

| ModuleName | ModuleVersion |
| ---------- | ------------- |
|            |               |

## Building PowerShellTemplate

To build PowerShellTemplate locally, run the following code:

```PowerShell
Optimize-Module -Path $ModulePath -Output $ModulePath\$Version -ModuleVersion $Version
```

## Testing PowerShellTemplate

To test PowerShellTemplate locally, run the following code:

```PowerShell
Import-Module $ModulePath

$TestParameters = @{
    Script = $ModulePath\tests
    CodeCoverage = (Get-ChildItem $ModulePath\$Version -Filter *.psm1).FullName
}

Invoke-Pester @TestParameters
```

## Version

| Version | Changes                |
| ------- | ---------------------- |
| 0.0.0.0 | Basic module structure |
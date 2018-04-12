# CloneModule

Description of CloneModule's purpose

## Requirements

CloneModule requires the following modules to be available:

| ModuleName | ModuleVersion |
| ---------- | ------------- |
|            |               |

## Building CloneModule

To build CloneModule locally, run the following code:

```PowerShell
Optimize-Module -Path $ModulePath -Output $ModulePath\$Version -ModuleVersion $Version
```

## Testing CloneModule

To test CloneModule locally, run the following code:

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
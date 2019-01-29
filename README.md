# PowerShellTemplate

This is an example module, following some good practices.

## How to use this Exemplar

For the sake of examples below, we will have cloned this repository to `C:\Source\PowerShellTemplate`, and be creating a module named "TestModule" at the path `C:\Source\TestModule`.

### Creating a New Module

Depending on the availability of `dotnet`, you can either use `dotnet new` or perform a naive clone of the directory (replacing all instances of 'CloneModule' with your module name, and editing the GUIDs and other fields in the PSD1 appropriately).

The blank template accepts several options.

|    Option     |                Description                |
| ------------- | ----------------------------------------- |
| --ModuleName  | Name of the new module                    |
| --Author      | Module author, in the PSD1                |
| --Company     | Company and Copyright fields, in the PSD1 |
| --Description | Description field, in the PSD1            |
| --output      | Path to output. Defaults to PWD.          |

If you have `dotnet` version 2.0 or above installed, you can run the following code:

```PowerShell
dotnet new --install C:\Source\PowerShellTemplate\
dotnet new PowerShellModule --ModuleName TestModule --Author $env:UserName --Company $CompanyName --Description $DescriptionOfModule --output C:\Source\TestModule
```

> Please note that dotnet is case sensitive, so --Output will fail to be parsed.

If you don't have dotnet installed, you can install the dotnet SDK for version 2.0 or above.

### Populating the Module with Functions

`Optimize-Module` creates a single psm1 file from all .ps1 files in folders that aren't specified in CopyDirectories.

We recommend creating a single `FunctionName.ps1` file per function, laid out in public and private folders.

To simplify conversion from a lengthy PowerShell file containing multiple functions to a module, you can call `ConvertFrom-FunctionFile` to create separate files for each function in a given file.

```PowerShell
ConvertFrom-FunctionFile -Path C:\Source\RefactorProject\SomeScript.ps1 -ModulePath C:\Source\TestModule
```

### Classes and Initialization

Classes, enums, and other module prerequisites should be placed in the classes folder. We name these with a digit-prefix (e.g. `00-init.ps1`, `10-ClassDependency.ps1`, `20-SampleClass.ps1`, etc), such that they can be ordered appropriately, and added to the top of the resultant psm1 file.

## Writing PowerShell Modules

### Guidelines

For some best practices regarding PowerShell, we recommend reading the [PoshCode Practice and Style guide](https://github.com/PoshCode/PowerShellPracticeAndStyle). Though not complete, it has a good selection of recommendations.

Within Questionmark, we suggest following the guidelines from the [Patterns and Practices document](https://questionmark365.sharepoint.com/employeewiki/OneTeam%20Wiki/Questionmark%20PowerShell%20Patterns%20and%20Practices.aspx) in order to have a company-wide standard. In short:

Formatting:

- Use [One True Brace Style](https://en.wikipedia.org/wiki/Indent_style#Variant:_1TBS_.28OTBS.29)
- Use [Pascal Casing](https://en.wikipedia.org/wiki/PascalCase) unless PowerShell has a previously established case (e.g. $env:USERNAME)
- Use 4-space indentation
- If there is more than one parameter, named parameters should be used instead of positional parameters
  (e.g. `Register-PSRepository -Name Test -SourceLocation C:\Temp` instead of `Register-PSRepository Test C:\Temp`)
- Aliases must not be used, instead expanded to the full command name
- Functions must have valid comment-based help, including (at minimum) a synopsis, parameter help, and working examples

Structure:

- Ensure all Public functions have valid names (i.e. using Verb-Noun format with a [supported Verb](https://msdn.microsoft.com/en-us/library/ms714428(v=vs.85).aspx))
  - `New-` commands must throw an error if the object already exists
  - `Set-` commands must throw an error if the object does not exist
  - `Add-` commands must gracefully create and/or update the object
- Functions should support pipelining
- Functions must use `[CmdletBinding()]` to facilitate use of Verbose and Debug

I/O:

- Avoid `Read-Host`, as it clashes with automation
- Functions should specify their output object type with `[OutputType()]`

### Folder Structure

```
\--ModuleFolder
   |--classes                   # OPTIONAL: Can contain class / enum definition ps1 files
   |--data                      # OPTIONAL: Can contain data used by the module
   |--private                   # Contains private function definitions
   |--public                    # Contains public function definitions
   |--tests
      |--classes                # OPTIONAL: Tests for items defined in classes folder
      |--data                   # OPTIONAL: Can contain data used by tests
      |--private                # Tests for private functions
      |--public                 # Tests for public functions
      \--ModuleName.Test.ps1    # Module level tests, including ScriptAnalyzer
   |--build.psd1                # PSD1 containing arguments for Optimize-Module
   |--ModuleName.psd1           # PSD1 containing module data
   \--README.md                 # A readme, containing useful information about the module
```

## Writing Tests for PowerShell Modules

You should use Pester for PowerShell unit-testing.

At a minimum, each function must have tests for every ParameterSet, and the module should run the shared ScriptAnalyzer tests.

## Building PowerShell Modules

This section covers building the module locally. For CI builds in Visual Studio Online, please refer to [VSO Builds](./VSO_Builds.md)

To build PowerShellTemplate locally, run the following code:

```PowerShell
Optimize-Module -Path C:\Source\TestModule -Output C:\Source\TestModule\$Version -ModuleVersion $Version
```

## Testing PowerShell Modules

To test a module locally, you can run the following code:

```PowerShell
Import-Module C:\Source\TestModule

$TestParameters = @{
    Script = C:\Source\TestModule\tests
    CodeCoverage = (Get-ChildItem C:\Source\TestModule\$Version -Filter *.psm1).FullName
}

Invoke-Pester @TestParameters
```

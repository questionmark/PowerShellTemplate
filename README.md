# PowerShellTemplate

This is an example module, following some good practices.

## How to use this Exemplar

### Creating a New Module

To build this module, run `Optimize-Module` on the module directory.  # TODO: link to [publicly available version?](https://gist.github.com/Jaykul/176c4aacc477a69b3d0fa86b4229503b#file-optimize-module-ps1) <- missing update-metadata / get-metadata

You should then be able to import the module, and run `New-PSModule` which clones the base structure of an example module.

You can use this as follows:

```PowerShell
New-PSModule -Name Questionmark.Test.Module -Path ~\Git\
```

Depending on the availability of `dotnet`, this will either use `dotnet new` or perform a naive clone of the directory (replacing all instances of 'CloneModule' with your module name, and editing the PSD1 appropriately).

Alternatively, you can manually clone the folder structure (excluding `.template.config`) from `.\data\CloneModule`.

You will then need to manually edit the PSD1 values, and replace all references to CloneModule with your preferred module name.

### Populating the Module with Functions

`Optimize-Module` creates a single psm1 file from all .ps1 files in folders that aren't specified in CopyDirectories.

We recommend creating a single `FunctionName.ps1` file per function, laid out in public and private folders.

To simplify conversion from a lengthy PowerShell file containing multiple functions to a module, you can call `ConvertFrom-FunctionFile` to create separate files for each function in a given file.

```PowerShell
ConvertFrom-FunctionFile -Path ~\Git\RefactorProject\SomeScript.ps1 -ModulePath ~\Git\Questionmark.Test.Module
```

### Classes and Initialization

Classes, enums, and other module prerequisites should be placed in the classes folder. We name these with a digit-prefix (e.g. `00-init.ps1`, `10-ClassDependency.ps1`, `20-SampleClass.ps1`, etc), such that they can be prioritised appropriately and will be added in order at the top of the resultant psm1 file.

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
   |--README.md                 # A readme, containing useful information about the purpose and running of the module
```

## Testing PowerShell Modules

Forge uses Pester for PowerShell unit-testing.

At a minimum, each function must have tests for every ParameterSet, and the module should run the shared ScriptAnalyzer tests.

## Building PowerShell Modules

An example build is available in [Builds\Platform\PowerShellTemplate](https://qmdevteam.visualstudio.com/Core/Forge/_build/index?definitionId=1614).

QMBuild is available on hosted build machines and the QM PowerShell feed.  

To build and sign the module, you should create a PowerShell script similar to the following code:

```PowerShell
#Requires -Modules QMBuild

Optimize-Module -Path $env:Build_SourcesDirectory -Destination $env:Build_StagingDirectory -ModuleVersion $env:Build_BuildNumber
Get-ChildItem $env:Build_StagingDirectory -Recurse | Add-QMSignatureToScript
```

Forge has created a task group that handles this, titled `Build PowerShell Module`.

### Unit Testing during Builds

For this, you can either create a PowerShell script and run it from a script-step, or use the [Pester Test Runner Build Task](https://marketplace.visualstudio.com/items?itemName=richardfennellBM.BM-VSTS-PesterRunner-Task).

#### Custom Script

You can run Pester manually by creating a PowerShell build task and entering code similar to the following:

```PowerShell
$PesterParameters = @{
    Script = "$($env:Build_SourcesDirectory)\Tests"
    OutputFile = "$($env:Common_TestResultsDirectory)\Test-$($env:Build_DefinitionName)_$($env:Build_BuildNumber).xml"
    CodeCoverage = (Get-ChildItem $($env:Build_StagingDirectory) -Filter *.psm1).FullName
    CodeCoverageOutputFile = "$($env:Common_TestResultsDirectory)\Coverage-$($env:Build_DefinitionName)_$($env:Build_BuildNumber).xml"
    CodeCoverageOutputFileFormat = 'JaCoCo'
    PassThru = $true
}

$Result = Invoke-Pester @PesterParameters

exit $Result.FailedCount
```

#### Pester Test Runner

You can also use the pre-made build task. Configure it as follows:

| Setting            | Value                                                                                    |
| ------------------ | ---------------------------------------------------------------------------------------- |
| Scripts Folder     | $(Build.SourcesDirectory)\Tests                                                          |
| Results File       | $(Common.TestResultsDirectory)\Test-$(Build.DefinitionName)_$(Build.BuildNumber).xml     |

If you have specified an output file, you can then add the test results to the build by using the `Publish Test Results to VSTS/TFS` build task. 

After adding the `Publish Test Results` build task, configure it as follows:

| Setting            | Value                                                                   |
| ------------------ | ----------------------------------------------------------------------- |
| Test result format | NUnit                                                                   |
| Test results files | **\Test-*.xml                                                           |
| Search Folder      | $(Common.TestResultsDirectory)                                          |
| Run this task      | Even if a previous task has failed, unless the deployment was cancelled |

Forge has created a task group that handles this, titled `Test PowerShell Module`.

### Code Coverage during Builds

If running Pester 4.0.3 or higher, you can specify a CodeCoverageOutputFile, which you can then add to the build using the `Publish Code Coverage Result` build task.

This step is covered within the task group `Test PowerShell Module`.

If using the Pester Test Runner build task separately, you should configure options in the Test Runner step to include the following:

| Setting                   | Value                                                                                    |
| ------------------------- | ---------------------------------------------------------------------------------------- |
| Code Coverage Output File | $(Common.TestResultsDirectory)\Coverage-$(Build.DefinitionName)_$(Build.BuildNumber).xml |
| Pester Version            | 4.3.1                                                                                    |
| Force the use of a Pester Module shipped within this task | ✓ |

To upload the file, you should then add the `Publish Code Coverage Result` step to your build, with the following options:

| Setting            | Value                                         |
| ------------------ | --------------------------------------------- |
| Code coverage tool | JaCoCo                                        |
| Summary file       | Path set in `Code Coverage Output File` above |

### Packaging Artifacts

Forge has created a task group that handles these steps, titled `Publish PowerShell Module`.

#### ZIP

Creating an archive of the module is simple. 

```PowerShell
[IO.DirectoryInfo]$Module = $($env:Build_StagingDirectory)\$ModuleName
Compress-Archive -Path $Module.FullName -DestinationPath ("$($env:Build_StagingDirectory)\" + $Module.Name + '_' + $(env:Build_BuildNumber) + ".zip")
```

#### NUPKG 

Creating an installable nupkg is more involved. We recommend registering a local package source temporarily, and using the PowerShellGet `Publish-Module` function to create the nupkg there.

```PowerShell
$RepoName = (New-Guid).Guid
$Location = "$($env:Temp)\$RepoName"

if (-not [bool](Get-PackageSource -Location $Location)) {
  Register-PackageSource -Name $RepoName -Location $Location -ProviderName PowerShellGet
}

[IO.DirectoryInfo]$Module = $($env:Build_StagingDirectory)\$ModuleName
Publish-Module -Path $Module -Repository $RepoName

Unregister-PackageSource -Location $Location
```

### Publishing Artifact

To publish the built artifacts to the build, add a `Publish Build Artifacts` build task to the build.

Configure it with the following options:

| Setting                   | Value                                         |
| ------------------------- | --------------------------------------------- |
| Path to Publish           | $(Build.StagingDirectory)                     |
| Artifact Name             | Module                                        |
| Artifact publish location | Visual Studio Team Services/TFS               |

You can, alternatively, configure this to publish to a file share.

### Publishing to Nuget Feed


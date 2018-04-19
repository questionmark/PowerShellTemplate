# VSO Builds

## JSON Builds

The current standard for building in Visual Studio Online

### JSON Build Variables

JSON builds support lots of predefined variables in build tasks. 

Use of these variables varies between build task settings and PowerShell environments.

|          JSON Build            |      PowerShell Environment      |                     Notes                      |
| ------------------------------ | -------------------------------- | ---------------------------------------------- |
| $(Build.SourcesDirectory)      | $env:Build_SourcesDirectory      | Location of files downloaded in Get sources    |
| $(Build.BuildDefinitionName)   | $env:Build_BuildDefinitionName   | Name of the build                              |
| $(Build.BuildNumber)           | $env:Build_BuildNumber           | This is the build number set in Options        |
| $(Build.StagingDirectory)      | $env:Build_StagingDirectory      | Synonymous with Build.ArtifactStagingDirectory |
| $(Build.SourceBranch)          | $env:Build_SourceBranch          | Full source branch. Useful to see build type   |
| $(Common.TestResultsDirectory) | $env:Common_TestResultsDirectory |                                                |

Further information is available on [docs.microsoft.com](https://docs.microsoft.com/en-us/vsts/build-release/concepts/definitions/build/variables?tabs=batch&view=vsts)

### Building the Module with JSON

Questionmark has an example build available in [Builds\Platform\PowerShellTemplate](https://qmdevteam.visualstudio.com/Core/Forge/_build/index?definitionId=1614).

For this process, we use `Optimize-Module` (included in QMBuild), which was the precursor to `Build-Module` (found in [ModuleBuilder](https://github.com/poshcode/modulebuilder)).

To build and sign the module, you should create a PowerShell script similar to the following code:

```PowerShell
#Requires -Modules QMBuild

Optimize-Module -Path $env:Build_SourcesDirectory -Destination $env:Build_StagingDirectory -ModuleVersion $env:Build_BuildNumber
Get-ChildItem $env:Build_StagingDirectory -Recurse | Add-QMSignatureToScript
```

We have created a task group that handles this, titled `Build PowerShell Module`. It contains a Build Module(s) and Sign step.

### Unit Testing during JSON Builds

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

We have created a task group that handles this, titled `Test PowerShell Module`. It contains a Pester Test Runner step, and separate Publish Test Result and Publish Code Coverage Result steps.

### Code Coverage during JSON Builds

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

We have created a task group that handles these steps, titled `Publish PowerShell Module`. It contains steps to package the module, and publish the zip to the build - only publishing the nupkg if it's a release branch.

#### ZIP

Creating an archive of the module is simple. 

```PowerShell
[IO.DirectoryInfo]$Module = $($env:Build_StagingDirectory)\$ModuleName
Compress-Archive -Path $Module.FullName -DestinationPath ("$($env:Build_StagingDirectory)\" + $Module.Name + '_' + $(env:Build_BuildNumber) + ".zip")
```

#### NUPKG 

Creating an installable nupkg is more involved. We recommend registering a local package source temporarily, and using the PowerShellGet `Publish-Module` function to create the nupkg there.

```PowerShell
#Requires -Modules PackageManagement, PowerShellGet

$RepoName = (New-Guid).Guid
$Location = $($env:Build_BinariesDirectory)

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

You can also configure this to publish to a file share by changing the `Artifact publish location`.

### Publishing to Nuget Feed

To publish NUPKG files to a release feed from a VSTS build, we suggest using the `NuGet` build task.

| Setting                             | Value                                                                                |
| ----------------------------------- | ------------------------------------------------------------------------------------ |
| Command                             | push                                                                                 |
| Path to NuGet package(s) to publish | $(Build.BinariesDirectory)/*.nupkg                                                   |
| Target feed                         | PowerShell (or appropriate feed)                                                     |
| Allow duplicates to be skipped      | ✓                                                                                    |
| Run this task                       | Custom conditions                                                                    |
| Custom condition                    | and(succeeded(), startsWith(variables['Build.SourceBranch'], 'refs/heads/release/')) |

Once a given version of a package has been uploaded to the nuget feeds, you can **not** modify or overwrite it.

The custom run condition will ensure this only publishes to the feed when the source branch is a /release/* branch.
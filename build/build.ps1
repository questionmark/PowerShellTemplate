#requires -Modules ModuleBuilder
[CmdletBinding()]
param(
    # Module Source Directory. Builds all modules with a build.psd1 within this path (as used by ModuleBuilder)
    [string]$SourcesDirectory = $(
        if ($env:Build_SourcesDirectory) {
            $env:Build_SourcesDirectory
        } else {
            Split-Path $PSScriptRoot
        }
    ),

    # Output directory for versioned module.
    [string]$Destination = $(
        if ($env:Build_BinariesDirectory) {
            $env:Build_BinariesDirectory
        } else {
            Split-Path $PSScriptRoot
        }
    ),

    # Version to build
    [string]$NuGetVersion = $(
        if (Get-Command gitversion -ErrorAction Ignore) {
            gitversion $SourcesDirectory -showvariable NuGetVersion
        }
    )
)

if (-not (Test-Path $Destination -PathType Container)) {
    $null = New-Item -Path $Destination -ItemType Directory -Force
}

Get-ChildItem -Path $SourcesDirectory -Recurse -Filter build.psd1 | ForEach-Object {
    $ModuleName = [IO.Path]::GetFileNameWithoutExtension((Import-LocalizedData -BaseDirectory $_.Directory.FullName -FileName $_.Name).Path)

    $Module = @{
        Path        = $_.FullName
        Destination = $Destination
    }

    if ((Split-Path $Module.Destination -Leaf) -ne $ModuleName) {
        $Module.Destination = Join-Path $Module.Destination $ModuleName
    }

    Build-Module @Module -VersionedOutputDirectory -SemVer $NugetVersion
}
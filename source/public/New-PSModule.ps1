function New-PSModule {
    <#
        .Synopsis
            Creates a new module from the data stored in CloneModule
        
        .Description
            Using either dotnet new (if available) or a naive copy of the CloneModule folder

        .Link
            InvokeDotnetNew

        .Example
            New-PSModule -Name 'Questionmark.New.Module' -Path C:\Temp\Modules\
    #>
    [CmdletBinding()]
    param(
        # The name for the generated module
        [Parameter(Mandatory)]
        [Alias('Name')]
        [string]$ModuleName,

        # The author of the generated module
        [string]$Author = $env:UserName,

        # The company of the generated module
        [string]$Company,

        # The path to create the module in
        [Parameter(Mandatory)]
        [string]$Path
    )
    process {
        $ModulePath = Join-Path $Path $ModuleName

        if (-not (Get-Command -Name dotnet -ErrorAction SilentlyContinue)) {
            # This function requires dotnet new to function.
            throw "New-PSModule requires dotnet. Please ensure it is available on PATH before retrying."
        }

        if (-not (Test-Path $ModulePath)) {
            $null = New-Item -Path $ModulePath -ItemType Directory -Force
        }

        # Because mocking direct calls is unsupported, we have wrapped dotnet in a private function, so we can test it
        $null = InvokeDotnetNew --install (Get-Module 'PowerShellTemplate').ModuleBase
        InvokeDotnetNew PowerShellModule --output $ModulePath --ModuleName $ModuleName --Author $AuthorName --Company $CompanyName | Write-Verbose
        
    }
}
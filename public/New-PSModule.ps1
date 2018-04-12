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
        $ClonePath = Join-Path (Get-Module 'PowerShellTemplate').ModuleBase "\data\CloneModule"
        $ModulePath = Join-Path $Path $ModuleName

        if (-not (Test-Path $ModulePath)) {
            $null = New-Item -Path $ModulePath -ItemType Directory -Force
        }
        
        if (Get-Command -Name dotnet -ErrorAction SilentlyContinue) {
            # Because mocking direct calls is unsupported, we have wrapped dotnet in a private function, so we can test it
            $null = InvokeDotnetNew --install $ClonePath
            InvokeDotnetNew PowerShellModule --output $ModulePath --ModuleName $ModuleName --Author $AuthorName --Company $CompanyName | Write-Verbose
        } else {
            # Copy files
            Copy-Item -Path $ClonePath\* -Container -Destination $ModulePath -Force -Recurse

            # Remove placeholders and other unnecessary files
            $FilesToRemove = @('.template.config', 'placeholder')
            Get-ChildItem -Path $ModulePath -Recurse -Include $FilesToRemove | Remove-Item -Recurse -Force

            # Rename ModuleName files
            Get-ChildItem -Path $ModulePath -Filter 'CloneModule*' -Recurse | ForEach-Object { 
                Rename-Item -Path $PSItem.FullName -NewName $PSItem.Name.Replace('CloneModule', $ModuleName)
            }

            # Edit PSD1 inelegantly
            $Psd1File = Join-Path $ModulePath "$($ModuleName).psd1"
            $Json = Get-Content $ClonePath\.template.config\template.json | ConvertFrom-Json

            @(
                @{
                    String      = $Json.guids[0]
                    Replacement = (New-Guid).Guid
                }
                # This assumes that there's a named parameter for each symbol in the template file
                foreach ($type in $Json.Symbols.PsObject.Properties.Name) {
                    @{
                        String      = $Json.Symbols.$type.replaces
                        Replacement = if ($Set = (Get-Variable -Name $Type -ErrorAction SilentlyContinue).Value) {$Set} else {$Json.Symbols.$type.DefaultValue}
                    }
                }
            ) | ForEach-Object {
                (Get-Content -Path $Psd1File).Replace($_.String, $_.Replacement) | Set-Content -Path $Psd1File
            }
        }
    }
}
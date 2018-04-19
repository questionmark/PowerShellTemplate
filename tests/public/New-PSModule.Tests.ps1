Describe "New-PSModule" {
    Context "Parameter Validation" {
        $Parameters = (Get-Command New-PSModule).Parameters

        It "Requires ModuleName as a Mandatory Parameter" {
            $Parameters['ModuleName'].Attributes.Mandatory | Should Be $true
        }

        It "Requires Path as a Mandatory Parameter" {
            $Parameters['Path'].Attributes.Mandatory | Should Be $true
        }
    }

    # If we want to reinitialise a mock before each context block, we can use BeforeEach
    BeforeAll {
        Mock InvokeDotnetNew -ModuleName PowerShellTemplate -MockWith {}
    }

    # We cannot guarantee that the build server has the prerequisite dotnet installation
    # So we test the function to see that it proceeds as we'd expect.
    Context "Creating a new module with 'dotnet new'" {
        Mock Get-Command -ParameterFilter {$Name -eq 'dotnet'} -ModuleName PowerShellTemplate -MockWith {$true}

        New-PSModule -ModuleName 'TestModule' -Path "$TestDrive\TestModule"

        It "Installs the Template" {
            Assert-MockCalled -CommandName InvokeDotnetNew -ModuleName PowerShellTemplate -ParameterFilter {
                $Arguments -like '--install*'
            } -Times 1 -Exactly
        }

        It "Creates the new module from the PowerShellModule template" {
            Assert-MockCalled -CommandName InvokeDotnetNew -ModuleName PowerShellTemplate -ParameterFilter {
                $Arguments -like 'PowerShellModule'
            } -Times 1 -Exactly
        }
    }

    # We can test the output if dotnet is available, though.
    if (Get-Command -Name dotnet -ErrorAction SilentlyContinue) {
        Context "Creating a new module dotnet new" {
            Mock Get-Command -ParameterFilter {$Name -eq 'dotnet'} -ModuleName PowerShellTemplate -MockWith {}
            $ClonePath = Join-Path (Get-Module 'PowerShellTemplate').ModuleBase 'data\EmptyTemplate'
            $Json = Get-Content $ClonePath\.template.config\template.json | ConvertFrom-Json

            $ModuleName = 'TestModule'

            New-PSModule -ModuleName $ModuleName -Path $TestDrive -Author 'TestAuthor' -Company 'TestCompany'
            $ModulePath = Join-Path $TestDrive $ModuleName

            It "Creates a new module in the Output directlry" {
                Test-Path $ModulePath | Should Be $true
            }

            It "Does not copy the '.template.config' or '.git' directories, or any placeholder files" {
                Test-Path "$ModulePath\.git" | Should Be $False
                Test-Path "$ModulePath\.template.config" | Should Be $False
                Get-ChildItem $ModulePath -Filter placeholder -Recurse | Should BeNullOrEmpty
            }

            It "Renames files from PowerShellTemplate to '$ModuleName'" {
                Get-ChildItem $ModulePath -Filter PowerShellTemplate -Recurse | Should BeNullOrEmpty
                (Get-ChildItem $ModulePath -Filter "$ModuleName*" -Recurse).Count | Should -BeGreaterThan 0
            }

            $PSD1 = Import-PowerShellDataFile "$ModulePath\$ModuleName.psd1"
            It "Updates the PSD1 with a new guid that is not '$($Json.guids[0])'" {
                $PSD1.GUID | Should Not Be $Json.guids[0]
            }

            It "Updates the PSD1 with the author parameter" {
                $PSD1.Author | Should Not Be $Json.Symbols.Author.replaces
                $PSD1.Author | Should Be 'TestAuthor'
            }

            It "Updates the PSD1 with the company parameter" {
                $PSD1.CompanyName | Should Not Be $Json.Symbols.Company.replaces
                $PSD1.CompanyName | Should Be 'TestCompany'
            }

            Remove-Item $ModulePath -Recurse -Force
            New-PSModule -ModuleName $ModuleName -Path $TestDrive
            $PSD1 = Import-PowerShellDataFile "$ModulePath\$ModuleName.psd1"
            It "Updates the PSD1 with '`$env:UserName' as the author name when otherwise unspecified" {
                $PSD1.Author | Should Not Be $Json.Symbols.Author.replaces
                $PSD1.Author | Should Be $env:UserName
            }

            It "Updates the PSD1 with 'Questionmark Computing Limited' as the company name when otherwise unspecified" {
                $PSD1.CompanyName | Should Not Be $Json.Symbols.Company.replaces
                $PSD1.CompanyName | Should Be 'Questionmark Computing Limited'
            }
        }
    }
}
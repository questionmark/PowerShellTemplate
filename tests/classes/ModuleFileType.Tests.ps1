using module PowerShellTemplate
Describe "ModuleFileType" {
    # For testing several similar cases, we can either iterate through an array...
    Context "Testing using iteration through an array" {
        $Types = @("Public", "Private", "Class", "Data")
        foreach ($Type in $Types) {
            It "Should have defined $($Type)" {
                {[ModuleFileType]$Type} | Should Not Throw
            }
        }
    }

    # ...or use the TestCases functionality built into Pester to allow for more complex testing
    Context "Testing using TestCases" {
        $TestCases = @(
            @{
                Number = '0'
                Result = "Class"
            }
            @{
                Number = '1'
                Result = "Private"
            }
            @{
                Number = '2'
                Result = "Public"
            }
            @{
                Number = '4'
                Result = "Data"
            }
        )

        # It statements use <KeyName> within angular brackets for value replacement from TestCases
        It "Value <Number> should be <Result>" -TestCases $TestCases {
            param($Number, $Result)
            [ModuleFileType]$Number | Should Be $Result
        }
    }
}
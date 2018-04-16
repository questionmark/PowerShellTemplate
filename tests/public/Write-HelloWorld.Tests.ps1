Describe "Write-HelloWorld" {
    Context "Parameter Validation" {
        $Parameters = (Get-Command Write-HelloWorld).Parameters
        
        It "Requires Stream as a Mandatory Parameter" {
            $Parameters['Stream'].Attributes.Mandatory | Should Be $true
        }

        It "Can take multiple string values for Stream" {
            $Parameters['Stream'].ParameterType.Name | Should Be "String[]"
        }

        $ValidStreamValues = 'Output', 'Verbose', 'Information', 'Warning', 'Error', 'Host'

        It "Requires Stream to be one of '$($ValidStreamValues -join "', '")'" {
            $AllowedValues = $Parameters['Stream'].Attributes.ValidValues

            $AllowedValues | ForEach-Object {
                $PSItem -in $ValidStreamValues | Should Be $true
            }
        }
    }

    Context "Writing Output" {
        It "Outputs 'Hello World!' by default" {
            Write-HelloWorld -Stream Output | Should Be "Hello World!"
        }
    }
    
    Context "Other Outputs" {
        It "Outputs to Information when passed -Stream Information" {
            Write-HelloWorld -Stream Information -InformationVariable InfoResult
            $InfoResult | Should Be "Hello World!"
        }

        It "Outputs to Warning when passed -Stream Warning" {
            # We use WarningAction to prevent the message appearing in the console during testing
            Write-HelloWorld -Stream Warning -WarningAction SilentlyContinue -WarningVariable WarnResult
            $WarnResult | Should Be "Hello World!"
        }

        It "Outputs to Error when passed -Stream Error" {
            Write-HelloWorld -Stream Error -ErrorAction SilentlyContinue -ErrorVariable ErrorResult
            $ErrorResult | Should Be "Hello World!"
        }

        It "Outputs to Verbose when passed -Stream Verbose" {
            # Testing for verbose output is harder, as you can't easily store it in a variable
            # We redirect it to the output stream to test, here.
            Write-HelloWorld -Stream Verbose -Verbose 4>&1 | Should Be  "Hello World!"
        }

        It "Outputs to Host when passed -Stream Host" {
            # Testing for host output is similarly difficult
            # In this case, we mock Write-Host within PowerShellTemplate and test that this is called as expected.
            Mock -CommandName Write-Host -ModuleName PowerShellTemplate -MockWith {}
            Write-HelloWorld -Stream Host

            Assert-MockCalled -CommandName Write-Host -ModuleName PowerShellTemplate -Times 1 -Exactly 
        }
    }
}
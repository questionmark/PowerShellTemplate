Describe "Write-Message" {
    Context "Parameter Validation" {
        $Parameters = (Get-Command Write-Message).Parameters
        
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
            Write-Message -Stream Output | Should Be "Hello World!"
        }

        It "Outputs a single string when passed to Message" {
            Write-Message -Message "A String" -Stream Output | Should Be "A String"
        }

        It "Outputs multiple string when passed to Message" {
            Write-Message -Message "A String", "Another String" -Stream Output | Should Be "A String", "Another String"
        }
    }
    
    Context "Other Outputs" {
        $TestMessage = 'Test'

        It "Outputs to Information when passed -Stream Information" {
            Write-Message -Message $TestMessage -Stream Information -InformationVariable InfoResult
            $InfoResult | Should Be $TestMessage
        }

        It "Outputs to Warning when passed -Stream Warning" {
            # We use WarningAction to prevent the message appearing in the console during testing
            Write-Message -Message $TestMessage -Stream Warning -WarningAction SilentlyContinue -WarningVariable WarnResult
            $WarnResult | Should Be $TestMessage
        }

        It "Outputs to Error when passed -Stream Error" {
            Write-Message -Message $TestMessage -Stream Error -ErrorAction SilentlyContinue -ErrorVariable ErrorResult
            $ErrorResult | Should Be $TestMessage
        }

        It "Outputs to Verbose when passed -Stream Verbose" {
            # Testing for verbose output is harder, as you can't easily store it in a variable
            # We redirect it to the output stream to test, here.
            Write-Message -Message $TestMessage -Stream Verbose -Verbose 4>&1 | Should Be "$TestMessage"
        }

        It "Outputs to Host when passed -Stream Host" {
            # Testing for host output is similarly difficult
            # In this case, we mock Write-Host within PowerShellTemplate and test that this is called as expected.
            Mock -CommandName Write-Host -ModuleName PowerShellTemplate -MockWith {}
            Write-Message -Message $TestMessage -Stream Host

            Assert-MockCalled -CommandName Write-Host -ModuleName PowerShellTemplate -Times 1 -Exactly 
        }
    }
}
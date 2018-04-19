using module PowerShellTemplate

Describe "ModuleFileClass" {
    $MFC = [ModuleFileClass]::new()
    Context "Value Validation" {
        It "Has a ModuleFileType value" {
            ($MFC | Get-Member).Name -contains 'ModuleFileType' | Should Be $true
        }
        
        It "Has a FileName value" {
            ($MFC | Get-Member).Name -contains 'FileName' | Should Be $true
        }
    }
}
using module PowerShellTemplate

Describe "HashTable Where-like MethodProperty" {
    $HashTable = @(
        @{Name='Test1'}
        @{Name='Test2'}
        @{Name='Test3'}
        @{Name='Worst1'}
        @{Name='Worst2'}
    )

    It "Adds a Where MethodProperty to HashTables" {
        ($HashTable | Get-Member).Name -contains 'Where' | Should Be $true
    }

    It "The Where property allows you to filter an array of HashTables" {
        $HashTable.Where{$_.Name -like 'Test*'}.Count | Should Be ($HashTable.Name -like 'Test*').Count
        $HashTable.Where{$_.Name -like 'Worst*'}.Count | Should Be ($HashTable.Name -like 'Worst*').Count
        $HashTable.Where{$_.Name -like '*2'}.Count | Should Be ($HashTable.Name -like '*2').Count
        $HashTable.Where{$_.Name -like '*2'}.Count | Should Be ($HashTable.Name -like '*2').Count
        $HashTable.Where{$_.Name -like '*3'}.Count | Should Be ($HashTable.Name -like '*3').Count
    }

    It "Should return a HashTable" {
        $HashTable.Where{$_.Name -like '*'} | Should BeOfType HashTable
    }
}
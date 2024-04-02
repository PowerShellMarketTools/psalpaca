#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.5.0'}

# Import the relevant function for testing
BeforeAll {
    . "Get-AlpacaApiConfiguration.ps1"
}

Describe "Configuration" {
    Context "Get-AlpacaApiConfiguration" {
        BeforeAll {
            Set-AlpacaApiConfiguration -ApiKey "TestApiKey" -ApiSecret "TestApiSecret" -SaveProfile -Confirm:$false
        }
        It "CredentialsReturnedAndCorrect" {
            Get-AlpacaApiConfiguration | Should -Not -BeNullOrEmpty
            (Get-AlpacaApiConfiguration).ApiKey | Should -Be "TestApiKey"
            (Get-AlpacaApiConfiguration).ApiSecret | Should -Be "TestApiSecret"
        }
    }
}

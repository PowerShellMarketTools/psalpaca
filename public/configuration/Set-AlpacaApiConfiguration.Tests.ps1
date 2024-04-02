#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.5.0'}

# Import the relevant function for testing
BeforeAll {
    . "./Set-AlpacaApiConfiguration.ps1"
}

Describe "Configuration" {
    Context "Set-AlpacaApiConfiguration" {
        It "CredentialsCreated" {
            Set-AlpacaApiConfiguration -ApiKey "TestApiKey" -ApiSecret "TestApiSecret" -SaveProfile -Confirm:$false
            Test-Path -Path "$($HOME)/.alpaca-credentials" | Should -BeTrue
            $config = Get-Content -Path "$($HOME)/.alpaca-credentials"
            $config.ApiKey | Should -Be "TestApiKey"
            $config.ApiSecret | Should -Be "TestApiSecret"
        }
    }
}

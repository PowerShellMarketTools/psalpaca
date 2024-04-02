#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.5.0'}

# Import the relevant function for testing
BeforeAll {
    Import-Module PSAlpaca
}

Describe "Configuration" {
    Context "Set-AlpacaApiConfiguration" {
        It "CredentialsCreated" {
            Set-AlpacaApiConfiguration -ApiKey "TestApiKey" -ApiSecret "TestApiSecret" -Confirm:$false
            Test-Path -Path "$($HOME)/.alpaca-credentials" | Should -BeTrue
            $config = Get-Content -Path "$($HOME)/.alpaca-credentials" | ConvertFrom-Json
            $config.ApiKey | Should -Be "TestApiKey"
            $config.ApiSecret | Should -Be "TestApiSecret"
        }
    }
}

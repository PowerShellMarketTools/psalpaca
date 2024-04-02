#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.5.0'}

# Import the relevant function for testing
BeforeAll {
    Import-Module PSAlpaca
}

Describe "Configuration" {
    Context "Set-AlpacaApiConfiguration" {
        It "CredentialsFileCreated" {
            Set-AlpacaApiConfiguration -ApiKey "TestApiKey" -ApiSecret "TestApiSecret" -Confirm:$false | Out-Null
            Test-Path -Path "$($HOME)/.alpaca-credentials" | Should -BeTrue
        }
    }
}

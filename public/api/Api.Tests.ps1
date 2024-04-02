#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.5.0'}

BeforeAll {
    Import-Module PSAlpaca
}

Describe "Api" {
    Context "Invoke-AlpacaApi" {
        BeforeAll {
            Set-AlpacaApiConfiguration -ApiKey $env:ALPACA_API_KEY -ApiSecret $env:ALPACA_SECRET_KEY -Confirm:$false
        }

        It "ThrowErrorMissingRequiredParameters" {
            { Invoke-AlpacaApi -ApiName "Trading" -Method "GET" } | Should -Throw
            { Invoke-AlpacaApi -Endpoint "bars/day" -Method "GET" } | Should -Throw
            { Invoke-AlpacaApi -ApiName "Data" -Method "GET" } | Should -Throw
        }
    }
}

#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.5.0'}

# Import the module
BeforeAll {
    Import-Module ./PSAlpaca.psm1
}

Describe "PSAlpaca" {
    Context "Set-AlpacaApiConfiguration" {
        It "EnvironmentCredentialsReturned" {
            Set-AlpacaApiConfiguration -ApiKey "TestApiKey" -SecretKey "TestApiSecret"
            $config = Get-AlpacaApiConfiguration
            $config | Should -Not -BeNullOrEmpty
            $config.ApiKey | Should -Be "TestApiKey"
            $config.ApiSecret | Should -Be "TestApiSecret"
        }

        It "ProfileCredentialsReturned" {
            Set-AlpacaApiConfiguration -ApiKey "TestApiKey" -SecretKey "TestApiSecret" -SaveProfile -Confirm:$false
            Test-Path -Path "$($HOME)/.alpaca-credentials" | Should -BeTrue
            $config = Get-Content -Path "$($HOME)/.alpaca-credentials"
            $config.ApiKey | Should -Be "TestApiKey"
            $config.ApiSecret | Should -Be "TestApiSecret"
        }
    }

    Context "Get-AlpacaApiConfiguration" {
        BeforeAll {
            Set-AlpacaApiConfiguration -ApiKey "TestApiKey" -SecretKey "TestApiSecret" -SaveProfile -Confirm:$false
        }
        It "CredentialsReturnedAndCorrect" {
            Get-AlpacaApiConfiguration | Should -Not -BeNullOrEmpty
            (Get-AlpacaApiConfiguration).ApiKey | Should -Be "TestApiKey"
            (Get-AlpacaApiConfiguration).ApiSecret | Should -Be "TestApiSecret"
        }
    }

    Context "InvokeAlpacaApi" {
        Mock Get-AlpacaApiConfiguration { 
            return @{
                ApiKey    = $env:ALPACA_API_KEY
                ApiSecret = $env:ALPACA_SECRET_KEY
            }
        }
        
        It "Should throw an error when ApiName parameter is not provided" {
            { Invoke-AlpacaApi -Endpoint "bars/day" -Method "GET" } | Should -Throw
        }

        It "Should throw an error when Endpoint parameter is not provided" {
            { Invoke-AlpacaApi -ApiName "Data" -Method "GET" } | Should -Throw
        }

        It "Should throw an error when Method parameter is not provided" {
            { Invoke-AlpacaApi -ApiName "Data" -Endpoint "bars/day" } | Should -Throw
        }
        It "Should return response for retrieving daily bars data" {
            $response = Invoke-AlpacaApi -ApiName "Data" -Endpoint "bars/day" -Method "GET" -QueryString "?symbol=AAPL&limit=5"
            $response | Should -Not -BeNullOrEmpty
            $response | Should -BeOfType [System.Object]
            # Add more specific tests for the response data if needed
        }

        It "Should return response for placing a buy order" {
            $response = Invoke-AlpacaApi -ApiName "Trading" -Endpoint "orders" -Method "POST" -BodyArguments @{symbol = "AAPL"; qty = 10; side = "buy" }
            $response | Should -Not -BeNullOrEmpty
            $response | Should -BeOfType [System.Object]
            # Add more specific tests for the response data if needed
        }
        It "Should return null if no Alpaca API configuration is found" {
            Mock Get-AlpacaApiConfiguration { return $null }
            $response = Invoke-AlpacaApi -ApiName "Data" -Endpoint "bars/day" -Method "GET" -QueryString "?symbol=AAPL&limit=5"
            $response | Should -Be $null
        }

        It "Should return null if API invocation fails" {
            $response = Invoke-AlpacaApi -ApiName "Trading" -Endpoint "nonexistent-endpoint" -Method "GET"
            $response | Should -Be $null
        }
    }
}

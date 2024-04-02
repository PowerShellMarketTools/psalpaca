#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.5.0'}

# Import the module
BeforeAll {
    Import-Module ./PSAlpaca.psm1
}

Describe "PSAlpaca" {
    Context "GetConfiguration" {
        It "EnvironmentCredentialsReturned" {
            # Mocking the existence of a credentials file and its content
            Mock Test-Path { return $true }
            Mock Get-Content { return '{"api_key": "TestApiKey", "api_secret": "TestApiSecret"}' }

            $config = Get-AlpacaApiConfiguration
            $config | Should -Not -BeNullOrEmpty
            $config.api_key | Should -Be "TestApiKey"
            $config.api_key | Should -Be "TestApiSecret"
        }

        It "NoCredentialsFoundInEnvironment" {
            # Mocking the absence of a credentials file
            Mock Test-Path { return $false }

            { Get-AlpacaApiConfiguration } | Should -Throw "No Alpaca API key and secret found. Use Set-AlpacaApiConfiguration."
        }

        It "NoCredentialsFoundInCredentialsFile" {
            # Mocking the existence of an empty credentials file
            Mock Test-Path { return $true }
            Mock Get-Content { return $null }

            { Get-AlpacaApiConfiguration } | Should -Throw "No Alpaca API key and secret found. Use Set-AlpacaApiConfiguration."
        }

        It "MissingFieldsInCredentialsFile" {
            # Mocking the existence of a credentials file missing required fields
            Mock Test-Path { return $true }
            Mock Get-Content { return '{"api_key": "TestApiKey"}' }

            { Get-AlpacaApiConfiguration } | Should -Throw "No Alpaca API key and secret found. Use Set-AlpacaApiConfiguration."
        }
    }

    Context "SetConfiguration" {
        It "Should return the API configuration" {
            # Mocking the existence of a credentials file and its content
            Mock Test-Path { return $true }
            Mock Get-Content { return '{"api_key": "TestApiKey", "api_secret": "TestApiSecret"}' }

            $config = Get-AlpacaApiConfiguration
            $config | Should -Not -BeNullOrEmpty
            $config.api_key | Should -Be "TestApiKey"
            $config.api_secret | Should -Be "TestApiSecret"
        }
        It "Should return null and throw an error" {
            # Mocking the absence of a credentials file
            Mock Test-Path { return $false }

            { Get-AlpacaApiConfiguration } | Should -Throw "No Alpaca API key and secret found. Use Set-AlpacaApiConfiguration."
        }
    

        It "Should return null and throw an error" {
            # Mocking the existence of an empty credentials file
            Mock Test-Path { return $true }
            Mock Get-Content { return $null }

            { Get-AlpacaApiConfiguration } | Should -Throw "No Alpaca API key and secret found. Use Set-AlpacaApiConfiguration."
        }
    

        It "Should return null and throw an error" {
            # Mocking the existence of a credentials file missing required fields
            Mock Test-Path { return $true }
            Mock Get-Content { return '{"api_key": "TestApiKey"}' }

            { Get-AlpacaApiConfiguration } | Should -Throw "No Alpaca API key and secret found. Use Set-AlpacaApiConfiguration."
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

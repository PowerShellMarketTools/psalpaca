#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.5.0'}

# Import the module
BeforeAll {
    Import-Module ./PSAlpaca.psm1
}

Describe "Set-AlpacaApiConfiguration Function" {
    Context "When setting Alpaca API configuration without SaveProfile switch" {
        It "Should set the Alpaca API configuration without saving profile" {
            Set-AlpacaApiConfiguration -ApiKey "TestApiKey" -ApiSecret "TestApiSecret"
            $env:ALPACA_API_KEY | Should -Be "TestApiKey"
            $env:ALPACA_API_SECRET | Should -Be "TestApiSecret"
        }
    }

    Context "When setting Alpaca API configuration with SaveProfile switch" {
        It "Should set the Alpaca API configuration and save profile" {
            Set-AlpacaApiConfiguration -ApiKey "TestApiKey" -ApiSecret "TestApiSecret" -SaveProfile
            $env:ALPACA_API_KEY | Should -Be "TestApiKey"
            $env:ALPACA_API_SECRET | Should -Be "TestApiSecret"
            # Check if credentials file is created
            $credentialsFile = switch ([Environment]::OSVersion.Platform) {
                [PlatformID]::Win32NT { Join-Path $env:USERPROFILE ".alpaca-credentials" }
                default { Join-Path $HOME ".alpaca-credentials" }
            }
            Test-Path $credentialsFile | Should -Be $true
        }

        It "Should prompt -Before overwriting existing profile" {
            # Mocking Read-Host to automatically select 'n' for overwrite prompt
            Mock Read-Host { return 'n' }
            Set-AlpacaApiConfiguration -ApiKey "TestApiKey" -ApiSecret "TestApiSecret" -SaveProfile
            # Check if credentials file is not created
            $credentialsFile = switch ([Environment]::OSVersion.Platform) {
                [PlatformID]::Win32NT { Join-Path $env:USERPROFILE ".alpaca-credentials" }
                default { Join-Path $HOME ".alpaca-credentials" }
            }
            Test-Path $credentialsFile | Should -Be $false
        }
    }
}

# Requires -Module Pester

Describe "Get-AlpacaApiConfiguration Function" {
    Context "When retrieving Alpaca API configuration from existing credentials file" {
        It "Should return the API configuration" {
            # Mocking the existence of a credentials file and its content
            Mock Test-Path { return $true }
            Mock Get-Content { return '{"api_key": "TestApiKey", "api_secret": "TestApiSecret"}' }

            $config = Get-AlpacaApiConfiguration
            $config | Should -Not -BeNullOrEmpty
            $config.ApiKey | Should -Be "TestApiKey"
            $config.ApiSecret | Should -Be "TestApiSecret"
        }
    }

    Context "When no credentials file exists" {
        It "Should return null and throw an error" {
            # Mocking the absence of a credentials file
            Mock Test-Path { return $false }

            $config = Get-AlpacaApiConfiguration
            $config | Should -Be $null
            Assert-Error "No Alpaca API key and secret found. Use Set-AlpacaApiConfiguration."
        }
    }

    Context "When the credentials file is empty or malformed" {
        It "Should return null and throw an error" {
            # Mocking the existence of an empty credentials file
            Mock Test-Path { return $true }
            Mock Get-Content { return $null }

            $config = Get-AlpacaApiConfiguration
            $config | Should -Be $null
            Assert-Error "No Alpaca API key and secret found. Use Set-AlpacaApiConfiguration."
        }
    }

    Context "When the credentials file is missing required fields" {
        It "Should return null and throw an error" {
            # Mocking the existence of a credentials file missing required fields
            Mock Test-Path { return $true }
            Mock Get-Content { return '{"api_key": "TestApiKey"}' }

            $config = Get-AlpacaApiConfiguration
            $config | Should -Be $null
            Assert-Error "No Alpaca API key and secret found. Use Set-AlpacaApiConfiguration."
        }
    }
}

Describe "Invoke-AlpacaApi Function" {
    # Mocking Get-AlpacaApiConfiguration function
    Mock Get-AlpacaApiConfiguration { 
        return @{
            ApiKey    = $env:ALPACA_API_KEY
            ApiSecret = $env:ALPACA_SECRET_KEY
        }
    }

    Context "When invoking Alpaca API without specifying required parameters" {
        It "Should throw an error when ApiName parameter is not provided" {
            { Invoke-AlpacaApi -Endpoint "bars/day" -Method "GET" } | Should -Throw
        }

        It "Should throw an error when Endpoint parameter is not provided" {
            { Invoke-AlpacaApi -ApiName "Data" -Method "GET" } | Should -Throw
        }

        It "Should throw an error when Method parameter is not provided" {
            { Invoke-AlpacaApi -ApiName "Data" -Endpoint "bars/day" } | Should -Throw
        }
    }

    Context "When invoking Alpaca API with valid parameters" {
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
    }

    Context "When invoking Alpaca API with invalid parameters" {
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

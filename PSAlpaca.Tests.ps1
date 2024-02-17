# Import the module containing the Get-AlpacaApiConfiguration function
BeforeAll {
    . $PSScriptRoot\AlpacaApi.psm1
}

# Test when environment variables are set
Describe 'Get-AlpacaApiConfiguration with Environment Variables' {
    BeforeAll {
        $originalEnvApiKey = $env:ALPACA_API_KEY
        $originalEnvApiSecret = $env:ALPACA_API_SECRET
        $originalEnvUserCredential = $env:ALPACA_USER_CREDENTIAL

        $env:ALPACA_API_KEY = 'testApiKey'
        $env:ALPACA_API_SECRET = 'testApiSecret'
        $env:ALPACA_USER_CREDENTIAL = 'true'
    }

    It 'Returns valid credentials from environment variables' {
        $result = Get-AlpacaApiConfiguration
        $result.ApiKey | Should -Be 'testApiKey'
        $result.ApiSecret | Should -Be 'testApiSecret'
        $result.BrokerCredential | Should -BeNullOrEmpty
    }

    AfterAll {
        $env:ALPACA_API_KEY = $originalEnvApiKey
        $env:ALPACA_API_SECRET = $originalEnvApiSecret
        $env:ALPACA_USER_CREDENTIAL = $originalEnvUserCredential
    }
}

# Test when credentials file exists
Describe 'Get-AlpacaApiConfiguration with Credentials File' {
    BeforeAll {
        $credentialsPath = [System.IO.Path]::Combine($HOME, ".alpaca-credentials")
        $credentials = @{
            ApiKey = 'fileApiKey'
            ApiSecret = 'fileApiSecret'
            Username = 'user'
            EncodedPassword = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes('password'))
        }
        $credentials | ConvertTo-Json | Set-Content -Path $credentialsPath
    }

    It 'Returns valid credentials from credentials file' {
        $result = Get-AlpacaApiConfiguration
        $result.ApiKey | Should -Be 'fileApiKey'
        $result.ApiSecret | Should -Be 'fileApiSecret'
        $result.BrokerCredential.UserName | Should -Be 'user'
        $result.BrokerCredential.GetNetworkCredential().Password | Should -Be 'password'
    }

    AfterAll {
        Remove-Item -Path $credentialsPath
    }
}

# Test when no configuration is found
Describe 'Get-AlpacaApiConfiguration without Configuration' {
    BeforeAll {
        $originalEnvApiKey = $env:ALPACA_API_KEY
        $originalEnvApiSecret = $env:ALPACA_API_SECRET
        $env:ALPACA_API_KEY = $null
        $env:ALPACA_API_SECRET = $null
    }

    It 'Throws an error when no configuration is found' {
        { Get-AlpacaApiConfiguration } | Should -Throw -ExpectedMessage 'No Alpaca API configuration found.*'
    }

    AfterAll {
        $env:ALPACA_API_KEY = $originalEnvApiKey
        $env:ALPACA_API_SECRET = $originalEnvApiSecret
    }
}

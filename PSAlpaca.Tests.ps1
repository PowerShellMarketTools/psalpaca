#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.6.0'}

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

Describe "Configuration" {
    Context "Get-AlpacaApiConfiguration" {
        It "CredentialsReturnedAndCorrect" {
            Set-AlpacaApiConfiguration -ApiKey "TestApiKey" -ApiSecret "TestApiSecret" -Confirm:$false
            Get-AlpacaApiConfiguration | Should -Not -BeNullOrEmpty
            (Get-AlpacaApiConfiguration).ApiKey | Should -Be "TestApiKey"
            (Get-AlpacaApiConfiguration).ApiSecret | Should -Be "TestApiSecret"
        }
    }

    Context "Set-AlpacaApiConfiguration" {
        It "CredentialsFileCreated" {
            Set-AlpacaApiConfiguration -ApiKey "TestApiKey" -ApiSecret "TestApiSecret" -Confirm:$false
            Test-Path -Path "$($HOME)/.alpaca-credentials" | Should -BeTrue
        }
    }
}

Describe "Data" {
    Context "Get-AlpacaCorporateActionsData" {
        It 'returns the correct data when called with valid parameters' {
            Set-AlpacaApiConfiguration -ApiKey $env:ALPACA_API_KEY -ApiSecret $env:ALPACA_SECRET_KEY -Confirm:$false
            $params = @{
                Symbols    = @('AAPL', 'MSFT')
                Types      = @('reverse_split', 'forward_split')
                Start      = (Get-Date).AddDays(-30)
                End        = (Get-Date)
                MaxResults = 10
                Sort       = 'Descending'
            }

            $result = Get-AlpacaCorporateActionsData @params

            $result.GetType() | Should -Be [System.Collections.Hashtable]
        }

        It 'throws an error when called with an invalid type' {
            Set-AlpacaApiConfiguration -ApiKey $env:ALPACA_API_KEY -ApiSecret $env:ALPACA_SECRET_KEY -Confirm:$false
            $params = @{
                Symbols    = @('AAPL', 'MSFT')
                Types      = @('invalid_type')
                Start      = (Get-Date).AddDays(-30)
                End        = (Get-Date)
                MaxResults = 10
                Sort       = 'Descending'
            }

            { Get-AlpacaCorporateActionsData @params } | Should -Throw -ExpectedMessage "Cannot validate argument on parameter 'Types'. Unsupported type: invalid_type. Supported values are 'reverse_split', 'forward_split', 'unit_split', 'cash_dividend', 'stock_dividend', 'spin_off', 'cash_merger', 'stock_merger', 'stock_and_cash_merger', 'redemption', 'name_change', 'worthless_removal'."
        }
    }
    Context "Get-AlpacaCryptoHistoricalBarsData" {
    
    }
    Context "Get-AlpacaCryptoHistoricalQuotesData" {
    
    }
    Context "Get-AlpacaCryptoHistoricalTradesData" {
    
    }
    Context "Get-AlpacaCryptoLatestBarsData" {
    
    }
    Context "Get-AlpacaCryptoLatestOrderBookData" {
    
    }
    Context "Get-AlpacaCryptoLatestQuotesData" {
    
    }
    Context "Get-AlpacaCryptoLatestTradesData" {
    
    }
    Context "Get-AlpacaCryptoSnapshotsData" {
    
    }
    Context "Get-AlpacaForexHistoricalCurrencyPairRates" {
    
    }
    Context "Get-AlpacaForexLatestCurrencyPairRates" {
    
    }
    Context "Get-AlpacaLogo" {
    
    }
    Context "Get-AlpacaNewsArticle" {
    
    }
    Context "Get-AlpacaMostActiveStocks" {
    
    }
    Context "Get-AlpacaTopMarketMovers" {
    
    }
    Context "Get-AlpacaStockConditionCodes" {
    
    }
    Context "Get-AlpacaStockExchangeCodes" {
    
    }
    Context "Get-AlpacaStockHistoricalAuctions" {
    
    }
    Context "Get-AlpacaStockHistoricalBars" {
    
    }
    Context "Get-AlpacaStockHistoricalQuotes" {
    
    }
    Context "Get-AlpacaStockHistoricalTrades" {
    
    }
    Context "Get-AlpacaStockLatestBars" {
    
    }
    Context "Get-AlpacaStockLatestQuotes" {
    
    }
    Context "Get-AlpacaStockLatestTrades" {
    
    }
    Context "Get-AlpacaStockSnapshots" {
    
    }
}

Describe "Trading" {
    BeforeAll {
        Set-AlpacaApiConfiguration -ApiKey $env:ALPACA_API_KEY -ApiSecret $env:ALPACA_SECRET_KEY -Confirm:$false
    }

    Context "Get-AlpacaAccountActivity" {

    }
    Context "Get-AlpacaAccountConfiguration" {

    }
    Context "Set-AlpacaAccountConfiguration" {

    }
    Context "Get-AlpacaAccount" {

    }
    Context "Get-AlpacaAsset" {

    }
    Context "Get-AlpacaOptionsContract" {

    }
    Context "Get-AlpacaMarketCalendarInfo" {

    }
    Context "Get-AlpacaMarketClockInfo" {

    }
    Context "Get-AlpacaCorporateActionAnnouncement" {

    }
    Context "Get-AlpacaOrder" {

    }
    Context "Get-AlpacaOrderById" {

    }
    Context "New-AlpacaOrder" {

    }
    Context "Remove-AllAlpacaOrders" {

    }
    Context "Remove-AlpacaOrderById" {

    }
    Context "Set-AlpacaOrderById" {

    }
    Context "Get-AlpacaAccountPortfolioHistory" {

    }
    Context "Get-AllOpenAlpacaPositions" {

    }
    Context "Get-OpenAlpacaPosition" {

    }
    Context "Remove-AllOpenAlpacaPositions" {

    }
    Context "Remove-AlpacaOpenPosition" {

    }
    Context "Add-AlpacaWatchlistAsset" {

    }
    Context "Get-AllAlpacaWatchlists" {

    }
    Context "Get-AlpacaWatchlist" {

    }
    Context "New-AlpacaWatchlist" {

    }
    Context "Remove-AlpacaWatchlist" {

    }
    Context "Remove-AlpacaWatchlistAsset" {

    }
    Context "Set-AlpacaWatchlist" {

    }
}

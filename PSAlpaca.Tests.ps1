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
    BeforeEach {
        Set-AlpacaApiConfiguration -ApiKey $env:ALPACA_API_KEY -ApiSecret $env:ALPACA_SECRET_KEY -Confirm:$false
    }

    Context "Get-AlpacaCorporateActionsData" {
        It 'returns data when called with valid parameters' {
            $params = @{
                Symbols    = @('AAPL', 'MSFT')
                Types      = @('reverse_split', 'forward_split')
                Start      = (Get-Date).AddDays(-30)
                End        = (Get-Date)
                MaxResults = 10
                Sort       = 'Descending'
            }

            $result = Get-AlpacaCorporateActionsData @params

            $result | Should -Not -BeNullOrEmpty
        }

        It 'throws an error when called with an invalid type' {
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
        It 'returns the correct data when called with valid parameters' {
            $params = @{
                Location          = 'US'
                Symbols           = 'BTC/USD'
                Timeframe         = 1
                TimeframeInterval = 'Hour'
                Start             = (Get-Date).AddDays(-30)
                End               = (Get-Date)
                MaxResults        = 10
                Sort              = 'Descending'
            }
    
            $result = Get-AlpacaCryptoHistoricalBarsData @params
    
            $result | Should -Not -BeNullOrEmpty
            $result.bars.'BTC/USD' | Should -Not -BeNullOrEmpty
        }
    
        It 'throws an error when called with an invalid symbol format' {
            $params = @{
                Location          = 'US'
                Symbols           = 'invalid_format'
                Timeframe         = 1
                TimeframeInterval = 'Hour'
                Start             = (Get-Date).AddDays(-30)
                End               = (Get-Date)
                MaxResults        = 10
                Sort              = 'Descending'
            }
    
            { Get-AlpacaCryptoHistoricalBarsData @params } | Should -Throw -ExpectedMessage 'Incorrect Symbols format. Format must be in ''CURRENCY\CURRENCY'' format. Ex: BTC/USD, USD/ETH, etc...'
        }
    }

    Context "Get-AlpacaCryptoHistoricalQuotesData" {
        It "Should return error when Symbols parameter is not in correct format" {
            { Get-AlpacaCryptoHistoricalQuotesData -Location "US" -Symbols "BTCUSD" -Timeframe 1 -TimeframeInterval "Hour" } | Should -Throw
        }
    
        It "Should return error when Timeframe and TimeframeInterval are not specified" {
            { Get-AlpacaCryptoHistoricalQuotesData -Location "US" -Symbols "BTC/USD" } | Should -Throw
        }
    
        It "Should return data when valid parameters are passed" {
            $result = Get-AlpacaCryptoHistoricalQuotesData -Location "US" -Symbols "BTC/USD" -Timeframe 1 -TimeframeInterval "Hour"
            $result | Should -Not -BeNullOrEmpty
        }
    
        It "Should return null when no data found" {
            $result = Get-AlpacaCryptoHistoricalQuotesData -Location "US" -Symbols "XYZ/ABC" -Timeframe 1 -TimeframeInterval "Hour"
            $result | Should -BeNullOrEmpty
        }
    }

    Context "Get-AlpacaCryptoHistoricalTradesData" {
        It "Should return error when Symbols parameter is not in correct format" {
            { Get-AlpacaCryptoHistoricalTradesData -Location "US" -Symbols "BTCUSD" -Timeframe 1 -TimeframeInterval "Hour" } | Should -Throw
        }
    
        It "Should return error when Timeframe and TimeframeInterval are not specified" {
            { Get-AlpacaCryptoHistoricalTradesData -Location "US" -Symbols "BTC/USD" } | Should -Throw
        }
    
        It "Should return data when valid parameters are passed" {
            $result = Get-AlpacaCryptoHistoricalTradesData -Location "US" -Symbols "BTC/USD" -Timeframe 1 -TimeframeInterval "Hour"
            $result | Should -Not -BeNullOrEmpty
        }
    
        It "Should return null when no data found" {
            $result = Get-AlpacaCryptoHistoricalTradesData -Location "US" -Symbols "XYZ/ABC" -Timeframe 1 -TimeframeInterval "Hour"
            $result | Should -BeNullOrEmpty
        }
    }

    Context "Get-AlpacaCryptoLatestBarsData" {
        It "Should return error when Symbols parameter is not in correct format" {
            { Get-AlpacaCryptoLatestBarsData -Location "US" -Symbols "BTCUSD" } | Should -Throw
        }
    
        It "Should return data when valid parameters are passed" {
            $result = Get-AlpacaCryptoLatestBarsData -Location "US" -Symbols "BTC/USD"
            $result | Should -Not -BeNullOrEmpty
        }
    
        It "Should return null when no data found" {
            $result = Get-AlpacaCryptoLatestBarsData -Location "US" -Symbols "XYZ/ABC"
            $result | Should -Be @{bars=$null}
        }
    }

    Context "Get-AlpacaCryptoLatestOrderBookData" {
        It "Should return error when Symbols parameter is not in correct format" {
            { Get-AlpacaCryptoLatestOrderBookData -Location "US" -Symbols "BTCUSD" } | Should -Throw
        }
    
        It "Should return data when valid parameters are passed" {
            $result = Get-AlpacaCryptoLatestOrderBookData -Location "US" -Symbols "BTC/USD"
            $result | Should -Not -BeNullOrEmpty
        }
    
        It "Should return null when no data found" {
            $result = Get-AlpacaCryptoLatestOrderBookData -Location "US" -Symbols "XYZ/ABC"
            $result | Should -BeNullOrEmpty
        }
    }

    Context "Get-AlpacaCryptoLatestQuotesData" {
        It "Should return error when Symbols parameter is not in correct format" {
            { Get-AlpacaCryptoLatestQuotesData -Location "US" -Symbols "BTCUSD" } | Should -Throw
        }
    
        It "Should return data when valid parameters are passed" {
            $result = Get-AlpacaCryptoLatestQuotesData -Location "US" -Symbols "BTC/USD"
            $result | Should -Not -BeNullOrEmpty
        }
    
        It "Should return null when no data found" {
            $result = Get-AlpacaCryptoLatestQuotesData -Location "US" -Symbols "XYZ/ABC"
            $result | Should -BeNullOrEmpty
        }
    }

    Context "Get-AlpacaCryptoLatestTradesData" {
        It "Should return error when Symbols parameter is not in correct format" {
            { Get-AlpacaCryptoLatestTradesData -Location "US" -Symbols "BTCUSD" } | Should -Throw
        }
    
        It "Should return data when valid parameters are passed" {
            $result = Get-AlpacaCryptoLatestTradesData -Location "US" -Symbols "BTC/USD"
            $result | Should -Not -BeNullOrEmpty
        }
    
        It "Should return null when no data found" {
            $result = Get-AlpacaCryptoLatestTradesData -Location "US" -Symbols "XYZ/ABC"
            $result | Should -BeNullOrEmpty
        }
    }

    Context "Get-AlpacaCryptoSnapshotsData" {
        It "Should return error when Symbols parameter is not in correct format" {
            { Get-AlpacaCryptoSnapshotsData -Location "US" -Symbols "BTCUSD" } | Should -Throw
        }
    
        It "Should return data when valid parameters are passed" {
            $result = Get-AlpacaCryptoSnapshotsData -Location "US" -Symbols "BTC/USD"
            $result | Should -Not -BeNullOrEmpty
        }
    
        It "Should return null when no data found" {
            $result = Get-AlpacaCryptoSnapshotsData -Location "US" -Symbols "XYZ/ABC"
            $result | Should -BeNullOrEmpty
        }
    }

    Context "Get-AlpacaForexHistoricalCurrencyPairRates" {
        It "Should return error when CurrencyPairs parameter is not in correct format" {
            { Get-AlpacaForexHistoricalCurrencyPairRates -CurrencyPairs "EURUSD,USDJPY" -Timeframe "1Min" } | Should -Throw
        }
    
        It "Should return data when valid parameters are passed" {
            $result = Get-AlpacaForexHistoricalCurrencyPairRates -CurrencyPairs "EUR/USD,USD/JPY" -Timeframe "1Min" -Start "2023-01-01" -End "2023-01-07"
            $result | Should -Not -BeNullOrEmpty
        }
    
        It "Should return null when no data found" {
            $result = Get-AlpacaForexHistoricalCurrencyPairRates -CurrencyPairs "XYZ/ABC" -Timeframe "1Min" -Start "2023-01-01" -End "2023-01-07"
            $result | Should -BeNullOrEmpty
        }
    }

    Context "Get-AlpacaForexLatestCurrencyPairRates" {
        It "Should return error when CurrencyPairs parameter is not in correct format" {
            { Get-AlpacaForexLatestCurrencyPairRates -CurrencyPairs "EURUSD,USDJPY" } | Should -Throw
        }
    
        It "Should return data when valid parameters are passed" {
            $result = Get-AlpacaForexLatestCurrencyPairRates -CurrencyPairs "EUR/USD,USD/JPY"
            $result | Should -Not -BeNullOrEmpty
        }
    
        It "Should return null when no data found" {
            $result = Get-AlpacaForexLatestCurrencyPairRates -CurrencyPairs "XYZ/ABC"
            $result | Should -BeNullOrEmpty
        }
    }

    Context "Get-AlpacaLogo" {
        It "Should return error when Symbol parameter is not provided" {
            { Get-AlpacaLogo } | Should -Throw
        }
    
        It "Should return data when valid parameters are passed" {
            $result = Get-AlpacaLogo -Symbol "AAPL"
            $result | Should -Not -BeNullOrEmpty
        }
    
        It "Should return placeholder when Placeholder switch is used and no logo found" {
            $result = Get-AlpacaLogo -Symbol "XYZ" -Placeholder
            $result | Should -Not -BeNullOrEmpty
        }
    
        It "Should return null when no logo found and Placeholder switch is not used" {
            $result = Get-AlpacaLogo -Symbol "XYZ"
            $result | Should -BeNullOrEmpty
        }
    }

    Context "Get-AlpacaNewsArticle" {
        It "Should return error when Symbols parameter is not provided" {
            { Get-AlpacaNewsArticle } | Should -Throw
        }
    
        It "Should return data when valid parameters are passed" {
            $result = Get-AlpacaNewsArticle -Symbols "AAPL,MSFT" -Limit 10 -Start "2023-01-01" -End "2023-01-07" -Sort "desc"
            $result | Should -Not -BeNullOrEmpty
        }
    
        It "Should return null when no articles found" {
            $result = Get-AlpacaNewsArticle -Symbols "XYZ" -Limit 10 -Start "2023-01-01" -End "2023-01-07" -Sort "desc"
            $result | Should -BeNullOrEmpty
        }
    
        It "Should return articles with content when IncludeContent parameter is used" {
            $result = Get-AlpacaNewsArticle -Symbols "AAPL,MSFT" -Limit 10 -Start "2023-01-01" -End "2023-01-07" -Sort "desc" -IncludeContent $true
            $result.articles | ForEach-Object { $_.content | Should -Not -BeNullOrEmpty }
        }
    
        It "Should not return articles without content when ExcludeContentless parameter is used" {
            $result = Get-AlpacaNewsArticle -Symbols "AAPL,MSFT" -Limit 10 -Start "2023-01-01" -End "2023-01-07" -Sort "desc" -ExcludeContentless $true
            $result.articles | ForEach-Object { $_.content | Should -Not -BeNullOrEmpty }
        }
    }

    Context "Get-AlpacaMostActiveStocks" {
        It "Should return error when By parameter is not provided" {
            { Get-AlpacaMostActiveStocks -Top 10 } | Should -Throw
        }
    
        It "Should return error when Top parameter is not provided" {
            { Get-AlpacaMostActiveStocks -By "volume" } | Should -Throw
        }
    
        It "Should return data when valid parameters are passed" {
            $result = Get-AlpacaMostActiveStocks -By "volume" -Top 10
            $result | Should -Not -BeNullOrEmpty
        }
    
        It "Should return top 10 most active stocks when Top parameter is 10" {
            $result = Get-AlpacaMostActiveStocks -By "volume" -Top 10
            $result.Count | Should -Be 10
        }
    
        It "Should return error when invalid By parameter is passed" {
            { Get-AlpacaMostActiveStocks -By "invalid" -Top 10 } | Should -Throw
        }
    }

    Context "Get-AlpacaTopMarketMovers" {
        It "Should return error when MarketType parameter is not provided" {
            { Get-AlpacaTopMarketMovers -Top 10 } | Should -Throw
        }
    
        It "Should return data when valid parameters are passed" {
            $result = Get-AlpacaTopMarketMovers -MarketType "stocks" -Top 10
            $result | Should -Not -BeNullOrEmpty
        }
    
        It "Should return top 10 market movers when Top parameter is 10" {
            $result = Get-AlpacaTopMarketMovers -MarketType "stocks" -Top 10
            $result.Count | Should -Be 10
        }
    
        It "Should return error when invalid MarketType parameter is passed" {
            { Get-AlpacaTopMarketMovers -MarketType "invalid" -Top 10 } | Should -Throw
        }
    }

    Context "Get-AlpacaStockConditionCodes" {
        It "Should return error when TickType parameter is not provided" {
            { Get-AlpacaStockConditionCodes -Tape "A" } | Should -Throw
        }
    
        It "Should return error when Tape parameter is not provided" {
            { Get-AlpacaStockConditionCodes -TickType "Trade" } | Should -Throw
        }
    
        It "Should return data when valid parameters are passed" {
            $result = Get-AlpacaStockConditionCodes -TickType "Trade" -Tape "A"
            $result | Should -Not -BeNullOrEmpty
        }
    
        It "Should return error when invalid TickType parameter is passed" {
            { Get-AlpacaStockConditionCodes -TickType "Invalid" -Tape "A" } | Should -Throw
        }
    
        It "Should return error when invalid Tape parameter is passed" {
            { Get-AlpacaStockConditionCodes -TickType "Trade" -Tape "D" } | Should -Throw
        }
    }

    Context "Get-AlpacaStockExchangeCodes" {
        It "Should return data when called" {
            $result = Get-AlpacaStockExchangeCodes
            $result | Should -Not -BeNullOrEmpty
        }
    
        It "Should return error when API call fails" {
            Mock Invoke-AlpacaApi { throw [System.Exception] "API call failed" }
            { Get-AlpacaStockExchangeCodes } | Should -Throw
        }
    }

    Context "Get-AlpacaStockHistoricalAuctions" {
        It "Should return error when Symbols parameter is not provided" {
            { Get-AlpacaStockHistoricalAuctions } | Should -Throw
        }
    
        It "Should return data when valid parameters are passed" {
            $result = Get-AlpacaStockHistoricalAuctions -Symbols "AAPL" -Start "2023-01-01" -End "2023-01-31" -MaxResults 100 -Currency "USD"
            $result | Should -Not -BeNullOrEmpty
        }
    
        It "Should return error when invalid Symbols parameter is passed" {
            { Get-AlpacaStockHistoricalAuctions -Symbols "Invalid" } | Should -Throw
        }
    
        It "Should return error when API call fails" {
            Mock Invoke-AlpacaApi { throw [System.Exception] "API call failed" }
            { Get-AlpacaStockHistoricalAuctions -Symbols "AAPL" } | Should -Throw
        }
    }

    Context "Get-AlpacaStockHistoricalBars" {
        It 'Get-AlpacaStockHistoricalBars should be available' {
            Get-Command Get-AlpacaStockHistoricalBars | Should -Not -BeNullOrEmpty
        }

        It 'Should return data for specified symbol' {
            $result = Get-AlpacaStockHistoricalBars -Symbols "AAPL" -Timeframe 1 -TimeframeInterval "Day" -Start "2023-01-01" -End "2023-01-07"
            $result.bars.AAPL | Should -Not -BeNullOrEmpty
            $result.bars.AAPL[0].o | Should -Be 150.0
        }
    }

    Context "Get-AlpacaStockHistoricalQuotes" {
        It 'Function is defined' {
            Get-Command Get-AlpacaStockHistoricalQuotes | Should -Not -BeNullOrEmpty
        }
    
        It 'Returns data with valid parameters' {
            $result = Get-AlpacaStockHistoricalQuotes -Symbols "AAPL" -Timeframe 1 -TimeframeInterval "Day" -Start "2023-01-01" -End "2023-01-01"
            $result.bars.AAPL | Should -Not -BeNullOrEmpty
        }
    
        It 'Returns null with invalid parameters' {
            $result = Get-AlpacaStockHistoricalQuotes -Symbols "INVALID" -Timeframe 1 -TimeframeInterval "Day" -Start "2023-01-01" -End "2023-01-01"
            $result | Should -Be $null
        }
    }

    Context "Get-AlpacaStockHistoricalTrades" {
        It 'Function is defined' {
            Get-Command Get-AlpacaStockHistoricalTrades | Should -Not -BeNullOrEmpty
        }
    
        It 'Returns data with valid parameters' {
            $result = Get-AlpacaStockHistoricalTrades -Symbols "AAPL" -Timeframe 1 -TimeframeInterval "Hour" -Start "2023-01-01" -End "2023-01-07"
            $result.bars.AAPL | Should -Not -BeNullOrEmpty
        }
    
        It 'Returns null with invalid parameters' {
            $result = Get-AlpacaStockHistoricalTrades -Symbols "INVALID" -Timeframe 1 -TimeframeInterval "Hour" -Start "2023-01-01" -End "2023-01-07"
            $result | Should -Be $null
        }
    }

    Context "Get-AlpacaStockLatestBars" {
        It 'Function is defined' {
            Get-Command Get-AlpacaStockLatestBars | Should -Not -BeNullOrEmpty
        }
        It 'Function returns expected result' {
            $result = Get-AlpacaStockLatestBars -Symbols @("AAPL") -Feed "IEX" -Currency "USD"
            $result | Should -BeOfType [PSCustomObject]
        }
    }
    
    Context "Get-AlpacaStockLatestQuotes" {
        It 'Function is defined' {
            Get-Command Get-AlpacaStockLatestQuotes | Should -Not -BeNullOrEmpty
        }
        It 'Function returns expected result' {
            $result = Get-AlpacaStockLatestQuotes -Symbols @("AAPL") -Feed "IEX" -Currency "USD"
            $result | Should -BeOfType [PSCustomObject]
        }
    }
    
    Context "Get-AlpacaStockLatestTrades" {
        It 'Function is defined' {
            Get-Command Get-AlpacaStockLatestTrades | Should -Not -BeNullOrEmpty
        }
        It 'Function returns expected result' {
            $result = Get-AlpacaStockLatestTrades -Symbols @("AAPL") -Feed "IEX" -Currency "USD"
            $result | Should -BeOfType [PSCustomObject]
        }
    }
    
    Context "Get-AlpacaStockSnapshots" {
        It 'Function is defined' {
            Get-Command Get-AlpacaStockSnapshots | Should -Not -BeNullOrEmpty
        }
        It 'Function returns expected result' {
            $result = Get-AlpacaStockSnapshots -Symbols @("AAPL") -Feed "IEX" -Currency "USD"
            $result | Should -BeOfType [PSCustomObject]
        }
    }
}

Describe "Trading" {
    BeforeEach {
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

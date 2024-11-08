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
            Set-AlpacaApiConfiguration -ApiKey "TestApiKey" -ApiSecret "TestApiSecret" -SaveProfile -Confirm:$false
            Test-Path -Path "$($HOME)/.alpaca-credentials" | Should -BeTrue
        }
    }
}

Describe "Data" {
    BeforeAll {
        Set-AlpacaApiConfiguration -ApiKey $env:ALPACA_API_KEY -ApiSecret $env:ALPACA_SECRET_KEY -Confirm:$false
    }

    Context "Get-AlpacaCorporateActionsData" {

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

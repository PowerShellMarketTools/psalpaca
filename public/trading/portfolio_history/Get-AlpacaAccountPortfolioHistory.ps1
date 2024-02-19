<#
.SYNOPSIS
Returns timeseries data about equity and profit/loss (P/L) of the account in the requested timespan.

.DESCRIPTION
The Get-AlpacaAccountPortfolioHistory cmdlet retrieves timeseries data on the equity and profit/loss (P/L) of the account for a specified timespan. It supports different configurations to suit both equity and crypto traders, including adjustments for intraday reporting and profit and loss calculation. Parameters allow for customization of the data retrieval period, timeframe, and accounting for extended or continuous market hours.

.PARAMETER Period
Specifies the duration of the data in number + unit format, such as 1D, where unit can be D for day, W for week, M for month, and A for year. Defaults to 1M.

.PARAMETER Timeframe
Specifies the resolution of the time window. Options include 1Min, 5Min, 15Min, 1H, or 1D. Defaults based on the period specified.

.PARAMETER IntradayReporting
Adjusts data points reporting for intraday timeframes. Options include market_hours, extended_hours, or continuous.

.PARAMETER Start
Defines the start date-time for data retrieval in RFC3339 format. It's considered based on the intraday_reporting value.

.PARAMETER PnlReset
Determines the baseline for profit and loss calculation in intraday queries. Options are default behavior or no_reset for continuous calculation.

.PARAMETER End
Specifies the end date-time for data retrieval in RFC3339 format. It's adjusted based on the intraday_reporting value.

.EXAMPLE
Get-AlpacaAccountPortfolioHistory -Period 1M -Timeframe 1D

Retrieves the account's portfolio history over the past month with daily data points.

.EXAMPLE
Get-AlpacaAccountPortfolioHistory -Period 5D -Timeframe 1Min -IntradayReporting continuous

Retrieves the account's portfolio history over the past 5 days with 1-minute intervals, including continuous 24/7 data points for a crypto trading scenario.

.NOTES
Author: Your Name

.LINK
https://docs.alpaca.markets/reference/getaccountportfoliohistory

#>
function Get-AlpacaAccountPortfolioHistory {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false)]
        [string]$Period = "1M",

        [Parameter(Mandatory = $false)]
        [string]$Timeframe,

        [Parameter(Mandatory = $false)]
        [string]$IntradayReporting,

        [Parameter(Mandatory = $false)]
        [datetime]$Start,

        [Parameter(Mandatory = $false)]
        [string]$PnlReset,

        [Parameter(Mandatory = $false)]
        [datetime]$End
    )

    # Initialize the query string
    $ApiQueryString = "period=$($Period)"

    if ($PSBoundParameters.ContainsKey('Timeframe')) {
        $ApiQueryString += "&timeframe=$($Timeframe)"
    }
    if ($PSBoundParameters.ContainsKey('IntradayReporting')) {
        $ApiQueryString += "&intraday_reporting=$($IntradayReporting)"
    }
    if ($PSBoundParameters.ContainsKey('Start')) {
        $startString = $Start.ToUniversalTime().ToString("o")  # ISO 8601 format
        $ApiQueryString += "&start=$($startString)"
    }
    if ($PSBoundParameters.ContainsKey('PnlReset')) {
        $ApiQueryString += "&pnl_reset=$($PnlReset)"
    }
    if ($PSBoundParameters.ContainsKey('End')) {
        $endString = $End.ToUniversalTime().ToString("o")  # ISO 8601 format
        $ApiQueryString += "&end=$($endString)"
    }

    $ApiParams = @{
        ApiName     = "Trading"
        Endpoint    = "account/portfolio/history"
        Method      = "GET"
        QueryString = $ApiQueryString
    }

    Try {
        Write-Verbose "Retrieving Alpaca account portfolio history..."
        $Response = Invoke-AlpacaApi @ApiParams
        return $Response
    }
    Catch [System.Exception] {
        Write-Error "API call to retrieve account portfolio history failed: $($_.Exception)"
        return $null
    }
}

<#
.SYNOPSIS
    Retrieves historical auction data for Alpaca stocks.

.DESCRIPTION
    This function retrieves historical auction data for Alpaca stocks based on the provided parameters such as symbols,
    start and end dates, maximum results, as-of date, feed, currency, and sorting.

.PARAMETER Symbols
    Specifies an array of stock symbols for which historical auction data will be retrieved.

.PARAMETER Start
    Specifies the start date for retrieving historical auction data. Defaults to null.

.PARAMETER End
    Specifies the end date for retrieving historical auction data. Defaults to null.

.PARAMETER MaxResults
    Specifies the maximum number of results to return. Defaults to null.

.PARAMETER AsOfDate
    Specifies a specific date to retrieve historical auction data. Defaults to null.

.PARAMETER Feed
    Specifies the feed source for the auction data. Accepted values are "IEX", "OTP", or "SIP". Defaults to null.

.PARAMETER Currency
    Specifies the currency for the auction data. Defaults to "USD".

.PARAMETER Sort
    Specifies the sorting order for the auction data. Accepted values are "Ascending" or "Descending". Defaults to null.

.EXAMPLE
    Get-AlpacaStockHistoricalAuctions -Symbols "AAPL" -Start "2023-01-01" -End "2023-01-31" -MaxResults 100 -Currency "USD"
    Retrieves historical auction data for the AAPL stock from January 1, 2023, to January 31, 2023, limited to 100 results in USD currency.

.EXAMPLE
    Get-AlpacaStockHistoricalAuctions -Symbols "GOOG", "MSFT" -AsOfDate "2023-03-15" -Feed "IEX" -Sort "Descending"
    Retrieves historical auction data for GOOG and MSFT stocks as of March 15, 2023, from IEX feed sorted in descending order.

.NOTES
    Author: [Author Name]
    Date: [Date]
    Version: [Version Number]
#>

Function Get-AlpacaStockHistoricalAuctions {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string[]]$Symbols,

        [Parameter(Mandatory = $false)]
        [datetime]$Start,

        [Parameter(Mandatory = $false)]
        [datetime]$End,

        [Parameter(Mandatory = $false)]
        [int]$MaxResults,

        [Parameter(Mandatory = $false)]
        [datetime]$AsOfDate,

        [Parameter(Mandatory = $false)]
        [ValidateSet("IEX", "OTP", "SIP")]
        [string]$Feed,

        [Parameter(Mandatory = $false)]
        [string]$Currency,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Ascending", "Descending")]
        [string]$Sort
    )

    $QueryParameters = @{}
    $QueryParameters.Add('symbols', ($Symbols -join ',').ToUpper())

    if ($Start) {
        $QueryParameters.Add('start', $(Get-Date $Start -Format "yyyy-MM-dd"))
    }

    if ($End) {
        $QueryParameters.Add('end', $(Get-Date $End -Format "yyyy-MM-dd"))
    }

    if ($MaxResults) {
        $QueryParameters.Add('limit', $MaxResults)
    }

    if ($AsOfDate) {
        $QueryParameters.Add('asof', $AsOfDate)
    }

    if ($Feed) {
        $QueryParameters.Add('feed', $Feed.ToLower())
    }

    if ($Currency) {
        $QueryParameters.Add('currency', $Currency.ToUpper())
    }
    else {
        $Currency = "USD"
    }

    if ($Sort) {
        $QueryParameters.Add('sort', $(
                switch ($Sort) {
                    "Ascending" { "asc" };
                    "Descending" { "desc" }
                }
            ))
    }

    $ApiParams = @{
        ApiName  = "Data"
        Endpoint = "stocks/auctions"
        Method   = "Get"
    }

    if ($null -ne $QueryParameters) {
        $ApiParams.Add(
            'QueryString',
            ('?' + (
                ($QueryParameters.GetEnumerator() | ForEach-Object {
                    "$($_.Key)=$([System.Web.HttpUtility]::UrlEncode($_.Value))" }
                ) -join '&'
            ))
        )
    }

    $ResponseData = @()

    Try {
        $Response = Invoke-AlpacaApi @ApiParams
        $ResponseData += @{
            data = $Response
        }
    }
    Catch [System.Exception] {
        Write-Error "API call failed: $($_.Exception)"
        return $null
    }

    while ($Response.next_page_token) {
        Write-Verbose "Found next_page_token '$($Response.next_page_token)' : requerying Alpaca API"
        if ($ApiParams.QueryString -notmatch 'page_token=') {
            $ApiParams.QueryString += "&page_token=$($Response.next_page_token)"
        }
        else {
            $ApiParams.QueryString = $ApiParams.QueryString -replace 'page_token=.*?(?=&|$)', "page_token=$($Response.next_page_token)"
        }
        Try {
            $Response = Invoke-AlpacaApi @ApiParams
            $ResponseData += @{
                data = $Response
            }
        }
        Catch [System.Exception] {
            Write-Error "API call failed: $($_.Exception)"
            return $null
            break
        }
    }
    
    if ($ResponseData.Count -gt 0) {
        return $ResponseData
    }
    else {
        Write-Verbose "No data found."
        return $null
    }
}

<#
.SYNOPSIS
    Retrieves the top market movers (gainers and losers) from the Alpaca API.

.DESCRIPTION
    This function retrieves the top market movers (gainers and losers) from the Alpaca API based on the specified market type.

.PARAMETER MarketType
    Specifies the market type to screen (stocks or crypto).

.PARAMETER Top
    Specifies the number of top market movers to fetch (both gainers and losers). By default, it returns 10 gainers and 10 losers.

.EXAMPLE
    Get-AlpacaTopMarketMovers -MarketType "stocks" -Top 10
    Retrieves the top 10 market movers (both gainers and losers) for stocks.

#>
Function Get-AlpacaTopMarketMovers {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("stocks", "crypto")]
        [string]$MarketType,

        [int]$Top = 10
    )

    $QueryParameters = @{
        'top' = $Top
    }

    $ApiParams = @{
        ApiName  = "Data"
        Endpoint = "screener/$($MarketType)/movers"
        Method   = "Get"
    }

    if ($QueryParameters.Count -gt 0) {
        $ApiParams.Add(
            'QueryString',
            ('?' + (
                ($QueryParameters.GetEnumerator() | ForEach-Object {
                    "$($_.Key)=$([System.Web.HttpUtility]::UrlEncode($_.Value))" }
                ) -join '&'
            ))
        )
    }

    Try {
        $Response = Invoke-AlpacaApi @ApiParams
        return $Response
    }
    Catch [System.Exception] {
        Write-Error "API call failed: $($_.Exception)"
        return $null
    }
}

<#
.SYNOPSIS
    Retrieves the latest rates data for currency pairs from the Alpaca API.

.DESCRIPTION
    This function retrieves the latest rates data for currency pairs from the Alpaca API based on the specified currency pairs.

.PARAMETER CurrencyPairs
    Specifies the currency pairs for which the latest rates data is to be retrieved. Should be a comma-separated string of currency pairs, e.g., "EUR/USD,USD/JPY".

.EXAMPLE
    Get-AlpacaForexLatestCurrencyPairRates -CurrencyPairs "EUR/USD,USD/JPY"
    Retrieves the latest rates data for the specified currency pairs.

#>
Function Get-AlpacaForexLatestCurrencyPairRates {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$CurrencyPairs
    )

    Write-Verbose "Retrieving latest rates data for currency pairs $CurrencyPairs from Alpaca API..."

    $ApiParams = @{
        ApiName  = "Data"
        Endpoint = "forex/rates/latest"
        Method   = "Get"
        QueryString = "?currency_pairs=$CurrencyPairs"
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

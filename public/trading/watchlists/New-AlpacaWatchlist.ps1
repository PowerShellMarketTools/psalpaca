<#
.SYNOPSIS
Creates a new watchlist in the Alpaca trading platform.

.DESCRIPTION
The `New-AlpacaWatchlist` function allows users to create a new watchlist on the Alpaca trading platform. Users can specify a name for the watchlist and optionally add a list of symbols (e.g., stock or asset tickers) to the watchlist upon creation. This function supports both paper and live trading environments through the Alpaca API.

.PARAMETER Name
Specifies the name of the new watchlist. This parameter is mandatory.

.PARAMETER SymbolsToAdd
Specifies an array of symbols (e.g., "AAPL", "GOOGL") that will be added to the watchlist upon creation. This parameter is optional.

.PARAMETER Paper
Indicates whether the watchlist should be created in a paper trading environment. If not specified, the watchlist will be created in the live trading environment. This parameter is optional.

.EXAMPLE
New-AlpacaWatchlist -Name "MyWatchlist" -SymbolsToAdd "NFLX" -Paper
This example creates a new watchlist named "MyWatchlist" with the symbol "NFLX" in the paper trading environment.

.EXAMPLE
New-AlpacaWatchlist -Name "TechStocks" -SymbolsToAdd "AAPL","GOOGL","MSFT"
This example creates a new watchlist named "TechStocks" and adds three symbols ("AAPL", "GOOGL", "MSFT") to it in the live trading environment.

.NOTES
- Ensure that you have the necessary API keys and have set up the Alpaca API configuration before using this function.
- The Alpaca API has rate limits. Be mindful of these limits when making frequent API calls.
- This function is designed for use with the Alpaca trading platform and requires an Alpaca account.

.LINK
https://docs.alpaca.markets/reference/postwatchlist

#>

function New-AlpacaWatchlist {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [string[]]$SymbolsToAdd,

        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    $ApiParams = @{
        ApiName = "Trading"
        Endpoint = "watchlists"
        Method = "POST"
    }

    $BodyArguments = @{
        name = $Name
    }

    if ($SymbolsToAdd -and $SymbolsToAdd.Count -gt 0) {
        $BodyArguments.Add('symbols', $SymbolsToAdd)
    }

    if ($Paper) {
        $ApiParams.Add('Paper', $true)
    }

    Try {
        Write-Verbose "Invoking Alpaca API..."
        $Response = Invoke-AlpacaApi @ApiParams -BodyArguments $BodyArguments
        return $Response
    }
    Catch [System.Exception] {
        Write-Error "API call failed: $($_.Exception)"
        return $null
    }
}

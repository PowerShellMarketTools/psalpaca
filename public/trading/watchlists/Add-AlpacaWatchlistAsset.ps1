<#
.SYNOPSIS
Adds an asset to a specified Alpaca watchlist by either watchlist ID or watchlist name.

.DESCRIPTION
The Add-AlpacaWatchlistAsset function adds a specified symbol to an Alpaca watchlist. 
Users can specify the watchlist by providing either its unique identifier (WatchlistId) or its name (WatchlistName). 
This function supports both paper and live trading environments through the use of the Paper switch.

.PARAMETER WatchlistId
The unique identifier of the watchlist to which the asset will be added. This parameter is mandatory if WatchlistName is not provided.

.PARAMETER WatchlistName
The name of the watchlist to which the asset will be added. This parameter is mandatory if WatchlistId is not provided.

.PARAMETER SymbolToAdd
The symbol of the asset to be added to the watchlist. This parameter is required.

.PARAMETER Paper
A switch parameter that, when present, indicates that the operation should be performed in the paper trading environment instead of the live trading environment.

.EXAMPLE
PS> Add-AlpacaWatchlistAsset -WatchlistId '12345678-90ab-cdef-1234-567890abcdef' -SymbolToAdd 'AAPL'

Adds the asset with the symbol 'AAPL' to the watchlist with the specified ID in the live trading environment.

.EXAMPLE
PS> Add-AlpacaWatchlistAsset -WatchlistName 'Tech Stocks' -SymbolToAdd 'GOOGL' -Paper

Adds the asset with the symbol 'GOOGL' to the watchlist named 'Tech Stocks' in the paper trading environment.

.NOTES
This function requires an existing Alpaca account and appropriate API keys set up in the Invoke-AlpacaApi function to authenticate requests.

.LINK
https://docs.alpaca.markets/reference/addassettowatchlist

.LINK
https://docs.alpaca.markets/reference/addassettowatchlistbyname

#>

function Add-AlpacaWatchlistAsset {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false, ParameterSetName = 'ById')]
        [string]$WatchlistId,

        [Parameter(Mandatory = $false, ParameterSetName = 'ByName')]
        [string]$WatchlistName,

        [Parameter(Mandatory = $true)]
        [string]$SymbolToAdd,

        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    Write-Verbose "Preparing to add asset to watchlist..."

    if ($WatchlistId) {
        $ApiParams = @{
            ApiName  = "Trading"
            Endpoint = "watchlists/$($WatchlistId)"
            Method   = "POST"
        }
    }
    elseif ($WatchlistName) {
        $EncodedWatchlistName = [System.Uri]::EscapeDataString($WatchlistName)
        $ApiParams = @{
            ApiName     = "Trading"
            Endpoint    = "watchlists:by_name"
            Method      = "POST"
            QueryString = "?name=$($encodedWatchlistName)"
        }
    }    

    $BodyArguments = @{
        symbol = $SymbolToAdd
    }

    if ($Paper) {
        $ApiParams.Add('Paper', $true)
    }

    Try {
        Write-Verbose "Invoking Alpaca API to add asset to watchlist..."
        $Response = Invoke-AlpacaApi @ApiParams -BodyArguments $BodyArguments
        return $Response
    }
    Catch {
        Write-Error "API call failed: $($_.Exception.Message)"
        return $null
    }
}

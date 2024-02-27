<#
.SYNOPSIS
Updates the details of an existing Alpaca watchlist, including renaming it or updating its symbols list.

.DESCRIPTION
The Set-AlpacaWatchlist function allows users to update an existing Alpaca watchlist. Users can specify the watchlist by its ID or name and can update the list of symbols it contains or rename the watchlist. This function supports operations on both live and paper trading accounts.

.PARAMETER WatchlistId
The unique identifier of the watchlist to update. This parameter cannot be used in conjunction with the WatchlistName parameter.

.PARAMETER WatchlistName
The name of the watchlist to update. This parameter cannot be used in conjunction with the WatchlistId parameter. The name will be URL encoded to handle special characters.

.PARAMETER Symbols
An array of symbol strings that the watchlist will be updated to contain. If specified, the watchlist will be updated to only contain these symbols.

.PARAMETER NewName
The new name for the watchlist. If specified, the watchlist will be renamed to this name.

.PARAMETER Paper
A switch parameter that, when specified, indicates that the operation should be performed on the paper trading account instead of the live trading account.

.EXAMPLE
Set-AlpacaWatchlist -WatchlistId '12345' -Symbols 'AAPL','MSFT' -NewName 'Tech Stocks'

Updates the watchlist with ID '12345', renaming it to 'Tech Stocks' and updating its contents to include only AAPL and MSFT symbols.

.EXAMPLE
Set-AlpacaWatchlist -WatchlistName 'My Watchlist' -Symbols 'GOOG','AMZN' -Paper

Updates a paper trading account's watchlist named 'My Watchlist', changing its symbols to GOOG and AMZN.

.NOTES
This function requires the Invoke-AlpacaApi helper function to be defined in the scope of its execution. Ensure you have the necessary API key and secret configured for the Invoke-AlpacaApi function.

.LINK
https://docs.alpaca.markets/reference/updatewatchlistbyid

.LINK
https://docs.alpaca.markets/reference/updatewatchlistbyname

#>

function Set-AlpacaWatchlist {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false, ParameterSetName = 'ById')]
        [string]$WatchlistId,

        [Parameter(Mandatory = $false, ParameterSetName = 'ByName')]
        [string]$WatchlistName,

        [Parameter(Mandatory = $false)]
        [string[]]$Symbols,

        [Parameter(Mandatory = $false)]
        [string]$NewName,

        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    Write-Verbose "Preparing to set watchlist..."

    $ApiParams = @{}

    if ($WatchlistId) {
        $ApiParams = @{
            ApiName  = "Trading"
            Endpoint = "watchlists/$($WatchlistId)"
            Method   = "PUT"
        }
    }
    elseif ($WatchlistName) {
        $encodedName = [System.Web.HttpUtility]::UrlEncode($WatchlistName)
        $ApiParams = @{
            ApiName  = "Trading"
            Endpoint = "watchlists:by_name?name=$($encodedName)"
            Method   = "PUT"
        }
    }
    else {
        Write-Error "Either WatchlistId or WatchlistName must be specified."
        return
    }

    if ($Symbols -or $NewName) {
        $ApiParams.BodyArguments = @{}
    }
    if ($Symbols) {
        $ApiParams.BodyArguments.Add('symbols', $Symbols)
    }

    if ($NewName) {
        $ApiParams.BodyArguments.Add('name', $NewName)
    }

    if ($Paper) {
        $ApiParams.Add('Paper', $true)
    }

    Try {
        Write-Verbose "Invoking Alpaca API to retrieve watchlist..."
        $Response = Invoke-AlpacaApi @ApiParams
        return $Response
    }
    Catch {
        Write-Error "API call failed: $($_.Exception.Message)"
        return $null
    }
}
<#
.SYNOPSIS
Retrieves details of an Alpaca watchlist by either its ID or name.

.DESCRIPTION
The Get-AlpacaWatchlist function makes an API call to the Alpaca Trading API to retrieve details of a specific watchlist. 
Users can specify the watchlist they wish to retrieve either by providing its unique ID or by specifying its name. 
This function supports both live and paper trading environments.

.PARAMETER WatchlistId
The unique identifier of the watchlist to retrieve. This parameter cannot be used in conjunction with the WatchlistName parameter.

.PARAMETER WatchlistName
The name of the watchlist to retrieve. This parameter cannot be used in conjunction with the WatchlistId parameter.

.PARAMETER Paper
Specifies whether to operate in a paper trading environment. If not specified, the function defaults to the live trading environment.

.EXAMPLE
PS> Get-AlpacaWatchlist -WatchlistId "12345678-90ab-cdef-1234-567890abcdef"

This example retrieves the details of a watchlist by its ID.

.EXAMPLE
PS> Get-AlpacaWatchlist -WatchlistName "My Favorite Stocks" -Paper

This example retrieves the details of a watchlist by its name in a paper trading environment.

.NOTES
This function requires an existing connection to the Alpaca Trading API and utilizes the Invoke-AlpacaApi function to make HTTP requests. Ensure that the Invoke-AlpacaApi function is properly configured to handle API requests.

.LINK
https://docs.alpaca.markets/reference/getwatchlistbyid

.LINK
https://docs.alpaca.markets/reference/getwatchlistbyname

#>

function Get-AlpacaWatchlist {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false, ParameterSetName = 'ById')]
        [string]$WatchlistId,

        [Parameter(Mandatory = $false, ParameterSetName = 'ByName')]
        [string]$WatchlistName,

        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    Write-Verbose "Preparing to retrieve watchlist..."

    $ApiParams = @{}

    if ($WatchlistId) {
        $ApiParams = @{
            ApiName  = "Trading"
            Endpoint = "watchlists/$($WatchlistId)"
            Method   = "GET"
        }
    }
    elseif ($WatchlistName) {
        $encodedName = [System.Web.HttpUtility]::UrlEncode($WatchlistName)
        $ApiParams = @{
            ApiName  = "Trading"
            Endpoint = "watchlists:by_name?name=$($encodedName)"
            Method   = "GET"
        }
    }
    else {
        Write-Error "Either WatchlistId or WatchlistName must be specified."
        return
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

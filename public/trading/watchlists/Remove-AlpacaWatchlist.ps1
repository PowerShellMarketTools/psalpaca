<#
.SYNOPSIS
Removes a specified watchlist from Alpaca trading services.

.DESCRIPTION
The `Remove-AlpacaWatchlist` function allows users to delete a watchlist by specifying either its ID or name. It supports operations on both live and paper trading accounts. The function makes an API call to Alpaca's trading services to remove the specified watchlist. It includes a safety mechanism requiring confirmation before proceeding with the deletion, especially because this action has a high impact.

.PARAMETER WatchlistId
The unique identifier of the watchlist to be removed. This parameter is not mandatory if the WatchlistName is provided. However, if specified, the function will prioritize the WatchlistId over the WatchlistName.

.PARAMETER WatchlistName
The name of the watchlist to be removed. This parameter is not mandatory if the WatchlistId is provided. It is used to identify the watchlist to delete when the ID is not known or provided.

.PARAMETER Paper
A switch parameter that indicates whether the operation should be performed on a paper trading account. If this switch is not provided, the operation assumes a live trading environment by default.

.EXAMPLE
Remove-AlpacaWatchlist -WatchlistId "123456"

This example demonstrates how to remove a watchlist by specifying its ID. It will prompt for confirmation before proceeding with the deletion.

.EXAMPLE
Remove-AlpacaWatchlist -WatchlistName "My Favorite Stocks" -Paper

This example shows how to remove a watchlist by its name in a paper trading account. The function will encode the watchlist name for the API call and request confirmation before deleting the watchlist.

.NOTES
- The function requires either a WatchlistId or a WatchlistName to be specified. If neither is provided, it will terminate with an error.
- Operations on live trading accounts have significant financial implications. Users are advised to proceed with caution and confirm their intentions when prompted.

.LINK
https://docs.alpaca.markets/reference/deletewatchlistbyid

.LINK
https://docs.alpaca.markets/reference/deletewatchlistbyname

#>

function Remove-AlpacaWatchlist {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    Param (
        [Parameter(Mandatory = $false, ParameterSetName = 'ById')]
        [string]$WatchlistId,

        [Parameter(Mandatory = $false, ParameterSetName = 'ByName')]
        [string]$WatchlistName,

        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    Write-Verbose "Preparing to set watchlist..."

    $ApiParams = @{}

    if ($WatchlistId) {
        $ApiParams = @{
            ApiName  = "Trading"
            Endpoint = "watchlists/$($WatchlistId)"
            Method   = "DELETE"
        }
    }
    elseif ($WatchlistName) {
        $EncodedName = [System.Web.HttpUtility]::UrlEncode($WatchlistName)
        $ApiParams = @{
            ApiName  = "Trading"
            Endpoint = "watchlists:by_name?name=$($EncodedName)"
            Method   = "DELETE"
        }
    }
    else {
        Write-Error "Either WatchlistId or WatchlistName must be specified."
        return
    }

    if ($Paper) {
        $ApiParams.Add('Paper', $true)
    }

    if ($PSCmdlet.ShouldProcess("$($ApiParams.ApiName)/$($ApiParams.Endpoint)", "Delete Watchlist")) {
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
}

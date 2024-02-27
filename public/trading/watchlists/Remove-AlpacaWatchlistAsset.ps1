<#
.SYNOPSIS
Removes a specified asset from a watchlist on Alpaca trading services.

.DESCRIPTION
The `Remove-AlpacaWatchlistAsset` function allows users to delete a specific asset from a watchlist by specifying the watchlist's ID and the symbol of the asset to remove. This function is designed to work with both live and paper trading accounts on Alpaca. It executes an API call to Alpaca's trading services to perform the deletion. The operation requires confirmation before proceeding due to its high impact, ensuring that deletions are intentional.

.PARAMETER WatchlistId
Specifies the unique identifier of the watchlist from which the asset will be removed. This parameter is mandatory.

.PARAMETER Symbol
Defines the symbol of the asset to be removed from the watchlist. This parameter is mandatory.

.PARAMETER Paper
A switch parameter that, when specified, indicates that the operation should be performed on a paper trading account. If this switch is not provided, the function defaults to assuming a live trading account.

.EXAMPLE
Remove-AlpacaWatchlistAsset -WatchlistId "256b74f3-fa7c-4757-aa83-5a3c53729340" -Symbol "AAPL"

This example shows how to remove the asset with the symbol "AAPL" from the watchlist identified by "256b74f3-fa7c-4757-aa83-5a3c53729340". The operation will prompt for confirmation before executing the deletion.

.EXAMPLE
Remove-AlpacaWatchlistAsset -WatchlistId "256b74f3-fa7c-4757-aa83-5a3c53729340" -Symbol "GOOGL" -Paper

This example illustrates how to remove the "GOOGL" asset from a watchlist on a paper trading account. The function will encode the endpoint URL and require confirmation before proceeding with the removal.

.NOTES
- The function mandates the specification of both a WatchlistId and a Symbol to accurately identify the asset to be removed.
- Given the irreversible nature of deletion operations, users are prompted to confirm their action to prevent accidental loss of data.

.LINK
https://docs.alpaca.markets/reference/removeassetfromwatchlist

#>

function Remove-AlpacaWatchlistAsset {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$WatchlistId,

        [Parameter(Mandatory = $true)]
        [string]$Symbol,

        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    $ApiParams = @{
        ApiName  = "Trading"
        Endpoint = [System.Web.HttpUtility]::UrlEncode("watchlists/$($WatchlistId)/$($Symbol)")
        Method   = "DELETE"
    }

    if ($Paper) {
        $ApiParams.Add('Paper', $true)
    }

    if ($PSCmdlet.ShouldProcess("$($ApiParams.ApiName)/$($ApiParams.Endpoint)", "Delete Watchlist Symbol")) {
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

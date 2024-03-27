<#
.SYNOPSIS
    Retrieves the most active stocks by volume or trade count from the Alpaca API.

.DESCRIPTION
    This function retrieves the most active stocks by volume or trade count from the Alpaca API.

.PARAMETER By
    Specifies the metric used for ranking the most active stocks. Valid values are "volume" or "top".

.PARAMETER Top
    Specifies the number of top most active stocks to fetch per day.

.EXAMPLE
    Get-AlpacaMostActiveStocks -By "volume" -Top 10
    Retrieves the top 10 most active stocks by volume.

#>
Function Get-AlpacaMostActiveStocks {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("volume", "top")]
        [string]$By,

        [Parameter(Mandatory = $true)]
        [int]$Top
    )

    $QueryParameters = @{
        'by'   = $By
        'top'  = $Top
    }

    $ApiParams = @{
        ApiName  = "Data"
        Endpoint = "screener/stocks/most-actives"
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

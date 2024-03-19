<#
.SYNOPSIS
Retrieves market clock information from the Alpaca Trading API.

.DESCRIPTION
The Get-AlpacaMarketClockInfo cmdlet is used to retrieve market clock information from the Alpaca Trading API. It provides details about the current market status, including whether the market is open or closed, the current time, and the next market open and close times.

.PARAMETER Paper
Indicates whether to retrieve market clock information for paper trading. If this switch is provided, the information for the paper trading account is retrieved.

.EXAMPLE
Get-AlpacaMarketClockInfo

This example retrieves market clock information from the Alpaca Trading API for the live trading account.

.EXAMPLE
Get-AlpacaMarketClockInfo -Paper

This example retrieves market clock information from the Alpaca Trading API for the paper trading account.

.LINK
https://docs.alpaca.markets/reference/getclock-1

#>

Function Get-AlpacaMarketClockInfo {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    $ApiParams = @{
        ApiName  = "Trading"
        Endpoint = "clock"
        Method   = "Get"
    }

    if ($Paper) {
        $ApiParams.Add('Paper', $true)
    }

    Try {
        Invoke-AlpacaApi @ApiParams
    }
    Catch [System.Exception] {
        Write-Error $_.Exception
    }
}

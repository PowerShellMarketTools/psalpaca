<#
.SYNOPSIS
Retrieves all open positions from the Alpaca Trading API.

.DESCRIPTION
The Get-AllOpenAlpacaPositions function queries the Alpaca Trading API to fetch all open trading positions. 
It supports both live and paper (simulated) trading environments. The function uses the Invoke-AlpacaApi 
cmdlet to make API calls, handling both success and error responses gracefully.

.PARAMETER Paper
Specifies whether to retrieve positions from the paper (simulated) trading environment instead of the live trading environment. 
This parameter is not mandatory; if omitted, the function defaults to retrieving positions from the live trading environment.

.EXAMPLE
PS> Get-AllOpenAlpacaPositions

This example retrieves all open positions from the live trading environment.

.EXAMPLE
PS> Get-AllOpenAlpacaPositions -Paper

This example retrieves all open positions from the paper (simulated) trading environment.

.NOTES
- Requires an active Alpaca account and appropriate API keys set up for either live or paper trading.
- This function is part of the psalpaca module, which provides a PowerShell interface to the Alpaca Trading API.

.LINK
https://docs.alpaca.markets/reference/getallopenpositions

#>

function Get-AllOpenAlpacaPositions {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    $ApiParams = @{
        ApiName = "Trading"
        Endpoint = "positions"
        Method = "Get"
    }

    if ($Paper) {
        $ApiParams.Add('Paper', $true)
    }

    Try {
        Write-Verbose "Invoking Alpaca API..."
        $Response = Invoke-AlpacaApi @ApiParams
        return $Response
    }
    Catch [System.Exception] {
        Write-Error "API call failed: $($_.Exception)"
        return $null
    }
}

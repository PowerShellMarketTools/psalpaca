<#
.SYNOPSIS
Closes all open positions in Alpaca Trading.

.DESCRIPTION
The Remove-AllOpenAlpacaPositions cmdlet closes all open positions in Alpaca Trading, effectively selling all stocks (for long positions) or buying them back (for short positions) at the current market prices. It can be applied to both live and paper trading environments by specifying the -Paper switch. This cmdlet makes an API call to Alpaca's "DELETE positions" endpoint to close all open positions.

.PARAMETER Paper
Indicates whether to operate in the paper trading environment instead of the live trading environment. This parameter is optional. When specified, it targets the paper trading environment for closing positions.

.EXAMPLE
Remove-AllOpenAlpacaPositions

Closes all open positions in the live trading environment, liquidating all held stocks.

.EXAMPLE
Remove-AllOpenAlpacaPositions -Paper

Closes all open positions in the paper trading environment, liquidating all held stocks.

.NOTES
Author: [Your Name]
Requires: PowerShell 5.1 or higher, Alpaca PowerShell module

.LINK
https://docs.alpaca.markets/reference/deleteallopenpositions

#>
function Remove-AllOpenAlpacaPositions {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    $ApiParams = @{
        ApiName = "Trading"
        Endpoint = "positions"
        Method = "DELETE"
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

<#
.SYNOPSIS
Cancels all open orders in Alpaca Trading.

.DESCRIPTION
The Remove-AllAlpacaOrders cmdlet cancels all open orders in Alpaca Trading. It can be applied to both live and paper trading environments by specifying the -Paper switch. This cmdlet makes an API call to Alpaca's "DELETE orders" endpoint to remove all open orders.

.PARAMETER Paper
Indicates whether to operate in the paper trading environment instead of the live trading environment. This parameter is optional. When specified, it targets the paper trading environment for the operation.

.EXAMPLE
Remove-AllAlpacaOrders

Cancels all open orders in the live trading environment.

.EXAMPLE
Remove-AllAlpacaOrders -Paper

Cancels all open orders in the paper trading environment.

.NOTES
Author: [Your Name]
Requires: PowerShell 5.1 or higher, Alpaca PowerShell module

.LINK
https://docs.alpaca.markets/reference/deleteallorders

#>
function Remove-AllAlpacaOrders {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    $ApiParams = @{
        ApiName = "Trading"
        Endpoint = "orders"
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

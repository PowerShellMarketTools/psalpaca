<#
.SYNOPSIS
Removes an order from Alpaca Trading using its Order ID.

.DESCRIPTION
The Remove-AlpacaOrderById cmdlet removes an existing order from Alpaca Trading by its Order ID. It can target both live and paper trading environments. The cmdlet makes an API call to Alpaca's "DELETE orders/{order_id}" endpoint to remove the specified order.

.PARAMETER OrderId
The ID of the order to remove. This parameter is mandatory.

.PARAMETER Paper
Indicates whether to operate in the paper trading environment instead of the live trading environment. This parameter is optional. If used, it targets the paper trading environment for the operation.

.EXAMPLE
Remove-AlpacaOrderById -OrderId "e3a2ase1-d4c2-4556-9ac4-b84ad8a3a8ad"

Removes the specified order from the live trading environment.

.EXAMPLE
Remove-AlpacaOrderById -OrderId "e3a2ase1-d4c2-4556-9ac4-b84ad8a3a8ad" -Paper

Removes the specified order from the paper trading environment.

.NOTES
Author: [Your Name]
Requires: PowerShell 5.1 or higher, Alpaca PowerShell module

.LINK
https://docs.alpaca.markets/reference/deleteorderbyorderid

#>
function Remove-AlpacaOrderById {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$OrderId,

        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    $ApiParams = @{
        ApiName       = "Trading"
        Endpoint      = "orders"
        Method        = "DELETE"
        QueryString   = "/$($OrderId)"
    }

    if ($Paper) {
        $ApiParams.Add('Paper', $true)
        Write-Verbose "Accessing paper trading environment."
    }

    Try {
        Write-Verbose "Invoking Alpaca API to close order_id: $($OrderId)..."
        $Response = Invoke-AlpacaApi @ApiParams
        return $Response
    }
    Catch [System.Exception] {
        Write-Error "API call to close position failed: $($_.Exception)"
        return $null
    }
}

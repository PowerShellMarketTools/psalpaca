<#
.SYNOPSIS
Removes an order from Alpaca Trading using its Order ID.

.DESCRIPTION
The Remove-AlpacaOrderById cmdlet removes an existing order from Alpaca Trading by its Order ID. It can target both live and paper trading environments. The cmdlet makes an API call to Alpaca's "DELETE orders/{order_id}" endpoint to remove the specified order. Now supports -Confirm and -WhatIf parameters to provide additional control and safety before executing the operation.

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
The cmdlet now supports -Confirm and -WhatIf parameters for safer operation.

.LINK
https://docs.alpaca.markets/reference/deleteorderbyorderid

#>
Function Remove-AlpacaOrderById {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$OrderId,

        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    $ApiParams = @{
        ApiName     = "Trading"
        Endpoint    = "orders/$($OrderId)"
        Method      = "DELETE"
    }

    if ($Paper) {
        $ApiParams['Paper'] = $true
        Write-Verbose "Accessing paper trading environment."
    }

    if ($PSCmdlet.ShouldProcess($OrderId, "Remove order")) {
        Try {
            Write-Verbose "Invoking Alpaca API to remove order_id: $($OrderId)..."
            $Response = Invoke-AlpacaApi @ApiParams
            return $Response
        }
        Catch [System.Exception] {
            Write-Error "API call to remove order failed: $($_.Exception)"
            return $null
        }
    }
}

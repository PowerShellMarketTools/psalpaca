<#
.SYNOPSIS
Updates an existing order in Alpaca Trading.

.DESCRIPTION
The Set-AlpacaOrderById function updates an existing order based on the specified order ID. It allows updating various aspects of the order, such as quantity, time in force, limit price, and stop price. This function is designed to work within both the paper and live trading environments of Alpaca.

.PARAMETER OrderId
The unique identifier of the order to be updated.

.PARAMETER Quantity
The new quantity of shares for the order.

.PARAMETER TimeInForce
Specifies how long the order remains in effect. Acceptable values are 'Day', 'Gtc', 'Opg', 'Cls', 'Ioc', and 'Fok'.

.PARAMETER LimitPrice
The new limit price for the order. This is required for orders of type 'Limit' or 'Stop_limit'.

.PARAMETER StopPrice
The new stop price for the order. This is required for orders of type 'Stop' or 'Stop_limit'.

.PARAMETER TrailPrice
The new trail price for the order. This is applicable for orders of type 'Trailing_stop'.

.PARAMETER Paper
Indicates if the order update should be performed in the paper trading environment.

.EXAMPLE
PS> Set-AlpacaOrderById -OrderId 'abc123' -Quantity 100 -TimeInForce 'Gtc' -LimitPrice '150.00' -Paper

Updates an existing order with the ID 'abc123' to a quantity of 100 shares, with a 'Gtc' time in force and a limit price of $150.00 in the paper trading environment.

.NOTES
Author: Your Name
API Reference: For more details, visit the Alpaca API documentation.

.LINK
https://docs.alpaca.markets/reference/patchorderbyorderid

#>

function Set-AlpacaOrderById {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$OrderId,

        [Parameter(Mandatory = $false)]
        [int]$Quantity,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Day', 'Gtc', 'Opg', 'Cls', 'Ioc', 'Fok')]
        [string]$TimeInForce,

        [Parameter(Mandatory = $false)]
        [string]$LimitPrice,

        [Parameter(Mandatory = $false)]
        [string]$StopPrice,

        [Parameter(Mandatory = $false)]
        [string]$TrailPrice,

        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    Write-Verbose "Preparing to update order with ID: $OrderId"

    # Construct the body of the update request dynamically
    $BodyArguments = @{}
    if ($Quantity) { $BodyArguments.Add("qty", $Quantity) }
    if ($TimeInForce) { $BodyArguments.Add("time_in_force", $TimeInForce) }
    if ($LimitPrice) { $BodyArguments.Add("limit_price", $LimitPrice) }
    if ($StopPrice) { $BodyArguments.Add("stop_price", $StopPrice) }
    if ($TrailPrice) { $BodyArguments.Add("trail_price", $TrailPrice) }

    $ApiParams = @{
        ApiName       = "Trading"
        Endpoint      = "orders"
        Method        = "Patch"
        QueryString   = "/$($OrderId)"
        BodyArguments = $BodyArguments
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

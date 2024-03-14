<#
.SYNOPSIS
Retrieves a specific order from Alpaca Trading by order ID.

.DESCRIPTION
The Get-AlpacaOrderById function fetches a specific order from the Alpaca Trading platform using the order's unique ID. It supports an option to include nested orders within the response.

.PARAMETER OrderId
The unique identifier of the order to retrieve. This parameter is required.

.PARAMETER Nested
If set to $true, includes nested orders in the response. Defaults to $false.

.PARAMETER Paper
If provided, fetches the order from the paper trading environment instead of the live trading environment.

.EXAMPLE
PS> Get-AlpacaOrderById -OrderId 'your-order-id' -Paper

This example retrieves a specific order by its ID from the paper trading environment without including nested orders.

.EXAMPLE
PS> Get-AlpacaOrderById -OrderId 'your-order-id' -Nested $true

This example retrieves a specific order by its ID, including nested orders in the response.

.NOTES
Author: Your Name
API Reference: Check the Alpaca API documentation for more details about the order endpoints.

.LINK
https://docs.alpaca.markets/reference/getorderbyorderid

#>

function Get-AlpacaOrderById {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$OrderId,

        [Parameter(Mandatory = $false)]
        [bool]$Nested = $false,

        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    Write-Verbose "Preparing to retrieve order with ID: $OrderId"

    # Construct the endpoint path
    $ApiQueryStr = "/$($OrderId)"
    if ($Nested) {
        $ApiQueryStr += "?nested=$($Nested)"
    }

    $ApiParams = @{
        ApiName     = "Trading"
        Endpoint    = "orders"
        Method      = "Get"
        QueryString = $ApiQueryStr 
    }

    if ($Paper) {
        $ApiParams.Add('Paper', $true)
        Write-Verbose "Accessing paper trading environment."
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

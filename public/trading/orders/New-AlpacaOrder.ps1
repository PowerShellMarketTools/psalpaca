<#
.SYNOPSIS
Creates a new order with Alpaca Trading services.

.DESCRIPTION
The New-AlpacaOrder function creates an order for stocks via the Alpaca Trading API. 
It supports various order types, including market, limit, stop, and more. 
The function allows specifying order parameters such as symbol, quantity, price, and time in force.

.PARAMETER Symbol
The ticker symbol of the stock to order.

.PARAMETER Quantity
The quantity of shares to order. Cannot be used with Notional.

.PARAMETER Notional
The dollar amount to order. Cannot be used with Quantity.

.PARAMETER Side
Specifies the order side. It can be either 'Buy' or 'Sell'.

.PARAMETER Type
Defines the order type. Valid options are 'Market', 'Limit', 'Stop', 'Stop_limit', 'Trailing_stop'.

.PARAMETER TimeInForce
Specifies how long an order will remain active before it is executed or expires. 
Options include 'Day', 'Gtc' (Good Till Cancel), 'Opg', 'Cls', 'Ioc' (Immediate or Cancel), 'Fok' (Fill or Kill).

.PARAMETER LimitPrice
The price at which a limit order is executed. Required for Limit and Stop_limit orders.

.PARAMETER StopPrice
The price at which a stop order is triggered. Required for Stop and Stop_limit orders.

.PARAMETER TrailPrice
The trailing amount (dollar amount) for trailing stop orders.

.PARAMETER TrailPercent
The trailing amount (percentage) for trailing stop orders.

.PARAMETER ExtendedHours
Indicates if the order is allowed to be executed in extended hours trading.

.PARAMETER ClientOrderId
An optional client-specified order ID.

.PARAMETER OrderClass
Specifies the class of the order. Options are 'Simple', 'Bracket', 'Oco', 'Oto'.

.PARAMETER TakeProfit
Specifies the limit price for the take-profit order in a bracket order.

.PARAMETER StopLoss
Specifies the stop price and limit price (optional) for the stop-loss order in a bracket order.

.PARAMETER Paper
Specifies if the order should be created in a paper trading account.

.EXAMPLE
PS> New-AlpacaOrder -Symbol 'AAPL' -Quantity 10 -Side 'Buy' -Type 'Market' -TimeInForce 'Day' -OrderClass 'Simple' -Paper

This example creates a simple market order to buy 10 shares of AAPL for the day in paper trading mode.

.EXAMPLE
PS> New-AlpacaOrder -Symbol 'MSFT' -Notional 1000 -Side 'Sell' -Type 'Limit' -LimitPrice 215 -TimeInForce 'Gtc' -OrderClass 'Simple'

This example creates a limit order to sell MSFT shares with a notional value of $1000 at a limit price of $215, good till cancel.

.EXAMPLE
PS> $takeProfit = @{limit_price = 300}
PS> $stopLoss = @{stop_price = 250; limit_price = 245}
PS> New-AlpacaOrder -Symbol 'GOOG' -Quantity 5 -Side 'Buy' -Type 'Market' -TimeInForce 'Day' -OrderClass 'Bracket' -TakeProfit $takeProfit -StopLoss $stopLoss -Paper

This example creates a bracket order to buy 5 shares of GOOG at market price, with a take-profit order at $300 and a stop-loss order that triggers at $250 and has a limit price of $245, in paper trading mode.

.NOTES
Author: Nate Askoff
API Reference: Check the Alpaca API documentation for more details about the parameters and their values.

.LINK
https://docs.alpaca.markets/reference/postorder

#>
function New-AlpacaOrder {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Symbol,

        [Parameter(Mandatory = $false)]
        [int]$Quantity,

        [Parameter(Mandatory = $false)]
        [decimal]$Notional,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Buy', 'Sell')]
        [string]$Side,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Market', 'Limit', 'Stop', 'Stop_limit', 'Trailing_stop')]
        [string]$Type,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Day', 'Gtc', 'Opg', 'Cls', 'Ioc', 'Fok')]
        [string]$TimeInForce,

        [Parameter(Mandatory = $false)]
        [decimal]$LimitPrice,

        [Parameter(Mandatory = $false)]
        [decimal]$StopPrice,

        [Parameter(Mandatory = $false)]
        [decimal]$TrailPrice,

        [Parameter(Mandatory = $false)]
        [decimal]$TrailPercent,

        [Parameter(Mandatory = $false)]
        [bool]$ExtendedHours = $false,

        [Parameter(Mandatory = $false)]
        [string]$ClientOrderId,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Simple', 'Bracket', 'Oco', 'Oto')]
        [string]$OrderClass,

        [Parameter(Mandatory = $false)]
        [psobject]$TakeProfit,

        [Parameter(Mandatory = $false)]
        [psobject]$StopLoss,

        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    # Construct the API request body
    $Body = @{
        symbol = $Symbol
        side = $Side.ToLower()
        type = $Type.ToLower()
        time_in_force = $TimeInForce.ToLower()
        order_class = $OrderClass.ToLower()
    }

    if ($Quantity) { $Body.Add('qty', $Quantity) }
    elseif ($Notional) { $Body.Add('notional', $Notional) }

    if ($LimitPrice) { $Body.Add('limit_price', $LimitPrice) }
    if ($StopPrice) { $Body.Add('stop_price', $StopPrice) }
    if ($TrailPrice) { $Body.Add('trail_price', $TrailPrice) }
    if ($TrailPercent) { $Body.Add('trail_percent', $TrailPercent) }
    if ($ExtendedHours) { $Body.Add('extended_hours', $True) }
    if ($ClientOrderId) { $Body.Add('client_order_id', $ClientOrderId) }
    if ($TakeProfit) { $Body.Add('take_profit', $TakeProfit) }
    if ($StopLoss) { $Body.Add('stop_loss', $StopLoss) }

    # API Params
    $ApiParams = @{
        ApiName       = "Trading"
        Endpoint      = "orders"
        Method        = "Post"
        BodyArguments = $Body
        Paper         = $Paper
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

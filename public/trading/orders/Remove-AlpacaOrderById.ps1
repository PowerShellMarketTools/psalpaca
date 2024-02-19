<#
.SYNOPSIS
Liquidates a specific quantity or percentage of a position in Alpaca Trading by symbol or asset ID.

.DESCRIPTION
The Remove-AlpacaPositionById function liquidates a specific quantity or percentage of a position for a given symbol or asset ID on the Alpaca Trading platform. It allows for specifying either the number of shares to liquidate or the percentage of the position to liquidate.

.PARAMETER SymbolOrAssetId
The symbol or asset ID of the position to liquidate. This parameter is required.

.PARAMETER Quantity
The number of shares to liquidate. Accepts up to 9 decimal points. Cannot be used with the Percentage parameter.

.PARAMETER Percentage
The percentage of the position to liquidate, must be between 0 and 100. This will only sell fractional if the position is originally fractional. Accepts up to 9 decimal points. Cannot be used with the Quantity parameter.

.PARAMETER Paper
If provided, performs the operation in the paper trading environment instead of the live trading environment.

.EXAMPLE
PS> Remove-AlpacaPositionById -SymbolOrAssetId 'AAPL' -Quantity 10 -Paper

This example liquidates 10 shares of AAPL from the paper trading environment.

.EXAMPLE
PS> Remove-AlpacaPositionById -SymbolOrAssetId 'GOOGL' -Percentage 50

This example liquidates 50% of the GOOGL position in the live trading environment.

.NOTES
Author: Your Name
API Reference: For more details about the position liquidation endpoints, check the Alpaca API documentation.

.LINK
[Alpaca API Documentation URL]

#>

function Remove-AlpacaPositionByIdById {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$SymbolOrAssetId,

        [Parameter(Mandatory = $false)]
        [decimal]$Quantity,

        [Parameter(Mandatory = $false)]
        [decimal]$Percentage,

        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    if (-not $Quantity -and -not $Percentage) {
        Write-Error "Either Quantity or Percentage must be specified."
        return
    }

    if ($Quantity -and $Percentage) {
        Write-Error "Only specify one of: Quantity / Percentage."
        return
    }

    $ApiQueryStr = "/$($SymbolOrAssetId)"
    if ($Quantity) {
        $ApiQueryStr += "?qty=$Quantity"
    } elseif ($Percentage) {
        $ApiQueryStr += "?percentage=$Percentage"
    }

    $ApiParams = @{
        ApiName     = "Trading"
        Endpoint    = "positions"
        Method      = "DELETE"
        QueryString = $ApiQueryStr 
    }

    if ($Paper) {
        $ApiParams.Add('Paper', $true)
        Write-Verbose "Accessing paper trading environment."
    }

    Try {
        Write-Verbose "Invoking Alpaca API for position liquidation..."
        $Response = Invoke-AlpacaApi @ApiParams
        return $Response
    }
    Catch [System.Exception] {
        Write-Error "API call to close position failed: $($_.Exception)"
        return $null
    }
}

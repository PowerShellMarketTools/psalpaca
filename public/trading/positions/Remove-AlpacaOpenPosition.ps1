<#
.SYNOPSIS
Closes (liquidates) the account's open position for a specified symbol or asset ID in Alpaca Trading.

.DESCRIPTION
The Remove-AlpacaPositionBySymbol function liquidates an open position for the given symbol or asset ID in Alpaca Trading. It supports both long and short positions. Users can specify either a quantity (Quantity) or a percentage of the position to liquidate. The function can target either the live or paper trading environment.

.PARAMETER SymbolOrAssetId
The symbol or asset ID of the position to liquidate. This parameter is mandatory.

.PARAMETER Quantity
The number of shares to liquidate. This parameter is optional and cannot be used in conjunction with the 'Percentage' parameter. Accepts up to 9 decimal points.

.PARAMETER Percentage
The percentage of the position to liquidate, must be between 0 and 100. This parameter is optional and cannot be used in conjunction with the 'Quantity' parameter. The function will only sell fractional shares if the position is originally fractional. Accepts up to 9 decimal points.

.PARAMETER Paper
Indicates whether to operate in the paper trading environment. This parameter is optional. When specified, the function targets the paper trading environment.

.EXAMPLE
Remove-AlpacaPositionBySymbol -SymbolOrAssetId "AAPL" -Quantity 10

Liquidates 10 shares of the AAPL position in the live trading environment.

.EXAMPLE
Remove-AlpacaPositionBySymbol -SymbolOrAssetId "AAPL" -Percentage 50 -Paper

Liquidates 50% of the AAPL position in the paper trading environment.

.NOTES
Author: [Your Name]
Requires: PowerShell 5.1 or higher, Alpaca PowerShell module

.LINK
https://docs.alpaca.markets/reference/deleteopenposition

#>

function Remove-AlpacaPositionBySymbol {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$SymbolOrAssetId,

        [Parameter(Mandatory = $false)]
        [double]$Quantity,

        [Parameter(Mandatory = $false)]
        [double]$Percentage,

        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    $ApiParams = @{
        ApiName = "Trading"
        Endpoint = "positions/$SymbolOrAssetId"
        Method = "DELETE"
    }

    # Validate that either Quantity or Percentage is provided, but not both
    if (-not [string]::IsNullOrWhiteSpace($Quantity) -and -not [string]::IsNullOrWhiteSpace($Percentage)) {
        Write-Error "Specify one of: 'Quantity' or 'Percentage'."
        return $null
    } elseif (-not [string]::IsNullOrWhiteSpace($Quantity)) {
        $ApiParams.Add('QueryString', "?Quantity=$($Quantity)")
    } elseif (-not [string]::IsNullOrWhiteSpace($Percentage)) {
        if ($Percentage -le 0 -or $Percentage -gt 100) {
            Write-Error "Percentage must be between 0 and 100."
            return $null
        }
        $ApiParams.Add('QueryString', "?percentage=$($Percentage)")
    } else {
        Write-Error "Either 'Quantity' or 'Percentage' must be specified."
        return $null
    }

    if ($Paper) {
        $ApiParams.Add('Paper', $true)
    }

    Try {
        Write-Verbose "Invoking Alpaca API to liquidate position for symbol: $SymbolOrAssetId..."
        $Response = Invoke-AlpacaApi @ApiParams
        return $Response
    }
    Catch [System.Exception] {
        Write-Error "API call to liquidate position failed: $($_.Exception)"
        return $null
    }
}

<#
.SYNOPSIS
Retrieves the account's open position for a specified symbol or asset ID from Alpaca Trading.

.DESCRIPTION
The Get-OpenAlpacaPosition cmdlet retrieves details about the account's open position for the given symbol or asset ID in Alpaca Trading. It targets either the live or paper trading environment, providing information such as the current quantity of shares, average entry price, and current market value of the position.

.PARAMETER SymbolOrAssetId
The symbol or asset ID of the open position to retrieve. This parameter is mandatory.

.PARAMETER Paper
Indicates whether to operate in the paper trading environment. This parameter is optional. When specified, the function targets the paper trading environment.

.EXAMPLE
Get-OpenAlpacaPosition -SymbolOrAssetId "AAPL"

Retrieves details of the open AAPL position in the live trading environment.

.EXAMPLE
Get-OpenAlpacaPosition -SymbolOrAssetId "AAPL" -Paper

Retrieves details of the open AAPL position in the paper trading environment.

.NOTES
Author: [Your Name]
Requires: PowerShell 5.1 or higher, Alpaca PowerShell module

.LINK
https://alpaca.markets/docs/api-documentation/api-v2/positions/#get-an-open-position

#>
function Get-OpenAlpacaPosition {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$SymbolOrAssetId,

        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    $ApiParams = @{
        ApiName = "Trading"
        Endpoint = "positions"
        Method = "GET"
        QueryString = "/$($SymbolOrAssetId)"
    }

    if ($Paper) {
        $ApiParams.Add('Paper', $true)
    }

    Try {
        Write-Verbose "Retrieving open position for symbol/asset ID: $SymbolOrAssetId..."
        $Response = Invoke-AlpacaApi @ApiParams
        return $Response
    }
    Catch [System.Exception] {
        Write-Error "API call to retrieve open position failed: $($_.Exception)"
        return $null
    }
}

<#
.SYNOPSIS
    Retrieves the latest trades data for cryptocurrencies from the Alpaca API.

.DESCRIPTION
    This function retrieves the latest trades data for cryptocurrencies from the Alpaca API based on the specified location and symbols.

.PARAMETER Location
    Specifies the location for which the data is to be retrieved. Currently, only "US" is supported.

.PARAMETER Symbols
    Specifies the symbols of the cryptocurrencies for which latest trades data is to be retrieved. Should be in the format 'CURRENCY\CURRENCY', e.g., BTC/USD, USD/ETH, etc.

.EXAMPLE
    Get-AlpacaCryptoLatestTradesData -Location "US" -Symbols "BTC/USD"
    Retrieves the latest trades data for the BTC/USD pair.

#>
Function Get-AlpacaCryptoLatestTradesData {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("US")]
        [string]$Location,

        [Parameter(Mandatory = $true)]
        [string]$Symbols
    )

    Write-Verbose "Retrieving latest trades data for $Symbols from Alpaca API..."

    $ApiParams = @{
        ApiName  = "Data"
        Endpoint = "crypto/$($Location.ToLower())/latest/trades"
        Method   = "Get"
        QueryString = "?symbols=$Symbols"
    }

    Try {
        $Response = Invoke-AlpacaApi @ApiParams
        return $Response
    }
    Catch [System.Exception] {
        Write-Error "API call failed: $($_.Exception)"
        return $null
    }
}

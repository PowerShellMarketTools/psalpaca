<#
.SYNOPSIS
    Retrieves the latest trades data for stocks from the Alpaca API.

.DESCRIPTION
    This function retrieves the latest trades data for stocks from the Alpaca API based on the specified symbols, feed, and currency.

.PARAMETER Symbols
    Specifies the symbols of the stocks for which the latest data is to be retrieved. Should be provided as an array of strings, e.g., @("AAPL", "GOOGL", "MSFT").

.PARAMETER Feed
    Specifies the feed for retrieving data. Valid values are "IEX", "OTP", "SIP". Optional.

.PARAMETER Currency
    Specifies the currency for retrieving data. Optional.

.EXAMPLE
    Get-AlpacaStockLatestTrades -Symbols @("AAPL", "GOOGL", "MSFT") -Feed "IEX" -Currency "USD"
    Retrieves the latest trades data for AAPL, GOOGL, and MSFT stocks with feed "IEX" and currency "USD".
#>

Function Get-AlpacaStockLatestTrades {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string[]]$Symbols,

        [Parameter(Mandatory = $false)]
        [ValidateSet("IEX", "OTP", "SIP")]
        [string]$Feed,

        [Parameter(Mandatory = $false)]
        [string]$Currency
    )

    $QueryParameters = @{}
    $QueryParameters.Add('symbols', ($Symbols -join ',').ToLower())

    if ($Feed) {
        $QueryParameters.Add('feed', $Feed.ToLower())
    }

    if ($Currency) {
        $QueryParameters.Add('currency', $Currency.ToUpper())
    }

    $ApiParams = @{
        ApiName  = "Data"
        Endpoint = "stocks/trades/latest"
        Method   = "Get"
    }

    if ($QueryParameters.Count -gt 0) {
        $ApiParams.Add(
            'QueryString',
            ('?' + (
                ($QueryParameters.GetEnumerator() | ForEach-Object {
                    "$($_.Key)=$([System.Web.HttpUtility]::UrlEncode($_.Value))" }
                ) -join '&'
            ))
        )
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

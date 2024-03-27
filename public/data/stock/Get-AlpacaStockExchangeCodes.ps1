<#
.SYNOPSIS
    Retrieves exchange codes for Alpaca stocks.

.DESCRIPTION
    This function retrieves exchange codes for Alpaca stocks.

.PARAMETER None
    This cmdlet does not accept any parameters.

.EXAMPLE
    Get-AlpacaStockExchangeCodes
    Retrieves exchange codes for Alpaca stocks.

.NOTES
    Author: [Author Name]
    Date: [Date]
    Version: [Version Number]
#>

Function Get-AlpacaStockExchangeCodes {
    [CmdletBinding()]
    Param ()

    $ApiParams = @{
        ApiName  = "Data"
        Endpoint = "stocks/meta/exchanges"
        Method   = "Get"
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

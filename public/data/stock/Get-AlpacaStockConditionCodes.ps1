<#
.SYNOPSIS
    Retrieves condition codes for Alpaca stocks based on the specified tick type and tape.

.DESCRIPTION
    This function retrieves condition codes for Alpaca stocks based on the specified tick type (Trade or Quote)
    and tape (A, B, or C).

.PARAMETER TickType
    Specifies the type of tick data to retrieve condition codes for. Accepted values are "Trade" or "Quote".

.PARAMETER Tape
    Specifies the tape to retrieve condition codes for. Accepted values are "A", "B", or "C".

.EXAMPLE
    Get-AlpacaStockConditionCodes -TickType Trade -Tape A
    Retrieves condition codes for Alpaca stocks based on trade ticks and tape A.

.EXAMPLE
    Get-AlpacaStockConditionCodes -TickType Quote -Tape B
    Retrieves condition codes for Alpaca stocks based on quote ticks and tape B.

.NOTES
    Author: [Author Name]
    Date: [Date]
    Version: [Version Number]
#>
Function Get-AlpacaStockConditionCodes {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Trade', 'Quote')]
        [string]$TickType,

        [Parameter(Mandatory = $true)]
        [ValidateSet('A', 'B', 'C')]
        [string]$Tape
    )

    $ApiParams = @{
        ApiName  = "Data"
        Endpoint = "stocks/meta/conditions"
        Method   = "Get"
        Query    = @{
            tick_type = $TickType
            tape      = $Tape
        }
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

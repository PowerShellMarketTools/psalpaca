<#
.SYNOPSIS
Closes all open positions in Alpaca Trading.

.DESCRIPTION
The Remove-AllOpenAlpacaPositions cmdlet closes all open positions in Alpaca Trading, effectively selling all stocks (for long positions) or buying them back (for short positions) at the current market prices. It can be applied to both live and paper trading environments by specifying the -Paper switch. This cmdlet makes an API call to Alpaca's "DELETE positions" endpoint to close all open positions. It supports the -Confirm and -WhatIf parameters, allowing the user to confirm the operation or simulate it.

.PARAMETER Paper
Indicates whether to operate in the paper trading environment instead of the live trading environment. This parameter is optional. When specified, it targets the paper trading environment for closing positions.

.EXAMPLE
Remove-AllOpenAlpacaPositions

Closes all open positions in the live trading environment, liquidating all held stocks. The cmdlet prompts for confirmation before proceeding with the operation if the ConfirmPreference is set to Medium or lower.

.EXAMPLE
Remove-AllOpenAlpacaPositions -Paper -Confirm:$false

Closes all open positions in the paper trading environment without prompting for confirmation, liquidating all held stocks.

.EXAMPLE
Remove-AllOpenAlpacaPositions -WhatIf

Shows what actions the cmdlet would take to close all open positions without actually making any changes.

.NOTES
Author: [Your Name]
Requires: PowerShell 5.1 or higher, Alpaca PowerShell module
The cmdlet now supports -Confirm and -WhatIf parameters, providing additional control and safety for the operation.

.LINK
https://docs.alpaca.markets/reference/deleteallopenpositions
#>
function Remove-AllOpenAlpacaPositions {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    Param (
        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    $ApiParams = @{
        ApiName = "Trading"
        Endpoint = "positions"
        Method = "DELETE"
    }

    if ($Paper) {
        $ApiParams.Add('Paper', $true)
    }

    if ($PSCmdlet.ShouldProcess("$($ApiParams.ApiName)/$($ApiParams.Endpoint)/ALL_POSITIONS", "Close all open positions")) {
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
    else {
        Write-Verbose "Operation cancelled by user."
    }
}

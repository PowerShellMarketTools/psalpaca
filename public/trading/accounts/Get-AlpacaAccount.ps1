<#
.SYNOPSIS
Retrieves account information from the Alpaca Trading API.

.DESCRIPTION
The Get-AlpacaAccount cmdlet is used to retrieve account information from the Alpaca Trading API. It provides details about the account balance, equity, buying power, and other relevant account information.

.PARAMETER Paper
Indicates whether to retrieve account information for paper trading. If this switch is provided, the information for the paper trading account is retrieved.

.EXAMPLE
Get-AlpacaAccount

This example retrieves account information from the Alpaca Trading API for the live trading account.

.EXAMPLE
Get-AlpacaAccount -Paper

This example retrieves account information from the Alpaca Trading API for the paper trading account.

.LINK
https://docs.alpaca.markets/reference/getaccount-1

#>

function Get-AlpacaAccount {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    $ApiParams = @{
        ApiName = "Trading"
        Endpoint = "account"
        Method = "Get"
    }

    if ($Paper) {
        $ApiParams.Add('Paper', $true)
    }

    Try {
        Invoke-AlpacaApi @ApiParams
    }
    Catch [System.Exception] {
        Write-Error $_.Exception
    }
}

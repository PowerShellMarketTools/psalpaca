<#
.SYNOPSIS
Retrieves account configuration information from the Alpaca Trading API.

.DESCRIPTION
The Get-AlpacaAccountConfiguration cmdlet is used to retrieve account configuration information from the Alpaca Trading API. It provides details about the account settings, including margin requirements, order types allowed, and other account-specific configurations.

.PARAMETER Paper
Indicates whether to retrieve account configuration for paper trading. If this switch is provided, the configuration for the paper trading account is retrieved.

.EXAMPLE
Get-AlpacaAccountConfiguration

This example retrieves account configuration information from the Alpaca Trading API for the live trading account.

.EXAMPLE
Get-AlpacaAccountConfiguration -Paper

This example retrieves account configuration information from the Alpaca Trading API for the paper trading account.

.LINK
https://docs.alpaca.markets/reference/getaccountconfig-1

#>

function Get-AlpacaAccountConfiguration {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    $ApiParams = @{
        ApiName  = "Trading"
        Endpoint = "account/configurations"
        Method   = "Get"
    }

    if ($Paper) {
        $ApiParams.Add('Paper', $true)
        Write-Verbose "Paper trading mode enabled."
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

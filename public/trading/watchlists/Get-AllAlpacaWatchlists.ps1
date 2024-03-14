<#
.SYNOPSIS
Retrieves all watchlists from the Alpaca Trading API.

.DESCRIPTION
The Get-AllAlpacaWatchlists function queries the Alpaca Trading API to fetch all watchlists created by the user. 
It supports querying watchlists from both live and paper (simulated) trading accounts. Utilizing the Invoke-AlpacaApi 
cmdlet, it performs a GET request to the watchlists endpoint, handling success and error responses accordingly.

.PARAMETER Paper
Indicates whether to retrieve watchlists from the paper (simulated) trading environment rather than the live trading environment. 
This parameter is optional. When not specified, the function defaults to retrieving watchlists from the live trading environment.

.EXAMPLE
PS> Get-AllAlpacaWatchlists

Executes the function to retrieve all watchlists from the live trading environment, demonstrating the default behavior when no parameters are specified.

.EXAMPLE
PS> Get-AllAlpacaWatchlists -Paper

Executes the function to retrieve all watchlists from the paper trading environment, illustrating how to use the -Paper switch to specify the environment.

.NOTES
- An active Alpaca account and the corresponding API keys for live or paper trading are prerequisites for using this function.
- The Invoke-AlpacaApi cmdlet is required for this function's operation and must be present in your PowerShell session.
- This function is a part of the psalpaca module, which provides PowerShell interfaces to interact with the Alpaca Trading API.

.LINK
https://docs.alpaca.markets/reference/getwatchlists

#>

Function Get-AllAlpacaWatchlists.ps1 {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false)]
        [switch]$Paper
    )

    $ApiParams = @{
        ApiName  = "Trading"
        Endpoint = "watchlists"
        Method   = "Get"
    }

    if ($Paper) {
        $ApiParams.Add('Paper', $true)
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
function Get-AlpacaAccountConfigurations {
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

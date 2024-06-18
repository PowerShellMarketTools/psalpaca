Function Get-AlpacaCryptoLatestBarsData {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("US")]
        [string]$Location,

        [Parameter(Mandatory = $true)]
        [string]$Symbols
    )

    Write-Verbose "Retrieving latest bars data for $Symbols from Alpaca API..."

    $ApiParams = @{
        ApiName  = "Data"
        Endpoint = "crypto/$($Location.ToLower())/latest/bars"
        Method   = "Get"
        QueryString = "?symbols=$Symbols"
    }

    Try {
        $Response = Invoke-AlpacaApi @ApiParams
        if ($Response.bars.Count -eq 0) {
            Write-Verbose "No bars data found for $Symbols."
            return $null
        }
        return $Response
    }
    Catch [System.Exception] {
        Write-Error "API call failed: $($_.Exception)"
        return $null
    }
}
